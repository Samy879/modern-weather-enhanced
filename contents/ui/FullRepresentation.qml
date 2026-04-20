import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3
import "components" as Components
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: rootItem

    Plasmoid.backgroundHints: "NoBackground"

    // La propriété qui reçoit MAGIQUEMENT les données depuis main.qml !
    property var weatherData

    property string temperatureUnit: root.temperatureUnit

    readonly property string unitStr: (temperatureUnit === "0" || temperatureUnit == 0) ? "°C" : "°F"
    readonly property string currentTempText: (weatherData && weatherData.temperaturaActualPopup) ? weatherData.temperaturaActualPopup : "--"
    readonly property bool anyDetailEnabled: !!(root.showApparentTemp || root.showHumidity || root.showUVIndex || root.showWind)
    readonly property bool showBottomDetails: !!(anyDetailEnabled && root.showConditionFull)

    // --- DIMENSIONS D'ORIGINE ---
    readonly property int fixedWidth: Kirigami.Units.gridUnit * 15
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

    // --- 1. LE FOND ANIMÉ ---
    Rectangle {
        id: backgroundContainer
        anchors { fill: parent; margins: -10 }
        color: "transparent"
        radius: 12
        clip: true

        layer.enabled: !!plasmoid.configuration.showAnimations
        layer.smooth: true
        z: -1

        Item {
            id: animationsLayers
            anchors.fill: parent

            visible: !!(plasmoid.configuration.showAnimations &&
            weatherData &&
            weatherData.weatherData &&
            weatherData.temperaturaActual !== "--")

            readonly property int weatherCode: weatherData && weatherData.codeweather ? parseInt(weatherData.codeweather) : 0
            readonly property real windValue: weatherData && weatherData.windSpeed ? parseFloat(weatherData.windSpeed) : 0

            readonly property bool isDay: {
                if (weatherData && weatherData.weatherData && weatherData.weatherData.current) {
                    return weatherData.weatherData.current.is_day === 1;
                }
                let currentHour = new Date().getHours();
                return (currentHour >= 7 && currentHour <= 20);
            }

            Loader {
                anchors.fill: parent
                active: !!(plasmoid.configuration.showAnimations && animationsLayers.visible)
                source: animationsLayers.isDay ? "animations/soleil.qml" : "animations/nuit.qml"
            }
            Loader {
                anchors.fill: parent
                active: {
                    if (!plasmoid.configuration.showAnimations || !animationsLayers.visible) return false;
                    let code = animationsLayers.weatherCode;
                    return code >= 3 && code !== 45 && code !== 48;
                }
                source: "animations/nuage.qml"
            }
            Loader {
                anchors.fill: parent
                active: !!(plasmoid.configuration.showAnimations && animationsLayers.visible && source !== "")
                source: {
                    let code = animationsLayers.weatherCode;
                    if (code >= 95) return "animations/orage.qml";
                    if ((code >= 71 && code <= 77) || code === 85 || code === 86) return "animations/neige.qml";
                    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) return "animations/pluie.qml";
                    if (code >= 51 && code <= 57) return "animations/bruine.qml";
                    if (code === 45 || code === 48) return "animations/brume.qml";
                    return "";
                }
            }
            Loader {
                anchors.fill: parent
                active: !!(plasmoid.configuration.showAnimations && animationsLayers.visible && animationsLayers.windValue >= 20)
                source: "animations/vent.qml"
            }
        }
    }

    // --- 2. LAYOUT PRINCIPAL ---
    ColumnLayout {
        id: infoLayout
        anchors.fill: parent
        spacing: 0

        RowLayout {
            id: headerSection
            Layout.fillWidth: true
            Layout.topMargin: -Kirigami.Units.smallSpacing
            Layout.leftMargin: Kirigami.Units.gridUnit
            Layout.rightMargin: Kirigami.Units.gridUnit
            spacing: 0

            Item { Layout.fillWidth: true; visible: !rightSideContainer.visible }

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

            Item { Layout.fillWidth: true }

            ColumnLayout {
                id: rightSideContainer
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0
                visible: !!(root.showConditionFull || anyDetailEnabled)

                PlasmaComponents3.Label {
                    visible: !!root.showConditionFull
                    Layout.fillWidth: true
                    text: weatherData ? weatherData.weatherLongtext : ""
                    font.pixelSize: text.length <= 10 ? Kirigami.Units.gridUnit * 1.3 : Kirigami.Units.gridUnit * 1.0
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: Kirigami.Units.gridUnit * 0.55
                }

                GridLayout {
                    id: detailsGrid
                    visible: !!(!root.showConditionFull && anyDetailEnabled)
                    columns: 2
                    rowSpacing: Kirigami.Units.gridUnit * 0.3
                    columnSpacing: Kirigami.Units.smallSpacing
                    layoutDirection: Qt.RightToLeft
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: -7.5

                    CompactGridItem {
                        visible: !!root.showWind
                        label: i18n("Wind")
                        value: weatherData ? Math.round(weatherData.windSpeed) + (unitStr === "°C" ? " km/h" : " mph") : "--"
                    }
                    CompactGridItem {
                        visible: !!root.showUVIndex
                        label: i18n("UV")
                        value: weatherData ? weatherData.uvIndex : "--"
                    }
                    CompactGridItem {
                        visible: !!root.showHumidity
                        label: i18n("Hum")
                        value: weatherData ? weatherData.humidity + "%" : "--"
                    }
                    CompactGridItem {
                        visible: !!root.showApparentTemp
                        label: i18n("Feels")
                        value: weatherData ? Math.round(weatherData.apparentTemp) + unitStr : "--"
                    }
                }
            }
        }

        RowLayout {
            id: forecastSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: -Kirigami.Units.gridUnit * 0.5
            spacing: 0

            Repeater {
                model: (weatherData && weatherData.weatherData && weatherData.weatherData.daily) ? 3 : 0
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    readonly property int dayIndex: modelData + root.forecastStartDay

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: (weatherData && root.days) ? root.days[root.sumarDia(dayIndex)] : ""
                        horizontalAlignment: Text.AlignHCenter
                        font.capitalization: Font.Capitalize
                        font.pixelSize: Kirigami.Units.gridUnit * 0.65
                        opacity: 0.8
                    }

                    Kirigami.Icon {
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2.7
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2.7
                        Layout.alignment: Qt.AlignHCenter
                        source: (weatherData && weatherData.weatherData.daily) ? weatherData.asingicon(weatherData.weatherData.daily.weather_code[dayIndex]) : ""
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                        PlasmaComponents3.Label {
                            text: (weatherData && weatherData.weatherData.daily) ? Math.round(weatherData.weatherData.daily.temperature_2m_max[dayIndex]) + "°" : ""
                            font.bold: true
                            font.pixelSize: Kirigami.Units.gridUnit * 0.75
                        }
                        PlasmaComponents3.Label {
                            text: (weatherData && weatherData.weatherData.daily) ? Math.round(weatherData.weatherData.daily.temperature_2m_min[dayIndex]) + "°" : ""
                            opacity: 0.6
                            font.pixelSize: Kirigami.Units.gridUnit * 0.75
                        }
                    }
                }
            }
        }

        RowLayout {
            id: detailsRow
            visible: !!showBottomDetails
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2.2
            Layout.leftMargin: Kirigami.Units.gridUnit * 0.5
            Layout.rightMargin: Kirigami.Units.gridUnit * 0.5
            spacing: 0

            DetailColumn {
                visible: !!root.showApparentTemp
                label: i18n("Apparent Temp")
                value: (weatherData ? Math.round(weatherData.apparentTemp) : "--") + unitStr
            }

            Rectangle {
                visible: !!(root.showApparentTemp && (root.showHumidity || root.showUVIndex || root.showWind))
                Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.2;
                color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
            }

            DetailColumn {
                visible: !!root.showHumidity
                label: i18n("Humidity")
                value: (weatherData ? weatherData.humidity : "--") + "%"
            }

            Rectangle {
                visible: !!(root.showHumidity && (root.showUVIndex || root.showWind))
                Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.2;
                color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
            }

            DetailColumn {
                visible: !!root.showUVIndex
                label: i18n("UV Index")
                value: weatherData ? weatherData.uvIndex : "--"
            }

            Rectangle {
                visible: !!(root.showUVIndex && root.showWind)
                Layout.preferredWidth: 1; Layout.preferredHeight: Kirigami.Units.gridUnit * 1.2;
                color: Kirigami.Theme.textColor; opacity: 0.15; Layout.alignment: Qt.AlignVCenter
            }

            DetailColumn {
                visible: !!root.showWind
                label: i18n("Wind")
                value: weatherData ? Math.round(weatherData.windSpeed) + (unitStr === "°C" ? " km/h" : " mph") : "--"
            }
        }
    }

    component CompactGridItem : ColumnLayout {
        property string label: ""
        property string value: ""
        spacing: 0
        Layout.preferredWidth: Kirigami.Units.gridUnit * 2.2
        PlasmaComponents3.Label {
            text: parent.label
            font.pixelSize: Kirigami.Units.gridUnit * 0.5
            opacity: 0.6
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
        PlasmaComponents3.Label {
            text: parent.value
            font.pixelSize: Kirigami.Units.gridUnit * 0.65
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    component DetailColumn : ColumnLayout {
        property string label: ""
        property string value: ""
        Layout.fillWidth: true
        spacing: 0
        PlasmaComponents3.Label {
            text: parent.label
            font.pixelSize: Kirigami.Units.gridUnit * 0.55
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.7
        }
        PlasmaComponents3.Label {
            text: parent.value
            font.pixelSize: Kirigami.Units.gridUnit * 0.70
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
