import Quickshell.Services.Pipewire
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick

import qs.Services
import qs.Components
import qs.Themes
import "start"

Item {
    height: parent.height
    width: startMenu.width

    PopupWindow {
        property bool is_show: false

        id: startMenu
        anchor.window: panel
        visible: true
        color: "transparent"
        
        HoverHandler { id: startHover }
        implicitHeight: is_show ? 350 : panel.height
        implicitWidth: is_show ? 300 : (startHover.hovered ? startRow.width+10 : panel.height)

        Rectangle {
            anchors.fill: parent
            radius: 30
            color: Colors.surface

            Row {
                property int len: startMenu.is_show ? 40 : 32

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: startMenu.is_show ? 4 : 2
                anchors.leftMargin: startMenu.is_show ? 20 : 2
                id: startRow
                spacing: 5

                // Animate top/left margins on the container only —
                // per-item size Behaviors removed to avoid layout thrash.
                Behavior on anchors.topMargin  { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                Behavior on anchors.leftMargin { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: startRow.len; width: startRow.len
                    radius: height/2; color: "transparent"

                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on width  { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    Text {
                        anchors.centerIn: parent
                        color: Colors.on_surface; text: "01"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { startMenu.is_show = !startMenu.is_show }
                    }
                }

                Repeater {
                    model: [
                        {svg: "poweroff.svg", command: ["poweroff"]},
                        {svg: "reboot.svg", command: ["reboot"]},
                        {svg: "logout.svg", command: ["uwsm", "stop"]}
                    ]
                    delegate: Button {
                        Process { id: startItemProc; command: modelData.command }

                        anchors.top: startRow.top
                        anchors.topMargin: 2
                        height: startRow.len-6; width: startRow.len-6
                        radius: height/2
                        icon: Qt.resolvedUrl("../../assets/"+modelData.svg)
                        bgColor: Colors.surface_variant
                        fgColor: Colors.on_surface_variant
                        activeBgColor: Colors.primary
                        activeFgColor: Colors.on_primary
                        active: hovered

                        // Color-only transition — size changes are instant
                        // to avoid multiple simultaneous layout animations.
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic } }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: { startItemProc.running = true }
                        }
                    }
                }

                BatteryIcon {
                    width: startMenu.is_show ? 90 : 0
                }
            }

            Rectangle {
                id: optionCard
                anchors.top: startRow.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width-20
                height: 150
                radius: 20
                color: Colors.surface_variant
                
                Grid {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.topMargin: 20
                    columns: 3
                    spacing: 15
                    
                    Button {
                        id: startButtom_idleInhibitor
                        width: (optionCard.width-4*15)/3
                        height: (optionCard.height-15-40)/2

                        bgColor: Colors.secondary_container
                        fgColor: Colors.on_secondary_container
                        activeBgColor: Colors.primary
                        activeFgColor: Colors.on_primary
                        activeIcon: Qt.resolvedUrl("../../assets/idle_inhibitor_on.svg")
                        icon: Qt.resolvedUrl("../../assets/idle_inhibitor_off.svg")
                        onClicked: active = !active
                    }
                    Button {
                        id: startButtom_notifications
                        width: (optionCard.width-4*15)/3
                        height: (optionCard.height-15-40)/2

                        bgColor: Colors.secondary_container
                        fgColor: Colors.on_secondary_container
                        activeBgColor: Colors.primary
                        activeFgColor: Colors.on_primary
                        activeIcon: Qt.resolvedUrl("../../assets/notifications_off.svg")
                        icon: Qt.resolvedUrl("../../assets/notifications_on.svg")
                        // Bound to DnD service — active = Do Not Disturb ON
                        active: NotificationService.dnd
                        onClicked: NotificationService.dnd = !NotificationService.dnd
                    }
                    Button {
                        width: (optionCard.width-4*15)/3
                        height: (optionCard.height-15-40)/2
                        
                        bgColor: Colors.secondary_container
                        fgColor: Colors.on_secondary_container
                        activeBgColor: Colors.primary
                        activeFgColor: Colors.on_primary
                        onClicked: BackgroundService.changeImage("")
                    }
                }
            }

            Column {
                anchors.top: optionCard.bottom
                anchors.topMargin: 40
                spacing: 25
                Slide {
                    anchors.horizontalCenter: startMenu.horizontalCenter
                    width: startMenu.width-20
                    height: 10
                    icon: "../assets/headphone.svg"

                    value: Math.round(Pipewire.defaultAudioSink.audio.volume*100)
                    onDeltaChanged: {
                        let v = Pipewire.defaultAudioSink.audio.volume + delta/100
                        Pipewire.defaultAudioSink.audio.volume = Math.max(minn/100, Math.min(v, maxn/100))
                        delta = 0
                    }

                    PwObjectTracker {
                        objects: [ Pipewire.defaultAudioSink ]
                    }
                }
                Slide {
                    anchors.horizontalCenter: startMenu.horizontalCenter
                    width: startMenu.width-20
                    height: 10
                    icon: "../assets/brightness.svg"

                    onDeltaChanged: {
                        let v = value + delta
                        value = Math.max(minn, Math.min(v, maxn))
                        delta = 0

                        setBrightness.command = ["brightnessctl", "set", value+"%"]
                        setBrightness.running = true
                    }

                    Process { id: setBrightness }
                }
            }

            // ── Settings gear button (bottom-right, visible when expanded) ──
            Rectangle {
                id: settingsButton
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                width: 36; height: 36; radius: 18
                color: settingsHover.hovered ? Colors.primary_container : Colors.secondary_container
                opacity: startMenu.is_show ? 1 : 0

                IconSvg {
                    anchors.centerIn: parent
                    width: 20; height: 20
                    path: Qt.resolvedUrl("../../assets/settings.svg")
                    color: settingsHover.hovered ? Colors.on_primary_container : Colors.on_secondary_container
                }

                HoverHandler { id: settingsHover }
                TapHandler {
                    id: settingsTap
                    onTapped: panel.toggleSettings()
                }

                scale: settingsTap.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}
