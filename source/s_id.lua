local isNDCoreInstalled = GetResourceState("ND_Core") == "started"

if isNDCoreInstalled then
    RegisterCommand("showid", function(source, args, rawCommand)
        local playerId = source
        local player = NDCore.getPlayer(playerId)
    
        if player then
            local fullName = player.getData("firstname") .. " " .. player.getData("lastname")
            local dob = player.getData("dob")
            local gender = player.getData("gender")
            local job = player.getData("job") -- You may need to fetch job data from another table if applicable
    
            -- Fetch driver's license data
            local driversLicense = player.getData("driverslicense")
    
            -- Trigger event to display ID
            TriggerEvent("showid:display", playerId, fullName, dob, gender, job, driversLicense)
        else
            print("Player not found.")
        end
    end, false)   
else
    -- Use the QBCore version
    RegisterCommand("showid", function(source, args, rawCommand)
        local playerId = source
        local player = QBCore.Functions.GetPlayer(playerId)

        if player then
            local fullName = player.PlayerData.metadata["fullname"] or "N/A"
            local dob = player.PlayerData.metadata["dob"] or "N/A"
            local gender = player.PlayerData.metadata["gender"] or "N/A"
            local job = player.PlayerData.job.name or "N/A"
            local driversLicense = player.PlayerData.metadata["driverslicense"] == 1 and "Yes" or "No" -- Convert to Yes/No format

            TriggerEvent("showid:display", playerId, fullName, dob, gender, job, driversLicense)
        else
            print("Player not found.")
        end
    end, false)
end

RegisterNetEvent("showid:display")
AddEventHandler("showid:display", function(playerId, fullName, dob, gender, job, driversLicense)
    print("showid:display event triggered for player ID: " .. tostring(playerId))
    local imageUrl = "https://cdn.discordapp.com/attachments/1213681910899810364/1220174289941303447/25b693_e59a57ddc9d04e9187a2409f8af7c652.jpg?ex=660dfadc&is=65fb85dc&hm=e9a7dc0a96eb8792d316db2fdfbc9b3e258ca1a6544695fe075eda74a1ca2630&"  -- Replace with the actual URL
    local assignedTag = "[" .. "Dispatch" .. "]"
    local bubbleData = {
        { label = "Full Name: ", value = fullName },
        { label = "Date of Birth: ", value = dob },
        { label = "Gender: ", value = gender },
        { label = "Job: ", value = job },
        { label = "Drivers License: ", value = driversLicense }
    }
    local chatBubbles = {}

    for _, data in ipairs(bubbleData) do
        table.insert(chatBubbles, formatChatBubble(imageUrl, assignedTag, data.label, data.value))
    end

    sendChatBubbles(playerId, chatBubbles)
end)

function formatChatBubble(imageUrl, label, tag, value)
    return string.format('<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.8); border-radius: 10px; max-width: 80vw; overflow-wrap: break-word; word-wrap: break-word; word-break: break-all;"><img src="%s" style="width: 30px; height: 30px; vertical-align: middle;"> <b>%s</b> %s %s</div>', imageUrl, label, tag, value)
end

function sendChatBubbles(playerId, chatBubbles)
    local posX, posY, posZ = table.unpack(GetEntityCoords(GetPlayerPed(playerId)))
    local radius = Config.CommandRadius or 10.0
    for _, targetPlayer in ipairs(GetPlayers()) do
        local targetPos = GetEntityCoords(GetPlayerPed(targetPlayer))
        local distance = #(vector3(posX, posY, posZ) - targetPos)

        if distance <= radius then
            for _, chatBubble in ipairs(chatBubbles) do
                TriggerClientEvent('chat:addMessage', targetPlayer, { template = chatBubble, args = { "", "" } })
            end
        end
    end
end
