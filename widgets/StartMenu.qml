import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick

Rectangle {
    property int itemSize: 34
    HoverHandler { id: startAreaHover }

    height: parent.height
    width: startAreaHover.hovered ? startMenu.width : itemSize
    radius: parent.height/2
    clip: true
    color: "#333333"

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: startMenu
        spacing: 5
        anchors.verticalCenter: parent

        Rectangle {
            height: itemSize
            width: itemSize
            radius: itemSize/2
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "01"
            }
        }

        Repeater {
            model: [
                {svg: "poweroff.svg", command: ["poweroff"]},
                {svg: "reboot.svg", command: ["reboot"]},
                {svg: "logout.svg", command: ["uwsm", "stop"]}
            ]
            delegate: Rectangle {
                HoverHandler { id: startItem }
                Process { id: startItemProc; command: modelData.command }

                height: itemSize
                width: itemSize
                radius: itemSize/2
                color: startItem.hovered ? "white" : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
                
                IconImage {
                    anchors.centerIn: parent
                    width: itemSize - 10
                    height: itemSize - 10
                    source: Qt.resolvedUrl("../assets/"+modelData.svg)
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: { startItemProc.running = true } 
                }
            }
        }
    }
}
