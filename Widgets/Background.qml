import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Effects
import Quickshell.Io
import Quickshell
import QtQuick
import QtQml

import qs.Services
import qs.Themes

PanelWindow {
    property real progress: 0

    id: root
    WlrLayershell.layer: WlrLayer.Background
    exclusionMode: ExclusionMode.Ignore
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    MultiEffect {
        id: blurShader
        anchors.fill: parent
        blurEnabled: true
        blur: Hyprland.focusedWorkspace.toplevels.values.length > 0 ? 0.8 : 0
        brightness: Hyprland.focusedWorkspace.toplevels.values.length > 0 ? -0.2 : 0
        blurMax: 64
        source: shader

        Behavior on blur {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuart
            }
        }
    }
        
    ShaderEffect {
        id: shader
        property variant source1: currentImage
        property variant source2: nextImage
        property real iTime: root.progress
        property int rand: Math.random()*1000
        property vector2d resolution: Qt.vector2d(width, height)

        anchors.fill: parent
        fragmentShader: Qt.resolvedUrl("../assets/shaders/particle.frag.qsb")
        visible: false
    }

    Image {
        id: currentImage
        anchors.fill: parent
        source: BackgroundService.randomImage()
        visible: false
    }

    Image {
        id: nextImage
        anchors.fill: parent
        source: currentImage.source
        visible: false
    }

    NumberAnimation {
        id: anim
        target: root
        property: "progress"
        from: 0
        to: 1
        duration: 1000
        onFinished: {
            currentImage.source = nextImage.source
        }
    }

    Connections {
        target: BackgroundService
        function onChangeImage(file) {
            if(file==="") file = BackgroundService.randomImage()

            nextImage.source = file
            shader.rand = Math.random()*1000

            matugenProc.exec({
                command: [
                "/usr/bin/matugen",
                "--prefer",
                "value",
                "image",
                file.toString().replace("file://", "")
            ] 
            })

            progress = 0
            anim.restart()
        }
    }
    Process {
        id: matugenProc
        onExited: Colors.file.reload()
    }
}
