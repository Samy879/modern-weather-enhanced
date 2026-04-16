import QtQuick

Item {
    property string latitud
    property string longitud
    readonly property bool fullCoordinates: latitud !== "" && longitud !== ""

    property int deepNight: 1230
    property int day: 360
    property bool isday: true
    property string apiUrlFinal: "https://api.sunrise-sunset.org/json?lat=" + latitud + "&lng=" + longitud + "&formatted=0"

    signal update

    Timer {
        id: delayFetchTimer
        interval: 50 // 50ms de retardo
        repeat: false
        onTriggered: {
            if (fullCoordinates) {
                fetchSunData(apiUrlFinal)
            }
        }
    }

    Timer {
        id: retryUpdate
        interval: 12000
        running: false
        repeat: true
        onTriggered: {
            fetchSunData(apiUrlFinal)
        }
    }

    function minutesOfDayISO8601(dat){
        var hours = parseInt(Qt.formatDateTime(dat, "H")) * 60
        var minutes = parseInt(Qt.formatDateTime(dat, "m"))
        return hours + minutes;
    }

    function minutesOfDay(dat){
        var UTCstring = dat.toUTCString();
        let parts = UTCstring.split(" ");
        let hoursMinutes = parts[3].split(":");
        let hours = parseInt(hoursMinutes[0])
        let minutes = parseInt(hoursMinutes[1])
        return (hours * 60) + minutes
    }

    function fetchSunData(url) {
        retryUpdate.stop()
        var minutesDay = minutesOfDay(new Date())
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.status === "OK") {
                    deepNight = minutesOfDayISO8601(response.results.sunset);
                    day = minutesOfDayISO8601(response.results.sunrise);
                    var AdjustedNightSchedule = deepNight < day ? deepNight + 1440 : deepNight
                    isday = minutesDay > day && minutesDay < AdjustedNightSchedule
                    console.log("isDay:", isday)
                }
            }
        };
        xhr.send();
    }

    // Al cambiar latitud o longitud, se activa un pequeño retardo antes de evaluar y llamar a fetch
    onLatitudChanged: delayFetchTimer.restart()
    onLongitudChanged: delayFetchTimer.restart()

    // También puedes seguir usando "update" externamente
    onUpdate: {
        if (fullCoordinates) {
            fetchSunData(apiUrlFinal)
        } else {
            retryUpdate.start()
        }
    }
}
