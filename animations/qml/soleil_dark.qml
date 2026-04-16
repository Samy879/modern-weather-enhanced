import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: 350
    height: 300
    clip: true

    // Fond Nuit Profonde [cite: 67]
    Rectangle {
        anchors.fill: parent
        color: "#0d0e17"
    }

    // --- POSITION DU SOLEIL (Haut à Droite) ---
    Item {
        id: sunPivot
        x: parent.width - 40
        y: 40
        width: 1; height: 1

        // 1. LA SPHÈRE (Cœur réduit)
        // On garde un Item large pour le flou, mais on réduit la zone de couleur
        Item {
            anchors.centerIn: parent
            width: 200; height: 200

            RadialGradient {
                anchors.fill: parent
                // --sun-core: rgba(255, 200, 80, 0.2)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4Dffc850" }
                    // On réduit la position de 0.3 à 0.12 pour une boule plus petite
                    GradientStop { position: 0.12; color: "transparent" }
                }
            }
        }

        // 2. LE HALO (Diffusion large inchangée)
        Item {
            anchors.centerIn: parent
            width: 600; height: 600

            RadialGradient {
                id: halo
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1Affc850" }
                    GradientStop { position: 0.5; color: "transparent" }
                }
            }

            layer.enabled: true
            layer.effect: GaussianBlur {
                radius: 40
            }
        }

        // 3. LES RAYONS DIFFUS (Couverture totale optimisée) [cite: 78-82]
        Item {
            id: raysContainer
            anchors.centerIn: parent
            // On augmente la taille du conteneur à 1200 pour éviter toute coupure
            width: 1200; height: 1200
            opacity: 0.4

            // Rotation extrêmement lente (300s) [cite: 85-86]
            RotationAnimation on rotation {
                from: 0; to: 360; duration: 300000
                loops: Animation.Infinite; running: true
            }

            Repeater {
                model: 12
                delegate: Item {
                    anchors.centerIn: parent
                    rotation: index * 30

                    Rectangle {
                        // Le rayon commence au pivot (x:0) et s'étend sur 1000px
                        x: 0; y: -10
                        width: 1000
                        height: 20
                        antialiasing: true

                        // --sun-ray: rgba(255, 220, 150, 0.05)
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#0Dffdc96" }
                            GradientStop { position: 0.5; color: "transparent" }
                        }
                    }
                }
            }

            layer.enabled: true
            layer.effect: GaussianBlur {
                radius: 25
            }
        }
    }
}
