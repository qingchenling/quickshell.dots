import QtQuick

import qs.Themes

Rectangle {
    property alias font: content.font
    property bool active: false
    property bool hovered: hoverHandler.hovered
    property string text: ""
    property string activeText: text
    property string icon: ""
    property string activeIcon: icon
    property string backColor: "surface"
    property string activeColor: backColor
    signal clicked

    id: root
    color: Colors.back(active ? activeColor : backColor)
    radius: 36

    Flow {
        anchors.centerIn: parent

        IconSvg {
            width: icon==="" ? 0 : 24
            height: width
            path: root.active ? root.activeIcon : root.icon
            color: Colors.text(root.active ? root.activeColor : root.backColor)
        }
        Text {
            id: content
            verticalAlignment: Text.AlignVCenter
            height: 24
            font.family: "XiaoLai"
            color: Colors.text(root.active ? root.activeColor : root.backColor)
            text: root.active ? root.activeText : root.text
        }
    }

    TapHandler { onTapped: root.clicked() }
    HoverHandler { id: hoverHandler }

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on opacity { NumberAnimation { duration: 200 } }
}
