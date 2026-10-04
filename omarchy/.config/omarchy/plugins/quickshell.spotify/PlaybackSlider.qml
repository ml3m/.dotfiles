import QtQuick
import qs.Ui

import "Api.js" as Api

// PanelSlider restores liveValue from value immediately after it emits
// released(). Playback controls are asynchronous, so retain the preview that
// moved() established until the backing player acknowledges the command.
PanelSlider {
  id: root

  property real sourceValue: 0
  property bool sourcePending: false
  property real acknowledgeTolerance: 0.01
  property int minimumFeedbackMs: 300
  property int feedbackTimeoutMs: 8000
  property string contextKey: ""

  property real pendingValue: -1
  property double pendingStartedAt: 0
  property string pendingContextKey: ""
  readonly property bool awaitingFeedback: pendingValue >= minimum

  value: awaitingFeedback ? pendingValue : sourceValue

  signal committed(real value)

  function preview(value) {
    pendingValue = Math.max(minimum, Math.min(maximum, Number(value) || 0))
    if (!pendingContextKey) pendingContextKey = contextKey
  }

  function clearPreview() {
    feedbackTimer.stop()
    pendingValue = -1
    pendingStartedAt = 0
    pendingContextKey = ""
  }

  onMoved: function(value) { preview(value) }
  onReleased: function(value) {
    preview(value)
    pendingStartedAt = Date.now()
    pendingContextKey = contextKey
    feedbackTimer.restart()
    committed(pendingValue)
  }
  onContextKeyChanged: {
    if (awaitingFeedback && pendingContextKey
        && contextKey !== pendingContextKey) clearPreview()
  }

  Timer {
    id: feedbackTimer
    interval: 50
    repeat: true
    onTriggered: {
      if (!root.awaitingFeedback) {
        stop()
        return
      }
      if (root.dragging) return
      var elapsed = Date.now() - root.pendingStartedAt
      if (Api.playbackSliderFeedbackComplete(root.sourceValue,
          root.pendingValue, root.sourcePending, elapsed,
          root.acknowledgeTolerance, root.minimumFeedbackMs,
          root.feedbackTimeoutMs))
        root.clearPreview()
    }
  }
}
