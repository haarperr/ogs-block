--[[

    Variables

]]

local pi = math.pi
local sin = math.sin
local cos = math.cos
local abs = math.abs

local function rgb(r, g, b)
    return { r = r, g = g, b = b, alpha = 255 }
end

colors = {
    ["red"] = rgb(255, 0, 0),
    ["yellow"] = rgb(255, 255, 0),
    ["green"] = rgb(0, 255, 0),
    ["blue"] = rgb(0, 0, 255),
    ["white"] = rgb(255, 255, 255),
    ["purple"] = rgb(128, 0, 128),
}

--[[

    Functions

]]

local function RotationToDirection(rotation)
    local piDivBy180 = pi / 180

    local adjustedRotation = vector3(
        piDivBy180 * rotation.x,
        piDivBy180 * rotation.y,
        piDivBy180 * rotation.z
    )

    local direction = vector3(
        -sin(adjustedRotation.z) * abs(cos(adjustedRotation.x)),
        cos(adjustedRotation.z) * abs(cos(adjustedRotation.x)),
        sin(adjustedRotation.x)
    )

    return direction
end

function DrawText3D(x, y, z, text, c)
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoord())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))

    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 70

    if onScreen then
        -- Formalize the text
        local color = colors[c] or colors.white
        SetTextColour(color.r, color.g, color.b, color.alpha)
        SetTextScale(0.0 * scale, 0.50 * scale)
        SetTextFont(0)

        -- SetTextProportional(1)
        SetTextCentre(true)
        SetTextDropshadow(1, 0, 0, 0, 255)

        -- Diplay the text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)

        -- Calculate width and height
        BeginTextCommandWidth("STRING")
        local height = GetTextScaleHeight(1*scale, 0) - 0.005
        local width = EndTextCommandGetWidth(text)
        local length = string.len(text)
        local factor = (length * .005) + .05
        DrawRect(_x, (_y+scale/45) - 0.002, (factor *scale) + .001, height, 0, 0, 0, 100)
    end
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)

    local destination = vector3(
        cameraCoord.x + direction.x * distance,
        cameraCoord.y + direction.y * distance,
        cameraCoord.z + direction.z * distance
    )

    local ray = StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 17, -1, 0)
    local rayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)

    return hit, endCoords, entityHit, surfaceNormal
end

function DrawSphere(pos, radius, r, g, b, a)
    DrawMarker(28, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, radius, r, g, b, a, false, false, 2, nil, nil, false)
end