import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: windRoot
    width: 350
    height: 300
    clip: true

    // 1. Fond de nuit profonde
    Rectangle {
        anchors.fill: parent
        color: "#0d0e17"
    }

    // 2. BRUME VAPOREUSE (Wind Drift) - Ralentie à 25 secondes
    Item {
        id: windDriftContainer
        anchors.fill: parent
        opacity: 0.4 // Légèrement plus discret

        RadialGradient {
            id: driftGrad
            width: 600
            height: 400
            x: -100
            y: -50
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#336e82aa" }
                GradientStop { position: 0.7; color: "transparent" }
            }

            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { from: -150; to: 50; duration: 25000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 50; to: -150; duration: 25000; easing.type: Easing.InOutQuad }
            }
        }

        layer.enabled: true
        layer.effect: GaussianBlur { radius: 50 }
    }

    // 3. COMPOSANT TRAÎNÉE DE VENT (Streak)
    Component {
        id: streakComponent
        Item {
            id: streakItem
            property int sDuration: 3500
            property int sDelay: 0
            property string sEasing: "linear"

            height: 1.2 // Encore plus fin pour le côté épuré
            opacity: 0

            Rectangle {
                anchors.fill: parent
                radius: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: "#40ffffff" } // Opacité réduite à 25%
                    GradientStop { position: 0.8; color: "#40ffffff" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            NumberAnimation on x {
                id: sweepAnim
                from: -400
                to: 600
                duration: streakItem.sDuration
                loops: Animation.Infinite
                easing.type: streakItem.sEasing === "gust" ? Easing.InOutQuad : Easing.Linear
            }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.5; duration: streakItem.sDuration * 0.2 }
                PauseAnimation { duration: streakItem.sDuration * 0.6 }
                NumberAnimation { to: 0; duration: streakItem.sDuration * 0.2 }
            }

            Timer {
                interval: sDelay
                running: true
                onTriggered: sweepAnim.start()
            }
        }
    }

    // --- REPRODUCTION ÉPURÉE ET RALENTIE ---

    // Brise constante (Anciennement "Fast", maintenant douce)
    Loader { sourceComponent: streakComponent; y: 80; width: 160; onLoaded: { item.sDuration = 4500; item.sDelay = 500 } }

    // Légère accélération (Anciennement "Gust")
    Loader { sourceComponent: streakComponent; y: 150; width: 220; onLoaded: { item.sDuration = 3200; item.sDelay = 2000; item.sEasing = "gust" } }

    // Traînée très lente
    Loader { sourceComponent: streakComponent; y: 230; width: 130; onLoaded: { item.sDuration = 8000; item.sDelay = 1200 } }

    // Brise basse
    Loader { sourceComponent: streakComponent; y: 260; width: 280; onLoaded: { item.sDuration = 5500; item.sDelay = 4000 } }
}
