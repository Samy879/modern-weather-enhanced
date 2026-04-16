import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import "components" as Components
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: fullweather
    property var weatherData: root.weatherSource
    property string temperatureUnit: root.temperatureUnit

    // --- LOGIQUE DU PANEL ---
    readonly property string unitStr: (temperatureUnit === "0" || temperatureUnit == 0) ? "°C" : "°F"

    // Valeur arrondie uniquement
    readonly property string currentTempText: weatherData.temperaturaActualPopup

    // --- LOGIQUE DE VISIBILITÉ ---
    readonly property bool detailsVisible: root.showApparentTemp || root.showHumidity || root.showUVIndex || root.showWind

    // --- DIMENSIONS DYNAMIQUES ---
    readonly property int fixedWidth: Kirigami.Units.gridUnit * 15;

    readonly property int calculatedHeight: {
        let base = Kirigami.Units.gridUnit * 13;
        return detailsVisible ? base : (base - Kirigami.Units.gridUnit * 2.5);
    }

    width: fixedWidth
    height: calculatedHeight

    Layout.minimumWidth: fixedWidth
    Layout.maximumWidth: fixedWidth
    Layout.preferredWidth: fixedWidth
    Layout.minimumHeight: calculatedHeight
    Layout.maximumHeight: calculatedHeight
    Layout.preferredHeight: calculatedHeight

    spacing: 0

    // SECTION HAUTE : TEMPÉRATURE ET CONDITION
    RowLayout {
        id: headerSection
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        Layout.leftMargin: Kirigami.Units.gridUnit
        Layout.rightMargin: Kirigami.Units.gridUnit
        spacing: Kirigami.Units.largeSpacing

        // Température avec décalage global et dynamique pour chiffre unique
        Row {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter
            // Marge à gauche (0 pour rester au bord comme demandé)
            Layout.leftMargin: Kirigami.Units.gridUnit * 0

            PlasmaComponents3.Label {
                text: currentTempText
                font.pixelSize: Kirigami.Units.gridUnit * 2.5
                font.bold: true
                // Décalage conservé pour l'équilibre optique si 1 seul chiffre
                leftPadding: currentTempText.length === 1 ? Kirigami.Units.gridUnit * 0.4 : 0
            }
            PlasmaComponents3.Label {
                text: unitStr
                font.pixelSize: Kirigami.Units.gridUnit * 1.5
                font.bold: true
                Layout.alignment: Qt.AlignTop
                topPadding: Kirigami.Units.gridUnit * 0.2
            }
        }

        PlasmaComponents3.Label {
            text: weatherData.weatherLongtext
            font.pixelSize: Kirigami.Units.gridUnit * 1.0
            opacity: 0.85
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // LIGNE DE DÉTAILS (AUTOCENTRÉE ET EXTENSIBLE)
    RowLayout {
        id: detailsRow
        visible: detailsVisible
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Kirigami.Units.gridUnit * 0.5
        Layout.rightMargin: Kirigami.Units.gridUnit * 0.5
        spacing: 0

        component DetailColumn : ColumnLayout {
            property string label: ""
            property string value: ""
            Layout.fillWidth: true
            spacing: 0

            PlasmaComponents3.Label {
                text: label
                font.pixelSize: Kirigami.Units.gridUnit * 0.55
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.7
            }
            PlasmaComponents3.Label {
                text: value
                // Taille réduite de 0.75 à 0.70 pour affiner le texte (notamment le vent)
                font.pixelSize: Kirigami.Units.gridUnit * 0.70
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        DetailColumn {
            visible: root.showApparentTemp
            label: i18n("Apparent Temp")
            value: weatherData.apparentTemp + unitStr
        }

        Rectangle {
            visible: root.showApparentTemp && (root.showHumidity || root.showUVIndex || root.showWind)
            Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5;
            color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
        }

        DetailColumn {
            visible: root.showHumidity
            label: i18n("Humidity")
            value: weatherData.humidity + "%"
        }

        Rectangle {
            visible: root.showHumidity && (root.showUVIndex || root.showWind)
            Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5;
            color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
        }

        DetailColumn {
            visible: root.showUVIndex
            label: i18n("UV Index")
            value: weatherData.uvIndex
        }

        Rectangle {
            visible: root.showUVIndex && root.showWind
            Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5;
            color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
        }

        DetailColumn {
            visible: root.showWind
            label: i18n("Wind")
            value: Math.round(weatherData.windSpeed) + " km/h"
        }
    }

    // SECTION BASSE : PRÉVISIONS
    RowLayout {
        id: forecastSection
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.bottomMargin: Kirigami.Units.largeSpacing
        spacing: 0

        Repeater {
            model: 3
            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                readonly property int dayIndex: modelData + root.forecastStartDay

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: root.days[root.sumarDia(dayIndex)]
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.Capitalize
                    font.pixelSize: Kirigami.Units.gridUnit * 0.65
                    opacity: 0.8
                }

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 2.7
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2.7
                    Layout.alignment: Qt.AlignHCenter
                    source: weatherData.asingicon(weatherData.weatherData.daily.weather_code[dayIndex])
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    PlasmaComponents3.Label {
                        text: Math.round(weatherData.weatherData.daily.temperature_2m_max[dayIndex]) + "°"
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.75
                    }
                    PlasmaComponents3.Label {
                        text: Math.round(weatherData.weatherData.daily.temperature_2m_min[dayIndex]) + "°"
                        opacity: 0.6
                        font.pixelSize: Kirigami.Units.gridUnit * 0.75
                    }
                }
            }
        }
    }
}
