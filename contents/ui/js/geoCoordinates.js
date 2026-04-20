function obtenerCoordenadas(callback) {
    // Utilisation de FreeIPAPI (Gratuit, HTTPS supporté, sans clé API)
    let url = "https://freeipapi.com/api/json";
    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    // Timeout de 5 secondes pour éviter de bloquer le widget
    req.timeout = 5000;

    // Ajout d'un User-Agent (souvent requis pour éviter les blocages)
    req.setRequestHeader("User-Agent", "Mozilla/5.0 (Plasma Modern Weather Widget)");

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                try {
                    let datos = JSON.parse(req.responseText);
                    console.log("--- [SUCCESS] Coordonnées récupérées via FreeIPAPI");
                    callback({
                        lat: datos.latitude.toString(),
                             lon: datos.longitude.toString()
                    });
                } catch (error) {
                    console.error("Erreur JSON Coordonnées:", error);
                    callback(null);
                }
            } else {
                console.error("Erreur API Géo (Status): " + req.status);
                callback(null);
            }
        }
    };

    // Gestionnaires d'erreurs pour libérer l'état isBusy du widget
    req.onerror = function() {
        console.error("Erreur réseau lors de la géo-localisation");
        callback(null);
    };

    req.ontimeout = function() {
        console.error("Délai d'attente dépassé pour la géo-localisation");
        callback(null);
    };

    req.send();
}
