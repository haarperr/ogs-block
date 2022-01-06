--[[

    Variables

]]

local relationshipTypes = {
    "PLAYER",
    "COP",
    "MISSION2",
    "MISSION3",
    "MISSION4",
    "MISSION5",
    "MISSION6",
    "MISSION7",
    "MISSION8",
}

--[[

    Events

]]

RegisterNetEvent("caue-jobs:jobChanged")
AddEventHandler("caue-jobs:jobChanged", function(job)
    if exports["caue-jobs"]:getJob(job, "is_emergency") then
        SetPedRelationshipGroupDefaultHash(PlayerPedId(), `MISSION2`)
        SetPedRelationshipGroupHash(PlayerPedId(), `MISSION2`)
	    SetPoliceIgnorePlayer(PlayerPedId(), true)
    else
        SetPedRelationshipGroupDefaultHash(PlayerPedId(), `PLAYER`)
        SetPedRelationshipGroupHash(PlayerPedId(), `PLAYER`)
		SetPoliceIgnorePlayer(PlayerPedId(), false)
    end
end)

RegisterNetEvent("caue-ai:setDefaultRelations")
AddEventHandler("caue-ai:setDefaultRelations",function()
    Citizen.Wait(1000)

    for _, group in ipairs(relationshipTypes) do
        SetRelationshipBetweenGroups(0, `PLAYER`,GetHashKey(group))
        SetRelationshipBetweenGroups(0, GetHashKey(group), `PLAYER`)
        SetRelationshipBetweenGroups(0, `MISSION2`,GetHashKey(group))
        SetRelationshipBetweenGroups(0, GetHashKey(group), `MISSION2`)

        SetRelationshipBetweenGroups(5, GetHashKey(group), `MISSION8`)
    end

    -- mission 7 is guards at vinewood and security guards
    SetRelationshipBetweenGroups(3, `PLAYER`, `MISSION7`)
    SetRelationshipBetweenGroups(3, `MISSION7`, `PLAYER`)

    SetRelationshipBetweenGroups(0, `MISSION7`, `COP`)
    SetRelationshipBetweenGroups(0, `COP`, `MISSION7`)

    SetRelationshipBetweenGroups(0, `MISSION2`, `MISSION7`)
    SetRelationshipBetweenGroups(0, `MISSION7`, `MISSION2`)

    SetRelationshipBetweenGroups(0, `MISSION7`, `MISSION7`)

    -- players love each other even if full hatred
    SetRelationshipBetweenGroups(0, `PLAYER`, `MISSION8`)

    -- cops from scenarios love cops and ems logged in
    SetRelationshipBetweenGroups(0, `COP`, `MISSION2`)

    -- players love cops and ems
    SetRelationshipBetweenGroups(0, `PLAYER`, `MISSION2`)

    SetRelationshipBetweenGroups(0, `PLAYER`, `MISSION3`)
    SetRelationshipBetweenGroups(0, `MISSION3`,`PLAYER`)
end)

--[[

    Threads

]]

