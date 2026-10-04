import QtQuick
import QtQuick.Window
import QtTest

import ".."

TestCase {
  id: testCase
  name: "MediaByline"
  when: testWindow.visible

  property var selectedArtist: null
  property var searchTrack: ({
    kind: "item",
    type: "track",
    id: "track-id",
    uri: "spotify:track:track-id",
    name: "Have a Cigar",
    subtitle: "Pink Floyd",
    artists: [{
      kind: "context",
      type: "artist",
      id: "pink-floyd",
      uri: "spotify:artist:pink-floyd",
      name: "Pink Floyd"
    }],
    albumItem: {
      kind: "context",
      type: "album",
      id: "wish-you-were-here",
      uri: "spotify:album:wish-you-were-here",
      name: "Wish You Were Here"
    }
  })

  Window {
    id: testWindow
    width: 560
    height: 60
    visible: true

    MediaByline {
      id: songByline
      width: parent.width
      foreground: "#a59d86"
      accent: "#f1dfb4"
      itemData: testCase.searchTrack
      onArtistRequested: function(item) { testCase.selectedArtist = item }
    }

    ListView {
      id: searchResults
      y: 30
      width: parent.width
      height: 30
      model: [testCase.searchTrack]

      delegate: MediaByline {
        required property var modelData
        objectName: "search-result-byline"
        width: searchResults.width
        itemData: modelData
        foreground: "#a59d86"
        accent: "#f1dfb4"
        onArtistRequested: function(item) { testCase.selectedArtist = item }
      }
    }
  }

  SignalSpy {
    id: artistSpy
    target: songByline
    signalName: "artistRequested"
  }

  function init() {
    selectedArtist = null
    artistSpy.clear()
  }

  function test_searchSongCardOpensItsArtist() {
    var link = findChild(songByline, "media-byline-artists")
    verify(link !== null)
    verify(link.visible)
    compare(link.linkAt(5, link.height / 2), "artist:0")

    mouseClick(link, 5, link.height / 2, Qt.LeftButton)

    compare(artistSpy.count, 1)
    verify(selectedArtist !== null)
    compare(selectedArtist.id, "pink-floyd")
  }

  function test_listDelegateKeepsStructuredArtists() {
    wait(1)
    var delegate = searchResults.itemAtIndex(0)
    verify(delegate !== null)
    verify(delegate.itemData.artists !== undefined)
    compare(delegate.itemData.artists.length, 1)
    compare(delegate.artists.length, 1)
    compare(delegate.artists[0].id, "pink-floyd")

    var link = findChild(delegate, "media-byline-artists")
    verify(link !== null)
    compare(link.linkAt(5, link.height / 2), "artist:0")
    mouseClick(link, 5, link.height / 2, Qt.LeftButton)
    verify(selectedArtist !== null)
    compare(selectedArtist.id, "pink-floyd")
  }
}
