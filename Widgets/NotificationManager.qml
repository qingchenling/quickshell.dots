import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Notifications

import qs.Components
import "notify"

PanelWindow {
    anchors.right: true
    anchors.top: true
    margins.top: 20
    margins.right: 30
    width: 400
    height: notificationColumn.height
    mask: Region { item: notificationColumn }
    color: "transparent"
    visible: true

    NotificationServer {
        id: notificationServer
        onNotification: (event) => {
            event.tracked = true
        }
    }

    Column {
        id: notificationColumn
        width: parent.width
        spacing: 12

        Repeater {
            model: notificationServer.trackedNotifications
            delegate: NotifyCard {
                width: notificationColumn.width
                height: 120

                icon: modelData.appIcon
                name: modelData.appName + " - " + modelData.summary
                content: modelData.body

                onClicked: {
                    if(modelData.actions.length)
                        modelData.actions[0].invoke()
                    closed = true
                }
            }
        }
    }
}
