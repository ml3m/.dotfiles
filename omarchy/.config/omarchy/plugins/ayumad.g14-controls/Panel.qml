import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "ayumad.g14-controls"
  ipcTarget: "ayumad.g14-controls"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property string view: "all"
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
  property string auraMode: "static"
  property string selectedAuraColor: "ff2244"
  property real selectedHue: 0.0
  property bool auraLocked: false
  property string slashMode: "Bounce"
  property string slashBrightness: "255"
  property string slashEnabled: "unknown"
  readonly property string rogLogoSource: "file:///usr/share/icons/hicolor/512x512/apps/rog-control-center.png"
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
  readonly property string helperPath: configHome + "/omarchy/plugins/ayumad.g14-controls/g14ctl"
  property string message: ""
  property string errorMessage: ""
  property string actionName: ""
  property string previousGpuPending: ""
  property bool advancedOpen: false
  property bool setupOpen: false
  property int cursorIndex: 0
  property bool cursorActive: false

  readonly property var profileChoices: ["Quiet", "Balanced", "Performance", "Adaptive"]
  readonly property var keyboardLevels: ["off", "low", "med", "high"]
  readonly property var gpuChoices: ["integrated", "hybrid", "ultimate"]
  readonly property int advancedControlCount: 8

  readonly property var auraModes: [
    { value: "static", label: "Static" },
    { value: "breathe", label: "Breathing" },
    { value: "rainbow-cycle", label: "Color Cycle" },
    { value: "rainbow-wave", label: "Rainbow" },
    { value: "pulse", label: "Pulse" }
  ]
  readonly property var slashModes: [
    "Static", "Bounce", "Slash", "Loading", "BitStream", "Transmission",
    "Flow", "Flux", "Phantom", "Spectrum", "Hazard", "Interfacing",
    "Ramp", "GameOver", "Start", "Buzzer"
  ]
  readonly property var slashBrightnessLevels: [
    { value: "0", label: "Off" },
    { value: "64", label: "25%" },
    { value: "128", label: "50%" },
    { value: "192", label: "75%" },
    { value: "255", label: "100%" }
  ]

  readonly property color contentForeground: root.bar ? root.bar.foreground : Color.foreground
  readonly property string contentFontFamily: root.bar ? root.bar.fontFamily : Style.font.family

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function runAction(args) {
    if (actionProc.running) return
    root.actionName = String(args[0] || "")
    if (root.actionName !== "graphics") root.message = "Applying…"
    root.errorMessage = ""
    actionProc.command = [root.helperPath].concat(args)
    actionProc.running = true
  }

  function normalizedColor(raw) {
    var value = String(raw || "").trim().replace(/^#/, "")
    return /^[0-9a-fA-F]{6}$/.test(value) ? value.toLowerCase() : ""
  }

  function colorToHue(raw) {
    var color = normalizedColor(raw)
    if (!color) return 0.0
    var red = parseInt(color.slice(0, 2), 16) / 255
    var green = parseInt(color.slice(2, 4), 16) / 255
    var blue = parseInt(color.slice(4, 6), 16) / 255
    var maximum = Math.max(red, green, blue)
    var minimum = Math.min(red, green, blue)
    var delta = maximum - minimum
    if (delta === 0) return 0.0
    var hue
    if (maximum === red) hue = ((green - blue) / delta + (green < blue ? 6 : 0)) / 6
    else if (maximum === green) hue = ((blue - red) / delta + 2) / 6
    else hue = ((red - green) / delta + 4) / 6
    return hue
  }

  function colorComponentHex(component) {
    var hex = Math.round(Math.max(0, Math.min(1, component)) * 255).toString(16)
    return hex.length === 1 ? "0" + hex : hex
  }

  function hueToColor(hue) {
    var color = Qt.hsla(Math.max(0, Math.min(1, hue)), 1, 0.5, 1)
    return colorComponentHex(color.r) + colorComponentHex(color.g) + colorComponentHex(color.b)
  }

  function applyAuraColor(raw) {
    var color = normalizedColor(raw)
    if (!color) {
      root.errorMessage = "Use six hex digits, for example ff2244"
      return
    }
    root.selectedAuraColor = color
    root.selectedHue = root.colorToHue(color)
    root.runAction(["aura-static", color])
  }

  function applyAuraMode(mode) {
    root.auraMode = String(mode)
    root.runAction(["aura-mode", root.auraMode, root.selectedAuraColor])
  }

  function adaptiveLevel() {
    switch (root.profile) {
      case "Quiet": return 1
      case "Performance": return 3
      default: return 2
    }
  }

  function profileOptionGlyph(profileName) {
    return profileName === "Adaptive" ? "󱣲" : {
      "Quiet": "󰌪",
      "Balanced": "󰊚",
      "Performance": "󰓅"
    }[profileName] || "󰂄"
  }

  function profileOptionTooltip(profileName) {
    return profileName === "Adaptive"
      ? "Adaptive · now " + (root.profile || "Balanced") + " · AC Balanced / battery Quiet"
      : profileName
  }

  function applySlashMode(mode) {
    root.slashMode = String(mode)
    root.runAction(["slash-mode", root.slashMode])
  }

  function applySlashBrightness(value) {
    root.slashBrightness = String(value)
    root.runAction(["slash-brightness", root.slashBrightness])
  }

  function graphicsLabel(mode) {
    return String(mode || "").toUpperCase()
  }

  function normalizedGpuMode(mode) {
    return String(mode || "").toLowerCase()
  }

  function displayedGpuMode() {
    return root.normalizedGpuMode(root.gpuTargetMode || root.gpuPending || root.gpuMode || "unknown")
  }

  function gpuChoiceName(mode) {
    switch (root.normalizedGpuMode(mode)) {
      case "integrated": return root.igpuName || "Integrated GPU"
      case "ultimate": return root.dgpuName || "Discrete GPU"
      case "hybrid": {
        var names = []
        if (root.igpuName) names.push(root.igpuName)
        if (root.dgpuName) names.push(root.dgpuName)
        return names.length ? names.join(" + ") : "Integrated + discrete GPUs"
      }
      default: return "GPU information unavailable"
    }
  }

  function gpuChoiceTooltip(mode) {
    return root.graphicsLabel(mode) + " · " + root.gpuChoiceName(mode)
  }

  function displayedGraphicsLabel() {
    var label = root.graphicsLabel(root.displayedGpuMode())
    if (root.gpuPending && root.gpuMode
        && root.normalizedGpuMode(root.gpuMode) !== root.normalizedGpuMode(root.gpuPending))
      return root.graphicsLabel(root.gpuMode) + " → " + label + " · QUEUED"
    return root.gpuPending ? label + " · QUEUED" : label
  }

  function queueGraphics(mode) {
    root.previousGpuPending = root.gpuPending
    root.gpuPending = String(mode)
    root.message = "Queued " + root.graphicsLabel(mode) + " for the next reboot"
    root.errorMessage = ""
    root.runAction(["graphics", mode])
  }

  function cursorCount() {
    if (root.view === "profile") return root.profileChoices.length
    if (root.view === "graphics") return root.gpuChoices.length
    return root.setupStartIndex() + (root.setupOpen ? 3 : 0)
  }

  function setupToggleIndex() {
    return 10 + (root.advancedOpen ? root.advancedControlCount : 0)
  }

  function setupStartIndex() {
    return root.setupToggleIndex() + 1
  }

  // Keep the complete panel concise enough to fit without making either
  // disclosure section a second scrolling menu.
  function toggleAdvanced() {
    root.advancedOpen = !root.advancedOpen
    if (root.advancedOpen) root.setupOpen = false
    root.cursorIndex = 9
  }

  function toggleSetup() {
    root.setupOpen = !root.setupOpen
    if (root.setupOpen) root.advancedOpen = false
    root.cursorIndex = root.setupToggleIndex()
  }

  function activeProfileIndex() {
    if (root.adaptive) return root.profileChoices.indexOf("Adaptive")
    var profileIndex = root.profileChoices.indexOf(root.profile)
    return profileIndex >= 0 ? profileIndex : 0
  }

  function initialCursorIndex() {
    if (root.view === "graphics") {
      var gpuIndex = root.gpuChoices.indexOf(root.displayedGpuMode())
      return gpuIndex >= 0 ? gpuIndex : 0
    }
    return root.activeProfileIndex()
  }

  function resetCursor() {
    root.cursorActive = false
    root.cursorIndex = root.initialCursorIndex()
    Qt.callLater(root.ensureCursorVisible)
  }

  function clampCursor() {
    root.cursorIndex = Math.max(0, Math.min(root.cursorIndex, root.cursorCount() - 1))
  }

  function adjustHue(direction) {
    root.selectedHue = Math.max(0, Math.min(1, root.selectedHue + direction * 0.025))
  }

  function moveCursor(dx, dy) {
    root.cursorActive = true
    if (root.view === "all" && root.cursorIndex === 8 && dx !== 0) {
      root.adjustHue(dx)
      return
    }
    var delta = dx !== 0 ? dx : dy
    if (delta === 0) return
    root.cursorIndex = Math.max(0, Math.min(root.cursorCount() - 1, root.cursorIndex + delta))
    Qt.callLater(root.ensureCursorVisible)
  }

  function activateCursor() {
    root.cursorActive = true
    if (root.view === "profile") {
      root.runAction(["profile", root.profileChoices[root.cursorIndex].toLowerCase()])
      return
    }
    if (root.view === "graphics") {
      root.runAction(["graphics", root.gpuChoices[root.cursorIndex]])
      return
    }

    if (root.cursorIndex < 4) {
      root.runAction(["profile", root.profileChoices[root.cursorIndex].toLowerCase()])
    } else if (root.cursorIndex < 8) {
      root.runAction(["keyboard", root.keyboardLevels[root.cursorIndex - 4]])
    } else if (root.cursorIndex === 8) {
      root.applyAuraColor(root.hueToColor(root.selectedHue))
    } else if (root.cursorIndex === 9) {
      root.toggleAdvanced()
      return
    }

    if (root.advancedOpen && root.cursorIndex >= 10
        && root.cursorIndex < 10 + root.advancedControlCount) {
      switch (root.cursorIndex - 10) {
        case 0: auraModeDropdown.open(); return
        case 1: slashModeDropdown.open(); return
        case 2: slashBrightnessDropdown.open(); return
        case 3: root.runAction(["slash", "on"]); return
        case 4: root.runAction(["slash", "off"]); return
        default: root.queueGraphics(root.gpuChoices[root.cursorIndex - 15]); return
      }
    }

    if (root.cursorIndex === root.setupToggleIndex()) {
      root.toggleSetup()
      return
    }

    if (root.setupOpen) {
      switch (root.cursorIndex - root.setupStartIndex()) {
        case 0: root.runAction(["aura-lock", root.auraLocked ? "off" : "on"]); return
        case 1: root.launchHotkeyCapture(); return
        case 2: root.launchHotkeySetup(); return
      }
    }
  }

  function cursorItem() {
    if (root.view === "profile") return profileButtons.itemAt(root.cursorIndex)
    if (root.view === "graphics") return gpuButtons.itemAt(root.cursorIndex)
    if (root.cursorIndex < 4) return profileButtons.itemAt(root.cursorIndex)
    if (root.cursorIndex < 8) return keyboardButtons.itemAt(root.cursorIndex - 4)
    if (root.cursorIndex === 8) return hueSlider
    if (root.cursorIndex === 9) return advancedButton
    if (root.advancedOpen && root.cursorIndex >= 10
        && root.cursorIndex < 10 + root.advancedControlCount) {
      switch (root.cursorIndex - 10) {
        case 0: return auraModeDropdown
        case 1: return slashModeDropdown
        case 2: return slashBrightnessDropdown
        case 3: return slashOnButton
        case 4: return slashOffButton
        default: return gpuButtons.itemAt(root.cursorIndex - 15)
      }
    }
    if (root.cursorIndex === root.setupToggleIndex()) return setupSectionButton
    if (root.setupOpen) {
      switch (root.cursorIndex - root.setupStartIndex()) {
        case 0: return colorLockButton
        case 1: return captureHotkeysButton
        case 2: return setupHotkeysButton
      }
    }
    return null
  }

  function launchHotkeyCapture() {
    if (hotkeyProc.running) return
    root.message = "Key capture opened in a terminal"
    root.errorMessage = ""
    hotkeyProc.command = ["omarchy", "launch", "terminal", root.helperPath, "hotkeys", "capture"]
    hotkeyProc.running = true
  }

  function launchHotkeySetup() {
    if (hotkeyProc.running) return
    root.message = "Hotkey setup opened in a terminal"
    root.errorMessage = ""
    hotkeyProc.command = ["omarchy", "launch", "terminal", root.helperPath, "hotkeys", "setup"]
    hotkeyProc.running = true
  }

  function ensureCursorVisible() {
    var target = root.cursorItem()
    var flickable = scrollArea ? scrollArea.contentItem : null
    if (!target || !flickable || !("contentY" in flickable)) return
    var position = target.mapToItem(panelColumn, 0, 0)
    var top = position.y
    var bottom = top + target.height
    var visibleTop = flickable.contentY
    var visibleBottom = visibleTop + scrollArea.height
    if (top < visibleTop) flickable.contentY = Math.max(0, top - Style.space(8))
    else if (bottom > visibleBottom) flickable.contentY = Math.max(0, bottom - scrollArea.height + Style.space(8))
  }

  function updateStatus(raw) {
    try {
      var value = JSON.parse(raw)
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
      root.auraMode = value.aura_mode || root.auraMode
      root.auraLocked = value.aura_locked === true
      var firmwareColor = root.normalizedColor(value.aura_color)
      if (firmwareColor) {
        root.selectedAuraColor = firmwareColor
        root.selectedHue = root.colorToHue(firmwareColor)
      }
      root.slashMode = value.slash_mode || root.slashMode
      root.slashBrightness = value.slash_brightness || root.slashBrightness
      root.slashEnabled = value.slash_enabled || root.slashEnabled
    } catch (error) {
      // Keep the last good state while a command is settling.
    }
  }

  function open() {
    refresh()
    resetCursor()
    root.controller.show()
  }

  function close() {
    root.controller.hide()
  }

  function toggle() {
    root.opened ? root.close() : root.open()
  }

  function switchPanel(direction) {
    if (root.hostWidget && root.hostWidget.bar && typeof root.hostWidget.bar.switchPanelFrom === "function")
      return root.hostWidget.bar.switchPanelFrom(root.hostWidget, direction)
    return false
  }

  onViewChanged: root.resetCursor()
  onAdvancedOpenChanged: {
    root.clampCursor()
    Qt.callLater(root.ensureCursorVisible)
  }
  onSetupOpenChanged: {
    root.clampCursor()
    Qt.callLater(root.ensureCursorVisible)
  }
  onCursorIndexChanged: Qt.callLater(root.ensureCursorVisible)

  Process {
    id: statusProc
    command: [root.helperPath, "status"]
    stdout: StdioCollector {
      onStreamFinished: root.updateStatus(text)
    }
    stderr: StdioCollector { waitForEnd: true }
  }

  Process {
    id: actionProc
    stdout: StdioCollector { waitForEnd: true }
    stderr: StdioCollector {
      id: actionStderr
      waitForEnd: true
    }
    onExited: function(exitCode, exitStatus) {
      if (exitCode === 0) {
        if (!root.gpuPending) root.message = "Applied"
        root.errorMessage = ""
      } else {
        if (root.actionName === "graphics") root.gpuPending = root.previousGpuPending
        root.message = ""
        root.errorMessage = String(actionStderr.text || "Action failed").trim()
      }
      root.actionName = ""
      root.refresh()
    }
  }

  Process {
    id: hotkeyProc
    stderr: StdioCollector {
      id: hotkeyStderr
      waitForEnd: true
    }
    onExited: function(exitCode, exitStatus) {
      if (exitCode !== 0)
        root.errorMessage = String(hotkeyStderr.text || "Could not open hotkey setup").trim()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    centerOnBar: false
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(root.view === "all" ? Style.space(460) : Style.space(330))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight, Style.space(680))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: auraModeDropdown.popupOpen
        || slashModeDropdown.popupOpen || slashBrightnessDropdown.popupOpen
      onMoveRequested: function(dx, dy) { root.moveCursor(dx, dy) }
      onActivateRequested: root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      ScrollView {
        id: scrollArea
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: panelColumn.implicitHeight > height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff

        Column {
          id: panelColumn
          width: scrollArea.availableWidth
          spacing: Style.space(14)

          Item {
            width: parent.width
            implicitHeight: Math.max(heroIcon.height, heroLabels.implicitHeight)

            Image {
              id: heroIcon
              width: Style.space(34)
              height: width
              source: root.rogLogoSource
              fillMode: Image.PreserveAspectFit
              smooth: true
              mipmap: true
              visible: false
              layer.enabled: true
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
            }

            MultiEffect {
              anchors.fill: heroIcon
              source: heroIcon
              autoPaddingEnabled: false
              colorization: 1.0
              colorizationColor: root.contentForeground
            }

            Column {
              id: heroLabels
              anchors.left: heroIcon.right
              anchors.leftMargin: Style.space(14)
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              Text {
                text: "G14 CONTROL"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.title
                font.bold: true
              }

              Text {
                text: (root.profile || "Unknown") + " · " + root.displayedGraphicsLabel()
                color: root.contentForeground
                opacity: 0.65
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.0
              }
            }
          }

          Row {
            visible: root.view === "all"
            width: parent.width
            spacing: Style.space(18)

            InfoPair {
              width: (parent.width - parent.spacing) * 0.68
              label: "GPU · " + root.displayedGpuMode().toUpperCase()
                + (root.gpuPending ? " · reboot required" : "")
                + (root.runtime ? " · dGPU " + root.runtime : "")
              value: root.gpuName || root.dgpuName || "—"
            }
            InfoPair {
              width: (parent.width - parent.spacing) * 0.32
              label: "Keyboard"
              value: root.keyboard || "—"
            }
          }

          Text {
            width: parent.width
            visible: root.message !== "" || root.errorMessage !== ""
            text: root.errorMessage || root.message
            color: root.errorMessage !== "" ? Color.urgent : root.contentForeground
            opacity: root.errorMessage !== "" ? 1.0 : 0.7
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          PanelSeparator { foreground: root.contentForeground }

          Column {
            visible: root.view === "all" || root.view === "profile"
            width: parent.width
            spacing: Style.space(8)

            PanelSectionHeader {
              text: "POWER PROFILE"
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
            }

            Flow {
              id: profileFlow
              width: parent.width
              spacing: Style.space(6)

              readonly property int columns: 4

              Repeater {
                id: profileButtons
                model: root.profileChoices

                Button {
                  required property string modelData
                  width: (profileFlow.width - profileFlow.spacing * (profileFlow.columns - 1)) / profileFlow.columns
                  text: root.view === "profile" ? "" : modelData
                  iconText: root.view === "profile" ? root.profileOptionGlyph(modelData) : ""
                  fontSize: Style.font.bodySmall
                  iconSize: Style.font.icon
                  tooltipText: root.view === "profile" ? root.profileOptionTooltip(modelData) : ""
                  foreground: root.contentForeground
                  fontFamily: root.contentFontFamily
                  horizontalPadding: Style.spacing.controlPaddingX
                  verticalPadding: Style.spacing.controlPaddingY
                  bordered: true
                  active: modelData === "Adaptive" ? root.adaptive : !root.adaptive && root.profile === modelData
                  hasCursor: root.cursorActive && root.cursorIndex === root.profileChoices.indexOf(modelData)
                  onClicked: root.runAction(["profile", modelData.toLowerCase()])

                  // Adaptive is a policy rather than another native ASUS
                  // profile. Its own automatic icon gets one, two, or three
                  // compact level marks for Quiet, Balanced, or Performance.
                  Row {
                    visible: root.view === "profile" && modelData === "Adaptive"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.space(4)
                    spacing: Style.space(1)

                    Repeater {
                      model: root.adaptiveLevel()

                      Rectangle {
                        width: Style.space(3)
                        height: Style.space(2)
                        radius: height / 2
                        color: root.contentForeground
                      }
                    }
                  }
                }
              }
            }
          }

          PanelSeparator {
            visible: root.view === "all"
            foreground: root.contentForeground
          }

          Column {
            visible: root.view === "all"
            width: parent.width
            spacing: Style.space(8)

            PanelSectionHeader {
              text: "KEYBOARD BACKLIGHT"
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
            }

            Flow {
              id: keyboardFlow
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                id: keyboardButtons
                model: root.keyboardLevels

                Button {
                  required property string modelData
                  width: (keyboardFlow.width - keyboardFlow.spacing * 3) / 4
                  text: modelData.toUpperCase()
                  fontSize: Style.font.caption
                  foreground: root.contentForeground
                  fontFamily: root.contentFontFamily
                  horizontalPadding: Style.spacing.controlPaddingX
                  verticalPadding: Style.spacing.controlPaddingY
                  bordered: true
                  active: root.keyboard.toLowerCase() === modelData
                  hasCursor: root.cursorActive && root.view === "all"
                    && root.cursorIndex === root.keyboardLevels.indexOf(modelData) + 4
                  onClicked: root.runAction(["keyboard", modelData])
                }
              }
            }
          }

          PanelSeparator {
            visible: root.view === "all"
            foreground: root.contentForeground
          }

          Column {
            visible: root.view === "all"
            width: parent.width
            spacing: Style.space(8)

            PanelSectionHeader {
              text: "KEYBOARD COLOR"
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
            }

            Row {
              width: parent.width
              spacing: Style.space(10)

              Rectangle {
                width: Style.space(28)
                height: width
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                color: "#" + root.hueToColor(root.selectedHue)
                border.width: Style.normalBorderWidth
                border.color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.55)
              }

              Slider {
                id: hueSlider
                width: parent.width - Style.space(28) - parent.spacing
                height: Style.space(28)
                from: 0.0
                to: 1.0
                value: root.selectedHue
                onMoved: root.selectedHue = value
                onPressedChanged: {
                  if (!pressed) root.applyAuraColor(root.hueToColor(value))
                }

                background: Rectangle {
                  x: hueSlider.leftPadding
                  y: hueSlider.topPadding + hueSlider.availableHeight / 2 - Style.space(5)
                  width: hueSlider.availableWidth
                  height: Style.space(10)
                  radius: height / 2
                  border.width: root.cursorActive && root.view === "all" && root.cursorIndex === 8
                    ? Style.normalBorderWidth : 0
                  border.color: root.contentForeground
                  gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.00; color: "#ff2244" }
                    GradientStop { position: 0.16; color: "#ffee33" }
                    GradientStop { position: 0.33; color: "#33dd66" }
                    GradientStop { position: 0.50; color: "#22ccff" }
                    GradientStop { position: 0.67; color: "#2299ff" }
                    GradientStop { position: 0.83; color: "#aa66ff" }
                    GradientStop { position: 1.00; color: "#ff2244" }
                  }
                }

                handle: Rectangle {
                  x: hueSlider.leftPadding + hueSlider.visualPosition * (hueSlider.availableWidth - width)
                  y: hueSlider.topPadding + hueSlider.availableHeight / 2 - height / 2
                  width: Style.space(18)
                  height: width
                  radius: width / 2
                  color: "#" + root.hueToColor(hueSlider.value)
                  border.width: Style.normalBorderWidth
                  border.color: root.contentForeground
                }
              }
            }

          }

          Button {
            id: advancedButton
            visible: root.view === "all"
            width: parent.width
            text: root.advancedOpen ? "HIDE ADVANCED CONTROLS" : "SHOW ADVANCED CONTROLS"
            fontSize: Style.font.caption
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            horizontalPadding: Style.spacing.controlPaddingX
            verticalPadding: Style.spacing.controlPaddingY
            bordered: true
            active: root.advancedOpen
            hasCursor: root.cursorActive && root.cursorIndex === 9
            onClicked: root.toggleAdvanced()
          }

          Column {
            id: advancedControls
            visible: root.view === "all" && root.advancedOpen
            width: parent.width
            spacing: Style.space(8)

            PanelSeparator { foreground: root.contentForeground }

            PanelSectionHeader {
              text: "ADVANCED"
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
            }

            Row {
              width: parent.width
              spacing: Style.space(8)

              Dropdown {
                id: auraModeDropdown
                width: (parent.width - parent.spacing) / 2
                label: "KEYBOARD MODE"
                value: root.auraMode
                options: root.auraModes
                foreground: root.contentForeground
                fontFamily: root.contentFontFamily
                hasCursor: root.cursorActive && root.cursorIndex === 10
                onChanged: root.applyAuraMode(value)
              }

              Dropdown {
                id: slashModeDropdown
                width: (parent.width - parent.spacing) / 2
                label: "SLASH"
                value: root.slashMode
                options: root.slashModes
                foreground: root.contentForeground
                fontFamily: root.contentFontFamily
                hasCursor: root.cursorActive && root.cursorIndex === 11
                onChanged: root.applySlashMode(value)
              }
            }

            Row {
              width: parent.width
              spacing: Style.space(8)

              Dropdown {
                id: slashBrightnessDropdown
                width: (parent.width - parent.spacing * 2) / 3
                label: "BRIGHT"
                value: root.slashBrightness
                options: root.slashBrightnessLevels
                foreground: root.contentForeground
                fontFamily: root.contentFontFamily
                hasCursor: root.cursorActive && root.cursorIndex === 12
                onChanged: root.applySlashBrightness(value)
              }

              Column {
                width: parent.width - slashBrightnessDropdown.width - parent.spacing
                spacing: Style.spacing.labelGap

                Text {
                  text: "POWER"
                  color: root.contentForeground
                  opacity: 0.65
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                Row {
                  width: parent.width
                  height: Style.spacing.controlHeight
                  spacing: Style.space(8)

                  Button {
                    id: slashOnButton
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height
                    text: "ON"
                    fontSize: Style.font.caption
                    foreground: root.contentForeground
                    fontFamily: root.contentFontFamily
                    horizontalPadding: Style.spacing.controlPaddingX
                    verticalPadding: Style.spacing.controlPaddingY
                    bordered: true
                    active: root.slashEnabled === "true"
                    hasCursor: root.cursorActive && root.cursorIndex === 13
                    onClicked: root.runAction(["slash", "on"])
                  }

                  Button {
                    id: slashOffButton
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height
                    text: "OFF"
                    fontSize: Style.font.caption
                    foreground: root.contentForeground
                    fontFamily: root.contentFontFamily
                    horizontalPadding: Style.spacing.controlPaddingX
                    verticalPadding: Style.spacing.controlPaddingY
                    bordered: true
                    active: root.slashEnabled === "false"
                    hasCursor: root.cursorActive && root.cursorIndex === 14
                    onClicked: root.runAction(["slash", "off"])
                  }
                }
              }
            }

          }

          Column {
            visible: root.view === "graphics" || (root.view === "all" && root.advancedOpen)
            width: parent.width
            spacing: Style.space(8)

            PanelSeparator {
              visible: root.view === "graphics"
              foreground: root.contentForeground
            }

            PanelSectionHeader {
              text: "GRAPHICS MODE · REBOOT REQUIRED"
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
            }

            Flow {
              id: gpuFlow
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                id: gpuButtons
                model: root.gpuChoices

                Button {
                  required property string modelData
                  width: (gpuFlow.width - gpuFlow.spacing * 2) / 3
                  text: modelData.toUpperCase()
                  tooltipText: root.gpuChoiceTooltip(modelData)
                  fontSize: Style.font.bodySmall
                  foreground: root.contentForeground
                  fontFamily: root.contentFontFamily
                  horizontalPadding: Style.spacing.controlPaddingX
                  verticalPadding: Style.spacing.controlPaddingY
                  bordered: true
                  active: root.displayedGpuMode() === modelData
                  hasCursor: root.cursorActive && (root.view === "graphics"
                    ? root.cursorIndex === root.gpuChoices.indexOf(modelData)
                    : root.cursorIndex === root.gpuChoices.indexOf(modelData) + 15)
                  onClicked: root.queueGraphics(modelData)
                }
              }
            }

            Column {
              width: parent.width
              spacing: Style.space(2)

              Text {
                width: parent.width
                visible: root.displayedGpuMode() !== "ultimate"
                text: "Integrated · " + root.gpuChoiceName("integrated")
                color: root.contentForeground
                opacity: 0.72
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
              }

              Text {
                width: parent.width
                visible: root.displayedGpuMode() !== "integrated"
                text: "Discrete · " + root.gpuChoiceName("ultimate")
                color: root.contentForeground
                opacity: 0.72
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
              }
            }

            Text {
              visible: root.gpuPending !== ""
              width: parent.width
              text: root.graphicsLabel(root.gpuPending) + " QUEUED · REBOOT TO APPLY"
              color: root.contentForeground
              opacity: 0.65
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              horizontalAlignment: Text.AlignHCenter
              wrapMode: Text.WordWrap
            }
          }

          Button {
            id: setupSectionButton
            visible: root.view === "all"
            width: parent.width
            text: root.setupOpen ? "HIDE SETUP" : "SHOW SETUP"
            fontSize: Style.font.caption
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            horizontalPadding: Style.spacing.controlPaddingX
            verticalPadding: Style.spacing.controlPaddingY
            bordered: true
            active: root.setupOpen
            hasCursor: root.cursorActive && root.cursorIndex === root.setupToggleIndex()
            onClicked: root.toggleSetup()
          }

          Column {
            id: setupControls
            visible: root.view === "all" && root.setupOpen
            width: parent.width
            spacing: Style.space(8)

            PanelSeparator { foreground: root.contentForeground }

            PanelSectionHeader {
              text: "SETUP"
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
            }

            Row {
              width: parent.width
              spacing: Style.space(6)

              Button {
                id: colorLockButton
                width: (parent.width - parent.spacing * 2) / 3
                text: root.auraLocked ? "COLOR LOCKED" : "LOCK COLOR"
                tooltipText: root.auraLocked
                  ? "Keyboard color lock is on — click to turn it off"
                  : "Keep the current keyboard lighting across theme changes"
                fontSize: Style.font.caption
                foreground: root.contentForeground
                fontFamily: root.contentFontFamily
                horizontalPadding: Style.space(8)
                verticalPadding: Style.space(5)
                bordered: true
                active: root.auraLocked
                hasCursor: root.cursorActive && root.cursorIndex === root.setupStartIndex()
                onClicked: root.runAction(["aura-lock", root.auraLocked ? "off" : "on"])
              }

              Button {
                id: captureHotkeysButton
                width: (parent.width - parent.spacing * 2) / 3
                text: "CAPTURE KEYS"
                tooltipText: "Open wev to identify your physical G14 key symbols"
                fontSize: Style.font.caption
                foreground: root.contentForeground
                fontFamily: root.contentFontFamily
                horizontalPadding: Style.space(8)
                verticalPadding: Style.space(5)
                bordered: true
                hasCursor: root.cursorActive && root.cursorIndex === root.setupStartIndex() + 1
                onClicked: root.launchHotkeyCapture()
              }

              Button {
                id: setupHotkeysButton
                width: (parent.width - parent.spacing * 2) / 3
                text: "SET UP HOTKEYS"
                tooltipText: "Guided, opt-in G14 hotkey setup with a backup and confirmation"
                fontSize: Style.font.caption
                foreground: root.contentForeground
                fontFamily: root.contentFontFamily
                horizontalPadding: Style.space(8)
                verticalPadding: Style.space(5)
                bordered: true
                hasCursor: root.cursorActive && root.cursorIndex === root.setupStartIndex() + 2
                onClicked: root.launchHotkeySetup()
              }
            }
          }
        }
      }
    }
  }

  component InfoPair: Column {
    width: (parent.width - parent.spacing) / 2
    spacing: Style.spacing.labelGap

    property string label: ""
    property string value: ""

    Text {
      text: parent.label
      color: root.contentForeground
      opacity: 0.6
      font.family: root.contentFontFamily
      font.pixelSize: Style.font.bodySmall
    }
    Text {
      width: parent.width
      text: parent.value
      color: root.contentForeground
      font.family: root.contentFontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }
  }
}
