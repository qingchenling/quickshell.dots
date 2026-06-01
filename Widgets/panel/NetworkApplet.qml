import Quickshell
import Quickshell.Networking
import QtQuick

import qs.Services
import qs.Components
import qs.Themes

Item {
    id: root
    height: parent.height
    width: networkButton.width

    // ── State ──
    property var selectedNetwork: null
    property string passwordInput: ""
    property bool showPassword: false
    property var networksModel: []
    property bool popupShown: false

    readonly property var svc: NetworkService
    onSvcChanged: refreshNetworks()

    // ── Helpers ──
    function wifiIconPath(signalLevel) {
        let lvl = Math.min(4, Math.max(1, Math.ceil(signalLevel / 25)))
        return Qt.resolvedUrl("../../assets/wifi_" + lvl + ".svg")
    }

    function refreshNetworks() {
        networksModel = svc ? svc.getSortedNetworks() : []
        if (svc) svc.scan()
    }

    function selectNetwork(network) {
        if (!network) {
            selectedNetwork = null; showPassword = false; passwordInput = ""; return
        }
        if (network.connected) {
            svc.disconnectFromNetwork(network)
            selectedNetwork = null; scheduleRefresh(); return
        }
        if (svc.isSecure(network) && !network.known) {
            if (selectedNetwork === network && showPassword) {
                selectedNetwork = null; showPassword = false; passwordInput = ""
            } else {
                selectedNetwork = network; showPassword = true; passwordInput = ""
            }
        } else {
            svc.connectToNetwork(network)
            selectedNetwork = null; showPassword = false; scheduleRefresh()
        }
    }

    function submitPassword() {
        if (!selectedNetwork || passwordInput.trim() === "") return
        svc.connectWithPassword(selectedNetwork, passwordInput)
        showPassword = false; passwordInput = ""; selectedNetwork = null
        scheduleRefresh()
    }

    function scheduleRefresh() {
        refreshNetworks()
        refreshTimer.interval = 1500
        refreshTimer.restart()
    }

    function togglePopup() {
        // Guard against re-entrant calls while transitioning
        if (_toggling) return
        _toggling = true
        togglingTimer.start()

        if (popupShown) {
            wifiPopup.visible = false
            popupShown = false
            cleanupPopupState()
        } else {
            popupShown = true
            refreshNetworks()
            popupCard.opacity = 0
            popupCard.slideY = -30
            openAnim.start()
        }
    }

    property bool _toggling: false
    Timer {
        id: togglingTimer
        interval: 50; repeat: false
        onTriggered: _toggling = false
    }

    function cleanupPopupState() {
        selectedNetwork = null; showPassword = false; passwordInput = ""
    }

    Timer { id: refreshTimer; interval: 2000; repeat: false; onTriggered: refreshNetworks() }

    Connections {
        target: svc
        function onNetworkStateChanged() { refreshTimer.restart() }
    }

    // ── Panel button ──
    Rectangle {
        id: networkButton
        height: parent.height
        width: Math.max(90, networkRow.width + 16)
        radius: 20
        color: hoverHandler.hovered ? Colors.surface_container_highest : Colors.surface_container

        Row {
            id: networkRow
            anchors.centerIn: parent
            spacing: 8

            IconSvg {
                anchors.verticalCenter: parent.verticalCenter
                width: 18; height: 18
                path: {
                    let lvl = svc && svc.connectedNetwork ? svc.signalPercent(svc.connectedNetwork) : 0
                    if (lvl <= 0) return Qt.resolvedUrl("../../assets/wifi_1.svg")
                    return root.wifiIconPath(lvl)
                }
                color: svc && svc.connectedNetwork ? Colors.on_surface : Colors.outline_variant
                opacity: svc && svc.connectedNetwork ? 1.0 : 0.45
            }

            Text {
                id: networkLabel
                anchors.verticalCenter: parent.verticalCenter
                font.family: "XiaoLai"; font.pixelSize: 13
                color: Colors.on_surface
                elide: Text.ElideRight; maximumLineCount: 1
                text: {
                    if (!svc || !svc.wifiEnabled || !svc.wifiHardwareEnabled) return "No Network"
                    if (svc.connectedNetwork && svc.connectedNetwork.name) return svc.connectedNetwork.name
                    if (!svc.online) return "No Network"
                    return "Wi-Fi"
                }
            }
        }

        HoverHandler { id: hoverHandler }
        TapHandler { onTapped: togglePopup() }

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    // ── Popup open animation ──
    SequentialAnimation {
        id: openAnim
        ScriptAction { script: { wifiPopup.visible = true; popupCard.forceActiveFocus() } }
        ParallelAnimation {
            NumberAnimation { target: popupCard; property: "opacity"; to: 1; duration: 250; easing.type: Easing.OutCubic }
            NumberAnimation { target: popupCard; property: "slideY"; to: 0; duration: 300; easing.type: Easing.OutCubic }
        }
    }

    // ── WiFi picker popup ──
    PopupWindow {
        id: wifiPopup
        anchor.window: panel
        anchor.rect.x: parent.x + x + width - implicitWidth
        anchor.rect.y: panel.height + 6
        visible: false
        color: "transparent"
        implicitWidth: 340
        implicitHeight: Math.min(520, popupContent.implicitHeight + 20)
        mask: Region { item: popupCard }

        Rectangle {
            id: popupCard
            anchors.fill: parent
            radius: 28
            color: Colors.surface_container_high
            opacity: 1
            focus: true

            property real slideY: 0
            transform: Translate { y: popupCard.slideY }

            Rectangle {
                anchors.fill: parent; anchors.margins: -2
                radius: parent.radius + 2
                color: "transparent"
                border.color: Colors.outline_variant; border.width: 0.5
                z: -1
            }

            Column {
                id: popupContent
                width: parent.width; spacing: 0

                // Header
                Rectangle {
                    width: parent.width; height: 60
                    color: "transparent"; radius: 28

                    Text {
                        anchors.left: parent.left; anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Wi-Fi"
                        font.family: "XiaoLai"; font.pixelSize: 22; font.bold: true
                        color: Colors.on_surface
                    }

                    ToggleSwitch {
                        id: wifiToggle
                        anchors.right: parent.right; anchors.rightMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        checked: svc && svc.wifiEnabled
                        onToggled: { if (svc) svc.toggleWifi() }
                    }
                }

                // Divider
                Rectangle {
                    width: parent.width - 32; height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.outline_variant; opacity: 0.5
                }

                // WiFi disabled
                Item {
                    width: parent.width
                    height: svc && !svc.wifiEnabled ? 80 : 0
                    visible: svc && !svc.wifiEnabled
                    clip: true
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Text {
                        anchors.centerIn: parent
                        text: "Wi-Fi is turned off"
                        font.family: "XiaoLai"; font.pixelSize: 14
                        color: Colors.on_surface_variant
                    }
                }

                // No adapter
                Item {
                    width: parent.width
                    height: (!svc || !svc.wifiDevice) && svc ? 80 : 0
                    visible: (!svc || !svc.wifiDevice) && svc
                    clip: true
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Text {
                        anchors.centerIn: parent
                        text: "No Wi-Fi adapter found"
                        font.family: "XiaoLai"; font.pixelSize: 14
                        color: Colors.on_surface_variant
                    }
                }

                // Connected network
                Item {
                    width: parent.width
                    height: svc && svc.connectedNetwork && svc.wifiEnabled ? 64 : 0
                    visible: svc && svc.connectedNetwork && svc.wifiEnabled
                    clip: true
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 8; anchors.leftMargin: 12; anchors.rightMargin: 12
                        radius: 20; color: Colors.secondary_container

                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter; spacing: 12
                            IconSvg {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 20; height: 20
                                path: root.wifiIconPath(svc && svc.connectedNetwork ? svc.signalPercent(svc.connectedNetwork) : 0)
                                color: Colors.on_secondary_container
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: svc && svc.connectedNetwork ? svc.connectedNetwork.name || "Unknown" : ""
                                font.family: "XiaoLai"; font.pixelSize: 15; font.bold: true
                                color: Colors.on_secondary_container
                                elide: Text.ElideRight; width: 180; maximumLineCount: 1
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right; anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            height: 22; width: connectedBadgeText.width + 20; radius: 11
                            color: Colors.primary; opacity: 0.85
                            Text {
                                id: connectedBadgeText
                                anchors.centerIn: parent
                                text: "Connected"
                                font.family: "XiaoLai"; font.pixelSize: 11
                                color: Colors.on_primary
                            }
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

                // Available networks header
                Item {
                    width: parent.width
                    height: svc && svc.wifiEnabled ? 36 : 0
                    visible: svc && svc.wifiEnabled
                    clip: true
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Text {
                        anchors.left: parent.left; anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Available networks"
                        font.family: "XiaoLai"; font.pixelSize: 13; font.bold: true
                        color: Colors.on_surface_variant
                    }
                }

                // Networks list
                Item {
                    id: networksContainer
                    width: parent.width
                    visible: svc && svc.wifiEnabled

                    readonly property bool noNetworks: networksModel.length === 0 && svc && svc.wifiEnabled
                    readonly property real listMaxHeight: 320
                    readonly property real listInnerHeight: networksList.height
                    height: Math.min(listMaxHeight, listInnerHeight + 12) + (noNetworks ? 40 : 0)

                    Flickable {
                        id: networkFlickable
                        anchors.fill: parent
                        height: Math.min(parent.listMaxHeight, networksList.height)
                        contentHeight: networksList.height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        flickDeceleration: 3000

                        Column {
                            id: networksList
                            width: parent.width; spacing: 1

                            Repeater {
                                model: networksModel.length > 0 ? networksModel : []

                                delegate: WifiNetworkCard {
                                    readonly property var net: modelData
                                    network: net
                                    selected: root.selectedNetwork === net
                                    showPassword: root.showPassword
                                    passwordText: root.passwordInput
                                    signalLevel: svc.signalPercent(net)
                                    secured: svc.isSecure(net)
                                    iconPath: root.wifiIconPath(svc.signalPercent(net))
                                    width: networksList.width - 24
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    onTapped: network => selectNetwork(network)
                                    onSubmitPassword: submitPassword()
                                }
                            }
                        }
                    }

                    // Scrollbar
                    Rectangle {
                        anchors.right: networkFlickable.right; anchors.rightMargin: 3
                        y: networkFlickable.y + networkFlickable.visibleArea.yPosition * networkFlickable.height
                        width: 3
                        height: Math.max(20, networkFlickable.visibleArea.heightRatio * networkFlickable.height)
                        radius: 1.5; color: Colors.outline_variant
                        opacity: networkFlickable.contentHeight > networkFlickable.height ? 0.5 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    // Searching message
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: networkFlickable.bottom; anchors.topMargin: 20
                        text: networksContainer.noNetworks ? "Searching for networks..." : ""
                        font.family: "XiaoLai"; font.pixelSize: 13
                        color: Colors.on_surface_variant; visible: networksContainer.noNetworks
                    }
                }

                // Bottom padding
                Item { width: parent.width; height: 12 }
            }
        }
    }
}
