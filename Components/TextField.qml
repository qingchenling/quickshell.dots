import QtQuick

import qs.Themes

Rectangle {
    property alias inputField: input
    property string backColor: "surface"

    radius: 36
    color: Colors.back(backColor)

    TextInput {
        id: input
        focus: true
        anchors {
            fill: parent
            leftMargin: 20
            topMargin: 10
            bottomMargin: 0
        }
        color: Colors.text(backColor)
        font.family: "XiaoLai"
        font.pointSize: 15
    }
}
