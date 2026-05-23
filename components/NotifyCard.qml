import QtQuick
import Quickshell.Widgets
import Quickshell

Rectangle {
    property string icon: ""
    property string name: ""
    property string content: ""
    property bool closed: false
    signal clicked

    color: Colors.surface_variant
    radius: 30
    border.width: 1
    border.color: Colors.outline_variant

    Behavior on opacity {
        NumberAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }


    Column {
        anchors.fill: parent
        anchors.topMargin: 10
        spacing: 7

        Row {
            spacing: 12
            anchors.left: parent.left
            anchors.leftMargin: 30
            IconImage {
                width: 24
                height: 24
                source: icon==="" ? "" : Quickshell.iconPath(icon)
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "XiaoLai"
                font.bold: true
                color: Colors.on_surface_variant
                text: name
            }
        }

        Rectangle {
            width: parent.width-40
            height: parent.height-40
            radius: 15
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colors.secondary
            
            Text {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 13
                anchors.topMargin: 10
                font.family: "XiaoLai"
                color: Colors.on_secondary
                text: content
                wrapMode: Text.WordWrap
                width: parent.width-13
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
    }

    onClosedChanged: {
        height = 0
        opacity = 0
        destoryTimer.start()
    }

    Timer {
        id: destoryTimer
        interval: 100
        repeat: false
        onTriggered: {
            modelData.dismiss()
        }
    }
}
