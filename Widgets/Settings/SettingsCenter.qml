import Quickshell
import Quickshell.Io
import QtQuick

import qs.Components
import qs.Themes

Item {
    id: root
    height: parent.height
    width: 0

    // ═══════════════════════════════════════════════════════════
    // Tab model — add entries here + a page file to extend
    // ═══════════════════════════════════════════════════════════
    property ListModel tabs: ListModel {
        ListElement { name: "Wi-Fi";      icon: "wifi";     page: "WifiPage.qml" }
        ListElement { name: "Bluetooth";  icon: "bluetooth"; page: "BluetoothPage.qml" }
        ListElement { name: "Wallpaper";  icon: "wallpaper"; page: "WallpaperPage.qml" }
    }

    property int currentIndex: 0
    property bool shown: false

    function toggle() {
        if (shown) {
            shown = false
            closeAnim.start()
        } else {
            shown = true
            openAnim.start()
        }
    }

    function switchPage(index) {
        if (index === currentIndex) return
        exitPageAnim.start()
        pageSwitchTarget = index
    }

    property int pageSwitchTarget: 0

    // ═══════════════════════════════════════════════════════════
    // IPC — allows external toggle via quickshell IPC
    // ═══════════════════════════════════════════════════════════
    IpcHandler {
        target: "SettingsCenter"
        function toggle() { root.toggle() }
    }

    // ── Open / close animations ──
    SequentialAnimation {
        id: openAnim
        ScriptAction { script: { settingsPopup.visible = true } }
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
        ScriptAction { script: { settingsPopup.visible = false } }
    }

    // ── Page transition animations ──
    SequentialAnimation {
        id: exitPageAnim
        ParallelAnimation {
            NumberAnimation { target: pageContainer; property: "pageOpacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { target: pageContainer; property: "pageSlideX"; from: 0; to: -30; duration: 180; easing.type: Easing.InCubic }
        }
        ScriptAction { script: { currentIndex = pageSwitchTarget } }
        ParallelAnimation {
            NumberAnimation { target: pageContainer; property: "pageOpacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { target: pageContainer; property: "pageSlideX"; from: 30; to: 0; duration: 220; easing.type: Easing.OutCubic }
        }
    }

    // ═══════════════════════════════════════════════════════════
    // Floating window — positioned by the compositor, same screen as panel
    // ═══════════════════════════════════════════════════════════
    FloatingWindow {
        id: settingsPopup
        screen: panel.screen
        visible: false
        color: "transparent"
        implicitWidth: 620
        implicitHeight: 440
        mask: Region { item: popupCard }

        Rectangle {
            id: popupCard
            anchors.fill: parent
            radius: 28
            color: Colors.surface_container_high
            opacity: 1

            property real slideY: 0
            transform: Translate { y: popupCard.slideY }

            // Border
            Rectangle {
                anchors.fill: parent; anchors.margins: -2
                radius: parent.radius + 2
                color: "transparent"
                border.color: Colors.outline_variant; border.width: 0.5
                z: -1
            }

            // ══════════════════════════════════════════════════
            // Header (no close button — toggled via start menu)
            // ══════════════════════════════════════════════════
            Rectangle {
                id: headerBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 52
                color: "transparent"

                Text {
                    anchors.left: parent.left; anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Settings"
                    font.family: "XiaoLai"; font.pixelSize: 20; font.bold: true
                    color: Colors.on_surface
                }
            }

            // Divider below header
            Rectangle {
                anchors.top: headerBar.bottom
                anchors.left: parent.left; anchors.leftMargin: 16
                anchors.right: parent.right; anchors.rightMargin: 16
                height: 1
                color: Colors.outline_variant; opacity: 0.4
            }

            // ══════════════════════════════════════════════════
            // Body: tab bar + page area
            // ══════════════════════════════════════════════════
            Row {
                anchors.top: headerBar.bottom; anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom; anchors.bottomMargin: 8

                // ── Left: Tab bar ──
                Rectangle {
                    id: tabBar
                    width: 76
                    height: parent.height
                    color: "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Repeater {
                            model: root.tabs

                            delegate: Rectangle {
                                id: tabItem
                                width: 68; height: 56
                                radius: 16
                                color: {
                                    if (tabHover.hovered && index !== root.currentIndex)
                                        return Colors.surface_container_highest
                                    if (index === root.currentIndex)
                                        return Colors.secondary_container
                                    return "transparent"
                                }

                                // Selected indicator
                                Rectangle {
                                    anchors.left: parent.left; anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 3; height: 24; radius: 1.5
                                    color: index === root.currentIndex ? Colors.primary : "transparent"
                                    opacity: index === root.currentIndex ? 1 : 0

                                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    IconSvg {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 20; height: 20
                                        path: Qt.resolvedUrl("../../assets/" + model.icon + ".svg")
                                        color: index === root.currentIndex ? Colors.on_secondary_container : Colors.on_surface_variant
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: model.name
                                        font.family: "XiaoLai"; font.pixelSize: 10
                                        color: index === root.currentIndex ? Colors.on_secondary_container : Colors.on_surface_variant
                                        font.bold: index === root.currentIndex
                                    }
                                }

                                HoverHandler { id: tabHover }
                                TapHandler {
                                    id: tabTap
                                    onTapped: root.switchPage(index)
                                }

                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                                // Press scale
                                scale: tabTap.pressed ? 0.94 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                            }
                        }
                    }
                }

                // Vertical divider
                Rectangle {
                    width: 1
                    height: parent.height - 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.outline_variant; opacity: 0.3
                }

                // ── Right: Page area ──
                Rectangle {
                    id: pageArea
                    width: parent.width - tabBar.width - 1
                    height: parent.height
                    color: "transparent"
                    clip: true

                    // Page container with transition properties
                    Item {
                        id: pageContainer
                        anchors.fill: parent
                        anchors.margins: 12

                        property real pageOpacity: 1
                        property real pageSlideX: 0

                        opacity: pageOpacity
                        transform: Translate { x: pageContainer.pageSlideX }

                        Loader {
                            id: pageLoader
                            anchors.fill: parent
                            source: root.tabs.get(root.currentIndex) ? Qt.resolvedUrl("pages/" + root.tabs.get(root.currentIndex).page) : ""
                            asynchronous: false
                        }
                    }
                }
            }
        }
    }
}
