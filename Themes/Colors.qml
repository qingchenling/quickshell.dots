pragma Singleton
import Quickshell.Io
import QtQuick

QtObject {
    property var data: null

    id: root

    property FileView file: FileView {
        id: file
        path: Qt.resolvedUrl("colors.json")
        onLoaded: root.data = JSON.parse(text())
    }

    function back(col) {
        return data["md3"][col]
    }
    function text(col) {
        return data["md3"]["on_"+col]
    }
}
