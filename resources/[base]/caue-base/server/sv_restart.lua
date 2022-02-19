--[[

    Functions

]]

function kickAllPlayers()
    local players = GetPlayers()
    for i, v in ipairs(players) do
        DropPlayer(v, "Servidor Reiniciando...")
    end
end

function restartServer()
    TriggerClientEvent("chatMessage", -1, "SISTEMA: ", {255, 0, 0}, "O servidor vai reiniciar em 10 minutos!")
    Citizen.Wait(300000)
    TriggerClientEvent("chatMessage", -1, "SISTEMA: ", {255, 0, 0}, "O servidor vai reiniciar em 5 minutos!")
    Citizen.Wait(60000)
    TriggerClientEvent("chatMessage", -1, "SISTEMA: ", {255, 0, 0}, "O servidor vai reiniciar em 4 minutos!")
    Citizen.Wait(60000)
    TriggerClientEvent("chatMessage", -1, "SISTEMA: ", {255, 0, 0}, "O servidor vai reiniciar em 3 minutos!")
    Citizen.Wait(60000)
    TriggerClientEvent("chatMessage", -1, "SISTEMA: ", {255, 0, 0}, "O servidor vai reiniciar em 2 minutos!")
    Citizen.Wait(60000)
    TriggerClientEvent("chatMessage", -1, "SISTEMA: ", {255, 0, 0}, "O servidor vai reiniciar em 1 minutos!")
    Citizen.Wait(60000)

    kickAllPlayers()
    Citizen.Wait(1000)
    io.popen("start START.bat")
    Citizen.Wait(300)
    os.exit()
end

function gitPull()
    io.popen("start GITPULL.bat")
end

--[[

    Threads

]]

Citizen.CreateThread(function()
    Citizen.Wait(90000)

    TriggerEvent("cron:runAt", 11, 30, gitPull)
    TriggerEvent("cron:runAt", 11, 50, restartServer)
    TriggerEvent("cron:runAt", 23, 30, gitPull)
    TriggerEvent("cron:runAt", 23, 50, restartServer)
end)