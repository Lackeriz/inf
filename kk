task.wait(20)
local replicatedStorage = game:GetService('ReplicatedStorage')
local workspace = game:GetService('Workspace')
local players = game:GetService('Players')
local player = players.LocalPlayer or players.PlayerAdded:Wait()
local teleportService = game:GetService('TeleportService')
local consts = require(replicatedStorage:WaitForChild('Safes'):WaitForChild('SafesConsts'))

player.PlayerGui:WaitForChild('TeamSelectGui', 5)
require(replicatedStorage.TeamSelect.TeamChooseUI).Hide()

if not player.Character then player.CharacterAdded:Wait() end
player.Character:WaitForChild('HumanoidRootPart')
task.wait(0.3)

local function TP()
    player.Character:PivotTo(CFrame.new(938, 22, -1198))
    if player.Character:FindFirstChild('Head') then player.Character.Head:Destroy() end
end

repeat task.wait() TP() until workspace:FindFirstChild('HomeHilltop')
local owner = workspace.HomeHilltop:GetAttribute('HomeOwnerId')
workspace:WaitForChild('HomeHilltop'):GetAttributeChangedSignal('HomeOwnerId'):Connect(function() owner = workspace.HomeHilltop:GetAttribute('HomeOwnerId') end)

workspace.HomeHilltop:WaitForChild('HomeClaim')
repeat TP() workspace.HomeHilltop.HomeClaim:FireServer() task.wait() until owner

if owner ~= player.UserId then teleportService:Teleport(game.PlaceId, player) return end
local store = require(replicatedStorage:WaitForChild('App'):WaitForChild('store'))
local appUI = player.PlayerGui.AppUI
local function CheckSafe()
    if appUI and appUI:FindFirstChild('RewardSpinner') then
        local rarity = store._state.rewardSpinnerConfig.items[store._state.rewardSpinnerConfig.winIndex].rarityIndex
        if rarity == 5 then
            task.wait(0.1)
            workspace.HomeHilltop.SetSavedSettingRemote:FireServer('entryAllowCrew', true)
            task.wait(8)
            teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            task.wait(999)
        end
    end
end

workspace.HomeHilltop.SetSavedSettingRemote:FireServer('entryAllowCrew', Vector3.new(0,0,0))
local cash = player:WaitForChild('leaderstats'):WaitForChild('Money').Value

local safes = 0
for _, safe in pairs(store._state.safesInventoryItems) do if safe.typeEnum == 5 then safes += 1 end end

for _ = 1, 5 - safes do
    if cash < 100000 then break end
    replicatedStorage[consts.SAFE_PURCHASE_REMOTE_NAME]:FireServer(5)
    cash -= 100000
end

task.wait(0.7)
local safesOpened = 0
for _, safe in pairs(store._state.safesInventoryItems) do
    if safe.typeEnum ~= 5 then continue end
    replicatedStorage[consts.SAFE_OPEN_REMOTE_NAME]:FireServer(safe.itemOwnedId)
    task.wait(1)
    CheckSafe()
    repeat task.wait() until not appUI:FindFirstChild('RewardSpinner')
    safesOpened += 1
    if safesOpened == 5 then break end
end

teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
