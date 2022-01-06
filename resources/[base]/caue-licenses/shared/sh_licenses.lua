LICENSES = {
    ["driver"] = {
        ["name"] = "Drivers License",
        ["default"] = 0,
    },
    ["weapon"] = {
        ["name"] = "Guns License",
        ["default"] = 0,
    },
}

--[[

    Functions

]]

function licenseName(license)
    if LICENSES[license] then
        return LICENSES[license]["name"]
    else
        return "ERROR"
    end
end


--[[

    Exports

]]

exports("licenseName", licenseName)