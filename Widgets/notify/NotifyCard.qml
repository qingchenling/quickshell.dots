import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

import qs.Themes

// ═══════════════════════════════════════════════════════════
// MD3 notification card — slide-in, auto-dismiss, fade-out.
//
// Properties:
//   notification  — Notification from the server
// The card self-manages its lifecycle: once the dismiss
// animation completes, it sets notification.tracked = false
// which removes it from the model.
// ═══════════════════════════════════════════════════════════

Item {
    id: root

    property var notification: null

    // ── height tracking for the Column / Layout ──
    implicitHeight: card.height  // animate to 0
    clip: true

    // ═════════════════════════════════════════
    // State
    // ═════════════════════════════════════════
    property bool closing: false
    readonly property int _defaultTimeout: 5000

    // ── resolved icon source ──
    readonly property string _iconSource: notification
        ? notification.appIcon || ""
        : ""

    // ═════════════════════════════════════════
    // Auto-dismiss timer (5 s)
    // ═════════════════════════════════════════
    Timer {
        id: autoDismissTimer
        interval: notification && notification.expireTimeout > 0
            ? notification.expireTimeout
            : root._defaultTimeout
        running: !root.closing
        repeat: false
        onTriggered: root._startDismiss()
    }

    // ═════════════════════════════════════════
    // Slide-in animation (x: width → 0)
    // ═════════════════════════════════════════
    NumberAnimation {
        id: slideInAnimation
        target: card
        property: "x"
        from: root.width
        to: 0
        duration: 350
        easing.type: Easing.OutCubic
        running: !root.closing  // auto-start when created
    }

    // ═════════════════════════════════════════
    // Dismiss animation — height collapse + fade
    // ═════════════════════════════════════════
    SequentialAnimation {
        id: dismissAnimation
        running: root.closing

        ParallelAnimation {
            NumberAnimation {
                target: card
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 200
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: card
                property: "scale"
                from: 1.0
                to: 0.7
                duration: 250
                easing.type: Easing.InCubic
            }
        }
        // Collapse height — implicitHeight animates toward 0
        NumberAnimation {
            target: root
            property: "implicitHeight"
            from: card.height
            to: 0
            duration: 300
            easing.type: Easing.InOutCubic
        }

        ScriptAction {
            script: {
                if (root.notification) {
                    root.notification.dismiss()
                    root.notification.tracked = false
                }
            }
        }
    }

    // ═════════════════════════════════════════
    // Card surface
    // ═════════════════════════════════════════
    Rectangle {
        id: card
        width: parent.width
        height: contentColumn.implicitHeight + 32
        radius: 16

        // ── MD3 surface colours ──
        color: Colors.surface_container_high
        border.width: 1
        border.color: Colors.outline_variant

        // ── Start off to the right for slide-in ──
        x: root.width
        scale: 1.0
        opacity: 1.0

        // Close button (top-right) — plain text ✕
        MouseArea {
            id: closeButton
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            width: 24
            height: 24
            cursorShape: Qt.PointingHandCursor

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: closeBtnHover.hovered
                    ? Colors.on_surface
                    : Colors.on_surface_variant
                font.pixelSize: 14
            }
            HoverHandler { id: closeBtnHover }
            onClicked: root._startDismiss()
        }

        // Content
        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: closeButton.left
            anchors.top: parent.top
            anchors.margins: 16
            anchors.rightMargin: 8
            spacing: 8

            // ── Header: icon + app name + summary ──
            RowLayout {
                id: headerRow
                spacing: 12
                Layout.fillWidth: true

                // App icon (32 dp)
                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: root._iconSource !== ""
                        ? Colors.surface_container_low
                        : "transparent"
                    Layout.alignment: Qt.AlignTop

                    IconImage {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: root._iconSource
                        visible: root._iconSource !== ""
                    }
                }

                // App name + summary
                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: root.notification
                            ? root.notification.appName
                            : ""
                        color: Colors.on_surface_variant
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.notification
                            ? root.notification.summary
                            : ""
                        color: Colors.on_surface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        visible: text !== ""
                    }
                }
            }

            // ── Body text ──
            Text {
                Layout.fillWidth: true
                text: root.notification ? root.notification.body : ""
                color: Colors.on_surface_variant
                font.pixelSize: 13
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                visible: text !== ""
            }

            // ── Image attachment ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                visible: root.notification
                    && root.notification.image
                    && root.notification.image !== ""
                radius: 8
                color: Colors.surface_container
                clip: true

                Image {
                    anchors.fill: parent
                    source: visible ? root.notification.image : ""
                    fillMode: Image.PreserveAspectCrop
                }
            }

            // ── Action buttons ──
            RowLayout {
                spacing: 8
                Layout.fillWidth: true
                visible: root.notification
                    && root.notification.actions
                    && root.notification.actions.length > 0

                Repeater {
                    model: root.notification
                        ? root.notification.actions
                        : []
                    delegate: Rectangle {
                        required property var modelData

                        implicitWidth: actionText.implicitWidth + 24
                        implicitHeight: 32
                        radius: 8
                        color: actionMouse.pressed
                            ? Colors.primary_container
                            : Colors.surface_container_low

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: modelData.text
                            color: Colors.primary
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                modelData.invoke()
                                root._startDismiss()
                            }
                        }
                    }
                }
            }

            // ── Inline reply ──
            RowLayout {
                spacing: 8
                Layout.fillWidth: true
                visible: root.notification
                    && root.notification.hasInlineReply

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 12
                    color: Colors.surface_container_low

                    TextInput {
                        id: replyField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colors.on_surface
                        font.pixelSize: 13
                        activeFocusOnPress: true
                    }
                }

                Rectangle {
                    implicitWidth: sendText.implicitWidth + 16
                    implicitHeight: 32
                    radius: 8
                    color: sendMouse.pressed
                        ? Colors.primary_container
                        : Colors.primary

                    Text {
                        id: sendText
                        anchors.centerIn: parent
                        text: "Send"
                        color: sendMouse.pressed
                            ? Colors.on_primary_container
                            : Colors.on_primary
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: sendMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (replyField.text.trim() !== "") {
                                root.notification.sendInlineReply(
                                    replyField.text.trim())
                                root._startDismiss()
                            }
                        }
                    }
                }
            }
        }

        // ═════════════════════════════════════════
        // Tap → invoke first action or dismiss
        // ═════════════════════════════════════════
        MouseArea {
            anchors.fill: parent
            z: -1  // below buttons (close, actions, reply)
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.notification
                    && root.notification.actions
                    && root.notification.actions.length > 0) {
                    root.notification.actions[0].invoke()
                }
                root._startDismiss()
            }
        }
    }

    // ═════════════════════════════════════════
    // Helpers
    // ═════════════════════════════════════════
    function _startDismiss() {
        if (root.closing) return
        root.closing = true
        autoDismissTimer.stop()
    }
}
