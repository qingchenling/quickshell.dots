import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 8
    height: parent.height
    Repeater {
        model: Hyprland.workspaces
        delegate: Rectangle {
            radius: 20
            width: 65
            opacity: 0
            height: parent.height
            color: modelData.active ? "#ffffff" : "#2D2D3D"

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
            Component.onCompleted: { opacity = 1 }
            Component.onDestruction: { opacity = 0 }

            Text {
                anchors.centerIn: parent
                text: modelData.id
            }
            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
            }
        }
    }
}
