import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick

import "components"

PanelWindow {
    property string searchText: ""
    property bool is_shown: false

    id: appLauncher
    implicitWidth: 400
    implicitHeight: 500
    color: "transparent"
    anchors.bottom: true
    exclusionMode: ExclusionMode.Normal
    focusable: true

    IpcHandler {
        target: "AppLauncher"
        function toggle() {
            is_shown = !is_shown
            if(is_shown) input.inputField.forceActiveFocus()
        }
    }

    MD3Card {
        anchors.fill: parent

        Column {
            anchors {
                fill: parent
                margins: 20
            }
            spacing: 10
           
            ListView {
                id: appList
                anchors.fill: parent
                anchors.topMargin: 48
                spacing: 5

                model: DesktopEntries.applications
                delegate: AppItem {
                    property bool is_match: {
                        var str = modelData.name.toLowerCase()
                        return searchText===""||str.indexOf(searchText)!==-1
                    }

                    width: parent.width
                    height: is_match ? 48 : -5
                    visible: is_match
                    opacity: is_match ? 1 : 0

                    icon: Quickshell.iconPath(modelData.icon)
                    text: modelData.name
                    onClicked: {
                        modelData.execute()
                        is_shown = false
                        input.inputField.clear()
                    }
                }
            }

            Row {
                height: 40
                width: parent.width
                MD3TextField {
                    id: input
                    height: 40
                    width: appLauncher.width-40
                    inputField.onTextChanged: {
                        searchText = inputField.text
                    }
                }
            }
        }
    }

    onSearchTextChanged: appList.forceLayout()

    margins.bottom: is_shown ? 10 : -550
}
