import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: 350
    height: 300
    clip: true

    Rectangle {
        anchors.fill: parent
        color: "#0d0e17" // Couleur de fond nuit profonde [cite: 101]
    }

    // --- BROUILLARD ATMOSPHÉRIQUE [cite: 108-110] ---
    Item {
        id: fogLayer
        anchors.fill: parent
        opacity: 0.6
        Repeater {
            model: 2
            delegate: Item {
                width: 600; height: 500
                x: index === 0 ? -100 : 50
                y: index === 0 ? -50 : 100
                RadialGradient {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#596e82aa" } // --fog-color [cite: 101]
                        GradientStop { position: 0.7; color: "transparent" }
                    }
                }
                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation { from: -40; to: 40; duration: 30000; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 40; to: -40; duration: 30000; easing.type: Easing.InOutQuad }
                }
            }
        }
        layer.enabled: true
        layer.effect: GaussianBlur { radius: 90 } // Simule le flou artistique [cite: 107]
    }

    // --- GESTIONNAIRE D'ÉCLAIR ---
    Item {
        id: boltManager
        property real currentIntensity: 0.3
        width: 1000; height: 1000

        RadialGradient {
            id: boltGrad
            anchors.centerIn: parent
            width: 800; height: 800
            opacity: 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 0.45; color: "transparent" }
            }
        }

        // --- TYPES D'ANIMATIONS (NERVES) [cite: 126-133] ---
        SequentialAnimation {
            id: animSingle
            NumberAnimation { target: boltGrad; property: "opacity"; to: boltManager.currentIntensity; duration: 50 }
            NumberAnimation { target: boltGrad; property: "opacity"; to: boltManager.currentIntensity * 0.2; duration: 40 }
            NumberAnimation { target: boltGrad; property: "opacity"; to: boltManager.currentIntensity * 0.8; duration: 100 }
            NumberAnimation { target: boltGrad; property: "opacity"; to: 0; duration: 500 }
        }

        SequentialAnimation {
            id: animDouble
            NumberAnimation { target: boltGrad; property: "opacity"; to: boltManager.currentIntensity * 0.8; duration: 80 }
            NumberAnimation { target: boltGrad; property: "opacity"; to: 0.1; duration: 40 }
            NumberAnimation { target: boltGrad; property: "opacity"; to: boltManager.currentIntensity; duration: 120 }
            NumberAnimation { target: boltGrad; property: "opacity"; to: 0; duration: 600 }
        }

        layer.enabled: true
        layer.effect: GaussianBlur { radius: 65 } // Flou pour l'aspect vaporeux
    }

    // --- GÉNÉRATEUR RYTHMIQUE AVANCÉ ---
    Timer {
        id: lightningSpawner
        running: true
        repeat: true
        interval: 1000

        onTriggered: {
            // Placement aléatoire sur toute la zone
            boltManager.x = (Math.random() * root.width) - 500;
            boltManager.y = (Math.random() * root.height) - 500;

            // Intensités basées sur orage.txt (Near, Std, Low)
            var randInt = Math.random();
            if (randInt > 0.75) boltManager.currentIntensity = 0.45;      // Near [cite: 102]
            else if (randInt > 0.3) boltManager.currentIntensity = 0.30;  // Std [cite: 103]
            else boltManager.currentIntensity = 0.12;                   // Low [cite: 104]

            // Choix de l'animation nerveuse [cite: 126-129]
            var randAnim = Math.floor(Math.random() * 2);
            if (randAnim === 0) animSingle.start();
            else animDouble.start();

            // LOGIQUE DE BATTEMENT VARIABLE
            var rhythmType = Math.random();

            if (rhythmType < 0.25) {
                // 1. Battement RAPIDE (Succession nerveuse)
                interval = 300 + Math.random() * 500;
            }
            else if (rhythmType < 0.50) {
                // 2. Battement DIFFÉRÉ (Succession lente et lourde)
                interval = 1200 + Math.random() * 1300;
            }
            else {
                // 3. CALME (Repos entre deux séquences)
                interval = 4000 + Math.random() * 4000;
            }
        }
    }
}
