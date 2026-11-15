-- Client entry: first-person camera, HUD, fists, ghost animation, effects, input, shop, plane crash.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local Client = script.Parent:WaitForChild("Client")

lp.CameraMode = Enum.CameraMode.LockFirstPerson
workspace.CurrentCamera.FieldOfView = 74
local Remotes = RS:WaitForChild("Remotes")

local HUD = require(Client.HUD)
local VM = require(Client.Viewmodel)
local GA = require(Client.GhostAnim)
local Fx = require(Client.Fx)
local Input = require(Client.Input)
local Shop = require(Client.ShopUI)
local PlaneFx = require(Client.PlaneFx)

HUD.init()
VM.init()
GA.init()
Fx.init()
Input.init()
PlaneFx.init(Fx)
Shop.init(function(open)
	Input.setShopOpen(open)
	lp.CameraMode = open and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
end)

Remotes.Fx.OnClientEvent:Connect(function(kind: string, ...)
	if kind == "OpenShop" then
		Shop.open()
	elseif kind == "BuyResult" then
		Shop.result(...)
	elseif kind == "PlaneCrash" then
		PlaneFx.crash(...)
	elseif kind == "PlaneImpact" then
		PlaneFx.impact(...)
	else
		Fx.handle(kind, ...)
	end
end)
