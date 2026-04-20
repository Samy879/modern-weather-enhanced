import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Item {
    id: sunRoot
    anchors.fill: parent

    // --- NOUVELLES COULEURS PLUS LÉGÈRES ---
    readonly property color sunColor: "#FFF0A8" // Jaune pastel très doux au lieu du or
    readonly property color rayColor: "#FFFFFF" // Blanc pur pour des rayons cristallins et propres
    readonly property color coreColor: "#FFFFFF" // Centre éclatant

    Item {
        id: sunPositioner
        // --- POSITION AJUSTÉE ICI ---
        // Plus à droite (88%) et plus haut (12%)
        x: parent.width * 0.88
        y: parent.height * 0.12

        // --- 1. HALO GLOBAL (Plus transparent et resserré) ---
        RadialGradient {
            anchors.centerIn: parent
            width: 700
            height: 700
            opacity: 0.08 // Encore plus léger pour ne pas "salir" les nuages
            gradient: Gradient {
                GradientStop { position: 0.0; color: sunColor }
                GradientStop { position: 0.3; color: "transparent" } // S'estompe plus vite
            }
        }

        // --- 2. LES FAISCEAUX (Oscillants et purs) ---
        Item {
            id: raysContainer
            anchors.centerIn: parent
            width: Math.max(sunRoot.width, sunRoot.height) * 3
            height: width

            Repeater {
                model: 12
                delegate: Rectangle {
                    anchors.centerIn: parent

                    width: raysContainer.width * (index % 3 === 0 ? 0.8 : 0.6)
                    height: index % 2 === 0 ? 8 : 3
                    opacity: index % 2 === 0 ? 0.12 : 0.06 // Transparence subtile

                    // On sauvegarde l'angle de base pour l'animation d'oscillation
                    property real baseAngle: index * (360 / 12) + (index * 8)
                    rotation: baseAngle

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.4; color: rayColor }
                        GradientStop { position: 0.5; color: sunColor }
                        GradientStop { position: 0.6; color: rayColor }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    // --- ANIMATION D'OSCILLATION (Légèrement accélérée) ---
                    SequentialAnimation on rotation {
                        loops: Animation.Infinite

                        // Mouvement fluide vers l'avant
                        NumberAnimation {
                            from: baseAngle
                            to: baseAngle + 20
                            // Durée réduite (de 80000 à 55000) pour plus de dynamisme
                            duration: 40000 + (index * 2000)
                            easing.type: Easing.InOutSine
                        }
                        // Retour en arrière fluide
                        NumberAnimation {
                            from: baseAngle + 20
                            to: baseAngle - 10
                            // Durée réduite (de 90000 à 65000)
                            duration: 45000 + (index * 2000)
                            easing.type: Easing.InOutSine
                        }
                        // Retour à la position de base
                        NumberAnimation {
                            from: baseAngle - 10
                            to: baseAngle
                            // Durée réduite (de 70000 à 45000)
                            duration: 45000 + (index * 2000)
                            easing.type: Easing.InOutSine
                        }
                    }
                }
            }

            layer.enabled: true
            layer.effect: GaussianBlur {
                radius: 12
                samples: 24
            }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.7; to: 1.0; duration: 6000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.7; duration: 6000; easing.type: Easing.InOutSine }
            }
        }

        // --- 3. LE CŒUR DU SOLEIL (Sans orange saturé) ---
        Item {
            anchors.centerIn: parent
            width: 200
            height: 200

            Rectangle {
                id: sunCore
                anchors.centerIn: parent
                width: Math.min(sunRoot.width, sunRoot.height) * 0.12
                height: width
                radius: width / 2

                // Dégradé pastel : termine sur un jaune doré léger au lieu d'un orange franc
                gradient: Gradient {
                    GradientStop { position: 0.0; color: coreColor }
                    GradientStop { position: 0.6; color: "#FFF8D6" } // Jaune-blanc très clair
                    GradientStop { position: 1.0; color: "#FFE266" } // Jaune chaleureux mais non agressif
                }
            }

            layer.enabled: true
            layer.effect: GaussianBlur {
                radius: 6
                samples: 16
            }
        }
    }
}
