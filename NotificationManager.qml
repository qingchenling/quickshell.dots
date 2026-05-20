import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    anchors.top: true
    anchors.right: true
    implicitWidth: 320
    color: "transparent"
    margins.top: 20
    margins.right: 20

    NotificationServer {
        id: notificationServer

        onNotification: function(notification) {
            notification.tracked = false
            notificationModel.append({
                notification: notification
            })
        }
    }

    ListModel { id: notificationModel }

    Column {
        id: notificationColumn
        width: parent.width
        spacing: 12

        Repeater {
            model: notificationModel

            delegate: Rectangle {
                width: notificationColumn.width
                height: 100
                radius: 18

                Row {
                    anchors.fill: parent
                    Text {
                        text: notification.appName
                    }
                    Text {
                        text: notification.summary
                    }
                    Text {
                        text: notification.body
                    }
                }
            }
        }
    }
}
