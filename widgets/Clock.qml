import Quickshell
import QtQuick

import "../components"
import "../"

MD3Card {
    height: parent.height
    width: 80

    SystemClock { id: clock }

    MD3CardText {
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm")
        font.bold: true
    }
}
