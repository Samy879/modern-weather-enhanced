import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Item {
    id: snowRoot
    anchors.fill: parent
    clip: true

    property int flakeCount: 75
    property int baseSpeed: 9000

    Component {
        id: flakeComponent
        Item {
            id: flakeGroup

            // --- PROFONDEUR SIMPLE ---
            readonly property real depth: Math.random()

            // Taille classique (finis les énormes flocons flous)
            property real size: 1.5 + (depth * 3.0)
            property real opacityValue: 0.2 + (depth * 0.5)

            width: size * 4; height: size * 4

            // --- SYSTÈME DE TRAJECTOIRE ROBUSTE ---
            property real progress: 0.0
            property real startX: 0
            property real swayX: 0
            property real windDrift: 30 + Math.random() * 30

            // Propriété stockée pour éviter les bugs d'animation
            property int currentDuration: snowRoot.baseSpeed / (0.5 + depth)

            x: startX - (progress * windDrift) + swayX
            y: -50 + (progress * (snowRoot.height + 100))

            // --- FLOCONS NETS SANS AURA ---
            RadialGradient {
                anchors.fill: parent
                // Rayon très resserré pour faire un point doux, pas un halo énorme
                horizontalRadius: parent.width * 0.25
                verticalRadius: horizontalRadius

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.alpha(Kirigami.Theme.textColor, flakeGroup.opacityValue) }
                    GradientStop { position: 0.5; color: Qt.alpha(Kirigami.Theme.textColor, flakeGroup.opacityValue * 0.3) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Balancement du vent
            SequentialAnimation on swayX {
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: 15 + depth * 10; duration: 2000 + Math.random() * 2000; easing.type: Easing.InOutSine }
                NumberAnimation { to: -(15 + depth * 10); duration: 4000 + Math.random() * 4000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0; duration: 2000 + Math.random() * 2000; easing.type: Easing.InOutSine }
            }

            // --- CHUTE SANS BUG (RangeError corrigé) ---
            SequentialAnimation {
                running: true

                // 1ère phase : Termine la chute depuis la position de départ aléatoire
                NumberAnimation {
                    target: flakeGroup
                    property: "progress"
                    to: 1.0
                    // Adapte la durée au trajet restant
                    duration: flakeGroup.currentDuration * (1.0 - flakeGroup.progress)
                }

                // 2ème phase : Boucle infinie classique (de haut en bas)
                SequentialAnimation {
                    loops: Animation.Infinite

                    ScriptAction {
                        script: {
                            if (snowRoot.width > 0) {
                                flakeGroup.startX = Math.random() * (snowRoot.width + flakeGroup.windDrift);
                            }
                            flakeGroup.currentDuration = (snowRoot.baseSpeed / (0.5 + flakeGroup.depth)) * (0.8 + Math.random() * 0.4);
                        }
                    }

                    NumberAnimation {
                        target: flakeGroup
                        property: "progress"
                        from: 0.0
                        to: 1.0
                        duration: flakeGroup.currentDuration
                    }
                }
            }

            Component.onCompleted: {
                flakeGroup.startX = Math.random() * (snowRoot.width > 0 ? snowRoot.width + windDrift : 1000);
                // Le flocon commence à une hauteur aléatoire pour éviter un écran vide au lancement
                flakeGroup.progress = Math.random();
            }
        }
    }

    Repeater {
        model: snowRoot.flakeCount
        delegate: Loader {
            asynchronous: true
            sourceComponent: flakeComponent
            opacity: status === Loader.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 1000 } }
        }
    }
}
