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

  // ------------------------------------------------------ password mask glyph
  // Omarchy masks the password with U+25CF (LockView sets passwordCharacter
  // explicitly). A theme can swap that for a character out of a font it ships
  // itself -- in Sheikah Complete the period is a rune, so the field fills
  // with runes as you type.
  //
  // The font is loaded straight out of the theme directory rather than
  // installed on the machine, which keeps it travelling with the theme and
  // leaves nothing behind on a switch. It is also the only arrangement that
  // can tell whether the font actually arrived: FontLoader reports a status,
  // where a named system family is silently substituted when missing. That
  // matters more here than anywhere else in the theme -- a "." drawn in the
  // ordinary UI font is a mask you can barely see.
  readonly property string runeFontAsset: String(Color.shellValues["lock.password-char-font"] || "")
  // Relative, inside the theme directory, or not used at all -- same rule as
  // the frame asset above.
  readonly property bool runeFontAssetSafe: runeFontAsset !== ""
    && runeFontAsset.charAt(0) !== "/" && runeFontAsset.indexOf("..") === -1
  readonly property string runeFontUrl: runeFontAssetSafe
    ? Util.fileUrl(Color.currentThemePath + "/" + runeFontAsset) : ""

  // Held behind a Loader rather than declared outright: a FontLoader handed an
  // empty source warns, and a theme that names no font would otherwise log
  // "Cannot load font" on every apply. Inactive means no FontLoader exists at
  // all, so every other theme stays quiet.
  Loader {
    id: runeFontLoader
    active: root.runeFontAssetSafe
    sourceComponent: FontLoader { source: root.runeFontUrl }
  }

  readonly property bool runeFontReady: runeFontLoader.item !== null
    && runeFontLoader.item.status === FontLoader.Ready
    && String(runeFontLoader.item.name || "").length > 0
  readonly property string runeFontName: runeFontReady ? runeFontLoader.item.name : ""

  readonly property string runeChar: String(Color.shellValues["lock.password-char"] || "")
  readonly property real runeScale: {
    var n = Number(Color.shellValues["lock.password-char-scale"])
    return (isFinite(n) && n > 0) ? Math.min(3, n) : 1
  }

  // Everything below hangs off this one gate. A theme that names no character,
  // or names a font that does not load, leaves it false -- every Binding then
  // stands down and the field keeps the stock bullet it always had.
  readonly property bool runeReady: runeChar.length > 0 && root.runeFontReady

  // Bindings rather than edits in place: the lines that would otherwise need
  // changing are not all uniquely anchorable -- `font.family: Style.font.family`
  // occurs three times at the same indent -- but both objects carry ids, so
  // they can be retargeted from here. `when` false restores the original
  // binding, which is what makes this revert cleanly on a theme switch.
  //
  // dotMetrics has to move in step with the field, not be left behind:
  // passwordDotScale is derived from its advanceWidth, and that is what
  // shrinks the row so a long password stays visible instead of clipping.
  // The rune is about 1.5x the bullet's advance, so leaving the metrics on the
  // old glyph would mis-measure every password.
  Binding {
    target: dotMetrics
    property: "font.family"
    when: root.runeReady
    value: root.runeFontName
  }
  Binding {
    target: dotMetrics
    property: "text"
    when: root.runeReady
    value: root.runeChar.repeat(passwordInput.text.length)
  }
  Binding {
    target: dotMetrics
    property: "font.pixelSize"
    when: root.runeReady
    value: Math.max(1, Math.round(root.passwordDotFontSize * root.runeScale))
  }

  Binding {
    target: passwordInput
    property: "passwordCharacter"
    when: root.runeReady
    value: root.runeChar
  }
  Binding {
    target: passwordInput
    property: "font.family"
    when: root.runeReady
    value: root.runeFontName
  }
  // Mirrors the stock expression with the theme's scale folded in; the empty
  // field still falls back to fieldFontSize so the caret keeps its size.
  Binding {
    target: passwordInput
    property: "font.pixelSize"
    when: root.runeReady
    value: passwordInput.text.length > 0
      ? Math.max(1, Math.floor(root.passwordDotFontSize * root.runeScale * root.passwordDotScale))
      : root.fieldFontSize
  }

