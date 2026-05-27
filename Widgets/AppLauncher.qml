import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick

import qs.Components
import qs.Themes
import "appLauncher"

PanelWindow {
    property string searchText: ""
    property bool shown: false

    id: root
    margins.bottom: shown ? 10 : -550
    implicitWidth: 400      // width
    implicitHeight: 500     // height
    color: "transparent"
    anchors.bottom: true
    exclusionMode: ExclusionMode.Normal
    focusable: true

    IpcHandler {
        target: "AppLauncher"
        function toggle() {
            shown = !shown
            if(shown) {
                input.inputField.forceActiveFocus()
                input.inputField.text = ""
                underline.y = 0
            }
        }
    }

    Rectangle { // 主要 Card
        id: card
        anchors.fill: parent
        radius: 36
        color: Colors.back("surface")
        
        ListView { // 应用列表
            id: appList
            anchors.fill: parent
            anchors.topMargin: 48
            spacing: 5

            model: DesktopEntries.applications
            delegate: Row {
                property bool shown: {
                    if(root.searchText==="") return true
                    if(modelData.name.includes(root.searchText)) return true
                    return false
                }

                id: appItem
                leftPadding: 20
                height: shown ? 48 : -5
                width: parent.width
                opacity: shown ? 1 : 0
                spacing: 10

                Behavior on height {NumberAnimation{}}
                Behavior on opacity {NumberAnimation{}}

                IconImage {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    source: Quickshell.iconPath(modelData.icon)
                }

                Text {
                    text: modelData.name
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.text("surface")
                }

                TapHandler {
                    onTapped: {
                        modelData.execute()
                        root.shown = false
                    }
                }
                HoverHandler {
                    onPointChanged: {
                        if(!hovered) return
                        underline.y = mapToItem(card,0,0).y+height
                    }
                }
            }
        }

        Rectangle { // 下划线
            id: underline
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width-40
            height: 3
            radius: 3
            opacity: y!==0
            color: Colors.back("outline")

            Behavior on y { NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }}
        }

        Row { // 功能栏
            height: 40
            topPadding: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            TextField {
                id: input
                height: 40
                backColor: "surface_variant"
                width: root.width-40
                inputField.onTextChanged: root.searchText = inputField.text
            }
        }
    }
}
