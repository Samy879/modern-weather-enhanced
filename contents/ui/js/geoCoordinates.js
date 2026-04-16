function obtenerCoordenadas(callback) {
    let url = "http://ip-api.com/json/?fields=lat,lon";
    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                try {
                    let datos = JSON.parse(req.responseText);
                    // On renvoie un objet propre
                    callback({
                        lat: datos.lat.toString(),
                             lon: datos.lon.toString()
                    });
                } catch (error) {
                    console.error("Erreur JSON:", error);
                    callback(null);
                }
            } else {
                callback(null);
            }
        }
    };
    req.send();
}
