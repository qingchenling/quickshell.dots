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

    /// Background color (normal state).  Set to a Colors.xxx property.
    property color bgColor: Colors.surface
    /// Text / icon color (normal state).
    property color fgColor: Colors.on_surface
    /// Background color when active.
    property color activeBgColor: bgColor
    /// Text / icon color when active.
    property color activeFgColor: fgColor

    signal clicked

    id: root
    color: active ? activeBgColor : bgColor
    radius: 36

    Row {
        anchors.centerIn: parent
        spacing: 10

        IconSvg {
            width: icon === "" ? 0 : 24
            height: width
            path: root.active ? root.activeIcon : root.icon
            color: root.active ? root.activeFgColor : root.fgColor
        }
        Text {
            id: content
            verticalAlignment: Text.AlignVCenter
            height: 24
            font.family: "XiaoLai"
            color: root.active ? root.activeFgColor : root.fgColor
            text: root.active ? root.activeText : root.text
        }
    }

    TapHandler { id: tapHandler; onTapped: root.clicked() }
    HoverHandler { id: hoverHandler }

    scale: tapHandler.pressed ? 0.92 : 1.0
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on opacity { NumberAnimation { duration: 200 } }
}
