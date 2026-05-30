pragma Singleton
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    signal colorsChanged()

    // ═══════════════════════════════════════════════════════════
    // Each md3 token is a real QML property. Bindings like
    //   color: Colors.surface
    // auto-refresh when colors.json is rewritten by matugen.
    // ═══════════════════════════════════════════════════════════

    property string background: ""
    property string error: ""
    property string error_container: ""
    property string inverse_on_surface: ""
    property string inverse_primary: ""
    property string inverse_surface: ""
    property string on_background: ""
    property string on_error: ""
    property string on_error_container: ""
    property string on_primary: ""
    property string on_primary_container: ""
    property string on_primary_fixed: ""
    property string on_primary_fixed_variant: ""
    property string on_secondary: ""
    property string on_secondary_container: ""
    property string on_secondary_fixed: ""
    property string on_secondary_fixed_variant: ""
    property string on_surface: ""
    property string on_surface_variant: ""
    property string on_tertiary: ""
    property string on_tertiary_container: ""
    property string on_tertiary_fixed: ""
    property string on_tertiary_fixed_variant: ""
    property string outline: ""
    property string outline_variant: ""
    property string primary: ""
    property string primary_container: ""
    property string primary_fixed: ""
    property string primary_fixed_dim: ""
    property string scrim: ""
    property string secondary: ""
    property string secondary_container: ""
    property string secondary_fixed: ""
    property string secondary_fixed_dim: ""
    property string shadow: ""
    property string source_color: ""
    property string surface: ""
    property string surface_bright: ""
    property string surface_container: ""
    property string surface_container_high: ""
    property string surface_container_highest: ""
    property string surface_container_low: ""
    property string surface_container_lowest: ""
    property string surface_dim: ""
    property string surface_tint: ""
    property string surface_variant: ""
    property string tertiary: ""
    property string tertiary_container: ""
    property string tertiary_fixed: ""
    property string tertiary_fixed_dim: ""

    // ═══════════════════════════════════════════════════════════
    // File watcher
    // ═══════════════════════════════════════════════════════════

    property FileView file: FileView {
        id: fileView
        path: Qt.resolvedUrl("colors.json")
        onLoaded: root.reload()
        onFileChanged: root.reload()
    }

    // ═══════════════════════════════════════════════════════════
    // Assign every property from JSON, triggering binding refresh.
    // ═══════════════════════════════════════════════════════════

    function reload() {
        try {
            let m = JSON.parse(fileView.text()).md3
            if (!m) return

            background               = m.background               || ""
            error                    = m.error                    || ""
            error_container          = m.error_container          || ""
            inverse_on_surface       = m.inverse_on_surface       || ""
            inverse_primary          = m.inverse_primary          || ""
            inverse_surface          = m.inverse_surface          || ""
            on_background            = m.on_background            || ""
            on_error                 = m.on_error                 || ""
            on_error_container       = m.on_error_container       || ""
            on_primary               = m.on_primary               || ""
            on_primary_container     = m.on_primary_container     || ""
            on_primary_fixed         = m.on_primary_fixed         || ""
            on_primary_fixed_variant = m.on_primary_fixed_variant || ""
            on_secondary             = m.on_secondary             || ""
            on_secondary_container   = m.on_secondary_container   || ""
            on_secondary_fixed       = m.on_secondary_fixed       || ""
            on_secondary_fixed_variant=m.on_secondary_fixed_variant|| ""
            on_surface               = m.on_surface               || ""
            on_surface_variant       = m.on_surface_variant       || ""
            on_tertiary              = m.on_tertiary              || ""
            on_tertiary_container    = m.on_tertiary_container    || ""
            on_tertiary_fixed        = m.on_tertiary_fixed        || ""
            on_tertiary_fixed_variant= m.on_tertiary_fixed_variant|| ""
            outline                  = m.outline                  || ""
            outline_variant          = m.outline_variant          || ""
            primary                  = m.primary                  || ""
            primary_container        = m.primary_container        || ""
            primary_fixed            = m.primary_fixed            || ""
            primary_fixed_dim        = m.primary_fixed_dim        || ""
            scrim                    = m.scrim                    || ""
            secondary                = m.secondary                || ""
            secondary_container      = m.secondary_container      || ""
            secondary_fixed          = m.secondary_fixed          || ""
            secondary_fixed_dim      = m.secondary_fixed_dim      || ""
            shadow                   = m.shadow                   || ""
            source_color             = m.source_color             || ""
            surface                  = m.surface                  || ""
            surface_bright           = m.surface_bright           || ""
            surface_container        = m.surface_container        || ""
            surface_container_high   = m.surface_container_high   || ""
            surface_container_highest= m.surface_container_highest|| ""
            surface_container_low    = m.surface_container_low    || ""
            surface_container_lowest = m.surface_container_lowest || ""
            surface_dim              = m.surface_dim              || ""
            surface_tint             = m.surface_tint             || ""
            surface_variant          = m.surface_variant          || ""
            tertiary                 = m.tertiary                 || ""
            tertiary_container       = m.tertiary_container       || ""
            tertiary_fixed           = m.tertiary_fixed           || ""
            tertiary_fixed_dim       = m.tertiary_fixed_dim       || ""

            colorsChanged()
        } catch (e) {
            console.warn("Colors: failed to parse colors.json:", e.message)
        }
    }
}
