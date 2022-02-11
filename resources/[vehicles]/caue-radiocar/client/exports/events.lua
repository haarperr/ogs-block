function onPlayStart(name, delegate)
    globalOptionsCache[name].onPlayStart = delegate
end

function onPlayEnd(name, delegate)
    globalOptionsCache[name].onPlayEnd = delegate
end

function onLoading(name, delegate)
    globalOptionsCache[name].onLoading = delegate
end

function onPlayPause(name, delegate)
    globalOptionsCache[name].onPlayPause = delegate
end

function onPlayResume(name, delegate)
    globalOptionsCache[name].onPlayResume = delegate
end