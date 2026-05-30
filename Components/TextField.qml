import QtQuick

import qs.Themes

Rectangle {
    property alias inputField: input
    /// Background color — set to a Colors.xxx property.
    property color bgColor: Colors.surface
    /// Text color.
    property color fgColor: Colors.on_surface

    radius: 36
    color: bgColor

    TextInput {
        id: input
        focus: true
        anchors {
            fill: parent
            leftMargin: 20
            topMargin: 10
            bottomMargin: 0
        }
        color: fgColor
        font.family: "XiaoLai"
        font.pointSize: 15
    }
}
