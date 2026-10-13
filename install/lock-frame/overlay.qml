    // Decorative frame from the active theme: above the blurred wallpaper,
    // below the passphrase field. Declared after the full-screen MouseArea, so
    // declaration order puts it over the blur; an Image takes no mouse events,
    // so the wake click still reaches the MouseArea underneath.
    Image {
      id: themeFrame
      anchors.fill: parent
      source: root.frameUrl
      // The art is a bezel welded to the screen edges, not a picture, and its
      // canvas is 1.722:1 against a usually-16:9 screen. Stretching keeps the
      // bands on the edges; fitting would float them inward.
      fillMode: Image.Stretch
      asynchronous: true
      // Matches the wallpaper above: the URL is reused across themes, and a
      // full-screen ARGB frame is too big to want in the pixmap cache.
      cache: false
      // Decode at physical pixels; a logical-size raster is soft on a scaled
      // output, and these two monitors run 1.6 and 1.2.
      sourceSize.width: Math.round(width * Screen.devicePixelRatio)
      sourceSize.height: Math.round(height * Screen.devicePixelRatio)
      // No flash while loading, and nothing drawn if a theme names a file it
      // does not ship. Guard on status: an empty source is never Ready.
      visible: status === Image.Ready
    }

