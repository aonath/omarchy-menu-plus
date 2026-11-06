import QtQuick
import Quickshell
import Quickshell.Io

// For panels the Omarchy menu opens (emojis, clipboard, image picker, app
// grid): whether this opening came from a menu row, the name of that menu for
// the "Esc …<menu>" hint, and going back to it. menuplus.menu writes the row it
// ran to $XDG_RUNTIME_DIR/omarchy-menu-handoff.json just before running it.
Item {
  id: menuReturn
  visible: false

  // Call markOpened() when the panel opens and clear() when it closes.
  property real openedAt: 0
  property var handoff: ({})

  readonly property bool fromMenu: openedAt > 0 && Number(handoff.time || 0) > 0
    && openedAt - Number(handoff.time) > -1500 && openedAt - Number(handoff.time) < 5000
  readonly property string label: fromMenu ? String(handoff.label || "Go") : ""
  readonly property string hint: "Esc …" + (label || "Cerrar")

  function markOpened() {
    openedAt = Date.now()
    handoffFile.reload()
  }

  function clear() {
    openedAt = 0
  }

  // After the panel closed on Esc: reopen the menu it came from. Returns
  // whether it did.
  function back() {
    var go = fromMenu
    clear()
    if (go) Quickshell.execDetached(["omarchy-shell", "shell", "call", "omarchy.menu", "resume", ""])
    return go
  }

  FileView {
    id: handoffFile
    path: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/omarchy-menu-handoff.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        menuReturn.handoff = JSON.parse(text()) || {}
      } catch (e) {
        menuReturn.handoff = {}
      }
    }
  }
}
