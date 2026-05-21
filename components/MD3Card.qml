import QtQuick.Effects
import QtQuick

Rectangle {
    property alias innerText: innerText 
    property bool is_active: false
    property bool is_hover: false
    property string text: ""
    signal clicked

    color: is_active ? Colors.primary : Colors.surface
    radius: 36
    border.width: 1
    border.color: Colors.outline_variant
    opacity: 0

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    Component.onCompleted: { opacity = 1 }
    Component.onDestruction: { opacity = 0 }

    Text {
        id: innerText
        anchors.centerIn: parent
        font.family: "XiaoLai"
        color: is_active ? Colors.on_primary : Colors.on_surface
        text: parent.text
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
    }
}
