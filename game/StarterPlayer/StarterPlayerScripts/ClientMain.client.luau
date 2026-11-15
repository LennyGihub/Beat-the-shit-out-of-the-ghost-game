-- Client entry: first-person camera, HUD, fists, ghost animation, effects, input, ultimate shop, plane crash.
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
local UltShop = require(Client.UltShopUI)
local PlaneFx = require(Client.PlaneFx)

HUD.init()
VM.init()
GA.init()
Fx.init()
Input.init()
PlaneFx.init(Fx)
UltShop.init(function(open)
	Input.setShopOpen(open)
	lp.CameraMode = open and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
end)

Remotes.Fx.OnClientEvent:Connect(function(kind: string, ...)
	if kind == "OpenUltShop" then
		UltShop.open()
	elseif kind == "UltResult" then
		UltShop.result(...)
	elseif kind == "PlaneCrash" then
		PlaneFx.crash(...)
	elseif kind == "PlaneImpact" then
		PlaneFx.impact(...)
	else
		Fx.handle(kind, ...)
	end
end)
