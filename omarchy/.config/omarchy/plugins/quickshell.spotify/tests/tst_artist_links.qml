import QtQuick
import QtQuick.Window
import QtTest

import ".."

TestCase {
  id: testCase
  name: "ArtistLinks"
  when: testWindow.visible

  property var selectedArtist: null
  property string selectedFallback: ""

  Window {
    id: testWindow
    width: 320
    height: 80
    visible: true

    ArtistLinks {
      id: artistLinks
      width: parent.width
      artists: []
      onArtistRequested: function(item) { testCase.selectedArtist = item }
      onFallbackRequested: function(name) { testCase.selectedFallback = name }
    }

  }

  function init() {
    selectedArtist = null
    selectedFallback = ""
    artistLinks.artists = []
    artistLinks.fallbackText = ""
    artistLinks.fallbackClickable = false
    artistLinks.suffixText = ""
  }

  function test_eachArtistGetsItsOwnLink() {
    artistLinks.artists = [
      { id: "one", type: "artist", name: "One & Only" },
      { id: "two", type: "artist", name: "Two" }
    ]
    artistLinks.suffixText = " · Album · 2026"

    verify(artistLinks.markup().indexOf("artist:0") >= 0)
    verify(artistLinks.markup().indexOf("One &amp; Only") >= 0)
    verify(artistLinks.markup().indexOf("artist:1") >= 0)
    verify(artistLinks.markup().indexOf(" · Album · 2026") >= 0)
    compare(artistLinks.displayText(), "One & Only, Two · Album · 2026")

    artistLinks.activateLink("artist:1")
    verify(selectedArtist !== null)
    compare(selectedArtist.id, "two")
  }

  function test_mouseClickActivatesTheVisibleArtistLink() {
    artistLinks.artists = [
      { id: "jimi", type: "artist", name: "Jimi Hendrix" }
    ]
    wait(1)

    compare(artistLinks.width, 320)
    verify(artistLinks.height > 0)
    compare(artistLinks.linkAt(5, artistLinks.height / 2), "artist:0")
    mouseClick(artistLinks, 5, artistLinks.height / 2, Qt.LeftButton)
    verify(selectedArtist !== null)
    compare(selectedArtist.id, "jimi")
  }

  function test_linkOnlyUnderlinesWhileHovered() {
    artistLinks.artists = [
      { id: "jimi", type: "artist", name: "Jimi Hendrix" }
    ]
    wait(1)

    compare(artistLinks.linkHovered, false)
    mouseMove(artistLinks, 5, artistLinks.height / 2)
    tryCompare(artistLinks, "linkHovered", true)

    mouseMove(artistLinks, artistLinks.width - 1, artistLinks.height / 2)
    tryCompare(artistLinks, "linkHovered", false)
  }

  function test_fallbackCanResolveAPlayerArtist() {
    artistLinks.fallbackText = "Jimi Hendrix"
    artistLinks.fallbackClickable = true

    verify(artistLinks.markup().indexOf("fallback") >= 0)
    compare(artistLinks.displayText(), "Jimi Hendrix")
    artistLinks.activateLink("fallback")
    compare(selectedFallback, "Jimi Hendrix")
  }
}