--[[

___________________________________________________________
| Relationship Group ID      | Sign Hash     | Unsign Hash|
|_________________________________________________________|
| PLAYER 	                 | 1862763509	 | 1862763509 |
| CIVMALE 	                 | 45677184	     | 45677184   |
| CIVFEMALE 	             | 1191392768	 | 1191392768 |
| COP 	                     | -1533126372	 | 2761840924 |
| SECURITY_GUARD	       	 | -183807561	 | 4111159735 |
| PRIVATE_SECURITY	   	     | -1467815081	 | 2827152215 |
| PRISONER	           	     | 2124571506	 | 2124571506 |
| FIREMAN	               	 | -64182425	 | 4230784871 |
| GANG_1	               	 | 1126561930	 | 1126561930 |
| GANG_2	               	 | 299800060	 | 299800060  |
| GANG_9	               	 | -1916596797	 | 2378370499 |
| GANG_10	               	 | 230631217	 | 230631217  |
| AMBIENT_GANG_LOST	   	     | -1865950624	 | 2429016672 |
| AMBIENT_GANG_MEXICAN	     | 296331235	 | 296331235  |
| AMBIENT_GANG_FAMILY	   	 | 1166638144	 | 1166638144 |
| AMBIENT_GANG_BALLAS	   	 | -1033021910	 | 3261945386 |
| AMBIENT_GANG_MARABUNTE	 | 2037579709	 | 2037579709 |
| AMBIENT_GANG_CULT	   	     | 2017343592	 | 2017343592 |
| AMBIENT_GANG_SALVA	   	 | -1821475077	 | 2473492219 |
| AMBIENT_GANG_WEICHENG	     | 1782292358	 | 1782292358 |
| AMBIENT_GANG_HILLBILLY	 | -1285976420	 | 3008990876 |
| DEALER	               	 | -2104069826	 | 2190897470 |
| HATES_PLAYER	       	     | -2065892691	 | 2229074605 |
| HEN	                   	 | -1072679431	 | 3222287865 |
| DOMESTIC_ANIMAL	       	 | 1928531822	 | 1928531822 |
| WILD_ANIMAL	           	 | 2078959127	 | 2078959127 |
| DEER	               	     | 837094928	 | 837094928  |
| SHARK	               	     | 580191176	 | 580191176  |
| COUGAR	               	 | -837599880	 | 3457367416 |
| NO_RELATIONSHIP	       	 | -86095805	 | 4208871491 |
| SPECIAL	               	 | -640645303	 | 3654321993 |
| MISSION2	           	     | -2143285144	 | 2151682152 |
| MISSION3	           	     | 1227432503	 | 1227432503 |
| MISSION4	           	     | 1531823744	 | 1531823744 |
| MISSION5	           	     | 654990842	 | 654990842  |
| MISSION6	           	     | 959218238	 | 959218238  |
| MISSION7	           	     | 38769797	     | 38769797   |
| MISSION8	           	     | 348830075	 | 348830075  |
| ARMY	               	     | -472287501	 | 3822679795 |
| GUARD_DOG	           	     | 1378588234	 | 1378588234 |
| AGGRESSIVE_INVESTIGATE	 | -347613984	 | 3947353312 |
| MEDIC	               	     | -1337836896	 | 2957130400 |
| CAT	                   	 | 1157867945	 | 1157867945 |
|_________________________________________________________|

]]

-- 0 = Companion
-- 1 = Respect
-- 2 = Like
-- 3 = Neutral
-- 4 = Dislike
-- 5 = Hate
-- 255 = Pedestrians

-- "AMBIENT_GANG_HILLBILLY" -- sandy shores + random trash {1813.9053955078,3780.8464355469,33.536880493164},
-- "AMBIENT_GANG_CULT" -- hillbillys with their dicks out {-1109.9310302734,4915.4189453125,217.24272155762},
-- "AMBIENT_GANG_LOST" - All lost gang members

-- "MISSION4", -- WEST
-- "MISSION5", -- CENTRAL
-- "MISSION6", -- EAST

-- "AMBIENT_GANG_FAMILY" -- Family (Green clothes near grove) {-173.74082946777,-1621.7894287109,33.628547668457},
-- "AMBIENT_GANG_BALLAS" -- Grove Stret Gangs

-- "AMBIENT_GANG_MEXICAN" -- mexican gang around {326.61358642578,-2034.1141357422,20.908306121826},
-- "AMBIENT_GANG_SALVA" || "AMBIENT_GANG_MARABUNTE" -- gang bangers in fudge lane area - east side LS {1236.2904052734,-1616.4357910156,51.829231262207},

-- "AMBIENT_GANG_WEICHENG" -- little seoul {-759.36694335938,-927.24609375,18.555536270142},

-- mission 8 is the group we set to when we want all civilians to attack them, or gangs etc.

