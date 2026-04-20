import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: window
    width: 600
    height: 500
    visible: true
    title: "Testeur d'Animations Final"

    property bool isDark: true

    // On définit les couleurs une seule fois pour éviter les boucles
    readonly property color bgColor: isDark ? "#1a1b26" : "#f0f2f5"
    readonly property color fgColor: isDark ? "white" : "black"

    palette.window: bgColor
    palette.windowText: fgColor
    palette.base: bgColor
    palette.text: fgColor
    palette.button: bgColor
    palette.buttonText: fgColor

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    Rectangle {
        anchors.fill: parent
        color: window.bgColor

        Loader {
            id: animLoader
            anchors.fill: parent
            source: "pluie.qml"
        }

        Text {
            anchors.centerIn: parent
            text: "12°C"
            font.pixelSize: 100; font.bold: true
            color: window.fgColor
            z: 50
        }
    }

    footer: ToolBar {
        Row {
            anchors.centerIn: parent
            spacing: 20
            Button {
                text: window.isDark ? "Passer en mode CLAIR" : "Passer en mode SOMBRE"
                onClicked: window.isDark = !window.isDark
            }
            ComboBox {
                width: 180
                model: ["pluie.qml", "neige.qml", "brume.qml", "soleil.qml", "nuit.qml", "orage.qml", "nuage.qml", "vent.qml", "grele.qml", "bruine.qml"]
                onActivated: (index) => animLoader.source = model[index]
            }
        }
    }
}
