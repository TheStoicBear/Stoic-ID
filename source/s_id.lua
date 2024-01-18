RegisterCommand("showid", function(source, args, rawCommand)
    local playerId = source
    local player = NDCore.getPlayer(playerId)

    if player then
        local fullName = player.getData("fullname") or "N/A"
        local dob = player.getData("dob") or "N/A"
        local gender = player.getData("gender") or "N/A"
        local job = player.getData("job") or "N/A"

        print("Player data retrieved - Full Name: " .. fullName .. ", DOB: " .. dob .. ", Gender: " .. gender .. ", Job: " .. job)

        TriggerEvent("showid:display", playerId, fullName, dob, gender, job)
    else
        print("Player not found.")
    end
end, false)

RegisterNetEvent("showid:display")
AddEventHandler("showid:display", function(playerId, fullName, dob, gender, job)
    print("showid:display event triggered for player ID: " .. tostring(playerId))

    local imageUrl = "https://i.imgur.com/adrNj4A.png"  -- Replace with the actual URL
    local assignedTag = "[" .. "Dispatch" .. "]"

    local bubbleData = {
        { label = "Full Name: ", value = fullName },
        { label = "Date of Birth: ", value = dob },
        { label = "Gender: ", value = gender },
        { label = "Job: ", value = job }
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
    print("Sending nearby chat bubbles to all players")

    local posX, posY, posZ = table.unpack(GetEntityCoords(GetPlayerPed(playerId)))
    local radius = 10.0

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
