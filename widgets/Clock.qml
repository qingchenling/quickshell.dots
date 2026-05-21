import Quickshell
import QtQuick

import "../components"
import "../"

MD3Card {
    height: parent.height
    width: 80

    SystemClock { id: clock }
    text: Qt.formatDateTime(clock.date, "hh : mm")
    innerText.font.bold: true
}
