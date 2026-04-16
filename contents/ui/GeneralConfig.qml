import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: configRoot
    title: i18n("General")

    property alias cfg_useCoordinatesIp: autoCoorde.checked
    property alias cfg_latitudeC: latitudeField.text
    property alias cfg_longitudeC: longitudeField.text
    property alias cfg_temperatureUnit: temperatureCombo.currentIndex
    property alias cfg_updateInterval: intervalSpin.value
    property alias cfg_textweather: textWeatherCheck.checked
    property alias cfg_showConditionOnPanel: conditionOnPanelCheck.checked
    property alias cfg_preciseTemp: preciseTempCheck.checked
    property alias cfg_reverseOrder: reverseCheck.checked
    property alias cfg_sizeFontTemp: fontSizeTempSpin.realValue
    property alias cfg_boldTempPanel: boldTempCheck.checked
    property alias cfg_sizeFontCond: fontSizeCondSpin.realValue
    property alias cfg_boldCondPanel: boldCondCheck.checked
    property alias cfg_boldfonts: boldFontsGlobalCheck.checked
    property alias cfg_forecastStartDay: startDaySpin.value
    property alias cfg_showApparentTemp: apparentCheck.checked
    property alias cfg_showHumidity: humidityCheck.checked
    property alias cfg_showUVIndex: uvCheck.checked
    property alias cfg_showWind: windCheck.checked

    // Ces valeurs doivent correspondre aux <default> du main.xml
    readonly property bool cfg_useCoordinatesIpDefault: true
    readonly property string cfg_latitudeCDefault: "0"
    readonly property string cfg_longitudeCDefault: "0"
    readonly property bool cfg_showConditionOnPanelDefault: true
    readonly property bool cfg_reverseOrderDefault: false
    readonly property int cfg_temperatureUnitDefault: 0
    readonly property double cfg_sizeFontTempDefault: 11.0
    readonly property double cfg_sizeFontCondDefault: 10.0
    readonly property bool cfg_boldfontsDefault: false
    readonly property bool cfg_textweatherDefault: true
    readonly property bool cfg_preciseTempDefault: false
    readonly property int cfg_updateIntervalDefault: 15
    readonly property int cfg_forecastStartDayDefault: 1
    readonly property bool cfg_boldTempPanelDefault: false
    readonly property bool cfg_boldCondPanelDefault: false
    readonly property bool cfg_showApparentTempDefault: true
    readonly property bool cfg_showHumidityDefault: true
    readonly property bool cfg_showUVIndexDefault: true
    readonly property bool cfg_showWindDefault: true

    Kirigami.FormLayout {

        // --- LOCALISATION ---
        CheckBox {
            id: autoCoorde
            Kirigami.FormData.label: i18n("Automatic Location (IP):")
        }
        TextField {
            id: latitudeField
            Kirigami.FormData.label: i18n("Latitude:")
            visible: !autoCoorde.checked
        }
        TextField {
            id: longitudeField
            Kirigami.FormData.label: i18n("Longitude:")
            visible: !autoCoorde.checked
        }

        Kirigami.Separator { }

        // --- SYSTÈME & UNITÉS ---
        ComboBox {
            id: temperatureCombo
            Kirigami.FormData.label: i18n("Temperature Unit:")
            model: [i18n("Celsius (°C)"), i18n("Fahrenheit (°F)")]
        }
        SpinBox {
            id: intervalSpin
            Kirigami.FormData.label: i18n("Update Interval (min):")
            from: 5; to: 360; stepSize: 5
        }

        Kirigami.Separator { }

        // --- CONFIGURATION DU PANEL ---
        CheckBox {
            id: textWeatherCheck
            Kirigami.FormData.label: i18n("Show temperature:")
        }
        CheckBox {
            id: conditionOnPanelCheck
            Kirigami.FormData.label: i18n("Show condition text:")
        }
        CheckBox {
            id: preciseTempCheck
            Kirigami.FormData.label: i18n("Show decimals (only panel):")
        }
        CheckBox {
            id: reverseCheck
            Kirigami.FormData.label: i18n("Reverse Temp/Condition order:")
        }

        Kirigami.Separator { }

        // --- STYLE & POLICES ---
        SpinBox {
            id: fontSizeTempSpin
            Kirigami.FormData.label: i18n("Temperature font size:")
            property real realValue: 11.0
            value: Math.round(realValue * 10)
            onValueModified: realValue = value / 10
            editable: true
            from: 80; to: 300; stepSize: 5
            textFromValue: (value, locale) => Number(value / 10).toLocaleString(locale, 'f', 1)
            valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text) * 10)
        }
        CheckBox {
            id: boldTempCheck
            Kirigami.FormData.label: i18n("Bold temperature:")
        }

        SpinBox {
            id: fontSizeCondSpin
            Kirigami.FormData.label: i18n("Condition font size:")
            property real realValue: 10.0
            value: Math.round(realValue * 10)
            onValueModified: realValue = value / 10
            editable: true
            from: 50; to: 250; stepSize: 5
            textFromValue: (value, locale) => Number(value / 10).toLocaleString(locale, 'f', 1)
            valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text) * 10)
        }
        CheckBox {
            id: boldCondCheck
            Kirigami.FormData.label: i18n("Bold condition text:")
        }

        // Ajout de la case à cocher pour l'option globale de police grasse
        CheckBox {
            id: boldFontsGlobalCheck
            Kirigami.FormData.label: i18n("Use bold fonts everywhere:")
        }

        Kirigami.Separator { }

        // --- DÉTAILS À AFFICHER ---
        Kirigami.Separator { Kirigami.FormData.label: i18n("Details to show:") }
        CheckBox { id: apparentCheck; text: i18n("Apparent Temperature") }
        CheckBox { id: humidityCheck; text: i18n("Humidity") }
        CheckBox { id: uvCheck; text: i18n("UV Index") }
        CheckBox { id: windCheck; text: i18n("Wind Speed") }

        Kirigami.Separator { }

        // --- PRÉVISIONS ---
        SpinBox {
            id: startDaySpin
            Kirigami.FormData.label: i18n("Forecast start day offset:")
            from: 0; to: 4; stepSize: 1
        }
    }
}
