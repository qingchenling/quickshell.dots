import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Notifications

import "components"

PanelWindow {
    ListModel { id: notificationModel }

    anchors.right: true
    anchors.top: true
    margins.top: 20
    margins.right: 30
    width: 400
    height: notificationColumn.height
    mask: Region { item: notificationColumn }
    color: "transparent"

    NotificationServer {
        id: notificationServer

        onNotification: function(notification) {
            notification.tracked = true
            notificationModel.append({
                notification: notification
            })
        }
    }

    Column {
        id: notificationColumn
        width: parent.width
        spacing: 12

        Repeater {
            model: notificationModel
            delegate: NotifyCard {
                width: notificationColumn.width
                height: 120

                icon: Quickshell.iconPath(notification.appIcon)
                name: notification.appName + " - " + notification.summary
                content: notification.body

                onClicked: notification.actions[0].invoke()
            }
        }
    }
}
