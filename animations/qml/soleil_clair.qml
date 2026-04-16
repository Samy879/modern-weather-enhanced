import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: sunRoot
    width: 350
    height: 300
    clip: true // Coupe ce qui dépasse du cadre de 350x300

    // --- POSITION DU SOLEIL (Haut à Droite) ---
    Item {
        id: sunPivot
        x: parent.width - 50  // Positionné en haut à droite
        y: 50
        width: 1; height: 1

        // 1. LE HALO (Diffusion très localisée)
        // On réduit la taille à 250px pour qu'il ne s'étende pas sur tout le widget
        Item {
            anchors.centerIn: parent
            width: 250; height: 250

            RadialGradient {
                id: sunHalo
                anchors.fill: parent
                // Couleur orange très transparente pour la douceur
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#26ffb400" }
                    GradientStop { position: 0.4; color: "transparent" }
                }

                // Pulsation légère pour le réalisme
                SequentialAnimation {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { target: sunHalo; property: "opacity"; from: 0.4; to: 1.0; duration: 5000; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: sunHalo; property: "opacity"; from: 1.0; to: 0.4; duration: 5000; easing.type: Easing.InOutQuad }
                }
            }

            layer.enabled: true
            layer.effect: GaussianBlur { radius: 30 }
        }

        // 2. LA SPHÈRE JAUNE/ORANGE (Cœur réduit)
        Item {
            anchors.centerIn: parent
            width: 120; height: 120

            RadialGradient {
                anchors.fill: parent
                // Utilisation de l'ambre concentré pour marquer le cercle
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#80ff9100" } // 50% opacité
                    GradientStop { position: 0.15; color: "transparent" } // Cercle très petit et précis
                }
            }
        }
    }
}
