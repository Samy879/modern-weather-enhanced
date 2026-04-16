// GetWeather.js
function fetchAllWeather(lat, lon, tempUnit, callback) {
    let unitParam = (tempUnit === "1") ? "&temperature_unit=fahrenheit" : "";
    // Ajout de apparent_temperature, relative_humidity_2m et uv_index dans la section "current"
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}${unitParam}&current=temperature_2m,apparent_temperature,relative_humidity_2m,is_day,weather_code,wind_speed_10m,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset&timezone=auto`;

    let req = new XMLHttpRequest();
    req.open("GET", url, true);
    req.onreadystatechange = function () {
        if (req.readyState === 4 && req.status === 200) {
            callback(JSON.parse(req.responseText));
        }
    };
    req.send();
}
