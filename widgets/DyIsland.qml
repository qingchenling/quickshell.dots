import Quickshell
import QtQuick

import "components/"

PopupWindow {
    anchor.window: panel
    height: island.height
    width: island.width
    anchor.rect.x: (panel.width-width)/2
    visible: false
    color: "transparent"

    Rectangle {
        id: island
        width: 100
        height: 34
        color: Colors.surface
        radius: 36
    }
}
