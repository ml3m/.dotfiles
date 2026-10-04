import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "ayumad.g14-controls"
  property string profile: ""
  property bool adaptive: false
  property string gpuMode: ""
  property string gpuPending: ""
  property string gpuTargetMode: ""
  property string runtime: ""
  property string gpuName: ""
  property string igpuName: ""
  property string dgpuName: ""
  property string keyboard: ""
  property var panelAnchor: null
  readonly property string rogLogoSource: "file:///usr/share/icons/hicolor/512x512/apps/rog-control-center.png"
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
  readonly property string helperPath: configHome + "/omarchy/plugins/ayumad.g14-controls/g14ctl"
  property int refreshIntervalSec: Number(setting("refreshIntervalSec", 10))
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  // The shell's default open-panel mark belongs to a bar module, while this
  // module contains three independent glyphs. Keep that group-level mark at
  // zero size and paint the active glyph's mark locally below.
  readonly property real openPanelIndicatorWidth: 0.1
  readonly property real openPanelIndicatorHeight: 0.1

  // Each state gets its own compact, directly hoverable glyph.
  implicitWidth: root.vertical ? root.barSize : glyphRow.implicitWidth
  implicitHeight: root.barSize

  function profileGlyph() {
    switch (root.profile.toLowerCase()) {
      case "quiet": return "󰌪"
      case "balanced": return "󰊚"
      case "performance": return "󰓅"
      default: return "󰂄"
    }
  }

  function profileTooltip() {
    var current = root.profile || "unknown"
    return root.adaptive ? "Adaptive profile · " + current + " now" : "Profile: " + current
  }

  function adaptiveLevel() {
    switch (root.profile.toLowerCase()) {
      case "quiet": return 1
      case "performance": return 3
      default: return 2
    }
  }

  function gpuGlyph() {
    // Follow the selected firmware mode, or its queued reboot target. Runtime
    // activity is intentionally not used here: Hybrid mode wakes the dGPU for
    // individual applications and must not make the bar glyph oscillate.
    return (root.gpuTargetMode || root.gpuPending || root.gpuMode).toLowerCase() === "ultimate" ? "󰢮" : ""
  }

  function openView(view, anchor) {
    var target = panelLoader.item
    if (!target) return
    root.panelAnchor = anchor || deviceButton
    if ("view" in target) target.view = view
    root.injectPanel()
    target.open()
  }

  function toggleView(view, anchor) {
    var target = panelLoader.item
    if (!target) return
    var nextAnchor = anchor || deviceButton
    if (target.opened && target.view === view && root.panelAnchor === nextAnchor) {
      target.close()
    } else {
      root.openView(view, nextAnchor)
    }
  }

  function open() { root.openView("all", deviceButton) }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function toggle() { root.toggleView("all", deviceButton) }

  function refresh() {
    if (!statusProc.running) statusProc.running = true
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function cycleProfile() {
    runAction(["profile", "next"])
  }

  function handleGlyphPress(mouseButton, view, anchor) {
    if (mouseButton === Qt.LeftButton) {
      root.toggleView(view, anchor)
    } else if (mouseButton === Qt.RightButton) {
      root.cycleProfile()
    } else if (mouseButton === Qt.MiddleButton) {
      root.refresh()
    }
  }

  function graphicsTooltip() {
    var mode = (root.gpuTargetMode || root.gpuPending || root.gpuMode || "unknown").toUpperCase()
    var name = root.gpuName || root.dgpuName || root.igpuName || "GPU"
    var pending = root.gpuPending ? " · queued · reboot required" : ""
    var current = root.gpuMode && root.gpuMode.toUpperCase() !== mode
      ? " · running " + root.gpuMode.toUpperCase()
      : ""
    var runtime = root.runtime ? " · dGPU " + root.runtime : ""
    return name + " · " + mode + pending + current + runtime
  }

  function glyphIsActive(button) {
    return root.opened && root.panelAnchor === button
  }

  function runAction(args) {
    if (actionProc.running) return
    actionProc.command = [root.helperPath].concat(args)
    actionProc.running = true
  }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = root.panelAnchor || deviceButton
    if ("hostWidget" in target) target.hostWidget = root
  }

  Process {
    id: statusProc
    command: [root.helperPath, "status"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var value = JSON.parse(text)
          root.profile = value.profile || ""
          root.adaptive = value.adaptive === true
          root.gpuMode = value.gpu_mode || ""
          root.gpuPending = value.gpu_pending || ""
          root.gpuTargetMode = value.gpu_target_mode || root.gpuPending || root.gpuMode
          root.runtime = value.dgpu_runtime || value.nvidia_runtime || ""
          root.gpuName = value.gpu_name || ""
          root.igpuName = value.igpu_name || ""
          root.dgpuName = value.dgpu_name || ""
          root.keyboard = value.keyboard_brightness || ""
        } catch (error) {}
      }
    }
  }

  Process {
    id: actionProc
    stdout: StdioCollector { waitForEnd: true }
    stderr: StdioCollector { waitForEnd: true }
    onExited: root.refresh()
  }

  Timer {
    interval: Math.max(5000, root.refreshIntervalSec * 1000)
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  onBarChanged: root.injectPanel()
  onSettingsChanged: root.injectPanel()

  IpcHandler {
    target: "ayumad.g14-controls"

    function refresh(): void { root.refresh() }
    function profileChanged(profileName: string): void {
      if (profileName) root.profile = profileName
      root.refresh()
    }
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function openProfile(): void { root.openView("profile", profileButton) }
    function openGraphics(): void { root.openView("graphics", gpuButton) }
  }

  Row {
    id: glyphRow
    anchors.centerIn: parent
    spacing: Style.space(1)

    BarIconButton {
      id: deviceButton
      bar: root.bar
      opticalSize: Style.space(20)
      iconComponent: Component {
        Item {
          Image {
            id: rogMark
            anchors.fill: parent
            source: root.rogLogoSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: false
            layer.enabled: true
          }

          MultiEffect {
            anchors.fill: rogMark
            source: rogMark
            autoPaddingEnabled: false
            colorization: 1.0
            colorizationColor: root.bar ? root.bar.foreground : Color.foreground
          }
        }
      }
      tooltipText: "G14 controls"
      onPressed: function(mouseButton) { root.handleGlyphPress(mouseButton, "all", deviceButton) }

      ActiveGlyphIndicator { active: root.glyphIsActive(deviceButton) }
    }

    BarIconButton {
      id: profileButton
      bar: root.bar
      iconComponent: Component {
        Item {
          Text {
            visible: !root.adaptive
            anchors.centerIn: parent
            text: root.profileGlyph()
            color: root.bar ? root.bar.foreground : Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.bar.iconFont
          }

          // Adaptive is a distinct automatic state. Its circular base glyph
          // does not reuse a native profile icon; the small level marks vary
          // with the current Quiet, Balanced, or Performance target.
          Item {
            visible: root.adaptive
            anchors.fill: parent

            Text {
              anchors.centerIn: parent
              anchors.verticalCenterOffset: -Style.space(1)
              text: "󱣲"
              color: root.bar ? root.bar.foreground : Color.foreground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.bar.iconFont
            }

            Row {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.bottom: parent.bottom
              anchors.bottomMargin: Style.space(1)
              spacing: Style.space(1)

              Repeater {
                model: root.adaptiveLevel()

                Rectangle {
                  width: Style.space(3)
                  height: Style.space(2)
                  radius: height / 2
                  color: root.bar ? root.bar.foreground : Color.foreground
                }
              }
            }
          }
        }
      }
      tooltipText: root.profileTooltip()
      onPressed: function(mouseButton) { root.handleGlyphPress(mouseButton, "profile", profileButton) }

      ActiveGlyphIndicator { active: root.glyphIsActive(profileButton) }
    }

    BarIconButton {
      id: gpuButton
      bar: root.bar
      text: root.gpuGlyph()
      tooltipText: root.graphicsTooltip()
      onPressed: function(mouseButton) { root.handleGlyphPress(mouseButton, "graphics", gpuButton) }

      ActiveGlyphIndicator { active: root.glyphIsActive(gpuButton) }
    }
  }

  component ActiveGlyphIndicator: Rectangle {
    property bool active: false

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Style.space(2)
    width: Math.max(Style.space(10), Math.round(parent.width * 0.55))
    height: Style.space(2)
    radius: height / 2
    color: Color.accent
    opacity: active ? 0.9 : 0.0
    z: 1

    Behavior on opacity {
      NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }
  }

  Component.onCompleted: root.refresh()
}
