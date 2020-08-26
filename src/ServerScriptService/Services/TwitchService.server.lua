local HttpService = game:GetService("HttpService")
local provuser = "cheekyvisuals"
local URL = "https://api.twitch.tv/helix/streams?user_login=" .. tostring(provuser)
local response
local client_id_header = {
    ["Client-ID"] = "gmr2upwb02k5i8qulff7p4c4fekomu",
    ["Client-SECRET"] = "su4e5u1poepne2wex5ejs2xbwryxo6"
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

local URLCat = "https://api.twitch.tv/helix/games?id=" .. tostring(game_id) -- gets cat name from game id
local responseCat
responseCat = HttpService:GetAsync(URLCat, true, client_id_header)
responseCat = game:GetService("HttpService"):JSONDecode(responseCat)
for i,v in pairs(responseCat["data"]) do
    for i2, v2 in pairs(v) do
        if i2 == "name" then
        
            catName = v2
        end
    end
end
print(catName)

while wait(60) do
    GetNewValues()
    if livestreaming then
        print("CheekyVisuals is currently live on Twitch working on Noir! Check him out at twitch.tv/CheekyVisuals for exclusive codes!")
        wait(240)
        if livestreaming then
            print("CheekyVisuals is currently live on Twitch working on Noir! Check him out at twitch.tv/CheekyVisuals for exclusive codes!")
        end
    end
end
