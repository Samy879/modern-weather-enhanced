import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Item {
    id: nightRoot
    anchors.fill: parent
    clip: true

    // 1. Étoiles classiques (Plus nombreuses : 45)
    Repeater {
        model: 45
        delegate: Rectangle {
            x: Math.random() * parent.width; y: Math.random() * parent.height
            width: 1.1; height: 1.1; radius: 0.5
            color: Kirigami.Theme.textColor; opacity: Math.random() * 0.4
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.6; duration: 2000 + Math.random() * 3000 }
                NumberAnimation { to: 0.1; duration: 2000 + Math.random() * 3000 }
            }
        }
    }

    // 2. Étoiles profondes (Plus nombreuses : 8)
    Repeater {
        model: 8
        delegate: Item {
            x: Math.random() * parent.width; y: Math.random() * parent.height
            width: 25; height: 25

            RadialGradient {
                anchors.fill: parent
                opacity: 0
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Kirigami.Theme.textColor }
                    GradientStop { position: 0.3; color: "transparent" }
                }
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    PauseAnimation { duration: Math.random() * 8000 }
                    NumberAnimation { to: 0.5; duration: 1200; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0; duration: 1800; easing.type: Easing.InOutQuad }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 1.5; height: 1.5; radius: 0.7
                color: Kirigami.Theme.textColor
            }
        }
    }
}
