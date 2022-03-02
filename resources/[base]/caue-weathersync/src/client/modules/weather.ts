import { wait } from "../functions"
import { includesRain, includesSnow, overrideTime, temperatureRanges, windDirections } from "../../common/weather";
import { Weather, WeatherProgression } from "../../common/types"
import { getRandomInt, Vector3 } from "fivem-js";
import { vehicleTemp, vehicleCleaning } from "./car";

let weatherFrozen = false
let insideShell = false
let insideSpawn = false

onNet("insideShell", (inside: boolean) => {
    insideShell = inside
    emitNet("caue-weathersync:client:weather:request")
})

onNet("insideSpawn", (inside: boolean) => {
    insideSpawn = inside
    emitNet("caue-weathersync:client:weather:request")
})

export let currentWeather: WeatherProgression = {
    weather: "CLEAR",
    windSpeed: 0,
    windDir: 0,
    rainLevel: 0,
    temperature: 0
}

setImmediate(() => {
    emitNet("caue-weathersync:client:weather:request")
})

const setWeather = async (weather: WeatherProgression, skipFreeze = false): Promise<void> => {
    if (weatherFrozen && !skipFreeze) {
        return
    }

    const coords = GetEntityCoords(PlayerPedId(), false)

    if ((insideShell || insideSpawn || coords["z"] < -30) && currentWeather.weather !== "CLEAR") {
        const temperature = temperatureRanges["CLEAR"] ?? [80, 100]

        currentWeather = {
            weather: "CLEAR",
            windDir: 0,
            windSpeed: 0,
            rainLevel: -1,
            temperature: getRandomInt(temperature[0], temperature[1])
        }

        SetWeatherTypeOvertimePersist("CLEAR", 99999)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist("CLEAR")
        SetWeatherTypeNow("CLEAR")
        SetWeatherTypeNowPersist("CLEAR")

        return
    }

    if (currentWeather.weather !== weather.weather) {
        SetWeatherTypeOvertimePersist(weather.weather, overrideTime)
        emit("caue-weathersync:currentWeather", weather.weather)
        await wait(overrideTime * 1000)
        currentWeather = weather
    }

    ClearOverrideWeather()
    ClearWeatherTypePersist()

    SetWeatherTypePersist(currentWeather.weather)
    SetWeatherTypeNow(currentWeather.weather)
    SetWeatherTypeNowPersist(currentWeather.weather)
    SetForceVehicleTrails(includesSnow.includes(currentWeather.weather))
    SetForcePedFootstepsTracks(includesSnow.includes(currentWeather.weather))

    if (includesRain.includes(currentWeather.weather)) {
        SetRainFxIntensity(weather.rainLevel)
    }

    SetWindSpeed(weather.windSpeed)
    SetWindDirection(weather.windDir)
}

onNet("caue-weathersync:client:weather", async (weather: WeatherProgression) => {
    setWeather(weather)
})

setInterval(() => {
    vehicleCleaning(currentWeather)
    vehicleTemp(currentWeather)
}, 30000)

global.exports("FreezeWeather", (freeze: boolean, freezeAt?: Weather) => {
    weatherFrozen = freeze
    if (weatherFrozen && freezeAt) {
        const temperature = temperatureRanges[freezeAt] ?? [80, 100]

        setWeather({
            weather: freezeAt,
            windDir: 0,
            windSpeed: 0,
            rainLevel: -1,
            temperature: getRandomInt(temperature[0], temperature[1])
        })

        return
    }

    if (!weatherFrozen) {
        emitNet("caue-weathersync:client:weather:request")
    }
})
