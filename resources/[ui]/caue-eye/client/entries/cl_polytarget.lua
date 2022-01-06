local Entries = {}

Entries[#Entries + 1] = {
    type = "polytarget",
    group = { "bar:grabDrink" },
    data = {
        {
            id = "bar:grabDrink",
            label = "Grab Drink",
            icon = "cocktail",
            event = "np-stripclub:peekAction",
            parameters = { action = "grabDrink" }
        }
    },
    options = {
        distance = { radius = 2.0 }
    }
}

Entries[#Entries + 1] = {
    type = "polytarget",
    group = { "bar:openFridge" },
    data = {
        {
            id = "bar:openFridge",
            label = "Open Fridge",
            icon = "circle",
            event = "np-stripclub:peekAction",
            parameters = { action = "openFridge" }
        }
    },
    options = {
        distance = { radius = 1.5 }
    }
}

Entries[#Entries + 1] = {
    type = "polytarget",
    group = { "townhall:gavel" },
    data = {
        {
            id = "townhall:gavel",
            label = "Use Gavel",
            icon = "circle",
            event = "np-gov:gavel",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 1.5 }
    }
}

Entries[#Entries + 1] = {
    type = "polytarget",
    group = { "job_sign_in" },
    data = {
        {
            id = "job_sign_in",
            label = "Duty Action",
            icon = "circle",
            event = "caue-signin:peekAction",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 1.5 }
    }
}

Entries[#Entries + 1] = {
    type = "polytarget",
    group = { "prison_services" },
    data = {
        {
            id = "prison_services",
            label = "Prison Services",
            icon = "circle",
            event = "np-jailbreak:services",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 1.5 }
    }
}

Citizen.CreateThread(function()
    for _, entry in ipairs(Entries) do
        if entry.type == "flag" then
            AddPeekEntryByFlag(entry.group, entry.data, entry.options)
        elseif entry.type == "model" then
            AddPeekEntryByModel(entry.group, entry.data, entry.options)
        elseif entry.type == "entity" then
            AddPeekEntryByEntityType(entry.group, entry.data, entry.options)
        elseif entry.type == "polytarget" then
            AddPeekEntryByPolyTarget(entry.group, entry.data, entry.options)
        end
    end
end)