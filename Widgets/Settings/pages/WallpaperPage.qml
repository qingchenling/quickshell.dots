import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Widgets
import QtQuick

import qs.Services
import qs.Components
import qs.Themes

// ═══════════════════════════════════════════════════════════
// Wallpaper page — pick wallpaper from ~/Pictures/Wallpapers,
// choose shader transition animation, set auto-switch timer
// ═══════════════════════════════════════════════════════════

Item {
    id: root

    property string selectedWallpaper: SettingsService.wallpaper || ""  // "" = random
    property string selectedShader: SettingsService.shader || "random"

    // Models from SettingsService
    readonly property var shaderOptions: SettingsService.shaderList || []
    readonly property var intervalOptions: SettingsService.intervalOptions || []

    // Wallpaper folder model
    property FolderListModel wallpaperModel: FolderListModel {
        folder: "file:///home/lingchen/Pictures/Wallpapers/"
        nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.webp"]
        showDirs: false
    }

    function selectWallpaper(fileUrl) {
        let path = fileUrl ? fileUrl.toString().replace("file://", "") : ""
        selectedWallpaper = path
        SettingsService.wallpaper = path
        if (path === "") {
            BackgroundService.changeImage("")
        } else {
            BackgroundService.changeImage("file://" + path)
        }
    }

    function selectShader(value) {
        selectedShader = value
        SettingsService.shader = value
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

            // ── Title ──
            PageHeader { title: "Wallpaper" }

            // ── Current wallpaper preview ──
            Rectangle {
                width: parent.width - 8; height: 100
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 18; color: Colors.surface_container
                clip: true

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 16

                    // Preview image
                    ClippingRectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 76; height: 76; radius: 14
                        color: Colors.surface_container_low

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: selectedWallpaper === "" ? BackgroundService.randomImage()
                                                             : "file://" + selectedWallpaper
                            asynchronous: true
                        }

                        // Selection ring
                        Rectangle {
                            anchors.fill: parent; radius: 14
                            color: "transparent"
                            border.color: Colors.primary
                            border.width: selectedWallpaper !== "" ? 2 : 0
                            Behavior on border.width { NumberAnimation { duration: 200 } }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 6
                        Text {
                            text: selectedWallpaper === "" ? "🎲 Random wallpaper"
                                                           : selectedWallpaper.split("/").pop()
                            font.family: "XiaoLai"; font.pixelSize: 15; font.bold: true
                            color: Colors.on_surface
                            elide: Text.ElideRight; width: 260; maximumLineCount: 1
                        }
                        Text {
                            text: selectedWallpaper === "" ? "A random image will be chosen each time"
                                                           : "Currently selected"
                            font.family: "XiaoLai"; font.pixelSize: 11
                            color: Colors.on_surface_variant
                        }

                        // Random toggle + interval selector
                        Row {
                            spacing: 8

                            // Random toggle pill
                            Rectangle {
                                width: randomBtnText.width + 20; height: 26; radius: 13
                                color: selectedWallpaper === "" ? Colors.primary : Colors.surface_container_highest

                                Text {
                                    id: randomBtnText
                                    anchors.centerIn: parent
                                    text: "Random"
                                    font.family: "XiaoLai"; font.pixelSize: 11
                                    color: selectedWallpaper === "" ? Colors.on_primary
                                                                    : Colors.on_surface_variant
                                }

                                TapHandler { onTapped: root.selectWallpaper("") }
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            }

                            // Interval selector — only visible when Random is active
                            Item {
                                visible: selectedWallpaper === ""
                                width: intervalRow.width; height: 26

                                Row {
                                    id: intervalRow
                                    spacing: 4
                                    Repeater {
                                        model: root.intervalOptions
                                        delegate: Rectangle {
                                            readonly property var opt: modelData
                                            width: intervalLabel.width + 14; height: 26; radius: 13
                                            color: SettingsService.wallpaperInterval === opt.value
                                                   ? Colors.primary_container : Colors.surface_container_highest

                                            Text {
                                                id: intervalLabel
                                                anchors.centerIn: parent
                                                text: opt.label
                                                font.family: "XiaoLai"; font.pixelSize: 10
                                                color: SettingsService.wallpaperInterval === opt.value
                                                       ? Colors.on_primary_container : Colors.on_surface_variant
                                            }

                                            TapHandler {
                                                onTapped: { SettingsService.wallpaperInterval = opt.value }
                                            }
                                            Behavior on color {
                                                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Wallpaper picker ──
            SectionHeader { text: "Wallpapers · " + wallpaperModel.count }

            Flow {
                width: parent.width - 8
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                // Random option tile
                Rectangle {
                    width: (parent.width - 16) / 3
                    height: width * 0.7
                    radius: 14
                    color: selectedWallpaper === "" ? Colors.primary_container : Colors.surface_container
                    clip: true

                    Column {
                        anchors.centerIn: parent; spacing: 8
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "🎲"; font.pixelSize: 28 }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Random"
                            font.family: "XiaoLai"; font.pixelSize: 12; font.bold: true
                            color: selectedWallpaper === "" ? Colors.on_primary_container
                                                            : Colors.on_surface_variant
                        }
                    }

                    Rectangle {
                        anchors.fill: parent; radius: parent.radius
                        color: "transparent"
                        border.color: selectedWallpaper === "" ? Colors.primary : "transparent"
                        border.width: selectedWallpaper === "" ? 2 : 0
                        Behavior on border.width { NumberAnimation { duration: 200 } }
                    }

                    TapHandler { onTapped: root.selectWallpaper("") }
                }

                Repeater {
                    model: wallpaperModel

                    delegate: ClippingRectangle {
                        width: (parent.width - 16) / 3
                        height: width * 0.7
                        radius: 14
                        color: Colors.surface_container

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: model.fileUrl
                            asynchronous: true

                            Rectangle {
                                anchors.fill: parent; color: "#000000"
                                opacity: selectedWallpaper === String(model.fileUrl).replace("file://", "") ? 0 : 0.25
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                            }
                        }

                        // File name pill
                        Rectangle {
                            anchors.bottom: parent.bottom; anchors.bottomMargin: 6
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 20; width: fileNameText.width + 12; radius: 10
                            color: Qt.rgba(0, 0, 0, 0.55)

                            Text {
                                id: fileNameText
                                anchors.centerIn: parent
                                text: model.fileName.length > 14 ? model.fileName.substring(0, 12) + "..."
                                                                 : model.fileName
                                font.family: "XiaoLai"; font.pixelSize: 9
                                color: "#ffffff"
                            }
                        }

                        // Selected ring
                        Rectangle {
                            anchors.fill: parent; radius: 14
                            color: "transparent"; border.color: Colors.primary
                            border.width: selectedWallpaper === String(model.fileUrl).replace("file://", "") ? 2 : 0
                            Behavior on border.width { NumberAnimation { duration: 200 } }
                        }

                        TapHandler { onTapped: root.selectWallpaper(model.fileUrl) }

                        HoverHandler {
                            onHoveredChanged: {
                                if (!(selectedWallpaper === String(model.fileUrl).replace("file://", "")))
                                    parent.opacity = hovered ? 0.85 : 1.0
                            }
                        }
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        scale: tapPress.pressed ? 0.95 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        TapHandler { id: tapPress }
                    }
                }
            }

            // ── Spacing ──
            Item { width: parent.width; height: 16 }

            // ── Shader animation selector ──
            SectionHeader { text: "Transition animation" }

            Flow {
                width: parent.width - 8
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Repeater {
                    model: root.shaderOptions

                    delegate: Rectangle {
                        width: (parent.width - 16) / 2
                        height: 44
                        radius: 14
                        color: selectedShader === modelData.value
                               ? Colors.primary_container : Colors.surface_container

                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter; spacing: 10

                            // Radio dot
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 18; height: 18; radius: 9
                                color: "transparent"
                                border.color: selectedShader === modelData.value
                                              ? Colors.primary : Colors.outline_variant
                                border.width: 2

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 9; height: 9; radius: 4.5
                                    color: Colors.primary
                                    opacity: selectedShader === modelData.value ? 1 : 0
                                    scale: selectedShader === modelData.value ? 1 : 0
                                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }

                                Behavior on border.color { ColorAnimation { duration: 200 } }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                font.family: "XiaoLai"; font.pixelSize: 13
                                color: selectedShader === modelData.value
                                       ? Colors.on_primary_container : Colors.on_surface_variant
                                font.bold: selectedShader === modelData.value
                            }
                        }

                        TapHandler { onTapped: root.selectShader(modelData.value) }

                        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }

                        scale: shaderPress.pressed ? 0.96 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        TapHandler { id: shaderPress }
                    }
                }
            }

            // ── Spacing ──
            Item { width: parent.width; height: 12 }

            // Bottom spacing
            Item { width: parent.width; height: 24 }
        }
    }
}
