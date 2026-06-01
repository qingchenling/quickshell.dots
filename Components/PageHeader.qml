import QtQuick

import qs.Themes

// Page title bar with an optional toggle switch on the right.
// Used at the top of settings pages (WiFi, Bluetooth, etc.).
//
// Usage:
//   PageHeader {
//       title: "Wi-Fi"
//       showToggle: true
//       toggleChecked: svc.wifiEnabled
//       onToggled: svc.toggleWifi()
//   }
//   // Without toggle (plain title only):
//   PageHeader { title: "Wallpaper" }

Rectangle {
    id: root

    property string title: ""
    property bool showToggle: false
    property bool toggleChecked: false

    signal toggled()

    implicitWidth: parent ? parent.width : 200
    implicitHeight: 52
    color: "transparent"

    Text {
        anchors.left: parent.left; anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        font.family: "XiaoLai"; font.pixelSize: 20; font.bold: true
        color: Colors.on_surface
    }

    Loader {
        active: root.showToggle
        sourceComponent: root._toggleComponent
        anchors.right: parent.right; anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
    }

    property Component _toggleComponent: Component {
        ToggleSwitch {
            checked: root.toggleChecked
            onToggled: root.toggled()
        }
    }
}
