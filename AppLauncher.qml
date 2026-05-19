import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick

PanelWindow {
    id: appLauncher
    width: 400
    height: 500
    color: "transparent"

    IpcHandler {
        target: "AppLauncher"
        function toggle() {
            appLauncher.visible = !appLauncher.visible
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        
        ListView {
            width: parent.width
            height: parent.height
            spacing: 5

            model: DesktopEntries.applications
            delegate: Rectangle {
                width: parent.width
                height: 48
                color: "red"

                Row {
                    IconImage {
                        width: 48
                        height: 48
                        source: Quickshell.iconPath(modelData.icon)
                    }
                    Text {
                        text: modelData.name
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        modelData.execute()
                        appLauncher.visible = false
                    }
                }
            }
        }
    }
}
