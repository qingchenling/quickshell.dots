import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick

import qs.Services
import qs.Components
import qs.Themes

// ═══════════════════════════════════════════════════════════
// WiFi page — Android-style: toggle at top, connected card,
// scrollable available networks list
// ═══════════════════════════════════════════════════════════

Item {
    id: root

    property string passwordInput: ""
    property bool showPassword: false
    property var selectedNetwork: null
    property var networksModel: []

    // ── Connection failure tracking ──
    property var pendingNetwork: null

    readonly property var svc: NetworkService

    function wifiIconPath(level) {
        let lvl = Math.min(4, Math.max(1, Math.ceil(level / 25)))
        return Qt.resolvedUrl("../../assets/wifi_" + lvl + ".svg")
    }

    function refreshNetworks() {
        networksModel = svc ? svc.getSortedNetworks() : []
        if (svc) svc.scan()
    }
    function scheduleRefresh() { refreshNetworks(); refreshTimer.restart() }

    function selectNetwork(network) {
        if (!network) { selectedNetwork = null; showPassword = false; passwordInput = ""; return }
        if (network.connected) { svc.disconnectFromNetwork(network); selectedNetwork = null; scheduleRefresh(); return }
        if (svc.isSecure(network) && !network.known) {
            if (selectedNetwork === network && showPassword) {
                selectedNetwork = null; showPassword = false; passwordInput = ""
            } else {
                selectedNetwork = network; showPassword = true; passwordInput = ""
            }
        } else { svc.connectToNetwork(network); selectedNetwork = null; showPassword = false; scheduleRefresh() }
    }
    function submitPassword() {
        if (!selectedNetwork || passwordInput.trim() === "") return
        pendingNetwork = selectedNetwork
        svc.connectWithPassword(selectedNetwork, passwordInput)
        showPassword = false; passwordInput = ""
        connectTimer.restart()
        scheduleRefresh()
    }

    Timer { id: refreshTimer; interval: 1500; repeat: false; onTriggered: refreshNetworks() }

    // ── Connection timeout: detect failure after password submit ──
    Timer {
        id: connectTimer
        interval: 8000
        repeat: false
        onTriggered: {
            if (!pendingNetwork) return
            if (pendingNetwork.connected) {
                pendingNetwork = null
            } else {
                _handleConnectFailed()
            }
        }
    }

    function _handleConnectFailed() {
        if (!pendingNetwork) return
        var net = pendingNetwork
        var netName = net.name || "Unknown"
        pendingNetwork = null
        if (svc.isSecure(net)) {
            selectedNetwork = net
            showPassword = true
            passwordInput = ""
        }
        _notifyConnFailed(netName)
    }

    function _handleConnectSuccess() {
        if (!pendingNetwork) return
        pendingNetwork = null
        connectTimer.stop()
        selectedNetwork = null
        showPassword = false
        passwordInput = ""
    }

    function _notifyConnFailed(networkName) {
        connFailedProc.command = [
            "dbus-send", "--session", "--type=method_call",
            "--dest=org.freedesktop.Notifications",
            "/org/freedesktop/Notifications",
            "org.freedesktop.Notifications.Notify",
            "string:quickshell", "uint32:0",
            "string:network-wireless-offline-symbolic",
            "string:Wi-Fi Connection Failed",
            "string:Failed to connect to " + networkName + ". Please check your password.",
            "array:string:", "dict:string:variant:", "int32:5000"
        ]
        connFailedProc.running = true
    }

    Process { id: connFailedProc; running: false }

    Connections {
        target: svc
        function onNetworkStateChanged() {
            refreshTimer.restart()
            if (pendingNetwork && pendingNetwork.connected) {
                _handleConnectSuccess()
            }
        }
    }

    Component.onCompleted: refreshNetworks()

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
                title: "Wi-Fi"
                showToggle: true
                toggleChecked: svc && svc.wifiEnabled
                onToggled: { if (svc) svc.toggleWifi() }
            }

            // ── WiFi disabled ──
            CollapsibleSection {
                expanded: svc && !svc.wifiEnabled
                heightWhenVisible: 64

                Rectangle {
                    anchors.fill: parent; anchors.margins: 4
                    radius: 16; color: Colors.surface_container
                    Text {
                        anchors.centerIn: parent
                        text: "Wi-Fi is turned off"
                        font.family: "XiaoLai"; font.pixelSize: 14
                        color: Colors.on_surface_variant
                    }
                }
            }

            // ── No adapter ──
            CollapsibleSection {
                expanded: (!svc || !svc.wifiDevice) && svc
                heightWhenVisible: 64

                Rectangle {
                    anchors.fill: parent; anchors.margins: 4
                    radius: 16; color: Colors.error_container
                    Text {
                        anchors.centerIn: parent
                        text: "No Wi-Fi adapter found"
                        font.family: "XiaoLai"; font.pixelSize: 14
                        color: Colors.on_error_container
                    }
                }
            }

            // ── Connected network card ──
            CollapsibleSection {
                expanded: svc && svc.connectedNetwork && svc.wifiEnabled
                heightWhenVisible: 64

                Rectangle {
                    anchors.fill: parent; anchors.margins: 4
                    radius: 18; color: Colors.secondary_container

                    Row {
                        anchors.left: parent.left; anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter; spacing: 12

                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22; height: 22
                            path: root.wifiIconPath(svc && svc.connectedNetwork ? svc.signalPercent(svc.connectedNetwork) : 0)
                            color: Colors.on_secondary_container
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text {
                                text: svc && svc.connectedNetwork ? svc.connectedNetwork.name || "Unknown" : ""
                                font.family: "XiaoLai"; font.pixelSize: 15; font.bold: true
                                color: Colors.on_secondary_container
                                elide: Text.ElideRight; width: 200; maximumLineCount: 1
                            }
                            Text {
                                text: "Connected · " + (svc && svc.connectedNetwork ? svc.securityLabel(svc.connectedNetwork) || "Open" : "")
                                font.family: "XiaoLai"; font.pixelSize: 11
                                color: Colors.on_secondary_container; opacity: 0.7
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right; anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        height: 26; width: disconnectText.width + 20; radius: 13
                        color: Colors.primary; opacity: 0.85

                        Text {
                            id: disconnectText
                            anchors.centerIn: parent
                            text: "Disconnect"
                            font.family: "XiaoLai"; font.pixelSize: 11
                            color: Colors.on_primary
                        }

                        TapHandler {
                            onTapped: {
                                if (svc && svc.connectedNetwork) {
                                    svc.disconnectFromNetwork(svc.connectedNetwork)
                                    scheduleRefresh()
                                }
                            }
                        }
                    }
                }
            }

            // ── Available networks ──
            SectionHeader {
                text: "Available networks"
                visible: svc && svc.wifiEnabled
            }

            // Networks list
            Column {
                width: parent.width
                spacing: 2
                visible: svc && svc.wifiEnabled

                Repeater {
                    model: networksModel.length > 0 ? networksModel : []
                    delegate: WifiNetworkCard {
                        readonly property var net: modelData
                        network: net
                        selected: root.selectedNetwork === net
                        showPassword: root.showPassword
                        passwordText: root.passwordInput
                        signalLevel: svc ? svc.signalPercent(net) : 0
                        secured: svc ? svc.isSecure(net) : false
                        iconPath: root.wifiIconPath(svc ? svc.signalPercent(net) : 0)
                        width: parent.width - 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        onTapped: root.selectNetwork(net)
                        onSubmitPassword: root.submitPassword()
                    }
                }
            }

            // Searching indicator
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: svc && svc.wifiEnabled && networksModel.length === 0 ? "Searching for networks..." : ""
                font.family: "XiaoLai"; font.pixelSize: 13
                color: Colors.on_surface_variant
                topPadding: 16
                visible: svc && svc.wifiEnabled && networksModel.length === 0
            }

            // Bottom spacing
            Item { width: parent.width; height: 24 }
        }
    }
}
