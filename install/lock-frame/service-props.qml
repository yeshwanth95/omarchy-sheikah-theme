  // ----------------------------------------------------- unlock fade release
  // WlSessionLock destroys its surfaces the moment `locked` goes false, and
  // the surface's own `visible` is read-only, so there is no
  // `visible: open || opacity > 0` escape here the way there is for an
  // ordinary panel. The only way to fade on the way out is to hold the release
  // back, which is why finishUnlock() calls this instead of writing
  // sessionLock.locked itself.
  //
  // This sits strictly downstream of the authentication decision: finishUnlock
  // is reached only from the two PAM success paths, and nothing here can
  // release a lock that was not already being released.
  property bool unlockFading: false

  readonly property int lockFadeMs: {
    var n = Number(Color.shellValues["lock.fade-duration"])
    if (!isFinite(n) || n <= 0) return 0
    // Capped rather than trusted. This is time the session stays locked after
    // a correct password, so a theme cannot make it unbounded.
    return Math.min(1000, Math.round(n))
  }

  function releaseSessionLock() {
    // No theme fade, or nothing to fade: behave exactly as the stock line did.
    if (root.lockFadeMs <= 0 || !sessionLock.locked) {
      sessionLock.locked = false
      return
    }
    if (unlockFadeTimer.running) return
    root.unlockFading = true
    unlockFadeTimer.restart()
  }

  // A lock arriving inside the fade window wins outright. Without this, the
  // pending timer would fire against a session that had meanwhile been locked
  // again and drop the lock the user just asked for.
  onLockRequestedChanged: if (lockRequested && unlockFadeTimer.running) {
    unlockFadeTimer.stop()
    root.unlockFading = false
  }

  Timer {
    id: unlockFadeTimer
    interval: root.lockFadeMs
    repeat: false
    // The timer is the authority, never the animation. This fires and releases
    // whether or not anything on screen finished moving, so a stalled or
    // broken fade cannot keep the session locked.
    onTriggered: {
      root.unlockFading = false
      if (root.lockRequested) return  // re-locked mid-fade; abandon the release
      sessionLock.locked = false
    }
  }

