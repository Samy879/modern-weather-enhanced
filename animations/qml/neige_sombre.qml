import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: snowRoot
    width: 350
    height: 300
    clip: true

    // 1. Fond de nuit profonde [cite: 19, 22]
    Rectangle {
        anchors.fill: parent
        color: "#0d0e17"
    }

    // 2. AMBIANCE FROIDE (Brouillard subtil en bas) [cite: 20, 24]
    RadialGradient {
        anchors.fill: parent
        horizontalOffset: 0
        verticalOffset: height * 0.5
        horizontalRadius: width * 0.5
        verticalRadius: height * 0.5
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#14b4dcff" } // --cold-glow [cite: 20]
            GradientStop { position: 0.6; color: "transparent" }
        }
    }

    // 3. COMPOSANT FLOCON AMÉLIORÉ
    Component {
        id: flakeComponent
        Item {
            id: flakeGroup
            property int sSpeed: 8000
            property int sWait: 0
            property string sPath: "A"
            property real bRad: 1.5
            property real fS: 3.5

            // On rend le conteneur 3x plus grand que le flocon
            // pour que le flou ne soit jamais coupé (évite l'effet carré)
            width: fS * 3; height: fS * 3
            opacity: 0

            // Le flocon lui-même, centré dans son grand conteneur
            Item {
                id: flakeShape
                anchors.centerIn: parent
                width: flakeGroup.fS; height: flakeGroup.fS

                RadialGradient {
                    anchors.fill: parent
                    // On force une forme circulaire parfaite
                    horizontalRadius: width / 2
                    verticalRadius: height / 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "white" } // --flake-color [cite: 19]
                        GradientStop { position: 0.4; color: "#80FFFFFF" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            // Application du flou sur le conteneur large
            layer.enabled: true
            layer.effect: GaussianBlur { radius: flakeGroup.bRad }

            // --- ANIMATIONS DE CHUTE OSCILLANTE [cite: 32-40] ---
            NumberAnimation on y {
                id: animY
                from: -50; to: 350
                duration: flakeGroup.sSpeed
                loops: Animation.Infinite
                running: false
            }

            SequentialAnimation on x {
                id: pathA
                running: false
                loops: Animation.Infinite
                NumberAnimation { to: -3; duration: flakeGroup.sSpeed * 0.15; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 6;  duration: flakeGroup.sSpeed * 0.25; easing.type: Easing.InOutQuad }
                NumberAnimation { to: -4; duration: flakeGroup.sSpeed * 0.3; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 3;  duration: flakeGroup.sSpeed * 0.3; easing.type: Easing.InOutQuad }
            }

            SequentialAnimation on x {
                id: pathB
                running: false
                loops: Animation.Infinite
                NumberAnimation { to: 4;   duration: flakeGroup.sSpeed * 0.2; easing.type: Easing.InOutQuad }
                NumberAnimation { to: -12; duration: flakeGroup.sSpeed * 0.4; easing.type: Easing.InOutQuad }
                NumberAnimation { to: -5;  duration: flakeGroup.sSpeed * 0.4; easing.type: Easing.InOutQuad }
            }

            SequentialAnimation on opacity {
                id: animAlpha
                loops: Animation.Infinite
                running: false
                NumberAnimation { to: 0.9; duration: flakeGroup.sSpeed * 0.1 }
                PauseAnimation { duration: flakeGroup.sSpeed * 0.7 }
                NumberAnimation { to: 0.3; duration: flakeGroup.sSpeed * 0.2 }
            }

            Timer {
                interval: sWait
                running: true
                onTriggered: {
                    animY.start()
                    animAlpha.start()
                    if (sPath === "A") pathA.start()
                        else pathB.start()
                }
            }
        }
    }

    // --- SYSTÈME DE FLOCONS [cite: 44-46] ---
    Repeater {
        model: ListModel {
            // Large (proches, rapides)
            ListElement { px: 0.20; sw: 500; ss: 5000; sp: "A"; sz: 5.0; sb: 2.5 }
            ListElement { px: 0.60; sw: 2500; ss: 5500; sp: "B"; sz: 5.0; sb: 2.5 }
            // Moyens [cite: 30]
            ListElement { px: 0.10; sw: 1000; ss: 7000; sp: "B"; sz: 3.5; sb: 1.5 }
            ListElement { px: 0.85; sw: 0; ss: 8000; sp: "A"; sz: 3.5; sb: 1.5 }
            ListElement { px: 0.45; sw: 4000; ss: 7500; sp: "B"; sz: 3.5; sb: 1.5 }
            // Petits (lents, nets) [cite: 31]
            ListElement { px: 0.30; sw: 2000; ss: 11000; sp: "A"; sz: 2.0; sb: 0.8 }
            ListElement { px: 0.75; sw: 1500; ss: 12000; sp: "B"; sz: 2.0; sb: 0.8 }
            ListElement { px: 0.05; sw: 5000; ss: 10000; sp: "A"; sz: 2.0; sb: 0.8 }
        }
        delegate: Loader {
            x: model.px * snowRoot.width
            sourceComponent: flakeComponent
            onLoaded: {
                item.sSpeed = model.ss; item.sWait = model.sw
                item.sPath = model.sp; item.fS = model.sz
                item.bRad = model.sb
            }
        }
    }
}
