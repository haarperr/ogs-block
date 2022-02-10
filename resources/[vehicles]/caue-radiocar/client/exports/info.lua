soundInfo = {}

function getLink(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:getLink(name_)
    end
    return soundInfo[name_].url
end

function getPosition(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:getPosition(name_)
    end
    return soundInfo[name_].position
end

function isLooped(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:isLooped(name_)
    end
    return soundInfo[name_].loop
end

function getInfo(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:getInfo(name_)
    end
    return soundInfo[name_]
end

function soundExists(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:soundExists(name_)
    end
    if soundInfo[name_] == nil then
        return false
    end
    return true
end

function isPlaying(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:isPlaying(name_)
    end
    return soundInfo[name_].playing
end

function isPaused(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:isPaused(name_)
    end
    return soundInfo[name_].paused
end

function getDistance(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:getDistance(name_)
    end
    return soundInfo[name_].distance
end

function getVolume(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:getVolume(name_)
    end
    return soundInfo[name_].volume
end

function isDynamic(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:isDynamic(name_)
    end
    return soundInfo[name_].isDynamic
end

function getTimeStamp(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:getTimeStamp(name_)
    end
    return soundInfo[name_].timeStamp or -1
end

function getMaxDuration(name_)
    if Config.UseExternalxSound then
        return exports["xsound"]:getMaxDuration(name_)
    end
    return soundInfo[name_].maxDuration or -1
end

function isPlayerInStreamerMode()
    if Config.UseExternalxSound then
        return exports["xsound"]:isPlayerInStreamerMode()
    end
    return disableMusic
end

function getAllAudioInfo()
    if Config.UseExternalxSound then
        return exports["xsound"]:getAllAudioInfo()
    end
    return soundInfo
end

function isPlayerCloseToAnySound()
    if Config.UseExternalxSound then
        return exports["xsound"]:isPlayerCloseToAnySound()
    end
    return isPlayerCloseToMusic
end