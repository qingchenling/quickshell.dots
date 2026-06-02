import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Themes
import "../../assets/js/pinyin-match.js" as PinyinMatch

// ═══════════════════════════════════════════════════════════
// LauncherModule — app search + list inside the pill.
//
// Receives keyboard focus from the parent PanelWindow.
// Uses DesktopEntries + pinyin filtering.
//
// Properties:
//   searchInput  — alias to the TextInput for focus
//   onAppLaunched() — called when user picks an app
// ═══════════════════════════════════════════════════════════

Item {
    id: root

    property alias searchInput: searchField.inputField
    signal appLaunched()

    // ── Keyboard navigation ──
    // _focusIndex tracks position in the FILTERED visible list, NOT the full model.
    // _delegates indexes into the full model — always match by _focusedApp, never by index.
    property int _focusIndex: -1
    property var _focusedApp: null

    function _visibleApps() {
        var t = searchField.inputField.text.toLowerCase()
        var all = DesktopEntries.applications
        var result = []
        for (var i = 0; i < all.length; i++) {
            var app = all[i]
            if (t === ""
                || app.name.toLowerCase().includes(t)
                || PinyinMatch.PinyinMatch.match(app.name, t))
                result.push(app)
        }
        return result
    }

    function _moveFocus(delta) {
        var vis = _visibleApps()
        if (vis.length === 0) {
            _focusIndex = -1
            _focusedApp = null
            _ulVisible = false
            return
        }
        var next = _focusIndex < 0 ? 0 : _focusIndex + delta
        // Wrap around
        if (next < 0) next = vis.length - 1
        if (next >= vis.length) next = 0
        _focusIndex = next
        _focusedApp = vis[_focusIndex]
        _ulVisible = true
        _ulHideTimer.stop()   // keyboard takes priority over mouse-leave
        _updateFocusUnderline()
    }

    function _updateFocusUnderline() {
        if (!_focusedApp) return
        for (var i = 0; i < _delegates.length; i++) {
            var dg = _delegates[i]
            if (dg && dg._appData === _focusedApp) {
                _ulY = dg.mapToItem(root, 0, 0).y + dg.height
                return
            }
        }
    }

    function _launchFocused() {
        if (_focusedApp) { _focusedApp.execute(); appLaunched() }
    }

    // ── Keyboard navigation (top-level Shortcuts for window-wide capture) ──
    Shortcut { sequence: "Up";    onActivated: _moveFocus(-1) }
    Shortcut { sequence: "Down";  onActivated: _moveFocus(1) }

    // ── Search bar ──
    Rectangle {
        id: searchBar
        anchors.top: parent.top; anchors.topMargin: 8
        anchors.left: parent.left; anchors.leftMargin: 16
        anchors.right: parent.right; anchors.rightMargin: 16
        height: 44
        color: "transparent"

        TextField {
            id: searchField
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 36
            bgColor: Colors.surface_variant
            fgColor: Colors.on_surface_variant
            inputField.onTextChanged: {
                var vis = _visibleApps()
                if (_focusIndex >= 0 && _focusedApp && vis.indexOf(_focusedApp) >= 0)
                    _focusIndex = vis.indexOf(_focusedApp)
                else
                    _focusIndex = vis.length > 0 ? 0 : -1
                _focusedApp = _focusIndex >= 0 ? vis[_focusIndex] : null
                if (_focusedApp) {
                    _ulVisible = true
                    _ulHideTimer.stop()
                    _updateFocusUnderline()
                }
            }
            // Numpad Enter + main Return — Shortcut won't fire while
            // TextInput has focus because it consumes both keys.
            inputField.Keys.onReturnPressed: _launchFocused()
            inputField.Keys.onEnterPressed: _launchFocused()
        }
    }

    // ── Hover underline ──
    property real _ulY: searchBar.y + searchBar.height + 2
    property bool _ulVisible: false
    // Collect delegates so timer can re-check hover state
    property var _delegates: []
    Timer {
        id: _ulHideTimer; interval: 50
        onTriggered: {
            for (var i = 0; i < root._delegates.length; i++) {
                if (root._delegates[i] && root._delegates[i].hovered) return
            }
            // Don't hide if keyboard focus is active (arrow-key navigation)
            if (root._focusedApp !== null) return
            root._ulVisible = false
        }
    }
    Rectangle {
        id: underline
        y: root._ulY
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 40
        height: 3; radius: 3
        opacity: root._ulVisible ? 1 : 0
        color: Colors.outline
        Behavior on y { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    // ── App list ──
    ListView {
        id: appList
        anchors.top: parent.top
        anchors.topMargin: searchBar.height + 14
        anchors.left: parent.left; anchors.leftMargin: 8
        anchors.right: parent.right; anchors.rightMargin: 8
        anchors.bottom: parent.bottom; anchors.bottomMargin: 8
        spacing: 0; clip: true
        model: DesktopEntries.applications
        delegate: appDelegate
    }

    // ── Delegate ──
    Component {
        id: appDelegate
        Item {
            id: dg
            property alias hovered: hover.hovered
            readonly property var _appData: modelData
            readonly property string _t: searchField.inputField.text.toLowerCase()
            readonly property bool _m: _t === ""
                || modelData.name.toLowerCase().includes(_t)
                || PinyinMatch.PinyinMatch.match(modelData.name, _t)

            height: _m ? 42 : 0; width: appList.width
            opacity: _m ? 1.0 : 0.0
            clip: true
            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.fill: parent; anchors.topMargin: 1; anchors.bottomMargin: 1
                radius: 10
                color: tap.pressed ? Colors.surface_container_highest
                    : (hover.hovered || root._focusedApp === modelData)
                        ? Colors.surface_container_high : "transparent"

                Row {
                    anchors.left: parent.left; anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    IconImage {
                        width: 28; height: 28
                        anchors.verticalCenter: parent.verticalCenter
                        source: Quickshell.iconPath(modelData.icon)
                    }
                    Text {
                        text: modelData.name
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: "XiaoLai"; font.pixelSize: 13
                        color: Colors.on_surface; elide: Text.ElideRight
                        width: appList.width - 66; maximumLineCount: 1
                    }
                }
            }

            HoverHandler {
                id: hover
                onHoveredChanged: {
                    if (hovered) {
                        _ulHideTimer.stop()
                        root._ulVisible = true
                        root._ulY = mapToItem(root, 0, 0).y + dg.height
                        // Sync keyboard focus so Enter can launch hovered app
                        var idx = root._visibleApps().indexOf(modelData)
                        if (idx >= 0) {
                            root._focusIndex = idx
                            root._focusedApp = modelData
                        }
                    } else {
                        _ulHideTimer.restart()
                    }
                }
                onPointChanged: {
                    if (!hovered) return
                    root._ulY = mapToItem(root, 0, 0).y + dg.height
                }
            }
            Component.onCompleted: root._delegates.push(dg)
            Component.onDestruction: {
                var idx = root._delegates.indexOf(dg)
                if (idx >= 0) root._delegates.splice(idx, 1)
            }
            TapHandler {
                id: tap
                onTapped: { modelData.execute(); root.appLaunched() }
            }
        }
    }
}
