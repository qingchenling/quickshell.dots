import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

import qs.Themes

Rectangle {
    height: parent.height
    width: trayRow.implicitWidth + 20
    color: Colors.surface
    radius: 36

    Row {
        id: trayRow
        spacing: 5
        anchors.centerIn: parent
    
        Repeater {
            model: SystemTray.items
            delegate: Rectangle {
                width: 24; height: 24
                radius: 8
                color: trayHover.hovered ? Colors.surface_container_highest : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }

                IconImage {
                    anchors.centerIn: parent
                    width: 17; height: 17
                    source: modelData.icon
                }

                HoverHandler { id: trayHover }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if(mouse.button === Qt.LeftButton)
                        modelData.activate()
                    }
                    onPressed: mouse => {
                        if(mouse.button === Qt.RightButton)
                        {
                            const p = mapToItem(null, mouse.x, mouse.y)
                            modelData.display(panel, p.x, p.y)
                        }
                    }
                }
            }
        }
    }
}

