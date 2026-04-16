import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: fogRoot
    width: 350
    height: 300
    clip: true

    // 1. FOND NUIT PROFONDE [cite: 69]
    Rectangle {
        anchors.fill: parent
        color: "#0a0b10"
    }

    // 2. DÉGRADÉ DE PROFONDEUR (Base du brouillard) [cite: 71, 78-79]
    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, height)
        end: Qt.point(0, height * 0.3)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4d3c506e" } // --fog-glow (30%) [cite: 71]
            GradientStop { position: 1.0; color: "transparent" }
        }
        z: 2
    }

    // 3. COMPOSANT NAPPE DE BRUME (Utilise un RadialGradient pour la douceur)
    Component {
        id: fogLayerComponent
        Item {
            id: fogLayer
            width: 800 // Très large pour éviter les bords coupés
            height: 600
            x: (fogRoot.width - width) / 2

            property int animDuration: 12000 // 12s [cite: 77]
            property int animDelay: 0
            property real baseOpacity: 0.4 // --fog-color (40%) [cite: 70]
            property real targetY: 50

            RadialGradient {
                anchors.fill: parent
                // On utilise des rayons très larges pour une transition invisible
                horizontalRadius: width * 0.5
                verticalRadius: height * 0.4
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#665a6982" } // --fog-color [cite: 70]
                    GradientStop { position: 0.7; color: "transparent" }
                }
            }

            // ANIMATION DE RESPIRATION
            SequentialAnimation {
                running: true
                loops: Animation.Infinite
                PauseAnimation { duration: animDelay }

                ParallelAnimation {
                    // Mouvement vertical fluide (-40px) [cite: 81]
                    NumberAnimation { target: fogLayer; property: "y"; to: targetY - 40; duration: animDuration; easing.type: Easing.InOutSine }
                    // Changement d'opacité [cite: 81-82]
                    NumberAnimation { target: fogLayer; property: "opacity"; from: baseOpacity; to: baseOpacity + 0.3; duration: animDuration; easing.type: Easing.InOutSine }
                    // Effet de dilatation [cite: 81]
                    NumberAnimation { target: fogLayer; property: "scale"; from: 1.0; to: 1.15; duration: animDuration; easing.type: Easing.InOutSine }
                }
                ParallelAnimation {
                    NumberAnimation { target: fogLayer; property: "y"; to: targetY; duration: animDuration; easing.type: Easing.InOutSine }
                    NumberAnimation { target: fogLayer; property: "opacity"; from: baseOpacity + 0.3; to: baseOpacity; duration: animDuration; easing.type: Easing.InOutSine }
                    NumberAnimation { target: fogLayer; property: "scale"; from: 1.15; to: 1.0; duration: animDuration; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // 4. LES TROIS NAPPES SUPERPOSÉES [cite: 85]
    // Ces nappes sont placées en bas du widget pour simuler la brume au sol.
    Loader {
        sourceComponent: fogLayerComponent
        y: 100
        onLoaded: { item.animDelay = 0; item.targetY = 100; item.baseOpacity = 0.4 }
    }

    Loader {
        sourceComponent: fogLayerComponent
        y: 140
        onLoaded: { item.animDelay = 4000; item.targetY = 140; item.baseOpacity = 0.3 }
    }

    Loader {
        sourceComponent: fogLayerComponent
        y: 180
        onLoaded: { item.animDelay = 8000; item.targetY = 180; item.baseOpacity = 0.5 }
    }
}
