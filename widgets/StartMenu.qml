import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick

import "../components/startPlugins/"
import "../components/"

Item {
    height: parent.height
    width: startMenu.width

    PopupWindow {
        property bool is_show: true

        id: startMenu
        anchor.window: panel
        visible: true
        color: "transparent"
        
        HoverHandler { id: startHover }
        height: is_show ? 350 : panel.height
        width: is_show ? 300 : (startHover.hovered ? startRow.width+10 : panel.height)

        MD3Card {
            anchors.fill: parent

            Row {
                property int len: startMenu.is_show ? 40 : 32

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: startMenu.is_show ? 4 : 2
                anchors.leftMargin: startMenu.is_show ? 20 : 2
                id: startRow
                spacing: 5

                Behavior on height {
                    NumberAnimation { duration: 100 }
                }
                Behavior on anchors.leftMargin {
                    NumberAnimation { duration: 100 }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: startRow.len
                    width: startRow.len
                    radius: height/2
                    color: "transparent"

                    Behavior on height {
                        NumberAnimation { duration: 100 }
                    }
                    Behavior on width {
                        NumberAnimation { duration: 100 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        color: Colors.on_surface
                        text: "01"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: { startMenu.is_show = !startMenu.is_show }
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

                        anchors.top: startRow.top
                        anchors.topMargin: 2
                        height: startRow.len-6
                        width: startRow.len-6
                        radius: height/2
                        color: startItem.hovered ? Colors.primary : Colors.surface_variant

                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on height {
                            NumberAnimation { duration: 100 }
                        }
                        Behavior on width {
                            NumberAnimation { duration: 100 }
                        }
                        
                        IconImage {
                            anchors.centerIn: parent
                            width: parent.height-4
                            height: parent.width-4
                            source: Qt.resolvedUrl("../assets/"+modelData.svg)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: { startItemProc.running = true } 
                        }
                    }
                }

                BatteryIcon {
                    width: startMenu.is_show ? 90 : 0
                }
            }

            Rectangle {
                id: optionCard
                anchors.top: startRow.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width-20
                height: 150
                radius: 20
                color: Colors.surface_variant
                
                Grid {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.topMargin: 20
                    columns: 3
                    spacing: 15
                    Repeater {
                        model: 6
                        delegate: Rectangle {
                            width: (optionCard.width-4*15)/3
                            height: (optionCard.height-15-40)/2
                            radius: 10
                            color: Colors.secondary_container
                        }
                    }
                }
            }

            Column {
                anchors.top: optionCard.bottom
                anchors.topMargin: 40
                spacing: 25
                Slide {
                    anchors.horizontalCenter: startMenu.horizontalCenter
                    width: startMenu.width-20
                    height: 10
                    icon: "../assets/headphone.svg"
                }
                Slide {
                    anchors.horizontalCenter: startMenu.horizontalCenter
                    width: startMenu.width-20
                    height: 10
                    icon: "../assets/brightness.svg"
                }
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}
