import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: rainRoot
    anchors.fill: parent
    clip: true

    Component {
        id: rainGroupComponent
        Item {
            id: dropGroup

            // Propriétés de contrôle
            property int animSpeed: 1000
            property int animWait: 0
            property real dropOpacity: 0.6
            property real dropLength: 15

            width: 40
            // Utilisation d'une hauteur fixe calculée une fois pour éviter les boucles de redimensionnement
            height: rainRoot.height > 0 ? rainRoot.height : 200

            Rectangle {
                id: drop
                anchors.horizontalCenter: parent.horizontalCenter
                width: 1
                height: dropGroup.dropLength
                color: Kirigami.Theme.textColor
                opacity: 0
            }

            SequentialAnimation {
                id: rainAnim
                running: true
                loops: Animation.Infinite

                // 1. Pause initiale basée sur la valeur actuelle
                PauseAnimation {
                    duration: Math.max(0, dropGroup.animWait)
                }

                // 2. Calcul des paramètres pour le PROCHAIN cycle
                // On prépare les valeurs ici pour éviter de les changer PENDANT le NumberAnimation
                ScriptAction {
                    script: {
                        let depthFactor = 0.3 + Math.random() * 0.7;

                        // On met à jour les propriétés du groupe
                        dropGroup.animWait = Math.random() * 1000;
                        dropGroup.animSpeed = 1300 - (depthFactor * 700);
                        dropGroup.dropLength = 5 + (depthFactor * 11);
                        dropGroup.dropOpacity = 0.1 + (depthFactor * 0.5);

                        if (rainRoot.width > 0) {
                            dropGroup.x = Math.random() * rainRoot.width;
                        }
                    }
                }

                // 3. Application de l'opacité
                PropertyAction {
                    target: drop
                    property: "opacity"
                    value: dropGroup.dropOpacity
                }

                // 4. Mouvement de chute
                ParallelAnimation {
                    NumberAnimation {
                        target: drop
                        property: "y"
                        from: -50
                        // On utilise une valeur numérique simple pour éviter les liens complexes
                        to: dropGroup.height + 20
                        duration: Math.max(1, dropGroup.animSpeed)
                        easing.type: Easing.InQuad
                    }

                    SequentialAnimation {
                        // On s'assure que la pause est légèrement plus courte que l'animation totale
                        PauseAnimation {
                            duration: Math.max(0, dropGroup.animSpeed - 50)
                        }
                        NumberAnimation {
                            target: drop
                            property: "opacity"
                            to: 0
                            duration: 50
                        }
                    }
                }

                // Reset de la position pour le prochain tour
                PropertyAction { target: drop; property: "y"; value: -50 }
            }
        }
    }

    Repeater {
        model: 25
        delegate: Loader {
            asynchronous: true
            sourceComponent: rainGroupComponent
            onLoaded: {
                item.x = Math.random() * rainRoot.width;
                item.animWait = Math.random() * 2000;
            }
        }
    }
}
