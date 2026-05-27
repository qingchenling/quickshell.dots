import Quickshell.Widgets
import Quickshell
import QtQuick

import qs.Components

Rectangle {
    property bool type: false
    property string icon_on: ""
    property string icon_off: ""
    property string text_on: ""
    property string text_off: ""

    id: capslockTip
    anchors.centerIn: parent
    width: 120
    height: 60
    radius: 30
    color: Colors.primary
    opacity: 0

    IconImage {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 6
        width: 24
        height: 24
        source: Qt.resolvedUrl(type ? parent.icon_on : parent.icon_off)
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: type ? parent.text_on : parent.text_off
        font.pointSize: 10
        font.bold: true
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        color: Colors.on_primary
    }

    onTypeChanged: {
        showAnim.stop()
        showAnim.start()
    }
    SequentialAnimation {
        id: showAnim
        NumberAnimation {
            target: capslockTip
            property: "opacity"
            to: 1
            duration: 120
            easing.type: Easing.OutCubic
        }
        PauseAnimation {
            duration: 700
        }
        NumberAnimation {
            target: capslockTip
            property: "opacity"
            to: 0
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
}
