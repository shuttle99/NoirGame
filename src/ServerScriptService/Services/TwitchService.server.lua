local HttpService = game:GetService("HttpService")
local provuser = "cheekyvisuals"
local URL = "https://api.twitch.tv/helix/streams?user_login=" .. tostring(provuser)
local response
local client_id_header = {
    ["Client-ID"] = "secret"
}
local livestreaming
local name
local views
local title
local game_id
local catName
function GetNewValues()
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

GetNewValues()
print(livestreaming)
print(name)
print(views)
print(title)
print(game_id)
print(catName)
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