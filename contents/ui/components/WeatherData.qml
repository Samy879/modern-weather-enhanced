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
  property var useCoordinatesIp: Plasmoid.configuration.useCoordinatesIp
  property string latitudeC: Plasmoid.configuration.latitudeC
  property string longitudeC: Plasmoid.configuration.longitudeC
  property string temperatureUnit: Plasmoid.configuration.temperatureUnit
  property int updateInterval: Plasmoid.configuration.updateInterval || 15

  property bool isBusy: false

  property int refreshTrigger: Plasmoid.configuration.refreshTrigger
  onRefreshTriggerChanged: {
    console.log("--- [ACTION] Bouton Refresh appuyé (Trigger: " + refreshTrigger + ")");
    updateWeather();
  }

  // --- Données météo ---
  property string apparentTemp: weatherData ? Math.round(weatherData.current.apparent_temperature) : "--"
  property string humidity: weatherData ? weatherData.current.relative_humidity_2m : "--"
  property string uvIndex: weatherData ? Math.round(weatherData.current.uv_index) : "--"
  property string windSpeed: weatherData ? Math.round(weatherData.current.wind_speed_10m) : "--"
  property var weatherData: null
  property var coordsObj: null

  // --- Localisation ---
  property bool isAutoLoc: useCoordinatesIp === true || useCoordinatesIp === "true"
  property string latitude: isAutoLoc ? (coordsObj ? coordsObj.lat : "0") : latitudeC
  property string longitud: isAutoLoc ? (coordsObj ? coordsObj.lon : "0") : longitudeC
  property string codeleng: (Qt.locale().name).substring(0, 2)
  property string city: ""

  // --- Propriétés d'affichage ---
  property int isDay: weatherData ? weatherData.current.is_day : 1
  readonly property string prefixIcon: isDay === 1 ? "" : "-night"
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

  // --- TIMERS ---
  Timer {
    id: weatherTimer
    interval: Math.max(root.updateInterval, 5) * 60000
    running: true; repeat: true
    onTriggered: updateWeather()
  }

  Timer {
    id: retryTimer
    interval: 10000
    running: false; repeat: false
    onTriggered: updateWeather()
  }

  Timer {
    id: wakeUpDetector
    interval: 10000; running: true; repeat: true
    property var lastExecutionTime: new Date().getTime()
    onTriggered: {
      var currentTime = new Date().getTime();
      if (currentTime - lastExecutionTime > 30000) {
        console.log("--- [SYSTEM] Réveil du PC détecté");
        updateWeather();
      }
      lastExecutionTime = currentTime;
    }
  }

  Timer {
    id: safetyUnlockTimer
    interval: 30000
    running: false; repeat: false
    onTriggered: {
      if (root.isBusy) {
        console.log("--- [TIMEOUT] Pas de réponse réseau après 30s. Déblocage.");
        root.isBusy = false;
      }
    }
  }

  // --- FONCTIONS ---
  function updateWeather() {
    if (isBusy) {
      console.log("--- [INFO] Mise à jour déjà en cours...");
      return;
    }
    isBusy = true;
    safetyUnlockTimer.start();
    retryTimer.stop();
    console.log("--- [1/4] Démarrage du cycle (Auto-IP: " + isAutoLoc + ")");

    if (isAutoLoc || (latitude === "0" && longitud === "0")) {
      GeoCoordinates.obtenerCoordenadas(function(res) {
        if (res) {
          console.log("--- [2/4] Coordonnées récupérées : " + res.lat + ", " + res.lon);
          coordsObj = res;
          fetchData();
        } else {
          endSession(false, "Echec Géo-localisation");
        }
      });
    } else {
      console.log("--- [2/4] Utilisation des coordonnées manuelles : " + latitude + ", " + longitud);
      fetchData();
    }
  }

  function fetchData() {
    console.log("--- [3/4] Requête Météo envoyée...");
    GetWeather.fetchAllWeather(latitude, longitud, root.temperatureUnit, function(data) {
      if (data) {
        console.log("--- [3/4] Données Météo reçues avec succès");
        weatherData = data;
        getCityName();
      } else {
        endSession(false, "Echec API Météo");
      }
    });
  }

  function getCityName() {
    GetCity.getNameCity(latitude, longitud, codeleng, function(res) {
      city = res;
      console.log("--- [4/4] Lieu détecté : " + city);
      endSession(true, "Succès");
    });
  }

  function endSession(success, message) {
    safetyUnlockTimer.stop();
    isBusy = false;
    if (success) {
      console.log("--- [FINAL] Cycle terminé avec succès !");
    } else {
      console.log("--- [ERREUR] Cycle interrompu : " + message);
      retryTimer.start();
    }
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
    let icon = "weather-" + (wmocodes[x] || "clouds");
    return (b === true || b === "preciso") ? icon + prefixIcon : icon;
  }

  Component.onCompleted: updateWeather()
  onTemperatureUnitChanged: updateWeather()
}
