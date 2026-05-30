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

    // ═══════════════════════════════════════════════════════════
    // Internal state
    // ═══════════════════════════════════════════════════════════

    property var selectedNetwork: null
    property string passwordInput: ""
    property bool showPassword: false
    property var networksModel: []

    readonly property var svc: NetworkService

    onSvcChanged: refreshNetworks()

    // ── WiFi icon helper ──
    function wifiIconPath(signalLevel) {
        let lvl = Math.min(4, Math.max(1, Math.ceil(signalLevel / 25)))
        return Qt.resolvedUrl("../../assets/wifi_" + lvl + ".svg")
    }

    function refreshNetworks() {
        if (!svc || !svc.wifiDevice || !svc.wifiDevice.networks) {
            networksModel = []
            return
        }
        svc.scan()
        let nets = svc.wifiDevice.networks.values
        let arr = []
        for (let i = 0; i < nets.length; i++) {
            // Filter out null / already-destroyed entries — the backend
            // may remove access points while we are iterating.
            if (nets[i]) arr.push(nets[i])
        }
        arr.sort((a, b) => {
            if (!a || !b) return 0
            if (a.connected && !b.connected) return -1
            if (!a.connected && b.connected) return 1
            let sa = a.signalStrength !== undefined ? a.signalStrength : -999
            let sb = b.signalStrength !== undefined ? b.signalStrength : -999
            return sb - sa
        })
        networksModel = arr
    }

    function selectNetwork(network) {
        if (!network) {
            selectedNetwork = null
            showPassword = false
            passwordInput = ""
            return
        }
        if (network.connected) {
            svc.disconnectFromNetwork(network)
            selectedNetwork = null
            scheduleRefresh()
            return
        }
        if (svc.isSecure(network) && !network.known) {
            // Toggle: if already selected, close the password prompt
            if (selectedNetwork === network && showPassword) {
                selectedNetwork = null
                showPassword = false
                passwordInput = ""
            } else {
                selectedNetwork = network
                showPassword = true
                passwordInput = ""
            }
        } else {
            svc.connectToNetwork(network)
            selectedNetwork = null
            showPassword = false
            scheduleRefresh()
        }
    }

    function submitPassword() {
        if (!selectedNetwork || passwordInput.trim() === "") return
        svc.connectWithPassword(selectedNetwork, passwordInput)
        showPassword = false
        passwordInput = ""
        selectedNetwork = null
        scheduleRefresh()
    }

    // Refresh immediately, then again after a short delay so the backend
    // has time to update connection state
    function scheduleRefresh() {
        refreshNetworks()
        refreshTimer.interval = 1500
        refreshTimer.restart()
    }

    function togglePopup() {
        if (wifiPopup.visible) {
            closeAnim.start()
        } else {
            refreshNetworks()
            openAnim.start()
        }
    }

    function cleanupPopupState() {
        selectedNetwork = null
        showPassword = false
        passwordInput = ""
    }

    Timer {
        id: refreshTimer
        interval: 2000
        repeat: false
        onTriggered: refreshNetworks()
    }

    Connections {
        target: svc
        function onNetworkStateChanged() {
            refreshTimer.restart()
        }
    }

    // ═══════════════════════════════════════════════════════════
    // Panel button — compact status display
    // ═══════════════════════════════════════════════════════════

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
                width: 18
                height: 18
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
                font.family: "XiaoLai"
                font.pixelSize: 13
                color: Colors.on_surface
                elide: Text.ElideRight
                maximumLineCount: 1

                text: {
                    if (!svc || !svc.wifiEnabled || !svc.wifiHardwareEnabled)
                        return "No Network"
                    if (svc.connectedNetwork && svc.connectedNetwork.name)
                        return svc.connectedNetwork.name
                    if (!svc.online)
                        return "No Network"
                    return "Wi-Fi"
                }
            }
        }

        HoverHandler { id: hoverHandler }

        TapHandler { onTapped: togglePopup() }

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    // ═══════════════════════════════════════════════════════════
    // Pop-up animations
    // ═══════════════════════════════════════════════════════════

    SequentialAnimation {
        id: openAnim
        ScriptAction { script: { wifiPopup.visible = true; popupCard.forceActiveFocus() } }
        ParallelAnimation {
            NumberAnimation { target: popupCard; property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
            NumberAnimation { target: popupCard; property: "slideY"; from: -30; to: 0; duration: 300; easing.type: Easing.OutCubic }
        }
    }

    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
            NumberAnimation { target: popupCard; property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
            NumberAnimation { target: popupCard; property: "slideY"; from: 0; to: -20; duration: 200; easing.type: Easing.InCubic }
        }
        ScriptAction { script: { wifiPopup.visible = false; cleanupPopupState() } }
    }

    // ═══════════════════════════════════════════════════════════
    // WiFi picker popup — Android-style network selector
    // ═══════════════════════════════════════════════════════════

    PopupWindow {
        id: wifiPopup
        anchor.window: panel
        // Position below the network button, right-aligned with it
        anchor.rect.x: parent.x + x + width - implicitWidth
        anchor.rect.y: panel.height + 6
        visible: false
        color: "transparent"
        grabFocus: true
        implicitWidth: 340
        implicitHeight: Math.min(520, popupContent.implicitHeight + 20)
        mask: Region { item: popupCard }

        Rectangle {
            id: popupCard
            anchors.fill: parent
            radius: 28
            color: Colors.surface_container_high
            opacity: 1
            // Grab focus so keyboard input reaches TextInput fields
            focus: true

            property real slideY: 0
            transform: Translate { y: popupCard.slideY }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                radius: parent.radius + 2
                color: "transparent"
                border.color: Colors.outline_variant
                border.width: 0.5
                z: -1
            }

            Column {
                id: popupContent
                width: parent.width
                spacing: 0

                // ── Header: title + toggle ──
                Rectangle {
                    width: parent.width
                    height: 60
                    color: "transparent"
                    radius: 28

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Wi-Fi"
                        font.family: "XiaoLai"
                        font.pixelSize: 22
                        font.bold: true
                        color: Colors.on_surface
                    }

                    Rectangle {
                        id: wifiToggle
                        anchors.right: parent.right
                        anchors.rightMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        width: 52
                        height: 32
                        radius: 16
                        color: svc && svc.wifiEnabled ? Colors.primary : Colors.surface_container_highest

                        Rectangle {
                            id: toggleKnob
                            width: 24
                            height: 24
                            radius: 12
                            color: svc && svc.wifiEnabled ? Colors.on_primary : Colors.outline_variant
                            anchors.verticalCenter: parent.verticalCenter
                            x: svc && svc.wifiEnabled ? parent.width - width - 4 : 4

                            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        }

                        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }

                        TapHandler { onTapped: { if (svc) svc.toggleWifi() } }

                        scale: tapHandler.pressed ? 0.92 : 1.0
                        TapHandler { id: tapHandler }
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                    }
                }

                // ── Divider ──
                Rectangle {
                    width: parent.width - 32
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.outline_variant
                    opacity: 0.5
                }

                // ── WiFi disabled message ──
                Item {
                    width: parent.width
                    height: svc && !svc.wifiEnabled ? 80 : 0
                    visible: svc && !svc.wifiEnabled
                    clip: true
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    Text {
                        anchors.centerIn: parent
                        text: "Wi-Fi is turned off"
                        font.family: "XiaoLai"
                        font.pixelSize: 14
                        color: Colors.on_surface_variant
                    }
                }

                // ── No WiFi hardware message ──
                Item {
                    width: parent.width
                    height: (!svc || !svc.wifiDevice) && svc ? 80 : 0
                    visible: (!svc || !svc.wifiDevice) && svc
                    clip: true
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    Text {
                        anchors.centerIn: parent
                        text: "No Wi-Fi adapter found"
                        font.family: "XiaoLai"
                        font.pixelSize: 14
                        color: Colors.on_surface_variant
                    }
                }

                // ── Connected network card ──
                Item {
                    width: parent.width
                    height: svc && svc.connectedNetwork && svc.wifiEnabled ? 64 : 0
                    visible: svc && svc.connectedNetwork && svc.wifiEnabled
                    clip: true
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 8
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        radius: 20
                        color: Colors.secondary_container

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            IconSvg {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 20
                                height: 20
                                path: root.wifiIconPath(
                                    svc && svc.connectedNetwork ? svc.signalPercent(svc.connectedNetwork) : 0)
                                color: Colors.on_secondary_container
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: svc && svc.connectedNetwork ? svc.connectedNetwork.name || "Unknown" : ""
                                font.family: "XiaoLai"
                                font.pixelSize: 15
                                font.bold: true
                                color: Colors.on_secondary_container
                                elide: Text.ElideRight
                                width: 180
                                maximumLineCount: 1
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            height: 22
                            width: connectedBadgeText.width + 20
                            radius: 11
                            color: Colors.primary
                            opacity: 0.85

                            Text {
                                id: connectedBadgeText
                                anchors.centerIn: parent
                                text: "Connected"
                                font.family: "XiaoLai"
                                font.pixelSize: 11
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

                // ── "Available networks" section header ──
                Item {
                    width: parent.width
                    height: svc && svc.wifiEnabled ? 36 : 0
                    visible: svc && svc.wifiEnabled
                    clip: true
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Available networks"
                        font.family: "XiaoLai"
                        font.pixelSize: 13
                        font.bold: true
                        color: Colors.on_surface_variant
                    }
                }

                // ── Networks list (scrollable) ──
                Item {
                    width: parent.width
                    height: Math.min(listMaxHeight, listInnerHeight + 12) + (noNetworks ? 40 : 0)
                    visible: svc && svc.wifiEnabled

                    readonly property bool noNetworks: networksModel.length === 0 && svc && svc.wifiEnabled
                    readonly property real listMaxHeight: 320
                    readonly property real listInnerHeight: networksList.height

                    Flickable {
                        id: networkFlickable
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: Math.min(parent.listMaxHeight, networksList.height)
                        contentHeight: networksList.height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        flickDeceleration: 3000

                        Column {
                            id: networksList
                            width: parent.width
                            spacing: 1

                            Repeater {
                                model: networksModel.length > 0 ? networksModel : []

                                delegate: Item {
                                    // Alias — may become null if the backend destroys
                                    // the network object (e.g. access-point removal).
                                    readonly property var net: modelData

                                    width: networksList.width - 24
                                    height: card.height
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    visible: net != null

                                    // ── Unified card (network row + inline password) ──
                                    Rectangle {
                                        id: card
                                        width: parent.width
                                        height: topSection.height + passwordSection.height
                                        radius: 24
                                        clip: true
                                        scale: hover.hovered && net ? 1.03 : 1.0

                                        color: {
                                            if (!net) return "transparent"
                                            if (root.selectedNetwork === net) return Colors.surface_container_low
                                            if (net.connected) return Colors.secondary_container
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
                                                    width: 18
                                                    height: 18
                                                    path: root.wifiIconPath(svc.signalPercent(net))
                                                    color: Colors.on_surface
                                                }

                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: net ? (net.name || "Hidden network") : ""
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
                                                text: svc && net && svc.isSecure(net) ? "🔒" : ""
                                                font.pixelSize: 11
                                                opacity: 0.7
                                                visible: svc && net && svc.isSecure(net)
                                            }

                                            // Connection status
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
                                                        if (!net) return "transparent"
                                                        if (net.state === ConnectionState.Connecting) return Colors.surface_container
                                                        if (net.connected) return Colors.primary
                                                        return "transparent"
                                                    }
                                                    opacity: net && net.state === ConnectionState.Connecting ? 0.7 : 1.0
                                                }

                                                Text {
                                                    id: statusText
                                                    anchors.centerIn: parent
                                                    font.family: "XiaoLai"
                                                    font.pixelSize: 11
                                                    color: {
                                                        if (!net) return "transparent"
                                                        if (net.connected) return Colors.on_primary
                                                        if (net.state === ConnectionState.Connecting) return Colors.on_surface_variant
                                                        return Colors.primary
                                                    }
                                                    text: {
                                                        if (!net) return ""
                                                        if (net.connected) return "Connected"
                                                        if (net.state === ConnectionState.Connecting) return "···"
                                                        if (net.stateChanging) return "···"
                                                        return "Connect"
                                                    }
                                                }
                                            }

                                            TapHandler { onTapped: { if (net) selectNetwork(net) } }
                                            HoverHandler { id: hover }
                                        }

                                        // ── Bottom: inline password (same card, animates open/close) ──
                                        Item {
                                            id: passwordSection
                                            anchors.top: topSection.bottom
                                            width: parent.width
                                            height: root.selectedNetwork === net && root.showPassword && net ? 52 : 0
                                            opacity: root.selectedNetwork === net && root.showPassword && net ? 1 : 0

                                            Behavior on height {
                                                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                                            }
                                            Behavior on opacity {
                                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                            }

                                            // Subtle divider between network row and password
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
                                                    width: 180
                                                    height: 38
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
                                                        text: root.passwordInput
                                                        activeFocusOnPress: true

                                                        onTextChanged: root.passwordInput = text
                                                        onAccepted: submitPassword()

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
                                                    width: 60
                                                    height: 36
                                                    radius: 18
                                                    color: passwordInput.trim() !== "" ? Colors.primary : Colors.surface_container_highest

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "Join"
                                                        font.family: "XiaoLai"
                                                        font.pixelSize: 14
                                                        font.bold: true
                                                        color: passwordInput.trim() !== "" ? Colors.on_primary : Colors.on_surface_variant
                                                    }

                                                    TapHandler { onTapped: submitPassword() }
                                                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Custom scrollbar
                    Rectangle {
                        anchors.right: networkFlickable.right
                        anchors.rightMargin: 3
                        y: networkFlickable.y + networkFlickable.visibleArea.yPosition * networkFlickable.height
                        width: 3
                        height: Math.max(20,
                            networkFlickable.visibleArea.heightRatio * networkFlickable.height)
                        radius: 1.5
                        color: Colors.outline_variant
                        opacity: networkFlickable.contentHeight > networkFlickable.height ? 0.5 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    // "Searching for networks..." message
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: networkFlickable.bottom
                        anchors.topMargin: 20
                        text: noNetworks ? "Searching for networks..." : ""
                        font.family: "XiaoLai"
                        font.pixelSize: 13
                        color: Colors.on_surface_variant
                        visible: noNetworks
                    }
                }

                // ── Bottom padding ──
                Item { width: parent.width; height: 12 }
            }
        }
    }
}
