import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: 350
    height: 300
    clip: true

    // Fond de nuit profonde
    Rectangle {
        anchors.fill: parent
        color: "#08090a"
    }

    Item {
        id: cloudsContainer
        anchors.fill: parent

        Repeater {
            // Modèle avec les tailles Large (400x200), Medium (280x140) et Small (180x100) [cite: 146, 147]
            model: [
                { w: 400, h: 200, yy: 20,  dur: 65000, col: "#802d374b" },
                { w: 280, h: 140, yy: 150, dur: 80000, col: "#802d374b" },
                { w: 400, h: 200, yy: 30,  dur: 45000, col: "#406478a0" },
                { w: 280, h: 140, yy: 120, dur: 55000, col: "#406478a0" },
                { w: 180, h: 100, yy: 210, dur: 40000, col: "#662d374b" }
            ]

            delegate: Item {
                width: modelData.w
                height: modelData.h
                y: modelData.yy

                RadialGradient {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: modelData.col }
                        GradientStop { position: 0.75; color: "transparent" }
                    }
                }

                // Animation de dérive (Drift) [cite: 144, 148]
                NumberAnimation on x {
                    from: -500
                    to: 800
                    duration: modelData.dur
                    loops: Animation.Infinite
                    running: true
                }

                Component.onCompleted: {
                    // Positionnement aléatoire immédiat pour peupler le ciel [cite: 148]
                    x = -500 + (Math.random() * 1200)
                }
            }
        }

        layer.enabled: true
        layer.effect: GaussianBlur {
            radius: 40 // Flou atmosphérique [cite: 143]
        }
    }
}
