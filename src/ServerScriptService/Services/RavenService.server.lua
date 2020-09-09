--[[local raven = require(game.ReplicatedStorage.Raven)
local client = raven:Client("https://7faeada2e6b54b0bb6a2124fdebaf63f:0bea4aa343eb4b8881c0d1c04c0677cf@o444471.ingest.sentry.io/5419403")

game:GetService("ScriptContext").Error:Connect(function(message, trace, script)
    client:SendMessage(
        script:GetFullName().." errored!" ..
        "Reason: "..message ..
        "Trace: "..trace
    )
end)]]