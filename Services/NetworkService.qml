pragma Singleton
import Quickshell.Networking
import QtQuick

QtObject {
    id: root

    // ═══════════════════════════════════════════════════════════
    // Network backend state — wraps Quickshell.Networking
    // ═══════════════════════════════════════════════════════════

    /// Primary WiFi device (null if no WiFi hardware)
    property var wifiDevice: null

    /// Whether WiFi is enabled via software
    property bool wifiEnabled: Networking.wifiEnabled

    /// Whether WiFi hardware is physically available / not blocked
    property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled

    /// Overall internet connectivity level
    property int connectivity: Networking.connectivity
    // NetworkConnectivity enum values: Unknown=0, None=1, Portal=2, Limited=3, Full=4

    /// Currently-connected network on the WiFi device (null if none)
    property var connectedNetwork: null

    /// Human-readable connectivity label
    readonly property string connectivityLabel: {
        switch (connectivity) {
            case 0: return "Unknown"
            case 1: return "No Network"
            case 2: return "Sign-in required"
            case 3: return "Limited"
            case 4: return "Connected"
        }
        return ""
    }

    /// True when the system has usable internet
    readonly property bool online: connectivity === NetworkConnectivity.Full
            || connectivity === NetworkConnectivity.Limited

    /// True while a connection attempt is in progress
    readonly property bool connecting: {
        if (!wifiDevice || !wifiDevice.networks) return false
        let nets = wifiDevice.networks.values
        for (let i = 0; i < nets.length; i++) {
            if (nets[i].state === ConnectionState.Connecting)
                return true
        }
        return false
    }

    signal networkStateChanged()

    // ═══════════════════════════════════════════════════════════
    // Initialisation
    // ═══════════════════════════════════════════════════════════

    Component.onCompleted: refreshDevices()

    // Retry device discovery periodically if no WiFi device was found at boot
    // (e.g. NetworkManager hasn't started yet or hardware is still initialising)
    property Timer deviceRetryTimer: Timer {
        interval: 5000
        repeat: true
        running: !root.wifiDevice
        onTriggered: refreshDevices()
    }

    function refreshDevices() {
        // Locate the first WifiDevice
        let devs = Networking.devices.values
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].type === DeviceType.Wifi) {
                root.wifiDevice = devs[i]
                root.scan()
                break
            }
        }
        refreshConnected()
        networkStateChanged()
    }

    function refreshConnected() {
        if (!wifiDevice || !wifiDevice.networks) {
            root.connectedNetwork = null
            return
        }
        let nets = wifiDevice.networks.values
        for (let i = 0; i < nets.length; i++) {
            if (nets[i].connected) {
                root.connectedNetwork = nets[i]
                return
            }
        }
        root.connectedNetwork = null
    }

    // ═══════════════════════════════════════════════════════════
    // Actions
    // ═══════════════════════════════════════════════════════════

    /// Toggle WiFi software kill-switch
    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled
        networkStateChanged()
    }

    /// Request an access-point scan
    function scan() {
        if (wifiDevice) {
            wifiDevice.scannerEnabled = true
        }
    }

    /// Connect to an open / known network
    function connectToNetwork(network) {
        if (!network) return
        network.connect()
        networkStateChanged()
    }

    /// Connect to a WPA-secured network with a passphrase
    function connectWithPassword(network, psk) {
        if (!network) return
        if (network.connectWithPsk) {
            network.connectWithPsk(psk)
        } else {
            network.connect()
        }
        networkStateChanged()
    }

    /// Disconnect from a network
    function disconnectFromNetwork(network) {
        if (!network) return
        network.disconnect()
        networkStateChanged()
    }

    /// Forget a known network
    function forgetNetwork(network) {
        if (!network) return
        network.forget()
        networkStateChanged()
    }

    // ═══════════════════════════════════════════════════════════
    // Helpers
    // ═══════════════════════════════════════════════════════════

    /// Quality percentage [0-100] from signal strength.
    /// Quickshell reports normalised 0.0–1.0 (double).
    function signalPercent(network) {
        if (!network || network.signalStrength === undefined) return 0
        let s = network.signalStrength
        // Normalised 0.0–1.0 (Quickshell's native format)
        if (s >= 0 && s <= 1.0)
            return Math.round(s * 100)
        // Fallback: already in percent (0-100)
        return Math.min(100, Math.max(0, Math.round(s)))
    }

    /// Human-readable security label
    function securityLabel(network) {
        if (!network || network.security === undefined)
            return ""
        switch (network.security) {
            case WifiSecurityType.Wpa3SuiteB192:
            case WifiSecurityType.Sae:
                return "WPA3"
            case WifiSecurityType.Wpa2Eap:
            case WifiSecurityType.Wpa2Psk:
                return "WPA2"
            case WifiSecurityType.WpaEap:
            case WifiSecurityType.WpaPsk:
                return "WPA"
            case WifiSecurityType.StaticWep:
            case WifiSecurityType.DynamicWep:
                return "WEP"
            case WifiSecurityType.Owe:
                return "Enhanced Open"
            case WifiSecurityType.Open:
                return ""
            default:
                return ""
        }
    }

    /// True if the network requires a password
    function isSecure(network) {
        if (!network || network.security === undefined)
            return false
        return network.security !== WifiSecurityType.Open
            && network.security !== WifiSecurityType.Owe
            && network.security !== WifiSecurityType.Unknown
    }

    // ═══════════════════════════════════════════════════════════
    // Reactive bridges — re-evaluate whenever backend state changes
    // ═══════════════════════════════════════════════════════════

    property Connections con: Connections {
        target: Networking
        function onWifiEnabledChanged() {
            root.wifiEnabled = Networking.wifiEnabled
            root.refreshConnected()
            root.networkStateChanged()
        }
        function onWifiHardwareEnabledChanged() {
            root.wifiHardwareEnabled = Networking.wifiHardwareEnabled
            root.refreshConnected()
            root.networkStateChanged()
        }
        function onConnectivityChanged() {
            root.connectivity = Networking.connectivity
            root.refreshConnected()
            root.networkStateChanged()
        }
    }
}
