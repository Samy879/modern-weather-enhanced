import QtQuick
import QtQuick.Controls

Window {
    visible: true
    width: 400
    height: 400
    color: "#1a1b26" // Fond de bureau sombre [cite: 139]

    pluie_sombre {
        anchors.centerIn: parent
    }

    // Overlay de texte pour simuler le widget
    Text {
        anchors.centerIn: parent
        text: "8.8°C"
        color: "black"
        font.pixelSize: 48
        font.bold: true
    }
}
