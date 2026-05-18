import Quickshell
import QtQuick

Rectangle {
    height: parent.height
    width: 80
    radius: 20
    color: "#2D2D3D"

    SystemClock {
        id: clock
    }

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm")
        color: "#ffffff"
        font {
            bold: true
            family: "Xiaolai"
        }
    }
}
