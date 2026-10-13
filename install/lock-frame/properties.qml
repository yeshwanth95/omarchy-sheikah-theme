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

