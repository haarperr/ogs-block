function Distance(name_, distance_)
    SendNUIMessage({
        type = "distance",
        name = name_,
        distance = distance_,
    })
    soundInfo[name_].distance = distance_
end

function Position(name_, pos)
    SendNUIMessage({
        type = "soundPosition",
        name = name_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
    })
    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
end

function Destroy(name_)
    SendNUIMessage({
        type = "delete",
        name = name_
    })
    soundInfo[name_] = nil

    if globalOptionsCache[name_] ~= nil and globalOptionsCache[name_].onPlayEnd ~= nil then
        globalOptionsCache[name_].onPlayEnd(getInfo(name_))
    end

    globalOptionsCache[name_] = nil
end

function Resume(name_)
    SendNUIMessage({
        type = "resume",
        name = name_
    })
    soundInfo[name_].playing = true
    soundInfo[name_].paused = false

    if globalOptionsCache[name_] ~= nil and globalOptionsCache[name_].onPlayResume ~= nil then
        globalOptionsCache[name_].onPlayResume(getInfo(name_))
    end
end

function Pause(name_)
    SendNUIMessage({
        type = "pause",
        name = name_
    })
    soundInfo[name_].playing = false
    soundInfo[name_].paused = true

    if globalOptionsCache[name_] ~= nil and globalOptionsCache[name_].onPlayPause ~= nil then
        globalOptionsCache[name_].onPlayPause(getInfo(name_))
    end
end

function setVolume(name_, vol)
    SendNUIMessage({
        type = "volume",
        volume = vol,
        name = name_,
    })
    soundInfo[name_].volume = vol
end

function setVolumeMax(name_, vol)
    SendNUIMessage({
        type = "max_volume",
        volume = vol,
        name = name_,
    })
    soundInfo[name_].volume = vol
end

function setTimeStamp(name_, timestamp)
    getInfo(name_).timeStamp = timestamp
    SendNUIMessage({
        name = name_,
        type = "timestamp",
        timestamp = timestamp,
    })
end

function destroyOnFinish(id, bool)
    soundInfo[id].destroyOnFinish = bool
end

function setSoundLoop(name, value)
    SendNUIMessage({
        type = "loop",
        name = name,
        loop = value,
    })
    soundInfo[name].loop = value
end

function repeatSound(name)
    if soundExists(name) then
        SendNUIMessage({
            type = "repeat",
            name = name,
        })
    end
end

function setSoundDynamic(name, bool)
    if soundExists(name) then
        soundInfo[name].isDynamic = bool
        SendNUIMessage({
            type = "changedynamic",
            name = name,
            bool = bool,
        })
    end
end

function setSoundURL(name, url)
    if soundExists(name) then
        soundInfo[name].url = url
        SendNUIMessage({
            type = "changeurl",
            name = name,
            url = url,
        })
    end
end