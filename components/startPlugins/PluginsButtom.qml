import Quickshell.Widgets
import QtQuick

import "../"

Rectangle {
    id: bottom
    property string icon_on: ""
    property string icon_off: ""
    property bool active: false

    radius: active ? 20 : 10
    color: active ? Colors.primary : Colors.secondary_container

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
    Behavior on radius {
        NumberAnimation {
            duration: 150
        }
    }

    IconImage {
        anchors.centerIn: parent
        width: 24
        height: 24
        source: Qt.resolvedUrl(active ? icon_on : icon_off)
    }

    TapHandler {
        onTapped: {
            bottom.active = !bottom.active
        }
    } 
}
