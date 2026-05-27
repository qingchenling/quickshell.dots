import Quickshell.Widgets
import Quickshell
import QtQuick

import qs.Themes
import qs.Components

Button {
    height: parent.height
    width: 80
    color: "transparent"
    backColor: Colors.text("primary")

    SystemClock { id: clock }
    text: Qt.formatDateTime(clock.date, "hh : mm")
    font.bold: true

    // background
    ClippingRectangle {
        anchors.fill: parent
        color: Colors.back("secondary")
        radius: 30
        z: -1

        Row {
            anchors.top: parent.top
            anchors.topMargin: -10
            spacing: 18
            Repeater {
                model: 20
                Rectangle {
                    width: 12
                    height: 100
                    rotation: 25
                    color: Colors.back("primary")
                }
            }

            NumberAnimation on x {
                id: anim
                from: 0
                to: -30
                duration: 1200
                loops: Animation.Infinite
                running: true
            }
        }
    }

    onClicked: {
        clander.visible = !clander.visible
    }

    PopupWindow {
        id: clander
        anchor.window: panel
        anchor.rect.x: panel.width-100
        anchor.rect.y: panel.height+10
        color: "transparent"
        width: 400
        height: 400

        Rectangle {
            anchors.fill: parent
            color: Colors.surface
            radius: 20
        }
    }
}
