import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

Rectangle {
    property string text: ""
    property string icon: ""
    signal clicked

    HoverHandler { id: appItemHover }
    id: appItem
    color: "transparent"

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
    
    Row {
        anchors {
            fill: parent
            leftMargin: 20
        }
        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            source: appItem.icon
        }
        Text {
            anchors.centerIn: parent
            font.family: "XiaoLai"
            font.pointSize: 12
            color: Colors.on_surface
            text: appItem.text
        }
    }

    Rectangle { // border
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: Colors.outline
        visible: appItemHover.hovered
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
    }
}
