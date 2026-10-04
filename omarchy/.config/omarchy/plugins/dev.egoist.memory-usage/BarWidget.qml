import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "dev.egoist.memory-usage"

  property var memorySnapshot: ({})
  property string memoryError: ""

  readonly property real configuredWidth: {
    var value = Number(setting("width", Style.bar.iconSlot))
    return isFinite(value) && value > 0
      ? Math.max(Style.bar.iconSlot, Math.min(100, value))
      : Style.bar.iconSlot
  }
  readonly property string memoryScript: localPath(Qt.resolvedUrl("scripts/memory-stats"))
  readonly property real totalBytes: Number(memorySnapshot.totalBytes || 0)
  readonly property real usedBytes: Number(memorySnapshot.usedBytes || 0)
  readonly property real usedFraction: totalBytes > 0
    ? Math.max(0, Math.min(1, usedBytes / totalBytes))
    : 0
  readonly property bool opened: panelLoader.item
    ? panelLoader.item.opened === true
    : false
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing === true
    : false

  function localPath(url) {
    var value = String(url || "")
    if (value.indexOf("file://") === 0) value = value.substring(7)
    try { return decodeURIComponent(value) } catch (error) { return value }
  }

  function formatBytes(bytes) {
    var value = Number(bytes)
    if (!isFinite(value) || value < 0) value = 0
    if (value < 1024 * 1024 * 1024)
      return (value / (1024 * 1024)).toFixed(value < 100 * 1024 * 1024 ? 1 : 0) + " MB"
    return (value / (1024 * 1024 * 1024)).toFixed(1) + " GB"
  }

  function refresh() {
    if (!memoryProcess.running) memoryProcess.running = true
  }

  function updateMemory(raw) {
    try {
      var next = JSON.parse(String(raw || "{}"))
      if (!next || Number(next.totalBytes || 0) <= 0)
        throw new Error("Missing memory total")

      var previous = memorySnapshot || ({})
      var elapsedMs = Number(next.sampledMs || 0) - Number(previous.sampledMs || 0)
      var pageSize = Number(next.pageSize || 4096)

      function counterRate(current, old) {
        var delta = Number(current || 0) - Number(old || 0)
        if (elapsedMs <= 0 || delta < 0) return 0
        return delta * pageSize * 1000 / elapsedMs
      }

      next.swapInBytesPerSecond = counterRate(next.swapInPages, previous.swapInPages)
      next.swapOutBytesPerSecond = counterRate(next.swapOutPages, previous.swapOutPages)
      memorySnapshot = next
      memoryError = ""
    } catch (error) {
      memoryError = "Could not read memory statistics"
    }
  }

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function toggle() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    target.bar = root.bar
    target.settings = root.settings
    target.anchorItem = button
    target.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()
  Component.onCompleted: refresh()

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

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    fixedWidth: root.vertical ? -1 : root.configuredWidth
    fixedHeight: root.vertical ? Style.bar.iconSlot : -1
    horizontalMargin: 0
    verticalPadding: 0
    labelVisible: false
    hasVisualContent: true
    tooltipText: root.totalBytes > 0
      ? "Memory: " + root.formatBytes(root.usedBytes) + " used of " + root.formatBytes(root.totalBytes)
      : (root.memoryError !== "" ? root.memoryError : "Reading memory usage…")

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.toggle()
    }

    Row {
      id: memoryIndicator
      anchors.centerIn: parent
      height: Style.bar.iconCanvas
      spacing: Style.spaceReal(3)

      Item {
        width: Style.spaceReal(8)
        height: parent.height

        Text {
          anchors.centerIn: parent
          text: "M\nE\nM"
          color: button.foreground
          font.family: button.fontFamily
          font.pixelSize: 7
          font.bold: true
          lineHeight: 0.72
          lineHeightMode: Text.ProportionalHeight
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          renderType: Text.NativeRendering

          Behavior on color {
            enabled: !root.bar || root.bar.foregroundAnimationEnabled
            ColorAnimation { duration: 160 }
          }
        }
      }

      Item {
        id: memoryMeter
        width: Style.spaceReal(7)
        height: parent.height

        Rectangle {
          id: memoryTrack
          anchors.fill: parent
          radius: width / 2
          color: Qt.rgba(button.foreground.r, button.foreground.g, button.foreground.b, 0.12)
        }

        Rectangle {
          anchors.left: memoryTrack.left
          anchors.right: memoryTrack.right
          anchors.bottom: memoryTrack.bottom
          height: root.totalBytes > 0
            ? memoryTrack.height * root.usedFraction
            : 0
          radius: Math.min(width / 2, height / 2)
          color: button.foreground

          Behavior on height {
            NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
          }

          Behavior on color {
            enabled: !root.bar || root.bar.foregroundAnimationEnabled
            ColorAnimation { duration: 160 }
          }
        }
      }
    }
  }

  Process {
    id: memoryProcess
    command: [root.memoryScript]

    onExited: function(exitCode) {
      if (exitCode !== 0 && root.totalBytes <= 0)
        root.memoryError = "Could not read memory statistics"
    }

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateMemory(text)
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
}
