  // ------------------------------------------------------ theme frame overlay
  // A theme opts in by setting `frame` under [lock] in its shell.lock.toml.
  // omarchy-theme-set-templates splices that section into the staged shell.toml
  // verbatim and Color.parseShell keeps keys it does not recognise, so carrying
  // this needs no change to Omarchy itself. A theme that sets nothing leaves
  // frameAsset empty and no image is ever loaded.
  readonly property string frameAsset: String(Color.shellValues["lock.frame"] || "")
  // Relative, inside the theme directory, or not used at all.
  readonly property bool frameAssetSafe: frameAsset !== ""
    && frameAsset.charAt(0) !== "/" && frameAsset.indexOf("..") === -1

  // omarchy-theme-set rebuilds the staged theme directory wholesale (rm -rf +
  // mv), so Color.currentThemePath is byte-identical for every theme and the
  // loader would hand back the previous theme's frame. Color.shellValues is
  // reassigned on every theme apply -- including the IPC push that bypasses
  // file watching -- so bumping a counter off it gives the URL something that
  // actually changes. Same ?v= trick as fileUrl() above.
  property int frameVersion: 0
  readonly property var frameThemeToken: Color.shellValues
  onFrameThemeTokenChanged: frameVersion++

  readonly property string frameUrl: root.loadBackground && frameAssetSafe
    ? Util.fileUrl(Color.currentThemePath + "/" + frameAsset) + "?v=" + frameVersion
    : ""

  // ------------------------------------------------------ lock screen fade-in
  // Hyprland animates a session lock in neither direction -- it has no
  // animation leaf for one, and an ext-session-lock surface is not a layer
  // surface, so no layer_rule can reach it either. A theme opts in with
  // `fade-duration` under [lock], the same unrecognised-key channel as `frame`
  // above.
  //
  // The fade needs nothing to fade against: WlSessionLockSurface is set to
  // Color.background and this view's own first child is an opaque Rectangle of
  // that same colour, so fading the whole view lifts the wallpaper, the frame
  // and the passphrase field up out of a backdrop that never itself changes.
  readonly property int lockFadeMs: {
    var n = Number(Color.shellValues["lock.fade-duration"])
    if (!isFinite(n) || n <= 0) return 0
    // Capped rather than trusted: on the way out this is time the session
    // stays locked after a correct password.
    return Math.min(1000, Math.round(n))
  }

  // Driven from Service.qml when the unlock half is installed. That half is
  // gated separately by the installer, so on an Omarchy where it did not apply
  // this stays false and the fade-in still works by itself.
  property bool dismissing: false
  property bool revealCapped: false

  // Held down until the blurred wallpaper has decoded. It takes around 400ms
  // here, which lands squarely mid-fade: without this the view finishes
  // rising on a bare background colour and the wallpaper then appears
  // underneath it, which reads as a fault rather than a fade. loadBackground
  // is "this view is showing" in both hosts -- the lock surface binds it to
  // root.locked, the preview window to previewVisible -- so this also re-arms
  // for the preview, whose LockView is built once and then toggled.
  readonly property bool revealed: root.loadBackground
    && (root.revealCapped || wallpaper.status === Image.Ready)

  opacity: (revealed && !dismissing) ? 1 : 0

  Behavior on opacity {
    enabled: root.lockFadeMs > 0
    NumberAnimation { duration: root.lockFadeMs; easing.type: Easing.OutCubic }
  }

  onLoadBackgroundChanged: if (!root.loadBackground) root.revealCapped = false

  // The wait is capped so a slow, missing or unreadable wallpaper costs a
  // fixed delay rather than holding the passphrase field back for good. Not
  // Component.onCompleted: LockView.qml already has one, and a second is a
  // duplicate-assignment error.
  Timer {
    id: revealCapTimer
    interval: 700
    repeat: false
    running: root.loadBackground
    onTriggered: root.revealCapped = true
  }

