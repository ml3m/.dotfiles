import QtQuick
import QtQuick.Controls
import QtTest

import ".."

TestCase {
  id: testCase
  name: "FastScroll"
  when: windowShown
  width: 320
  height: 240

  ListView {
    id: list
    anchors.fill: parent
    model: 100
    delegate: Rectangle {
      required property int index
      width: 320
      height: 66
    }

    FastScrollHandler {
      id: fastScroll
      parent: list
      flickable: list
    }
  }

  ScrollView {
    id: scrollView
    x: testCase.width + 20
    width: 180
    height: 100

    Rectangle {
      width: scrollView.availableWidth
      implicitHeight: 600
      height: implicitHeight
    }
  }

  FastScrollHandler {
    id: scrollViewFastScroll
    parent: scrollView.contentItem
    flickable: scrollView.contentItem
  }

  SignalSpy {
    id: scrollSpy
    target: fastScroll
    signalName: "scrolled"
  }

  function init() {
    list.positionViewAtBeginning()
    scrollSpy.clear()
    wait(1)
  }

  function test_deltaIsQuadrupled() {
    compare(fastScroll.parent, list)
    compare(fastScroll.scrollDistance(14, 0), 56)
    compare(fastScroll.scrollDistance(0, -120),
      -fastScroll.mouseWheelStep * 4)
  }

  function test_scrollApplicationMovesFourTimesTheBaseStep() {
    var expected = fastScroll.mouseWheelStep * 4
    compare(fastScroll.scrollByDeltas(0, -120), expected)
    compare(list.contentY, expected)
    compare(scrollSpy.count, 1)
  }

  function test_scrollIsBounded() {
    compare(fastScroll.boundedContentY(-500), 0)
    compare(fastScroll.boundedContentY(100000), list.contentHeight - list.height)
  }

  function test_scrollViewOverlayDoesNotBecomeScrollableContent() {
    compare(scrollViewFastScroll.parent, scrollView.contentItem)
    compare(scrollViewFastScroll.flickable.contentHeight, 600)
    compare(scrollViewFastScroll.scrollByDeltas(0, -120),
      scrollViewFastScroll.mouseWheelStep * 4)
    compare(scrollViewFastScroll.flickable.contentHeight, 600)
  }
}
