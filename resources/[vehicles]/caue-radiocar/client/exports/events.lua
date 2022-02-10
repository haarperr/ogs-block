function onPlayStart(name, delegate)
    if Config.UseExternalxSound then
        exports["xsound"]:onPlayStart(name, delegate)
        return
    end
    globalOptionsCache[name].onPlayStart = delegate
end

function onPlayEnd(name, delegate)
    if Config.UseExternalxSound then
        exports["xsound"]:onPlayEnd(name, delegate)
        return
    end
    globalOptionsCache[name].onPlayEnd = delegate
end

function onLoading(name, delegate)
    if Config.UseExternalxSound then
        exports["xsound"]:onLoading(name, delegate)
        return
    end
    globalOptionsCache[name].onLoading = delegate
end

function onPlayPause(name, delegate)
    if Config.UseExternalxSound then
        exports["xsound"]:onPlayPause(name, delegate)
        return
    end
    globalOptionsCache[name].onPlayPause = delegate
end

function onPlayResume(name, delegate)
    if Config.UseExternalxSound then
        exports["xsound"]:onPlayResume(name, delegate)
        return
    end
    globalOptionsCache[name].onPlayResume = delegate
end