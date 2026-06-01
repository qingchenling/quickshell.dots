import QtQuick

import qs.Themes

// Section title label — consistent typography for settings page sections.
// Usage:
//   SectionHeader { text: "Available networks" }
//   SectionHeader { text: "Wallpapers · " + count }

Rectangle {
    property string text: ""

    implicitWidth: parent ? parent.width : 200
    implicitHeight: 32

    color: "transparent"

    Text {
        anchors.left: parent.left; anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: parent.text
        font.family: "XiaoLai"; font.pixelSize: 12; font.bold: true
        color: Colors.on_surface_variant
    }
}
