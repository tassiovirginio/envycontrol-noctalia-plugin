import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    property real contentPreferredWidth: 480 * Style.uiScaleRatio
    property real contentPreferredHeight: 420 * Style.uiScaleRatio

    anchors.fill: parent

    readonly property string currentMode: pluginApi?.mainInstance?.currentMode || "unknown"
    readonly property bool switching: pluginApi?.mainInstance?.switching || false
    readonly property bool confirmReboot: pluginApi?.pluginSettings?.confirmReboot ?? pluginApi?.manifest?.metadata?.defaultSettings?.confirmReboot ?? true

    property string pendingMode: ""

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors {
                fill: parent
                margins: Style.marginL
            }
            spacing: Style.marginL

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                NIcon {
                    icon: "settings-automation"
                    pointSize: Style.fontSizeXL
                    color: Color.mPrimary
                }

                NText {
                    Layout.fillWidth: true
                    text: pluginApi?.tr("panel.title") || "GPU Mode"
                    pointSize: Style.fontSizeXL
                    font.weight: Font.Bold
                    color: Color.mOnSurface
                }

                NIconButton {
                    icon: "refresh"
                    onClicked: {
                        pluginApi?.mainInstance?.refreshMode()
                    }
                }

                NIconButton {
                    icon: "close"
                    onClicked: {
                        pluginApi.closePanel(pluginApi.panelOpenScreen)
                    }
                }
            }

            // Current mode indicator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Qt.rgba(Color.mPrimary.r, Color.mPrimary.g, Color.mPrimary.b, 0.1)
                radius: Style.radiusM

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    NIcon {
                        icon: pluginApi?.mainInstance?.getModeIcon(root.currentMode) || "question-mark"
                        color: pluginApi?.mainInstance?.getModeColor(root.currentMode) || Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeL
                    }

                    NText {
                        text: (pluginApi?.tr("panel.currentMode") || "Current Mode") + ": " + (pluginApi?.mainInstance?.getModeLabel(root.currentMode) || "")
                        pointSize: Style.fontSizeM
                        font.weight: Font.Bold
                        color: Color.mOnSurface
                    }
                }
            }

            // Mode selection cards
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Style.marginM

                // Integrated
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: root.currentMode === "integrated" ? Qt.rgba(0.13, 0.59, 0.95, 0.15) : (integratedMouse.containsMouse ? Color.mHover : Color.mSurfaceVariant)
                    radius: Style.radiusL
                    border.color: root.currentMode === "integrated" ? "#2196F3" : Style.capsuleBorderColor
                    border.width: root.currentMode === "integrated" ? 2 : Style.capsuleBorderWidth

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: Style.marginM
                        }
                        spacing: Style.marginM

                        NIcon {
                            icon: "cpu"
                            color: "#2196F3"
                            pointSize: Style.fontSizeXL
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginXS

                            NText {
                                text: pluginApi?.tr("panel.integrated") || "Integrated"
                                pointSize: Style.fontSizeM
                                font.weight: Font.Bold
                                color: Color.mOnSurface
                            }

                            NText {
                                text: pluginApi?.tr("panel.integratedDesc") || "Intel/AMD only, best battery"
                                pointSize: Style.fontSizeS
                                color: Color.mOnSurfaceVariant
                            }
                        }

                        NIcon {
                            visible: root.currentMode === "integrated"
                            icon: "check"
                            color: "#2196F3"
                        }
                    }

                    MouseArea {
                        id: integratedMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentMode !== "integrated" && !root.switching) {
                                root.pendingMode = "integrated"
                                if (root.confirmReboot) {
                                    rebootConfirmDialog.visible = true
                                } else {
                                    pluginApi?.mainInstance?.switchMode("integrated", null)
                                }
                            }
                        }
                    }
                }

                // Hybrid
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: root.currentMode === "hybrid" ? Qt.rgba(0.61, 0.15, 0.69, 0.15) : (hybridMouse.containsMouse ? Color.mHover : Color.mSurfaceVariant)
                    radius: Style.radiusL
                    border.color: root.currentMode === "hybrid" ? "#9C27B0" : Style.capsuleBorderColor
                    border.width: root.currentMode === "hybrid" ? 2 : Style.capsuleBorderWidth

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: Style.marginM
                        }
                        spacing: Style.marginM

                        NIcon {
                            icon: "device-desktop"
                            color: "#9C27B0"
                            pointSize: Style.fontSizeXL
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginXS

                            NText {
                                text: pluginApi?.tr("panel.hybrid") || "Hybrid"
                                pointSize: Style.fontSizeM
                                font.weight: Font.Bold
                                color: Color.mOnSurface
                            }

                            NText {
                                text: pluginApi?.tr("panel.hybridDesc") || "On-demand GPU, balanced"
                                pointSize: Style.fontSizeS
                                color: Color.mOnSurfaceVariant
                            }
                        }

                        NIcon {
                            visible: root.currentMode === "hybrid"
                            icon: "check"
                            color: "#9C27B0"
                        }
                    }

                    MouseArea {
                        id: hybridMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentMode !== "hybrid" && !root.switching) {
                                root.pendingMode = "hybrid"
                                if (root.confirmReboot) {
                                    rebootConfirmDialog.visible = true
                                } else {
                                    pluginApi?.mainInstance?.switchMode("hybrid", null)
                                }
                            }
                        }
                    }
                }

                // NVIDIA
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: root.currentMode === "nvidia" ? Qt.rgba(0.46, 0.73, 0.0, 0.15) : (nvidiaMouse.containsMouse ? Color.mHover : Color.mSurfaceVariant)
                    radius: Style.radiusL
                    border.color: root.currentMode === "nvidia" ? "#76B900" : Style.capsuleBorderColor
                    border.width: root.currentMode === "nvidia" ? 2 : Style.capsuleBorderWidth

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: Style.marginM
                        }
                        spacing: Style.marginM

                        NIcon {
                            icon: "gpu"
                            color: "#76B900"
                            pointSize: Style.fontSizeXL
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginXS

                            NText {
                                text: pluginApi?.tr("panel.nvidia") || "NVIDIA"
                                pointSize: Style.fontSizeM
                                font.weight: Font.Bold
                                color: Color.mOnSurface
                            }

                            NText {
                                text: pluginApi?.tr("panel.nvidiaDesc") || "NVIDIA only, max performance"
                                pointSize: Style.fontSizeS
                                color: Color.mOnSurfaceVariant
                            }
                        }

                        NIcon {
                            visible: root.currentMode === "nvidia"
                            icon: "check"
                            color: "#76B900"
                        }
                    }

                    MouseArea {
                        id: nvidiaMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentMode !== "nvidia" && !root.switching) {
                                root.pendingMode = "nvidia"
                                if (root.confirmReboot) {
                                    rebootConfirmDialog.visible = true
                                } else {
                                    pluginApi?.mainInstance?.switchMode("nvidia", null)
                                }
                            }
                        }
                    }
                }
            }

            // Loading indicator
            RowLayout {
                visible: root.switching
                Layout.fillWidth: true
                spacing: Style.marginM

                NIcon {
                    icon: "loader"
                    color: Color.mPrimary

                    RotationAnimator on rotation {
                        running: root.switching
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                NText {
                    text: pluginApi?.tr("panel.switching") || "Switching mode..."
                    pointSize: Style.fontSizeM
                    color: Color.mOnSurfaceVariant
                }
            }

            // Reset button
            NButton {
                Layout.fillWidth: true
                text: pluginApi?.tr("panel.reset") || "Reset EnvyControl"
                icon: "restore"
                onClicked: {
                    pluginApi?.mainInstance?.resetEnvycontrol()
                }
            }
        }
    }

    // Reboot confirmation dialog
    Rectangle {
        id: rebootConfirmDialog
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        visible: false
        z: 100

        Rectangle {
            anchors.centerIn: parent
            width: 350
            height: 200
            color: Color.mSurface
            radius: Style.radiusL
            border.color: Style.capsuleBorderColor
            border.width: Style.capsuleBorderWidth

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: Style.marginL
                }
                spacing: Style.marginL

                NText {
                    text: pluginApi?.tr("dialog.rebootTitle") || "Reboot Required"
                    pointSize: Style.fontSizeL
                    font.weight: Font.Bold
                    color: Color.mOnSurface
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                NText {
                    text: (pluginApi?.tr("dialog.rebootMessage") || "Switch to {mode} mode requires a reboot. Proceed?").replace("{mode}", pluginApi?.mainInstance?.getModeLabel(root.pendingMode) || "")
                    pointSize: Style.fontSizeM
                    color: Color.mOnSurfaceVariant
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginM

                    NButton {
                        Layout.fillWidth: true
                        text: pluginApi?.tr("dialog.cancel") || "Cancel"
                        onClicked: {
                            rebootConfirmDialog.visible = false
                            root.pendingMode = ""
                        }
                    }

                    NButton {
                        Layout.fillWidth: true
                        text: pluginApi?.tr("dialog.switchAndReboot") || "Switch & Reboot"
                        highlighted: true
                        onClicked: {
                            rebootConfirmDialog.visible = false
                            pluginApi?.mainInstance?.switchMode(root.pendingMode, null)
                            root.pendingMode = ""
                        }
                    }

                    NButton {
                        Layout.fillWidth: true
                        text: pluginApi?.tr("dialog.switchOnly") || "Switch Only"
                        onClicked: {
                            rebootConfirmDialog.visible = false
                            pluginApi?.mainInstance?.switchMode(root.pendingMode, null)
                            root.pendingMode = ""
                        }
                    }
                }
            }
        }
    }
}
