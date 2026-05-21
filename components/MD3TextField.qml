import QtQuick

Rectangle {
    property alias inputField: input

    anchors.fill: parent
    radius: 36
    color: Colors.surface_variant
    TextInput {
        id: input
        focus: true
        anchors {
            fill: parent
            leftMargin: 20
            topMargin: 10
            bottomMargin: 0
        }
        color: Colors.on_surface_variant
        font.family: "XiaoLai"
        font.pointSize: 15
    }
}
