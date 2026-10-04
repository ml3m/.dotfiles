import QtQuick

import "Api.js" as Api

Row {
  id: root

  property var itemData: null
  property color foreground: "white"
  property color muted: Qt.darker(foreground, 1.4)
  property color accent: foreground
  property color albumColor: accent
  property string fontFamily: ""
  property real fontPixelSize: 12

  signal artistRequested(var item)
  signal albumRequested(var item)
  signal contextRequested(var item)

  readonly property var artists: {
    if (!itemData || ["track", "album"].indexOf(itemData.type) < 0) return []
    return Api.arrayValues(itemData.artists)
  }
  readonly property var primaryContext: {
    if (!itemData) return null
    if (artists.length) return artists[0]
    return itemData.parentContext || null
  }
  readonly property var albumContext: itemData && itemData.type === "track"
    ? itemData.albumItem : null

  spacing: 4

  ArtistLinks {
    id: artistLinks
    objectName: "media-byline-artists"
    width: root.albumContext
      ? Math.min(implicitWidth, Math.max(20, Math.round(root.width * 0.48)))
      : root.width
    artists: root.artists
    fallbackText: root.itemData ? String(root.itemData.subtitle || "") : ""
    fallbackClickable: root.artists.length === 0 && !!root.primaryContext
    suffixText: root.itemData ? Api.artistSubtitleSuffix(root.itemData) : ""
    color: root.muted
    accent: root.accent
    font.family: root.fontFamily
    font.pixelSize: root.fontPixelSize
    visible: fallbackText !== "" || root.artists.length > 0
    onArtistRequested: function(item) { root.artistRequested(item) }
    onFallbackRequested: if (root.primaryContext)
      root.contextRequested(root.primaryContext)
  }

  ArtistLinks {
    id: albumLink
    objectName: "media-byline-album"
    visible: !!root.albumContext
    width: visible ? Math.max(20, root.width - artistLinks.width - root.spacing) : 0
    artists: []
    fallbackText: root.albumContext
      ? "· " + String(root.albumContext.name || "Album") : ""
    fallbackClickable: visible
    color: root.albumColor
    accent: root.albumColor
    font.family: root.fontFamily
    font.pixelSize: root.fontPixelSize
    onFallbackRequested: if (root.albumContext)
      root.albumRequested(root.albumContext)
  }
}
