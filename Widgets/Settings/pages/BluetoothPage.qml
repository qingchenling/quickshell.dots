import Quickshell
import QtQuick

import qs.Components
import qs.Themes

// ═══════════════════════════════════════════════════════════
// Bluetooth page — Android-style settings page
// Toggle, device name, paired/available device lists
// ═══════════════════════════════════════════════════════════

Item {
    id: root

    property bool bluetoothEnabled: false
    property bool isScanning: false

    // Placeholder — replace with real Bluetooth backend when available
    property var pairedDevices: []
    property var availableDevices: []

    function toggleBluetooth() {
        bluetoothEnabled = !bluetoothEnabled
        if (bluetoothEnabled) startScan()
    }
    function startScan() {
        if (!bluetoothEnabled) return
        isScanning = true
        scanTimer.restart()
    }

    Timer {
        id: scanTimer
        interval: 5000; repeat: false
        onTriggered: { isScanning = false }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 3000

        Column {
            id: contentColumn
            width: parent.width
            spacing: 0

            // ── Title + Toggle ──
            PageHeader {
                title: "Bluetooth"
                showToggle: true
                toggleChecked: root.bluetoothEnabled
                onToggled: root.toggleBluetooth()
            }

            // ── Bluetooth disabled ──
            CollapsibleSection {
                expanded: !bluetoothEnabled
                heightWhenVisible: 64

                Rectangle {
                    anchors.fill: parent; anchors.margins: 4
                    radius: 16; color: Colors.surface_container

                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Bluetooth is turned off"
                            font.family: "XiaoLai"; font.pixelSize: 14
                            color: Colors.on_surface_variant
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Turn on to connect to nearby devices"
                            font.family: "XiaoLai"; font.pixelSize: 11
                            color: Colors.outline
                        }
                    }
                }
            }

            // ── This device card ──
            CollapsibleSection {
                expanded: bluetoothEnabled
                heightWhenVisible: 72

                Rectangle {
                    anchors.fill: parent; anchors.margins: 4
                    radius: 18; color: Colors.secondary_container

                    Row {
                        anchors.left: parent.left; anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter; spacing: 12

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 40; height: 40; radius: 20
                            color: Colors.primary

                            IconSvg {
                                anchors.centerIn: parent
                                width: 22; height: 22
                                path: Qt.resolvedUrl("../../assets/bluetooth.svg")
                                color: Colors.on_primary
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text {
                                text: "This device"
                                font.family: "XiaoLai"; font.pixelSize: 15; font.bold: true
                                color: Colors.on_secondary_container
                            }
                            Text {
                                text: bluetoothEnabled ? "Visible to nearby devices" : ""
                                font.family: "XiaoLai"; font.pixelSize: 11
                                color: Colors.on_secondary_container; opacity: 0.65
                            }
                        }
                    }

                    // Scanning indicator
                    Rectangle {
                        anchors.right: parent.right; anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        height: 26; width: scanIndicator.width + 20; radius: 13
                        color: isScanning ? Colors.tertiary_container : Colors.surface_container
                        opacity: isScanning ? 1 : 0.5

                        Row {
                            id: scanIndicator
                            anchors.centerIn: parent; spacing: 6
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 8; height: 8; radius: 4
                                color: isScanning ? Colors.on_tertiary_container : Colors.outline

                                SequentialAnimation on opacity {
                                    running: isScanning
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1; to: 0.3; duration: 500; easing.type: Easing.InOutCubic }
                                    NumberAnimation { from: 0.3; to: 1; duration: 500; easing.type: Easing.InOutCubic }
                                }
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: isScanning ? "Scanning..." : "Idle"
                                font.family: "XiaoLai"; font.pixelSize: 11
                                color: isScanning ? Colors.on_tertiary_container : Colors.on_surface_variant
                            }
                        }

                        TapHandler { onTapped: root.startScan() }

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
            }

            // ── Paired devices ──
            SectionHeader {
                text: "Paired devices"
                visible: bluetoothEnabled && pairedDevices.length > 0
            }

            Repeater {
                model: pairedDevices.length > 0 && bluetoothEnabled ? pairedDevices : []
                delegate: Rectangle {
                    width: parent.width - 8; height: 56
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 16; color: Colors.surface_container

                    Row {
                        anchors.left: parent.left; anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter; spacing: 12

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 36; height: 36; radius: 18
                            color: Colors.primary_container

                            IconSvg {
                                anchors.centerIn: parent
                                width: 18; height: 18
                                path: Qt.resolvedUrl("../../assets/bluetooth.svg")
                                color: Colors.on_primary_container
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text {
                                text: modelData.name || "Unknown device"
                                font.family: "XiaoLai"; font.pixelSize: 14
                                color: Colors.on_surface
                            }
                            Text {
                                text: modelData.connected ? "Connected" : "Paired"
                                font.family: "XiaoLai"; font.pixelSize: 11
                                color: modelData.connected ? Colors.primary : Colors.on_surface_variant
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right; anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        height: 28; width: 32; radius: 14
                        color: Colors.surface_container_highest

                        IconSvg {
                            anchors.centerIn: parent
                            width: 16; height: 16
                            path: Qt.resolvedUrl("../../assets/settings.svg")
                            color: Colors.on_surface_variant
                        }

                        TapHandler { onTapped: { /* device options */ } }
                    }
                }
            }

            // ── Available devices ──
            SectionHeader {
                text: availableDevices.length > 0 ? "Available devices" : "No devices found"
                visible: bluetoothEnabled
            }

            Repeater {
                model: availableDevices.length > 0 && bluetoothEnabled ? availableDevices : []
                delegate: Rectangle {
                    width: parent.width - 8; height: 56
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 16; color: "transparent"

                    Row {
                        anchors.left: parent.left; anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter; spacing: 12

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 36; height: 36; radius: 18
                            color: Colors.surface_container

                            IconSvg {
                                anchors.centerIn: parent
                                width: 18; height: 18
                                path: Qt.resolvedUrl("../../assets/bluetooth.svg")
                                color: Colors.on_surface_variant
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text {
                                text: modelData.name || "Unknown device"
                                font.family: "XiaoLai"; font.pixelSize: 14
                                color: Colors.on_surface
                            }
                            Text {
                                text: modelData.type || "Bluetooth device"
                                font.family: "XiaoLai"; font.pixelSize: 11
                                color: Colors.on_surface_variant
                            }
                        }
                    }

                    TapHandler { onTapped: { /* pair */ } }
                    HoverHandler {
                        onHoveredChanged: parent.color = hovered ? Colors.surface_container : "transparent"
                    }
                }
            }

            // ── Empty state ──
            CollapsibleSection {
                expanded: bluetoothEnabled && availableDevices.length === 0
                          && pairedDevices.length === 0 && !isScanning
                heightWhenVisible: 80

                Rectangle {
                    anchors.fill: parent; anchors.margins: 4
                    radius: 16; color: "transparent"
                    border.color: Colors.outline_variant; border.width: 1

                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No nearby Bluetooth devices"
                            font.family: "XiaoLai"; font.pixelSize: 14
                            color: Colors.on_surface_variant
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Tap Scan to search for devices"
                            font.family: "XiaoLai"; font.pixelSize: 11
                            color: Colors.outline
                        }
                    }
                }
            }

            // Bottom spacing
            Item { width: parent.width; height: 24 }
        }
    }
}
