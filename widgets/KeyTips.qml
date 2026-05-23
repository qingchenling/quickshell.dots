import Quickshell.Io
import Quickshell
import QtQuick

import "../components/"

PopupWindow {
    anchor.window: panel
    anchor.rect.x: (panel.width-width)/2
    anchor.rect.y: 1000
    visible: true
    color: "transparent"
    width: 200

    id: fuck
    property int qwq: 0
    TipCard {
        id: capslock
        icon_on: Qt.resolvedUrl("../assets/CAPSLOCK_on.svg")
        icon_off: Qt.resolvedUrl("../assets/CAPSLOCK_off.svg")
        text_on: "CAPS ON"
        text_off: "CAPS OFF"

        FileView {
            id: capslockFile
            path: "/sys/class/leds/input4::capslock/brightness"
            onLoaded: capslock.type = text()==="1\n"
        }
    }

    TipCard {
        id: numlock
        icon_on: Qt.resolvedUrl("../assets/NUMLOCK_on.svg")
        icon_off: Qt.resolvedUrl("../assets/NUMLOCK_off.svg")
        text_on: "NUM ON"
        text_off: "NUM OFF"

        FileView {
            id: numlockFile
            path: "/sys/class/leds/input4::numlock/brightness"
            onLoaded: numlock.type = text()==="1\n"
        }
    }

    Timer {
        interval: 50
        repeat: true
        running: true
        onTriggered: {
            capslockFile.reload()
            numlockFile.reload()
        }
    }
}
