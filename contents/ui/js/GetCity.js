function getNameCity(latitude, longitud, leng, callback) {
    function fetchCity(useLanguage) {
        let url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitud}`;
        if (useLanguage) {
            url += `&accept-language=${leng}`;
        }

        let req = new XMLHttpRequest();
        req.open("GET", url, true);

        // Timeout de 5 secondes
        req.timeout = 5000;

        // Nominatim exige un User-Agent pour éviter le blocage 403
        req.setRequestHeader("User-Agent", "ChaacWeatherPlasmoid/1.0");

        req.onreadystatechange = function () {
            if (req.readyState === 4) {
                if (req.status === 200) {
                    try {
                        let datos = JSON.parse(req.responseText);
                        let address = datos.address || {};
                        let city = address.city || address.town || address.village;
                        let county = address.county;
                        let state = address.state;
                        let full = city ? city : state ? state : county;

                        if (full === "Language not supported" && useLanguage) {
                            fetchCity(false);
                        } else {
                            callback(full || "Unknown");
                        }
                    } catch (e) {
                        console.error("Error JSON City: ", e);
                        callback("Unknown");
                    }
                } else {
                    console.error("city failed, status: " + req.status);
                    callback("Unknown");
                }
            }
        };

        req.onerror = function() { callback("Unknown"); };
        req.ontimeout = function() { callback("Unknown"); };

        req.send();
    }
    fetchCity(true);
}
