import Quickshell.Widgets
import Quickshell.Io
import QtQuick

IconImage {
    property color color: "#ffffff"
    property string path: ""

    id: root

    FileView {
        id: file
        path: root.path
        onLoaded: root.update()
        onFileChanged: root.update()
    }

    onColorChanged: update()

    function update() {
        let s = file.text()
        s = s.replace(/fill="[^"]*"/g, `fill="${color}"`)
        s = s.replace(/stroke="[^"]*"/g, `stroke="${color}"`)
        root.source = "data:image/svg+xml;utf8," + encodeURIComponent(s)
    }
}
