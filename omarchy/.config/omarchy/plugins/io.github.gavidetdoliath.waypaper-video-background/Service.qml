import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root

  property var manifest: ({})
  property bool desiredRunning: true
  property bool stopping: false
  property bool manualRestart: false
  property int restartAttempts: 0
  property int lastExitCode: 0
  property string lastLog: ""

  readonly property string pluginDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir) : ""

  function ensureStarted() {
    if (stopping || !desiredRunning || !pluginDir || wallpaperProcess.running) return
    wallpaperProcess.command = [pluginDir + "/start-mpvpaper.sh"]
    wallpaperProcess.running = true
  }

  function startWallpaper() {
    desiredRunning = true
    restartAttempts = 0
    lastLog = ""
    ensureStarted()
  }

  function stopWallpaper() {
    desiredRunning = false
    manualRestart = false
    restartTimer.stop()
    stabilityTimer.stop()
    if (wallpaperProcess.running) wallpaperProcess.running = false
  }

  function restartWallpaper() {
    desiredRunning = true
    restartAttempts = 0
    lastLog = ""
    restartTimer.stop()
    if (wallpaperProcess.running) {
      manualRestart = true
      wallpaperProcess.running = false
    } else {
      Qt.callLater(root.ensureStarted)
    }
  }

  function runControl(action) {
    if (!pluginDir || controlProcess.running) return
    controlProcess.command = [pluginDir + "/control.sh", action]
    controlProcess.running = true
  }

  onPluginDirChanged: Qt.callLater(root.ensureStarted)
  Component.onCompleted: Qt.callLater(root.ensureStarted)
  Component.onDestruction: {
    stopping = true
    desiredRunning = false
    restartTimer.stop()
    stabilityTimer.stop()
    if (wallpaperProcess.running) wallpaperProcess.running = false
  }

  Process {
    id: wallpaperProcess

    onRunningChanged: {
      if (running) {
        root.lastLog = ""
        stabilityTimer.restart()
      }
    }

    onExited: function(exitCode) {
      root.lastExitCode = exitCode
      stabilityTimer.stop()

      if (root.stopping || !root.desiredRunning) return

      if (root.manualRestart) {
        root.manualRestart = false
        restartTimer.interval = 250
        restartTimer.restart()
        return
      }

      // Configuration and dependency errors require an explicit user retry.
      if (exitCode === 69) {
        root.lastLog = "mpvpaper or a required dependency is unavailable"
        root.desiredRunning = false
        return
      }
      if (exitCode === 78) {
        root.lastLog = "Waypaper configuration is invalid; run start-mpvpaper.sh --check"
        root.desiredRunning = false
        return
      }

      root.lastLog = "mpvpaper exited with code " + exitCode
      root.restartAttempts += 1
      if (root.restartAttempts > 5) {
        root.desiredRunning = false
        root.lastLog = "mpvpaper stopped after five failed restart attempts"
        return
      }

      restartTimer.interval = Math.min(30000, 1000 * Math.pow(2, root.restartAttempts - 1))
      restartTimer.restart()
    }
  }

  Process {
    id: controlProcess
    onExited: function(exitCode) {
      if (exitCode !== 0) root.lastLog = "Video background control command failed"
    }
  }

  Timer {
    id: restartTimer
    repeat: false
    onTriggered: root.ensureStarted()
  }

  Timer {
    id: stabilityTimer
    interval: 30000
    repeat: false
    onTriggered: root.restartAttempts = 0
  }

  IpcHandler {
    target: "waypaper-video-background"

    function status(): string {
      return JSON.stringify({
        running: wallpaperProcess.running,
        desiredRunning: root.desiredRunning,
        processId: Number(wallpaperProcess.processId || 0),
        restartAttempts: root.restartAttempts,
        lastExitCode: root.lastExitCode,
        lastLog: root.lastLog
      })
    }

    function start(): string {
      root.startWallpaper()
      return "starting"
    }

    function stop(): string {
      root.stopWallpaper()
      return "stopping"
    }

    function restart(): string {
      root.restartWallpaper()
      return "restarting"
    }

    function pause(): string {
      root.runControl("pause")
      return "pausing"
    }

    function resume(): string {
      root.runControl("resume")
      return "resuming"
    }

    function toggle(): string {
      root.runControl("toggle")
      return "toggling"
    }

    function open(): string {
      Quickshell.execDetached(["uwsm-app", "--", "waypaper"])
      return "opening"
    }
  }
}
