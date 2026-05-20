import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

import "../components"

MD3Card {
    height: parent.height
    width: trayRow.implicitWidth + 20

    Row {
        id: trayRow
        spacing: 5
        anchors.centerIn: parent
    
        Repeater {
            model: SystemTray.items
            delegate: Item {
                width: 17
                height: 17

                IconImage {
                    anchors.fill: parent
                    source: modelData.icon
                }
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

