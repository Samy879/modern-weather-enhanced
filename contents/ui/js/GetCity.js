function getNameCity(latitude, longitud, leng, callback) {
    function fetchCity(useLanguage) {
        let url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitud}`;
        if (useLanguage) {
            url += `&accept-language=${leng}`;
        }

        console.log("Generated URL: ", url);

        let req = new XMLHttpRequest();
        req.open("GET", url, true);

        // AJOUT : Nominatim exige un User-Agent pour éviter le blocage 403
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

                        console.log("Parsed location:", full);

                        if (full === "Language not supported" && useLanguage) {
                            fetchCity(false);
                        } else {
                            callback(full || "Unknown");
                        }
                    } catch (e) {
                        console.error("Error al analizar la respuesta JSON: ", e);
                    }
                } else {
                    console.error("city failed, status: " + req.status);
                }
            }
        };
        req.send();
    }
    fetchCity(true);
}