Citizen.CreateThread(function()
    Citizen.Wait(3000)

    while true do
        Citizen.Wait(1500)

        for _, group in ipairs(relationshipTypes) do
            if group == "COP" then
                SetRelationshipBetweenGroups(3, `PLAYER`, GetHashKey(group))
                SetRelationshipBetweenGroups(3, GetHashKey(group), `PLAYER`)
                SetRelationshipBetweenGroups(0, `MISSION2`, GetHashKey(group))
                SetRelationshipBetweenGroups(0, GetHashKey(group), `MISSION2`)
            else
                SetRelationshipBetweenGroups(0, `PLAYER`, GetHashKey(group))
                SetRelationshipBetweenGroups(0, GetHashKey(group), `PLAYER`)
                SetRelationshipBetweenGroups(0, `MISSION2`, GetHashKey(group))
                SetRelationshipBetweenGroups(0, GetHashKey(group), `MISSION2`)
            end

            SetRelationshipBetweenGroups(5, GetHashKey(group), `MISSION8`)
        end

        ------------------------------------- PLAYER -------------------------------------

        -- PLAYER / FAMILY --
        if exports["caue-groups"]:GroupRank("families") > 0 then
            SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_FAMILY`)
            SetRelationshipBetweenGroups(1, `AMBIENT_GANG_FAMILY`, `PLAYER`)
        else
            SetRelationshipBetweenGroups(3, `PLAYER`, `AMBIENT_GANG_FAMILY`)
            SetRelationshipBetweenGroups(3, `AMBIENT_GANG_FAMILY`, `PLAYER`)
        end

        -- PLAYER / BALLAS --
        if exports["caue-groups"]:GroupRank("ballas") > 0 then
            SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_BALLAS`)
            SetRelationshipBetweenGroups(1, `AMBIENT_GANG_BALLAS`, `PLAYER`)
        else
            SetRelationshipBetweenGroups(3, `PLAYER`, `AMBIENT_GANG_BALLAS`)
            SetRelationshipBetweenGroups(3, `AMBIENT_GANG_BALLAS`, `PLAYER`)
        end

        -- PLAYER / VAGOS --
        if exports["caue-groups"]:GroupRank("vagos") > 0 then
            SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_MEXICAN`)
            SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MEXICAN`, `PLAYER`)
        else
            SetRelationshipBetweenGroups(3, `PLAYER`, `AMBIENT_GANG_MEXICAN`)
            SetRelationshipBetweenGroups(3, `AMBIENT_GANG_MEXICAN`, `PLAYER`)
        end

        -- PLAYER / LOST MC --
        if exports["caue-groups"]:GroupRank("lost_mc") > 0 then
            SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_LOST`)
            SetRelationshipBetweenGroups(1, `AMBIENT_GANG_LOST`, `PLAYER`)
        else
            SetRelationshipBetweenGroups(3, `PLAYER`, `AMBIENT_GANG_LOST`)
            SetRelationshipBetweenGroups(3, `AMBIENT_GANG_LOST`, `PLAYER`)
        end

        -- PLAYER / WEICHENG --
        SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_WEICHENG`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_WEICHENG`, `PLAYER`)

        -- PLAYER / MARABUNTA --
        SetRelationshipBetweenGroups(1, `PLAYER`, `AMBIENT_GANG_SALVA`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_SALVA`, `PLAYER`)

        -- PLAYER / COP --
        SetRelationshipBetweenGroups(3, `PLAYER`, `COP`)
        SetRelationshipBetweenGroups(3, `COP`,`PLAYER`)

        -- PLAYER / MISSION3 --
        SetRelationshipBetweenGroups(3, `PLAYER`, `MISSION3`)
        SetRelationshipBetweenGroups(3, `MISSION3`,`PLAYER`)

        -- PLAYER / MISSION7 --
        SetRelationshipBetweenGroups(3, `PLAYER`, `MISSION7`)
        SetRelationshipBetweenGroups(3, `MISSION7`, `PLAYER`)

        -- PLAYER / PRISONER --
        SetRelationshipBetweenGroups(3, `PLAYER`, `PRISONER`)
        SetRelationshipBetweenGroups(3, `PRISONER`, `PLAYER`)

        ------------------------------------- POLICE / EMS -------------------------------------

        -- MISSION2 / BALLAS --
        SetRelationshipBetweenGroups(3, `AMBIENT_GANG_BALLAS`, `MISSION2`)
        SetRelationshipBetweenGroups(3, `MISSION2`, `AMBIENT_GANG_BALLAS`)

        -- MISSION2 / FAMILY --
        SetRelationshipBetweenGroups(3, `AMBIENT_GANG_FAMILY`, `MISSION2`)
        SetRelationshipBetweenGroups(3, `MISSION2`, `AMBIENT_GANG_FAMILY`)

        -- MISSION2 / WEICHENG --
        SetRelationshipBetweenGroups(3, `AMBIENT_GANG_WEICHENG`, `MISSION2`)
        SetRelationshipBetweenGroups(3, `MISSION2`, `AMBIENT_GANG_WEICHENG`)

        -- MISSION2 / MARABUNTA --
        SetRelationshipBetweenGroups(3, `MISSION2`, `AMBIENT_GANG_SALVA`)
        SetRelationshipBetweenGroups(3, `AMBIENT_GANG_SALVA`, `MISSION2`)

        -- MISSION2 / VAGOS --
        SetRelationshipBetweenGroups(3, `MISSION2`, `AMBIENT_GANG_MEXICAN`)
        SetRelationshipBetweenGroups(3, `AMBIENT_GANG_MEXICAN`, `MISSION2`)

        -- MISSION2 / NORELATIONSHIP --
        SetRelationshipBetweenGroups(1, `MISSION2`, `NO_RELATIONSHIP`)
        SetRelationshipBetweenGroups(1, `NO_RELATIONSHIP`, `MISSION2`)

        -- MISSION2 / CIVMALE --
        SetRelationshipBetweenGroups(1, `MISSION2`, `CIVMALE`)
        SetRelationshipBetweenGroups(1, `CIVMALE`, `MISSION2`)

        -- MISSION2 / CIVFEMALE --
        SetRelationshipBetweenGroups(1, `MISSION2`, `CIVFEMALE`)
        SetRelationshipBetweenGroups(1, `CIVFEMALE`, `MISSION2`)

        -- MISSION2 / MISSION7 --
        SetRelationshipBetweenGroups(0, `MISSION2`, `MISSION7`)
        SetRelationshipBetweenGroups(0, `MISSION7`, `MISSION2`)

        ------------------------------------- MISC -------------------------------------

        -- COP / MISSION7 --
        SetRelationshipBetweenGroups(0, `COP`, `MISSION7`)
        SetRelationshipBetweenGroups(0, `MISSION7`, `COP`)

        -- COP / LOST MC --
        SetRelationshipBetweenGroups(3, `COP`, `AMBIENT_GANG_LOST`)
        SetRelationshipBetweenGroups(3, `AMBIENT_GANG_LOST`, `COP`)

        -- COP / PRISONER --
        SetRelationshipBetweenGroups(3, `COP`, `PRISONER`)
        SetRelationshipBetweenGroups(3, `PRISONER`, `COP`)

        -- MISSION4 / WEICHENG --
        SetRelationshipBetweenGroups(1, `MISSION4`, `AMBIENT_GANG_WEICHENG`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_WEICHENG`, `MISSION4`)

        -- MISSION5 / FAMILY --
        SetRelationshipBetweenGroups(1, `MISSION5`, `AMBIENT_GANG_FAMILY`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_FAMILY`, `MISSION5`)

        -- MISSION5 / BALLAS --
        SetRelationshipBetweenGroups(1, `MISSION5`, `AMBIENT_GANG_BALLAS`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_BALLAS`, `MISSION5`)

        -- MISSION6 / MARABUNTA --
        SetRelationshipBetweenGroups(1, `MISSION6`, `AMBIENT_GANG_SALVA`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_SALVA`, `MISSION6`)

        -- MISSION6 / VAGOS --
        SetRelationshipBetweenGroups(1, `MISSION6`, `AMBIENT_GANG_MEXICAN`)
        SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MEXICAN`, `MISSION6`)

        -- MISSION7 / MISSION7 --
        SetRelationshipBetweenGroups(0, `MISSION7`, `MISSION7`)
    end
end)