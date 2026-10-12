import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// A stand-in for omarchy.workspaces. Everything above the quest-marker
// divider is the built-in widget verbatim; the only behavioural change is the
// focused slot, which shows the active theme's marker artwork when that theme
// ships one. Themes that do not are left with the stock Nerd Font dot, so this
// is safe to leave enabled permanently.
BarWidget {
  id: root
  // Overwritten by the bar with the layout entry id. Kept as the built-in's
  // name so IPC aimed at omarchy.workspaces still resolves here.
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  // -------------------------------------------------------- quest marker

  // Tunable per bar entry, e.g.
  //   omarchy bar set sheikah.workspaces markerScale 1.15
  readonly property string markerAsset: String(root.setting("markerAsset", "assets/quest_marker.svg"))
  readonly property real markerScale: {
    var n = Number(root.setting("markerScale", 1))
    return isFinite(n) && n > 0 ? n : 1
  }
  // The artwork sits in the middle ~35% of its canvas; the rest is headroom
  // for the glow. Painting the whole canvas at bar height puts the ring at
  // about the glyph's optical size and keeps the halo inside the bar window.
  readonly property real markerExtent: Math.max(8, Math.round(root.barSize * root.markerScale))

  property string themeName: ""

  // Resolved against the theme's own directory rather than the staged copy
  // under ~/.local/state. omarchy-theme-set rebuilds that directory wholesale
  // (rm -rf + mv), so its path is byte-identical for every theme and Qt's
  // pixmap cache would keep serving the previous theme's marker. Keying the
  // URL by theme name makes the cache correct with no cache-busting tricks.
  // User themes first, then stock -- the same walk this theme's hook does.
  readonly property bool themeNameSafe: themeName !== ""
    && themeName.indexOf("/") === -1 && themeName.indexOf("..") === -1
  readonly property bool markerAssetSafe: markerAsset !== ""
    && markerAsset.charAt(0) !== "/" && markerAsset.indexOf("..") === -1

  readonly property var markerCandidates: themeNameSafe && markerAssetSafe ? [
    Util.fileUrl(Color.home + "/.config/omarchy/themes/" + themeName + "/" + markerAsset),
    Util.fileUrl("/usr/share/omarchy/themes/" + themeName + "/" + markerAsset)
  ] : []

  // Restart the walk only when the URLs actually change: re-pointing source at
  // a URL whose load already failed emits no statusChanged.
  readonly property string markerCandidatesKey: markerCandidates.join("\n")
  property int markerCandidateIndex: 0
  onMarkerCandidatesKeyChanged: markerCandidateIndex = 0

  readonly property string markerSource: markerCandidateIndex < markerCandidates.length
    ? markerCandidates[markerCandidateIndex] : ""
  readonly property bool markerReady: markerProbe.status === Image.Ready

  // theme.name is rewritten in place after the staged theme is swapped in and
  // before the shell is told, so this watch is race-free and keeps its inode
  // -- unlike a watch on anything inside the staged directory.
  FileView {
    id: themeNameFile
    path: Color.stateHome + "/omarchy/current/theme.name"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.themeName = String(text() || "").trim()
    onLoadFailed: root.themeName = ""
  }

  // Color.shellValues is reassigned wholesale on every theme apply, including
  // the IPC push that bypasses file watching. A cheap second trigger in case
  // inotify drops an event.
  readonly property var themeApplyToken: Color.shellValues
  onThemeApplyTokenChanged: themeNameFile.reload()

  // One probe owns availability and the fallback walk; the visible per-slot
  // image reuses its pixmap (same URL, same sourceSize), so the asset is
  // decoded once per screen however many workspaces exist.
  Image {
    id: markerProbe
    visible: false
    width: 0
    height: 0
    source: root.markerSource
    sourceSize.width: Math.round(root.markerExtent * Screen.devicePixelRatio)
    sourceSize.height: Math.round(root.markerExtent * Screen.devicePixelRatio)
    // Advancing source from inside its own status change trips the
    // binding-loop detector; defer the step one tick.
    onStatusChanged: if (status === Image.Error && root.markerCandidateIndex < root.markerCandidates.length)
      Qt.callLater(function() { root.markerCandidateIndex++ })
  }

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        id: slot
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
        readonly property bool showMarker: focused && root.markerReady

        bar: root.bar
        // text stays set even when the marker covers it: WidgetButton derives
        // hasVisualContent from it, which gates both visible and opacity, so
        // blanking it would hide the slot entirely. Only the painted label is
        // traded away, and a load failure brings the glyph straight back.
        text: focused ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        labelVisible: !showMarker
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }

        // No MultiEffect colorization on purpose: the glow is three
        // differently tinted layers, and colorization flattens them to one hue.
        Image {
          anchors.centerIn: parent
          visible: slot.showMarker
          width: root.markerExtent
          height: root.markerExtent
          source: root.markerSource
          fillMode: Image.PreserveAspectFit
          // Decode at physical pixels; a logical-size raster is soft on a
          // scaled output.
          sourceSize.width: Math.round(root.markerExtent * Screen.devicePixelRatio)
          sourceSize.height: Math.round(root.markerExtent * Screen.devicePixelRatio)
        }
      }
    }
  }
}
