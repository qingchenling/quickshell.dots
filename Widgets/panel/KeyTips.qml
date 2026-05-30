import Quickshell.Io
import Quickshell
import QtQuick

import qs.Components

PopupWindow {
    anchor.window: panel
    anchor.rect.x: (panel.width-width)/2
    anchor.rect.y: 1000
    visible: true
    color: "transparent"
    width: 200
    mask: Region {}

   KeyTips_card { 
        id: capslock
        activeIcon: Qt.resolvedUrl("../../assets/CAPSLOCK_on.svg")
        icon: Qt.resolvedUrl("../../assets/CAPSLOCK_off.svg")
        activeText: "CAPS ON"
        text: "CAPS OFF"

        FileView {
            id: capslockFile
            path: "/sys/class/leds/input4::capslock/brightness"
            onLoaded: capslock.active = text()==="1\n"
        }
    }

    KeyTips_card {
        id: numlock
        activeIcon: Qt.resolvedUrl("../../assets/NUMLOCK_on.svg")
        icon: Qt.resolvedUrl("../../assets/NUMLOCK_off.svg")
        activeText: "NUM ON"
        text: "NUM OFF"

        FileView {
            id: numlockFile
            path: "/sys/class/leds/input4::numlock/brightness"
            onLoaded: numlock.active = text()==="1\n"
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
