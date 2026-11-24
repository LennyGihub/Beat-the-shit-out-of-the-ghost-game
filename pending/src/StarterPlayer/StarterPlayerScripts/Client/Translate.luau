--!strict
-- TRANSLATIONS (2026-11-24, the business guide: Roblox's players are more and more outside the US - Asia-Pacific is
-- 29.5% of them). Fixed UI text is translated by Roblox itself (Creator Hub > Localization: automatic text capture +
-- automatic translation; every TextLabel has AutoLocalize on). What Roblox can't do alone is text built from numbers
-- and names ("NEXT GHOST IN 12", "+$350 CASH"): every value would be a different string. This helper turns the
-- numbers into {1}, {2}... ("NEXT GHOST IN {1}"), translates that PATTERN through the player's Translator
-- (LocalizationService:GetTranslatorForPlayerAsync, in pcall) and puts the numbers back.
--   Translate.t(text)    a fixed text
--   Translate.auto(text) a text with numbers in it (most toasts, the objective line, the jars tutorial)
-- English players skip all of it. A pattern only translates once it is in the game's localization table: in Studio
-- every pattern asked for is kept in the player attribute I18nPatterns (JSON list) so a test session can export them
-- (tools/localization/README.md) and the CSV can be uploaded in Creator Hub > Localization.
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local T = {}
local lp = Players.LocalPlayer
local STUDIO = RunService:IsStudio()

local translator: Translator? = nil
local english = true -- (until the translator says otherwise: nothing to do)
local cache: { [string]: string } = {}
local nCache = 0
local seen: { [string]: boolean } = {}
local seenList: { string } = {}

local function remember(pattern: string)
	if not STUDIO or seen[pattern] or #seenList >= 600 then return end
	seen[pattern] = true
	table.insert(seenList, pattern)
	lp:SetAttribute("I18nPatterns", HttpService:JSONEncode(seenList))
end

local function lookup(s: string): string
	local tr = translator
	if not tr then return s end
	local ok, out = pcall(function() return tr:Translate(game, s) end)
	if ok and type(out) == "string" and out ~= "" then return out end
	return s
end

local function store(k: string, v: string)
	if nCache > 800 then table.clear(cache); nCache = 0 end
	if cache[k] == nil then nCache += 1 end
	cache[k] = v
end

function T.t(s: string): string
	if type(s) ~= "string" or s == "" then return s end
	if STUDIO then remember(s) end
	if english then return s end
	local c = cache[s]
	if c then return c end
	local out = lookup(s)
	store(s, out)
	return out
end

function T.auto(s: string): string
	if type(s) ~= "string" or s == "" then return s end
	if english and not STUDIO then return s end
	local c = cache[s]
	if c then return c end
	local vals = {}
	local pattern = string.gsub(s, "%d[%d,%.]*", function(num: string)
		table.insert(vals, num)
		return "{" .. #vals .. "}"
	end)
	remember(pattern)
	if english then return s end
	local out = #vals == 0 and lookup(s) or string.gsub(lookup(pattern), "{(%d+)}", function(i: string)
		return vals[tonumber(i) :: number] or ""
	end)
	store(s, out)
	return out
end

function T.init()
	task.spawn(function()
		local ok, tr = pcall(function() return LocalizationService:GetTranslatorForPlayerAsync(lp) end)
		if ok and tr then
			translator = tr
			english = string.sub(string.lower(tr.LocaleId), 1, 2) == "en"
			table.clear(cache); nCache = 0
		end
	end)
end

return T
