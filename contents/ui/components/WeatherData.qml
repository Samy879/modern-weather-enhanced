import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import "../js/traductor.js" as Traduc
import "../js/GetWeather.js" as GetWeather
import "../js/geoCoordinates.js" as GeoCoordinates
import "../js/GetCity.js" as GetCity

Item {
  id: root

  // --- Propriétés de configuration ---
  property string useCoordinatesIp: Plasmoid.configuration.useCoordinatesIp
  property string latitudeC: Plasmoid.configuration.latitudeC
  property string longitudeC: Plasmoid.configuration.longitudeC
  property string temperatureUnit: Plasmoid.configuration.temperatureUnit
  property int updateInterval: Plasmoid.configuration.updateInterval || 15

  property string apparentTemp: weatherData ? Math.round(weatherData.current.apparent_temperature) : "--"
  property string humidity: weatherData ? weatherData.current.relative_humidity_2m : "--"
  property string uvIndex: weatherData ? Math.round(weatherData.current.uv_index) : "--"
  property string windSpeed: weatherData ? Math.round(weatherData.current.wind_speed_10m) : "--"

  property var weatherData: null
  property var coordsObj: null

  // --- Logique de Localisation ---
  property string latitude: (useCoordinatesIp === "true") ? (coordsObj ? coordsObj.lat : "0") : latitudeC
  property string longitud: (useCoordinatesIp === "true") ? (coordsObj ? coordsObj.lon : "0") : longitudeC
  property string codeleng: (Qt.locale().name).substring(0, 2)

  // --- Gestion de l'affichage actuel ---
  property int isDay: weatherData ? weatherData.current.is_day : 1
  readonly property string prefixIcon: isDay === 1 ? "" : "-night"

  // On initialise avec "--" pour éviter le "0°" trompeur au démarrage
  property string temperaturaActual: weatherData ? weatherData.current.temperature_2m.toFixed(1) : "--"
  property string temperaturaActualPopup: weatherData ? Math.round(weatherData.current.temperature_2m) : "--"

  property string codeweather: weatherData ? weatherData.current.weather_code : 0
  property string iconWeatherCurrent: asingicon(codeweather, true)

  property string weatherLongtext: Traduc.weatherLongText(codeleng, codeweather)
  property string weatherShottext: Traduc.weatherShortText(codeleng, codeweather)

  property string probabilidadDeLLuvia: weatherData ? weatherData.daily.precipitation_probability_max[0] : "0"
  property string textProbability: Traduc.rainProbabilityText(codeleng)

  // --- Prévisions ---
  property int maxweatherTomorrow: weatherData ? Math.round(weatherData.daily.temperature_2m_max[1]) : 0
  property int minweatherTomorrow: weatherData ? Math.round(weatherData.daily.temperature_2m_min[1]) : 0
  property int codeweatherTomorrow: weatherData ? weatherData.daily.weather_code[1] : 0

  property int maxweatherDayAftertomorrow: weatherData ? Math.round(weatherData.daily.temperature_2m_max[2]) : 0
  property int minweatherDayAftertomorrow: weatherData ? Math.round(weatherData.daily.temperature_2m_min[2]) : 0
  property int codeweatherDayAftertomorrow: weatherData ? weatherData.daily.weather_code[2] : 0

  property int maxweatherTwoDaysAfterTomorrow: weatherData ? Math.round(weatherData.daily.temperature_2m_max[3]) : 0
  property int minweatherTwoDaysAfterTomorrow: weatherData ? Math.round(weatherData.daily.temperature_2m_min[3]) : 0
  property int codeweatherTwoDaysAfterTomorrow: weatherData ? weatherData.daily.weather_code[3] : 0

  property string city: ""

  // --- TIMERS ---

  // Minuteur principal (Mise à jour régulière)
  Timer {
    id: weatherTimer
    interval: Math.max(root.updateInterval, 5) * 60000
    running: true
    repeat: true
    onTriggered: updateWeather()
  }

  // Minuteur de secours (En cas d'échec réseau au démarrage)
  Timer {
    id: retryTimer
    interval: 30000 // Réessaie toutes les 30 secondes
    running: false
    repeat: false
    onTriggered: updateWeather()
  }

  // --- FONCTIONS ---

  function updateWeather() {
    retryTimer.stop() // On arrête le retry dès qu'on lance une tentative

    if (useCoordinatesIp === "true" || (latitude === "0" && longitud === "0")) {
      GeoCoordinates.obtenerCoordenadas(function(res) {
        if (res) {
          coordsObj = res;
          fetchData();
        } else {
          retryTimer.start(); // Échec localisation (réseau ?), on réessaie dans 30s
        }
      });
    } else {
      fetchData();
    }
  }

  function fetchData() {
    GetWeather.fetchAllWeather(latitude, longitud, root.temperatureUnit, function(data) {
      if (data) {
        weatherData = data;
        getCityName();
      } else {
        retryTimer.start(); // Échec météo, on réessaie dans 30s
      }
    });
  }

  function getCityName() {
    GetCity.getNameCity(latitude, longitud, codeleng, function(res) {
      city = res;
    });
  }

  function asingicon(x, b) {
    let wmocodes = {
      0: "clear", 1: "few-clouds", 2: "few-clouds", 3: "clouds",
      45: "fog", 48: "fog",
      51: "showers-scattered", 53: "showers-scattered", 55: "showers-scattered",
      61: "showers", 63: "showers", 65: "showers",
      80: "showers", 81: "showers", 82: "showers",
      95: "storm", 96: "storm", 99: "storm"
    };

    // Fallback sur "clouds" au lieu de "unknown" pour un meilleur rendu visuel
    let icon = "weather-" + (wmocodes[x] || "clouds");

    return (b === true || b === "preciso") ? icon + prefixIcon : icon;
  }

  Component.onCompleted: updateWeather()
  onTemperatureUnitChanged: updateWeather()
}
