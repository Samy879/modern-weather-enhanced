import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: rainRoot
    width: 350
    height: 300
    clip: true

    // Fond sombre
    Rectangle {
        anchors.fill: parent
        color: "#0d0e17"
        radius: 12
    }

    Component {
        id: rainGroupComponent
        Item {
            id: dropGroup
            property int animSpeed: 1500
            property int animWait: 0

            width: 40
            height: rainRoot.height
            anchors.horizontalCenter: parent.left

            // LA GOUTTE : Ultra-fine et courte
            Rectangle {
                id: drop
                anchors.horizontalCenter: parent.horizontalCenter
                width: 0.7
                height: 15
                opacity: 0
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#A0FFFFFF" }
                }
            }

            // L'IMPACT : Ellipse en perspective
            Item {
                id: impact
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: 40
                height: 10
                scale: 0
                opacity: 0

                RadialGradient {
                    anchors.fill: parent
                    horizontalRadius: 20
                    verticalRadius: 5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.4; color: "#50FFFFFF" }
                        GradientStop { position: 0.8; color: "transparent" }
                    }
                }
            }

            SequentialAnimation {
                running: true
                loops: Animation.Infinite

                PauseAnimation { duration: dropGroup.animWait }

                // 1. Chute Linéaire
                ParallelAnimation {
                    NumberAnimation {
                        target: drop; property: "y"
                        from: -20; to: dropGroup.height - 15
                        duration: dropGroup.animSpeed * 0.75
                        easing.type: Easing.Linear
                    }
                    SequentialAnimation {
                        NumberAnimation { target: drop; property: "opacity"; to: 1; duration: dropGroup.animSpeed * 0.1 }
                        PauseAnimation { duration: dropGroup.animSpeed * 0.55 }
                        NumberAnimation { target: drop; property: "opacity"; to: 0; duration: dropGroup.animSpeed * 0.1 }
                    }
                }

                // 2. Splash en Perspective
                ParallelAnimation {
                    NumberAnimation {
                        target: impact; property: "scale"
                        from: 0.2; to: 1.4
                        duration: dropGroup.animSpeed * 0.25
                        easing.type: Easing.OutCubic
                    }
                    SequentialAnimation {
                        NumberAnimation { target: impact; property: "opacity"; to: 0.6; duration: dropGroup.animSpeed * 0.05 }
                        NumberAnimation { target: impact; property: "opacity"; to: 0; duration: dropGroup.animSpeed * 0.2 }
                    }
                }
            }
        }
    }

    // --- GÉNÉRATION ÉPURÉE (6 gouttes bien espacées) ---
    Repeater {
        model: ListModel {
            ListElement { px: 0.10; dWait: 0;    dSpd: 1100 }
            ListElement { px: 0.28; dWait: 600;  dSpd: 1400 }
            ListElement { px: 0.45; dWait: 200;  dSpd: 1200 }
            ListElement { px: 0.62; dWait: 900;  dSpd: 1500 }
            ListElement { px: 0.80; dWait: 400;  dSpd: 1300 }
            ListElement { px: 0.95; dWait: 1200; dSpd: 1150 }
        }
        delegate: Loader {
            x: model.px * rainRoot.width
            sourceComponent: rainGroupComponent
            onLoaded: {
                item.animSpeed = model.dSpd
                item.animWait = model.dWait
            }
        }
    }
}
