import Quickshell.Wayland
import Quickshell
import QtQuick
import QtQml

import qs.Services

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

    ShaderEffect {
        id: shader
        property variant source1: currentImage
        property variant source2: nextImage
        property real iTime: root.progress
        property int rand: Math.random()*1000
        property vector2d resolution: Qt.vector2d(width, height)

        anchors.fill: parent
        fragmentShader: Qt.resolvedUrl("../assets/shaders/particle.frag.qsb")
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
        onFinished: currentImage.source = nextImage.source
    }

    Connections {
        target: BackgroundService
        function onChangeImage(file) {
            file = BackgroundService.randomImage()
            nextImage.source = file
            shader.rand = Math.random()*1000
            progress = 0
            anim.restart()
        }
    }
}
