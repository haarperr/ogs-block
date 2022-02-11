soundInfo = {}

function getLink(name_)
    return soundInfo[name_].url
end

function getPosition(name_)
    return soundInfo[name_].position
end

function isLooped(name_)
    return soundInfo[name_].loop
end

function getInfo(name_)
    return soundInfo[name_]
end

function soundExists(name_)
    if soundInfo[name_] == nil then
        return false
    end
    return true
end

function isPlaying(name_)
    return soundInfo[name_].playing
end

function isPaused(name_)
    return soundInfo[name_].paused
end

function getDistance(name_)
    return soundInfo[name_].distance
end

function getVolume(name_)
    return soundInfo[name_].volume
end

function isDynamic(name_)
    return soundInfo[name_].isDynamic
end

function getTimeStamp(name_)
    return soundInfo[name_].timeStamp or -1
end

function getMaxDuration(name_)
    return soundInfo[name_].maxDuration or -1
end

function isPlayerInStreamerMode()
    return disableMusic
end

function getAllAudioInfo()
    return soundInfo
end

function isPlayerCloseToAnySound()
    return isPlayerCloseToMusic
end