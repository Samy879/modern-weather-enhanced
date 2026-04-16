import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: nightRoot
    width: 350
    height: 300
    clip: true

    // 1. FOND NUIT D'ENCRE [cite: 47-48]
    Rectangle {
        anchors.fill: parent
        color: "#05070a"
    }

    // 2. LES ÉTOILES SCINTILLANTES [cite: 55-60]
    Item {
        id: starLayer
        anchors.fill: parent

        Component {
            id: starComponent
            Rectangle {
                id: starItem
                property int starDuration: 3000
                property real starSize: 1.0
                property real starBlur: 0.0

                width: starSize; height: starSize
                color: "#ffffff" // --star-color [cite: 48]
                radius: width / 2
                opacity: 0.2

                // Effet de scintillement (Twinkle) [cite: 59-60]
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.0; duration: starItem.starDuration * 0.5; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0.2; duration: starItem.starDuration * 0.5; easing.type: Easing.InOutQuad }
                }

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.2; duration: starItem.starDuration * 0.5; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: starItem.starDuration * 0.5; easing.type: Easing.InOutQuad }
                }

                // Applique le flou pour les étoiles moyennes [cite: 58]
                layer.enabled: starBlur > 0
                layer.effect: GaussianBlur { radius: starItem.starBlur }
            }
        }

        // Reproduction des positions du fichier source [cite: 66]
        Repeater {
            model: ListModel {
                ListElement { tx: 0.15; ty: 0.20; tdur: 3000; tsize: 1.0; tblur: 0.0 } // Small
                ListElement { tx: 0.40; ty: 0.10; tdur: 4000; tsize: 2.0; tblur: 0.5 } // Medium
                ListElement { tx: 0.80; ty: 0.40; tdur: 5000; tsize: 1.0; tblur: 0.0 }
                ListElement { tx: 0.10; ty: 0.60; tdur: 3500; tsize: 2.0; tblur: 0.5 }
                ListElement { tx: 0.30; ty: 0.75; tdur: 6000; tsize: 1.0; tblur: 0.0 }
                ListElement { tx: 0.70; ty: 0.85; tdur: 4500; tsize: 2.0; tblur: 0.5 }
                ListElement { tx: 0.65; ty: 0.25; tdur: 3200; tsize: 1.0; tblur: 0.0 }
                ListElement { tx: 0.90; ty: 0.55; tdur: 4800; tsize: 1.0; tblur: 0.0 }
            }
            delegate: Loader {
                x: model.tx * parent.width
                y: model.ty * parent.height
                sourceComponent: starComponent
                onLoaded: {
                    item.starDuration = model.tdur
                    item.starSize = model.tsize
                    item.starBlur = model.tblur
                }
            }
        }
    }

    // 3. LA LUNE VAPOREUSE [cite: 52-54, 61-62]
    Item {
        id: moonContainer
        width: 100; height: 100
        x: parent.width - 110 // À droite [cite: 52]
        y: 30 // En haut [cite: 52]

        // Halo Lunaire Diffus [cite: 54]
        RadialGradient {
            anchors.centerIn: parent
            width: 150; height: 150
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#33c8dcff" } // --moon-halo (20%) [cite: 48]
                GradientStop { position: 0.5; color: "transparent" }
            }
        }

        // Disque Lunaire [cite: 53]
        Rectangle {
            id: moonDisk
            anchors.centerIn: parent
            width: 45; height: 45 // [cite: 53]
            radius: 22.5
            color: "#CCffffef" // --moon-core (80%) [cite: 48]

            // Flou du disque [cite: 54]
            layer.enabled: true
            layer.effect: GaussianBlur { radius: 2.0 }

            // Animation de pulsation
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.8; to: 1.0; duration: 10000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.0; to: 0.8; duration: 10000; easing.type: Easing.InOutQuad }
            }
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.05; duration: 10000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.05; to: 1.0; duration: 10000; easing.type: Easing.InOutQuad }
            }
        }
    }
}
