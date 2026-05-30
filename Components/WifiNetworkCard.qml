import Quickshell.Networking
import QtQuick

import qs.Services
import qs.Themes

// Material You WiFi network card — extracted from NetworkApplet delegate.
// Shows the network row (icon, name, lock, status) and an expandable
// inline password field when selected.
//
// Properties:
//   network      — the WifiNetwork access-point object
//   selected     — whether this card is the selected one
//   showPassword — expand the inline password field
//   passwordText — bound password input string
//   signalLevel  — pre-computed 0-100 signal percentage
//   secured      — pre-computed whether password is required
//   iconPath     — resolved wifi SVG icon path
//
// Signals:
//   tapped(var network)           — user taps the network row
//   submitPassword()              — user submits the password

Item {
    id: root

    property var network: null
    property bool selected: false
    property bool showPassword: false
    property string passwordText: ""
    property real signalLevel: 0
    property bool secured: false
    property string iconPath: ""

    signal tapped(var network)
    signal submitPassword()

    width: parent ? parent.width : 300
    height: card.height
    visible: network != null

    // Sync TextInput when parent resets passwordText (e.g. on select/deselect)
    onPasswordTextChanged: {
        if (passwordField.text !== passwordText)
            passwordField.text = passwordText
    }

    // ── Unified card (network row + inline password) ──
    Rectangle {
        id: card
        width: parent.width
        height: topSection.height + passwordSection.height
        radius: 24
        clip: true
        scale: hover.hovered ? 1.03 : 1.0

        color: {
            if (root.selected) return Colors.surface_container_low
            if (network && network.connected) return Colors.secondary_container
            if (hover.hovered) return Colors.surface_container
            return "transparent"
        }

        Behavior on height { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // ── Top: network info row ──
        Item {
            id: topSection
            width: parent.width
            height: 48

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                IconSvg {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18; height: 18
                    path: root.iconPath
                    color: Colors.on_surface
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: network ? (network.name || "Hidden network") : ""
                    font.family: "XiaoLai"
                    font.pixelSize: 14
                    color: Colors.on_surface
                    elide: Text.ElideRight
                    width: 165
                    maximumLineCount: 1
                }
            }

            // Lock icon
            Text {
                anchors.right: statusIndicator.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: root.secured ? "\u{1F512}" : ""
                font.pixelSize: 11
                opacity: 0.7
                visible: root.secured
            }

            // Connection status badge
            Item {
                id: statusIndicator
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                width: statusText.width + 16
                height: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 11
                    color: {
                        if (!network) return "transparent"
                        if (network.state === ConnectionState.Connecting) return Colors.surface_container
                        if (network.connected) return Colors.primary
                        return "transparent"
                    }
                    opacity: network && network.state === ConnectionState.Connecting ? 0.7 : 1.0
                }

                Text {
                    id: statusText
                    anchors.centerIn: parent
                    font.family: "XiaoLai"
                    font.pixelSize: 11
                    color: {
                        if (!network) return "transparent"
                        if (network.connected) return Colors.on_primary
                        if (network.state === ConnectionState.Connecting) return Colors.on_surface_variant
                        return Colors.primary
                    }
                    text: {
                        if (!network) return ""
                        if (network.connected) return "Connected"
                        if (network.state === ConnectionState.Connecting) return "···"
                        if (network.stateChanging) return "···"
                        return "Connect"
                    }
                }
            }

            TapHandler { onTapped: root.tapped(network) }
            HoverHandler { id: hover }
        }

        // ── Bottom: inline password (same card, animates open/close) ──
        Item {
            id: passwordSection
            anchors.top: topSection.bottom
            width: parent.width
            height: root.selected && root.showPassword ? 52 : 0
            opacity: root.selected && root.showPassword ? 1 : 0

            Behavior on height {
                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            // Subtle divider
            Rectangle {
                anchors.top: parent.top
                width: parent.width - 32
                height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: Colors.outline_variant
                opacity: 0.25
            }

            Row {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 2
                spacing: 10

                Rectangle {
                    width: 180; height: 38
                    radius: 19
                    color: Colors.surface_variant

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: "XiaoLai"
                        font.pixelSize: 14
                        color: Colors.on_surface
                        echoMode: TextInput.Password
                        text: root.passwordText
                        activeFocusOnPress: true

                        onTextChanged: root.passwordText = text
                        onAccepted: root.submitPassword()

                        onVisibleChanged: {
                            if (visible) passwordField.forceActiveFocus()
                        }

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            verticalAlignment: Text.AlignVCenter
                            text: "Password"
                            font.family: "XiaoLai"
                            font.pixelSize: 14
                            color: Colors.on_surface_variant
                            visible: passwordField.text === "" && !passwordField.activeFocus
                        }
                    }
                }

                Rectangle {
                    width: 60; height: 36
                    radius: 18
                    color: passwordText.trim() !== "" ? Colors.primary : Colors.surface_container_highest

                    Text {
                        anchors.centerIn: parent
                        text: "Join"
                        font.family: "XiaoLai"
                        font.pixelSize: 14
                        font.bold: true
                        color: passwordText.trim() !== "" ? Colors.on_primary : Colors.on_surface_variant
                    }

                    TapHandler { onTapped: root.submitPassword() }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
