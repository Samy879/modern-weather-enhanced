import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "components" as Components

PlasmoidItem {
  id: root
  width: compactRepresentation.implicitWidth

  Components.WeatherData {
    id: weatherSource
  }

  property bool boldTempPanel: Plasmoid.configuration.boldTempPanel
  property bool boldCondPanel: Plasmoid.configuration.boldCondPanel
  property bool reverseOrder: Plasmoid.configuration.reverseOrder
  property bool boldfonts: Plasmoid.configuration.boldfonts
  property string temperatureUnit: Plasmoid.configuration.temperatureUnit
  property real sizeFontTemp: Plasmoid.configuration.sizeFontTemp
  property real sizeFontCond: Plasmoid.configuration.sizeFontCond
  property bool preciseTemp: Plasmoid.configuration.preciseTemp

  property bool showApparentTemp: Plasmoid.configuration.showApparentTemp
  property bool showHumidity: Plasmoid.configuration.showHumidity
  property bool showUVIndex: Plasmoid.configuration.showUVIndex
  property bool showWind: Plasmoid.configuration.showWind

  property bool textweather: Plasmoid.configuration.textweather
  property int forecastStartDay: Plasmoid.configuration.forecastStartDay

  property var days: []
  Plasmoid.backgroundHints: (PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground)
  preferredRepresentation: compactRepresentation

  function sumarDia(offset) {
    let date = new Date();
    return (date.getDay() + offset) % 7;
  }

  Component.onCompleted: {
    let locale = Qt.locale();
    let tempDays = [];
    for (let i = 0; i < 7; i++) {
      tempDays.push(locale.dayName(i, Locale.ShortFormat));
    }
    days = tempDays;
  }

  compactRepresentation: CompactRepresentation {
    weatherData: weatherSource
  }
  fullRepresentation: FullRepresentation {
    weatherData: weatherSource
  }
}
