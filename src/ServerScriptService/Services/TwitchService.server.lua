local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local provuser = "cheekyvisuals"
local URL = "https://api.twitch.tv/helix/streams?user_login=" .. tostring(provuser)
local response
local client_id_header = {
    ["Client-ID"] = "2fe4i8xaffgu5x0ftk8w20tgl8t00i",
    ["Client-SECRET"] = "2kqn0fvmfsg87b34agn3u4j3mup23i"
}
local livestreaming
local name
local views
local title
local game_id
local catName
function GetNewValues()
    local resp
    resp = HttpService:PostAsync("https://id.twitch.tv/oauth2/token?client_id=" .. tostring(client_id_header["Client-ID"]) .. "&client_secret="  .. tostring(client_id_header["Client-SECRET"]) .. "&grant_type=client_credentials", HttpService:JSONEncode({})) -- geting the oauth token documentation is bloody shite
    local access_token = (HttpService:JSONDecode(resp)["access_token"])
    
    client_id_header["authorization"] = "Bearer " .. tostring(access_token) -- twitch are reatrded you have to put bearer b4 it
    response = HttpService:GetAsync(URL, true, client_id_header)
    response = game:GetService("HttpService"):JSONDecode(response)
    for i,v in pairs(response["data"]) do
        for i2, v2 in pairs(v) do
            if i2 == "type" then
                livestreaming = v2
            elseif i2 == "user_name" then
                name = v2
            elseif i2 == "title" then
                title = v2
            elseif i2 == "game_id" then
                game_id = v2
            elseif i2 == "viewer_count" then
                views = v2
            end
        end
    end
end


local uiComponents = game.ReplicatedStorage:WaitForChild("UIComponents")
local uiEvents = uiComponents:WaitForChild("UIEvents")

local twitchEvent = uiEvents:WaitForChild("TwitchLive")
local checkTwitch = game.ReplicatedStorage.Events:WaitForChild("CheckTwitch")
local playersSeenNotification = {}

game.Players.PlayerAdded:Connect(function(plr)
    print("e")
    GetNewValues()
    if livestreaming == "live" then
        twitchEvent:FireClient(plr)
        table.insert(playersSeenNotification, plr)
    end
end)

checkTwitch.Event:Connect(function(plr)
    GetNewValues()
    if livestreaming == "live" then
        if not table.find(playersSeenNotification, plr) then
            twitchEvent:FireClient(plr)
            table.insert(playersSeenNotification, plr)
        end
    end
end)