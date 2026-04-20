import QtQuick

Item {
    id: dayOrNightRoot
    property string latitud
    property string longitud
    readonly property bool fullCoordinates: latitud !== "" && longitud !== ""

    // Propriété principale que ton plasmoid consultera
    property bool isDay: true

    // URL de l'API (formatted=0 renvoie du format ISO 8601 standard)
    property string apiUrlFinal: "https://api.sunrise-sunset.org/json?lat=" + latitud + "&lng=" + longitud + "&formatted=0"

    signal update

    Timer {
        id: delayFetchTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (fullCoordinates) {
                fetchSunData(apiUrlFinal)
            }
        }
    }

    Timer {
        id: retryUpdate
        interval: 12000 // Réessaie toutes les minutes en cas d'échec réseau
        running: false
        repeat: true
        onTriggered: fetchSunData(apiUrlFinal)
    }

    function fetchSunData(url) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    if (response.status === "OK") {
                        retryUpdate.stop();

                        // --- LOGIQUE SIMPLIFIÉE ---
                        var now = new Date();
                        // L'API renvoie des chaînes comme "2024-05-24T04:12:01+00:00"
                        // Le constructeur Date() les parse parfaitement en tenant compte de l'UTC
                        var sunrise = new Date(response.results.sunrise);
                        var sunset = new Date(response.results.sunset);

                        // Comparaison directe des objets Date (comparaison de timestams)
                        isDay = (now >= sunrise && now <= sunset);

                        console.log("DayOrNight - Lever:", sunrise.toLocaleTimeString(),
                                    "Coucher:", sunset.toLocaleTimeString(),
                                    "Il fait jour :", isDay);
                    }
                } else {
                    // Si l'API échoue, on lance le timer de secours
                    retryUpdate.start();
                }
            }
        };
        xhr.send();
    }

    // Déclenche la mise à jour si les coordonnées changent
    onLatitudChanged: delayFetchTimer.restart()
    onLongitudChanged: delayFetchTimer.restart()

    // Gestion du signal update
    onUpdate: {
        if (fullCoordinates) {
            fetchSunData(apiUrlFinal)
        } else {
            retryUpdate.start()
        }
    }
}
