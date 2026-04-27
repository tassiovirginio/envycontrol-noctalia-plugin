import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property string screenName: screen?.name ?? ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

    readonly property bool showLabel: pluginApi?.pluginSettings?.showLabel ?? pluginApi?.manifest?.metadata?.defaultSettings?.showLabel ?? true
    readonly property bool boldText: pluginApi?.pluginSettings?.boldText ?? pluginApi?.manifest?.metadata?.defaultSettings?.boldText ?? true

    readonly property string mode: pluginApi?.mainInstance?.currentMode || "unknown"
    readonly property bool switching: pluginApi?.mainInstance?.switching || false

    readonly property real contentWidth: isBarVertical ? capsuleHeight : layout.implicitWidth + Style.marginM * 2
    readonly property real contentHeight: isBarVertical ? layout.implicitHeight + Style.marginM * 2 : capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
        radius: Style.radiusL
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        Item {
            id: layout
            anchors.centerIn: parent
            implicitWidth: rowLayout.visible ? rowLayout.implicitWidth : colLayout.implicitWidth
            implicitHeight: rowLayout.visible ? rowLayout.implicitHeight : colLayout.implicitHeight

            RowLayout {
                id: rowLayout
                visible: !root.isBarVertical
                anchors.centerIn: parent
                spacing: Style.marginS

                NIcon {
                    visible: !root.switching
                    icon: root.pluginApi?.mainInstance?.getModeIcon(root.mode) || "question-mark"
                    color: mouseArea.containsMouse ? Color.mOnHover : (root.pluginApi?.mainInstance?.getModeColor(root.mode) || Color.mOnSurfaceVariant)
                }

                NIcon {
                    visible: root.switching
                    icon: "loader"
                    color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurfaceVariant

                    RotationAnimator on rotation {
                        running: root.switching
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                NText {
                    visible: root.showLabel && !root.switching
                    text: root.pluginApi?.mainInstance?.getModeLabel(root.mode) || ""
                    color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
                    pointSize: root.barFontSize
                    applyUiScale: false
                    font.weight: root.boldText ? Font.Bold : Font.Normal
                }
            }

            ColumnLayout {
                id: colLayout
                visible: root.isBarVertical
                anchors.centerIn: parent
                spacing: Style.marginS

                NText {
                    visible: root.showLabel && !root.switching
                    text: root.pluginApi?.mainInstance?.getModeLabel(root.mode) || ""
                    color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
                    pointSize: root.barFontSize
                    applyUiScale: false
                    font.weight: root.boldText ? Font.Bold : Font.Normal
                }

                NIcon {
                    visible: !root.switching
                    icon: root.pluginApi?.mainInstance?.getModeIcon(root.mode) || "question-mark"
                    color: mouseArea.containsMouse ? Color.mOnHover : (root.pluginApi?.mainInstance?.getModeColor(root.mode) || Color.mOnSurfaceVariant)
                }

                NIcon {
                    visible: root.switching
                    icon: "loader"
                    color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurfaceVariant

                    RotationAnimator on rotation {
                        running: root.switching
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }
            }
        }
    }

    NPopupContextMenu {
        id: contextMenu
        model: [
            {
                "label": pluginApi.tr("context.refresh"),
                "action": "refresh",
                "icon": "refresh"
            },
            {
                "label": pluginApi.tr("context.integrated"),
                "action": "integrated",
                "icon": "cpu"
            },
            {
                "label": pluginApi.tr("context.hybrid"),
                "action": "hybrid",
                "icon": "device-desktop"
            },
            {
                "label": pluginApi.tr("context.nvidia"),
                "action": "nvidia",
                "icon": "gpu"
            },
            {
                "label": pluginApi.tr("context.reset"),
                "action": "reset",
                "icon": "restore"
            },
            {
                "label": pluginApi.tr("context.settings"),
                "action": "settings",
                "icon": "settings"
            }
        ]

        onTriggered: action => {
            contextMenu.close();
            PanelService.closeContextMenu(screen);

            if (action === "refresh") {
                root.pluginApi.mainInstance.refreshMode()
            } else if (action === "integrated") {
                root.pluginApi.mainInstance.switchMode("integrated", null)
            } else if (action === "hybrid") {
                root.pluginApi.mainInstance.switchMode("hybrid", null)
            } else if (action === "nvidia") {
                root.pluginApi.mainInstance.switchMode("nvidia", null)
            } else if (action === "reset") {
                root.pluginApi.mainInstance.resetEnvycontrol()
            } else if (action === "settings") {
                BarService.openPluginSettings(screen, pluginApi.manifest)
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton || mouse.button === Qt.RightButton) {
                PanelService.showContextMenu(contextMenu, root, screen)
            }
        }

        onEntered: {
            var tooltip = pluginApi.tr("tooltip.currentMode") + ": " + root.pluginApi?.mainInstance?.getModeLabel(root.mode)
            TooltipService.show(root, tooltip, BarService.getTooltipDirection(root.screen?.name))
        }

        onExited: {
            TooltipService.hide()
        }
    }
}
