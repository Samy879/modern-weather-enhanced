import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import "components" as Components
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: fullweather
    property var weatherData: root.weatherSource
    property string temperatureUnit: root.temperatureUnit

    readonly property string unitStr: (temperatureUnit === "0" || temperatureUnit == 0) ? "°C" : "°F"
    readonly property string currentTempText: weatherData.temperaturaActualPopup

    readonly property bool anyDetailEnabled: root.showApparentTemp || root.showHumidity || root.showUVIndex || root.showWind
    readonly property bool showBottomDetails: anyDetailEnabled && root.showConditionFull

    readonly property int fixedWidth: Kirigami.Units.gridUnit * 15;

    readonly property int calculatedHeight: {
        let base = Kirigami.Units.gridUnit * 12.5;
        return (showBottomDetails) ? base : (base - Kirigami.Units.gridUnit * 2.5);
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

    // 1. SECTION HAUTE
    RowLayout {
        id: headerSection
        Layout.fillWidth: true
        Layout.topMargin: -Kirigami.Units.smallSpacing
        Layout.leftMargin: Kirigami.Units.gridUnit
        Layout.rightMargin: Kirigami.Units.gridUnit
        spacing: 0

        // --- NOUVEAU : ESPACEUR GAUCHE ---
        // Il ne devient actif (visible) que si le bloc de droite est caché.
        // Cela force la température à se déplacer vers le centre.
        Item {
            Layout.fillWidth: true
            visible: !rightSideContainer.visible
        }

        // BLOC TEMPÉRATURE
        Row {
            id: tempContainer
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents3.Label {
                text: currentTempText
                font.pixelSize: Kirigami.Units.gridUnit * 2.5
                font.bold: true
                leftPadding: currentTempText.length === 1 ? Kirigami.Units.gridUnit * 0.4 : 0
            }
            PlasmaComponents3.Label {
                text: unitStr
                font.pixelSize: Kirigami.Units.gridUnit * 1.5
                font.bold: true
                topPadding: Kirigami.Units.gridUnit * 0.2
            }
        }

        // ESPACEUR CENTRAL / DROIT
        // Toujours présent : il sert de séparation quand la droite est là,
        // et de contrepoids pour centrer quand la droite est cachée.
        Item { Layout.fillWidth: true }

        // CONTAINER DE DROITE
        ColumnLayout {
            id: rightSideContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0
            visible: root.showConditionFull || anyDetailEnabled

            // OPTION A : Le Titre
            PlasmaComponents3.Label {
                visible: root.showConditionFull
                Layout.fillWidth: true
                text: weatherData.weatherLongtext
                font.pixelSize: text.length <= 10 ? Kirigami.Units.gridUnit * 1.3 : Kirigami.Units.gridUnit * 1.0
                opacity: 1.0
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // OPTION B : Grille d'infos
            GridLayout {
                id: detailsGrid
                visible: !root.showConditionFull && anyDetailEnabled
                columns: 2
                rowSpacing: Kirigami.Units.gridUnit * 0.3
                columnSpacing: Kirigami.Units.smallSpacing
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: -7

                component CompactGridItem : ColumnLayout {
                    property string label: ""
                    property string value: ""
                    spacing: 0
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 2.2

                    PlasmaComponents3.Label {
                        text: label
                        font.pixelSize: Kirigami.Units.gridUnit * 0.5
                        opacity: 0.6
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    PlasmaComponents3.Label {
                        text: value
                        font.pixelSize: Kirigami.Units.gridUnit * 0.65
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                CompactGridItem {
                    visible: root.showWind
                    label: i18n("Wind")
                    value: Math.round(weatherData.windSpeed) + (unitStr === "°C" ? " km/h" : " mph")
                }
                CompactGridItem {
                    visible: root.showUVIndex
                    label: i18n("UV")
                    value: weatherData.uvIndex
                }
                CompactGridItem {
                    visible: root.showHumidity
                    label: i18n("Hum")
                    value: weatherData.humidity + "%"
                }
                CompactGridItem {
                    visible: root.showApparentTemp
                    label: i18n("Feels")
                    value: Math.round(weatherData.apparentTemp) + unitStr
                }
            }
        }
    }

    // 2. SECTION MILIEU (Prévisions)
    RowLayout {
        id: forecastSection
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: -Kirigami.Units.gridUnit * 0.5
        spacing: 0

        Repeater {
            model: 3
            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
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

    // 3. SECTION BASSE
    RowLayout {
        id: detailsRow
        visible: showBottomDetails
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 2.2
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
            Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.2;
            color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
        }

        DetailColumn {
            visible: root.showHumidity
            label: i18n("Humidity")
            value: weatherData.humidity + "%"
        }

        Rectangle {
            visible: root.showHumidity && (root.showUVIndex || root.showWind)
            Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.2;
            color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
        }

        DetailColumn {
            visible: root.showUVIndex
            label: i18n("UV Index")
            value: weatherData.uvIndex
        }

        Rectangle {
            visible: root.showUVIndex && root.showWind
            Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.2;
            color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
        }

        DetailColumn {
            visible: root.showWind
            label: i18n("Wind")
            value: Math.round(weatherData.windSpeed) + (unitStr === "°C" ? " km/h" : " mph")
        }
    }
}
