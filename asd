local KEY_SERVER_VALIDATE_URL = "https://web-eight-mu-4k76n8qoag.vercel.app/api/loader"

local function ghostKeyNotify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title or "GHOST_HOOK Key"),
            Text = tostring(text or ""),
            Duration = tonumber(duration) or 3,
        })
    end)
end

local function ghostKeySave(value, path)
    if not writefile or type(path) ~= "string" then return false end
    local ok = pcall(function()
        writefile(path, tostring(value))
    end)
    return ok
end

local function ghostKeyLoad(path)
    if not isfile or not readfile or type(path) ~= "string" or not isfile(path) then
        return nil
    end

    local ok, value = pcall(readfile, path)
    if ok then
        return value
    end
    return nil
end

local function getGhostProvidedKey()
    local env = getgenv and getgenv() or nil
    return (env and (env.Key or env.script_key))
        or rawget(_G, "script_key")
        or (shared and shared.script_key)
        or rawget(_G, "Key")
        or script_key
end

local function getGhostDeviceId()
    if syn and syn.crypt and syn.crypt.hwid then
        local ok, value = pcall(syn.crypt.hwid)
        if ok and value then
            return tostring(value)
        end
    end

    local clientId = nil
    pcall(function()
        clientId = game:GetService("RbxAnalyticsService"):GetClientId()
    end)

    local executor = "executor"
    pcall(function()
        if identifyexecutor then
            executor = tostring(identifyexecutor())
        elseif getexecutorname then
            executor = tostring(getexecutorname())
        end
    end)

    if clientId and tostring(clientId) ~= "" then
        return executor .. "-" .. tostring(clientId)
    end

    local savedId = ghostKeyLoad("GhostKeyDevice")
    if savedId and tostring(savedId) ~= "" then
        return tostring(savedId)
    end

    savedId = executor .. "-" .. tostring(math.random(100000, 999999)) .. "-" .. tostring(os.time())
    ghostKeySave(savedId, "GhostKeyDevice")
    return savedId
end

local function ghostHttpRequest(requestData)
    local requester = (syn and syn.request) or http_request or request or (http and http.request)
    if requester then
        return requester(requestData)
    end

    return HttpService:RequestAsync(requestData)
end

local function validateGhostKey()
    local providedKey = getGhostProvidedKey()
    if not providedKey or tostring(providedKey) == "" then
        return false, "Missing key"
    end

    providedKey = tostring(providedKey)
    local env = getgenv and getgenv() or nil
    if env then
        env.Key = providedKey
    end

    local deviceId = getGhostDeviceId()
    local body = HttpService:JSONEncode({
        key = providedKey,
        deviceId = deviceId,
        hwid = deviceId,
        userId = LocalPlayer and tostring(LocalPlayer.UserId) or nil,
    })

    for attempt = 1, 3 do
        local ok, response = pcall(ghostHttpRequest, {
            Url = KEY_SERVER_VALIDATE_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
            },
            Body = body,
        })

        if ok and response then
            local responseBody = response.Body or response.body or ""
            local decodedOk, decoded = pcall(function()
                return HttpService:JSONDecode(responseBody)
            end)

            if decodedOk and decoded then
                if decoded.success == true then
                    return true, decoded.message or "Key validated", decoded
                end

                return false, decoded.message or decoded.error or "Key validation failed"
            end

            return false, "Invalid response from key server"
        end

        if attempt < 3 then
            task.wait(1)
        end
    end

    return false, "Could not reach key server"
end

-- ============================================================
-- USAGE / EXECUTION
-- ============================================================

local ghostKeyOk, ghostKeyMessage, ghostKeyInfo = validateGhostKey()
if not ghostKeyOk then
    ghostKeyNotify("GHOST_HOOK Key", tostring(ghostKeyMessage), 5)
    return
end

ghostKeyNotify("GHOST_HOOK Key", tostring(ghostKeyMessage), 2.5)

-- ============================================================
-- EXPIRY PARSING (for the status overlay)
-- ============================================================

local function ghostParseIsoUnix(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    if DateTime and DateTime.fromIsoDate then
        local ok, parsed = pcall(DateTime.fromIsoDate, value)
        if ok and parsed then
            return parsed.UnixTimestamp
        end
    end

    local year, month, day, hour, minute, second = value:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
    if not year then
        return nil
    end

    return os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(minute),
        sec = tonumber(second),
    })
end

local ghostKeyExpiresAtUnix = ghostKeyInfo and ghostParseIsoUnix(ghostKeyInfo.expiresAt or ghostKeyInfo.expires_at) or nil
local ghostKeyExpiresAfterHours = ghostKeyInfo and tonumber(ghostKeyInfo.expiresAfterHours or ghostKeyInfo.expires_after_hours) or nil
local ghostKeyServerOffset = 0
do
    local serverUnix = ghostKeyInfo and ghostParseIsoUnix(ghostKeyInfo.serverTime or ghostKeyInfo.server_time) or nil
    if serverUnix then
        ghostKeyServerOffset = serverUnix - os.time()
    end
end


repeat
	task["wait"]()
until game:IsLoaded()

AR2_antidetect = { disabled = 0, hooked = false }
pcall(function()
	local ScriptError = game:GetService("ScriptContext").Error
	if getconnections then
		for _, con in ipairs(getconnections(ScriptError)) do
			if pcall(con.Disable, con) then
				AR2_antidetect.disabled = AR2_antidetect.disabled + 1
			end
		end
	end
	if hookfunction then
		local oldCon
		oldCon = hookfunction(ScriptError.Connect, function(self, fn)
			if self == ScriptError then
				pcall(hookfunction, fn, function() end)
			end
			return oldCon(self, fn)
		end)
		AR2_antidetect.hooked = true
	end
end)



local __juju_origin_src = [=[

AR2_antidetect = { disabled = 0, hooked = false }
pcall(function()
    local ScriptError = game:GetService("ScriptContext").Error
    if getconnections then
        for _, con in ipairs(getconnections(ScriptError)) do
            if pcall(con.Disable, con) then AR2_antidetect.disabled = AR2_antidetect.disabled + 1 end
        end
    end
    if hookfunction then
        local oldCon
        oldCon = hookfunction(ScriptError.Connect, function(self, fn)
            if self == ScriptError then pcall(hookfunction, fn, function() end) end
            return oldCon(self, fn)
        end)
        AR2_antidetect.hooked = true
    end
end)

AR2_CAP = {
    getrawmetatable    = typeof(getrawmetatable) == "function",
    setreadonly         = typeof(setreadonly) == "function",
    isreadonly          = typeof(isreadonly) == "function",
    newcclosure         = typeof(newcclosure) == "function",
    hookfunction        = typeof(hookfunction) == "function",
    hookmetamethod      = typeof(hookmetamethod) == "function",
    checkcaller         = typeof(checkcaller) == "function",
    getnamecallmethod   = typeof(getnamecallmethod) == "function",
    getconnections      = typeof(getconnections) == "function",
    getgc               = typeof(getgc) == "function" or (debug and typeof(debug.getgc) == "function"),
    getupvalue          = debug and typeof(debug.getupvalue) == "function",
    setupvalue          = debug and typeof(debug.setupvalue) == "function",
    getinfo             = debug and typeof(debug.getinfo) == "function",
    getupvalues         = typeof(getupvalues) == "function" or (debug and typeof(debug.getupvalues) == "function"),
    islclosure          = typeof(islclosure) == "function",
    gethui              = typeof(gethui) == "function",
    mousemoverel        = typeof(mousemoverel) == "function" or (syn and typeof(syn.mousemoverel) == "function") or (Input and typeof(Input.mousemoverel) == "function"),
    writefile           = typeof(writefile) == "function",
    readfile            = typeof(readfile) == "function",
    isfile              = typeof(isfile) == "function",
    delfile             = typeof(delfile) == "function",
    listfiles           = typeof(listfiles) == "function",
    getcustomasset      = typeof(getcustomasset) == "function" or typeof(getsynasset) == "function",
    fireproximityprompt = typeof(fireproximityprompt) == "function",
    firetouchinterest   = typeof(firetouchinterest) == "function",
    setclipboard        = typeof(setclipboard) == "function" or typeof(toclipboard) == "function" or (syn and typeof(syn.write_clipboard) == "function") or typeof(writeclipboard) == "function",
}

AR2_hookLog = {}
local function AR2_logHook(name, ok, reason)
    AR2_hookLog[name] = { ok = ok, reason = reason or "" }
    if not ok then
        warn("[juju] Hook skipped: " .. name .. " (" .. (reason or "unknown") .. ")")
    end
end

do
    local missing = {}
    for k, v in pairs(AR2_CAP) do
        if not v then table.insert(missing, k) end
    end
    if #missing > 0 then
        table.sort(missing)
        warn("[juju] Unsupported on this executor: " .. table.concat(missing, ", "))
    end
end

AR2_Players              = game:GetService("Players")
AR2_Workspace            = game:GetService("Workspace")
AR2_CollectionService    = game:GetService("CollectionService")
AR2_HttpService          = game:GetService("HttpService")
AR2_RunService           = game:GetService("RunService")
AR2_UserInputService     = game:GetService("UserInputService")
AR2_Lighting             = game:GetService("Lighting")
AR2_ReplicatedStorage    = game:GetService("ReplicatedStorage")
AR2_ReplicatedFirst      = game:GetService("ReplicatedFirst")
AR2_LocalPlayer          = AR2_Players.LocalPlayer
AR2_Camera               = AR2_Workspace.CurrentCamera
AR2_SoundService         = game:GetService("SoundService")
AR2_TweenService         = game:GetService("TweenService")

AR2_writefile    = writefile
AR2_readfile     = readfile
AR2_isfile       = isfile
AR2_delfile      = delfile
AR2_listfiles    = listfiles
AR2_makefolder   = makefolder
AR2_isfolder     = isfolder
AR2_setclipboard = setclipboard or toclipboard or (syn and syn.write_clipboard) or writeclipboard
AR2_gethui       = gethui


function AR2_folder(name)
    return AR2_Workspace:FindFirstChild(name)
end

AR2_Characters = AR2_folder("Characters")
AR2_Corpses    = AR2_folder("Corpses")
AR2_Zombies    = AR2_folder("Zombies")
AR2_Vehicles   = AR2_folder("Vehicles")

task.spawn(function()
    local wanted = {
        Characters = function(f) AR2_Characters = f end,
        Corpses    = function(f) AR2_Corpses    = f end,
        Zombies    = function(f) AR2_Zombies    = f end,
        Vehicles   = function(f) AR2_Vehicles   = f end,
    }
    AR2_Workspace.ChildAdded:Connect(function(c)
        local set = wanted[c.Name]
        if set then set(c) end
    end)
end)


AR2_esp = {}; AR2_aim = {}; AR2_magicAim = {}; AR2_speed = {}
AR2_radar = {}; AR2_freeze = {}; AR2_visuals = {}; AR2_carMods = {}
AR2_car = {}; AR2_tp = {}

AR2_corpseMemory = {}
AR2_Players.PlayerRemoving:Connect(function(player)
    task.defer(function()
        local function snap(folder)
            if not folder then return end
            local model = folder:FindFirstChild(player.Name)
            if not model then return end
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
            if root then
                AR2_corpseMemory[player.Name] = { name = player.Name, position = root.Position, time = os.clock() }
            end
        end
        snap(AR2_Corpses)
        if not AR2_corpseMemory[player.Name] then snap(AR2_Characters) end
    end)
end)

AR2_ORIGIN = Vector3.zero
AR2_velocityTracker = {}


AR2_CFG = {
    players  = { on = false, box = true, name = true, tracer = false, weapon = true, dist = true, chams = true, maxDist = 2000, healthBar = true, skeleton = false },
    zombies  = { on = false, box = true, name = false, tracer = false, agro = true, dist = true, maxDist = 500, healthBar = true, skeleton = false },
    loot     = { on = false, box = false, name = true, tracer = false, chams = true, dist = true, maxDist = 1200, minRank = 0 },
    vehicles = { on = false, box = false, name = true, tracer = false, dist = true, maxDist = 1500, chams = false },
    corpses  = { on = false, box = false, name = true, tracer = false, dist = true, maxDist = 800, playersOnly = false },
    style    = { textSize = 13, boxThickness = 1, tracerThickness = 1, tracerFromBottom = true, cornerBox = true, fill = false, healthText = false },


    colors   = {
        player  = Color3.fromRGB(255, 80, 90),
        armed   = Color3.fromRGB(255, 140, 40),
        zombie  = Color3.fromRGB(150, 255, 120),
        agro    = Color3.fromRGB(255, 60, 60),
        vehicle = Color3.fromRGB(90, 200, 255),
        info    = Color3.fromRGB(220, 220, 225),
    },
    aim      = { on = false, key = "MouseButton2", part = "HeadCollider", fov = 180, smooth = 18, wallCheck = true, showFov = true, players = true, zombies = false, maxDist = 1500 },
    magicAim = {


        on = false, fov = 250, ignoreFov = false, maxDist = 1200, maxBend = 45,
        part = "Head", players = false, zombies = true, visCheck = false,
        showFov = true, showLockLine = true, autoSpeed = true, dropComp = true,
        bulletSpeed = 0, killSpread = true, originShift = true, redirectChance = 100,
        noTeammate = false,
    },
    magicBullet = { searchRadius = 10, forwardNudge = 1 },
    rageBot = {
        on = false, maxDist = 800, ignoreFov = false, inventoryShoot = false,
        requireADS = false, forceADS = false, adsMinDist = 0, fov = 250,
        panicKey = "L", glitchWarn = true,
        visCheck = false,
    },
    weapon = {
        noRecoil = false, noSpread = false, wallbang = false, allFireModes = false,
        instantReload = false, recoilReduction = 0,
        hbeOn = false, hbeSize = 10, autoReload = false, alwaysSuppressed = false,
        vehicleEquip = false,
    },
    visuals = {
        fullbright = false, nofog = false, setTime = false, brightness = 3, time = 14,
        skybox = "Default",
        cloudsEnabled = false, modifyClouds = false,
        cloudsColor = Color3.fromRGB(255,255,255), cloudsCover = 0.5, cloudsDensity = 0.5,
        colorCorrectionEnabled = false, ccSaturation = 1, ccContrast = 0.5, ccBrightness = 1,
        removeDoors    = false,
        removeSunRays  = false,
        customAmbient  = false,
        ambientIndoor  = Color3.fromRGB(127, 127, 127),
        ambientOutdoor = Color3.fromRGB(127, 127, 127),
    },
    car = {
        fuel = false, boost = false, god = false, speed = 120, torque = 3,
        allCars = false, method = "desync",
        tpDash = false, tpDashStuds = 30, tpDashInterval = 2, tpDashVert = 0,
        fly = false, flySpeed = 100,
        boatMode = false, removeDrag = false, fullSteer = false,
        maxTraction = false,
        noclipSpeed = 90,
        noclipEjectDelay = 0.15,
        noclipTPSpeed = 800,
        noclipTPVertOffset = 5,
        noclipTPMaxSeconds = 15,
    },
    tp = {
        target = "-", behind = 10, above = 0, side = 0,
        clickKey = "T", playerKey = "Y", mapKey = "L", clickLift = 0,
        everyFrame = true, intervalCs = 9, stableCs = 100, maxSeconds = 8,
        snapBack = 8, chunked = true, hopStuds = 200, holdSecs = 0, retries = 2,
        unseat = true, guard = false, guardSecs = 10, force = false, forceSecs = 8,
        underground = false, burrowDepth = 25, burrowClip = true, stayUnder = true,
        diveKey = "G", neverGiveUp = false, waypoints = {},
        clickTPOn = false, mapTPOn = false, respawnTP = false,
        mapImageId = "102357544057594",
    },
    speed = { on = false, pct = 140, collide = true, pulse = true, pulseOn = 25, pulseOff = 35, adaptive = true, minPct = 105, airborne = false, spoof = false, spoofAs = "Falling" },
    radar = {
        on = false, names = true, localToo = false, armedColor = true, weapon = false, dist = false,
        vehicles = { on = false, names = true, dist = true },
        corpses  = { on = false, names = true, dist = true },
    },
    minimap = { on = false, size = 200, x = 10, y = 50 },
    misc = {
        infJump = false, noclip = false, noclipSpeed = 90, carNoclip = false,
        bhop = false, bhopHeight = 15,
        tpDash = false, tpDashStuds = 30, tpDashInterval = 2, tpDashVert = 0,
        fovZoom = false, zoomFOV = 30, distZoomEnabled = false, distZoomActive = false,
        normalDist = 10, zoomedDist = 3,
        thirdPersonADS = {
            enabled     = false,
            offsetRight = 2.5,
            offsetUp    = 1.2,
            offsetBack  = 3.5,
            adsFOV      = 55,
            smooth      = 0.18,
        },
        removeTextures = false, removeLeaves = false, removeBushes = false,
        hidePlayer = false, hideGun = false,
        removeReticle = false, tracers = false, tracerHue = 0,
        tracerLength = 10, tracerWidth = 2, tracerRainbow = false, tracerLightning = false, tracerStyle = "Beam",
        tracerEmission = 1, tracerGlow = 6, tracerTexLength = 4, tracerTexSpeed = 1,
        tracerLife = 0.6, tracerFade = 0.35, tracerExpand = true,
        tracerExpandSpeed = 18, tracerDamper = 0.7, tracerMax = 48,
        spinOn = false, spinSpeed = 20, spinTilt = false,
        charm = false, charmMode = "Color", charmHue = 0, charmRainbow = false,
        charmGray = 50, globalCharm = false,
        globalChams = false, globalChamsHue = 0,
        freeze = false, freezeAll = false, freezeAnchor = true, freezeRadius = 300,
        hitSound = true, hitSoundVolume = 70,
        personalCharOn = false, personalCharMode = "Color",
        personalCharHue = 0, personalCharGray = 100,
        personalCharMaterial = "ForceField", personalCharRainbow = false,
        personalGunOn = false, personalGunMode = "Color",
        personalGunHue = 0, personalGunGray = 100,
        personalGunMaterial = "Neon", personalGunRainbow = false,
        cosUnlock = false,
        instantInteract = false, playerJesus = false,
        selfBacktrack = { enabled = false, color = Color3.fromRGB(255,255,255), transparency = 0.4, material = Enum.Material.ForceField, delay = 0.3 },
        jumpCircle = { enabled = false, color = Color3.new(1,1,1), startRadius = 1, endRadius = 12, duration = 1.2 },
        removeShadows = false,
        antiAim = { enabled = false, radius = 3, speed = 5, mode = "Circle" },
        zombieCircle = { enabled = false, distance = 10, speed = 5 },
        tungSelf = false, tungGlobal = false,
        fly = false,
        flySpeedPct = 300,
        antiFallStun = false,
        morphId = "", morphPreset = "Custom", morphHideSelf = false,
    },
    ui = {
        accent       = Color3.fromRGB(255, 140, 30),
        accentHue    = 30,
        background   = Color3.fromRGB(14, 14, 14),
        panel        = Color3.fromRGB(20, 20, 20),
        transparency = 0.15,
        cornerRadius = 8,
        glow         = true,
        compact      = false,
        sizePreset   = "Default",
    },
    cosmetics = {
        savedOutfits      = {},
        currentOutfit     = "",
        currentOutfitName = "My Outfit",
    },
    hitmarker = {
        enabled = false, colorHue = 0, size = 20, thickness = 3,
        gap = 6, opacity = 1, shape = "X",
        sound = "None", soundPath = "", duration = 0.3, rainbow = false,
    },
    crosshair = { enabled = false, hue = 120, size = 15, thickness = 2, gap = 5, shape = "Cross", rainbow = false },
    keybinds = {
        playerESP = "None", zombieESP = "None", lootESP = "None",
        silentAim = "None", rageBot = "L", hbe = "None",
        noSpread = "None", instantReload = "None",
        allFireModes = "None", wallbang = "None", alwaysSuppressed = "None",
        vehicleEquip = "None", boatMode = "None", removeDrag = "None",
        fullSteer = "None", antiFallStun = "None",
        hitmarker = "None", crosshair = "None", tracers = "None",
        speedHack = "None", infJump = "None", noclip = "None", spinBot = "None",
        bhop = "None", tpDash = "None", carTpDash = "None", carFly = "None",
        fly = "F", flyRecover = "None",
        freezeZombies = "None", fullbright = "None",
        antiAim = "None", zombieCircle = "None", jumpCircle = "None",
        selfBacktrack = "None", instantInteract = "None",
        playerJesus = "None",
        thirdPersonADS = "None",
        resetConfig = "None", minimizeUI = "None",
    },
}


AR2_HITSOUND_PRESETS = {
    { name = "None", path = "", id = "" },
    { name = "Hitmarker Classic", path = "", id = "160432334" },
    { name = "Hitmarker Tick", path = "", id = "705502934" },
    { name = "Hitmarker Sharp", path = "", id = "8618186140" },
    { name = "Osu Hit", path = "", id = "7147454322" },
    { name = "DBZ Sword Hit", path = "", id = "232210146" },
    { name = "Flashbang", path = "", id = "2926571220" },
    { name = "Fortnite Gun", path = "", id = "3008769599" },
    { name = "Level Up", path = "", id = "2686079706" },
    { name = "Taco Bell Bong", path = "", id = "5696182212" },
    { name = "Cartoon Bonk", path = "", id = "5682262154" },
    { name = "Bruh", path = "bruh.ogg", id = "5044897021" },
    { name = "Vine Boom", path = "vineboom.ogg", id = "6308606116" },
    { name = "Vine Boom Alt", path = "", id = "5153845714" },
    { name = "Oof Hitsound", path = "oof.ogg", id = "5943191430" },
    { name = "Official Oof", path = "", id = "5987688492" },
    { name = "Sheesh", path = "", id = "6591330256" },
    { name = "Yeah Boi", path = "", id = "610314024" },
    { name = "Za Warudo", path = "", id = "5679636294" },
    { name = "Disappointed Quack", path = "", id = "767845364" },
    { name = "Pac Man Death", path = "", id = "132366334" },
    { name = "Fart", path = "", id = "6367774932" },
    { name = "Cash Register", path = "cash.ogg", id = "" },
    { name = "Pool Ball", path = "poolball.ogg", id = "" },
    { name = "Typewriter Bell", path = "typebell.ogg", id = "" },
    { name = "Bone Crack", path = "bone.ogg", id = "" },
    { name = "XP Error", path = "xperror.ogg", id = "" },
    { name = "Bubble Pop", path = "bubble.ogg", id = "" },
    { name = "Custom...", path = "", id = "" },
}


AR2_rageBotConn     = nil
AR2_rageBotHeld     = false
AR2_reloadWatchLast = AR2_reloadWatchLast or 0
AR2_reloadWatchConn = AR2_reloadWatchConn or nil

function AR2_esp.update() end -- juju ESP owns visuals
function AR2_aim.start() end
function AR2_aim.stop() end
function AR2_magicUpdate() end
function AR2_tracersUpdate() end
function AR2_freeze.start() end
function AR2_freeze.stop() end
function AR2_visuals.apply() end
function AR2_carMods.apply() end
function AR2_radar.start() end
function AR2_radar.stop() end
function AR2_speed.start() end
function AR2_speed.stop() end
function AR2_rageBotSetEnabled() end
function AR2_toggleCharm() end
function AR2_toggleFOVZoom() end
function AR2_toggleDistZoomEnabled() end
function AR2_toggleDistanceZoom() end
function AR2_startNoclip() end
function AR2_stopNoclip() end
function AR2_startInfJump() end
function AR2_stopInfJump() end
function AR2_startBhop() end
function AR2_stopBhop() end
function AR2_startTpDash() end
function AR2_stopTpDash() end
function AR2_startCarDash() end
function AR2_stopCarDash() end
function AR2_toggleRemoveTextures() end
function AR2_toggleRemoveLeaves() end
function AR2_toggleRemoveBushes() end
function AR2_toggleHidePlayer() end
function AR2_toggleHideGun() end
function startWallbangTagging() end
function stopWallbangTagging() end
function AR2_applyAllFireModes() end
function setInstantReloadEnabled() end
function AR2_setPersonalCharacter() end
function AR2_setPersonalGun() end
function AR2_applySkybox() end
function AR2_toggleHitmarker() end
function AR2_toggleCrosshair() end
function AR2_toggleRespawnTP() end
function AR2_hbeSetEnabled() end
function AR2_cosSetEnabled() end
function AR2_setAutoReload() end
function AR2_setRemoveShadows() end
function AR2_setClouds() end
function AR2_setColorCorrection() end
function AR2_refreshUI() end
function AR2_stopAntiAim() end
function AR2_toggleAntiAim() end
function AR2_setZombieCircle() end
function AR2_setAlwaysSuppressed() end
function AR2_startFly() end
function AR2_stopFly() end
function AR2_setFly() end
function AR2_applyUITheme() end
function AR2_carFlyStop() end
function AR2_carFlySetEnabled() end
function AR2_cosRemoveAll() end
function AR2_cosSaveOutfit() return false end
function AR2_cosLoadOutfit() return false end
function AR2_cosDeleteOutfit() return false end
function AR2_cosOutfitNames() return { "(no saved outfits)" } end
function AR2_setBoatMode() end
function AR2_setRemoveDrag() end
function AR2_setFullSteer() end
function AR2_setAntiFallStun() end
function AR2_setVehicleEquip() end
function AR2_setRemoveDoors() end
function AR2_setRemoveSunRays() end
function AR2_setContainerPersist() end
function AR2_setCustomAmbient() end
function AR2_carPick() return nil end
function AR2_carConfig() return nil end
function AR2_set3pAds() end


AR2_COLORS = {
    player  = Color3.fromRGB(255, 80, 90),
    armed   = Color3.fromRGB(255, 140, 40),
    zombie  = Color3.fromRGB(150, 255, 120),
    agro    = Color3.fromRGB(255, 60, 60),
    vehicle = Color3.fromRGB(90, 200, 255),
    info    = Color3.fromRGB(220, 220, 225),
}


function AR2_applyEspColors()
    local c = AR2_CFG and AR2_CFG.colors
    if type(c) ~= "table" then return end
    for k, v in pairs(c) do
        if typeof(v) == "Color3" then AR2_COLORS[k] = v end
    end
end

AR2_SETTINGS    = { menuKey = "PageDown" }
AR2_CONFIG_FILE = "juju_hub_config_index.json"
AR2_configList  = {}


function AR2_deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do copy[k] = AR2_deepCopy(v) end
    return copy
end
AR2_DEFAULTS = { cfg = AR2_deepCopy(AR2_CFG), settings = AR2_deepCopy(AR2_SETTINGS) }

function AR2_mergeInto(target, saved)
    if type(saved) ~= "table" then return end
    for key, current in pairs(target) do
        local incoming = saved[key]
        if type(current) == "table" then
            if next(current) == nil and type(incoming) == "table" then
                for index, value in pairs(incoming) do current[index] = value end
            else
                AR2_mergeInto(current, incoming)
            end
        elseif incoming ~= nil and type(incoming) == type(current) then
            target[key] = incoming
        end
    end
end


local function AR2_basename(path)
    return tostring(path):match("[^/\\]+$") or tostring(path)
end

function AR2_refreshConfigList()
    AR2_configList = {}
    if AR2_isfile and AR2_readfile then
        local exists = false
        pcall(function() exists = AR2_isfile(AR2_CONFIG_FILE) end)
        if exists then
            local ok, raw = pcall(AR2_readfile, AR2_CONFIG_FILE)
            if ok and raw and raw ~= "" then
                local decoded, data = pcall(AR2_HttpService.JSONDecode, AR2_HttpService, raw)
                if decoded and type(data) == "table" and type(data.configs) == "table" then
                    for _, n in ipairs(data.configs) do
                        if type(n) == "string" and n ~= "" then
                            table.insert(AR2_configList, n)
                        end
                    end
                end
            end
        end
    end
    if AR2_listfiles then
        local ok, files = pcall(AR2_listfiles)
        if ok and type(files) == "table" then
            local existing = {}
            for _, n in ipairs(AR2_configList) do existing[n] = true end
            for _, file in ipairs(files) do
                local base = AR2_basename(file)
                local name = base:match("juju_hub_config_(.+)%.json$")
                if name and not existing[name] then
                    table.insert(AR2_configList, name)
                    existing[name] = true
                end
            end
        end
    end
    return AR2_configList
end


function AR2_jsonSafe(v)
    local t = typeof(v)
    if t == "Color3" then
        return { __t = "Color3", r = v.R, g = v.G, b = v.B }
    elseif t == "EnumItem" then
        return { __t = "Enum", e = tostring(v.EnumType), n = v.Name }
    elseif t == "Vector3" then
        return { __t = "Vector3", x = v.X, y = v.Y, z = v.Z }
    elseif t == "table" then
        local out = {}
        for k, vv in pairs(v) do out[k] = AR2_jsonSafe(vv) end
        return out
    end
    return v
end

function AR2_jsonRestore(v)
    if type(v) ~= "table" then return v end
    if v.__t == "Color3" then
        return Color3.new(tonumber(v.r) or 0, tonumber(v.g) or 0, tonumber(v.b) or 0)
    elseif v.__t == "Vector3" then
        return Vector3.new(tonumber(v.x) or 0, tonumber(v.y) or 0, tonumber(v.z) or 0)
    elseif v.__t == "Enum" then
        local ok, res = pcall(function()
            local et = Enum[(tostring(v.e):gsub("^Enum%.", ""))]
            return et[v.n]
        end)
        if ok and res then return res end
        return nil
    end
    local out = {}
    for k, vv in pairs(v) do out[k] = AR2_jsonRestore(vv) end
    return out
end

function AR2_saveConfig(name)
    if not AR2_writefile then
        warn("[juju] writefile is not available on this executor")
        return false
    end
    name = tostring(name):gsub("[^%w%s_-]", "")
    if name == "" then return false end
    local file = "juju_hub_config_" .. name .. ".json"
    local ok, encoded = pcall(AR2_HttpService.JSONEncode, AR2_HttpService,
        { version = 17, cfg = AR2_jsonSafe(AR2_CFG), settings = AR2_jsonSafe(AR2_SETTINGS) })
    if not ok then
        warn("[juju] JSONEncode failed: " .. tostring(encoded))
        return false
    end
    local fileOk, err = pcall(AR2_writefile, file, encoded)
    if not fileOk then
        warn("[juju] writefile failed for " .. file .. ": " .. tostring(err))
        return false
    end
    local exists = false
    for _, n in ipairs(AR2_configList) do
        if n == name then exists = true break end
    end
    if not exists then
        AR2_configList[#AR2_configList + 1] = name
    end
    local idxOk, idxEncoded = pcall(AR2_HttpService.JSONEncode, AR2_HttpService,
        { configs = AR2_configList })
    if idxOk then
        pcall(AR2_writefile, AR2_CONFIG_FILE, idxEncoded)
    end
    AR2_refreshConfigList()
    return true
end

function AR2_applyLoadedConfig()
    local success, err = pcall(function()
        AR2_applyUITheme()
        AR2_esp.update()
        if AR2_CFG.aim.on then AR2_aim.start() else AR2_aim.stop() end
        AR2_magicUpdate()
        AR2_tracersUpdate()
        if AR2_CFG.misc.freeze then AR2_freeze.start() else AR2_freeze.stop() end
        AR2_visuals.apply()
        AR2_carMods.apply()
        if AR2_CFG.radar.on then AR2_radar.start() else AR2_radar.stop() end
        if AR2_CFG.speed.on then AR2_speed.start() else AR2_speed.stop() end
        pcall(AR2_rageBotSetEnabled, AR2_CFG.rageBot.on)
        if AR2_CFG.misc.charm then AR2_toggleCharm(true) else AR2_toggleCharm(false) end
        if AR2_CFG.minimap.on then
            AR2_minimapEnabled = true
            AR2_updateMinimap()
        else
            AR2_minimapEnabled = false
            if AR2_minimapGui then AR2_minimapGui.Enabled = false end
        end
        AR2_toggleFOVZoom(AR2_CFG.misc.fovZoom)
        AR2_toggleDistZoomEnabled(AR2_CFG.misc.distZoomEnabled)
        AR2_toggleDistanceZoom(AR2_CFG.misc.distZoomActive)
        AR2_tracersEnabled = AR2_CFG.misc.tracers
        if AR2_CFG.misc.noclip then AR2_startNoclip() else AR2_stopNoclip() end
        if AR2_CFG.misc.infJump then AR2_startInfJump() else AR2_stopInfJump() end
        AR2_setSpin(AR2_CFG.misc.spinOn)
        if AR2_CFG.misc.bhop then AR2_startBhop() else AR2_stopBhop() end
        if AR2_CFG.misc.tpDash then AR2_startTpDash() else AR2_stopTpDash() end
        if AR2_CFG.car.tpDash then AR2_startCarDash() else AR2_stopCarDash() end
        if AR2_CFG.misc.fly then AR2_startFly() else AR2_stopFly() end
        AR2_set3pAds(AR2_CFG.misc.thirdPersonADS.enabled)
        AR2_toggleRemoveTextures(AR2_CFG.misc.removeTextures)
        AR2_toggleRemoveLeaves(AR2_CFG.misc.removeLeaves)
        AR2_toggleRemoveBushes(AR2_CFG.misc.removeBushes)
        AR2_toggleHidePlayer(AR2_CFG.misc.hidePlayer)
        AR2_toggleHideGun(AR2_CFG.misc.hideGun)
        if AR2_CFG.weapon.wallbang then startWallbangTagging() else stopWallbangTagging() end
        if AR2_CFG.weapon.allFireModes then AR2_applyAllFireModes(true) else AR2_applyAllFireModes(false) end
        if AR2_CFG.weapon.instantReload then setInstantReloadEnabled(true) else setInstantReloadEnabled(false) end
        AR2_setPersonalCharacter(AR2_CFG.misc.personalCharOn, AR2_CFG.misc.personalCharMode, AR2_CFG.misc.personalCharHue, AR2_CFG.misc.personalCharGray, AR2_CFG.misc.personalCharMaterial, AR2_CFG.misc.personalCharRainbow)
        AR2_setPersonalGun(AR2_CFG.misc.personalGunOn, AR2_CFG.misc.personalGunMode, AR2_CFG.misc.personalGunHue, AR2_CFG.misc.personalGunGray, AR2_CFG.misc.personalGunMaterial, AR2_CFG.misc.personalGunRainbow)
        AR2_applySkybox(AR2_CFG.visuals.skybox)
        AR2_toggleHitmarker(AR2_CFG.hitmarker.enabled)
        AR2_toggleCrosshair(AR2_CFG.crosshair.enabled)
        if AR2_CFG.tp.respawnTP then AR2_toggleRespawnTP(true) else AR2_toggleRespawnTP(false) end
        if AR2_CFG.weapon.hbeOn then AR2_hbeSetEnabled(true) else AR2_hbeSetEnabled(false) end
        if AR2_CFG.misc.cosUnlock then AR2_cosSetEnabled(true) else AR2_cosSetEnabled(false) end
        AR2_setAutoReload(AR2_CFG.weapon.autoReload)
        AR2_setInstantInteract(AR2_CFG.misc.instantInteract)
        AR2_setPlayerJesus(AR2_CFG.misc.playerJesus)
        AR2_setSelfBacktrack(AR2_CFG.misc.selfBacktrack.enabled)
        AR2_setJumpCircle(AR2_CFG.misc.jumpCircle.enabled)
        AR2_setRemoveShadows(AR2_CFG.misc.removeShadows)
        AR2_setClouds(AR2_CFG.visuals.cloudsEnabled, AR2_CFG.visuals.modifyClouds, AR2_CFG.visuals.cloudsColor, AR2_CFG.visuals.cloudsCover, AR2_CFG.visuals.cloudsDensity)
        AR2_setColorCorrection(AR2_CFG.visuals.colorCorrectionEnabled, AR2_CFG.visuals.ccSaturation, AR2_CFG.visuals.ccContrast, AR2_CFG.visuals.ccBrightness)
        AR2_toggleWorldwide(AR2_CFG.magicAim.ignoreFov)
        AR2_toggleAntiAim(AR2_CFG.misc.antiAim.enabled)
        AR2_setZombieCircle(AR2_CFG.misc.zombieCircle.enabled)
        AR2_setAlwaysSuppressed(AR2_CFG.weapon.alwaysSuppressed)
        AR2_hitSoundLoad(AR2_CFG.hitmarker.soundPath)
        AR2_applyEspColors()
        AR2_setBoatMode(AR2_CFG.car.boatMode)
        AR2_setFullSteer(AR2_CFG.car.fullSteer)
        AR2_setAntiFallStun(AR2_CFG.misc.antiFallStun)
        AR2_setVehicleEquip(AR2_CFG.weapon.vehicleEquip)
        AR2_setRemoveDoors(AR2_CFG.visuals.removeDoors)
        AR2_setRemoveSunRays(AR2_CFG.visuals.removeSunRays)
        AR2_setCustomAmbient(AR2_CFG.visuals.customAmbient)


        AR2_refreshUI()
    end)
    if not success then warn("[Config Load Error] " .. tostring(err)) end
    return success
end

function AR2_loadConfigByName(name)
    name = tostring(name)
    if name == "" then return false end
    local file = "juju_hub_config_" .. name .. ".json"
    if not (AR2_readfile and AR2_isfile) then return false end
    local present, exists = pcall(AR2_isfile, file)
    if not present or not exists then return false end
    local read, raw = pcall(AR2_readfile, file)
    if not read then return false end
    local decoded, data = pcall(AR2_HttpService.JSONDecode, AR2_HttpService, raw)
    if not decoded or type(data) ~= "table" then return false end
    AR2_mergeInto(AR2_CFG, AR2_jsonRestore(data.cfg))
    AR2_mergeInto(AR2_SETTINGS, AR2_jsonRestore(data.settings))

    return AR2_applyLoadedConfig()
end

AR2_CONFIG_FOLDER = AR2_CONFIG_FOLDER or "OriginHUB_Configs"

local function AR2_nlEncrypt(data)
    local bytes = {}
    local seed = ((#data + 3782) % 111) + 1
    string.gsub(data, ".", function(ch)
        table.insert(bytes, tostring(ch:byte() + seed))
    end)
    local out = "{" .. tostring(seed + 72667) .. "}?" .. table.concat(bytes, "?")
    table.clear(bytes)
    return out
end

local function AR2_nlDecrypt(data)
    local parts = string.split(data, "?")
    if not parts[1] then return nil end
    local seedStr = parts[1]:gsub("{", ""):gsub("}", "")
    local seed = tonumber(seedStr)
    if not seed then return nil end
    local real = seed - 72667
    local chars = {}
    for i, v in ipairs(parts) do
        if i > 1 then
            local b = tonumber(v)
            if not b then return nil end
            table.insert(chars, string.char(math.clamp(b - real, 0, 255)))
        end
    end
    local out = table.concat(chars)
    table.clear(chars)
    return out
end

local function AR2_nlB64()
    local NL = getgenv and getgenv().OriginHUB_NL or nil
    if type(NL) ~= "table" then return nil, nil end
    return NL.Base64Encode, NL.Base64Decode
end

local function AR2_nlFlags()
    local NL = getgenv and getgenv().OriginHUB_NL or nil
    if type(NL) ~= "table" or type(NL.Flags) ~= "table" then return nil end
    return NL.Flags
end

function AR2_nlConfigPath(name)
    name = tostring(name):gsub("[^%w%s_%-]", "")
    if name == "" then return nil end
    return AR2_CONFIG_FOLDER .. "/" .. name, name
end

function AR2_nlConfigList()
    local out = {}
    if not AR2_listfiles then return out end
    local ok, files = pcall(AR2_listfiles, AR2_CONFIG_FOLDER)
    if not ok or type(files) ~= "table" then return out end
    for _, path in ipairs(files) do
        local base = tostring(path):match("[^/\\]+$")
        if base and base ~= "" then table.insert(out, base) end
    end
    table.sort(out)
    return out
end

function AR2_nlConfigData()
    local flags = AR2_nlFlags()
    if not flags then return nil, "UI library not loaded" end
    local enc, _ = AR2_nlB64()
    if type(enc) ~= "function" then return nil, "no Base64Encode" end

    local items = {}
    for flag, elem in pairs(flags) do
        if type(elem) == "table" and type(elem.GetValue) == "function" then
            local ok, val = pcall(function() return elem:GetValue() end)
            if ok then
                if typeof(val) == "Color3" then
                    table.insert(items, { Idx = flag, Value = val:ToHex() })
                elseif val ~= nil then
                    table.insert(items, { Idx = flag, Value = val })
                end
            end
        end
    end

    local jok, json = pcall(function() return AR2_HttpService:JSONEncode(items) end)
    if not jok then return nil, "JSONEncode failed" end
    local eok, blob = pcall(function() return enc(AR2_nlEncrypt(json)) end)
    if not eok then return nil, "encode failed" end
    return blob
end

function AR2_nlConfigApply(blob)
    local flags = AR2_nlFlags()
    if not flags then return false, "UI library not loaded" end
    local _, dec = AR2_nlB64()
    if type(dec) ~= "function" then return false, "no Base64Decode" end

    local ok, raw = pcall(function() return dec(blob) end)
    if not ok or type(raw) ~= "string" then return false, "decode failed" end
    local plain = AR2_nlDecrypt(raw)
    if not plain then return false, "decrypt failed" end
    local jok, items = pcall(function() return AR2_HttpService:JSONDecode(plain) end)
    if not jok or type(items) ~= "table" then return false, "bad config data" end

    local state = nil
    for _, entry in ipairs(items) do
        if type(entry) == "table" and entry.Idx == "juju_hub_state" then
            state = entry.Value
        end
    end

    for _, entry in ipairs(items) do
        if type(entry) == "table" and entry.Idx and entry.Idx ~= "juju_hub_state" then
            local elem = flags[entry.Idx]
            if elem and type(elem.SetValue) == "function" then
                task.spawn(function()
                    pcall(function() elem:SetValue(entry.Value) end)
                end)
            end
        end
    end

    if state ~= nil then
        local elem = flags["juju_hub_state"]
        if elem and type(elem.SetValue) == "function" then
            pcall(function() elem:SetValue(state) end)
        end
    else
        task.spawn(function()
            task.wait(0.15)
            pcall(AR2_applyLoadedConfig)
        end)
    end
    return true
end

function AR2_nlConfigSave(name)
    if not AR2_writefile then return false, "no writefile" end
    local path, clean = AR2_nlConfigPath(name)
    if not path then return false, "bad name" end
    pcall(function()
        if AR2_isfolder and AR2_makefolder and not AR2_isfolder(AR2_CONFIG_FOLDER) then
            AR2_makefolder(AR2_CONFIG_FOLDER)
        end
    end)
    local blob, err = AR2_nlConfigData()
    if not blob then return false, err or "serialize failed" end
    local ok, werr = pcall(AR2_writefile, path, blob)
    if not ok then return false, tostring(werr) end
    return true, clean
end

function AR2_nlConfigLoad(name)
    if not (AR2_readfile and AR2_isfile) then return false, "no readfile" end
    local path = AR2_nlConfigPath(name)
    if not path then return false, "bad name" end
    local present, exists = pcall(AR2_isfile, path)
    if not present or not exists then return false, "not found" end
    local rok, blob = pcall(AR2_readfile, path)
    if not rok or type(blob) ~= "string" or blob == "" then return false, "read failed" end
    return AR2_nlConfigApply(blob)
end

function AR2_nlConfigDelete(name)
    local path = AR2_nlConfigPath(name)
    if not path then return false, "bad name" end
    if not AR2_delfile then return false, "no delfile" end
    local present, exists = pcall(AR2_isfile, path)
    if not present or not exists then return false, "not found" end
    local ok, err = pcall(AR2_delfile, path)
    if not ok then return false, tostring(err) end
    return true
end

function AR2_nlConfigRefreshWidget()
    local win = getgenv and getgenv().OriginHUB_Window or nil
    if type(win) ~= "table" then return false end
    local ok = pcall(function()
        if type(win.RefreshConfig) == "function" then win:RefreshConfig() end
    end)
    return ok
end


function AR2_deleteConfig(name)
    name = tostring(name)
    if name == "" then return false end
    pcall(function()
        if AR2_isfile and AR2_isfile("juju_hub_config_" .. name .. ".json") then
            if AR2_delfile then AR2_delfile("juju_hub_config_" .. name .. ".json") end
        end
    end)
    for i, n in ipairs(AR2_configList) do
        if n == name then table.remove(AR2_configList, i) break end
    end
    local idxOk, idxEncoded = pcall(AR2_HttpService.JSONEncode, AR2_HttpService, { configs = AR2_configList })
    if idxOk then pcall(AR2_writefile, AR2_CONFIG_FILE, idxEncoded) end
    AR2_refreshConfigList()
    return true
end

function AR2_resetConfig()
    AR2_mergeInto(AR2_CFG, AR2_DEFAULTS.cfg)
    AR2_mergeInto(AR2_SETTINGS, AR2_DEFAULTS.settings)
    for _, cat in pairs({"players","zombies","loot","vehicles","corpses","aim","magicAim","speed","radar","minimap"}) do
        if AR2_CFG[cat] then AR2_CFG[cat].on = false end
    end
    AR2_CFG.weapon.noRecoil = false
    AR2_CFG.weapon.noSpread = false
    AR2_CFG.weapon.wallbang = false
    AR2_CFG.weapon.allFireModes = false
    AR2_CFG.weapon.instantReload = false
    AR2_CFG.weapon.recoilReduction = 0
    AR2_CFG.weapon.hbeOn = false
    AR2_CFG.weapon.hbeSize = 10
    AR2_CFG.weapon.autoReload = false
    AR2_CFG.weapon.alwaysSuppressed = false
    AR2_CFG.weapon.vehicleEquip = false
    AR2_CFG.magicAim.redirectChance = 100
    AR2_CFG.magicAim.ignoreFov = false
    AR2_CFG.magicAim.fov = 250
    AR2_CFG.magicAim.killSpread = true
    AR2_CFG.rageBot.on = false
    AR2_CFG.misc.freeze = false
    AR2_CFG.misc.infJump = false
    AR2_CFG.misc.noclip = false
    AR2_CFG.misc.bhop = false
    AR2_CFG.misc.tpDash = false
    AR2_CFG.misc.fly = false
    AR2_CFG.misc.flySpeedPct = 300
    AR2_CFG.misc.antiFallStun = false
    AR2_CFG.car.tpDash = false
    AR2_CFG.car.fly = false
    AR2_CFG.car.flySpeed = 100
    AR2_CFG.car.boatMode = false
    AR2_CFG.car.removeDrag = false
    AR2_CFG.car.fullSteer = false
    AR2_CFG.car.maxTraction = false
    AR2_CFG.misc.fovZoom = false
    AR2_CFG.misc.distZoomEnabled = false
    AR2_CFG.misc.distZoomActive = false
    AR2_CFG.misc.thirdPersonADS.enabled = false
    AR2_CFG.misc.tracers = false
    AR2_CFG.misc.charm = false
    AR2_CFG.misc.globalChams = false
    AR2_CFG.misc.globalCharm = false
    AR2_CFG.misc.removeTextures = false
    AR2_CFG.misc.removeLeaves = false
    AR2_CFG.misc.removeBushes = false
    AR2_CFG.misc.hidePlayer = false
    AR2_CFG.misc.hideGun = false
    AR2_CFG.car.fuel = false
    AR2_CFG.car.boost = false
    AR2_CFG.car.god = false
    AR2_CFG.visuals.fullbright = false
    AR2_CFG.visuals.nofog = false
    AR2_CFG.visuals.setTime = false
    AR2_CFG.visuals.skybox = "Default"
    AR2_CFG.visuals.cloudsEnabled = false
    AR2_CFG.visuals.modifyClouds = false
    AR2_CFG.visuals.colorCorrectionEnabled = false
    AR2_CFG.visuals.removeDoors = false
    AR2_CFG.visuals.removeSunRays = false
    AR2_CFG.visuals.customAmbient = false
    AR2_CFG.tp.clickTPOn = false
    AR2_CFG.tp.mapTPOn = false
    AR2_CFG.tp.respawnTP = false
    AR2_CFG.misc.personalCharOn = false
    AR2_CFG.misc.personalGunOn = false
    AR2_CFG.hitmarker.enabled = false
    AR2_CFG.crosshair.enabled = false
    AR2_CFG.misc.cosUnlock = false
    AR2_CFG.misc.instantInteract = false
    AR2_CFG.misc.playerJesus = false
    AR2_CFG.misc.selfBacktrack.enabled = false
    AR2_CFG.misc.jumpCircle.enabled = false
    AR2_CFG.misc.removeShadows = false
    AR2_CFG.misc.antiAim.enabled = false
    AR2_CFG.misc.zombieCircle.enabled = false
    AR2_CFG.misc.tungSelf = false
    AR2_CFG.misc.tungGlobal = false
    AR2_CFG.ui.sizePreset = "Default"
    AR2_ibEnabled = false
    AR2_ibMult    = 2
    pcall(function()
        AR2_esp.stop()
        AR2_aim.stop()
        AR2_magicUpdate()
        AR2_tracersStop()
        AR2_freeze.stop()
        AR2_visuals.apply()
        AR2_carMods.apply()
        AR2_radar.stop()
        AR2_speed.stop()
        pcall(AR2_rageBotSetEnabled, false)
        AR2_toggleCharm(false)
        AR2_toggleFOVZoom(false)
        AR2_toggleDistZoomEnabled(false)
        AR2_toggleDistanceZoom(false)
        AR2_set3pAds(false)
        AR2_tracersEnabled = false
        AR2_minimapEnabled = false
        if AR2_minimapGui then AR2_minimapGui.Enabled = false end
        AR2_stopNoclip()
        AR2_stopInfJump()
        AR2_stopBhop()
        AR2_stopTpDash()
        AR2_stopCarDash()
        AR2_carFlyStop()
        AR2_stopFly()
        AR2_toggleRemoveTextures(false)
        AR2_toggleRemoveLeaves(false)
        AR2_toggleRemoveBushes(false)
        AR2_toggleHidePlayer(false)
        AR2_toggleHideGun(false)
        stopWallbangTagging()
        AR2_applyAllFireModes(false)
        setInstantReloadEnabled(false)
        AR2_setPersonalCharacter(false)
        AR2_setPersonalGun(false)
        AR2_applySkybox("Default")
        AR2_toggleHitmarker(false)
        AR2_toggleCrosshair(false)
        AR2_toggleRespawnTP(false)
        AR2_hbeSetEnabled(false)
        AR2_hbeRemoveAll()
        AR2_cosSetEnabled(false)
        AR2_setAutoReload(false)
        AR2_setInstantInteract(false)
        AR2_setPlayerJesus(false)
        AR2_setSelfBacktrack(false)
        AR2_setJumpCircle(false)
        AR2_setRemoveShadows(false)
        AR2_setClouds(false, false, nil, nil, nil)
        AR2_setColorCorrection(false)
        AR2_toggleWorldwide(false)
        AR2_stopAntiAim()
        AR2_setZombieCircle(false)
        AR2_setAlwaysSuppressed(false)
        AR2_setBoatMode(false)
        AR2_setRemoveDrag(false)
        AR2_setFullSteer(false)
        AR2_setAntiFallStun(false)
        AR2_setVehicleEquip(false)
        AR2_setRemoveDoors(false)
        AR2_setRemoveSunRays(false)
        AR2_setCustomAmbient(false)
        AR2_hitSoundLoad("")
        AR2_refreshUI()
    end)
end

function AR2_resetAllKeybinds()
    for k, _ in pairs(AR2_CFG.keybinds) do
        AR2_CFG.keybinds[k] = "None"
    end
end

AR2_configLoaded = false
AR2_refreshConfigList()


AR2_clientHP    = {}
AR2_clientMaxHP = {}

for _, p in ipairs(AR2_Players:GetPlayers()) do
    if p ~= AR2_LocalPlayer then
        AR2_clientHP[p.Name]    = 100
        AR2_clientMaxHP[p.Name] = 100
    end
end

function AR2_getWeaponDamage(wi, hitPartName)
    if not wi then return 15 end
    local dmg = 0
    pcall(function()
        local fc = wi.FireConfig
        if not fc then return end
        dmg = fc.Damage or fc.BaseDamage or 0
        if hitPartName == "Head" or hitPartName == "HeadCollider" then
            dmg = dmg * (fc.HeadshotMultiplier or fc.HeadMultiplier or 1.5)
        end
    end)
    return dmg > 0 and dmg or 15
end

AR2_Players.PlayerRemoving:Connect(function(p)
    AR2_clientHP[p.Name]    = nil
    AR2_clientMaxHP[p.Name] = nil
end)

AR2_Players.PlayerAdded:Connect(function(p)
    AR2_clientHP[p.Name]    = 100
    AR2_clientMaxHP[p.Name] = 100
    p.CharacterAdded:Connect(function()
        task.wait(2)
        AR2_clientHP[p.Name] = 100
    end)
end)

for _, p in ipairs(AR2_Players:GetPlayers()) do
    if p ~= AR2_LocalPlayer then
        p.CharacterAdded:Connect(function()
            task.wait(2)
            AR2_clientHP[p.Name] = 100
        end)
    end
end

do
    local lastHitTarget, lastHitAt = nil, 0

    function AR2_noteDamageTarget(name)
        lastHitTarget, lastHitAt = name, os.clock()
    end

    local seen = setmetatable({}, { __mode = "k" })
    local function watch(obj)
        if seen[obj] then return end
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then return end
        seen[obj] = true
        local function read()
            local n = tonumber((obj.Text or ""):match("%-?%d+%.?%d*") or "")
            if not n or n <= 0 then return end
            if os.clock() - lastHitAt > 0.75 then return end
            local who = lastHitTarget
            if not who then return end
            local cur = AR2_clientHP[who] or 100
            AR2_clientHP[who] = math.max(0, cur - n)
        end
        pcall(function() obj:GetPropertyChangedSignal("Text"):Connect(read) end)
        read()
    end

    task.spawn(function()
        local PG
        while not PG do
            PG = AR2_LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not PG then task.wait(0.5) end
        end
        for _, d in ipairs(PG:GetDescendants()) do pcall(watch, d) end
        PG.DescendantAdded:Connect(function(d) pcall(watch, d) end)
    end)
end


function AR2_normalizeKey(k)
    if not k or k == "" then return "None" end
    k = tostring(k):gsub("^%s+", ""):gsub("%s+$", "")
    if k == "" then return "None" end
    local low = k:lower()
    if low == "none" then return "None" end
    local aliases = {
        ["mouse1"]="MouseButton1", ["mouse2"]="MouseButton2", ["mouse3"]="MouseButton3",
        ["m1"]="MouseButton1", ["m2"]="MouseButton2", ["m3"]="MouseButton3",
        ["ctrl"]="LeftControl", ["control"]="LeftControl",
        ["shift"]="LeftShift", ["lshift"]="LeftShift", ["rshift"]="RightShift",
        ["alt"]="LeftAlt", ["lalt"]="LeftAlt", ["ralt"]="RightAlt",
        ["esc"]="Escape", ["enter"]="Return", ["return"]="Return",
        ["spacebar"]="Space", ["space"]="Space",
        ["pageup"]="PageUp", ["pagedown"]="PageDown",
        ["caps"]="CapsLock", ["capslock"]="CapsLock",
        ["up"]="Up", ["down"]="Down", ["left"]="Left", ["right"]="Right",
        ["home"]="Home", ["end"]="End", ["insert"]="Insert", ["delete"]="Delete",
        ["del"]="Delete", ["tab"]="Tab",
    }
    if aliases[low] then return aliases[low] end
    if #k == 1 then
        local c = k:upper()
        if c >= "A" and c <= "Z" then return c end
        if tonumber(c) then return c end
    end
    local upper = k:upper()
    if upper:match("^F%d+$") then return upper end
    return k:sub(1,1):upper() .. k:sub(2)
end


AR2_tracersEnabled = false
function AR2_tracersUpdate() end
function AR2_tracersStop() end
function AR2_addTracer() end
function AR2_markDirty() end

function AR2_localPosition()
    local rig = AR2_LocalPlayer.Character
    local root = rig and rig:FindFirstChild("HumanoidRootPart")
    if root then return root.Position end
    return Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position or Vector3.zero
end

function AR2_animState(model, key, default)
    local folder = model:FindFirstChild("Animator")
    local value = folder and folder:FindFirstChild(key)
    if value and value:IsA("ValueBase") then return value.Value end
    return default
end

function AR2_parts(model)
    return {
        root = model:FindFirstChild("HumanoidRootPart"),
        head = model:FindFirstChild("Head"),
        headCollider = model:FindFirstChild("HeadCollider"),
        torso = model:FindFirstChild("UpperTorso"),
        lowerTorso = model:FindFirstChild("LowerTorso"),
    }
end

function AR2_isSquadmate(player)
    if not player or player == AR2_LocalPlayer then return false end
    local pg = AR2_LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local sf = pg:FindFirstChild("PlayerList")
    sf = sf and sf:FindFirstChild("MainList")
    sf = sf and sf:FindFirstChild("PlayerList")
    sf = sf and sf:FindFirstChild("ScrollingFrame")
    if not sf then return false end
    for _, template in ipairs(sf:GetChildren()) do
        if template:IsA("UIListLayout") or template:IsA("UIPadding") then continue end
        local nameLabel = template:FindFirstChild("NameLabel", true)
        if not nameLabel or nameLabel.Text ~= player.Name then continue end
        local yesBox = template:FindFirstChild("YesSquadOuterBox", true)
        return yesBox and yesBox.Visible or false
    end
    return false
end


AR2_itemCache, AR2_itemCacheN = {}, 0
function AR2_equippedItem(model)
    local raw = AR2_animState(model, "EquippedItem", "")
    if raw == "" or raw == "[]" then return nil, nil end

    local hit = AR2_itemCache[raw]
    if hit then return hit.n, hit.d end

    local name, out
    local ok, data = pcall(AR2_HttpService.JSONDecode, AR2_HttpService, raw)
    if not ok or type(data) ~= "table" then
        name, out = raw, nil
    elseif data.ItemName == nil or data.ItemName == "" then
        name, out = nil, data
    else
        name, out = data.ItemName, data
    end


    if AR2_itemCacheN > 256 then AR2_itemCache, AR2_itemCacheN = {}, 0 end
    AR2_itemCache[raw] = { n = name, d = out }
    AR2_itemCacheN = AR2_itemCacheN + 1
    return name, out
end


AR2_charmData = {}
AR2_charmEnabled = false
AR2_charmMode = AR2_CFG.misc.charmMode or "Color"
AR2_charmHue = AR2_CFG.misc.charmHue or 0
AR2_charmGray = AR2_CFG.misc.charmGray or 50
AR2_charmRainbow = AR2_CFG.misc.charmRainbow or false
AR2_charmRainbowConn = nil


local function AR2_getSmoothedVelocity(model, position)
    local now = os.clock()
    local tracker = AR2_velocityTracker[model]
    local rawVelocity = Vector3.zero
    if tracker then
        local dt = now - tracker.time
        if dt > 0.01 then rawVelocity = (position - tracker.position) / dt end
    end
    local smoothed = (tracker and tracker.velocity) or Vector3.zero


    smoothed = smoothed * 0.7 + rawVelocity * 0.3
    AR2_velocityTracker[model] = { position = position, time = now, velocity = smoothed }
    return smoothed
end

function AR2_buildPlayer(model)
    local p = AR2_parts(model)
    local anchor = p.root or p.torso or p.head
    if not anchor then return nil end
    local player = AR2_Players:GetPlayerFromCharacter(model)
    local itemName = AR2_equippedItem(model)
    local velocity = AR2_getSmoothedVelocity(model, anchor.Position)
    return {
        kind = "player", model = model, player = player,
        name = player and player.Name or model.Name,
        displayName = player and player.DisplayName or model.Name,
        isLocal = player == AR2_LocalPlayer, root = anchor,
        head = p.head, headCollider = p.headCollider, torso = p.torso,
        position = anchor.Position, velocity = velocity,
        distance = (anchor.Position - AR2_ORIGIN).Magnitude,
        item = itemName, armed = itemName ~= nil,
    }
end

function AR2_buildZombie(model)
    local p = AR2_parts(model)
    local anchor = p.root or p.torso or p.head
    if not anchor then return nil end
    local velocity = AR2_getSmoothedVelocity(model, anchor.Position)
    return {
        kind = "zombie", model = model, name = model.Name,
        root = anchor, head = p.head, headCollider = p.headCollider,
        position = anchor.Position, velocity = velocity,
        distance = (anchor.Position - AR2_ORIGIN).Magnitude,
        agroState = AR2_animState(model, "AgroState", "?"),
    }
end

function AR2_buildCorpse(model)
    local p = AR2_parts(model)
    local anchor = p.root or p.torso or p.head
    if not anchor then
        for _, child in ipairs(model:GetDescendants()) do
            if child:IsA("BasePart") then anchor = child break end
        end
        if not anchor then return nil end
    end
    local player = AR2_Players:FindFirstChild(model.Name)
    return {
        kind = "corpse", model = model, name = model.Name, player = player,
        isPlayer = player ~= nil, online = player ~= nil,
        root = anchor, position = anchor.Position,
        distance = (anchor.Position - AR2_ORIGIN).Magnitude,
    }
end

function AR2_buildVehicle(model)
    local anchor = model:FindFirstChild("Base") or model.PrimaryPart
    if not anchor then return nil end
    return {
        kind = "vehicle", model = model, name = model.Name, root = anchor,
        position = anchor.Position, velocity = anchor.AssemblyLinearVelocity,
        speed = anchor.AssemblyLinearVelocity.Magnitude,
        distance = (anchor.Position - AR2_ORIGIN).Magnitude,
        moving = anchor.AssemblyLinearVelocity.Magnitude > 1,
    }
end

function AR2_collect(container, builder)
    local list = {}
    if not container then return list end
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Model") then
            local e = builder(child)
            if e then list[#list + 1] = e end
        end
    end
    table.sort(list, function(a, b) return a.distance < b.distance end)
    return list
end

function AR2_readLootNodes(model)
    local nodes = {}
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("NumberValue") then nodes[#nodes + 1] = { name = child.Name, value = child.Value } end
    end
    return nodes
end

function AR2_collectLoot(radius, filter)
    local needle = filter and string.lower(filter) or nil
    local list = {}
    for _, model in ipairs(AR2_CollectionService:GetTagged("Loot Container")) do
        local anchor = model:FindFirstChild("BasePart") or (model:IsA("Model") and model.PrimaryPart) or (model:IsA("BasePart") and model)
        if anchor then
            local dist = (anchor.Position - AR2_ORIGIN).Magnitude
            if dist <= radius then
                local nodes = AR2_readLootNodes(model)
                local keep = needle == nil
                if needle then
                    for _, n in ipairs(nodes) do
                        if string.find(string.lower(n.name), needle, 1, true) then keep = true break end
                    end
                end
                if keep then
                    list[#list + 1] = {
                        kind = "loot", model = model, name = model.Name,
                        displayName = model:GetAttribute("DisplayName") or model.Name,
                        root = anchor, position = anchor.Position, distance = dist, nodes = nodes,
                    }
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.distance < b.distance end)
    return list
end


AR2_api = {}
AR2_cache = {}

function AR2_cached(key, ttl, build)
    local entry = AR2_cache[key]
    local now = os.clock()
    if entry and (now - entry.at) < ttl then return entry.value end
    local value = build()
    AR2_cache[key] = { at = now, value = value }
    return value
end

AR2_FRESH  = 0.05
AR2_STATIC = 0.60

function AR2_api.players(includeLocal)
    local list = AR2_cached("players", AR2_FRESH, function()
        if not AR2_Characters or not AR2_Characters.Parent then
            AR2_Characters = AR2_Workspace:FindFirstChild("Characters")
        end
        AR2_ORIGIN = AR2_localPosition()
        return AR2_collect(AR2_Characters, AR2_buildPlayer)
    end)
    if includeLocal then return list end
    return AR2_cached("playersNoLocal", AR2_FRESH, function()
        local filtered = {}
        for _, e in ipairs(list) do if not e.isLocal then filtered[#filtered + 1] = e end end
        return filtered
    end)
end

function AR2_api.zombies()
    return AR2_cached("zombies", AR2_FRESH, function()
        if not AR2_Zombies or not AR2_Zombies.Parent then
            AR2_Zombies = AR2_Workspace:FindFirstChild("Zombies")
        end
        AR2_ORIGIN = AR2_localPosition()
        return AR2_collect(AR2_Zombies, AR2_buildZombie)
    end)
end

function AR2_api.vehicles()
    return AR2_cached("vehicles", 0.35, function()
        if not AR2_Vehicles or not AR2_Vehicles.Parent then
            AR2_Vehicles = AR2_Workspace:FindFirstChild("Vehicles")
        end
        AR2_ORIGIN = AR2_localPosition()
        if not AR2_Vehicles then return {} end
        return AR2_collect(AR2_Vehicles, AR2_buildVehicle)
    end)
end

function AR2_api.corpses()
    return AR2_cached("corpses", 0.25, function()
        if not AR2_Corpses or not AR2_Corpses.Parent then
            AR2_Corpses = AR2_Workspace:FindFirstChild("Corpses")
        end
        if not AR2_Characters or not AR2_Characters.Parent then
            AR2_Characters = AR2_Workspace:FindFirstChild("Characters")
        end
        AR2_ORIGIN = AR2_localPosition()

        local list, seen = {}, {}
        if AR2_Corpses then
            for _, child in ipairs(AR2_Corpses:GetChildren()) do
                if child:IsA("Model") then
                    local e = AR2_buildCorpse(child)
                    if e then
                        list[#list + 1] = e
                        seen[e.name] = true
                    end
                end
            end
        end
        if AR2_Characters then
            for _, child in ipairs(AR2_Characters:GetChildren()) do
                if child:IsA("Model") and not seen[child.Name] and child ~= AR2_LocalPlayer.Character then
                    local hum = child:FindFirstChildWhichIsA("Humanoid")
                    if hum and hum.Health <= 0 then
                        local e = AR2_buildCorpse(child)
                        if e then
                            e.kind = "corpse"
                            list[#list + 1] = e
                            seen[child.Name] = true
                        end
                    end
                end
            end
        end
        local now = os.clock()
        for name, mem in pairs(AR2_corpseMemory) do
            if now - mem.time > 90 then
                AR2_corpseMemory[name] = nil
            elseif not seen[name] then
                list[#list + 1] = {
                    kind = "corpse", model = nil, name = name,
                    position = mem.position,
                    distance = (mem.position - AR2_ORIGIN).Magnitude,
                    isPlayer = true, online = false, root = nil, isGhost = true,
                }
            end
        end
        table.sort(list, function(a, b) return a.distance < b.distance end)
        return list
    end)
end

function AR2_api.loot(radius, filter)
    radius = radius or 1500
    return AR2_cached("loot:" .. radius .. ":" .. tostring(filter), 1.0, function()
        AR2_ORIGIN = AR2_localPosition()
        return AR2_collectLoot(radius, filter)
    end)
end


AR2_RANK = {
    { score = 5, words = { "legendary", "exotic", "unique", "epic" } },
    { score = 4, words = { "rare", "military", "surplus", "nato", "soviet", "armory", "weapon" } },
    { score = 3, words = { "uncommon", "firearms", "gun", "attachment", "armor", "backpack" } },
    { score = 2, words = { "ammo", "medical", "medkit", "tool", "common" } },
    { score = 1, words = { "civilian", "villager", "food", "drink", "clothing", "garbage", "junk" } },
}
AR2_TIER_COLOR = {
    [5] = Color3.fromRGB(255, 200, 40), [4] = Color3.fromRGB(190, 110, 255),
    [3] = Color3.fromRGB(70, 150, 255), [2] = Color3.fromRGB(80, 220, 120),
    [1] = Color3.fromRGB(165, 165, 175), [0] = Color3.fromRGB(120, 120, 130),
}

function AR2_rankOf(entry)
    local best = 0
    local haystack = { string.lower(entry.name), string.lower(entry.displayName or "") }
    for _, node in ipairs(entry.nodes) do haystack[#haystack + 1] = string.lower(node.name) end
    for _, tier in ipairs(AR2_RANK) do
        if tier.score > best then
            for _, word in ipairs(tier.words) do
                for _, text in ipairs(haystack) do
                    if string.find(text, word, 1, true) then best = tier.score break end
                end
                if best == tier.score then break end
            end
        end
    end
    return best
end


AR2_esp = { enabled = false, counts = {}, frameCounter = 0 }
AR2_hasDrawing = pcall(function() return Drawing.new("Line"):Remove() end)
AR2_drawPool   = {}
AR2_chamsPool  = {}
AR2_chamsFolder = nil
AR2_CHAMS_CAP  = 28

local function AR2_mkText(size)
    local t = Drawing.new("Text")
    t.Size, t.Center, t.Outline, t.Visible = size, true, true, false
    t.Color = Color3.fromRGB(235,235,235)


    pcall(function() t.OutlineColor = Color3.fromRGB(0,0,0) end)
    pcall(function() t.Font = Drawing.Fonts and Drawing.Fonts.Plex or 2 end)
    return t
end

function AR2_newVisual()
    local box = Drawing.new("Square")
    box.Thickness, box.Filled, box.Transparency, box.Visible = 1, false, 1, false
    local outline = Drawing.new("Square")
    outline.Thickness, outline.Filled, outline.Transparency, outline.Visible = 3, false, 1, false
    outline.Color = Color3.fromRGB(0,0,0)
    local fill = Drawing.new("Square")
    fill.Thickness, fill.Filled, fill.Transparency, fill.Visible = 1, true, 0.8, false
    local corners = {}
    for i = 1, 8 do
        local l = Drawing.new("Line")
        l.Thickness, l.Transparency, l.Visible = 1, 1, false
        corners[i] = l
    end
    local name = AR2_mkText(AR2_CFG.style.textSize)
    local info = AR2_mkText(AR2_CFG.style.textSize - 1)
    local htxt = AR2_mkText(AR2_CFG.style.textSize - 2)
    local tracer = Drawing.new("Line")
    tracer.Thickness, tracer.Transparency, tracer.Visible = 1, 1, false
    local hbBg = Drawing.new("Square")
    hbBg.Filled, hbBg.Color, hbBg.Transparency, hbBg.Visible = true, Color3.fromRGB(0,0,0), 0.5, false
    local hbFill = Drawing.new("Square")
    hbFill.Filled, hbFill.Color, hbFill.Transparency, hbFill.Visible = true, Color3.fromRGB(80,220,90), 1, false
    return { box=box, outline=outline, fill=fill, corners=corners,
             name=name, info=info, htxt=htxt, tracer=tracer, hbBg=hbBg, hbFill=hbFill }
end

function AR2_acquireVisual(index)
    local v = AR2_drawPool[index]
    if not v then v = AR2_newVisual() AR2_drawPool[index] = v end
    return v
end

function AR2_hideVisual(v)
    v.box.Visible    = false
    if v.outline then v.outline.Visible = false end
    if v.fill    then v.fill.Visible    = false end
    if v.corners then for _, l in ipairs(v.corners) do l.Visible = false end end
    v.name.Visible   = false
    v.info.Visible   = false
    if v.htxt   then v.htxt.Visible   = false end
    v.tracer.Visible = false
    if v.hbBg   then v.hbBg.Visible   = false end
    if v.hbFill then v.hbFill.Visible = false end
end


local function AR2_paintBox(v, x, y, w, h, color)
    local th = AR2_CFG.style.boxThickness or 1
    if AR2_CFG.style.fill then
        v.fill.Position = Vector2.new(x, y)
        v.fill.Size     = Vector2.new(w, h)
        v.fill.Color    = color
        v.fill.Transparency = 0.82
        v.fill.Visible  = true
    else v.fill.Visible = false end

    if AR2_CFG.style.cornerBox == false then
        v.outline.Position = Vector2.new(x-1, y-1)
        v.outline.Size     = Vector2.new(w+2, h+2)
        v.outline.Thickness = th + 2
        v.outline.Visible  = true
        v.box.Position  = Vector2.new(x, y)
        v.box.Size      = Vector2.new(w, h)
        v.box.Color     = color
        v.box.Thickness = th
        v.box.Visible   = true
        for _, l in ipairs(v.corners) do l.Visible = false end
    else
        v.box.Visible = false
        v.outline.Visible = false
        local L = math.clamp(math.min(w, h) * 0.28, 5, 16)
        local c = v.corners
        local function seg(i, x1, y1, x2, y2)
            local l = c[i]
            l.From, l.To = Vector2.new(x1, y1), Vector2.new(x2, y2)
            l.Color, l.Thickness, l.Visible = color, th, true
        end
        seg(1, x, y,       x+L, y)        seg(2, x, y,       x, y+L)
        seg(3, x+w, y,     x+w-L, y)      seg(4, x+w, y,     x+w, y+L)
        seg(5, x, y+h,     x+L, y+h)      seg(6, x, y+h,     x, y+h-L)
        seg(7, x+w, y+h,   x+w-L, y+h)    seg(8, x+w, y+h,   x+w, y+h-L)
    end
end


local ESP_BODY_WHITELIST = {
    Head=true,
    UpperTorso=true,   LowerTorso=true,
    LeftUpperArm=true,  LeftLowerArm=true,  LeftHand=true,
    RightUpperArm=true, RightLowerArm=true, RightHand=true,
    LeftUpperLeg=true,  LeftLowerLeg=true,  LeftFoot=true,
    RightUpperLeg=true, RightLowerLeg=true, RightFoot=true,
}

function AR2_screenBox(model, useWhitelist)
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false

    local function addPart(part)
        if not part:IsA("BasePart") then return end
        if part:GetAttribute("ar2_hbe") then return end
        if useWhitelist and not ESP_BODY_WHITELIST[part.Name] then return end
        local cf, sz = part.CFrame, part.Size
        for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
            local pt = cam:WorldToViewportPoint(
                (cf * CFrame.new(sz.X/2*x, sz.Y/2*y, sz.Z/2*z)).Position)
            if pt.Z > 0 then
                anyOnScreen = true
                if pt.X < minX then minX = pt.X end
                if pt.Y < minY then minY = pt.Y end
                if pt.X > maxX then maxX = pt.X end
                if pt.Y > maxY then maxY = pt.Y end
            end
        end end end
    end

    if model:IsA("Model") then
        for _, p in ipairs(model:GetDescendants()) do addPart(p) end


        if not anyOnScreen and useWhitelist then
            return AR2_screenBox(model, false)
        end
    elseif model:IsA("BasePart") then
        addPart(model)
    end

    if not anyOnScreen or minX == math.huge then return nil end
    return minX, minY, maxX - minX, maxY - minY
end

function AR2_readEntityHealth(model)
    local anim = model:FindFirstChild("Animator")
    if anim then
        local hp  = anim:FindFirstChild("Health")
        local mhp = anim:FindFirstChild("MaxHealth")
        if hp and hp:IsA("ValueBase") then
            local h  = tonumber(hp.Value)
            local mh = (mhp and mhp:IsA("ValueBase") and tonumber(mhp.Value)) or 100
            if h then return h, math.max(mh, 1) end
        end
    end
    local humanoid = model:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local h  = humanoid.Health
        local mh = humanoid.MaxHealth
        if type(h) == "number" and type(mh) == "number" and mh > 0 then return h, mh end
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d.Name == "Health" and d:IsA("ValueBase") then
            local h = tonumber(d.Value)
            if h then return h, 100 end
        end
    end
    return nil, nil
end


AR2_skelPool = AR2_skelPool or {}
AR2_skelSlot = 0

local AR2_BONES = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},  {"LeftUpperArm","LeftLowerArm"},  {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},  {"LeftUpperLeg","LeftLowerLeg"},  {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
}

local function AR2_acquireBone(i)
    local l = AR2_skelPool[i]
    if not l then
        l = Drawing.new("Line")
        l.Thickness, l.Transparency, l.Visible = 1, 1, false
        AR2_skelPool[i] = l
    end
    return l
end

function AR2_drawSkeleton(model, color)
    if not model then return end
    local cam = Workspace.CurrentCamera
    for _, bone in ipairs(AR2_BONES) do
        local a, b = model:FindFirstChild(bone[1]), model:FindFirstChild(bone[2])
        if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            local pa, oa = cam:WorldToViewportPoint(a.Position)
            local pb, ob = cam:WorldToViewportPoint(b.Position)
            if oa and ob and pa.Z > 0 and pb.Z > 0 then
                AR2_skelSlot = AR2_skelSlot + 1
                local l = AR2_acquireBone(AR2_skelSlot)
                l.From      = Vector2.new(pa.X, pa.Y)
                l.To        = Vector2.new(pb.X, pb.Y)
                l.Color     = color
                l.Thickness = AR2_CFG.style.boxThickness
                l.Visible   = true
            end
        end
    end
end

function AR2_hideSkeletons()
    for i = AR2_skelSlot + 1, #AR2_skelPool do
        AR2_skelPool[i].Visible = false
    end
end


AR2_slot = 0

local function AR2_hpColor(pct)
    pct = math.clamp(pct, 0, 1)
    if pct > 0.5 then
        local t = (pct - 0.5) * 2
        return Color3.fromRGB(math.floor(255*(1-t)), 210, 60)
    else
        local t = pct * 2
        return Color3.fromRGB(230, math.floor(200*t), 45)
    end
end

function AR2_drawEntity(model, color, label, sub, opt)
    local x, y, w, h = AR2_screenBox(model, opt.skeleton ~= nil)
    if not x then return false end
    AR2_slot = AR2_slot + 1
    local v = AR2_acquireVisual(AR2_slot)
    local ts = AR2_CFG.style.textSize or 13

    if opt.box then AR2_paintBox(v, x, y, w, h, color)
    else
        v.box.Visible = false v.outline.Visible = false v.fill.Visible = false
        for _, l in ipairs(v.corners) do l.Visible = false end
    end

    if label and label ~= "" then
        v.name.Text, v.name.Color, v.name.Size = label, color, ts
        v.name.Position = Vector2.new(x + w/2, y - ts - 3)
        v.name.Visible  = true
    else v.name.Visible = false end

    if sub and sub ~= "" then

        v.info.Text, v.info.Color, v.info.Size = sub, (AR2_COLORS.info or Color3.fromRGB(220,220,225)), ts - 1
        v.info.Position = Vector2.new(x + w/2, y + h + 2)
        v.info.Visible  = true
    else v.info.Visible = false end

    if opt.tracer then
        local cam = Workspace.CurrentCamera
        local origin = AR2_CFG.style.tracerFromBottom
            and Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
            or  Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        v.tracer.From, v.tracer.To = origin, Vector2.new(x + w/2, y + h)
        v.tracer.Color, v.tracer.Thickness = color, AR2_CFG.style.tracerThickness or 1
        v.tracer.Visible = true
    else v.tracer.Visible = false end

    if opt.healthBar and v.hbBg and v.hbFill then
        local hp, maxHp
        local player = AR2_Players:GetPlayerFromCharacter(model)
        if player then hp, maxHp = AR2_clientHP[player.Name], AR2_clientMaxHP[player.Name] or 100
        else hp, maxHp = AR2_readEntityHealth(model) end
        if hp and maxHp and maxHp > 0 then
            local pct   = math.clamp(hp / maxHp, 0, 1)
            local barW  = 3
            local barX  = x - barW - 4
            local fillH = math.max(1, math.floor(h * pct))
            v.hbBg.Position = Vector2.new(barX - 1, y - 1)
            v.hbBg.Size     = Vector2.new(barW + 2, h + 2)
            v.hbBg.Color, v.hbBg.Transparency, v.hbBg.Visible = Color3.fromRGB(0,0,0), 0.45, true
            v.hbFill.Position = Vector2.new(barX, y + h - fillH)
            v.hbFill.Size     = Vector2.new(barW, fillH)
            v.hbFill.Color, v.hbFill.Transparency, v.hbFill.Visible = AR2_hpColor(pct), 0, true
            if AR2_CFG.style.healthText and v.htxt then
                v.htxt.Text = tostring(math.floor(hp))
                v.htxt.Color = AR2_hpColor(pct)
                v.htxt.Position = Vector2.new(barX - 1, y + h - fillH - ts)
                v.htxt.Center = false
                v.htxt.Visible = true
            elseif v.htxt then v.htxt.Visible = false end
        else
            v.hbBg.Visible, v.hbFill.Visible = false, false
            if v.htxt then v.htxt.Visible = false end
        end
    else
        if v.hbBg   then v.hbBg.Visible   = false end
        if v.hbFill then v.hbFill.Visible = false end
        if v.htxt   then v.htxt.Visible   = false end
    end
    return true
end


function AR2_drawPoint(pos, color, label, sub, opt)
    local cam = Workspace.CurrentCamera
    local sp, on = cam:WorldToViewportPoint(pos)
    if not on or sp.Z <= 0 then return false end
    AR2_slot = AR2_slot + 1
    local v = AR2_acquireVisual(AR2_slot)
    if v.outline then v.outline.Visible = false end
    if v.fill then v.fill.Visible = false end
    if v.corners then for _, l in ipairs(v.corners) do l.Visible = false end end
    if v.htxt then v.htxt.Visible = false end
    local s = 10
    if opt.box then
        v.box.Position  = Vector2.new(sp.X - s/2, sp.Y - s/2)
        v.box.Size      = Vector2.new(s, s)
        v.box.Color     = color
        v.box.Thickness = AR2_CFG.style.boxThickness
        v.box.Visible   = true
    else v.box.Visible = false end
    if label and label ~= "" then
        v.name.Text     = label
        v.name.Color    = color
        v.name.Size     = AR2_CFG.style.textSize
        v.name.Position = Vector2.new(sp.X, sp.Y - AR2_CFG.style.textSize - 4)
        v.name.Visible  = true
    else v.name.Visible = false end
    if sub and sub ~= "" then
        v.info.Text     = sub
        v.info.Color    = color
        v.info.Size     = AR2_CFG.style.textSize - 1
        v.info.Position = Vector2.new(sp.X, sp.Y + 6)
        v.info.Visible  = true
    else v.info.Visible = false end
    v.tracer.Visible = false
    if v.hbBg   then v.hbBg.Visible   = false end
    if v.hbFill then v.hbFill.Visible = false end
    return true
end


function AR2_ensureChamsFolder()
    if AR2_chamsFolder and AR2_chamsFolder.Parent then return end
    AR2_chamsFolder = Instance.new("Folder")
    AR2_chamsFolder.Name = "juju_chams"
    AR2_chamsFolder.Parent = (AR2_gethui and AR2_gethui()) or game:GetService("CoreGui")
end

AR2_chamsSlot = 0
function AR2_applyChams(model, color)
    if AR2_chamsSlot >= AR2_CHAMS_CAP then return end
    AR2_chamsSlot = AR2_chamsSlot + 1
    local h = AR2_chamsPool[AR2_chamsSlot]
    if not h then
        AR2_ensureChamsFolder()
        h = Instance.new("Highlight")
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillTransparency, h.OutlineTransparency = 1, 0
        h.Parent = AR2_chamsFolder
        AR2_chamsPool[AR2_chamsSlot] = h
    end
    h.Adornee, h.FillColor, h.OutlineColor, h.Enabled = model, color, Color3.new(1,1,1), true
end

function AR2_fmtDist(d) return string.format("%.0f", d) end


function AR2_buildFrame()
    AR2_slot, AR2_chamsSlot, AR2_skelSlot = 0, 0, 0
    local counts = { player = 0, zombie = 0, loot = 0, vehicle = 0, corpse = 0 }


    if AR2_CFG.players.on then
        local c = AR2_CFG.players
        for _, e in ipairs(AR2_api.players()) do
            if e.distance <= c.maxDist then
                local color = e.armed and AR2_COLORS.armed or AR2_COLORS.player
                local label = c.name and e.name or nil
                local bits = {}
                if c.weapon and e.item then bits[#bits+1] = e.item end
                if c.dist   then bits[#bits+1] = AR2_fmtDist(e.distance) .. "s" end
                if AR2_drawEntity(e.model, color, label, table.concat(bits, "  "), c) then
                    counts.player = counts.player + 1
                end
                if c.skeleton then AR2_drawSkeleton(e.model, color) end
                if AR2_CFG.misc.globalChams then
                    AR2_applyChams(e.model, Color3.fromHSV(AR2_CFG.misc.globalChamsHue / 360, 1, 1))
                elseif c.chams then
                    AR2_applyChams(e.model, color)
                end
                if AR2_CFG.misc.globalCharm and AR2_CFG.misc.charm then
                    AR2_applyCharmToCharacter(e.model)
                end
            end
        end
    end


    if AR2_CFG.zombies.on then
        local c = AR2_CFG.zombies
        local drawn = 0
        for _, e in ipairs(AR2_api.zombies()) do
            if drawn >= 50 then break end
            if e.distance <= c.maxDist then
                local hostile = e.agroState == "Attacking" or e.agroState == "Investigating"
                local color = hostile and AR2_COLORS.agro or AR2_COLORS.zombie
                local bits = {}
                if c.agro and hostile then bits[#bits+1] = e.agroState end
                if c.dist then bits[#bits+1] = AR2_fmtDist(e.distance) .. "s" end
                if AR2_drawEntity(e.model, color, c.name and e.name or nil, table.concat(bits, "  "), c) then
                    counts.zombie = counts.zombie + 1
                    drawn = drawn + 1
                end
                if c.skeleton then AR2_drawSkeleton(e.model, color) end
            end
        end
    end


    if AR2_CFG.loot.on then
        local c = AR2_CFG.loot
        local drawn = 0
        for _, e in ipairs(AR2_api.loot(c.maxDist)) do
            if drawn >= 35 then break end
            local rank = AR2_rankOf(e)
            if rank >= c.minRank then
                local color = AR2_TIER_COLOR[rank] or AR2_TIER_COLOR[0]
                local bits = {}
                if c.dist then bits[#bits+1] = AR2_fmtDist(e.distance) .. "s" end
                if AR2_drawEntity(e.model, color, c.name and e.displayName or nil, table.concat(bits, "  "), c) then
                    counts.loot = counts.loot + 1
                    drawn = drawn + 1
                end
                if c.chams and rank >= 4 then AR2_applyChams(e.model, color) end
            end
        end
    end


    if AR2_CFG.vehicles.on or AR2_CFG.vehicles.chams then
        local c = AR2_CFG.vehicles
        for _, e in ipairs(AR2_api.vehicles()) do
            if e.distance <= c.maxDist then
                if c.on then
                    local bits = {}
                    if e.moving then bits[#bits+1] = "MOVING" end
                    if c.dist then bits[#bits+1] = AR2_fmtDist(e.distance) .. "s" end
                    if AR2_drawEntity(e.model, AR2_COLORS.vehicle, c.name and e.name or nil, table.concat(bits, "  "), c) then
                        counts.vehicle = counts.vehicle + 1
                    end
                end
                if c.chams then AR2_applyChams(e.model, AR2_COLORS.vehicle) end
            end
        end
    end


    if AR2_CFG.corpses.on then
        local c = AR2_CFG.corpses
        local drawn = 0
        for _, e in ipairs(AR2_api.corpses()) do
            if drawn >= 25 then break end
            if e.distance <= (c.maxDist or 2000) then
                if not (c.playersOnly and not e.isPlayer) then
                    local color = e.isGhost and Color3.fromRGB(120,120,130)
                               or (e.isPlayer and Color3.fromRGB(255,170,60) or Color3.fromRGB(190,190,190))
                    local bits = {}
                    if e.isGhost then bits[#bits+1] = "last seen" end
                    if c.dist then bits[#bits+1] = AR2_fmtDist(e.distance) .. "s" end
                    if e.model then
                        if AR2_drawEntity(e.model, color, c.name and e.name or nil,
                                          table.concat(bits, "  "), c) then
                            counts.corpse = counts.corpse + 1
                            drawn = drawn + 1
                        end
                    elseif e.position then
                        if AR2_drawPoint(e.position, color, c.name and e.name or nil,
                                         table.concat(bits, "  "), c) then
                            counts.corpse = counts.corpse + 1
                            drawn = drawn + 1
                        end
                    end
                end
            end
        end
    end

    for i = AR2_slot + 1, #AR2_drawPool do AR2_hideVisual(AR2_drawPool[i]) end
    AR2_hideSkeletons()
    for i = AR2_chamsSlot + 1, #AR2_chamsPool do
        AR2_chamsPool[i].Adornee = nil
        AR2_chamsPool[i].Enabled = false
    end
    AR2_esp.counts = counts
end


AR2_espConn = nil
function AR2_esp.update()
    local anyOn = AR2_CFG.players.on or AR2_CFG.zombies.on or AR2_CFG.loot.on or AR2_CFG.vehicles.on or AR2_CFG.corpses.on
    if anyOn and not AR2_espConn then AR2_esp.start()
    elseif not anyOn and AR2_espConn then AR2_esp.stop() end
end

function AR2_esp.start()
    if AR2_espConn then return end
    if not AR2_hasDrawing then return end
    AR2_esp.enabled = true
    AR2_espConn = AR2_RunService.RenderStepped:Connect(function()
        AR2_Camera = Workspace.CurrentCamera
        local ok, err = pcall(AR2_buildFrame)
        if not ok then warn("[esp] " .. tostring(err)) end
    end)
end

function AR2_esp.stop()
    AR2_esp.enabled = false
    if AR2_espConn then AR2_espConn:Disconnect() AR2_espConn = nil end
    for _, v in ipairs(AR2_drawPool) do AR2_hideVisual(v) end
    for _, h in ipairs(AR2_chamsPool) do h.Adornee = nil h.Enabled = false end
    AR2_hideSkeletons()
end

function AR2_esp.destroy()
    AR2_esp.stop()
    for _, v in ipairs(AR2_drawPool) do
        v.box:Remove()
        v.name:Remove()
        v.info:Remove()
        v.tracer:Remove()
        if v.hbBg   then v.hbBg:Remove()   end
        if v.hbFill then v.hbFill:Remove() end
    end
    AR2_drawPool = {}
    for _, l in ipairs(AR2_skelPool) do l:Remove() end
    AR2_skelPool = {}
    for _, h in ipairs(AR2_chamsPool) do h:Destroy() end
    AR2_chamsPool = {}
    if AR2_chamsFolder then AR2_chamsFolder:Destroy() AR2_chamsFolder = nil end
end


AR2_Notif = nil

function AR2_notify(content, dur)
    local shown = false
    pcall(function()
        if AR2_Notif and AR2_Notif.new then
            AR2_Notif.new({ Title = "juju", Content = tostring(content), Duration = dur or 4 })
            shown = true
        end
    end)
    if not shown then warn("[juju] " .. tostring(content)) end
end

local function AR2_seatedInVehiclesFolder(hum)
    local container = AR2_Workspace:FindFirstChild("Vehicles")
    if not (container and hum) then return false end
    for _, model in ipairs(container:GetChildren()) do
        if model:IsA("Model") then
            for _, d in ipairs(model:GetDescendants()) do
                if (d:IsA("VehicleSeat") or d:IsA("Seat")) and d.Occupant == hum then
                    return true
                end
            end
        end
    end
    return false
end

function AR2_inVehicle()
    local char = AR2_LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        if hum.Sit == true then return true end
        if hum.SeatPart ~= nil then return true end
    end
    if AR2_vehEquipInVeh == true then return true end
    local ok, seated = pcall(AR2_seatedInVehiclesFolder, hum)
    if ok and seated then return true end
    return false
end

do
    AR2_MAP_ORIGIN = CFrame.new(Vector3.new(-7349.55, 0, -6187.35), Vector3.new(-7349.55, 0, -6186.35))
    AR2_MAP_SX, AR2_MAP_SZ = -13499.068, -12386.184
    AR2_MAP_IMAGE = "rbxassetid://102357544057594"
    AR2_IMG_W, AR2_IMG_H = 1024, 925
    AR2_mapImageOk = false
    AR2_mapStatus = nil
    AR2_mapLastRoute = ""

    function AR2_mapImageCandidates()
        local id = tostring((AR2_CFG and AR2_CFG.tp and AR2_CFG.tp.mapImageId) or ""):match("%d+")
            or "102357544057594"
        return {
            "rbxassetid://" .. id,
            "http://www.roblox.com/asset/?id=" .. id,
            "rbxthumb://type=Asset&id=" .. id .. "&w=420&h=420",
        }
    end

    function AR2_mapBuildGrid(parent)
        if not parent or parent:FindFirstChild("ar2_grid") then return end
        local grid = Instance.new("Folder")
        grid.Name = "ar2_grid"
        grid.Parent = parent
        for i = 1, 9 do
            local vline = Instance.new("Frame")
            vline.BackgroundColor3 = Color3.fromRGB(72, 82, 98)
            vline.BackgroundTransparency = 0.55
            vline.BorderSizePixel = 0
            vline.Size = UDim2.new(0, 1, 1, 0)
            vline.Position = UDim2.fromScale(i / 10, 0)
            vline.ZIndex = 2
            vline.Parent = grid
            local hline = Instance.new("Frame")
            hline.BackgroundColor3 = Color3.fromRGB(72, 82, 98)
            hline.BackgroundTransparency = 0.55
            hline.BorderSizePixel = 0
            hline.Size = UDim2.new(1, 0, 0, 1)
            hline.Position = UDim2.fromScale(0, i / 10)
            hline.ZIndex = 2
            hline.Parent = grid
        end
    end

    function AR2_mapLoadImage()
        if not AR2_mapImg then return end
        task.spawn(function()
            for _, url in ipairs(AR2_mapImageCandidates()) do
                if not AR2_mapImg or not AR2_mapImg.Parent then return end
                pcall(function() AR2_mapImg.Image = url end)
                pcall(function()
                    game:GetService("ContentProvider"):PreloadAsync({ AR2_mapImg })
                end)
                local deadline = os.clock() + 3
                while os.clock() < deadline do
                    local loaded = false
                    pcall(function() loaded = AR2_mapImg.IsLoaded end)
                    if loaded then
                        AR2_mapImageOk = true
                        pcall(function()
                            local g = AR2_mapImg:FindFirstChild("ar2_grid")
                            if g then g:Destroy() end
                            if AR2_mapStatus then AR2_mapStatus.Text = "" end
                        end)
                        return
                    end
                    task.wait(0.1)
                end
            end
            AR2_mapImageOk = false
            pcall(function()
                AR2_mapBuildGrid(AR2_mapImg)
                if AR2_mapStatus then
                    AR2_mapStatus.Text = "image unavailable — grid mode (clicks still work)"
                end
            end)
        end)
    end

    function AR2_worldToMap(p) local r = AR2_MAP_ORIGIN:PointToObjectSpace(p) return r.X / AR2_MAP_SX, r.Z / AR2_MAP_SZ end
    function AR2_mapToWorld(u, v) return AR2_MAP_ORIGIN:PointToWorldSpace(Vector3.new(u * AR2_MAP_SX, 0, v * AR2_MAP_SZ)) end

    function AR2_groundY(x, z)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { AR2_LocalPlayer.Character }
        params.IgnoreWater = false
        local hit = AR2_Workspace:Raycast(Vector3.new(x, 5000, z), Vector3.new(0, -12000, 0), params)
        return hit and hit.Position.Y or nil
    end

    AR2_mapGui = nil
    AR2_mapConn = nil
    AR2_mapImg = nil
    AR2_youDot = nil
    AR2_dotPool = {}

    function AR2_buildMap()
        if AR2_mapGui then pcall(function() AR2_mapGui:Destroy() end) end
        AR2_dotPool = {}
        AR2_mapImageOk = false
        local host = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
        AR2_mapGui = Instance.new("ScreenGui")
        AR2_mapGui.Name = "ar2_map"
        AR2_mapGui.ResetOnSpawn = false
        AR2_mapGui.IgnoreGuiInset = true
        AR2_mapGui.DisplayOrder = 999998
        AR2_mapGui.Enabled = false
        AR2_mapGui.Parent = host
        local dim = Instance.new("TextButton")
        dim.Size = UDim2.fromScale(1,1)
        dim.BackgroundColor3 = Color3.new(0,0,0)
        dim.BackgroundTransparency = 0.35
        dim.AutoButtonColor = false
        dim.Text = ""
        dim.Parent = AR2_mapGui
        local W = 720
        local H = math.floor(W * AR2_IMG_H / AR2_IMG_W)
        local panel = Instance.new("Frame")
        panel.AnchorPoint = Vector2.new(0.5,0.5)
        panel.Position = UDim2.fromScale(0.5,0.5)
        panel.Size = UDim2.fromOffset(W, H+34)
        panel.BackgroundColor3 = Color3.fromRGB(15,16,20)
        panel.BorderSizePixel = 0
        panel.Parent = AR2_mapGui
        local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,8) pc.Parent = panel
        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(12,0)
        title.Size = UDim2.new(1,-80,0,34)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = Color3.fromRGB(225,225,235)
        title.Text = "Map"
        title.Parent = panel
        local close = Instance.new("TextButton")
        close.Size = UDim2.fromOffset(26,22)
        close.Position = UDim2.new(1,-32,0,6)
        close.BackgroundColor3 = Color3.fromRGB(40,42,52)
        close.Text = "X"
        close.Font = Enum.Font.GothamBold
        close.TextSize = 13
        close.TextColor3 = Color3.fromRGB(230,120,120)
        close.BorderSizePixel = 0
        close.Parent = panel
        local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,5) cc.Parent = close
        AR2_mapStatus = Instance.new("TextLabel")
        AR2_mapStatus.BackgroundTransparency = 1
        AR2_mapStatus.Position = UDim2.fromOffset(12,16)
        AR2_mapStatus.Size = UDim2.new(1,-80,0,16)
        AR2_mapStatus.Font = Enum.Font.Gotham
        AR2_mapStatus.TextSize = 11
        AR2_mapStatus.TextXAlignment = Enum.TextXAlignment.Left
        AR2_mapStatus.TextColor3 = Color3.fromRGB(235,180,110)
        AR2_mapStatus.Text = "loading map image..."
        AR2_mapStatus.Parent = panel
        AR2_mapImg = Instance.new("ImageButton")
        AR2_mapImg.Position = UDim2.fromOffset(0,34)
        AR2_mapImg.Size = UDim2.fromOffset(W,H)
        AR2_mapImg.BackgroundColor3 = Color3.fromRGB(20,24,30)
        AR2_mapImg.ScaleType = Enum.ScaleType.Stretch
        AR2_mapImg.AutoButtonColor = false
        AR2_mapImg.BorderSizePixel = 0
        AR2_mapImg.Parent = panel
        local ic = Instance.new("UICorner") ic.CornerRadius = UDim.new(0,6) ic.Parent = AR2_mapImg
        AR2_mapLoadImage()
        AR2_youDot = Instance.new("Frame")
        AR2_youDot.AnchorPoint = Vector2.new(0.5,0.5)
        AR2_youDot.Size = UDim2.fromOffset(9,9)
        AR2_youDot.BackgroundColor3 = Color3.fromRGB(255,220,60)
        AR2_youDot.BorderSizePixel = 0
        AR2_youDot.ZIndex = 5
        AR2_youDot.Parent = AR2_mapImg
        local yc = Instance.new("UICorner") yc.CornerRadius = UDim.new(1,0) yc.Parent = AR2_youDot
        dim.MouseButton1Click:Connect(function() AR2_tp.toggleMap(false) end)
        close.MouseButton1Click:Connect(function() AR2_tp.toggleMap(false) end)

        AR2_mapImg.Activated:Connect(function()
            local mouse = AR2_UserInputService:GetMouseLocation()
            local abs, sz = AR2_mapImg.AbsolutePosition, AR2_mapImg.AbsoluteSize
            if sz.X <= 0 or sz.Y <= 0 then return end
            local u = math.clamp((mouse.X - abs.X) / sz.X, 0, 1)
            local v = math.clamp((mouse.Y - abs.Y) / sz.Y, 0, 1)
            local w = AR2_mapToWorld(u, v)
            local y = AR2_groundY(w.X, w.Z)
            local dest = Vector3.new(w.X, (y or 200) + 6, w.Z)
            local label = string.format("map (%.0f, %.0f)", w.X, w.Z)

            AR2_tp.toggleMap(false)

            if not (AR2_carNoclipTP and AR2_carNoclipTP.toPosition) then
                AR2_tp.lastResult = label .. " -- vehicle TP unavailable"
                AR2_notify("Vehicle TP unavailable")
                return
            end

            if not AR2_inVehicle() then
                AR2_tp.lastResult = label .. " -- not in a vehicle"
                AR2_notify("Get in a vehicle first — map TP flies your car there", 5)
                return
            end

            AR2_mapLastRoute = "vehicle"
            AR2_tp.lastResult = label .. " -- vehicle route"
            AR2_notify(string.format("Flying to %.0f, %.0f", w.X, w.Z), 3)

            task.spawn(function()
                AR2_carNoclipTP.lastResult = ""
                pcall(function() AR2_carNoclipTP.toPosition(dest, label) end)
                local deadline = os.clock() + (AR2_CFG.car.noclipTPMaxSeconds or 15) + 5
                while os.clock() < deadline do
                    if AR2_carNoclipTP.lastResult ~= "" and not AR2_carNoclipTP.busy then break end
                    task.wait(0.15)
                end
                if AR2_carNoclipTP.lastResult ~= "" then
                    AR2_notify(AR2_carNoclipTP.lastResult, 4)
                end
            end)
        end)
    end

    local function AR2_mapDot(i, size, color, zi)
        local d = AR2_dotPool[i]
        if not d then
            d = Instance.new("Frame")
            d.AnchorPoint = Vector2.new(0.5,0.5)
            d.BorderSizePixel = 0
            d.Parent = AR2_mapImg
            local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(1,0) dc.Parent = d
            local lbl = Instance.new("TextLabel")
            lbl.Name = "tag"
            lbl.AnchorPoint = Vector2.new(0.5,1)
            lbl.Position = UDim2.new(0.5,0,0,-2)
            lbl.Size = UDim2.fromOffset(120,12)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10
            lbl.TextStrokeTransparency = 0.4
            lbl.TextColor3 = Color3.fromRGB(240,240,245)
            lbl.Visible = false
            lbl.ZIndex = 6
            lbl.Parent = d
            AR2_dotPool[i] = d
        end
        d.Size = UDim2.fromOffset(size, size)
        d.BackgroundColor3 = color
        d.ZIndex = zi
        d.Visible = true
        return d
    end

    function AR2_refreshDots()
        if not AR2_mapImg or not AR2_mapImg.Parent then return end
        local root = AR2_LocalPlayer.Character and AR2_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myPos = root and root.Position or nil
        if root then
            local u, v = AR2_worldToMap(root.Position)
            AR2_youDot.Position = UDim2.fromScale(u, v)
            AR2_youDot.Visible = true
        else
            AR2_youDot.Visible = false
        end

        local i = 0
        local showNames = AR2_CFG.radar and AR2_CFG.radar.names
        local showDist  = AR2_CFG.radar and AR2_CFG.radar.dist

        for _, pl in ipairs(AR2_Players:GetPlayers()) do
            local r = pl ~= AR2_LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
            if r then
                i = i + 1
                local d = AR2_mapDot(i, 7, AR2_COLORS.player or Color3.fromRGB(255,90,90), 4)
                local u, v = AR2_worldToMap(r.Position)
                d.Position = UDim2.fromScale(u, v)
                local tag = d:FindFirstChild("tag")
                if tag then
                    if showNames or showDist then
                        local txt = showNames and pl.Name or ""
                        if showDist and myPos then
                            local dd = math.floor((r.Position - myPos).Magnitude)
                            txt = (txt ~= "" and (txt .. "  ") or "") .. dd .. "m"
                        end
                        tag.Text = txt
                        tag.TextColor3 = AR2_COLORS.player or Color3.fromRGB(255,120,120)
                        tag.Visible = true
                    else
                        tag.Visible = false
                    end
                end
            end
        end

        local vehCfg = AR2_CFG.radar and AR2_CFG.radar.vehicles
        if vehCfg and vehCfg.on then
            local container = AR2_Workspace:FindFirstChild("Vehicles")
            if container then
                for _, model in ipairs(container:GetChildren()) do
                    if model:IsA("Model") then
                        local base = AR2_carBase(model)
                        if base then
                            i = i + 1
                            local d = AR2_mapDot(i, 6, AR2_COLORS.vehicle or Color3.fromRGB(90,200,255), 3)
                            local u, v = AR2_worldToMap(base.Position)
                            d.Position = UDim2.fromScale(u, v)
                            local tag = d:FindFirstChild("tag")
                            if tag then
                                if vehCfg.names or vehCfg.dist then
                                    local txt = vehCfg.names and model.Name or ""
                                    if vehCfg.dist and myPos then
                                        local dd = math.floor((base.Position - myPos).Magnitude)
                                        txt = (txt ~= "" and (txt .. "  ") or "") .. dd .. "m"
                                    end
                                    tag.Text = txt
                                    tag.TextColor3 = AR2_COLORS.vehicle or Color3.fromRGB(120,210,255)
                                    tag.Visible = true
                                else
                                    tag.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end

        for j = i+1, #AR2_dotPool do
            AR2_dotPool[j].Visible = false
        end
    end

    function AR2_tp.toggleMap(on)
        if not AR2_mapGui or not AR2_mapGui.Parent then AR2_buildMap() end
        if on == nil then on = not AR2_mapGui.Enabled end
        AR2_mapGui.Enabled = on
        if on then
            AR2_refreshDots()
            if not AR2_mapConn then
                local acc = 0
                AR2_mapConn = AR2_RunService.RenderStepped:Connect(function(dt)
                    acc = acc + dt
                    if acc >= 0.2 then acc = 0 pcall(AR2_refreshDots) end
                end)
            end
        elseif AR2_mapConn then
            AR2_mapConn:Disconnect()
            AR2_mapConn = nil
        end
    end
end


AR2_radar = { running = false, layer = "off", players = 0, drawn = 0, sample = "" }
do
    local MAP_ORIGIN = CFrame.new(Vector3.new(-7349.55, 0, -6187.35), Vector3.new(-7349.55, 0, -6186.35))
    local MAP_SX, MAP_SZ = -13499.068, -12386.184
    local function worldToMap(position)
        local rel = MAP_ORIGIN:PointToObjectSpace(position)
        return rel.X / MAP_SX, rel.Z / MAP_SZ
    end
    local RADAR_COLOR = { normal = Color3.fromRGB(120,190,255), armed = Color3.fromRGB(255,150,50), localP = Color3.fromRGB(255,220,60), veh = Color3.fromRGB(90,255,140), corpse = Color3.fromRGB(200,200,205) }
    local radarConn, radarDots = nil, {}
    local radarLayer, radarMarker, radarNextScan = nil, nil, 0

    local function radarRendered(gui)
        if gui.AbsoluteSize.X <= 0 then return false end
        local node = gui
        while node do
            if node:IsA("ScreenGui") then return node.Enabled end
            if node:IsA("GuiObject") and not node.Visible then return false end
            node = node.Parent
        end
        return true
    end


    local function radarMarkerLayer()
        if radarMarker and radarMarker.Parent and radarRendered(radarMarker) then
            return radarLayer, radarMarker, "ok"
        end
        local now = os.clock()
        if now < radarNextScan then return radarLayer, radarMarker, "map not open" end
        radarNextScan = now + 2.0
        radarLayer, radarMarker = nil, nil
        local gui = AR2_LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return nil, nil, "no PlayerGui" end

        local anyMarker = false
        for _, descendant in ipairs(gui:GetDescendants()) do
            if descendant.Name == "LocalMarker" and descendant:IsA("GuiObject") then
                anyMarker = true
                if radarRendered(descendant) then
                    radarLayer, radarMarker = descendant.Parent, descendant
                    return descendant.Parent, descendant, "ok"
                end
            end
        end
        return nil, nil, anyMarker and "map not open" or "no LocalMarker"
    end

    local function radarMakeDot(zbase)
        local dot = Instance.new("Frame")
        dot.Name = "ar2_dot"
        dot.AnchorPoint = Vector2.new(0.5,0.5)
        dot.Size = UDim2.fromOffset(12,12)
        dot.BorderSizePixel = 0
        dot.ZIndex = zbase + 5
        local round = Instance.new("UICorner") round.CornerRadius = UDim.new(1,0) round.Parent = dot
        local edge = Instance.new("UIStroke") edge.Color = Color3.fromRGB(0,0,0) edge.Thickness = 1.5 edge.Transparency = 0.25 edge.Parent = dot
        local name = Instance.new("TextLabel")
        name.Name = "Name"
        name.BackgroundTransparency = 1
        name.AnchorPoint = Vector2.new(0,0.5)
        name.Position = UDim2.fromOffset(10,0)
        name.Size = UDim2.fromOffset(200,28)
        name.Font = Enum.Font.GothamBold
        name.TextSize = 12
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextStrokeTransparency = 0.4
        name.ZIndex = zbase + 6
        name.Parent = dot
        return dot
    end

    local function radarColorFor(entry)
        if entry.isLocal then return RADAR_COLOR.localP end
        if AR2_CFG.radar.armedColor and entry.armed then return RADAR_COLOR.armed end
        return RADAR_COLOR.normal
    end

    local function radarClearDots()
        for name, dot in pairs(radarDots) do
            dot:Destroy()
            radarDots[name] = nil
        end
    end

    local function radarStep()
        if not AR2_CFG.radar.on then
            if next(radarDots) then radarClearDots() end
            AR2_radar.layer, AR2_radar.players, AR2_radar.drawn = "disabled", 0, 0
            return
        end
        local parent, localMarker, why = radarMarkerLayer()
        AR2_radar.layer = why
        if not parent then
            if next(radarDots) then radarClearDots() end
            AR2_radar.players, AR2_radar.drawn = 0, 0
            return
        end
        local zbase = localMarker and localMarker.ZIndex or 10
        local seen, drawn = {}, 0


        local function place(key, worldPos, colour, labelText)
            seen[key] = true
            local dot = radarDots[key]
            if not dot or dot.Parent ~= parent then
                if dot then dot:Destroy() end
                dot = radarMakeDot(zbase)
                dot.Parent = parent
                radarDots[key] = dot
            end
            local x, z = worldToMap(worldPos)
            dot.Position = UDim2.fromScale(x, z)
            dot.BackgroundColor3 = colour
            local label = dot:FindFirstChild("Name")
            if label then
                label.Text = labelText or ""
                label.Visible = labelText ~= nil and labelText ~= ""
                label.TextColor3 = colour
            end
            drawn = drawn + 1
        end


        local live = AR2_api.players(true)
        AR2_radar.players = #live
        for _, e in ipairs(live) do
            if (AR2_CFG.radar.localToo or not e.isLocal) and e.root then
                local parts = {}
                if AR2_CFG.radar.names then parts[#parts+1] = e.name end
                if AR2_CFG.radar.weapon and e.item then parts[#parts+1] = "["..e.item.."]" end
                if AR2_CFG.radar.dist then parts[#parts+1] = string.format("%.0fs", e.distance) end
                place("p:"..e.name, e.root.Position, radarColorFor(e), #parts>0 and table.concat(parts,"  ") or nil)
            end
        end


        if AR2_CFG.radar.vehicles and AR2_CFG.radar.vehicles.on then
            for _, e in ipairs(AR2_api.vehicles()) do
                if e.root then
                    local parts = {}
                    if AR2_CFG.radar.vehicles.names then parts[#parts+1] = e.name end
                    if AR2_CFG.radar.vehicles.dist then parts[#parts+1] = string.format("%.0fs", e.distance) end
                    place("v:"..e.model:GetFullName(), e.root.Position, RADAR_COLOR.veh, #parts>0 and table.concat(parts,"  ") or nil)
                end
            end
        end


        if AR2_CFG.radar.corpses and AR2_CFG.radar.corpses.on then
            for _, e in ipairs(AR2_api.corpses()) do
                local pos = e.position or (e.root and e.root.Position)
                if pos then
                    local parts = {}
                    if AR2_CFG.radar.corpses.names then parts[#parts+1] = e.name end
                    if AR2_CFG.radar.corpses.dist then parts[#parts+1] = string.format("%.0fs", e.distance) end
                    place("c:"..tostring(e.name), pos, RADAR_COLOR.corpse, #parts>0 and table.concat(parts,"  ") or nil)
                end
            end
        end

        AR2_radar.drawn = drawn
        for key, dot in pairs(radarDots) do
            if not seen[key] then dot:Destroy() radarDots[key] = nil end
        end
    end

    function AR2_radar.start()
        if radarConn then return end
        AR2_radar.running = true
        AR2_radar.layer = "starting"
        radarConn = AR2_RunService.RenderStepped:Connect(function()
            local ok, err = pcall(radarStep)
            if not ok then AR2_radar.layer = "error: "..tostring(err) end
        end)
    end

    function AR2_radar.stop()
        AR2_radar.running = false
        if radarConn then radarConn:Disconnect() radarConn = nil end
        radarClearDots()
        AR2_radar.layer, AR2_radar.players, AR2_radar.drawn = "off", 0, 0
    end

    function AR2_radar.destroy()
        AR2_radar.stop()
        radarLayer, radarMarker = nil, nil
        radarNextScan = 0
    end
end


AR2_minimapEnabled = false
AR2_minimapGui = nil
AR2_minimapImg = nil
AR2_minimapYouDot = nil
AR2_minimapDots = {}
AR2_minimapConn = nil

function AR2_buildMinimap()
    local host = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
    AR2_minimapGui = Instance.new("ScreenGui")
    AR2_minimapGui.Name = "ar2_minimap"
    AR2_minimapGui.ResetOnSpawn = false
    AR2_minimapGui.IgnoreGuiInset = true
    AR2_minimapGui.DisplayOrder = 999997
    AR2_minimapGui.Enabled = AR2_minimapEnabled
    AR2_minimapGui.Parent = host
    AR2_minimapImg = Instance.new("ImageButton")
    AR2_minimapImg.Size = UDim2.fromOffset(AR2_CFG.minimap.size, AR2_CFG.minimap.size)
    AR2_minimapImg.Position = UDim2.fromOffset(AR2_CFG.minimap.x, AR2_CFG.minimap.y)
    AR2_minimapImg.BackgroundColor3 = Color3.fromRGB(20,24,30)
    AR2_minimapImg.Image = AR2_MAP_IMAGE
    AR2_minimapImg.ScaleType = Enum.ScaleType.Stretch
    AR2_minimapImg.AutoButtonColor = false
    AR2_minimapImg.BorderSizePixel = 0
    AR2_minimapImg.Parent = AR2_minimapGui
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,6) corner.Parent = AR2_minimapImg
    AR2_minimapYouDot = Instance.new("Frame")
    AR2_minimapYouDot.AnchorPoint = Vector2.new(0.5,0.5)
    AR2_minimapYouDot.Size = UDim2.fromOffset(7,7)
    AR2_minimapYouDot.BackgroundColor3 = Color3.fromRGB(255,220,60)
    AR2_minimapYouDot.BorderSizePixel = 0
    AR2_minimapYouDot.ZIndex = 5
    AR2_minimapYouDot.Parent = AR2_minimapImg
end

function AR2_updateMinimap()
    if not AR2_minimapEnabled then
        if AR2_minimapGui then AR2_minimapGui.Enabled = false end
        return
    end
    if not AR2_minimapGui or not AR2_minimapGui.Parent then AR2_buildMinimap() end
    AR2_minimapGui.Enabled = true
    AR2_minimapImg.Size = UDim2.fromOffset(AR2_CFG.minimap.size, AR2_CFG.minimap.size)
    AR2_minimapImg.Position = UDim2.fromOffset(AR2_CFG.minimap.x, AR2_CFG.minimap.y)
    local root = AR2_LocalPlayer.Character and AR2_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local u, v = AR2_worldToMap(root.Position)
        AR2_minimapYouDot.Position = UDim2.fromScale(u, v)
        AR2_minimapYouDot.Visible = true
    else
        AR2_minimapYouDot.Visible = false
    end
    local i = 0
    for _, pl in ipairs(AR2_Players:GetPlayers()) do
        if pl == AR2_LocalPlayer then continue end
        local pRoot = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
        if pRoot then
            i = i + 1
            local dot = AR2_minimapDots[i]
            if not dot then
                dot = Instance.new("Frame")
                dot.AnchorPoint = Vector2.new(0.5,0.5)
                dot.Size = UDim2.fromOffset(5,5)
                dot.BackgroundColor3 = Color3.fromRGB(255,90,90)
                dot.BorderSizePixel = 0
                dot.ZIndex = 4
                dot.Parent = AR2_minimapImg
                AR2_minimapDots[i] = dot
            end
            local u, v = AR2_worldToMap(pRoot.Position)
            dot.Position = UDim2.fromScale(u, v)
            dot.Visible = true
        end
    end
    for j = i+1, #AR2_minimapDots do AR2_minimapDots[j].Visible = false end
end

function AR2_minimapStart()
    if AR2_minimapConn then return end
    AR2_minimapConn = AR2_RunService.RenderStepped:Connect(function()
        if not AR2_minimapEnabled then return end
        AR2_updateMinimap()
    end)
end

function AR2_minimapStop()
    if AR2_minimapConn then AR2_minimapConn:Disconnect() AR2_minimapConn = nil end
end

function AR2_minimapUpdate()
    if AR2_CFG.minimap.on and not AR2_minimapConn then AR2_minimapStart()
    elseif not AR2_CFG.minimap.on and AR2_minimapConn then AR2_minimapStop() end
end


AR2_visuals = { running = false, note = "off" }
AR2_FLAT_AMBIENT = Color3.fromRGB(150,150,150)

function AR2_atmosphere() return AR2_Lighting:FindFirstChildOfClass("Atmosphere") end

AR2_ORIG = {
    Brightness = AR2_Lighting.Brightness, Ambient = AR2_Lighting.Ambient,
    OutdoorAmbient = AR2_Lighting.OutdoorAmbient, GlobalShadows = AR2_Lighting.GlobalShadows,
    ExposureCompensation = AR2_Lighting.ExposureCompensation, FogEnd = AR2_Lighting.FogEnd,
    FogStart = AR2_Lighting.FogStart, ClockTime = AR2_Lighting.ClockTime,
    AtmosphereDensity = (AR2_atmosphere() and AR2_atmosphere().Density) or nil,
}

local AR2_origColorCorrection = nil
local AR2_addedColorCorrection = false
local AR2_origBloom = nil
local AR2_addedBloom = false

local function AR2_snapshotPostFX()
    local existingCC = AR2_Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if existingCC then
        AR2_origColorCorrection = { inst = existingCC, Saturation = existingCC.Saturation, Contrast = existingCC.Contrast, Brightness = existingCC.Brightness, Enabled = existingCC.Enabled }
    end
    local existingBloom = AR2_Lighting:FindFirstChildOfClass("BloomEffect")
    if existingBloom then
        AR2_origBloom = { inst = existingBloom, Intensity = existingBloom.Intensity, Size = existingBloom.Size, Threshold = existingBloom.Threshold, Enabled = existingBloom.Enabled }
    end
end
AR2_snapshotPostFX()

function AR2_applyFullbright()
    AR2_Lighting.Brightness = AR2_CFG.visuals.brightness
    AR2_Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    AR2_Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    AR2_Lighting.GlobalShadows = false
    AR2_Lighting.ExposureCompensation = 0.45
    local cc = AR2_origColorCorrection and AR2_origColorCorrection.inst or AR2_Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not cc or not cc.Parent then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "AR2_CC"
        cc.Parent = AR2_Lighting
        AR2_addedColorCorrection = true
    end
    cc.Saturation = 0.25 cc.Contrast = 0.10 cc.Brightness = 0.02 cc.Enabled = true
    local bloom = AR2_origBloom and AR2_origBloom.inst or AR2_Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom or not bloom.Parent then
        bloom = Instance.new("BloomEffect")
        bloom.Name = "AR2_Bloom"
        bloom.Parent = AR2_Lighting
        AR2_addedBloom = true
    end
    bloom.Intensity = 0.20 bloom.Size = 22 bloom.Threshold = 0.95 bloom.Enabled = true
end

function AR2_restoreFullbright()
    AR2_Lighting.Brightness          = AR2_ORIG.Brightness
    AR2_Lighting.Ambient             = AR2_ORIG.Ambient
    AR2_Lighting.OutdoorAmbient      = AR2_ORIG.OutdoorAmbient
    AR2_Lighting.GlobalShadows       = AR2_ORIG.GlobalShadows
    AR2_Lighting.ExposureCompensation = AR2_ORIG.ExposureCompensation
    if AR2_addedColorCorrection then
        local cc = AR2_Lighting:FindFirstChild("AR2_CC")
        if cc then cc:Destroy() end
        AR2_addedColorCorrection = false
    elseif AR2_origColorCorrection then
        local o = AR2_origColorCorrection
        o.inst.Saturation = o.Saturation
        o.inst.Contrast = o.Contrast
        o.inst.Brightness = o.Brightness
        o.inst.Enabled = o.Enabled
    end
    if AR2_addedBloom then
        local bloom = AR2_Lighting:FindFirstChild("AR2_Bloom")
        if bloom then bloom:Destroy() end
        AR2_addedBloom = false
    elseif AR2_origBloom then
        local o = AR2_origBloom
        o.inst.Intensity = o.Intensity
        o.inst.Size = o.Size
        o.inst.Threshold = o.Threshold
        o.inst.Enabled = o.Enabled
    end
end

function AR2_applyNoFog()
    AR2_Lighting.FogEnd = 1e6
    AR2_Lighting.FogStart = 0
    local air = AR2_atmosphere()
    if air then air.Density = 0.0001 end
end

function AR2_restoreFog()
    AR2_Lighting.FogEnd = AR2_ORIG.FogEnd
    AR2_Lighting.FogStart = AR2_ORIG.FogStart
    local air = AR2_atmosphere()
    if air and AR2_ORIG.AtmosphereDensity then air.Density = AR2_ORIG.AtmosphereDensity end
end

AR2_visualsConn = nil

function AR2_visualsStep()
    local c = AR2_CFG.visuals
    if c.fullbright then AR2_applyFullbright() end
    if c.nofog then AR2_applyNoFog() end
    if c.setTime then AR2_Lighting.ClockTime = c.time end
end

function AR2_visuals.apply()
    local c = AR2_CFG.visuals
    if not c.fullbright then AR2_restoreFullbright() end
    if not c.nofog then AR2_restoreFog() end
    if not c.setTime then AR2_Lighting.ClockTime = AR2_ORIG.ClockTime end
    if c.fullbright or c.nofog or c.setTime then
        if not AR2_visualsConn then
            AR2_visualsConn = AR2_RunService.RenderStepped:Connect(function()
                local ok, err = pcall(AR2_visualsStep)
                if not ok then AR2_visuals.note = "error: "..tostring(err) end
            end)
        end
        AR2_visuals.running = true
        local parts_ = {}
        if c.fullbright then parts_[#parts_+1] = "fullbright" end
        if c.nofog then parts_[#parts_+1] = "nofog" end
        if c.setTime then parts_[#parts_+1] = string.format("%dh", c.time) end
        AR2_visuals.note = table.concat(parts_, ", ")
    else
        if AR2_visualsConn then AR2_visualsConn:Disconnect() AR2_visualsConn = nil end
        AR2_visuals.running = false
        AR2_visuals.note = "off"
    end
end

function AR2_visuals.destroy()
    if AR2_visualsConn then AR2_visualsConn:Disconnect() AR2_visualsConn = nil end
    AR2_visuals.running = false
    AR2_restoreFullbright()
    AR2_restoreFog()
    AR2_Lighting.ClockTime = AR2_ORIG.ClockTime
    AR2_visuals.note = "off"
end


AR2_charmHighlights = {}
function AR2_getCharmColor()
    if AR2_charmMode == "BlackWhite" then
        local gray = AR2_charmGray / 100
        return Color3.fromRGB(gray*255, gray*255, gray*255)
    else
        return Color3.fromHSV(AR2_charmHue/360, 1, 1)
    end
end

function AR2_applyCharmToCharacter(char)
    if not char then return end
    local existing = AR2_charmHighlights[char]
    if existing then existing:Destroy() AR2_charmHighlights[char] = nil end
    if AR2_charmEnabled then
        local fillColor = AR2_getCharmColor()
        local outlineColor = Color3.new(1,1,1)
        local fillTransparency = 0.3
        if AR2_charmMode == "BlackWhite" then outlineColor = Color3.new(0,0,0) end
        local highlight = Instance.new("Highlight")
        highlight.FillColor = fillColor
        highlight.OutlineColor = outlineColor
        highlight.FillTransparency = fillTransparency
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = char
        highlight.Parent = char
        AR2_charmHighlights[char] = highlight
    end
end

function AR2_applyCharm(char)
    AR2_applyCharmToCharacter(char)
    if AR2_CFG.misc.globalCharm then
        for _, player in ipairs(AR2_Players:GetPlayers()) do
            if player ~= AR2_LocalPlayer and player.Character then
                AR2_applyCharmToCharacter(player.Character)
            end
        end
    end
end

function AR2_toggleCharm(enabled)
    AR2_charmEnabled = enabled
    if enabled then
        AR2_applyCharm(AR2_LocalPlayer.Character)
        if AR2_charmRainbow and not AR2_charmRainbowConn then
            AR2_charmRainbowConn = AR2_RunService.Heartbeat:Connect(function()
                if not AR2_charmEnabled or not AR2_charmRainbow then
                    if AR2_charmRainbowConn then AR2_charmRainbowConn:Disconnect() AR2_charmRainbowConn = nil end
                    return
                end
                AR2_charmHue = (AR2_charmHue + 0.5) % 360
                local col = Color3.fromHSV(AR2_charmHue/360, 1, 1)
                for _, highlight in pairs(AR2_charmHighlights) do highlight.FillColor = col end
            end)
        end
    else
        for _, highlight in pairs(AR2_charmHighlights) do highlight:Destroy() end
        AR2_charmHighlights = {}
        if AR2_charmRainbowConn then AR2_charmRainbowConn:Disconnect() AR2_charmRainbowConn = nil end
    end
end

function AR2_setCharmMode(mode)
    AR2_charmMode = mode
    AR2_CFG.misc.charmMode = mode
    if AR2_charmEnabled then AR2_applyCharm(AR2_LocalPlayer.Character) end
    AR2_markDirty()
end

function AR2_setCharmHue(hue)
    AR2_charmHue = hue % 360
    AR2_CFG.misc.charmHue = AR2_charmHue
    if AR2_charmEnabled and AR2_charmMode == "Color" then
        for _, highlight in pairs(AR2_charmHighlights) do
            highlight.FillColor = Color3.fromHSV(AR2_charmHue/360,1,1)
        end
    end
end

function AR2_setCharmGray(gray)
    AR2_charmGray = gray
    AR2_CFG.misc.charmGray = gray
    if AR2_charmEnabled and AR2_charmMode == "BlackWhite" then
        local g = gray/100
        for _, highlight in pairs(AR2_charmHighlights) do
            highlight.FillColor = Color3.fromRGB(g*255,g*255,g*255)
        end
    end
end

function AR2_toggleCharmRainbow(enabled)
    AR2_charmRainbow = enabled
    AR2_CFG.misc.charmRainbow = enabled
    if enabled and AR2_charmEnabled then
        if not AR2_charmRainbowConn then
            AR2_charmRainbowConn = AR2_RunService.Heartbeat:Connect(function()
                if not AR2_charmEnabled or not AR2_charmRainbow then
                    if AR2_charmRainbowConn then AR2_charmRainbowConn:Disconnect() AR2_charmRainbowConn = nil end
                    return
                end
                AR2_charmHue = (AR2_charmHue + 0.5) % 360
                local col = Color3.fromHSV(AR2_charmHue/360, 1, 1)
                for _, highlight in pairs(AR2_charmHighlights) do highlight.FillColor = col end
            end)
        end
    else
        if AR2_charmRainbowConn then AR2_charmRainbowConn:Disconnect() AR2_charmRainbowConn = nil end
    end
end


AR2_tracers = {}
AR2_tracersConn = nil

AR2_TRACER_STYLES = {
    Plain     = "",
    Beam      = "rbxassetid://12781852245",
    Lightning = "rbxassetid://446111271",
    Trail     = "rbxassetid://6419989824",
    Zigzag    = "rbxassetid://1274380363",
    Heartrate = "rbxassetid://5830549480",
    Chain     = "rbxassetid://9632168658",
    Glitch    = "rbxassetid://8089467613",
    Swirl     = "rbxassetid://5638168605",
    Classic   = "rbxassetid://2382169232",
}

AR2_TRACER_STYLE_NAMES = {
    "Beam","Plain","Classic","Lightning","Trail","Zigzag",
    "Heartrate","Chain","Glitch","Swirl","3D Part",
}

do
local AR2_beamPool = {}
local AR2_TRACER_SEQ_CLEAR = NumberSequence.new(0)
local AR2_TRACER_FADE_LUT = {}
for i = 0, 16 do AR2_TRACER_FADE_LUT[i] = NumberSequence.new(i / 16) end
local AR2_lastTracerCol, AR2_lastTracerSeq, AR2_tracerColDirty = nil, nil, false

local function AR2_tracerColor()
    if AR2_CFG.misc.tracerRainbow then
        return Color3.fromHSV((tick() * 1000 % 360) / 360, 1, 1)
    end
    return Color3.fromHSV((AR2_CFG.misc.tracerHue or 0) / 360, 1, 1)
end

local function AR2_killTracer(t)
    pcall(function()
        if t.Beam then t.Beam:Destroy() end
        if t.Near then t.Near:Destroy() end
        if t.Far then t.Far:Destroy() end
    end)
end

local function AR2_freeTracer(t, broken)
    if broken or not t.Beam or t.Beam.Parent == nil then AR2_killTracer(t) return end
    t.Beam.Enabled = false
    if #AR2_beamPool < (AR2_CFG.misc.tracerMax or 48) then
        AR2_beamPool[#AR2_beamPool + 1] = t
    else
        AR2_killTracer(t)
    end
end

function AR2_tracersClear()
    for _, t in ipairs(AR2_tracers) do AR2_killTracer(t) end
    for _, t in ipairs(AR2_beamPool) do AR2_killTracer(t) end
    AR2_tracers, AR2_beamPool = {}, {}
    AR2_lastTracerCol, AR2_lastTracerSeq, AR2_tracerColDirty = nil, nil, false
end

local function AR2_newTracer()
    local terrain = AR2_Workspace.Terrain
    if not terrain then return nil end
    local near = Instance.new("Attachment") near.Parent = terrain
    local far  = Instance.new("Attachment") far.Parent  = terrain
    local b = Instance.new("Beam")
    b.Name = "ORIGIN_Tracer"
    b.Attachment0, b.Attachment1 = near, far
    b.FaceCamera, b.LightInfluence = true, 0
    b.Parent = terrain
    return { Beam = b, Near = near, Far = far, P = 0, V = 0 }
end

local function AR2_makeBeamTracer(a, b2)
    if typeof(a) ~= "Vector3" or typeof(b2) ~= "Vector3" then return end
    local maxT = math.max(1, AR2_CFG.misc.tracerMax or 48)
    while #AR2_tracers >= maxT do
        AR2_freeTracer(table.remove(AR2_tracers, 1))
    end
    local t = table.remove(AR2_beamPool) or AR2_newTracer()
    if not t then return end

    local col = AR2_tracerColor()
    if col ~= AR2_lastTracerCol then
        AR2_lastTracerCol = col
        AR2_lastTracerSeq = ColorSequence.new(col)
        AR2_tracerColDirty = true
    end

    local bm = t.Beam
    local w = AR2_CFG.misc.tracerWidth or 2
    bm.Color = AR2_lastTracerSeq
    bm.Width0, bm.Width1 = w, w
    bm.LightEmission = math.clamp(AR2_CFG.misc.tracerEmission or 1, 0, 1)
    bm.Brightness = 10000 ^ ((math.clamp(AR2_CFG.misc.tracerGlow or 6, 1, 25) - 1) / 24)
    bm.Transparency = AR2_TRACER_SEQ_CLEAR

    local tex = AR2_TRACER_STYLES[AR2_CFG.misc.tracerStyle] or ""
    bm.Texture = tex
    if tex ~= "" then
        bm.TextureLength = math.max(0.1, AR2_CFG.misc.tracerTexLength or 4)
        bm.TextureSpeed  = AR2_CFG.misc.tracerTexSpeed or 1
    end

    t.Near.Position = a
    t.Start, t.Finish = a, b2
    t.CreatedAt = tick()
    t.Life = math.max(0.1, AR2_CFG.misc.tracerLife or 0.6)
    t.Fade = math.max(0, AR2_CFG.misc.tracerFade or 0.35)
    t.Expand = AR2_CFG.misc.tracerExpand == true
    t.Step = -1
    if t.Expand then
        t.P, t.V = 0, 0
        t.Far.Position = a
    else
        t.P, t.V = 1, 0
        t.Far.Position = b2
    end
    bm.Enabled = true
    AR2_tracers[#AR2_tracers + 1] = t
end

local function AR2_stepTracers(dt)
    if #AR2_tracers == 0 then return end
    local now = tick()
    local recol = nil
    if AR2_tracerColDirty then
        recol, AR2_tracerColDirty = AR2_lastTracerSeq, false
    end
    local s = math.max(1, AR2_CFG.misc.tracerExpandSpeed or 18)
    local d = math.clamp(AR2_CFG.misc.tracerDamper or 0.7, 0.1, 1)
    local sub = math.max(1, math.ceil(dt * s * d / 0.5))
    local h = dt / sub

    for i = #AR2_tracers, 1, -1 do
        local t = AR2_tracers[i]
        local age = now - t.CreatedAt
        local broken = (not t.Beam) or t.Beam.Parent == nil
        if broken or age >= t.Life + t.Fade then
            table.remove(AR2_tracers, i)
            AR2_freeTracer(t, broken)
        else
            if recol then t.Beam.Color = recol end
            if t.Expand then
                for _ = 1, sub do
                    t.V = t.V + (1 - t.P) * s * s * h - t.V * 2 * d * s * h
                    t.P = t.P + t.V * h
                end
                t.Far.Position = t.Start:Lerp(t.Finish, math.clamp(t.P, 0, 1))
                if math.abs(t.P - 1) < 0.002 and math.abs(t.V) < 0.05 then
                    t.Expand = false
                    t.Far.Position = t.Finish
                end
            end
            if t.Fade > 0 and age >= t.Life then
                local step = math.clamp(
                    math.floor(((age - t.Life) / t.Fade) * 16 + 0.5), 0, 16)
                if step ~= t.Step then
                    t.Step = step
                    t.Beam.Transparency = AR2_TRACER_FADE_LUT[step]
                end
            end
        end
    end
end

function AR2_addTracer(origin, direction)
    if not AR2_tracersEnabled then return end

    if AR2_CFG.misc.tracerStyle == "3D Part" then
        local dir = direction.Unit
        local length = (AR2_CFG.misc.tracerLength or 10) * 100
        local col = AR2_CFG.misc.tracerRainbow
            and Color3.fromHSV((tick()*1000%360)/360,1,1)
            or  Color3.fromHSV((AR2_CFG.misc.tracerHue or 0)/360,1,1)
        local w = math.max(0.05,(AR2_CFG.misc.tracerWidth or 2)*0.06)
        local pt = Instance.new("Part")
        pt.Anchored=true pt.CanCollide=false pt.CanQuery=false pt.CanTouch=false pt.CastShadow=false
        pt.Material=Enum.Material.Neon pt.Color=col
        pt.Size=Vector3.new(w,w,length)
        pt.CFrame=CFrame.lookAt(origin, origin+dir)*CFrame.new(0,0,-length/2)
        pt.Parent=AR2_Workspace
        task.spawn(function()
            local steps=14
            for i=1,steps do
                if not pt.Parent then return end
                pcall(function() pt.Transparency=i/steps end)
                task.wait(0.4/steps)
            end
            pcall(function() pt:Destroy() end)
        end)
        return
    end
    local terrain = AR2_Workspace.Terrain
    if not terrain then return end
    local length = (AR2_CFG.misc.tracerLength or 10) * 100
    local dir = direction.Unit

    if AR2_CFG.misc.tracerLightning then
        local perp1 = Vector3.new(-dir.Z, 0, dir.X)
        local perp2 = Vector3.new(0, dir.Z, -dir.X)
        local segments = 20
        local points = {origin}
        for i = 1, segments do
            local frac = i / segments
            local basePoint = origin + dir * (length * frac)
            local offset = (perp1 * (math.random() - 0.5) + perp2 * (math.random() - 0.5)) * (math.random() * 6 + 2)
            table.insert(points, basePoint + offset)
        end
        for i = 1, #points - 1 do
            AR2_makeBeamTracer(points[i], points[i + 1])
        end
        return
    end

    AR2_makeBeamTracer(origin, origin + dir * length)
end

function AR2_tracersStart()
    if AR2_tracersConn then return end
    AR2_tracersConn = AR2_RunService.Heartbeat:Connect(function(dt)
        pcall(AR2_stepTracers, dt)
    end)
end

function AR2_tracersStop()
    if AR2_tracersConn then
        pcall(function() AR2_tracersConn:Disconnect() end)
        AR2_tracersConn = nil
    end
    pcall(AR2_tracersClear)
end

function AR2_tracersUpdate()
    AR2_tracersEnabled = AR2_CFG.misc.tracers
    if AR2_tracersEnabled then
        AR2_tracersStart()
    else
        AR2_tracersStop()
    end
end
end


do
    local joint, baseC0, angle = nil, nil, 0
    local function findJoint()
        local ch = AR2_LocalPlayer.Character
        if not ch then return nil end
        local lt = ch:FindFirstChild("LowerTorso")
        if lt then for _, d in ipairs(lt:GetChildren()) do if d:IsA("Motor6D") then return d end end end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hrp then local rj = hrp:FindFirstChild("RootJoint") if rj and rj:IsA("Motor6D") then return rj end end
        return nil
    end
    function AR2_setSpin(on)
        AR2_CFG.misc.spinOn = on and true or false
        if not on then
            if joint and joint.Parent and baseC0 then pcall(function() joint.C0 = baseC0 end) end
            joint, baseC0 = nil, nil
        end
    end
    AR2_LocalPlayer.CharacterAdded:Connect(function() joint, baseC0 = nil, nil end)
    pcall(function()
        AR2_RunService:BindToRenderStep("AR2_SpinBot", Enum.RenderPriority.Character.Value + 1, function(dt)
            if not AR2_CFG.misc.spinOn then return end
            if not joint or not joint.Parent then joint = findJoint() baseC0 = joint and joint.C0 or nil end
            if not joint or not baseC0 then return end
            angle = (angle + (AR2_CFG.misc.spinSpeed or 20) * dt) % (math.pi * 2)
            local cf = CFrame.Angles(0, angle, 0)
            if AR2_CFG.misc.spinTilt then cf = cf * CFrame.Angles(math.rad(25) * math.sin(angle * 2), 0, 0) end
            pcall(function() joint.C0 = baseC0 * cf end)
        end)
    end)
end


AR2_hidePlayerOriginal = {}

function AR2_refreshHideState()
    local char = AR2_LocalPlayer.Character
    if not char then return end
    local shouldHide = AR2_CFG.misc.hidePlayer
                    or (AR2_CFG.misc.morphHideSelf and AR2_morph and AR2_morph.model)
    if shouldHide then
        for _, descendant in ipairs(char:GetDescendants()) do
            if descendant:IsA("BasePart")
            or descendant:IsA("Decal")
            or descendant:IsA("Texture") then
                if AR2_hidePlayerOriginal[descendant] == nil then
                    AR2_hidePlayerOriginal[descendant] = descendant.Transparency
                end
                descendant.Transparency = 1
            end
        end
    else
        for part, orig in pairs(AR2_hidePlayerOriginal) do
            if part and part.Parent then part.Transparency = orig end
        end
        table.clear(AR2_hidePlayerOriginal)
    end
end

function AR2_toggleHidePlayer(enabled)
    AR2_CFG.misc.hidePlayer = enabled
    AR2_refreshHideState()
end

local AR2_hideGunOriginal = {}
local AR2_hideGunConn = nil
function AR2_findGunModel()
    local char = AR2_LocalPlayer.Character
    if not char then return nil end
    local equipped = char:FindFirstChild("Equipped")
    if equipped then
        for _, child in ipairs(equipped:GetChildren()) do
            if child:IsA("Model") or child:IsA("Tool") then return child end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then return child end
    end
    return nil
end

function AR2_toggleHideGun(enabled)
    AR2_CFG.misc.hideGun = enabled
    if enabled then
        if not AR2_hideGunConn then
            AR2_hideGunConn = AR2_RunService.RenderStepped:Connect(function()
                local gun = AR2_findGunModel()
                if gun then
                    for _, descendant in ipairs(gun:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            if AR2_hideGunOriginal[descendant] == nil then
                                AR2_hideGunOriginal[descendant] = descendant.Transparency
                                descendant.Transparency = 1
                            end
                        end
                    end
                end
            end)
        end
    else
        if AR2_hideGunConn then AR2_hideGunConn:Disconnect() AR2_hideGunConn = nil end
        for part, orig in pairs(AR2_hideGunOriginal) do
            if part.Parent then part.Transparency = orig end
        end
        table.clear(AR2_hideGunOriginal)
    end
end


local personalCharOriginal    = {}
local personalCharRainbowConn = nil

function AR2_setPersonalCharacter(enabled, mode, hue, gray, materialStr, rainbow)
    AR2_CFG.misc.personalCharOn = enabled
    if mode then AR2_CFG.misc.personalCharMode = mode end
    if hue then AR2_CFG.misc.personalCharHue = hue end
    if gray then AR2_CFG.misc.personalCharGray = gray end
    if materialStr then AR2_CFG.misc.personalCharMaterial = materialStr end
    if rainbow ~= nil then AR2_CFG.misc.personalCharRainbow = rainbow end
    if not enabled then
        if personalCharRainbowConn then personalCharRainbowConn:Disconnect() personalCharRainbowConn = nil end
        for part, orig in pairs(personalCharOriginal) do
            if part.Parent then
                part.Color = orig.Color
                part.Material = orig.Material
                part.Transparency = orig.Transparency
            end
        end
        table.clear(personalCharOriginal)
        return
    end
    local char = AR2_LocalPlayer.Character
    if not char then return end
    task.wait(0.5)
    local material = Enum.Material[AR2_CFG.misc.personalCharMaterial] or Enum.Material.ForceField
    local targetParts = { "Head","UpperTorso","LowerTorso",
        "LeftUpperArm","LeftLowerArm","LeftHand",
        "RightUpperArm","RightLowerArm","RightHand",
        "LeftUpperLeg","LeftLowerLeg","LeftFoot",
        "RightUpperLeg","RightLowerLeg","RightFoot" }
    local function getColor()
        if AR2_CFG.misc.personalCharMode == "BlackWhite" then
            local g = AR2_CFG.misc.personalCharGray / 100
            return Color3.fromRGB(g*255, g*255, g*255)
        else
            return Color3.fromHSV(AR2_CFG.misc.personalCharHue/360, 1, 1)
        end
    end
    for _, name in ipairs(targetParts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if not personalCharOriginal[part] then
                personalCharOriginal[part] = { Color = part.Color, Material = part.Material, Transparency = part.Transparency }
            end
            part.Material = material
            if material == Enum.Material.ForceField then part.Transparency = 0.5 else part.Transparency = 0 end
            part.Color = getColor()
        end
    end
    if AR2_CFG.misc.personalCharRainbow then
        if personalCharRainbowConn then personalCharRainbowConn:Disconnect() end
        personalCharRainbowConn = AR2_RunService.Heartbeat:Connect(function()
            local hue = (tick() * 100) % 360
            local color = Color3.fromHSV(hue/360, 1, 1)
            for _, name in ipairs(targetParts) do
                local part = char:FindFirstChild(name)
                if part and part:IsA("BasePart") then part.Color = color end
            end
        end)
    else
        if personalCharRainbowConn then personalCharRainbowConn:Disconnect() personalCharRainbowConn = nil end
    end
end


do
    local _host = (typeof(AR2_gethui)=="function" and AR2_gethui()) or game:GetService("CoreGui")
    pcall(function() local o=_host:FindFirstChild("juju_hm") if o then o:Destroy() end end)

    local _gui = Instance.new("ScreenGui")
    _gui.Name="juju_hm" _gui.ResetOnSpawn=false _gui.IgnoreGuiInset=true
    _gui.DisplayOrder=999999 _gui.Parent=_host

    local function _mkF(rot)
        local f=Instance.new("Frame")
        f.BorderSizePixel=0 f.AnchorPoint=Vector2.new(0.5,0.5)
        f.Rotation=rot f.ZIndex=10 f.Visible=false f.Parent=_gui
        return f
    end
    local function _round(f)
        Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
    end

    local _xA  = _mkF(45)   local _xB  = _mkF(-45)
    local _pA  = _mkF(0)    local _pB  = _mkF(90)
    local _dot = _mkF(0)    _round(_dot)
    local _dia = _mkF(45)
    local _cT  = _mkF(0)    _round(_cT)
    local _cB  = _mkF(0)    _round(_cB)
    local _cL  = _mkF(0)    _round(_cL)
    local _cR  = _mkF(0)    _round(_cR)
    local _sT  = _mkF(0)    local _sB  = _mkF(0)
    local _sL  = _mkF(90)   local _sR  = _mkF(90)

    local _allFrames = {_xA,_xB,_pA,_pB,_dot,_dia,_cT,_cB,_cL,_cR,_sT,_sB,_sL,_sR}

    local function _hideAll()
        for _,f in ipairs(_allFrames) do f.Visible=false end
    end

    local _hmActive  = false
    local _hmEndTime = 0
    local _rainbowH  = 0

    AR2_HM_SHAPE_NAMES = {"X","+","Dot","Diamond","Circle","Square"}

    local function _applyShape(cx,cy)
        local cfg = AR2_CFG.hitmarker
        local s   = cfg.size      or 20
        local t   = cfg.thickness or 3
        local g   = cfg.gap       or 6
        local op  = cfg.opacity   or 1
        local tr  = 1 - math.clamp(op,0,1)
        local hue = (cfg.rainbow and _rainbowH or (cfg.colorHue or 0)) / 360
        local col = Color3.fromHSV(hue,1,1)
        local shape = cfg.shape or "X"

        _hideAll()

        local function show(f,x,y,w,h)
            f.Position=UDim2.fromOffset(x,y) f.Size=UDim2.fromOffset(w,h)
            f.BackgroundColor3=col f.BackgroundTransparency=tr f.Visible=true
        end

        if shape=="X" then
            show(_xA,cx,cy,s*2,t) show(_xB,cx,cy,s*2,t)
        elseif shape=="+" then
            show(_pA,cx,cy,s*2,t) show(_pB,cx,cy,t,s*2)
        elseif shape=="Dot" then
            local r=math.max(t*2,5) show(_dot,cx,cy,r,r)
        elseif shape=="Diamond" then
            show(_dia,cx,cy,s*1.4,t)
        elseif shape=="Circle" then
            local r=s+g local ds=math.max(t+2,6)
            show(_cT,cx,cy-r,ds,ds) show(_cB,cx,cy+r,ds,ds)
            show(_cL,cx-r,cy,ds,ds) show(_cR,cx+r,cy,ds,ds)
        elseif shape=="Square" then
            show(_sT,cx,cy-(s+g),s*2,t) show(_sB,cx,cy+(s+g),s*2,t)
            show(_sL,cx-(s+g),cy,t,s*2) show(_sR,cx+(s+g),cy,t,s*2)
        end
    end

    AR2_hitmarkerFlag = false

    local function _showVisual()
        local cam=workspace.CurrentCamera if not cam then return end
        if AR2_CFG.hitmarker.rainbow then _rainbowH=(_rainbowH+15)%360 end
        _applyShape(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        _hmActive=true _hmEndTime=tick()+(AR2_CFG.hitmarker.duration or 0.3)
    end

    AR2_showHitmarker = function()
        _showVisual()
        local id   = AR2_CFG.hitmarker.sound
        local path = AR2_CFG.hitmarker.soundPath
        local want = (path and path ~= "") and path or id
        if want ~= AR2_hitSoundId then
            AR2_hitSoundLoad(want)
        end
    end

    function AR2_toggleHitmarker(enabled)
        AR2_CFG.hitmarker.enabled=enabled
        if not enabled then AR2_hitmarkerFlag=false _hideAll() _hmActive=false end
    end

    AR2_RunService.RenderStepped:Connect(function()
        if AR2_hitmarkerFlag then AR2_hitmarkerFlag=false AR2_showHitmarker() end
        if _hmActive and tick()>_hmEndTime then _hideAll() _hmActive=false end
    end)
end


local AR2_crosshairDrawings = {}
local AR2_crosshairConn = nil
local function AR2_destroyCrosshair()
    for _,d in ipairs(AR2_crosshairDrawings) do pcall(function() d:Remove() end) end
    AR2_crosshairDrawings = {}
end
local function AR2_buildCrosshair()
    AR2_destroyCrosshair()
    if not AR2_CFG.crosshair.enabled or not AR2_hasDrawing then return end
    local cfg = AR2_CFG.crosshair
    local color = Color3.fromHSV(cfg.hue/360,1,1)
    local s,g,t = cfg.size,cfg.gap,cfg.thickness
    if cfg.shape == "Cross" then
        for i=1,4 do
            local l=Drawing.new("Line")
            l.Thickness=t l.Color=color l.Transparency=1 l.Visible=true
            AR2_crosshairDrawings[i]=l
        end
    elseif cfg.shape == "Dot" then
        local c=Drawing.new("Circle")
        c.Radius=t+1 c.Color=color c.Filled=true c.Transparency=1 c.Visible=true
        AR2_crosshairDrawings[1]=c
    elseif cfg.shape == "Circle" then
        local c=Drawing.new("Circle")
        c.Radius=s c.Color=color c.Filled=false c.Thickness=t c.Transparency=1 c.Visible=true
        AR2_crosshairDrawings[1]=c
    elseif cfg.shape == "T" then
        for i=1,3 do
            local l=Drawing.new("Line")
            l.Thickness=t l.Color=color l.Transparency=1 l.Visible=true
            AR2_crosshairDrawings[i]=l
        end
    elseif cfg.shape == "Square" then
        local sq=Drawing.new("Square")
        sq.Size=Vector2.new(s*2,s*2) sq.Color=color sq.Filled=false sq.Thickness=t sq.Transparency=1 sq.Visible=true
        AR2_crosshairDrawings[1]=sq
    end
end
local function AR2_updateCrosshairPositions(center)
    local cfg = AR2_CFG.crosshair
    local color = cfg.rainbow and Color3.fromHSV((tick()*80%360)/360,1,1) or Color3.fromHSV(cfg.hue/360,1,1)
    local s,g,t = cfg.size,cfg.gap,cfg.thickness
    if cfg.shape=="Cross" and #AR2_crosshairDrawings==4 then
        AR2_crosshairDrawings[1].From=center+Vector2.new(0,-(g+s))
        AR2_crosshairDrawings[1].To=center+Vector2.new(0,-g)
        AR2_crosshairDrawings[2].From=center+Vector2.new(0,g)
        AR2_crosshairDrawings[2].To=center+Vector2.new(0,g+s)
        AR2_crosshairDrawings[3].From=center+Vector2.new(-(g+s),0)
        AR2_crosshairDrawings[3].To=center+Vector2.new(-g,0)
        AR2_crosshairDrawings[4].From=center+Vector2.new(g,0)
        AR2_crosshairDrawings[4].To=center+Vector2.new(g+s,0)
        for _,d in ipairs(AR2_crosshairDrawings) do d.Color=color d.Thickness=t end
    elseif cfg.shape=="Dot" and #AR2_crosshairDrawings==1 then
        AR2_crosshairDrawings[1].Position=center
        AR2_crosshairDrawings[1].Radius=t+1
        AR2_crosshairDrawings[1].Color=color
    elseif cfg.shape=="Circle" and #AR2_crosshairDrawings==1 then
        AR2_crosshairDrawings[1].Position=center
        AR2_crosshairDrawings[1].Radius=s
        AR2_crosshairDrawings[1].Color=color
        AR2_crosshairDrawings[1].Thickness=t
    elseif cfg.shape=="T" and #AR2_crosshairDrawings==3 then
        AR2_crosshairDrawings[1].From=center+Vector2.new(0,-(g+s))
        AR2_crosshairDrawings[1].To=center+Vector2.new(0,-g)
        AR2_crosshairDrawings[2].From=center+Vector2.new(-(g+s),0)
        AR2_crosshairDrawings[2].To=center+Vector2.new(-g,0)
        AR2_crosshairDrawings[3].From=center+Vector2.new(g,0)
        AR2_crosshairDrawings[3].To=center+Vector2.new(g+s,0)
        for _,d in ipairs(AR2_crosshairDrawings) do d.Color=color d.Thickness=t end
    elseif cfg.shape=="Square" and #AR2_crosshairDrawings==1 then
        AR2_crosshairDrawings[1].Position=center-Vector2.new(s,s)
        AR2_crosshairDrawings[1].Size=Vector2.new(s*2,s*2)
        AR2_crosshairDrawings[1].Color=color
        AR2_crosshairDrawings[1].Thickness=t
    end
end
function AR2_toggleCrosshair(enabled)
    AR2_CFG.crosshair.enabled = enabled
    if AR2_crosshairConn then AR2_crosshairConn:Disconnect() AR2_crosshairConn=nil end
    AR2_destroyCrosshair()
    if not enabled then return end
    AR2_buildCrosshair()
    AR2_crosshairConn = AR2_RunService.RenderStepped:Connect(function()
        if not AR2_CFG.crosshair.enabled then return end
        local cam = AR2_Camera if not cam then return end
        local expected = ({Cross=4,Dot=1,Circle=1,T=3,Square=1})[AR2_CFG.crosshair.shape] or 1
        if #AR2_crosshairDrawings ~= expected then AR2_buildCrosshair() end
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        AR2_updateCrosshairPositions(center)
    end)
end


local advCorpseESP = {
    enabled = false, showNames = false, showDistance = false,
    highlightColor = Color3.fromRGB(255,0,0), nameColor = Color3.fromRGB(255,150,0),
    distanceColor = Color3.fromRGB(255,255,255), maxDistance = 10000
}
local advCorpseConn = nil
local advCorpseChildAddedConn = nil

local function isInfected(m) return m.Name:lower():find("infected") ~= nil end
local function removeAdvCorpseElements(m)
    local h = m:FindFirstChild("AdvCorpseHighlight") if h then h:Destroy() end
    local b = m:FindFirstChild("AdvCorpseBillboard") if b then b:Destroy() end
end
local function applyAdvCorpse(m)
    if not m or isInfected(m) then return end
    local primary = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
    if not primary then return end
    removeAdvCorpseElements(m)
    local hl = Instance.new("Highlight")
    hl.Name="AdvCorpseHighlight"
    hl.FillColor=advCorpseESP.highlightColor
    hl.OutlineColor=Color3.new(1,1,1)
    hl.FillTransparency=0.5
    hl.OutlineTransparency=0
    hl.Adornee=m
    hl.Parent=m
    if advCorpseESP.showNames or advCorpseESP.showDistance then
        local bb = Instance.new("BillboardGui")
        bb.Name="AdvCorpseBillboard"
        bb.Adornee=primary
        bb.Size=UDim2.new(0,200,0,50)
        bb.StudsOffset=Vector3.new(0,3,0)
        bb.AlwaysOnTop=true
        bb.Parent=m
        if advCorpseESP.showNames then
            local nl = Instance.new("TextLabel")
            nl.Name="CorpseName"
            nl.Size=UDim2.new(1,0,0,20)
            nl.BackgroundTransparency=1
            nl.TextSize=12
            nl.TextColor3=advCorpseESP.nameColor
            nl.TextStrokeTransparency=0.5
            nl.Font=Enum.Font.Code
            nl.Text=m.Name.."'s Corpse"
            nl.Parent=bb
        end
        if advCorpseESP.showDistance then
            local dl = Instance.new("TextLabel")
            dl.Name="CorpseDistance"
            dl.Size=UDim2.new(1,0,0,20)
            dl.Position=UDim2.new(0,0,0,16)
            dl.BackgroundTransparency=1
            dl.TextSize=11
            dl.TextColor3=advCorpseESP.distanceColor
            dl.TextStrokeTransparency=0.5
            dl.Font=Enum.Font.Code
            dl.Text="..."
            dl.Parent=bb
        end
    end
end
local function clearAllAdvCorpse()
    if AR2_Corpses then
        for _,m in ipairs(AR2_Corpses:GetChildren()) do
            if m:IsA("Model") then removeAdvCorpseElements(m) end
        end
    end
end
local function updateAdvCorpse()
    if not advCorpseESP.enabled or not AR2_Corpses then return end
    local camPos = AR2_Camera.CFrame.Position
    for _,m in ipairs(AR2_Corpses:GetChildren()) do
        if m:IsA("Model") and not isInfected(m) then
            local primary = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
            if primary then
                local dist = (camPos - primary.Position).Magnitude
                local inRange = dist <= advCorpseESP.maxDistance
                local hl = m:FindFirstChild("AdvCorpseHighlight")
                if hl then hl.Enabled = inRange end
                local bb = m:FindFirstChild("AdvCorpseBillboard")
                if bb then
                    bb.Enabled = inRange
                    local nl = bb:FindFirstChild("CorpseName")
                    if nl then nl.Visible = advCorpseESP.showNames and inRange end
                    local dl = bb:FindFirstChild("CorpseDistance")
                    if dl then
                        dl.Visible = advCorpseESP.showDistance and inRange
                        if inRange then dl.Text = "["..math.floor(dist).."m]" end
                    end
                end
            end
        end
    end
end
function toggleAdvCorpseESP(enabled)
    advCorpseESP.enabled = enabled
    if enabled then
        AR2_CFG.corpses.on = false
        AR2_esp.update()
        if AR2_Corpses then
            for _,m in ipairs(AR2_Corpses:GetChildren()) do
                if m:IsA("Model") then applyAdvCorpse(m) end
            end
        end
        if not advCorpseChildAddedConn and AR2_Corpses then
            advCorpseChildAddedConn = AR2_Corpses.ChildAdded:Connect(function(c)
                if advCorpseESP.enabled and c:IsA("Model") then applyAdvCorpse(c) end
            end)
        end
        if not advCorpseConn then
            advCorpseConn = AR2_RunService.RenderStepped:Connect(updateAdvCorpse)
        end
    else
        if advCorpseConn then advCorpseConn:Disconnect() advCorpseConn=nil end
        if advCorpseChildAddedConn then advCorpseChildAddedConn:Disconnect() advCorpseChildAddedConn=nil end
        clearAllAdvCorpse()
    end
end
function setAdvCorpseSetting(key,value)
    advCorpseESP[key]=value
    if advCorpseESP.enabled then
        if AR2_Corpses then
            for _,m in ipairs(AR2_Corpses:GetChildren()) do
                if m:IsA("Model") then applyAdvCorpse(m) end
            end
        end
        updateAdvCorpse()
    end
end


function AR2_getClosestPlayerInFOV()
    local cam = Workspace.CurrentCamera
    local c = AR2_CFG.aim
    local centre = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local best, bestDist = nil, c.fov
    local myPos = cam.CFrame.Position
    for _, player in ipairs(AR2_Players:GetPlayers()) do
        if player ~= AR2_LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local dist3D = (myPos - head.Position).Magnitude
                if dist3D <= c.maxDist then
                    local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local flat = (Vector2.new(screenPos.X, screenPos.Y) - centre).Magnitude
                        if flat < bestDist then bestDist = flat best = player end
                    end
                end
            end
        end
    end
    return best
end

AR2_aim = { aiming = false, target = nil, hasMouseMove = false }
AR2_aimConn = nil
AR2_fovCircle = nil
AR2_mousemoverel = mousemoverel or (syn and syn.mousemoverel) or (Input and Input.mousemoverel)
AR2_aim.hasMouseMove = AR2_mousemoverel ~= nil
AR2_AIM_PARTS = { "HeadCollider", "Head", "UpperTorso", "Root" }
AR2_MAGIC_AIM_PARTS = { "Head", "UpperTorso", "Root" }

function AR2_heldKey(name)
    if name == "MouseButton1" then return AR2_UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
    if name == "MouseButton2" then return AR2_UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    if name == "MouseButton3" then return AR2_UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) end
    local code = Enum.KeyCode[name]
    return code ~= nil and AR2_UserInputService:IsKeyDown(code)
end

function AR2_aimPartOf(entity, preference)
    if preference == "HeadCollider" then return entity.headCollider or entity.head or entity.torso or entity.root
    elseif preference == "Head" then return entity.head or entity.torso or entity.root
    elseif preference == "UpperTorso" then return entity.torso or entity.root end
    return entity.root
end

function AR2_isVisible(model, part)
    if not part then return false end
    local cam = Workspace.CurrentCamera
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { AR2_LocalPlayer.Character, model }
    local origin = cam.CFrame.Position
    return AR2_Workspace:Raycast(origin, part.Position - origin, params) == nil
end

function AR2_getTarget(mousePos)
    local cam = Workspace.CurrentCamera
    local c = AR2_CFG.aim
    local best, bestPart, bestDist = nil, nil, c.fov
    local pool = {}
    if c.players then for _, e in ipairs(AR2_api.players()) do pool[#pool+1] = e end end
    if c.zombies then for _, e in ipairs(AR2_api.zombies()) do pool[#pool+1] = e end end
    for _, entity in ipairs(pool) do
        if entity.distance <= c.maxDist then
            local part = AR2_aimPartOf(entity, c.part)
            if part then
                local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    local flat = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if flat < bestDist then
                        if not c.wallCheck or AR2_isVisible(entity.model, part) then
                            best, bestPart, bestDist = entity, part, flat
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

function AR2_stepAim()
    local cam = Workspace.CurrentCamera
    local c = AR2_CFG.aim
    local mousePos = AR2_UserInputService:GetMouseLocation()
    AR2_aim.aiming = c.on and AR2_heldKey(c.key)
    if AR2_fovCircle then
        AR2_fovCircle.Visible = c.on and c.showFov
        if AR2_fovCircle.Visible then
            AR2_fovCircle.Radius = c.fov
            AR2_fovCircle.Position = mousePos
            AR2_fovCircle.Color = AR2_aim.aiming and Color3.fromRGB(255,80,90) or Color3.fromRGB(255,200,40)
        end
    end
    if not AR2_aim.aiming then AR2_aim.target = nil return end
    local entity, part = AR2_getTarget(mousePos)
    AR2_aim.target = entity
    if not part then return end
    local screenPos = cam:WorldToViewportPoint(part.Position)
    local delta = Vector2.new(screenPos.X, screenPos.Y) - mousePos
    local smooth = math.clamp(c.smooth / 100, 0.01, 1)
    if AR2_mousemoverel and AR2_CAP.mousemoverel then
        pcall(AR2_mousemoverel, delta.X * smooth, delta.Y * smooth)
    else
        local desired = CFrame.new(cam.CFrame.Position, part.Position)
        cam.CFrame = cam.CFrame:Lerp(desired, smooth)
    end
end

function AR2_aim.start()
    if AR2_aimConn then return end
    if AR2_hasDrawing and not AR2_fovCircle then
        AR2_fovCircle = Drawing.new("Circle")
        AR2_fovCircle.Thickness, AR2_fovCircle.Filled, AR2_fovCircle.Transparency = 1, false, 1
        AR2_fovCircle.NumSides, AR2_fovCircle.Visible = 64, false
    end
    AR2_aimConn = AR2_RunService.RenderStepped:Connect(function()
        local ok, err = pcall(AR2_stepAim)
        if not ok then warn("[aim] " .. tostring(err)) end
    end)
end

function AR2_aim.stop()
    if AR2_aimConn then AR2_aimConn:Disconnect() AR2_aimConn = nil end
    AR2_aim.aiming, AR2_aim.target = false, nil
    if AR2_fovCircle then AR2_fovCircle.Visible = false end
end

function AR2_aim.destroy()
    AR2_aim.stop()
    if AR2_fovCircle then AR2_fovCircle:Remove() AR2_fovCircle = nil end
end


AR2_getgc = getgc or (debug and debug.getgc)
AR2_getinfo = (debug and debug.getinfo) or getinfo
AR2_getupvalues = (debug and debug.getupvalues) or getupvalues
AR2_islclosure = islclosure
AR2_hookfunction = hookfunction or (syn and syn.hookfunction) or replaceclosure

AR2_magicAim = { supported = (AR2_CAP.getgc == true), shots = 0, redirected = 0, lastBend = 0, target = nil, lastSpeed = nil, widestRefused = 0 }
AR2_magicCircle = nil
AR2_magicConn = nil
AR2_magicLockLine = nil

function AR2_getEquippedItemName()
    local ok, pc = pcall(function()
        return require(AR2_ReplicatedFirst:WaitForChild("Framework", 30)).Classes.Players.get()
    end)
    if ok and pc and pc.Character then
        local item = pc.Character.EquippedItem
        if item then
            local inner = rawget(item, "__item") or item
            if inner.ItemName then return inner.ItemName end
            if inner.Name then return inner.Name end
            if inner.WeaponName then return inner.WeaponName end
            for _, child in ipairs(item:GetChildren()) do
                if child:IsA("Tool") then return child.Name end
            end
        end
    end
    local char = AR2_LocalPlayer.Character
    if char then
        local animator = char:FindFirstChild("Animator")
        if animator then
            local eq = animator:FindFirstChild("EquippedItem")
            if eq and eq:IsA("ValueBase") then
                local raw = eq.Value
                if type(raw) == "string" and raw ~= "" then return raw end
                if type(raw) == "table" then return raw.ItemName or raw.Name end
            end
        end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then return tool.Name end
        end
    end
    local backpack = AR2_LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then return tool.Name end
        end
    end
    return nil
end

function AR2_getItemDataModule()
    local replicated = AR2_ReplicatedStorage
    local client = replicated:FindFirstChild("Client")
    if client then
        local configs = client:FindFirstChild("Configs")
        if configs then
            local itemData = configs:FindFirstChild("ItemData")
            if itemData then
                local ok, ItemData = pcall(require, itemData)
                if ok and type(ItemData) == "table" then return ItemData end
            end
        end
    end
    for _, obj in ipairs(replicated:GetDescendants()) do
        if obj:IsA("ModuleScript") and obj.Name == "ItemData" then
            local ok, ItemData = pcall(require, obj)
            if ok and type(ItemData) == "table" then return ItemData end
        end
    end
    return nil
end

function AR2_getBulletSpeed()
    local c = AR2_CFG.magicAim
    local base

    if not c.autoSpeed and c.bulletSpeed and c.bulletSpeed > 0 then
        base = c.bulletSpeed
    else
        local weaponName = AR2_getEquippedItemName()
        if weaponName then
            local ItemData = AR2_getItemDataModule()
            if ItemData and ItemData[weaponName] and ItemData[weaponName].FireConfig then
                local speed = ItemData[weaponName].FireConfig.MuzzleVelocity
                if type(speed) == "number" and speed > 100 then base = speed end
            end
        end
        base = base or 4700
    end


    return base
end


AR2_gravSeen = AR2_gravSeen or {}
local function AR2_reportBallistics(name, fcGrav, fcDrop, muzzle, resolved)
    if not name or AR2_gravSeen[name] then return end
    AR2_gravSeen[name] = true
    print(string.format(
        "[AR2 BALLISTICS] %s | fc.Gravity=%s fc.BulletDrop=%s MuzzleVelocity=%s | using g=%.1f (world=%.1f) -- %s",
        tostring(name), tostring(fcGrav), tostring(fcDrop), tostring(muzzle),
        resolved, AR2_Workspace.Gravity,
        (fcGrav ~= nil or fcDrop ~= nil) and "from the weapon"
            or "weapon declares none, using world gravity"))
end

function AR2_getBulletGravity()
    local g = nil
    local fcGrav, fcDrop, muzzle = nil, nil, nil
    local weaponName = AR2_getEquippedItemName()
    if weaponName then
        local ItemData = AR2_getItemDataModule()
        local fc = ItemData and ItemData[weaponName] and ItemData[weaponName].FireConfig
        if fc then
            fcGrav, fcDrop, muzzle = fc.Gravity, fc.BulletDrop, fc.MuzzleVelocity
            local v = fc.Gravity
            if type(v) ~= "number" then v = fc.BulletDrop end
            if type(v) == "number" and v > 0 then
                g = (v < 20) and (AR2_Workspace.Gravity * v) or v
            elseif type(v) == "number" and v == 0 then
                g = 0
            end
        end
    end


    if g == nil then g = AR2_Workspace.Gravity * 0.6 end
    AR2_reportBallistics(weaponName, fcGrav, fcDrop, muzzle, g)
    return g
end

function AR2_predict(part, origin, velocity)
    if not part then return origin end
    local speed = AR2_getBulletSpeed()
    if not speed or speed <= 0 then return part.Position end
    velocity = velocity or Vector3.zero
    local c = AR2_CFG.magicAim


    local g = 0
    if c.dropComp then
        g = AR2_getBulletGravity()
    end


    local vy = velocity.Y
    if math.abs(vy) < 12 then vy = 0 end


    local hx, hz = velocity.X, velocity.Z
    if math.sqrt(hx * hx + hz * hz) < 2 then hx, hz = 0, 0 end

    local vLead = Vector3.new(hx, vy, hz)

    local base   = part.Position
    local point  = base
    local flight = (point - origin).Magnitude / speed
    for _ = 1, 8 do
        point = base + vLead * flight
        if g > 0 then
            point = point + Vector3.new(0, 0.5 * g * flight * flight, 0)
        end
        local newFlight = (point - origin).Magnitude / speed
        if math.abs(newFlight - flight) < 0.001 then break end
        flight = newFlight
    end

    return point
end

function AR2_findBestOrigin(origin, direction, targetPos, targetChar)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { AR2_LocalPlayer.Character, targetChar }
    local dirs = {
        Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,1,0), Vector3.new(0,-1,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1)
    }
    for x=-1,1 do for y=-1,1 do for z=-1,1 do
        if math.abs(x)+math.abs(y)+math.abs(z) > 1 then table.insert(dirs, Vector3.new(x,y,z).Unit) end
    end end end
    table.insert(dirs, direction.Unit)
    local bestOrigin = origin
    local bestScore = -math.huge
    local foundClear = false
    local maxRadius = math.min(AR2_CFG.magicBullet.searchRadius, 12)
    local stepSize = math.max(0.3, maxRadius/30)
    for _, dir in ipairs(dirs) do
        for step = stepSize, maxRadius, stepSize do
            local newOrigin = origin + dir*step
            local result = AR2_Workspace:Raycast(newOrigin, (targetPos-newOrigin).Unit * (targetPos-newOrigin).Magnitude, rayParams)
            if not result then
                if not foundClear then bestOrigin = newOrigin foundClear = true end
            else
                if not foundClear then
                    local dist = (newOrigin - result.Position).Magnitude
                    if dist > bestScore then bestScore = dist bestOrigin = newOrigin end
                end
            end
        end
    end
    if foundClear then return bestOrigin, true end
    return bestOrigin, false
end

function AR2_magicTarget()
    local cam = Workspace.CurrentCamera
    local c = AR2_CFG.magicAim
    local centre = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local best, bestPart, bestScore = nil, nil, (c.ignoreFov and math.huge or c.fov)
    local pool = {}
    if c.players then
        for _, e in ipairs(AR2_api.players()) do
            local isTeammate = false
            if c.noTeammate and e.player then
                if AR2_isSquadmate(e.player) then isTeammate = true end
            end
            if not isTeammate then pool[#pool+1] = e end
        end
    end
    if c.zombies then for _, e in ipairs(AR2_api.zombies()) do pool[#pool+1] = e end end
    for _, entity in ipairs(pool) do
        if entity.distance <= c.maxDist then
            local part = AR2_aimPartOf(entity, c.part)
            if part then
                local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                if c.ignoreFov or (onScreen and screenPos.Z > 0) then
                    local score = c.ignoreFov and entity.distance or (centre - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if score < bestScore then
                        if not c.visCheck or AR2_isVisible(entity.model, part) then
                            best, bestPart, bestScore = entity, part, score
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

function AR2_magicUpdate()
    local shouldRun = AR2_CFG.magicAim.on and (AR2_CFG.magicAim.showFov or AR2_CFG.magicAim.showLockLine)
    if shouldRun and not AR2_magicConn then
        if not AR2_hasDrawing then return end
        AR2_magicCircle = Drawing.new("Circle")
        AR2_magicCircle.Thickness, AR2_magicCircle.Filled, AR2_magicCircle.Transparency = 1, false, 1
        AR2_magicCircle.NumSides, AR2_magicCircle.Visible = 64, true
        AR2_magicLockLine = Drawing.new("Line")
        AR2_magicLockLine.Thickness, AR2_magicLockLine.Transparency, AR2_magicLockLine.Visible = 1, 1, false
        AR2_magicConn = AR2_RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
            local centre = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            local entity, part = AR2_magicTarget()
            AR2_magicAim.target = entity
            if AR2_CFG.magicAim.showFov then
                AR2_magicCircle.Position = centre
                AR2_magicCircle.Radius = AR2_CFG.magicAim.fov
                AR2_magicCircle.Color = AR2_magicAim.target and Color3.fromRGB(255,80,90) or Color3.fromRGB(150,90,200)
                AR2_magicCircle.Visible = true
            else AR2_magicCircle.Visible = false end
            if AR2_CFG.magicAim.showLockLine then
                if part then
                    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                        AR2_magicLockLine.From = centre
                        AR2_magicLockLine.To = Vector2.new(screenPos.X, screenPos.Y)
                        AR2_magicLockLine.Color = Color3.fromRGB(255,80,90)
                        AR2_magicLockLine.Visible = true
                    else AR2_magicLockLine.Visible = false end
                else AR2_magicLockLine.Visible = false end
            else AR2_magicLockLine.Visible = false end
        end)
    elseif not shouldRun and AR2_magicConn then
        AR2_magicConn:Disconnect()
        AR2_magicConn = nil
        if AR2_magicCircle then AR2_magicCircle.Visible = false end
        if AR2_magicLockLine then AR2_magicLockLine.Visible = false end
    end
end

function AR2_toggleWorldwide(enabled)
    AR2_CFG.magicAim.ignoreFov = enabled
    AR2_magicUpdate()
end


local AR2_antiAimConn   = nil
local AR2_antiAimCenter = nil
local AR2_antiAimAngle  = 0

function AR2_startAntiAim()
    if AR2_antiAimConn then return end
    local root = AR2_tpRoot()
    if not root then return end
    AR2_antiAimCenter = root.Position
    AR2_antiAimAngle  = 0
    AR2_antiAimConn = AR2_RunService.Heartbeat:Connect(function(dt)
        if not AR2_CFG.misc.antiAim.enabled then AR2_stopAntiAim() return end
        local r = AR2_tpRoot()
        if not r then return end
        local c = AR2_CFG.misc.antiAim
        local offset
        if c.mode == "Jitter" then
            local angle = math.random() * math.pi * 2
            local dist  = math.random() * c.radius
            offset = Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
        else
            AR2_antiAimAngle = (AR2_antiAimAngle + dt * c.speed * (math.pi * 2)) % (math.pi * 2)
            offset = Vector3.new(math.cos(AR2_antiAimAngle) * c.radius, 0, math.sin(AR2_antiAimAngle) * c.radius)
        end
        r.CFrame                   = CFrame.new(AR2_antiAimCenter + offset)
        r.AssemblyLinearVelocity   = Vector3.zero
        r.AssemblyAngularVelocity  = Vector3.zero
    end)
end

function AR2_stopAntiAim()
    AR2_CFG.misc.antiAim.enabled = false
    if AR2_antiAimConn then AR2_antiAimConn:Disconnect() AR2_antiAimConn = nil end
    local r = AR2_tpRoot()
    if r and AR2_antiAimCenter then
        r.CFrame = CFrame.new(AR2_antiAimCenter)
        r.AssemblyLinearVelocity  = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
    AR2_antiAimCenter = nil
end

function AR2_toggleAntiAim(enabled)
    AR2_CFG.misc.antiAim.enabled = enabled
    if enabled then AR2_startAntiAim() else AR2_stopAntiAim() end
end


local AR2_instantInteractEnabled = false
local AR2_instantInteractOriginal = nil

function AR2_setInstantInteract(enabled)
    AR2_instantInteractEnabled = enabled
    AR2_CFG.misc.instantInteract = enabled
    if enabled then
        local Fw = require(AR2_ReplicatedFirst:WaitForChild("Framework", 30))
        local Interactables = Fw.Classes.Interactables
        if Interactables and Interactables.GetInteractPromptData then
            if not AR2_instantInteractOriginal then
                AR2_instantInteractOriginal = Interactables.GetInteractPromptData
            end
            Interactables.GetInteractPromptData = function(...)
                local data = AR2_instantInteractOriginal(...)
                if data and data.Actions then
                    for _, action in ipairs(data.Actions) do action.Time = 0 end
                end
                return data
            end
        end
    else
        if AR2_instantInteractOriginal then
            local Fw = require(AR2_ReplicatedFirst:WaitForChild("Framework", 30))
            local Interactables = Fw.Classes.Interactables
            if Interactables then Interactables.GetInteractPromptData = AR2_instantInteractOriginal end
            AR2_instantInteractOriginal = nil
        end
    end
end


local AR2_playerJesusEnabled = false
function AR2_setPlayerJesus(enabled)
    AR2_playerJesusEnabled = enabled
    AR2_CFG.misc.playerJesus = enabled
    local waterFolder = AR2_Workspace:FindFirstChild("Map") and AR2_Workspace.Map:FindFirstChild("Water") or AR2_Workspace:FindFirstChild("Water")
    if not waterFolder then return end
    for _, part in ipairs(waterFolder:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if enabled then
                if part:HasTag("Swim Surface") then
                    part:RemoveTag("Swim Surface")
                    part:AddTag("Player Jesus")
                end
            else
                if part:HasTag("Player Jesus") then
                    part:RemoveTag("Player Jesus")
                    part:AddTag("Swim Surface")
                end
            end
        end
    end
end


AR2_hitSoundId      = nil
AR2_hitSoundOrig    = nil
AR2_hitSoundKeep    = nil
AR2_hitSoundApplied = nil

local function AR2_impactSounds()
    local rs = game:GetService("ReplicatedStorage")
    local assets = rs:FindFirstChild("Assets")
    if not assets then return nil, nil end
    local sounds = assets:FindFirstChild("Sounds")
    if not sounds then return nil, nil end
    local impact = sounds:FindFirstChild("Impact")
    if not impact then return nil, nil end
    local head = impact:FindFirstChild("Headshot")
    local body = impact:FindFirstChild("Bodyshot")
    return head, body
end

local function AR2_resolveHitSoundId(input)
    if not input or input == "" or input == "None" then return nil end
    if string.find(input, "rbxassetid://", 1, true)
    or string.find(input, "rbxasset://",   1, true) then
        return input
    end
    if tonumber(input) then
        return "rbxassetid://" .. input
    end
    local gca = getcustomasset or getsynasset
    if typeof(gca) ~= "function" then
        warn("[hitmarker] no getcustomasset — can't load local file: " .. input)
        return nil
    end
    if typeof(isfile) == "function" then
        local exists = false
        pcall(function() exists = isfile(input) end)
        if not exists then
            warn("[hitmarker] file not found: " .. input)
            return nil
        end
    end
    local ok, result = pcall(gca, input)
    if not ok or not result then
        warn("[hitmarker] getcustomasset failed for " .. input .. ": " .. tostring(result))
        return nil
    end
    return result
end

function AR2_hitSoundLoad(input)
    if AR2_hitSoundKeep then
        pcall(function() AR2_hitSoundKeep:Disconnect() end)
        AR2_hitSoundKeep = nil
    end
    local head, body = AR2_impactSounds()
    if not head and not body then
        warn("[hitmarker] Impact sounds not found in ReplicatedStorage")
        return
    end
    if AR2_hitSoundOrig == nil then
        AR2_hitSoundOrig = {
            head = head and head.SoundId or nil,
            body = body and body.SoundId or nil,
        }
    end
    if not input or input == "" then
        local id   = AR2_CFG.hitmarker.sound
        local path = AR2_CFG.hitmarker.soundPath
        if path and path ~= "" then
            input = path
        elseif id and id ~= "" and id ~= "None" and id ~= "Custom..." then
            input = id
        else
            input = "None"
        end
    end
    if not input or input == "" or input == "None" then
        AR2_hitSoundApplied = nil
        AR2_hitSoundId      = nil
        if head and AR2_hitSoundOrig.head then head.SoundId = AR2_hitSoundOrig.head end
        if body and AR2_hitSoundOrig.body then body.SoundId = AR2_hitSoundOrig.body end
        return
    end
    local resolved = AR2_resolveHitSoundId(input)
    if not resolved then return end
    local vol = math.clamp((AR2_CFG.misc.hitSoundVolume or 70) / 100, 0, 10)
    if head then
        head.SoundId = resolved
        pcall(function() head.Volume = vol end)
    end
    if body then
        body.SoundId = resolved
        pcall(function() body.Volume = vol end)
    end
    AR2_hitSoundApplied = resolved
    AR2_hitSoundId      = input
    AR2_hitSoundKeep = AR2_RunService.RenderStepped:Connect(function()
        local h, b = AR2_impactSounds()
        local want = AR2_hitSoundApplied
        if not want then return end
        local v = math.clamp((AR2_CFG.misc.hitSoundVolume or 70) / 100, 0, 10)
        if h then
            if h.SoundId ~= want then h.SoundId = want end
            if h.Volume  ~= v    then pcall(function() h.Volume = v end) end
        end
        if b then
            if b.SoundId ~= want then b.SoundId = want end
            if b.Volume  ~= v    then pcall(function() b.Volume = v end) end
        end
    end)
end

function AR2_hitSoundReload()
    AR2_hitSoundLoad(AR2_hitSoundId)
end


AR2_ibEnabled       = false
AR2_ibAdapt         = true
AR2_ibMult          = 2
AR2_ibSeeded        = false
AR2_ibLastSpd       = nil
AR2_ibShotsFired    = 0
AR2_ibHitsConfirmed = 0
AR2_ibLastEval      = os.clock()
AR2_ibLastHitTime   = 0
AR2_ibHistory       = {}

AR2_IB_CFG = {
    targetTravelMs  = 50,
    stepUpPct       = 0.10,
    stepDownPct     = 0.20,
    windowSecs      = 5,
    missThresh      = 0.65,
    goodThresh      = 0.88,
    maxMult         = 5,
    minMult         = 1,
    velocityCap     = true,
    velCapSlow      = 2,
    velCapFast      = 5,
    seedDistance    = 400,
}

function AR2_ibVelocityCap(spd)
    if not AR2_IB_CFG.velocityCap then return AR2_IB_CFG.maxMult end
    if not spd or spd <= 0 then return AR2_IB_CFG.velCapSlow end
    local t = math.clamp((spd - 1500) / 3500, 0, 1)
    return math.floor(AR2_IB_CFG.velCapSlow + (AR2_IB_CFG.velCapFast - AR2_IB_CFG.velCapSlow) * t)
end

function AR2_ibSeedMult(spd, dist)
    if AR2_ibSeeded or spd <= 0 or dist <= 0 then return end
    local targetSecs  = AR2_IB_CFG.targetTravelMs / 1000
    local naturalSecs = dist / spd
    local ideal       = naturalSecs / targetSecs
    local cap         = AR2_ibVelocityCap(spd)
    AR2_ibMult = math.max(AR2_IB_CFG.minMult, math.min(cap, math.floor(ideal)))
    AR2_ibSeeded = true
end

function AR2_ibEvaluate()
    local now = os.clock()
    if now - AR2_ibLastEval < AR2_IB_CFG.windowSecs then return end
    if AR2_ibShotsFired == 0 then AR2_ibLastEval = now return end

    local rate = AR2_ibHitsConfirmed / AR2_ibShotsFired
    table.insert(AR2_ibHistory, {
        mult = AR2_ibMult, rate = rate,
        shots = AR2_ibShotsFired,
        confirmed = AR2_ibHitsConfirmed,
        spd = AR2_ibLastSpd,
    })

    local cap = AR2_ibVelocityCap(AR2_ibLastSpd)

    if AR2_ibAdapt then
        if rate >= AR2_IB_CFG.goodThresh then
            local step = math.max(1, math.floor(AR2_ibMult * AR2_IB_CFG.stepUpPct))
            AR2_ibMult = math.min(cap, AR2_ibMult + step)
        elseif rate < AR2_IB_CFG.missThresh then
            local step = math.max(1, math.floor(AR2_ibMult * AR2_IB_CFG.stepDownPct))
            AR2_ibMult = math.max(AR2_IB_CFG.minMult, AR2_ibMult - step)
        end
    end

    if AR2_ibMult > cap then AR2_ibMult = cap end

    AR2_ibShotsFired    = 0
    AR2_ibHitsConfirmed = 0
    AR2_ibLastEval      = now
end

AR2_ibSeedHP  = {}
AR2_ibDedupeT = {}
local function AR2_ibStartHitConfirm()
    for _, obj in ipairs(AR2_ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            obj.OnClientEvent:Connect(function(...)
                local args = {...}
                if args[1] ~= "Character State Sync" then return end
                local data = args[2]
                if type(data) ~= "table" or not data.Seed then return end
                local seed = data.Seed
                local now  = os.clock()
                if AR2_ibDedupeT[seed]
                and now - AR2_ibDedupeT[seed] < 0.15 then return end
                AR2_ibDedupeT[seed] = now
                local hp = nil
                pcall(function()
                    if data.Stats and data.Stats.Health then
                        hp = data.Stats.Health.Value
                    end
                end)
                if not hp then return end
                local prev = AR2_ibSeedHP[seed]
                AR2_ibSeedHP[seed] = hp
                if prev and hp < prev
                and now - AR2_ibLastHitTime < 3 then
                    AR2_ibHitsConfirmed = AR2_ibHitsConfirmed + 1
                end
            end)
        end
    end
end


AR2_originalFireModesCache = {}
AR2_allFireModesConn = nil
AR2_allFireModes_table = { "Automatic", "Semiautomatic", "Burst" }

function AR2_getEquippedInner()
    local ok, pc = pcall(function()
        return require(AR2_ReplicatedFirst:WaitForChild("Framework", 30)).Classes.Players.get()
    end)
    if not ok or not pc or not pc.Character then return nil end
    local item = pc.Character.EquippedItem
    if not item then return nil end
    return rawget(item, "__item") or item
end

function AR2_applyToInner(inner)
    if not inner then return end
    local id = tostring(inner.Id or inner.ItemName or inner.Name or "unknown")
    if not AR2_originalFireModesCache[id] then
        AR2_originalFireModesCache[id] = inner.FireModes
    end
    inner.FireModes = AR2_allFireModes_table
    return inner
end

function AR2_applyAllFireModes(enabled)
    AR2_CFG.weapon.allFireModes = enabled
    if AR2_allFireModesConn then
        AR2_allFireModesConn:Disconnect()
        AR2_allFireModesConn = nil
    end
    if not enabled then
        local inner = AR2_getEquippedInner()
        if inner then
            local id = tostring(inner.Id or inner.ItemName or inner.Name or "unknown")
            inner.FireModes = AR2_originalFireModesCache[id] or inner.FireModes
        end
        return
    end
    local lastInner = AR2_applyToInner(AR2_getEquippedInner())
    AR2_allFireModesConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_CFG.weapon.allFireModes then return end
        local inner = AR2_getEquippedInner()
        if inner and inner ~= lastInner then lastInner = AR2_applyToInner(inner) end
    end)
end


AR2_personalGunOriginal = {}
AR2_personalGunConn = nil

function AR2_findLocalGun()
    local char = AR2_LocalPlayer.Character
    if not char then return nil end
    local equipped = char:FindFirstChild("Equipped")
    if equipped then
        for _, child in ipairs(equipped:GetChildren()) do
            if child:IsA("Model") or child:IsA("Tool") then return child end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then return child end
    end
    local cam = workspace.CurrentCamera
    if cam then
        for _, child in ipairs(cam:GetChildren()) do
            if child:IsA("Model") and (child.Name:lower():find("gun") or child.Name:lower():find("weapon") or child.Name:lower():find("viewmodel")) then
                return child
            end
        end
    end
    return nil
end

function AR2_setPersonalGun(enabled, mode, hue, gray, material, rainbow)
    AR2_CFG.misc.personalGunOn       = enabled and true or false
    AR2_CFG.misc.personalGunMode     = mode or AR2_CFG.misc.personalGunMode
    AR2_CFG.misc.personalGunHue      = hue or AR2_CFG.misc.personalGunHue
    AR2_CFG.misc.personalGunGray     = gray or AR2_CFG.misc.personalGunGray
    AR2_CFG.misc.personalGunMaterial = material or AR2_CFG.misc.personalGunMaterial
    AR2_CFG.misc.personalGunRainbow  = rainbow and true or false

    if AR2_personalGunConn then AR2_personalGunConn:Disconnect() AR2_personalGunConn = nil end

    local function restore()
        for part, orig in pairs(AR2_personalGunOriginal) do
            if part and part.Parent then
                pcall(function()
                    part.Color        = orig.Color
                    part.Material     = orig.Material
                    part.Transparency = orig.Transparency
                end)
            end
        end
        AR2_personalGunOriginal = {}
    end

    if not enabled then restore() return end

    local function applyNow()
        local gun = AR2_findLocalGun()
        if not gun then return end

        local col
        if AR2_CFG.misc.personalGunRainbow then
            AR2_CFG.misc.personalGunHue = (AR2_CFG.misc.personalGunHue + 3) % 360
            col = Color3.fromHSV(AR2_CFG.misc.personalGunHue / 360, 1, 1)
        elseif AR2_CFG.misc.personalGunMode == "BlackWhite" then
            local g = (AR2_CFG.misc.personalGunGray or 100) / 100
            col = Color3.fromRGB(g * 255, g * 255, g * 255)
        else
            col = Color3.fromHSV((AR2_CFG.misc.personalGunHue or 0) / 360, 1, 1)
        end

        local mat = Enum.Material[AR2_CFG.misc.personalGunMaterial] or Enum.Material.Neon

        for _, part in ipairs(gun:GetDescendants()) do
            if part:IsA("BasePart") then
                if not AR2_personalGunOriginal[part] then
                    AR2_personalGunOriginal[part] = {
                        Color        = part.Color,
                        Material     = part.Material,
                        Transparency = part.Transparency,
                    }
                end
                part.Color    = col
                part.Material = mat
            end
        end
    end

    applyNow()
    AR2_personalGunConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_CFG.misc.personalGunOn then return end
        applyNow()
    end)
end


local AR2_instantReloadEnabled = false
local AR2_instantReloadHooked = false
local AR2_instantReloadEquipConn = nil
local AR2_instantReloadOriginalMap = {}

local function AR2_getPlayerClass()
    local ok, pc = pcall(function()
        return require(AR2_ReplicatedFirst:WaitForChild("Framework", 30)).Classes.Players.get()
    end)
    return ok and pc or nil
end

local function AR2_instantReloadHook()
    if not AR2_instantReloadEnabled then return end
    if not AR2_CAP.getupvalue then return end
    local pc = AR2_getPlayerClass()
    if not pc or not pc.Character then return end
    local item = pc.Character.EquippedItem
    if not item then return end
    local inner = rawget(item, "__item") or item
    if not inner or type(inner.OnReload) ~= "function" then return end
    if inner.__reloadHooked then return end

    local findReloadAmmo = nil
    for i = 1, 20 do
        local ok, val = pcall(debug.getupvalue, inner.OnReload, i)
        if not ok then break end
        if type(val) == "function" then
            local infoOk, info = pcall(debug.getinfo, val)
            if infoOk and info and info.name == "findReloadAmmo" then findReloadAmmo = val break end
        end
    end
    if not findReloadAmmo then return end

    local originalOnReload = inner.OnReload
    AR2_instantReloadOriginalMap[inner] = originalOnReload

    local Network = nil
    local netOk, netResult = pcall(function()
        return require(AR2_ReplicatedFirst:WaitForChild("Framework", 30)).Libraries.Network
    end)
    if netOk then Network = netResult end

    inner.OnReload = function(gun, charClass, itemData, ...)
        if AR2_instantReloadEnabled then
            local AmmoSelection = findReloadAmmo(gun, charClass, itemData)
            if AmmoSelection then
                if Network then
                    Network:Send('Character Reload Firearm Initiated', gun.Id, AmmoSelection.Id)
                    if gun.FireConfig and gun.FireConfig.InternalMag then
                        for i = 1, gun.FireConfig.InternalMagSize do
                            Network:Send('Character Reload Firearm Committed', gun.Id, AmmoSelection.Id)
                        end
                    else
                        Network:Send('Character Reload Firearm Committed', gun.Id, AmmoSelection.Id)
                    end
                    Network:Send('Character Reload Firearm Clear', gun.Id, AmmoSelection.Id)
                end
            end
            return true
        end
        return originalOnReload(gun, charClass, itemData, ...)
    end

    inner.__reloadHooked = true
end

local function AR2_instantReloadOnEquip()
    if AR2_instantReloadEquipConn then
        AR2_instantReloadEquipConn:Disconnect()
        AR2_instantReloadEquipConn = nil
    end
    local pc = AR2_getPlayerClass()
    if not pc or not pc.Character then return end
    AR2_instantReloadEquipConn = pc.Character.EquipmentChanged:Connect(function()
        task.wait(0.1)
        if AR2_instantReloadEnabled then AR2_instantReloadHook() end
        if AR2_CFG.misc.personalGunOn then
            AR2_setPersonalGun(true, AR2_CFG.misc.personalGunMode, AR2_CFG.misc.personalGunHue, AR2_CFG.misc.personalGunGray, AR2_CFG.misc.personalGunMaterial, AR2_CFG.misc.personalGunRainbow)
        end
        if AR2_CFG.misc.hideGun then AR2_toggleHideGun(true) end
    end)
end

AR2_reloadWatchConn = nil
AR2_reloadWatchLast = 0

function setInstantReloadEnabled(enabled)
    AR2_instantReloadEnabled = enabled
    AR2_CFG.weapon.instantReload = enabled
    if enabled then
        AR2_instantReloadHook()
        AR2_instantReloadOnEquip()
        if not AR2_reloadWatchConn then
            AR2_reloadWatchConn = AR2_RunService.Heartbeat:Connect(function()
                if not AR2_instantReloadEnabled then
                    AR2_reloadWatchConn:Disconnect()
                    AR2_reloadWatchConn = nil
                    return
                end
                local now = os.clock()
                if now - AR2_reloadWatchLast < 4 then return end
                AR2_reloadWatchLast = now
                local pc = AR2_getPlayerClass()
                local actualChar = AR2_LocalPlayer.Character
                if pc and pc.Character ~= actualChar then return end
                local inner = AR2_getEquippedInner()
                if inner and not inner.__reloadHooked then AR2_instantReloadHook() end
            end)
        end
    else
        if AR2_reloadWatchConn then
            AR2_reloadWatchConn:Disconnect()
            AR2_reloadWatchConn = nil
        end
        AR2_reloadWatchLast = 0
        for weapon, origFunc in pairs(AR2_instantReloadOriginalMap) do
            if weapon and type(weapon.OnReload) == "function" then
                weapon.OnReload = origFunc
                weapon.__reloadHooked = nil
            end
        end
        table.clear(AR2_instantReloadOriginalMap)
        if AR2_instantReloadEquipConn then
            AR2_instantReloadEquipConn:Disconnect()
            AR2_instantReloadEquipConn = nil
        end
    end
end

local function AR2_reloadRespawnSetup(newChar)
    task.spawn(function()
        local deadline = os.clock() + 15
        while os.clock() < deadline do
            if not AR2_instantReloadEnabled then return end
            local hum = newChar:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health > 0 and newChar:FindFirstChild("HumanoidRootPart") then
                task.wait(2)
                if not AR2_instantReloadEnabled then return end
                AR2_instantReloadHook()
                AR2_instantReloadOnEquip()
                return
            end
            task.wait(0.25)
        end
        if AR2_instantReloadEnabled then
            AR2_instantReloadHook()
            AR2_instantReloadOnEquip()
        end
    end)
end

AR2_LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if AR2_instantReloadEnabled then AR2_reloadRespawnSetup(newChar) end
    if AR2_CFG.misc.personalCharOn then
        AR2_setPersonalCharacter(true, AR2_CFG.misc.personalCharMode, AR2_CFG.misc.personalCharHue, AR2_CFG.misc.personalCharGray, AR2_CFG.misc.personalCharMaterial, AR2_CFG.misc.personalCharRainbow)
    end
    if AR2_CFG.misc.personalGunOn then
        AR2_setPersonalGun(true, AR2_CFG.misc.personalGunMode, AR2_CFG.misc.personalGunHue, AR2_CFG.misc.personalGunGray, AR2_CFG.misc.personalGunMaterial, AR2_CFG.misc.personalGunRainbow)
    end
    AR2_refreshHideState()
    if AR2_CFG.misc.hideGun then AR2_toggleHideGun(true) end
    if AR2_CFG.misc.cosUnlock then AR2_cosSetEnabled(true) end
end)

if AR2_LocalPlayer.Character then
    task.wait(1)
    if AR2_instantReloadEnabled then AR2_reloadRespawnSetup(AR2_LocalPlayer.Character) end
end


local wallbangTagConn = nil
local AR2_wallbangSaved = {}
local AR2_WALLBANG_GROUPS = { [7]=true, [8]=true, [9]=true, [11]=true, [17]=true }


local function isCharacterPart(part)
    local parent = part.Parent
    while parent do
        if parent:FindFirstChildOfClass("Humanoid") then return true end
        if parent:IsA("Model") and (parent.Parent == AR2_Characters or parent.Parent == AR2_Zombies) then return true end
        parent = parent.Parent
    end
    return false
end

local function tagPart(part)
    if part.Name == "ar2_hbe_head" or part:GetAttribute("ar2_hbe") then return end
    if part:IsA("BasePart") and not isCharacterPart(part) and not AR2_CollectionService:HasTag(part, "Bullets Penetrate") then
        AR2_CollectionService:AddTag(part, "Bullets Penetrate")
    end
end

local function removeCharacterTags(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if AR2_CollectionService:HasTag(part, "Bullets Penetrate") then
                AR2_CollectionService:RemoveTag(part, "Bullets Penetrate")
            end


            local saved = AR2_wallbangSaved[part]
            if saved ~= nil then
                pcall(function() part.CollisionGroupId = saved end)
                AR2_wallbangSaved[part] = nil
            end
        end
    end
end

local function AR2_wallbangForcePart(part)
    if not part:IsA("BasePart") then return end


    if part.Name == "ar2_hbe_head" or part:GetAttribute("ar2_hbe") then return end
    if isCharacterPart(part) then return end


    if AR2_Characters and part:IsDescendantOf(AR2_Characters) then return end
    if AR2_Zombies and part:IsDescendantOf(AR2_Zombies) then return end


    if AR2_Vehicles and part:IsDescendantOf(AR2_Vehicles) then return end
    if part:IsA("VehicleSeat") or part:IsA("Seat") then return end
    if part:FindFirstAncestorWhichIsA("VehicleSeat") then return end
    local gid = part.CollisionGroupId
    if AR2_WALLBANG_GROUPS[gid] then
        AR2_wallbangSaved[part] = gid
        pcall(function() part.CollisionGroupId = 0 end)
    end
    tagPart(part)
end

function startWallbangTagging()
    if wallbangTagConn then return end


    for _, part in ipairs(AR2_Workspace:GetDescendants()) do
        AR2_wallbangForcePart(part)
    end
    local mapFolder = AR2_Workspace:FindFirstChild("Map")
    if mapFolder then
        for _, desc in ipairs(mapFolder:GetDescendants()) do
            AR2_wallbangForcePart(desc)
        end
    end

    wallbangTagConn = AR2_Workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") then
            AR2_wallbangForcePart(desc)
        elseif desc:IsA("Humanoid") then
            local model = desc.Parent
            if model and model:IsA("Model") then removeCharacterTags(model) end
        end
    end)
end

function stopWallbangTagging()
    if wallbangTagConn then wallbangTagConn:Disconnect() wallbangTagConn = nil end
    for part, gid in pairs(AR2_wallbangSaved) do
        pcall(function()
            if part and part.Parent then part.CollisionGroupId = gid end
        end)
    end
    AR2_wallbangSaved = {}
end


AR2_rbLastFire = 0
AR2_lastFireParams = nil
AR2_rbHeld = false
AR2_adsHeld = false
AR2_autoSeeding = false
AR2_autoSeeded = false
AR2_hasRealWD = false
AR2_lastTargetDist = 0
AR2_cachedAmmoItem = nil
local AR2_VIM = game:GetService("VirtualInputManager")


AR2_gameChar = nil

local function AR2_tryCacheAmmoRef(inner)
    if not inner or type(inner) ~= "table" then return end
    pcall(function()
        local att      = rawget(inner, "Attachments") or inner.Attachments
        if not att then return end
        local ammoSlot = rawget(att, "Ammo") or att.Ammo
        if not ammoSlot then return end
        local ammoItem = rawget(ammoSlot, "__item") or ammoSlot
        if ammoItem and ammoItem.WorkingAmount ~= nil then
            AR2_cachedAmmoItem = ammoItem
        end
    end)
end

local function AR2_readAmmoFromInner(inner)
    if not inner or type(inner) ~= "table" then return nil end
    local result = nil
    pcall(function()
        local att = rawget(inner, "Attachments") or inner.Attachments
        if att then
            local ammoSlot = rawget(att, "Ammo") or att.Ammo
            if ammoSlot then
                local ammoItem = rawget(ammoSlot, "__item") or ammoSlot
                if ammoItem then
                    if ammoItem.WorkingAmount ~= nil then result = ammoItem.WorkingAmount; return end
                    if ammoItem.Amount        ~= nil then result = ammoItem.Amount; return end
                end
            end
        end
    end)
    if result ~= nil then return result end
    pcall(function() if inner.WorkingAmount ~= nil then result = inner.WorkingAmount end end)
    if result ~= nil then return result end
    pcall(function() if inner.Magazine      ~= nil then result = inner.Magazine end end)
    return result
end

local function AR2_getAmmoLive()
    local pc = AR2_getPlayerClass()
    if pc and pc.Character then
        local item = pc.Character.EquippedItem
        if item then
            local inner = rawget(item, "__item") or item
            local ammo  = AR2_readAmmoFromInner(inner)
            if ammo ~= nil then return ammo end
        end
    end
    if AR2_lastFireParams and AR2_lastFireParams.wi then
        return AR2_readAmmoFromInner(AR2_lastFireParams.wi)
    end
    return nil
end

local function AR2_getReloading()
    local inner = AR2_getEquippedInner()
    if not inner and AR2_lastFireParams then inner = AR2_lastFireParams.wi end
    if not inner then return false end
    local r = false
    pcall(function() r = inner.Reloading == true end)
    return r
end

local function AR2_getFireInterval(wi)
    if wi and wi.FireConfig and wi.FireConfig.FireRate then
        return math.max(0.05, 60 / wi.FireConfig.FireRate)
    end
    return 0.1
end

local function AR2_releaseVIM()
    if AR2_rbHeld then
        pcall(function() AR2_VIM:SendMouseButtonEvent(0,0,0,false,game,1) end)
        AR2_rbHeld = false
    end
end

local function AR2_releaseADS()
    if AR2_adsHeld then
        pcall(function() AR2_VIM:SendMouseButtonEvent(0,0,1,false,game,1) end)
        AR2_adsHeld = false
    end
end

function AR2_rageBotVisCheck(model, part, origin)
    if not part then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { AR2_LocalPlayer.Character, model }
    params.IgnoreWater = true
    local hit = AR2_Workspace:Raycast(origin, part.Position - origin, params)
    return hit == nil
end

local function AR2_rageBotTarget()
    local cam    = workspace.CurrentCamera
    local rc     = AR2_CFG.rageBot
    local centre = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local best, bestPart, bestScore, bestDist = nil, nil, math.huge, 0
    local origin = AR2_localPosition()

    local Characters = workspace:FindFirstChild("Characters")
    if not Characters then return nil, nil, 0 end

    for _, model in ipairs(Characters:GetChildren()) do
        if model ~= AR2_LocalPlayer.Character and model:IsA("Model") then
            local player = AR2_Players:GetPlayerFromCharacter(model)
            if AR2_CFG.magicAim.noTeammate and player then
                if AR2_isSquadmate(player) then
                    continue
                end
            end

            local part = model:FindFirstChild("HeadCollider")
                      or model:FindFirstChild("Head")
                      or model:FindFirstChild("HumanoidRootPart")
            if part then
                local dist = (part.Position - origin).Magnitude
                if dist <= rc.maxDist then
                    if rc.visCheck and not AR2_CFG.weapon.wallbang then
                        if not AR2_rageBotVisCheck(model, part, origin) then
                            continue
                        end
                    end

                    local score
                    if rc.ignoreFov then
                        score = dist
                    else
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        if not (onScreen and sp.Z > 0) then continue end
                        local px = (centre - Vector2.new(sp.X, sp.Y)).Magnitude
                        if px > rc.fov then continue end
                        score = px
                    end
                    if score < bestScore then
                        best, bestPart, bestScore, bestDist = model, part, score, dist
                    end
                end
            end
        end
    end
    return best, bestPart, bestDist
end

local function AR2_doInventoryFire(part)
    if not AR2_lastFireParams or not AR2_originalFireFunction then return end
    local pc = AR2_lastFireParams.pc
    local wi = AR2_lastFireParams.wi
    local wd = AR2_lastFireParams.wd
    local char = AR2_LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local origin = hrp and (hrp.Position + Vector3.new(0,1.5,0)) or AR2_localPosition()
    local dir = (part.Position - origin).Unit

    local saved, spoofed = nil, false
    pcall(function()
        if pc and pc.Character then
            saved = pc.Character.EquippedItem
            if not saved then
                pc.Character.EquippedItem = wi
                spoofed = true
            end
        end
    end)

    local ok, err = pcall(AR2_originalFireFunction,
        AR2_lastFireParams.self, pc, wi, wd,
        origin, dir, math.random(100000, 999999)
    )

    if spoofed then
        pcall(function()
            if pc and pc.Character then
                pc.Character.EquippedItem = saved
            end
        end)
    end
    if not ok then warn("[ragebot] inv fire failed: " .. tostring(err)) end
end

local function AR2_rageBotStep()
    local c = AR2_CFG.rageBot
    if not c.on then return end

    local inner     = AR2_getEquippedInner()
    local gunOut    = inner ~= nil
    local ammo      = AR2_getAmmoLive()
    local reloading = AR2_getReloading()
    local vimOk     = not reloading and (ammo == nil or ammo > 0)
    local invOk     = not reloading and (ammo == nil or (type(ammo) == "number" and ammo > 0))

    if gunOut and not AR2_hasRealWD then
        pcall(function()
            if not AR2_autoSeeding and not AR2_autoSeeded then
                AR2_autoSeeding = true
                task.spawn(function()
                    pcall(function() AR2_VIM:SendMouseButtonEvent(0,0,0,true,game,1) end)
                    task.wait(0.08)
                    pcall(function() AR2_VIM:SendMouseButtonEvent(0,0,0,false,game,1) end)
                    task.wait(0.3)
                    if not AR2_autoSeeded then AR2_autoSeeding = false end
                end)
            end
        end)
    end

    local entity, part, targetDist = AR2_rageBotTarget()
    local hasTarget = entity ~= nil
    AR2_lastTargetDist = targetDist or 0

    if c.forceADS then
        if hasTarget and AR2_lastTargetDist >= c.adsMinDist and vimOk then
            pcall(function() AR2_VIM:SendMouseButtonEvent(0,0,1,true,game,1) end)
            AR2_adsHeld = true
        else
            AR2_releaseADS()
        end
    end

    if c.requireADS then
        local adsActive = AR2_UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            or (c.forceADS and AR2_adsHeld)
        if not adsActive then AR2_releaseVIM() return end
    end

    if hasTarget then
        if gunOut and vimOk then
            pcall(function() AR2_VIM:SendMouseButtonEvent(0,0,0,true,game,1) end)
            AR2_rbHeld = true
        elseif gunOut and not vimOk then
            AR2_releaseVIM()
        elseif c.inventoryShoot and invOk and AR2_hasRealWD
            and AR2_lastFireParams and AR2_originalFireFunction and part then
            AR2_releaseVIM()
            local now = os.clock()
            if now - AR2_rbLastFire >= AR2_getFireInterval(AR2_lastFireParams.wi) then
                AR2_rbLastFire = now
                AR2_doInventoryFire(part)
            end
        else
            AR2_releaseVIM()
        end
    else
        AR2_releaseVIM()
        if c.forceADS then AR2_releaseADS() end
    end
end

function AR2_rageBotSetEnabled(enabled)
    AR2_CFG.rageBot.on = enabled
    if AR2_rageBotConn then
        AR2_rageBotConn:Disconnect()
        AR2_rageBotConn = nil
    end
    AR2_releaseVIM()
    AR2_releaseADS()
    if enabled then
        task.spawn(function()
            if AR2_getEquippedInner() then
                pcall(function()
                    if not AR2_autoSeeding and not AR2_autoSeeded then
                        AR2_autoSeeding = true
                        task.spawn(function()
                            pcall(function() AR2_VIM:SendMouseButtonEvent(0,0,0,true,game,1) end)
                            task.wait(0.08)
                            pcall(function() AR2_VIM:SendMouseButtonEvent(0,0,0,false,game,1) end)
                            task.wait(0.3)
                            if not AR2_autoSeeded then AR2_autoSeeding = false end
                        end)
                    end
                end)
            else
                warn("[ragebot] no gun out — equip gun briefly to seed real wd for inventory mode")
            end
        end)
        AR2_rageBotConn = AR2_RunService.Heartbeat:Connect(function()
            local ok, err = pcall(AR2_rageBotStep)
            if not ok then warn("[ragebot] " .. tostring(err)) end
        end)
    end
end

function AR2_toggleRageBotWorldwide(enabled)
    AR2_CFG.rageBot.ignoreFov = enabled
end

function AR2_toggleRageBotInventoryShoot(enabled)
    AR2_CFG.rageBot.inventoryShoot = enabled
end


AR2_success, AR2_Bullets = pcall(function()
    return require(AR2_ReplicatedFirst:WaitForChild("Framework", 30)).Libraries.Bullets
end)
AR2_originalFireFunction = nil
AR2_recoilOriginalFn     = nil
AR2_spreadOriginalFn     = nil

if AR2_success and AR2_Bullets and AR2_Bullets.Fire then
    AR2_originalFireFunction = AR2_Bullets.Fire

    if AR2_CAP.getupvalue then
        pcall(function()
            AR2_recoilOriginalFn = debug.getupvalue(AR2_originalFireFunction, 6)
        end)
        pcall(function()
            AR2_spreadOriginalFn = debug.getupvalue(AR2_originalFireFunction, 3)
        end)
    end

    local function AR2_identitySpread(rng, direction)
        return direction.Unit
    end

    AR2_Bullets.Fire = function(self, playerController, weaponInstance, weaponData, origin, direction, shotId)
        AR2_lastFireParams = {
            self = self,
            pc   = playerController,
            wi   = weaponInstance,
            wd   = weaponData,
        }
        AR2_hasRealWD      = true
        AR2_autoSeeded     = true
        AR2_autoSeeding    = false
        AR2_tryCacheAmmoRef(weaponInstance)


        pcall(function()
            AR2_gameChar = playerController and playerController.Character or nil
        end)

        local ok, result = pcall(function()
            local originalOrigin    = origin
            local originalDirection = direction


            local AR2_ibSavedSpd, AR2_ibSavedGrav, AR2_ibSavedDrop = nil, nil, nil
            if AR2_ibEnabled and weaponData then
                AR2_ibEvaluate()
                pcall(function()
                    local fc = weaponData
                    local spd = fc.BulletSpeed
                                or (weaponInstance
                                    and weaponInstance.FireConfig
                                    and weaponInstance.FireConfig.BulletSpeed)
                    if not spd or spd <= 0 then return end

                    AR2_ibLastSpd    = spd
                    AR2_ibShotsFired = AR2_ibShotsFired + 1

                    local bestDist = 400
                    local Characters = AR2_Workspace:FindFirstChild("Characters")
                    if Characters then
                        local dir = direction.Unit
                        local minLat = 5
                        for _, model in ipairs(Characters:GetChildren()) do
                            if model:IsA("Model") then
                                local p = AR2_Players:GetPlayerFromCharacter(model)
                                if p and p ~= AR2_LocalPlayer then
                                    local hrp = model:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        local toT  = hrp.Position - origin
                                        local proj = toT:Dot(dir)
                                        if proj > 0 then
                                            local lat = (toT - dir * proj).Magnitude
                                            if lat < minLat then
                                                minLat            = lat
                                                bestDist          = proj
                                                AR2_ibLastHitTime = os.clock()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    AR2_ibSeedMult(spd, bestDist)

                    AR2_ibSavedSpd  = spd
                    AR2_ibSavedGrav = fc.Gravity
                    AR2_ibSavedDrop = fc.BulletDrop

                    fc.BulletSpeed = spd * AR2_ibMult
                    if fc.Gravity    ~= nil then fc.Gravity    = 0 end
                    if fc.BulletDrop ~= nil then fc.BulletDrop = 0 end
                end)
            end

            local aimEntity, aimPart = nil, nil
            if AR2_CFG.magicAim.on or AR2_CFG.rageBot.on then
                aimEntity, aimPart = AR2_magicTarget()
                AR2_magicAim.target = aimEntity
            end

            if (AR2_CFG.magicAim.on or AR2_CFG.rageBot.on) and aimEntity and aimPart then
                if AR2_CFG.magicAim.originShift then
                    if aimEntity.model then
                        local headPart = aimEntity.headCollider or aimEntity.head
                        if headPart then
                            local nudge = originalOrigin + originalDirection * AR2_CFG.magicBullet.forwardNudge
                            local newOrigin, clear = AR2_findBestOrigin(nudge, originalDirection, headPart.Position, aimEntity.model)
                            if clear or newOrigin ~= originalOrigin then
                                origin = newOrigin
                                direction = (headPart.Position - origin).Unit
                            end
                        end
                    end
                end
                local aimPoint = AR2_predict(aimPart, origin, aimEntity.velocity)
                local bend = aimPoint - origin
                if bend.Magnitude > 0.001 then
                    local angle = math.deg(math.acos(math.clamp(bend.Unit:Dot(direction.Unit), -1, 1)))
                    local chance = AR2_CFG.magicAim.redirectChance or 100
                    if angle <= AR2_CFG.magicAim.maxBend and math.random(1,100) <= chance then
                        direction = bend.Unit

                        if aimEntity.name then AR2_noteDamageTarget(aimEntity.name) end
                    end
                end
            end

            local applyNoSpread = AR2_CFG.weapon.noSpread
            if AR2_CFG.magicAim.killSpread and aimEntity ~= nil then
                applyNoSpread = true
            end

            if applyNoSpread and AR2_CAP.setupvalue and AR2_spreadOriginalFn then
                pcall(function()
                    debug.setupvalue(AR2_originalFireFunction, 3, AR2_identitySpread)
                end)
            else
                if AR2_spreadOriginalFn then
                    pcall(debug.setupvalue, AR2_originalFireFunction, 3, AR2_spreadOriginalFn)
                end
            end

            if AR2_CFG.weapon.noRecoil and AR2_CAP.setupvalue then
                pcall(function()
                    debug.setupvalue(AR2_originalFireFunction, 6,
                        function(...) return Vector2.new(0,0), 0, 0, 0, 0 end)
                end)
            elseif AR2_CFG.weapon.recoilReduction and AR2_CFG.weapon.recoilReduction > 0 and AR2_CAP.setupvalue then
                local reduction = AR2_CFG.weapon.recoilReduction / 100
                if AR2_recoilOriginalFn then
                    local function newRecoil(...)
                        local x, y, z, a, b = AR2_recoilOriginalFn(...)
                        return Vector2.new(x.X*(1-reduction), x.Y*(1-reduction)),
                               z*(1-reduction), a*(1-reduction), b*(1-reduction), 0
                    end
                    pcall(debug.setupvalue, AR2_originalFireFunction, 6, newRecoil)
                end
            else
                if AR2_recoilOriginalFn and AR2_CAP.setupvalue then
                    pcall(debug.setupvalue, AR2_originalFireFunction, 6, AR2_recoilOriginalFn)
                end
            end

            if AR2_CFG.weapon.wallbang then
                local penFields = {
                    "Penetration","PenetrationPower","WallPenetration",
                    "WallPenetrationPower","PierceCount","Piercing",
                    "BulletPenetration","ArmorPenetration","PenPower",
                }
                for _, f in ipairs(penFields) do
                    pcall(function() weaponData[f] = 9999 end)
                end
                pcall(function() weaponData.CanPenetrate    = true end)
                pcall(function() weaponData.PenetrateWalls  = true end)
                pcall(function() weaponData.IgnoreArmor     = true end)
                pcall(function()
                    if weaponData.FireConfig then
                        weaponData.FireConfig.Penetration = 9999
                        weaponData.FireConfig.PenetrationPower = 9999
                    end
                end)
            end


            local result = AR2_originalFireFunction(self, playerController, weaponInstance, weaponData, origin, direction, shotId)

            if AR2_ibSavedSpd then
                pcall(function()
                    local fc = weaponData
                    if not fc then return end
                    fc.BulletSpeed = AR2_ibSavedSpd
                    if AR2_ibSavedGrav ~= nil then fc.Gravity    = AR2_ibSavedGrav end
                    if AR2_ibSavedDrop ~= nil then fc.BulletDrop = AR2_ibSavedDrop end
                end)
            end

            if AR2_tracersEnabled then AR2_addTracer(origin, direction) end

            if AR2_CFG.hitmarker.enabled then
                local _rp=RaycastParams.new()
                _rp.FilterType=Enum.RaycastFilterType.Exclude
                _rp.FilterDescendantsInstances={AR2_LocalPlayer.Character}
                local _hit=AR2_Workspace:Raycast(origin,direction*2000,_rp)
                local _det=false
                if _hit and _hit.Instance then
                    local _m=_hit.Instance
                    while _m and not _m:IsA("Model") do _m=_m.Parent end
                    if _m then
                        _det=(AR2_Characters~=nil and _m.Parent==AR2_Characters)
                            or(ZombiesFolder~=nil and _m.Parent==ZombiesFolder)
                            or _m:FindFirstChildOfClass("Humanoid")~=nil
                    end
                end
                if _det then AR2_hitmarkerFlag=true end
            end

            return result
        end)
        if not ok then
            warn("[fire] hook error: " .. tostring(result))
            return AR2_originalFireFunction(self, playerController, weaponInstance, weaponData, origin, direction, shotId)
        end
        return result
    end
end


AR2_hbeVisuals     = {}
AR2_hbeHookInstalled = false
AR2_hbeReentry     = false
AR2_hbeFolder      = nil

local function AR2_getHbeFolder()
    if AR2_hbeFolder and AR2_hbeFolder.Parent then return AR2_hbeFolder end
    AR2_hbeFolder = Instance.new("Folder")
    AR2_hbeFolder.Name = "juju_hbe"
    AR2_hbeFolder.Parent = AR2_Workspace
    return AR2_hbeFolder
end

local function AR2_hbeIsLocalPlayer(character)
    if not character then return false end
    if character == AR2_LocalPlayer.Character then return true end
    if AR2_Players:GetPlayerFromCharacter(character) == AR2_LocalPlayer then return true end
    if character.Name == AR2_LocalPlayer.Name then return true end
    return false
end

local function AR2_hbeAddVisual(character)
    if AR2_hbeVisuals[character] then return end
    if AR2_hbeIsLocalPlayer(character) then return end
    if not character:FindFirstChildOfClass("Humanoid") then return end

    local realHead = character:FindFirstChild("Head")
    if not realHead then return end

    local charRoot = character:FindFirstChild("HumanoidRootPart") or realHead
    if (charRoot.Position - AR2_localPosition()).Magnitude > 2000 then return end


    local v = Instance.new("Part")
    v.Name         = "HeadHitbox"
    v.Size         = Vector3.new(
        AR2_CFG.weapon.hbeSize,
        AR2_CFG.weapon.hbeSize,
        AR2_CFG.weapon.hbeSize)
    v.Transparency = 1
    v.CanCollide   = false
    v.CanTouch     = false
    v.CanQuery     = true
    v.Massless     = true
    v.Anchored     = true
    v.CastShadow   = false
    v:SetAttribute("ar2_hbe", true)
    v:SetAttribute("ar2_hbe_owner", character.Name)
    pcall(function() v.CollisionGroupId = realHead.CollisionGroupId end)
    v.CFrame       = realHead.CFrame
    v.Parent       = AR2_getHbeFolder()

    AR2_hbeVisuals[character] = v


    local guardConn
    guardConn = AR2_RunService.Heartbeat:Connect(function()
        if not v or not v.Parent or not realHead or not realHead.Parent then
            if v and v.Parent then v:Destroy() end
            if guardConn then guardConn:Disconnect() end
            AR2_hbeVisuals[character] = nil
            return
        end
        v.CFrame = realHead.CFrame
        if AR2_CollectionService:HasTag(v, "Bullets Penetrate") then
            AR2_CollectionService:RemoveTag(v, "Bullets Penetrate")
        end
    end)

    character.AncestryChanged:Connect(function()
        if not character.Parent then
            if v and v.Parent then v:Destroy() end
            if guardConn then guardConn:Disconnect() end
            AR2_hbeVisuals[character] = nil
        end
    end)
end

function AR2_hbeScan()
    if not AR2_Characters then return end
    local localRoot = AR2_localPosition()
    for _, model in ipairs(AR2_Characters:GetChildren()) do
        if model:IsA("Model") and not AR2_hbeIsLocalPlayer(model) then
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
            if root then
                if (root.Position - localRoot).Magnitude <= 2000 then
                    AR2_hbeAddVisual(model)
                else
                    local v = AR2_hbeVisuals[model]
                    if v then v:Destroy() AR2_hbeVisuals[model] = nil end
                end
            end
        end
    end
end

function AR2_hbeRemoveAll()
    for char, v in pairs(AR2_hbeVisuals) do
        if v and v.Parent then v:Destroy() end
        AR2_hbeVisuals[char] = nil
    end
    AR2_hbeVisuals = {}
    if AR2_hbeFolder and AR2_hbeFolder.Parent then AR2_hbeFolder:Destroy() AR2_hbeFolder = nil end
end

function AR2_hbeUpdateSizes()
    for _, v in pairs(AR2_hbeVisuals) do
        if v and v.Parent then
            v.Size = Vector3.new(
                AR2_CFG.weapon.hbeSize,
                AR2_CFG.weapon.hbeSize,
                AR2_CFG.weapon.hbeSize)
        end
    end
end

function AR2_hbeInstallHook()
    if AR2_hbeHookInstalled then return end
    if not (AR2_CAP.getrawmetatable and AR2_CAP.setreadonly and AR2_CAP.getnamecallmethod) then
        AR2_logHook("HBE", false, "missing getrawmetatable/setreadonly/getnamecallmethod")
        return
    end
    AR2_hbeHookInstalled = true

    local ok, err = pcall(function()
    local mt = getrawmetatable(game)
    local originalNC = mt.__namecall
    setreadonly(mt, false)


    local rawRaycast = workspace.Raycast

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()

        if method == "Raycast" and self == workspace and AR2_CFG.weapon.hbeOn and not AR2_hbeReentry then
            local origin, direction, params = ...

            if typeof(origin) == "Vector3" and params and typeof(params) == "RaycastParams" then
                local filter = params.FilterDescendantsInstances
                if filter and #filter >= 1 then
                    local hasChars = false
                    for _, inst in ipairs(filter) do
                        if inst == AR2_Characters
                        or (inst.Name == "Characters" and inst.ClassName == "Folder") then
                            hasChars = true
                            break
                        end
                    end

                    if hasChars then
                        local cleaned = {}
                        for _, inst in ipairs(filter) do
                            if inst ~= AR2_Characters
                            and not (inst.Name == "Characters" and inst.ClassName == "Folder") then
                                table.insert(cleaned, inst)
                            end
                        end
                        local selfChar = AR2_LocalPlayer.Character
                        if selfChar then
                            table.insert(cleaned, selfChar)
                        end
                        params.FilterDescendantsInstances = cleaned
                    end
                end
            end

            local result = originalNC(self, ...)


            if result and result.Instance then
                local hit    = result.Instance
                local hpos   = result.Position
                local radius = (AR2_CFG.weapon.hbeSize or 10) * 0.75
                for char, fakeHead in pairs(AR2_hbeVisuals) do
                    if fakeHead and fakeHead.Parent and char and char.Parent then
                        if hit == fakeHead
                        or (fakeHead.Position - hpos).Magnitude < radius then


                            local realHead = char:FindFirstChild("Head")
                            if realHead and realHead.Parent then
                                return {
                                    Instance = realHead,
                                    Position = result.Position,
                                    Normal   = result.Normal,
                                    Material = result.Material,
                                    Distance = result.Distance,
                                }
                            end
                        end
                    end
                end
            end

            return result
        end


        return originalNC(self, ...)
    end)

    setreadonly(mt, true)
    end)
    if not ok then AR2_logHook("HBE", false, tostring(err)) return end
    AR2_logHook("HBE", true)

    if AR2_Characters then
        AR2_Characters.ChildAdded:Connect(function(model)
            if not model:IsA("Model") then return end
            if not AR2_CFG.weapon.hbeOn then return end
            if model.Name == AR2_LocalPlayer.Name then return end
            task.wait(0.3)
            if AR2_hbeIsLocalPlayer(model) then return end
            AR2_hbeAddVisual(model)
        end)
    end

    task.spawn(function()
        while true do
            task.wait(2)
            if AR2_CFG.weapon.hbeOn then
                pcall(AR2_hbeScan)
            end
        end
    end)
end

function AR2_hbeSetEnabled(enabled)
    AR2_CFG.weapon.hbeOn = enabled
    if enabled then
        AR2_hbeInstallHook()
        AR2_hbeScan()
    else
        AR2_hbeRemoveAll()
    end
end


local AR2_textureUpdateConn = nil
local AR2_textureLastScan = 0
local AR2_savedTextures = {}

local function AR2_scanTextures()
    for _, obj in ipairs(AR2_Workspace:GetDescendants()) do
        if (obj:IsA("Texture") or obj:IsA("Decal")) and obj.Transparency < 1 and not AR2_savedTextures[obj] then
            AR2_savedTextures[obj] = obj.Transparency
            obj.Transparency = 1
        end
    end
end

function AR2_toggleRemoveTextures(enabled)
    AR2_CFG.misc.removeTextures = enabled
    if enabled then
        AR2_scanTextures()
        if not AR2_textureUpdateConn then
            AR2_textureUpdateConn = AR2_RunService.Heartbeat:Connect(function()
                local now = os.clock()
                if now - AR2_textureLastScan >= 20 then
                    AR2_textureLastScan = now
                    AR2_scanTextures()
                end
            end)
        end
    else
        if AR2_textureUpdateConn then
            AR2_textureUpdateConn:Disconnect()
            AR2_textureUpdateConn = nil
        end
        for obj, t in pairs(AR2_savedTextures) do
            if obj and obj.Parent then obj.Transparency = t end
        end
        AR2_savedTextures = {}
        AR2_textureLastScan = 0
    end
end

local AR2_leaveConn = nil
local AR2_leaveSaved = {}

local function AR2_applyLeafTransparency(part)
    if not AR2_leaveSaved[part] then AR2_leaveSaved[part] = part.Transparency end
    part.Transparency = 1
end

local function AR2_scanLeaves()
    local mapElements = AR2_Workspace:FindFirstChild("Map") and AR2_Workspace.Map:FindFirstChild("Elements")
    if not mapElements then return end
    for _, part in ipairs(mapElements:GetDescendants()) do
        if part.Name == "Fronds" or part.Name == "Leaves" or part.Name == "PineLeaves" then
            AR2_applyLeafTransparency(part)
        end
    end
end

function AR2_toggleRemoveLeaves(enabled)
    AR2_CFG.misc.removeLeaves = enabled
    if enabled then
        AR2_scanLeaves()
        if not AR2_leaveConn then
            local mapElements = AR2_Workspace:FindFirstChild("Map") and AR2_Workspace.Map:FindFirstChild("Elements")
            if mapElements then
                AR2_leaveConn = mapElements.DescendantAdded:Connect(function(part)
                    if part.Name == "Fronds" or part.Name == "Leaves" or part.Name == "PineLeaves" then
                        task.wait()
                        AR2_applyLeafTransparency(part)
                    end
                end)
            end
        end
    else
        if AR2_leaveConn then
            AR2_leaveConn:Disconnect()
            AR2_leaveConn = nil
        end
        for part, orig in pairs(AR2_leaveSaved) do
            if part.Parent then part.Transparency = orig end
        end
        AR2_leaveSaved = {}
    end
end

local AR2_bushRemoved = {}

local function AR2_removeBushes()
    local mapElements = AR2_Workspace:FindFirstChild("Map") and AR2_Workspace.Map:FindFirstChild("Elements")
    if not mapElements then return end
    local function scan(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name:find("Foliage") or child.Name:find("Shrub") then
                AR2_bushRemoved[child] = child.Parent
                child.Parent = nil
            else
                scan(child)
            end
        end
    end
    scan(mapElements)
end

local function AR2_restoreBushes()
    for child, parent in pairs(AR2_bushRemoved) do
        if child and parent then child.Parent = parent end
    end
    AR2_bushRemoved = {}
end

function AR2_toggleRemoveBushes(enabled)
    AR2_CFG.misc.removeBushes = enabled
    if enabled then
        AR2_removeBushes()
    else
        AR2_restoreBushes()
    end
end


AR2_cosEnabled       = false
AR2_cosRendering     = false
AR2_cosEquipped      = {}
AR2_cosSlot          = 0
AR2_cosHooked        = {}
AR2_cosWatchConn     = nil
AR2_cosEnforceConn   = nil

local AR2_wantedShirt    = nil
local AR2_wantedPants    = nil
local AR2_origShirt      = nil
local AR2_origPants      = nil
local AR2_defaultTemplates = {}

local function AR2_cosGetTemplates()
    local char = AR2_LocalPlayer.Character
    if not char then return nil, nil end
    local s = char:FindFirstChildOfClass("Shirt")
    local p = char:FindFirstChildOfClass("Pants")
    return s and s.ShirtTemplate or nil,
           p and p.PantsTemplate or nil
end

local function AR2_cosScanDefaults()
    AR2_defaultTemplates = {}
    local counts = {}
    local gui    = AR2_LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("ViewportFrame") then
            for _, wm in ipairs(d:GetChildren()) do
                if wm:IsA("WorldModel") then
                    for _, vm in ipairs(wm:GetChildren()) do
                        if vm:IsA("Model") then
                            for _, obj in ipairs(vm:GetChildren()) do
                                local t = nil
                                if obj:IsA("Shirt") then t = obj.ShirtTemplate
                                elseif obj:IsA("Pants") then t = obj.PantsTemplate end
                                if t and t ~= "" then
                                    counts[t] = (counts[t] or 0) + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    for t, n in pairs(counts) do
        if n >= 3 then AR2_defaultTemplates[t] = true end
    end
end

local function AR2_cosStartEnforce()
    if AR2_cosEnforceConn then AR2_cosEnforceConn:Disconnect() end
    AR2_cosEnforceConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_cosRendering then return end
        local char = AR2_LocalPlayer.Character
        if not char then return end
        if AR2_wantedShirt then
            local s = char:FindFirstChildOfClass("Shirt")
            if not s then s = Instance.new("Shirt") s.Parent = char end
            if s.ShirtTemplate ~= AR2_wantedShirt then
                pcall(function() s.ShirtTemplate = AR2_wantedShirt end)
            end
        end
        if AR2_wantedPants then
            local p = char:FindFirstChildOfClass("Pants")
            if not p then p = Instance.new("Pants") p.Parent = char end
            if p.PantsTemplate ~= AR2_wantedPants then
                pcall(function() p.PantsTemplate = AR2_wantedPants end)
            end
        end
    end)
end

local AR2_COS_BODY = {
    HumanoidRootPart=true, Head=true,
    UpperTorso=true, LowerTorso=true, Torso=true,
    ["Left Arm"]=true, ["Right Arm"]=true,
    ["Left Leg"]=true, ["Right Leg"]=true,
    LeftUpperArm=true, LeftLowerArm=true, LeftHand=true,
    RightUpperArm=true, RightLowerArm=true, RightHand=true,
    LeftUpperLeg=true, LeftLowerLeg=true, LeftFoot=true,
    RightUpperLeg=true, RightLowerLeg=true, RightFoot=true,
}

local function AR2_cosFindVM(root)
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ViewportFrame") then
            for _, wm in ipairs(d:GetChildren()) do
                if wm:IsA("WorldModel") then
                    for _, vm in ipairs(wm:GetChildren()) do
                        if vm:IsA("Model") and (
                            vm:FindFirstChild("HumanoidRootPart") or
                            vm:FindFirstChild("UpperTorso") or
                            vm:FindFirstChild("Torso")
                        ) then return vm end
                    end
                end
            end
        end
    end
end

local function AR2_cosFindNear(el)
    local node = el
    for _ = 1, 6 do
        if not node then break end
        local vm = AR2_cosFindVM(node)
        if vm then return vm end
        node = node.Parent
    end
end

local function AR2_cosNearestBody(vm, pos)
    local best, bestD = nil, math.huge
    for _, p in ipairs(vm:GetDescendants()) do
        if p:IsA("BasePart") and AR2_COS_BODY[p.Name] then
            local d = (p.Position - pos).Magnitude
            if d < bestD then best = p bestD = d end
        end
    end
    return best
end

local function AR2_cosIsWeapon(p, vmRoot)
    local node = p.Parent
    while node and node ~= vmRoot do
        if node:IsA("Tool") then return true end
        node = node.Parent
    end
    return false
end

local function AR2_cosClonePart(p, anchor, nbCF)
    local ok, clone = pcall(function() return p:Clone() end)
    if not ok or not clone then return nil end
    for _, c in ipairs(clone:GetChildren()) do
        if c:IsA("Motor6D") or c:IsA("Weld") or c:IsA("WeldConstraint")
        or c:IsA("Script") or c:IsA("LocalScript")
        or c:IsA("BodyVelocity") or c:IsA("Humanoid") then
            c:Destroy()
        end
    end
    clone.Anchored   = true  clone.CanCollide = false
    clone.CanTouch   = false clone.CanQuery   = false
    clone.CastShadow = false clone.Massless   = true
    clone.Parent     = AR2_Camera
    pcall(function() AR2_CollectionService:AddTag(clone, "Bullets Penetrate") end)
    return clone, { anchor = anchor, localCF = nbCF:Inverse() * p.CFrame }
end

local function AR2_cosAttach(vm)
    local char = AR2_LocalPlayer.Character
    if not char then return end

    local curShirt, curPants = AR2_cosGetTemplates()
    local vmShirt = vm:FindFirstChildOfClass("Shirt")
    local vmPants = vm:FindFirstChildOfClass("Pants")
    local vmST    = vmShirt and vmShirt.ShirtTemplate or ""
    local vmPT    = vmPants and vmPants.PantsTemplate or ""

    if vmST ~= "" and vmST ~= curShirt and not AR2_defaultTemplates[vmST] then
        AR2_wantedShirt = vmST
    end
    if vmPT ~= "" and vmPT ~= curPants and not AR2_defaultTemplates[vmPT] then
        AR2_wantedPants = vmPT
    end

    local parts   = {}
    local bpCount = 0
    local hrp     = char:FindFirstChild("HumanoidRootPart")

    for _, p in ipairs(vm:GetDescendants()) do
        if p:IsA("BasePart") and not AR2_COS_BODY[p.Name] then
            if AR2_cosIsWeapon(p, vm) then continue end
            local nb = AR2_cosNearestBody(vm, p.Position)
            local clone, data = AR2_cosClonePart(
                p,
                nb and nb.Name or "HumanoidRootPart",
                nb and nb.CFrame or CFrame.new()
            )
            if clone then
                local anchor = char:FindFirstChild(data.anchor) or hrp
                if anchor then clone.CFrame = anchor.CFrame * data.localCF end
                parts[clone] = data
                bpCount = bpCount + 1
            end
        end
    end
    if bpCount > 0 then
        AR2_cosSlot = AR2_cosSlot + 1
        AR2_cosEquipped[AR2_cosSlot] = parts
    end
end

AR2_RunService.RenderStepped:Connect(function()
    if not AR2_cosRendering then return end
    local char = AR2_LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for slot, ptbl in pairs(AR2_cosEquipped) do
        local empty = true
        for part, data in pairs(ptbl) do
            if part and part.Parent then
                local anchor = char:FindFirstChild(data.anchor) or hrp
                part.CFrame  = anchor.CFrame * data.localCF
                empty = false
            else ptbl[part] = nil end
        end
        if empty then AR2_cosEquipped[slot] = nil end
    end
end)

function AR2_cosRemoveAll()
    for slot, ptbl in pairs(AR2_cosEquipped) do
        for part in pairs(ptbl) do
            pcall(function() if part and part.Parent then part:Destroy() end end)
        end
        AR2_cosEquipped[slot] = nil
    end
    AR2_wantedShirt = AR2_origShirt
    AR2_wantedPants = AR2_origPants
    if not AR2_cosEnabled then
        AR2_cosRendering = false
        if AR2_cosEnforceConn then AR2_cosEnforceConn:Disconnect() AR2_cosEnforceConn = nil end
        AR2_wantedShirt, AR2_wantedPants = nil, nil
        AR2_origShirt,   AR2_origPants   = nil, nil
    end
end

local function AR2_cosHookBtn(btn)
    if AR2_cosHooked[btn] then return end
    AR2_cosHooked[btn] = btn.MouseButton1Click:Connect(function()
        if not AR2_cosEnabled then return end
        task.wait(0.15)
        local vm = AR2_cosFindNear(btn)
        if vm then AR2_cosAttach(vm) end
    end)
end

local function AR2_cosScan()
    local gui = AR2_LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("ImageButton") or d:IsA("TextButton") then
            pcall(AR2_cosHookBtn, d)
        end
    end
end

function AR2_cosSetEnabled(on)
    AR2_cosEnabled = on
    AR2_CFG.misc.cosUnlock = on

    if on then
        AR2_cosRendering = true
        AR2_origShirt, AR2_origPants = AR2_cosGetTemplates()
        if not AR2_wantedShirt then AR2_wantedShirt = AR2_origShirt end
        if not AR2_wantedPants then AR2_wantedPants = AR2_origPants end
        AR2_cosScanDefaults()
        AR2_cosStartEnforce()
        AR2_cosScan()
        local gui = AR2_LocalPlayer:FindFirstChild("PlayerGui")
        if gui and not AR2_cosWatchConn then
            AR2_cosWatchConn = gui.DescendantAdded:Connect(function(d)
                if not AR2_cosEnabled then return end
                if d:IsA("ImageButton") or d:IsA("TextButton") then
                    task.wait(0.1) pcall(AR2_cosHookBtn, d)
                end
            end)
        end
    else
        if AR2_cosWatchConn then AR2_cosWatchConn:Disconnect() AR2_cosWatchConn = nil end
        for _, conn in pairs(AR2_cosHooked) do pcall(function() conn:Disconnect() end) end
        AR2_cosHooked = {}
    end
end

function AR2_cosSaveOutfit(name) return false end
function AR2_cosLoadOutfit(name) return false end
function AR2_cosDeleteOutfit(name) return false end
function AR2_cosOutfitNames() return { "(no saved outfits)" } end


AR2_freeze = { running = false, held = 0, near = 0, note = "off", lastUpdate = 0 }
AR2_freezeConn = nil
AR2_frozen = {}

function AR2_freezeAnchorParts(model, record)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            record.anchored[descendant] = descendant.Anchored
            descendant.Anchored = true
        end
    end
end

function AR2_freezeGrab(model, root)
    local record = { cf = root.CFrame, anchored = {} }
    if AR2_CFG.misc.freezeAnchor then pcall(AR2_freezeAnchorParts, model, record) end
    AR2_frozen[model] = record
    return record
end

function AR2_freezeUnanchor(record)
    for part, wasAnchored in pairs(record.anchored) do
        pcall(function() if part.Parent then part.Anchored = wasAnchored end end)
    end
    record.anchored = {}
end

function AR2_freezeRelease(model)
    local record = AR2_frozen[model]
    if not record then return end
    AR2_freezeUnanchor(record)
    AR2_frozen[model] = nil
end

function AR2_freezeReleaseAll()
    for model in pairs(AR2_frozen) do AR2_freezeRelease(model) end
end

function AR2_freezeStep()
    if not AR2_CFG.misc.freeze then
        if next(AR2_frozen) then AR2_freezeReleaseAll() end
        AR2_freeze.held, AR2_freeze.near, AR2_freeze.note = 0, 0, "off"
        return
    end
    local held, near = 0, 0
    local seen = {}
    for _, entry in ipairs(AR2_api.zombies()) do
        if AR2_CFG.misc.freezeAll or entry.distance <= AR2_CFG.misc.freezeRadius then
            near = near + 1
            local model, root = entry.model, entry.root
            if model.Parent and root.Parent then
                seen[model] = true
                local record = AR2_frozen[model] or AR2_freezeGrab(model, root)
                root.CFrame = record.cf
                root.AssemblyLinearVelocity = Vector3.zero
                held = held + 1
            end
        end
    end
    for model in pairs(AR2_frozen) do
        if not seen[model] then AR2_freezeRelease(model) end
    end
    AR2_freeze.held, AR2_freeze.near = held, near
    AR2_freeze.note = AR2_CFG.misc.freezeAll and "whole server" or (AR2_CFG.misc.freezeRadius .. " studs")
end

function AR2_freeze.start()
    if AR2_freezeConn then return end
    AR2_freeze.running = true
    AR2_freezeConn = AR2_RunService.Heartbeat:Connect(function()
        if os.clock() - (AR2_freeze.lastUpdate or 0) >= 0.1 then
            AR2_freeze.lastUpdate = os.clock()
            local ok, err = pcall(AR2_freezeStep)
            if not ok then AR2_freeze.note = "error: "..tostring(err) end
        end
    end)
end

function AR2_freeze.stop()
    AR2_freeze.running = false
    if AR2_freezeConn then AR2_freezeConn:Disconnect() AR2_freezeConn = nil end
    AR2_freezeReleaseAll()
    AR2_freeze.held, AR2_freeze.near, AR2_freeze.note = 0, 0, "off"
end

function AR2_freeze.destroy() AR2_freeze.stop() end


AR2_tp = AR2_tp or {}
do
    local _tpDefaults = { busy = false, cancel = false, gen = 0, lastResult = "", writes = 0, phase = "idle", attempt = 0, pulls = 0, hops = 0, surfaceTarget = nil, under = false, underGoal = nil, clipSaved = nil, clipAt = 0 }
    for k, v in pairs(_tpDefaults) do AR2_tp[k] = v end
end
AR2_tpGuard = { installed = false, active = false, blocked = 0, why = "", goal = nil }
AR2_hookmetamethod = hookmetamethod
AR2_checkcaller = checkcaller
AR2_getnamecallmethod = getnamecallmethod
AR2_newcclosure = newcclosure or function(fn) return fn end
AR2_GUARD_PROPS = { CFrame = true, Position = true, WorldCFrame = true }
AR2_GUARD_METHODS = { PivotTo = true, SetPrimaryPartCFrame = true, MoveTo = true, ApplyImpulse = true }

function AR2_tpGuard.install()
    if AR2_tpGuard.installed then return true end
    if not (AR2_hookmetamethod and AR2_checkcaller) then AR2_tpGuard.why = "no hookmetamethod/checkcaller" AR2_logHook("TPGuard", false, AR2_tpGuard.why) return false, AR2_tpGuard.why end
    local okIndex = pcall(function()
        local old
        old = AR2_hookmetamethod(game, "__newindex", AR2_newcclosure(function(self, key, value)
            if AR2_tpGuard.active and AR2_GUARD_PROPS[key] and not AR2_checkcaller() then
                if self == AR2_tpRoot() then
                    local position = (typeof(value) == "CFrame" and value.Position) or (typeof(value) == "Vector3" and value) or nil
                    if AR2_tpGuard.goal and position and (position - AR2_tpGuard.goal).Magnitude >= (AR2_CFG.tp.snapBack or 8) then
                        AR2_tpGuard.blocked = AR2_tpGuard.blocked + 1
                        return
                    end
                end
            end
            return old(self, key, value)
        end))
    end)
    local okCall = pcall(function()
        local old
        old = AR2_hookmetamethod(game, "__namecall", AR2_newcclosure(function(self, ...)
            if AR2_tpGuard.active and not AR2_checkcaller() then
                local method = AR2_getnamecallmethod and AR2_getnamecallmethod() or ""
                if AR2_GUARD_METHODS[method] and (self == AR2_tpRoot() or self == AR2_LocalPlayer.Character) then
                    AR2_tpGuard.blocked = AR2_tpGuard.blocked + 1
                    return
                end
            end
            return old(self, ...)
        end))
    end)
    if not (okIndex or okCall) then AR2_tpGuard.why = "both hooks failed" return false, AR2_tpGuard.why end
    AR2_tpGuard.installed = true
    AR2_tpGuard.why = "armed"
    AR2_logHook("TPGuard", true)
    return true
end

function AR2_tpRoot()
    local char = AR2_LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

function AR2_tpUnseat()
    if not AR2_CFG.tp.unseat then return end
    local char = AR2_LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid and humanoid.Sit then
        humanoid.Sit = false
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("Weld") and part.Name == "SeatWeld" then part:Destroy() end
    end
end

function AR2_tpWrite(root, goal)
    AR2_tpGuard.goal = goal.Position
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    if AR2_CFG.tp.force then
        root.Anchored = true
        local char = AR2_LocalPlayer.Character
        local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
            humanoid.AutoRotate = false
        end
    end
    root.CFrame = goal
end

function AR2_tpRelease()
    local root = AR2_tpRoot()
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.zero
    end
    for part in pairs(AR2_tp.clipSaved or {}) do
        pcall(function() if part.Parent then part.CanCollide = true end end)
    end
    AR2_tp.clipSaved = nil
    local char = AR2_LocalPlayer.Character
    local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
    end
end

function AR2_tpYield()
    if AR2_CFG.tp.everyFrame then AR2_RunService.Heartbeat:Wait() else task.wait(AR2_CFG.tp.intervalCs/100) end
end

function AR2_tpAlive(mine) return AR2_tp.gen == mine and not AR2_tp.cancel end

function AR2_tpGroundStand(position)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { AR2_LocalPlayer.Character }
    params.IgnoreWater = true
    local hit = AR2_Workspace:Raycast(position + Vector3.new(0,3,0), Vector3.new(0,-12,0), params)
    if not hit then return position end
    return Vector3.new(position.X, hit.Position.Y + 3, position.Z)
end

function AR2_tpGroundBelow(position)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { AR2_LocalPlayer.Character }
    params.IgnoreWater = true
    local hit = AR2_Workspace:Raycast(position + Vector3.new(0,2,0), Vector3.new(0,-4000,0), params)
    if hit then return math.min(hit.Position.Y, position.Y) end
    return position.Y - 20
end

function AR2_tpNoclip(on)
    local char = AR2_LocalPlayer.Character
    if not char then return end
    if on then
        AR2_tp.clipSaved = AR2_tp.clipSaved or {}
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                AR2_tp.clipSaved[part] = true
                part.CanCollide = false
            end
        end
    else
        for part in pairs(AR2_tp.clipSaved or {}) do
            pcall(function() if part.Parent then part.CanCollide = true end end)
        end
        AR2_tp.clipSaved = nil
    end
end

function AR2_tpPush(goalFn, mine, seconds)
    local c = AR2_CFG.tp
    local started = os.clock()
    local stableSince, lastGoal = nil, nil
    local needed = math.min(c.stableCs/100, seconds*0.6)
    while AR2_tpAlive(mine) do
        local root = AR2_tpRoot()
        local goal = root and goalFn() or nil
        if not root or not goal then return false end
        if lastGoal then
            if (root.Position - lastGoal).Magnitude >= c.snapBack then
                stableSince = nil
            else
                stableSince = stableSince or os.clock()
            end
        end
        AR2_tpWrite(root, goal)
        lastGoal = goal.Position
        AR2_tp.writes = AR2_tp.writes + 1
        if stableSince and os.clock() - stableSince >= needed then return true end
        if os.clock() - started >= seconds then return false end
        AR2_tpYield()
    end
    return false
end

function AR2_tpHop(goalFn, mine)
    local c = AR2_CFG.tp
    local hop = math.max(4, c.hopStuds)
    for _ = 1, 600 do
        if not AR2_tpAlive(mine) then return false end
        local root = AR2_tpRoot()
        local goal = root and goalFn() or nil
        if not root or not goal then return false end
        local delta = goal.Position - root.Position
        if delta.Magnitude <= hop then return AR2_tpPush(goalFn, mine, c.maxSeconds) end
        local before = root.Position
        local heading = delta.Unit
        local waypoint = CFrame.new(before + heading * hop)
        AR2_tp.phase = string.format("hopping %.0f studs left", delta.Magnitude)
        local ok = AR2_tpPush(function() return waypoint end, mine, c.stableCs/100 + 1.5)
        AR2_RunService.Heartbeat:Wait()
        AR2_RunService.Heartbeat:Wait()
        local after = AR2_tpRoot()
        if not after then return false end
        local gained = (after.Position - before):Dot(heading)
        if ok and gained >= hop*0.5 then
            AR2_tp.hops = AR2_tp.hops + 1
        else
            hop = hop/2
            if hop < 4 then return false end
        end
    end
    return false
end

function AR2_tpHold(anchorPoint, mine)
    local c = AR2_CFG.tp
    if c.holdSecs <= 0 then return true end
    local until_ = os.clock() + c.holdSecs
    local last = anchorPoint.Position
    AR2_tp.phase = "holding"
    while os.clock() < until_ and AR2_tpAlive(mine) do
        local dt = AR2_RunService.Heartbeat:Wait()
        local root = AR2_tpRoot()
        if root then
            local jump = (root.Position - last).Magnitude
            last = root.Position
            if jump / math.max(dt, 1/240) >= 60 then
                AR2_tp.pulls = AR2_tp.pulls + 1
                if not AR2_tpPush(function() return anchorPoint end, mine, c.maxSeconds) then return false end
                last = anchorPoint.Position
            end
        end
    end
    return true
end

function AR2_tpUnderground(goalFn, mine)
    local c = AR2_CFG.tp
    local root = AR2_tpRoot()
    local goal = root and goalFn() or nil
    if not root or not goal then return false end
    local depth = math.max(5, c.burrowDepth)
    AR2_tp.phase = "burrowing"
    local under = Vector3.new(root.Position.X, AR2_tpGroundBelow(root.Position) - depth, root.Position.Z)
    if c.burrowClip then AR2_tpNoclip(true) end
    local landed = false
    if AR2_tpPush(function() return CFrame.new(under) end, mine, c.maxSeconds) then
        AR2_tp.phase = "crossing under"
        local destination = goalFn()
        if destination then
            local floor = AR2_tpGroundBelow(destination.Position)
            local cruise = math.min(under.Y, floor - depth)
            local across = CFrame.new(destination.Position.X, cruise, destination.Position.Z)
            if AR2_tpPush(function() return across end, mine, c.maxSeconds) then
                AR2_tp.hops = AR2_tp.hops + 1
            end
        end
        AR2_tp.phase = "surfacing"
        landed = AR2_tpPush(goalFn, mine, c.maxSeconds)
        if c.burrowClip then AR2_tpNoclip(false) end
    end
    return landed
end

function AR2_tpTargetRoot()
    local wanted = AR2_CFG.tp.target
    if not wanted or wanted == "-" then return nil end
    for _, entry in ipairs(AR2_api.players()) do
        if entry.name == wanted or entry.displayName == wanted then return entry.root end
    end
    return nil
end

function AR2_tpOffset(cframe)
    local c = AR2_CFG.tp
    return cframe * CFrame.new(c.side, c.above, c.behind)
end

function AR2_tp.run(getGoal, label, keepGoing)
    AR2_tp.gen = (AR2_tp.gen or 0) + 1
    local mine = AR2_tp.gen
    AR2_tp.cancel = true
    task.spawn(function()
        while AR2_tp.busy do task.wait() end
        if AR2_tp.gen ~= mine then return end
        local c = AR2_CFG.tp
        AR2_tp.busy, AR2_tp.cancel = true, false
        AR2_tp.writes, AR2_tp.attempt, AR2_tp.pulls, AR2_tp.hops = 0, 0, 0, 0
        local started = os.clock()
        AR2_tpUnseat()
        if c.guard then
            AR2_tpGuard.install()
            AR2_tpGuard.blocked = 0
            AR2_tpGuard.active = true
        end
        if c.force and not keepGoing then
            AR2_tp.phase = "FORCED"
            local until_ = os.clock() + c.forceSecs
            while os.clock() < until_ and AR2_tpAlive(mine) do
                local root = AR2_tpRoot()
                local goal = root and getGoal() or nil
                if not root or not goal then break end
                AR2_tpWrite(root, goal)
                AR2_tp.writes = AR2_tp.writes + 1
                AR2_RunService.Heartbeat:Wait()
            end
            AR2_tpRelease()
            local landing = AR2_tpRoot()
            local goal = getGoal()
            AR2_RunService.Heartbeat:Wait()
            AR2_RunService.Heartbeat:Wait()
            local drift = (landing and goal) and (landing.Position - goal.Position).Magnitude or -1
            AR2_tp.lastResult = string.format("%s -- forced %d writes, %.0f off%s", label, AR2_tp.writes, drift, drift > c.snapBack and "  <-- server did NOT accept it" or "")
        elseif keepGoing then
            AR2_tp.phase = "following"
            while AR2_tpAlive(mine) do
                local root = AR2_tpRoot()
                local goal = root and getGoal() or nil
                if root and goal then
                    AR2_tpWrite(root, goal)
                    AR2_tp.writes = AR2_tp.writes + 1
                end
                AR2_tpYield()
            end
            AR2_tp.lastResult = string.format("%s -- followed, %d writes", label, AR2_tp.writes)
        else
            local landed = false
            repeat
                if c.underground and AR2_tpAlive(mine) then landed = AR2_tpUnderground(getGoal, mine) end
                for attempt = 1, math.max(1, c.retries) do
                    if landed or not AR2_tpAlive(mine) then break end
                    AR2_tp.attempt = AR2_tp.attempt + 1
                    AR2_tp.phase = string.format("attempt %d", AR2_tp.attempt)
                    landed = AR2_tpPush(getGoal, mine, c.maxSeconds)
                    if landed then break end
                end
                if not landed and c.chunked and AR2_tpAlive(mine) then
                    landed = AR2_tpHop(getGoal, mine)
                end
                if not landed then AR2_RunService.Heartbeat:Wait() end
            until landed or not AR2_tpAlive(mine) or not c.neverGiveUp
            if landed then
                local resting = AR2_tpRoot()
                local anchorPoint = resting and CFrame.new(resting.Position) or nil
                AR2_tp.lastResult = string.format("%s -- landed in %.1fs (%d writes, %d attempts%s)", label, os.clock()-started, AR2_tp.writes, AR2_tp.attempt, AR2_tp.hops > 0 and (", "..AR2_tp.hops.." hops") or "")
                local held = true
                if anchorPoint then held = AR2_tpHold(anchorPoint, mine) end
                if not held then
                    AR2_tp.lastResult = string.format("%s -- landed, then pulled back %d time(s) and REFUSED to stay", label, AR2_tp.pulls)
                elseif AR2_tp.pulls > 0 then
                    AR2_tp.lastResult = AR2_tp.lastResult .. string.format(" -- pulled back %d time(s), re-sent", AR2_tp.pulls)
                end
            else
                AR2_tp.lastResult = string.format("%s -- REFUSED after %d attempts and %d writes", label, AR2_tp.attempt, AR2_tp.writes)
            end
        end
        AR2_tpRelease()
        if c.guard then
            task.delay(math.max(0, c.guardSecs), function()
                if not AR2_tp.busy then AR2_tpGuard.active = false end
            end)
        end
        if AR2_tp.cancel and not string.find(AR2_tp.lastResult, "landed", 1, true) then
            AR2_tp.lastResult = label .. " -- stopped"
        end
        AR2_tp.busy, AR2_tp.phase = false, "idle"
    end)
end

function AR2_tp.stop()
    AR2_tp.cancel = true
    AR2_tp.gen = (AR2_tp.gen or 0) + 1
end

function AR2_tp.plain()
    local c = AR2_CFG.tp
    c.everyFrame, c.intervalCs, c.stableCs = false, 9, 100
    c.snapBack, c.maxSeconds, c.retries = 100, 8, 1
    c.neverGiveUp, c.holdSecs = false, 0
    c.everyFrame = true
    c.chunked, c.hopStuds = true, 200
    c.guard, c.force, c.underground = false, false, false
    c.follow = false
    AR2_tp.stop()
    AR2_tpGuard.active = false
    AR2_tp.lastResult = "settings back to original method"
end

function AR2_tp.toPosition(position, label)
    AR2_tp.run(function() return CFrame.new(position) end, label)
end

function AR2_tp.toPlayer()
    local wanted = AR2_CFG.tp.target
    if wanted == "-" then AR2_tp.lastResult = "no player picked" return end
    AR2_tp.run(function()
        local root = AR2_tpTargetRoot()
        return root and AR2_tpOffset(root.CFrame) or nil
    end, wanted, false)
end

function AR2_tp.toMouse()
    if not AR2_CFG.tp.clickTPOn then return end
    local cam = Workspace.CurrentCamera
    local screen = AR2_UserInputService:GetMouseLocation()
    local ray = cam:ViewportPointToRay(screen.X, screen.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { AR2_LocalPlayer.Character }
    local hit = AR2_Workspace:Raycast(ray.Origin, ray.Direction * 10000, params)
    if not hit then AR2_tp.lastResult = "mouse -- nothing under cursor" return end
    local ground = AR2_tpGroundStand(hit.Position)
    local pos = ground + Vector3.new(0, AR2_CFG.tp.clickLift, 0)
    local char = AR2_LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.SeatPart then
        local carModel = AR2_carPick()
        if carModel then AR2_car.desyncTo(pos, "mouse car") return end
    end
    AR2_tp.toPosition(pos, "mouse")
end

function AR2_tp.dive()
    local root = AR2_tpRoot()
    if not root then return false end
    AR2_tp.under = true
    AR2_tp.underGoal = CFrame.new(root.Position.X, AR2_tpGroundBelow(root.Position) - math.max(5, AR2_CFG.tp.burrowDepth), root.Position.Z)
    AR2_tpNoclip(true)
    AR2_tp.run(function()
        local now = os.clock()
        if now - (AR2_tp.clipAt or 0) > 0.25 then
            AR2_tp.clipAt = now
            AR2_tpNoclip(true)
        end
        return AR2_tp.underGoal
    end, "under the map", true)
    return true
end

function AR2_tp.surface(position)
    local target = position or AR2_tp.surfaceTarget
    if not target then
        local root = AR2_tpRoot()
        if root then target = root.Position + Vector3.new(0, math.max(5, AR2_CFG.tp.burrowDepth) + 6, 0) end
    end
    AR2_tp.under = false
    AR2_tp.stop()
    if not target then return end
    task.spawn(function()
        while AR2_tp.busy do task.wait() end
        AR2_tp.toPosition(target, "surfaced")
    end)
end

function AR2_tp.saveWaypoint()
    local root = AR2_tpRoot()
    if not root then return false end
    local list = AR2_CFG.tp.waypoints
    local position = root.Position
    list[#list+1] = { name = string.format("WP %d", #list+1), x = math.floor(position.X+0.5), y = math.floor(position.Y+0.5), z = math.floor(position.Z+0.5) }
    return true
end

AR2_respawnTP = false
function AR2_toggleRespawnTP(enabled)
    AR2_respawnTP = enabled
    AR2_CFG.tp.respawnTP = enabled
    if enabled then
        task.spawn(function()
            while AR2_respawnTP do
                AR2_tp.toPlayer()
                task.wait(1)
            end
        end)
    end
end


AR2_noclipConn = nil
AR2_noclipKeys = {W=false,A=false,S=false,D=false,Space=false,LeftControl=false}
local noclipParts = {}
local noclipOffsets = {}
local noclipRootPart = nil
local isSitting = false

function AR2_startNoclip()
    if AR2_noclipConn then return end
    local char = AR2_LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.Sit = true
    hum.PlatformStand = true
    isSitting = true
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local parts = {}
    local radius = 15
    for _, obj in ipairs(AR2_Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Position - root.Position).Magnitude <= radius then
            table.insert(parts, obj)
        end
    end
    if #parts == 0 then
        AR2_CFG.misc.noclip = false
        return
    end

    noclipOffsets = {}
    for _, part in ipairs(parts) do
        noclipOffsets[part] = root.CFrame:Inverse() * part.CFrame
    end
    noclipRootPart = root
    noclipParts = parts

    for _, part in ipairs(parts) do part.Anchored = true end

    AR2_noclipConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_CFG.misc.noclip then AR2_stopNoclip() return end
        if not noclipRootPart or not noclipRootPart.Parent then AR2_stopNoclip() return end

        local hum2 = AR2_LocalPlayer.Character and AR2_LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum2 then
            hum2.Sit = true
            hum2.PlatformStand = true
            isSitting = true
        else
            AR2_stopNoclip()
            return
        end

        local cam = Workspace.CurrentCamera
        local move = Vector3.zero
        if AR2_noclipKeys.W then move += cam.CFrame.LookVector end
        if AR2_noclipKeys.S then move -= cam.CFrame.LookVector end
        if AR2_noclipKeys.D then move += cam.CFrame.RightVector end
        if AR2_noclipKeys.A then move -= cam.CFrame.RightVector end
        if AR2_noclipKeys.Space then move += Vector3.new(0,1,0) end
        if AR2_noclipKeys.LeftControl then move -= Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            local delta = move.Unit * (AR2_CFG.misc.noclipSpeed or 90) * 0.05
            local newCF = noclipRootPart.CFrame + delta
            noclipRootPart.CFrame = newCF
            for part, offset in pairs(noclipOffsets) do
                if part and part.Parent then part.CFrame = newCF * offset end
            end
        end
    end)
end

function AR2_stopNoclip()
    AR2_CFG.misc.noclip = false
    if AR2_noclipConn then AR2_noclipConn:Disconnect() AR2_noclipConn = nil end
    for _, part in ipairs(noclipParts) do
        if part and part.Parent then
            part.Anchored = false
            part.Velocity = Vector3.zero
            part.RotVelocity = Vector3.zero
        end
    end
    noclipParts = {}
    noclipOffsets = {}
    noclipRootPart = nil
    for k in pairs(AR2_noclipKeys) do AR2_noclipKeys[k] = false end
    local char = AR2_LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.Sit = false
            hum.PlatformStand = false
            isSitting = false
        end
    end
end

function AR2_toggleNoclip(enabled)
    if enabled and not AR2_noclipConn then
        AR2_CFG.misc.noclip = true
        AR2_startNoclip()
    elseif not enabled and AR2_noclipConn then
        AR2_stopNoclip()
    end
end

AR2_UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then AR2_noclipKeys.W = true
    elseif k == Enum.KeyCode.A then AR2_noclipKeys.A = true
    elseif k == Enum.KeyCode.S then AR2_noclipKeys.S = true
    elseif k == Enum.KeyCode.D then AR2_noclipKeys.D = true
    elseif k == Enum.KeyCode.Space then AR2_noclipKeys.Space = true
    elseif k == Enum.KeyCode.LeftControl then AR2_noclipKeys.LeftControl = true end
end)
AR2_UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then AR2_noclipKeys.W = false
    elseif k == Enum.KeyCode.A then AR2_noclipKeys.A = false
    elseif k == Enum.KeyCode.S then AR2_noclipKeys.S = false
    elseif k == Enum.KeyCode.D then AR2_noclipKeys.D = false
    elseif k == Enum.KeyCode.Space then AR2_noclipKeys.Space = false
    elseif k == Enum.KeyCode.LeftControl then AR2_noclipKeys.LeftControl = false end
end)


AR2_infJumpConn = nil
AR2_infJumpLast = 0
function AR2_startInfJump()
    if AR2_infJumpConn then return end
    AR2_infJumpConn = AR2_UserInputService.InputBegan:Connect(function(input, gpe)
        if not AR2_CFG.misc.infJump then return end
        if gpe then return end
        if input.KeyCode ~= Enum.KeyCode.Space then return end

        local char = AR2_LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        task.spawn(function()
            if not hrp.Parent then return end
            hrp.Anchored = true
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 15, 0)
            task.wait(0.03)
            if hrp and hrp.Parent then
                hrp.Anchored = false
            end
        end)
    end)
end

function AR2_stopInfJump()
    if AR2_infJumpConn then AR2_infJumpConn:Disconnect() AR2_infJumpConn = nil end
end

function AR2_flyToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local char = AR2_LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetRoot then return end

    local anchoredParts = {}
    local offsets = {}
    for _, part in ipairs(AR2_Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and (part.Position - hrp.Position).Magnitude <= 15 then
            anchoredParts[#anchoredParts+1] = part
            offsets[part] = hrp.CFrame:Inverse() * part.CFrame
            part.Anchored = true
        end
    end

    for _ = 1, 400 do
        if not targetPlayer.Character or not targetRoot.Parent then break end
        local targetPos = targetRoot.Position + Vector3.new(0, 2, 0)
        local delta = targetPos - hrp.Position
        if delta.Magnitude <= 3 then break end
        local step = delta.Unit * math.min(15, delta.Magnitude)
        hrp.CFrame = hrp.CFrame + step
        for _, part in ipairs(anchoredParts) do
            if part.Parent then part.CFrame = hrp.CFrame * offsets[part] end
        end
        AR2_RunService.Heartbeat:Wait()
    end

    for _, part in ipairs(anchoredParts) do
        if part.Parent then part.Anchored = false end
    end
end

AR2_bhopConn = nil
function AR2_startBhop()
    if AR2_bhopConn then return end
    AR2_bhopConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_CFG.misc.bhop then AR2_stopBhop() return end
        local char = AR2_LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
        if not root or not hum then return end
        local moving = AR2_UserInputService:IsKeyDown(Enum.KeyCode.W)
                    or AR2_UserInputService:IsKeyDown(Enum.KeyCode.A)
                    or AR2_UserInputService:IsKeyDown(Enum.KeyCode.S)
                    or AR2_UserInputService:IsKeyDown(Enum.KeyCode.D)
        if moving and hum.FloorMaterial ~= Enum.Material.Air then
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X,
                AR2_CFG.misc.bhopHeight * 3,
                root.AssemblyLinearVelocity.Z
            )
        end
    end)
end

function AR2_stopBhop()
    AR2_CFG.misc.bhop = false
    if AR2_bhopConn then AR2_bhopConn:Disconnect() AR2_bhopConn = nil end
end

AR2_tpDashConn = nil
AR2_tpDashLast = 0

function AR2_startTpDash()
    if AR2_tpDashConn then return end
    AR2_CFG.misc.tpDash = true
    AR2_tpDashLast = os.clock()
    AR2_tpDashConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_CFG.misc.tpDash then AR2_stopTpDash() return end
        local now = os.clock()
        if now - AR2_tpDashLast < AR2_CFG.misc.tpDashInterval then return end
        AR2_tpDashLast = now
        local char = AR2_LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local fwd  = workspace.CurrentCamera.CFrame.LookVector
        local flat = Vector3.new(fwd.X, 0, fwd.Z)
        if flat.Magnitude < 0.01 then return end
        local verticalOffset = AR2_CFG.misc.tpDashVert or 0
        local movement = flat.Unit * AR2_CFG.misc.tpDashStuds + Vector3.new(0, verticalOffset, 0)
        root.CFrame = root.CFrame + movement
    end)
end

function AR2_stopTpDash()
    AR2_CFG.misc.tpDash = false
    if AR2_tpDashConn then AR2_tpDashConn:Disconnect() AR2_tpDashConn = nil end
end

AR2_carDashConn = nil
AR2_carDashLast = 0

function AR2_startCarDash()
    if AR2_carDashConn then return end
    AR2_CFG.car.tpDash = true
    AR2_carDashLast = os.clock()

    AR2_carDashConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_CFG.car.tpDash then AR2_stopCarDash() return end
        local now = os.clock()
        if now - AR2_carDashLast < AR2_CFG.car.tpDashInterval then return end
        AR2_carDashLast = now
        local model = AR2_carPick()
        if not model then return end
        local fwd  = workspace.CurrentCamera.CFrame.LookVector
        local flat = Vector3.new(fwd.X, 0, fwd.Z)
        if flat.Magnitude < 0.01 then return end
        flat = flat.Unit
        local verticalOffset = AR2_CFG.car.tpDashVert or 0
        local movement = flat * AR2_CFG.car.tpDashStuds + Vector3.new(0, verticalOffset, 0)
        local curPivot = model:GetPivot()
        local newPivot = CFrame.new(curPivot.Position + movement) * (curPivot - curPivot.Position)
        local savedAnchor = {}
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                savedAnchor[p] = p.Anchored
                p.Anchored = true
                p.AssemblyLinearVelocity = Vector3.zero
                p.AssemblyAngularVelocity = Vector3.zero
            end
        end
        model:PivotTo(newPivot)
        for p, wasAnchored in pairs(savedAnchor) do
            if p and p.Parent then
                p.Anchored = wasAnchored
                p.AssemblyLinearVelocity = Vector3.zero
                p.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

function AR2_stopCarDash()
    AR2_CFG.car.tpDash = false
    if AR2_carDashConn then AR2_carDashConn:Disconnect() AR2_carDashConn = nil end
end


AR2_car = { busy = false, cancel = false, gen = 0, lastResult = "", target = nil }

function AR2_carBase(model)
    return model and (model:FindFirstChild("Base") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"))
end

function AR2_carPick()
    local char = AR2_LocalPlayer.Character
    local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
    local seat = humanoid and humanoid.SeatPart
    local container = AR2_Workspace:FindFirstChild("Vehicles")
    if not container then return nil end
    if seat then
        local node = seat
        while node and node.Parent do
            if node.Parent == container then return node end
            node = node.Parent
        end
    end
    local best, bestDist = nil, math.huge
    local origin = AR2_localPosition()
    for _, model in ipairs(container:GetChildren()) do
        if model:IsA("Model") then
            local base = AR2_carBase(model)
            if base then
                local d = (base.Position - origin).Magnitude
                if d < bestDist then best, bestDist = model, d end
            end
        end
    end
    return best
end

function AR2_car.owned(model)
    local base = AR2_carBase(model)
    return base ~= nil and base.ReceiveAge == 0
end

AR2_carNoclipTP = { busy = false, cancel = false, gen = 0, lastResult = "" }

AR2_carNoclipRoot       = nil
AR2_carNoclipOffsets    = nil
AR2_carNoclipSaved      = nil
AR2_carNoclipModel      = nil
AR2_carNoclipCharOffset = nil

function AR2_carNoclipSetEnabled(enabled, anchor)
    if not enabled then
        if AR2_carNoclipSaved then
            for part, s in pairs(AR2_carNoclipSaved) do
                pcall(function()
                    if part and part.Parent then
                        part.AssemblyLinearVelocity  = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                        part.CanCollide = s.canCollide
                        part.Anchored   = s.anchored
                    end
                end)
            end
        end
        AR2_carNoclipSaved      = nil
        AR2_carNoclipOffsets    = nil
        AR2_carNoclipRoot       = nil
        AR2_carNoclipModel      = nil
        AR2_carNoclipCharOffset = nil
        AR2_CFG.misc.carNoclip  = false
        return true
    end

    local model = AR2_carPick()
    if not model then return false end
    local root = AR2_carBase(model)
    if not (root and root:IsA("BasePart")) then return false end

    local saved, offsets = {}, {}
    local rootCF = root.CFrame
    local count = 0

    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            saved[d] = { canCollide = d.CanCollide, anchored = d.Anchored }
            offsets[d] = rootCF:Inverse() * d.CFrame
            count = count + 1
            pcall(function()
                d.AssemblyLinearVelocity  = Vector3.zero
                d.AssemblyAngularVelocity = Vector3.zero
                d.CanCollide = false
                if anchor then d.Anchored = true end
            end)
        end
    end

    if count == 0 then return false end

    AR2_carNoclipCharOffset = nil
    if anchor then
        pcall(function()
            local char = AR2_LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then AR2_carNoclipCharOffset = rootCF:Inverse() * hrp.CFrame end
        end)
    end

    AR2_carNoclipModel   = model
    AR2_carNoclipRoot    = root
    AR2_carNoclipOffsets = offsets
    AR2_carNoclipSaved   = saved
    AR2_CFG.misc.carNoclip = true
    return true
end

AR2_carNoclipDriveConn = nil

local function AR2_carNoclipDriveStep(dt)
    local r = AR2_carNoclipRoot
    if not r or not r.Parent then return end
    local cam = AR2_Workspace.CurrentCamera
    if not cam then return end

    local speed = math.clamp(AR2_CFG.car.noclipSpeed or 90, 10, 1000)
    local uis = AR2_UserInputService

    local dir = Vector3.zero
    if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
    if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
    if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude > 0.01 then dir = dir.Unit else dir = Vector3.zero end

    local vert = 0
    if uis:IsKeyDown(Enum.KeyCode.Space) then vert = vert + 1 end
    if uis:IsKeyDown(Enum.KeyCode.LeftControl)
    or uis:IsKeyDown(Enum.KeyCode.Q) then vert = vert - 1 end

    local move = (dir * speed * dt) + Vector3.new(0, vert * speed * dt, 0)
    if move.Magnitude < 0.0001 then
        AR2_carNoclipTPMoveTo(r.CFrame)
        return
    end

    local baseCF = r.CFrame - r.CFrame.Position
    AR2_carNoclipTPMoveTo(CFrame.new(r.Position + move) * baseCF)
end

function AR2_carNoclipDriveStart()
    if AR2_carNoclipDriveConn then return end
    AR2_carNoclipDriveConn = AR2_RunService.Heartbeat:Connect(function(dt)
        if not AR2_CFG.misc.carNoclip then return end
        if AR2_carNoclipTP.busy then return end
        pcall(AR2_carNoclipDriveStep, dt)
    end)
end

function AR2_carNoclipDriveStop()
    if AR2_carNoclipDriveConn then
        pcall(function() AR2_carNoclipDriveConn:Disconnect() end)
        AR2_carNoclipDriveConn = nil
    end
end

function AR2_carNoclipStop()
    AR2_carNoclipDriveStop()
    return AR2_carNoclipSetEnabled(false)
end

function AR2_carHealth(model)
    if not model then return nil end
    local hp = nil
    pcall(function()
        local attr = model:GetAttribute("Health")
        if type(attr) == "number" then hp = attr return end
        local hv = model:FindFirstChild("Health")
        if hv and hv:IsA("ValueBase") and type(hv.Value) == "number" then hp = hv.Value return end
        local hum = model:FindFirstChildWhichIsA("Humanoid")
        if hum then hp = hum.Health return end
        local base = AR2_carBase(model)
        if base then
            local ba = base:GetAttribute("Health")
            if type(ba) == "number" then hp = ba end
        end
    end)
    return hp
end

function AR2_ejectFromVehicle()
    local char = AR2_LocalPlayer.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return false end
    local seat = hum.SeatPart
    pcall(function() hum.Sit = false end)
    pcall(function()
        if seat then
            local weld = seat:FindFirstChild("SeatWeld")
            if weld then weld:Destroy() end
        end
    end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    return true
end

function AR2_stopVehicleVelocity(model)
    if not model then return false end
    pcall(function()
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                p.AssemblyLinearVelocity  = Vector3.zero
                p.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
    return true
end

local function AR2_carNoclipTPMoveTo(newCF)
    local r = AR2_carNoclipRoot
    if not r or not r.Parent then return end
    r.CFrame = newCF
    pcall(function()
        r.AssemblyLinearVelocity  = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end)
    for part, offset in pairs(AR2_carNoclipOffsets or {}) do
        if part and part.Parent and part ~= r then
            part.CFrame = newCF * offset
        end
    end
    if AR2_carNoclipCharOffset then
        pcall(function()
            local char = AR2_LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = newCF * AR2_carNoclipCharOffset
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
end

function AR2_carNoclipTP.run(goalPosition, label)
    AR2_carNoclipTP.gen = (AR2_carNoclipTP.gen or 0) + 1
    local mine = AR2_carNoclipTP.gen
    AR2_carNoclipTP.cancel = true

    task.spawn(function()
        local runOk, runErr = pcall(function()
        while AR2_carNoclipTP.busy do task.wait() end
        if AR2_carNoclipTP.gen ~= mine then return end

        AR2_carNoclipTP.busy, AR2_carNoclipTP.cancel = true, false
        local started = os.clock()
        local tag = label or "car TP"

        if not AR2_inVehicle() then
            AR2_carNoclipTP.lastResult = tag .. " -- not in a vehicle"
            AR2_carNoclipTP.busy = false
            return
        end

        local model = AR2_carPick()
        if not model then
            AR2_carNoclipTP.lastResult = tag .. " -- no vehicle found"
            AR2_carNoclipTP.busy = false
            return
        end

        local wasNoclip = AR2_CFG.misc.carNoclip == true
        pcall(AR2_carNoclipDriveStop)
        pcall(AR2_carNoclipSetEnabled, false)
        task.wait(0.05)
        local okCall, ok = pcall(AR2_carNoclipSetEnabled, true, true)
        if not okCall then
            AR2_carNoclipTP.lastResult = tag .. " -- noclip error: " .. tostring(ok)
            AR2_carNoclipTP.busy = false
            return
        end
        if not ok then
            AR2_carNoclipTP.lastResult = tag .. " -- could not enable noclip"
            AR2_carNoclipTP.busy = false
            return
        end
        if not AR2_carNoclipRoot then
            AR2_carNoclipTP.lastResult = tag .. " -- no car root part"
            pcall(AR2_carNoclipSetEnabled, false)
            AR2_carNoclipTP.busy = false
            return
        end

        local vertOffset = AR2_CFG.car.noclipTPVertOffset or 5
        local goal = Vector3.new(goalPosition.X, goalPosition.Y + vertOffset, goalPosition.Z)

        local speed   = math.max(50, AR2_CFG.car.noclipTPSpeed or 800)
        local maxSecs = math.max(2, AR2_CFG.car.noclipTPMaxSeconds or 15)
        local deadline = os.clock() + maxSecs
        local reached = false

        while os.clock() < deadline do
            if AR2_carNoclipTP.cancel or AR2_carNoclipTP.gen ~= mine then break end
            local r = AR2_carNoclipRoot
            if not r or not r.Parent then break end

            local delta = goal - r.Position
            local dist  = delta.Magnitude
            if dist <= 2 then
                reached = true
                break
            end

            local step = math.min(speed * (1/60), dist)
            local baseCF = r.CFrame - r.CFrame.Position
            AR2_carNoclipTPMoveTo(CFrame.new(r.Position + delta.Unit * step) * baseCF)

            AR2_RunService.Heartbeat:Wait()
        end

        if reached and AR2_carNoclipRoot and AR2_carNoclipRoot.Parent then
            pcall(function()
                local r = AR2_carNoclipRoot
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {
                    AR2_carNoclipModel, AR2_LocalPlayer.Character
                }
                local hit = AR2_Workspace:Raycast(
                    r.Position + Vector3.new(0, 20, 0),
                    Vector3.new(0, -400, 0), params)
                if hit then
                    local baseCF = r.CFrame - r.CFrame.Position
                    local clearance = (r.Size.Y * 0.5) + 2
                    AR2_carNoclipTPMoveTo(
                        CFrame.new(hit.Position + Vector3.new(0, clearance, 0)) * baseCF)
                end
            end)
            task.wait(0.1)
        end

        if wasNoclip then
            pcall(AR2_carNoclipSetEnabled, true, true)
            pcall(AR2_carNoclipDriveStart)
        else
            pcall(AR2_carNoclipSetEnabled, false)
        end

        local elapsed = os.clock() - started
        if reached then
            AR2_carNoclipTP.lastResult = string.format("%s -- arrived in %.1fs", tag, elapsed)
        else
            AR2_carNoclipTP.lastResult = string.format("%s -- timeout after %.1fs", tag, elapsed)
        end
        AR2_carNoclipTP.busy = false
        end)
        if not runOk then
            AR2_carNoclipTP.lastResult = "car TP error: " .. tostring(runErr)
            AR2_carNoclipTP.busy = false
            pcall(AR2_carNoclipSetEnabled, false)
        end
    end)
end

function AR2_carNoclipTP.toPlayer()
    local wanted = AR2_CFG.tp.target
    if wanted == "-" then AR2_carNoclipTP.lastResult = "no player picked" return end
    local root = AR2_tpTargetRoot()
    if not root then AR2_carNoclipTP.lastResult = "target not found" return end
    AR2_carNoclipTP.run(root.Position, wanted)
end

function AR2_carNoclipTP.toPosition(position, label)
    AR2_carNoclipTP.run(position, label or "map")
end

function AR2_carNoclipTP.stop()
    AR2_carNoclipTP.cancel = true
    AR2_carNoclipTP.gen = (AR2_carNoclipTP.gen or 0) + 1
end


AR2_speed = { enabled = false, resets = 0, lastReset = nil }
AR2_speedConn = nil
AR2_lastPosition = nil
AR2_BASE_SPEED = 16
AR2_RESET_JUMP = 25

function AR2_localRig()
    local char = AR2_LocalPlayer.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildWhichIsA("Humanoid")
end

function AR2_wishDirection()
    local cam = Workspace.CurrentCamera
    local dir = Vector3.zero
    if AR2_UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
    if AR2_UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
    if AR2_UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    if AR2_UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude < 0.01 then return nil end
    return dir.Unit
end

function AR2_detectReset(position)
    if not AR2_lastPosition then AR2_lastPosition = position return false end
    local jump = (position - AR2_lastPosition).Magnitude
    AR2_lastPosition = position
    if jump < AR2_RESET_JUMP then return false end
    AR2_speed.resets = AR2_speed.resets + 1
    return true
end

function AR2_stepSpeed(dt)
    local c = AR2_CFG.speed
    local char, root = AR2_localRig()
    if not c.on or not root then AR2_lastPosition = nil return end
    if AR2_detectReset(root.Position) and c.adaptive then
        local reduced = math.max(c.minPct, c.pct - 10)
        if reduced ~= c.pct then c.pct = reduced end
        return
    end
    if c.pct <= 100 then return end
    if c.pulse then
        local onTime = c.pulseOn/100
        local offTime = c.pulseOff/100
        local period = onTime + offTime
        if period > 0 and (os.clock() % period) >= onTime then return end
    end
    local dir = AR2_wishDirection()
    if not dir then return end
    local extra = AR2_BASE_SPEED * (c.pct/100 - 1) * dt
    if extra <= 0 then return end
    if c.collide then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { char }
        if AR2_Workspace:Raycast(root.Position, dir * (extra + 2), params) then return end
    end
    if c.airborne then
        local grounded = math.abs(root.AssemblyLinearVelocity.Y) < 1
        if grounded then root.CFrame = root.CFrame + Vector3.new(0, 3.5, 0) end
    end
    if c.spoof then
        local folder = char:FindFirstChild("Animator")
        local state = folder and folder:FindFirstChild("MoveState")
        if state and state.Value ~= c.spoofAs then state.Value = c.spoofAs end
    end
    root.CFrame = root.CFrame + dir * extra
    AR2_lastPosition = root.Position
end

function AR2_speed.start()
    if AR2_speedConn then return end
    AR2_speed.enabled = true
    AR2_speedConn = AR2_RunService.RenderStepped:Connect(function(dt)
        local ok, err = pcall(AR2_stepSpeed, dt)
        if not ok then warn("[speed] "..tostring(err)) end
    end)
end

function AR2_speed.stop()
    AR2_speed.enabled = false
    if AR2_speedConn then AR2_speedConn:Disconnect() AR2_speedConn = nil end
end


AR2_carMods = { running = false, touched = 0, note = "off" }
AR2_touched = {}
AR2_carLoopGen = 0

function AR2_carConfig(model)
    local module = model:FindFirstChild("Config")
    if not (module and module:IsA("ModuleScript")) then return nil end
    local ok, tbl = pcall(require, module)
    return (ok and type(tbl) == "table") and tbl or nil
end

function AR2_forEachDamageMod(cfg, fn)
    if type(cfg.Health) ~= "table" then return end
    for _, group in pairs(cfg.Health) do
        if type(group) == "table" and type(group.DamageModifiers) == "table" then
            for key in pairs(group.DamageModifiers) do fn(group.DamageModifiers, key) end
        end
        if type(group) == "table" and not group.DamageModifiers then
            for _, sub in pairs(group) do
                if type(sub) == "table" and type(sub.DamageModifiers) == "table" then
                    for key in pairs(sub.DamageModifiers) do fn(sub.DamageModifiers, key) end
                end
            end
        end
    end
end

function AR2_snapshot(cfg)
    if AR2_touched[cfg] then return AR2_touched[cfg] end
    local saved = { torques = {}, grips = {}, dmg = {} }
    if type(cfg.Fuel) == "table" then saved.burnRate = cfg.Fuel.BurnRate end
    if type(cfg.Physics) == "table" then
        saved.driveSpeed = cfg.Physics.DriveSpeed
        saved.reverseSpeed = cfg.Physics.ReverseSpeed

        if type(cfg.Physics.Wheels) == "table" then
            for name, wheel in pairs(cfg.Physics.Wheels) do
                if type(wheel) == "table"
                   and type(wheel.Shock) == "table"
                   and wheel.Shock.DriveMotorTorque then
                    saved.torques[name] = wheel.Shock.DriveMotorTorque
                end
            end
        end

        if type(cfg.Physics.MaterialGrip) == "table" then
            for name, material in pairs(cfg.Physics.MaterialGrip) do
                if type(material) == "table" then
                    saved.grips[name] = {
                        Speed    = material.Speed,
                        Friction = material.Friction,
                    }
                end
            end
        end
    end
    if type(cfg.ExitDamage) == "table" then saved.exitMax = cfg.ExitDamage.MaxSpeed end
    AR2_forEachDamageMod(cfg, function(t, k) saved.dmg[#saved.dmg+1] = { t = t, k = k, v = t[k] } end)
    AR2_touched[cfg] = saved
    return saved
end

function AR2_applyTo(cfg, model)
    local c = AR2_CFG.car
    local saved = AR2_snapshot(cfg)

    if c.boost and type(cfg.Physics) == "table" then
        cfg.Physics.DriveSpeed   = c.speed
        cfg.Physics.ReverseSpeed = math.floor(c.speed * 0.4)

        if type(cfg.Physics.Wheels) == "table" then
            for name, wheel in pairs(cfg.Physics.Wheels) do
                if type(wheel) == "table"
                   and type(wheel.Shock) == "table"
                   and saved.torques[name] then
                    wheel.Shock.DriveMotorTorque = saved.torques[name] * c.torque
                end
            end
        end

        if type(cfg.ExitDamage) == "table" then
            cfg.ExitDamage.MaxSpeed = 99999
        end
    end

    if c.maxTraction and type(cfg.Physics) == "table"
       and type(cfg.Physics.MaterialGrip) == "table" then
        for _, mat in pairs(cfg.Physics.MaterialGrip) do
            if type(mat) == "table" then
                if mat.Speed    ~= nil then mat.Speed    = 1 end
                if mat.Friction ~= nil then mat.Friction = 1 end
            end
        end
    end

    if c.fuel and type(cfg.Fuel) == "table" then
        cfg.Fuel.BurnRate        = 0
        cfg.Fuel.ConsumptionRate = 0
    end

    if c.god and type(cfg.Health) == "table" then
        local function zeroDmg(t)
            if type(t) ~= "table" then return end
            if type(t.DamageModifiers) == "table" then
                for k in pairs(t.DamageModifiers) do
                    t.DamageModifiers[k] = 0
                end
            else
                for _, v in pairs(t) do zeroDmg(v) end
            end
        end
        zeroDmg(cfg.Health)
    end
end

function AR2_restoreOne(cfg)
    local saved = AR2_touched[cfg]
    if not saved then return end
    if type(cfg.Fuel) == "table" and saved.burnRate ~= nil then cfg.Fuel.BurnRate = saved.burnRate end
    if type(cfg.Physics) == "table" then
        if saved.driveSpeed ~= nil then cfg.Physics.DriveSpeed = saved.driveSpeed end
        if saved.reverseSpeed ~= nil then cfg.Physics.ReverseSpeed = saved.reverseSpeed end

        if type(cfg.Physics.Wheels) == "table" then
            for name, wheel in pairs(cfg.Physics.Wheels) do
                if type(wheel) == "table"
                   and type(wheel.Shock) == "table"
                   and saved.torques[name] then
                    wheel.Shock.DriveMotorTorque = saved.torques[name]
                end
            end
        end

        if type(cfg.Physics.MaterialGrip) == "table" then
            for name, material in pairs(cfg.Physics.MaterialGrip) do
                if type(material) == "table" and saved.grips[name] then
                    if saved.grips[name].Speed    ~= nil then material.Speed    = saved.grips[name].Speed    end
                    if saved.grips[name].Friction ~= nil then material.Friction = saved.grips[name].Friction end
                end
            end
        end
    end
    if type(cfg.ExitDamage) == "table" and saved.exitMax ~= nil then cfg.ExitDamage.MaxSpeed = saved.exitMax end
    for _, entry in ipairs(saved.dmg) do entry.t[entry.k] = entry.v end
    AR2_touched[cfg] = nil
end

function AR2_restoreAll()
    for cfg in pairs(AR2_touched) do AR2_restoreOne(cfg) end
    AR2_carMods.touched = 0
end

function AR2_occupiedCar()
    local char = AR2_LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local vehicles = AR2_Workspace:FindFirstChild("Vehicles")
    if not vehicles then return nil end

    for _, model in ipairs(vehicles:GetChildren()) do
        if model:IsA("Model") then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    for _, weld in ipairs(part:GetChildren()) do
                        if (weld:IsA("Weld") or weld:IsA("WeldConstraint"))
                        and (weld.Part0 == hrp or weld.Part1 == hrp) then
                            return model
                        end
                    end
                end
            end
        end
    end

    local best, bestDist = nil, 12
    for _, model in ipairs(vehicles:GetChildren()) do
        if model:IsA("Model") then
            local base = AR2_carBase(model)
            if base then
                local d = (base.Position - hrp.Position).Magnitude
                if d < bestDist then best = model bestDist = d end
            end
        end
    end
    return best
end

function AR2_sweep()
    local vehicles = AR2_Workspace:FindFirstChild("Vehicles")
    if not vehicles then AR2_carMods.note = "no Vehicles folder" return end
    local count = 0
    if AR2_CFG.car.allCars then
        for _, model in ipairs(vehicles:GetChildren()) do
            if model:IsA("Model") then
                local cfg = AR2_carConfig(model)
                if cfg then AR2_applyTo(cfg, model) count = count + 1 end
            end
        end
    else
        local model = AR2_occupiedCar()
        local cfg = model and AR2_carConfig(model)
        if cfg then AR2_applyTo(cfg, model) count = count + 1 end
    end
    AR2_carMods.touched = count
    local parts_ = {}
    if AR2_CFG.car.fuel then parts_[#parts_+1] = "fuel" end
    if AR2_CFG.car.boost then parts_[#parts_+1] = "boost" end
    if AR2_CFG.car.god then parts_[#parts_+1] = "god" end
    if AR2_CFG.car.maxTraction then parts_[#parts_+1] = "traction" end
    AR2_carMods.note = string.format("%s  --  %d car%s tuned%s", table.concat(parts_, ", "), count, count == 1 and "" or "s", AR2_CFG.car.allCars and "  (all)" or "  (yours)")
end

function AR2_carMods.apply()
    local wanted = AR2_CFG.car.fuel or AR2_CFG.car.boost or AR2_CFG.car.god or AR2_CFG.car.maxTraction
    AR2_restoreAll()
    AR2_carLoopGen = AR2_carLoopGen + 1
    if not wanted then
        AR2_carMods.running = false
        AR2_carMods.note = "off"
        return
    end
    AR2_carMods.running = true
    pcall(AR2_sweep)
    local mine = AR2_carLoopGen
    task.spawn(function()
        while mine == AR2_carLoopGen and AR2_carMods.running do
            task.wait(1)
            if mine ~= AR2_carLoopGen then break end
            pcall(AR2_sweep)
        end
    end)
end

function AR2_carMods.destroy()
    AR2_carLoopGen = AR2_carLoopGen + 1
    AR2_carMods.running = false
    AR2_restoreAll()
    AR2_carMods.note = "off"
end


function AR2_setBoatMode(enabled)
    AR2_CFG.car.boatMode = enabled
    local waterFolder = AR2_Workspace:FindFirstChild("Map")
        and AR2_Workspace.Map:FindFirstChild("Water")
        or  AR2_Workspace:FindFirstChild("Water")
    if not waterFolder then return end
    for _, part in ipairs(waterFolder:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if enabled then
                if part:HasTag("Swim Surface") then
                    part:RemoveTag("Swim Surface")
                    part:AddTag("Boat Surface")
                end
            else
                if part:HasTag("Boat Surface") then
                    part:RemoveTag("Boat Surface")
                    part:AddTag("Swim Surface")
                end
            end
        end
    end
end

AR2_dragSaved   = {}
AR2_dragVehicle = nil

function AR2_setRemoveDrag(enabled)
    AR2_CFG.car.removeDrag = enabled
    local model = AR2_carPick()
    if not model then return end
    local cfg = AR2_carConfig(model)
    if not cfg then return end

    if enabled then
        AR2_dragSaved   = {}
        AR2_dragVehicle = model
        if type(cfg.Physics) == "table" then
            if type(cfg.Physics.MaterialGrip) == "table" then
                for matName, mat in pairs(cfg.Physics.MaterialGrip) do
                    if type(mat) == "table" then
                        if mat.Speed ~= nil then
                            AR2_dragSaved["gs_"..matName] = mat.Speed
                            mat.Speed = 1
                        end
                        if mat.Friction ~= nil then
                            AR2_dragSaved["gf_"..matName] = mat.Friction
                            mat.Friction = 1
                        end
                    end
                end
            end
            if type(cfg.Physics.Wheels) == "table" then
                for wname, wheel in pairs(cfg.Physics.Wheels) do
                    if type(wheel) == "table" then
                        if wheel.Elasticity ~= nil then
                            AR2_dragSaved["we_"..tostring(wname)] = wheel.Elasticity
                            wheel.Elasticity = 0
                        end
                        if wheel.Friction ~= nil then
                            AR2_dragSaved["wf_"..tostring(wname)] = wheel.Friction
                            wheel.Friction = 1
                        end
                    end
                end
            end
        end
    else
        if AR2_dragVehicle then
            local cfgOld = AR2_carConfig(AR2_dragVehicle)
            if cfgOld and cfgOld.Physics then
                if type(cfgOld.Physics.MaterialGrip) == "table" then
                    for matName, mat in pairs(cfgOld.Physics.MaterialGrip) do
                        if type(mat) == "table" then
                            if AR2_dragSaved["gs_"..matName] then mat.Speed    = AR2_dragSaved["gs_"..matName] end
                            if AR2_dragSaved["gf_"..matName] then mat.Friction = AR2_dragSaved["gf_"..matName] end
                        end
                    end
                end
                if type(cfgOld.Physics.Wheels) == "table" then
                    for wname, wheel in pairs(cfgOld.Physics.Wheels) do
                        if type(wheel) == "table" then
                            local we = AR2_dragSaved["we_"..tostring(wname)]
                            local wf = AR2_dragSaved["wf_"..tostring(wname)]
                            if we then wheel.Elasticity = we end
                            if wf then wheel.Friction   = wf end
                        end
                    end
                end
            end
        end
        AR2_dragSaved, AR2_dragVehicle = {}, nil
    end
end

AR2_steerSaved   = {}
AR2_steerApplied = false
AR2_steerConn    = nil

function AR2_setFullSteer(enabled)
    AR2_CFG.car.fullSteer = enabled
    if enabled then
        if AR2_steerConn then return end
        AR2_steerConn = AR2_RunService.Heartbeat:Connect(function()
            if not AR2_CFG.car.fullSteer then return end
            local model = AR2_carPick()
            if not model then return end
            local cfg = AR2_carConfig(model)
            if not cfg or not cfg.Physics then return end

            if not AR2_steerApplied then
                AR2_steerApplied = true
                for _, k in ipairs({"FullSteeringUntil","NoSteeringAfter","SteerResponce","TurnSpeed"}) do
                    if cfg.Physics[k] ~= nil then AR2_steerSaved[k] = cfg.Physics[k] end
                end
                if type(cfg.Physics.Wheels) == "table" then
                    for wname, wheel in pairs(cfg.Physics.Wheels) do
                        if type(wheel) == "table" and wheel.SteerAngle ~= nil then
                            AR2_steerSaved["sa_"..tostring(wname)] = wheel.SteerAngle
                        end
                    end
                end
            end

            if cfg.Physics.FullSteeringUntil ~= nil then cfg.Physics.FullSteeringUntil = 9999 end
            if cfg.Physics.NoSteeringAfter   ~= nil then cfg.Physics.NoSteeringAfter   = 99999 end
            if cfg.Physics.SteerResponce     ~= nil then cfg.Physics.SteerResponce     = math.max(8, cfg.Physics.SteerResponce) end
            if type(cfg.Physics.Wheels) == "table" then
                for wname, wheel in pairs(cfg.Physics.Wheels) do
                    if type(wheel) == "table" and wheel.SteerAngle ~= nil then
                        local orig = AR2_steerSaved["sa_"..tostring(wname)] or 0
                        if orig > 0 then wheel.SteerAngle = math.max(orig, 45)
                        elseif orig < 0 then wheel.SteerAngle = math.min(orig, -45) end
                    end
                end
            end
        end)
    else
        if AR2_steerConn then AR2_steerConn:Disconnect() AR2_steerConn = nil end
        if AR2_steerApplied then
            local model = AR2_carPick()
            local cfg = model and AR2_carConfig(model)
            if cfg and cfg.Physics then
                for k, v in pairs(AR2_steerSaved) do
                    if type(k) == "string" and k:sub(1,3) ~= "sa_" then
                        cfg.Physics[k] = v
                    end
                end
                if type(cfg.Physics.Wheels) == "table" then
                    for wname, wheel in pairs(cfg.Physics.Wheels) do
                        if type(wheel) == "table" then
                            local saved = AR2_steerSaved["sa_"..tostring(wname)]
                            if saved then wheel.SteerAngle = saved end
                        end
                    end
                end
            end
            AR2_steerSaved, AR2_steerApplied = {}, false
        end
    end
end


AR2_afsEnabled = false
AR2_afsConn    = nil

function AR2_setAntiFallStun(enabled)
    AR2_CFG.misc.antiFallStun = enabled
    AR2_afsEnabled = enabled

    if AR2_afsConn then AR2_afsConn:Disconnect() AR2_afsConn = nil end
    if not enabled then return end

    AR2_afsConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_afsEnabled then return end
        local gc = AR2_gameChar
        if type(gc) ~= "table" then return end
        pcall(function()
            if rawget(gc, "FallImpacting") ~= nil then rawset(gc, "FallImpacting", false) end
            if rawget(gc, "Staggered")     ~= nil then rawset(gc, "Staggered", false)     end
            local rt = rawget(gc, "RagdollTimer")
            if type(rt) == "number" and rt > 0 then rawset(gc, "RagdollTimer", 0) end
        end)
    end)
end


AR2_vehEquipEnabled      = false
AR2_vehEquipPC           = nil
AR2_vehEquipOrig         = nil
AR2_vehEquipInVeh        = false
AR2_vehEquipBulletHooked = false
AR2_vehEquipOrigFire     = nil

do
    local RS = AR2_ReplicatedStorage

    local function _getPC()
        local ok, pc = pcall(function()
            return require(RS.Client.Classes.Players).get()
        end)
        return ok and pc or nil
    end

    local function _withWritable(t, fn)
        if type(t) ~= "table" then return end
        local wasReadonly = false
        pcall(function()
            if isreadonly then wasReadonly = isreadonly(t) end
        end)
        pcall(function() setreadonly(t, false) end)
        pcall(fn)
        if wasReadonly then
            pcall(function() setreadonly(t, true) end)
        end
    end

    AR2_vehEquipPC = _getPC()

    AR2_RunService.Heartbeat:Connect(function()
        pcall(function()
            local pc = AR2_vehEquipPC
            if not pc then return end
            local char = pc.Character
            local flag = char and char.IsVehicleDriver
            AR2_vehEquipInVeh = flag == true
        end)
    end)

    local okCh, Chars = pcall(function() return require(RS.Client.Classes.Characters) end)
    if okCh and Chars then AR2_vehEquipOrig = Chars.Equip end

    local TIMING = {
        "NextEquipTime","LastEquipTime","EquipDelay","NextHotbarSwitchTime",
        "UseDelay","CooldownTime","EquipCooldown","NextEquipValid","EquipReadyAt",
        "SwitchTime","NextSwitchTime","HotbarSwitchTime","EquipTime","SelectTime",
    }
    local VEH_KEYS = { "IsVehicleDriver","Sitting","Mounting","Dismounting" }

    local function _zeroTiming(item)
        if not item then return end
        _withWritable(item, function()
            for _, f in ipairs(TIMING) do rawset(item, f, 0) end
        end)
        local inner = rawget(item, "__item")
        if type(inner) == "table" then
            _withWritable(inner, function()
                for _, f in ipairs(TIMING) do rawset(inner, f, 0) end
            end)
        end
    end

    local function _customVehEquip(self, item, ...)
        _zeroTiming(item)
        if not AR2_vehEquipOrig then return end
        if not (AR2_vehEquipEnabled and AR2_vehEquipInVeh) then
            return AR2_vehEquipOrig(self, item, ...)
        end

        local saved = {}
        _withWritable(self, function()
            for _, key in ipairs(VEH_KEYS) do
                saved[key] = rawget(self, key)
                rawset(self, key, false)
            end
            saved.isItemUsable = rawget(self, "isItemUsable")
            rawset(self, "isItemUsable", function() return true end)
        end)

        local ok, result = pcall(AR2_vehEquipOrig, self, item, ...)

        _withWritable(self, function()
            for _, key in ipairs(VEH_KEYS) do rawset(self, key, saved[key]) end
            rawset(self, "isItemUsable", saved.isItemUsable)
        end)

        return ok and result or nil
    end

    local function _patch(char)
        if not char or not AR2_vehEquipOrig then return false end
        if not AR2_CAP.getrawmetatable then return false end
        local ok = pcall(function()
            local mt = getrawmetatable(char)
            if not mt then return false end
            local oldIndex = rawget(mt, "__index")
            _withWritable(mt, function()
                rawset(mt, "__index", AR2_newcclosure(function(self, key)
                    if AR2_vehEquipEnabled and key == "Equip" then
                        return _customVehEquip
                    end
                    if type(oldIndex) == "function" then return oldIndex(self, key)
                    elseif oldIndex ~= nil then return oldIndex[key] end
                    return nil
                end))
            end)
            return true
        end)
        return ok
    end

    local function _hookBullets()
        if AR2_vehEquipBulletHooked then return end
        local ok, Bullets = pcall(function() return require(RS.Client.Libraries.Bullets) end)
        if not ok or not Bullets or not Bullets.Fire then return end
        AR2_vehEquipOrigFire = Bullets.Fire

        _withWritable(Bullets, function()
            rawset(Bullets, "Fire", function(self, pc2, wi, wd, origin, dir, sid)
                if AR2_vehEquipEnabled and wd then
                    _withWritable(wd, function()
                        wd.CanFire = true wd.CanFireInVehicles = true
                        wd.InVehicle = false wd.VehicleFireLocked = false
                    end)
                    local inner = rawget(wd, "__item")
                    if type(inner) == "table" then
                        _withWritable(inner, function()
                            inner.CanFire = true inner.CanFireInVehicles = true
                            inner.InVehicle = false inner.VehicleFireLocked = false
                        end)
                    end
                end
                return AR2_vehEquipOrigFire(self, pc2, wi, wd, origin, dir, sid)
            end)
        end)

        AR2_vehEquipBulletHooked = true
    end

    if AR2_vehEquipPC and AR2_vehEquipPC.Character then
        _patch(AR2_vehEquipPC.Character)
    end
    _hookBullets()

    AR2_LocalPlayer.CharacterAdded:Connect(function()


        task.wait(1)
        local pc4 = _getPC()
        if pc4 then
            AR2_vehEquipPC = pc4
            local ok6, C = pcall(function() return require(RS.Client.Classes.Characters) end)
            if ok6 and C and C.Equip then AR2_vehEquipOrig = C.Equip end
            if pc4.Character then _patch(pc4.Character) end
        end
    end)
end

function AR2_setVehicleEquip(enabled)
    AR2_vehEquipEnabled = enabled
    AR2_CFG.weapon.vehicleEquip = enabled
end


AR2_doorsRemoved = {}
AR2_doorsConn = nil

local function AR2_hideDoorPart(part)
    if not part:IsA("BasePart") then return end
    if AR2_doorsRemoved[part] ~= nil then return end
    AR2_doorsRemoved[part] = {
        transparency = part.Transparency,
        canCollide   = part.CanCollide,
        canQuery     = part.CanQuery,
        canTouch     = part.CanTouch,
    }
    pcall(function()
        part.Transparency = 1
        part.CanCollide   = false
        part.CanQuery     = false
        part.CanTouch     = false
    end)
end

local function AR2_hideDoor(inst)
    if inst:IsA("BasePart") then
        AR2_hideDoorPart(inst)
    else
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("BasePart") then AR2_hideDoorPart(d) end
        end
    end
end

local function AR2_isDoorInstance(inst)
    if inst.Name ~= "Door" then return false end
    local parent = inst.Parent
    if not parent then return false end
    local container = parent.Parent
    return container ~= nil and container.Name == "Doors"
end

local function AR2_scanDoors(root)
    for _, desc in ipairs(root:GetDescendants()) do
        if AR2_isDoorInstance(desc) then AR2_hideDoor(desc) end
    end
end

function AR2_setRemoveDoors(enabled)
    AR2_CFG.visuals.removeDoors = enabled

    if AR2_doorsConn then
        pcall(function() AR2_doorsConn:Disconnect() end)
        AR2_doorsConn = nil
    end

    if enabled then
        local map = AR2_Workspace:FindFirstChild("Map")
        local mapElements = map and map:FindFirstChild("Elements")
        if not mapElements then return end
        pcall(AR2_scanDoors, mapElements)
        AR2_doorsConn = mapElements.DescendantAdded:Connect(function(desc)
            if not AR2_CFG.visuals.removeDoors then return end
            task.defer(function()
                pcall(function()
                    if desc and desc.Parent and AR2_isDoorInstance(desc) then
                        AR2_hideDoor(desc)
                    end
                end)
            end)
        end)
    else
        for part, saved in pairs(AR2_doorsRemoved) do
            pcall(function()
                if part and part.Parent then
                    part.Transparency = saved.transparency
                    part.CanCollide   = saved.canCollide
                    part.CanQuery     = saved.canQuery
                    part.CanTouch     = saved.canTouch
                end
            end)
        end
        AR2_doorsRemoved = {}
    end
end

AR2_sunRaysSaved = {}

function AR2_setRemoveSunRays(enabled)
    AR2_CFG.visuals.removeSunRays = enabled
    AR2_sunRaysSaved = AR2_sunRaysSaved or {}
    for _, child in ipairs(AR2_Lighting:GetChildren()) do
        if child:IsA("SunRaysEffect") then
            if AR2_sunRaysSaved[child] == nil then
                AR2_sunRaysSaved[child] = child.Enabled
            end
            child.Enabled = not enabled
        end
    end
end

AR2_ambientSaved = nil
AR2_ambientConn  = nil

function AR2_setCustomAmbient(enabled)
    AR2_CFG.visuals.customAmbient = enabled
    if AR2_ambientSaved == nil then
        AR2_ambientSaved = {
            Ambient        = AR2_Lighting.Ambient,
            OutdoorAmbient = AR2_Lighting.OutdoorAmbient,
        }
    end
    if enabled then
        AR2_Lighting.Ambient        = AR2_CFG.visuals.ambientIndoor
        AR2_Lighting.OutdoorAmbient = AR2_CFG.visuals.ambientOutdoor
        if not AR2_ambientConn then
            AR2_ambientConn = AR2_RunService.RenderStepped:Connect(function()
                if not AR2_CFG.visuals.customAmbient then return end
                AR2_Lighting.Ambient        = AR2_CFG.visuals.ambientIndoor
                AR2_Lighting.OutdoorAmbient = AR2_CFG.visuals.ambientOutdoor
            end)
        end
    else
        if AR2_ambientConn then
            AR2_ambientConn:Disconnect()
            AR2_ambientConn = nil
        end
        if AR2_ambientSaved then
            AR2_Lighting.Ambient        = AR2_ambientSaved.Ambient
            AR2_Lighting.OutdoorAmbient = AR2_ambientSaved.OutdoorAmbient
        end
    end
end


local AR2_skyboxCache = {}
function AR2_applySkybox(skyboxName)
    AR2_CFG.visuals.skybox = skyboxName
    if not AR2_skyboxCache.original then
        AR2_skyboxCache.original = {
            Ambient = AR2_Lighting.Ambient, OutdoorAmbient = AR2_Lighting.OutdoorAmbient,
            FogColor = AR2_Lighting.FogColor, FogStart = AR2_Lighting.FogStart,
            FogEnd = AR2_Lighting.FogEnd, ClockTime = AR2_Lighting.ClockTime,
        }
    end


    if AR2_customSky and AR2_customSky.Parent then
        pcall(function() AR2_customSky:Destroy() end)
    end
    for _, child in ipairs(AR2_Lighting:GetChildren()) do
        if child:IsA("Sky") and child:GetAttribute("ar2_sky") then
            pcall(function() child:Destroy() end)
        end
    end
    AR2_customSky = nil
    if skyboxName == "Default" then
        AR2_Lighting.Ambient = AR2_skyboxCache.original.Ambient
        AR2_Lighting.OutdoorAmbient = AR2_skyboxCache.original.OutdoorAmbient
        AR2_Lighting.FogColor = AR2_skyboxCache.original.FogColor
        AR2_Lighting.FogStart = AR2_skyboxCache.original.FogStart
        AR2_Lighting.FogEnd = AR2_skyboxCache.original.FogEnd
        AR2_Lighting.ClockTime = AR2_skyboxCache.original.ClockTime
    else
        local skyboxes = {
            ["Space"] = { Bk = "rbxassetid://159454299", Dn = "rbxassetid://159454299", Ft = "rbxassetid://159454299", Lf = "rbxassetid://159454299", Rt = "rbxassetid://159454299", Up = "rbxassetid://159454299" },
            ["Galaxy"] = { Bk = "http://www.roblox.com/asset/?id=149397692", Dn = "http://www.roblox.com/asset/?id=149397686", Ft = "http://www.roblox.com/asset/?id=149397697", Lf = "http://www.roblox.com/asset/?id=149397684", Rt = "http://www.roblox.com/asset/?id=149397688", Up = "http://www.roblox.com/asset/?id=149397702" },
            ["Galaxy 2"] = { Bk = "http://www.roblox.com/asset/?id=155441936", Dn = "http://www.roblox.com/asset/?id=155441802", Ft = "http://www.roblox.com/asset/?id=155441818", Lf = "http://www.roblox.com/asset/?id=155441777", Rt = "http://www.roblox.com/asset/?id=155441874", Up = "http://www.roblox.com/asset/?id=155441905" },
            ["Galaxy 3"] = { Bk = "rbxassetid://135908594667929", Dn = "rbxassetid://139584143501514", Ft = "rbxassetid://92947876187368", Lf = "rbxassetid://72493016739936", Rt = "rbxassetid://81731245279712", Up = "rbxassetid://88174897344210" },
            ["Saturne"] = { Bk = "rbxassetid://1898724755", Dn = "rbxassetid://1898727189", Ft = "rbxassetid://1898722814", Lf = "rbxassetid://1898729298", Rt = "rbxassetid://1898741025", Up = "rbxassetid://1898736761" },
            ["Neptune"] = { Bk = "rbxassetid://218955819", Dn = "rbxassetid://218953419", Ft = "rbxassetid://218954524", Lf = "rbxassetid://218958493", Rt = "rbxassetid://218957134", Up = "rbxassetid://218950090" },
            ["Redshift"] = { Bk = "rbxassetid://401664839", Dn = "rbxassetid://401664862", Ft = "rbxassetid://401664960", Lf = "rbxassetid://401664881", Rt = "rbxassetid://401664901", Up = "rbxassetid://401664936" },
            ["Pink Daylights"] = { Bk = "rbxassetid://11555017034", Dn = "rbxassetid://11555013415", Ft = "rbxassetid://11555010145", Lf = "rbxassetid://11555006545", Rt = "rbxassetid://11555000712", Up = "rbxassetid://11554996247" },
            ["Purple Night"] = { Bk = "rbxassetid://17279854976", Dn = "rbxassetid://17279856318", Ft = "rbxassetid://17279858447", Lf = "rbxassetid://17279860360", Rt = "rbxassetid://17279862234", Up = "rbxassetid://17279864507" },
            ["Gray Night"] = { Bk = "rbxassetid://1618912481", Dn = "rbxassetid://1618913943", Ft = "rbxassetid://1618913244", Lf = "rbxassetid://1618912849", Rt = "rbxassetid://1618911568", Up = "rbxassetid://1618913654" },
            ["Anime Sky"] = { Bk = "rbxassetid://18351376859", Dn = "rbxassetid://18351374919", Ft = "rbxassetid://18351376800", Lf = "rbxassetid://18351376469", Rt = "rbxassetid://18351376457", Up = "rbxassetid://18351377189" }
        }
        local data = skyboxes[skyboxName]
        if data then
            AR2_Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            AR2_Lighting.OutdoorAmbient = Color3.new(0.8, 0.8, 0.8)
            AR2_Lighting.FogColor = Color3.new(0.5, 0.5, 0.5)
            AR2_Lighting.FogStart = 0
            AR2_Lighting.FogEnd = 1000
            AR2_Lighting.ClockTime = 0
            local sky = Instance.new("Sky")
            sky.Name = skyboxName
            sky:SetAttribute("ar2_sky", true)
            sky.SkyboxBk = data.Bk
            sky.SkyboxDn = data.Dn
            sky.SkyboxFt = data.Ft
            sky.SkyboxLf = data.Lf
            sky.SkyboxRt = data.Rt
            sky.SkyboxUp = data.Up
            sky.Parent = AR2_Lighting
            AR2_customSky = sky
        end
    end
end

AR2_cloudsInstance = nil
AR2_cloudsConn     = nil
AR2_cloudsState    = {
    enabled = false,
    modify  = false,
    color   = Color3.fromRGB(255, 255, 255),
    cover   = 0.5,
    density = 0.5,
}

do
    local c = AR2_Workspace:FindFirstChildOfClass("Clouds")
    if not c and AR2_Workspace.Terrain then
        c = AR2_Workspace.Terrain:FindFirstChildOfClass("Clouds")
    end
    if not c then
        c = AR2_Lighting:FindFirstChildOfClass("Clouds")
    end
    AR2_cloudsInstance = c
    if c then
        AR2_cloudsState.color   = c.Color
        AR2_cloudsState.cover   = c.Cover
        AR2_cloudsState.density = c.Density
        AR2_cloudsState.enabled = c.Enabled
    end
end

function AR2_setClouds(enabled, modify, color, cover, density)
    AR2_CFG.visuals.cloudsEnabled = enabled
    AR2_CFG.visuals.modifyClouds  = modify
    if color   then AR2_CFG.visuals.cloudsColor   = color   end
    if cover   then AR2_CFG.visuals.cloudsCover   = cover   end
    if density then AR2_CFG.visuals.cloudsDensity = density end

    AR2_cloudsState.enabled = enabled and true or false
    AR2_cloudsState.modify  = modify  and true or false
    if color   then AR2_cloudsState.color   = color   end
    if cover   then AR2_cloudsState.cover   = cover   end
    if density then AR2_cloudsState.density = density end

    local c = AR2_cloudsInstance
    if not c or not c.Parent then
        c = AR2_Workspace:FindFirstChildOfClass("Clouds")
        if not c and AR2_Workspace.Terrain then
            c = AR2_Workspace.Terrain:FindFirstChildOfClass("Clouds")
        end
        if not c then c = AR2_Lighting:FindFirstChildOfClass("Clouds") end
        AR2_cloudsInstance = c
    end
    if not c then return end

    pcall(function() c.Enabled = AR2_cloudsState.enabled end)

    if AR2_cloudsState.modify then
        pcall(function()
            c.Color   = AR2_cloudsState.color
            c.Cover   = AR2_cloudsState.cover
            c.Density = AR2_cloudsState.density
        end)
    end

    if not AR2_cloudsConn then
        AR2_cloudsConn = AR2_RunService.RenderStepped:Connect(function()
            local ci = AR2_cloudsInstance
            if not ci or not ci.Parent then return end
            if not AR2_cloudsState.modify then return end
            pcall(function()
                ci.Color   = AR2_cloudsState.color
                ci.Cover   = AR2_cloudsState.cover
                ci.Density = AR2_cloudsState.density
            end)
        end)
    end
end

local AR2_ccInst = nil
function AR2_setColorCorrection(enabled, saturation, contrast, brightness)
    AR2_CFG.visuals.colorCorrectionEnabled = enabled
    if saturation then AR2_CFG.visuals.ccSaturation = saturation end
    if contrast then AR2_CFG.visuals.ccContrast = contrast end
    if brightness then AR2_CFG.visuals.ccBrightness = brightness end
    if not enabled then
        if AR2_ccInst then AR2_ccInst:Destroy() AR2_ccInst = nil end
        return
    end
    if not AR2_ccInst then
        AR2_ccInst = Instance.new("ColorCorrectionEffect")
        AR2_ccInst.Parent = AR2_Lighting
    end
    AR2_ccInst.Saturation = AR2_CFG.visuals.ccSaturation
    AR2_ccInst.Contrast   = AR2_CFG.visuals.ccContrast * 2
    AR2_ccInst.Brightness = AR2_CFG.visuals.ccBrightness - 1
    AR2_ccInst.Enabled = true
end


local AR2_selfBacktrackModel = nil
local AR2_selfBacktrackConn = nil
local AR2_selfBacktrackVisConn = nil
local AR2_backtrackHistory = {}
local AR2_backtrackMaxHistory = 200
local AR2_backtrackParts = {
    "Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg",
    "LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"
}

local function AR2_createFakeBacktrack(char, cf)
    local old = workspace:FindFirstChild("juju_selfBacktrack")
    if old then old:Destroy() end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local model = Instance.new("Model")
    model.Name = "juju_selfBacktrack"
    for _, name in ipairs(AR2_backtrackParts) do
        local orig = char:FindFirstChild(name)
        if orig and orig:IsA("BasePart") then
            local clone = orig:Clone()
            clone.Anchored = true
            clone.CanCollide = false
            clone.CanQuery = false
            clone.CanTouch = false
            clone.CastShadow = false
            clone.Massless = true
            clone.Transparency = AR2_CFG.misc.selfBacktrack.transparency or 0.4
            clone.Color = AR2_CFG.misc.selfBacktrack.color or Color3.fromRGB(255,255,255)
            clone.Material = AR2_CFG.misc.selfBacktrack.material or Enum.Material.ForceField
            clone.Name = name
            for _, child in ipairs(clone:GetChildren()) do
                if not child:IsA("SpecialMesh") and not child:IsA("DataModelMesh") then child:Destroy() end
            end
            local offset = root.CFrame:Inverse() * orig.CFrame
            clone.CFrame = cf * offset
            clone.Parent = model
        end
    end
    model.Parent = workspace
end

function AR2_setSelfBacktrack(enabled)
    AR2_CFG.misc.selfBacktrack.enabled = enabled
    if AR2_selfBacktrackConn then AR2_selfBacktrackConn:Disconnect() AR2_selfBacktrackConn = nil end
    if AR2_selfBacktrackVisConn then AR2_selfBacktrackVisConn:Disconnect() AR2_selfBacktrackVisConn = nil end
    if AR2_selfBacktrackModel then AR2_selfBacktrackModel:Destroy() AR2_selfBacktrackModel = nil end
    AR2_backtrackHistory = {}
    if not enabled then return end
    AR2_selfBacktrackConn = AR2_RunService.Heartbeat:Connect(function()
        local char = AR2_LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local now = tick()
        table.insert(AR2_backtrackHistory, { time = now, cframe = root.CFrame })
        while #AR2_backtrackHistory > AR2_backtrackMaxHistory do table.remove(AR2_backtrackHistory, 1) end
        local targetTime = now - AR2_CFG.misc.selfBacktrack.delay
        local best, bestDiff = nil, math.huge
        for _, rec in ipairs(AR2_backtrackHistory) do
            local diff = math.abs(rec.time - targetTime)
            if diff < bestDiff then bestDiff = diff best = rec end
        end
        if best then pcall(AR2_createFakeBacktrack, char, best.cframe) end
    end)
    AR2_selfBacktrackVisConn = AR2_RunService.RenderStepped:Connect(function()
        local model = workspace:FindFirstChild("juju_selfBacktrack")
        if not model then return end
        local camPos = AR2_Camera.CFrame.Position
        local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("LowerTorso")
        if not torso then return end
        local hide = (torso.Position - camPos).Magnitude < 5
        for _, part in ipairs(model:GetChildren()) do
            if part:IsA("BasePart") then part.LocalTransparencyModifier = hide and 1 or 0 end
        end
    end)
end

local AR2_jumpCircleConn = nil

local function AR2_createJumpCircleEffect(pos, color, startRadius, endRadius, duration, icon)
    task.spawn(function()
        local part = Instance.new("Part")
        part.Name = "juju_jumpCircle"
        part.Shape = Enum.PartType.Block
        part.Material = Enum.Material.ForceField
        part.Transparency = 1
        part.Color = color
        part.Size = Vector3.new(startRadius, 0.05, startRadius)
        part.Anchored = true
        part.CanCollide = false
        part.CastShadow = false
        local char = AR2_LocalPlayer.Character
        local rp = RaycastParams.new()
        if char then rp.FilterDescendantsInstances = {char} end
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = workspace:Raycast(pos, Vector3.new(0,-15,0), rp)
        part.Position = hit and (hit.Position + Vector3.new(0,0.1,0)) or (pos - Vector3.new(0,3,0))
        local decal = Instance.new("Decal")
        decal.Texture = icon
        decal.Face = Enum.NormalId.Top
        decal.Transparency = 0.1
        decal.Color3 = color
        decal.Parent = part
        part.Parent = workspace
        local expandTween = AR2_TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), { Size = Vector3.new(endRadius, 0.05, endRadius) })
        local fadeTween = AR2_TweenService:Create(decal, TweenInfo.new(duration * 0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Transparency = 1 })
        expandTween:Play()
        fadeTween:Play()
        expandTween.Completed:Once(function() part:Destroy() end)
    end)
end

function AR2_setJumpCircle(enabled)
    AR2_CFG.misc.jumpCircle.enabled = enabled
    if AR2_jumpCircleConn then AR2_jumpCircleConn:Disconnect() AR2_jumpCircleConn = nil end
    if not enabled then return end
    local function onChar(char)
        local hum = char:WaitForChild("Humanoid")
        hum.StateChanged:Connect(function(_, state)
            if state == Enum.HumanoidStateType.Jumping then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    AR2_createJumpCircleEffect(root.Position, AR2_CFG.misc.jumpCircle.color, AR2_CFG.misc.jumpCircle.startRadius, AR2_CFG.misc.jumpCircle.endRadius, AR2_CFG.misc.jumpCircle.duration, "rbxassetid://89391029290549")
                end
            end
        end)
    end
    AR2_jumpCircleConn = AR2_LocalPlayer.CharacterAdded:Connect(onChar)
    if AR2_LocalPlayer.Character then onChar(AR2_LocalPlayer.Character) end
end

function AR2_setRemoveShadows(enabled)
    AR2_CFG.misc.removeShadows = enabled
    AR2_Lighting.GlobalShadows = not enabled
end

local AR2_zombieCircleConn = nil
function AR2_setZombieCircle(enabled)
    AR2_CFG.misc.zombieCircle.enabled = enabled
    if AR2_zombieCircleConn then AR2_zombieCircleConn:Disconnect() AR2_zombieCircleConn = nil end
    if not enabled then return end
    AR2_zombieCircleConn = AR2_RunService.Heartbeat:Connect(function()
        local root = AR2_LocalPlayer.Character and AR2_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not AR2_Zombies then return end
        local zombies = AR2_Zombies:GetChildren()
        if #zombies == 0 then return end
        local angleStep = math.pi * 2 / #zombies
        for i, zombie in ipairs(zombies) do
            local zr = zombie:FindFirstChild("HumanoidRootPart")
            if zr then
                local angle = tick() * AR2_CFG.misc.zombieCircle.speed + i * angleStep
                local offset = Vector3.new(math.cos(angle) * AR2_CFG.misc.zombieCircle.distance, 0, math.sin(angle) * AR2_CFG.misc.zombieCircle.distance)
                zr.CFrame = CFrame.new(root.Position + offset)
                zr.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end


local AR2_alwaysSuppressedOrig = nil
local function AR2_applyAlwaysSuppressedHook()
    if AR2_alwaysSuppressedOrig then return end
    local fwOk, fw = pcall(function()
        return require(AR2_ReplicatedFirst:WaitForChild("Framework", 30))
    end)
    if not fwOk or not fw then return end
    local bullets = fw.Libraries and fw.Libraries.Bullets
    if not bullets or type(bullets.Fire) ~= "function" then return end

    AR2_alwaysSuppressedOrig = bullets.Fire

    pcall(function() if AR2_CAP.setreadonly then setreadonly(bullets, false) end end)
    pcall(function()
        rawset(bullets, "Fire", function(...)
            local args = {...}
            if AR2_CFG.weapon.alwaysSuppressed and args[4] then
                pcall(function() args[4].SuppressedByDefault = true end)
            end
            return AR2_alwaysSuppressedOrig(unpack(args))
        end)
    end)
    pcall(function() if AR2_CAP.setreadonly then setreadonly(bullets, true) end end)
end

function AR2_setAlwaysSuppressed(enabled)
    AR2_CFG.weapon.alwaysSuppressed = enabled
    pcall(AR2_applyAlwaysSuppressedHook)
end

task.spawn(function()
    AR2_ReplicatedFirst:WaitForChild("Framework", 30)
    AR2_applyAlwaysSuppressedHook()
end)


local AR2_flyActive       = false
local AR2_flyConn         = nil
local AR2_flyVel          = Vector3.zero
local AR2_flyLastPos      = nil
local AR2_flySnapSlowdown = 1.0
local AR2_flySnapCount    = 0
local AR2_flyRevalidating = false
local AR2_flyRevalUntil   = 0
local AR2_flyBurstFrame   = 0
local AR2_noFallConn      = nil

local AR2_FLY_MAX_SPEED   = 1000
local AR2_FLY_MIN_SPEED   = 10
local AR2_FLY_SNAP_LIMIT  = 5
local AR2_FLY_REVAL_PAUSE = 0.6

AR2_flySpeed = math.clamp(AR2_CFG.misc.flySpeedPct or 300, AR2_FLY_MIN_SPEED, AR2_FLY_MAX_SPEED)
AR2_CFG.misc.flySpeedPct = AR2_flySpeed

local function AR2_flyGetRoot()
    local char = AR2_LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function AR2_flyGetHum()
    local char = AR2_LocalPlayer.Character
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function AR2_flyStartNoFall()
    if AR2_noFallConn then return end
    AR2_noFallConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_flyActive then return end
        local char = AR2_LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local vy = root.AssemblyLinearVelocity.Y
        if vy >= -30 then return end
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = { char }
        local hit = AR2_Workspace:Raycast(root.Position, Vector3.new(0,-15,0), rp)
        if hit then
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X, 0,
                root.AssemblyLinearVelocity.Z)
        else
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X,
                math.max(vy * 0.88, -25),
                root.AssemblyLinearVelocity.Z)
        end
    end)
end

function AR2_stopFly()
    AR2_flyActive       = false
    AR2_flyLastPos      = nil
    AR2_flyVel          = Vector3.zero
    AR2_flySnapCount    = 0
    AR2_flyRevalidating = false
    AR2_flyBurstFrame   = 0
    if AR2_flyConn then AR2_flyConn:Disconnect() AR2_flyConn = nil end

    local root = AR2_flyGetRoot()
    if root then
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = { AR2_LocalPlayer.Character }
        local hit = AR2_Workspace:Raycast(root.Position, Vector3.new(0,-2000,0), rp)
        if hit then
            root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3.5, 0))
                * (root.CFrame - root.CFrame.Position)
        end
        root.AssemblyLinearVelocity  = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    task.delay(0.2, function()
        local h = AR2_flyGetHum()
        if h then
            pcall(function()
                h:SetStateEnabled(Enum.HumanoidStateType.Landed,     true)
                h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                h:SetStateEnabled(Enum.HumanoidStateType.GettingUp,   true)
            end)
        end
    end)
end

function AR2_startFly()
    if AR2_flyActive then return end
    if AR2_flyConn then
        AR2_flyConn:Disconnect()
        AR2_flyConn = nil
    end

    local root = AR2_flyGetRoot()
    local hum  = AR2_flyGetHum()
    if not root or not hum then return end

    AR2_flySpeed = math.clamp(AR2_CFG.misc.flySpeedPct or AR2_flySpeed or 300, AR2_FLY_MIN_SPEED, AR2_FLY_MAX_SPEED)
    AR2_CFG.misc.flySpeedPct = AR2_flySpeed

    root.CFrame = root.CFrame + Vector3.new(0, 3, 0)
    root.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
    task.wait(0.1)

    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed,      false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,   true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)

    AR2_flyLastPos      = root.Position
    AR2_flyVel          = Vector3.zero
    AR2_flySnapSlowdown = 1.0
    AR2_flySnapCount    = 0
    AR2_flyRevalidating = false
    AR2_flyBurstFrame   = 0
    AR2_flyActive       = true

    AR2_flyConn = AR2_RunService.Heartbeat:Connect(function(dt)
        if not AR2_CFG.misc.fly then AR2_stopFly() return end
        local r = AR2_flyGetRoot()
        local h = AR2_flyGetHum()
        if not r then AR2_stopFly() return end

        pcall(function()
            h:SetStateEnabled(Enum.HumanoidStateType.Landed,     false)
            h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            local state = h:GetState()
            if state == Enum.HumanoidStateType.Landed
            or state == Enum.HumanoidStateType.FallingDown then
                h:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)

        if AR2_flyRevalidating then
            if os.clock() < AR2_flyRevalUntil then
                r.AssemblyLinearVelocity = Vector3.new(
                    (math.random() - 0.5) * 2, -2, (math.random() - 0.5) * 2)
                AR2_flyLastPos = r.Position
                return
            else
                AR2_flyRevalidating = false
                AR2_flySnapSlowdown = 0.4
                AR2_flyVel          = Vector3.zero
            end
        end

        if AR2_flyLastPos then
            local actualSpeed   = (r.Position - AR2_flyLastPos).Magnitude / math.max(dt, 0.001)
            local expectedSpeed = AR2_flyVel.Magnitude
            if expectedSpeed > 15 and actualSpeed < expectedSpeed * 0.25 then
                AR2_flySnapSlowdown = math.max(0.15, AR2_flySnapSlowdown - 0.2)
                AR2_flySnapCount    = AR2_flySnapCount + 1
                if AR2_flySnapCount >= AR2_FLY_SNAP_LIMIT then
                    AR2_flyRevalidating = true
                    AR2_flyRevalUntil   = os.clock() + AR2_FLY_REVAL_PAUSE
                    AR2_flySnapCount    = 0
                    AR2_flyVel          = Vector3.zero
                    AR2_flyLastPos      = r.Position
                    return
                end
            else
                AR2_flySnapSlowdown = math.min(1.0, AR2_flySnapSlowdown + 0.025)
                if AR2_flySnapCount > 0 then AR2_flySnapCount = AR2_flySnapCount - 1 end
            end
        end
        AR2_flyLastPos = r.Position

        local cam    = workspace.CurrentCamera
        local target = Vector3.zero
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.W) then target = target + cam.CFrame.LookVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.S) then target = target - cam.CFrame.LookVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.D) then target = target + cam.CFrame.RightVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.A) then target = target - cam.CFrame.RightVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.Space) then target = target + Vector3.new(0, 1, 0) end
        local descendDown = AR2_UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.Q)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        if descendDown then target = target - Vector3.new(0, 1, 0) end

        local effectiveSpeed = AR2_flySpeed * AR2_flySnapSlowdown
        local targetVel = target.Magnitude > 0.01 and target.Unit * effectiveSpeed or Vector3.zero

        local lerpRate = math.min(1, dt * (10 + math.random() * 4))
        AR2_flyVel = AR2_flyVel:Lerp(targetVel, lerpRate)

        local hSpeed   = Vector3.new(AR2_flyVel.X, 0, AR2_flyVel.Z).Magnitude
        local gravBias = hSpeed > 30 and Vector3.new(0, -hSpeed * 0.04, 0) or Vector3.zero

        local noise = Vector3.zero
        if math.random(3) == 1 then
            noise = Vector3.new(
                (math.random() - 0.5) * 0.5,
                (math.random() - 0.5) * 0.5,
                (math.random() - 0.5) * 0.5)
        end

        AR2_flyBurstFrame = (AR2_flyBurstFrame + 1) % 5
        if AR2_flyBurstFrame == 0
        and not AR2_UserInputService:IsKeyDown(Enum.KeyCode.Space)
        and AR2_flyVel.Magnitude > 10 then
            r.AssemblyLinearVelocity = AR2_flyVel * 0.6 + gravBias
        else
            r.AssemblyLinearVelocity = AR2_flyVel + gravBias + noise
        end
    end)
end

function AR2_setFly(enabled)
    AR2_CFG.misc.fly = enabled
    if enabled then
        pcall(function() if AR2_3pAds and AR2_3pAds.stop then AR2_3pAds.stop() end end)
        if not AR2_flyActive then AR2_startFly() end
    else
        AR2_stopFly()
    end
end

function AR2_resetFallState()
    AR2_CFG.misc.fly = false
    AR2_flyActive       = false
    AR2_flyRevalidating = false
    AR2_flySnapCount    = 0
    AR2_flyVel          = Vector3.zero
    AR2_flyLastPos      = nil
    AR2_flyBurstFrame   = 0
    if AR2_flyConn then AR2_flyConn:Disconnect() AR2_flyConn = nil end

    local char = AR2_LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")

    if not root then return end

    root.AssemblyLinearVelocity  = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    if hum then
        pcall(function()
            for _, state in ipairs({
                Enum.HumanoidStateType.Landed,
                Enum.HumanoidStateType.FallingDown,
                Enum.HumanoidStateType.GettingUp,
                Enum.HumanoidStateType.Running,
                Enum.HumanoidStateType.RunningNoPhysics,
                Enum.HumanoidStateType.Jumping,
                Enum.HumanoidStateType.Physics,
            }) do
                hum:SetStateEnabled(state, true)
            end
        end)
        hum.Sit           = false
        hum.PlatformStand = false
        hum.AutoRotate    = true
    end

    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { char }
    local hit = AR2_Workspace:Raycast(root.Position, Vector3.new(0, -2000, 0), rp)
    if hit then
        root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3.5, 0))
            * (root.CFrame - root.CFrame.Position)
    end

    task.delay(0.1, function()
        local h = AR2_flyGetHum()
        if h then
            pcall(function() h:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end)

    local cam = workspace.CurrentCamera
    if cam and hum then
        pcall(function()
            cam.CameraSubject = hum
            cam.CameraType    = Enum.CameraType.Custom
        end)
    end
end

AR2_flyStartNoFall()

AR2_LocalPlayer.CharacterAdded:Connect(function(char)
    if AR2_flyConn then AR2_flyConn:Disconnect() AR2_flyConn = nil end
    AR2_flyActive       = false
    AR2_flyVel          = Vector3.zero
    AR2_flyLastPos      = nil
    AR2_flySnapCount    = 0
    AR2_flyRevalidating = false
    AR2_flyBurstFrame   = 0
    AR2_CFG.misc.fly    = false

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.AutoRotate    = true
            hum.Sit           = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed,     true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,   true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,    true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running,     true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,     true)
        end)
    end

    task.wait(1.0)
    local hum2 = char:FindFirstChildWhichIsA("Humanoid")
    if hum2 then
        pcall(function()
            hum2.PlatformStand = false
            hum2.AutoRotate    = true
            hum2:SetStateEnabled(Enum.HumanoidStateType.Landed,     true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.GettingUp,   true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Freefall,    true)
        end)
    end
    if type(AR2_refreshUI) == "function" then pcall(AR2_refreshUI) end
end)

local function _flyKillState()
    if AR2_flyConn then AR2_flyConn:Disconnect() AR2_flyConn = nil end
    AR2_flyActive       = false
    AR2_flyVel          = Vector3.zero
    AR2_flyLastPos      = nil
    AR2_flyRevalidating = false
    AR2_CFG.misc.fly    = false
end
if AR2_LocalPlayer.Character then
    local h = AR2_LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if h then h.Died:Connect(_flyKillState) end
end
AR2_LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    local h = c:FindFirstChildWhichIsA("Humanoid")
    if h then h.Died:Connect(_flyKillState) end
end)

AR2_UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not AR2_flyActive then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.Equals or k == Enum.KeyCode.KeypadPlus then
        AR2_flySpeed = math.min(AR2_flySpeed + 20, AR2_FLY_MAX_SPEED)
        AR2_CFG.misc.flySpeedPct = AR2_flySpeed
    elseif k == Enum.KeyCode.Minus or k == Enum.KeyCode.KeypadMinus then
        AR2_flySpeed = math.max(AR2_flySpeed - 20, AR2_FLY_MIN_SPEED)
        AR2_CFG.misc.flySpeedPct = AR2_flySpeed
    end
end)

AR2_UserInputService.InputChanged:Connect(function(input)
    if not AR2_flyActive then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        AR2_flySpeed = math.clamp(AR2_flySpeed + input.Position.Z * 20, AR2_FLY_MIN_SPEED, AR2_FLY_MAX_SPEED)
        AR2_CFG.misc.flySpeedPct = AR2_flySpeed
    end
end)


AR2_flyHudGui     = nil
AR2_flyHudConn    = nil
AR2_flyHudLabel   = nil
AR2_flyHudSub     = nil
AR2_flyHudBarFill = nil

local function AR2_buildFlyHud()
    if AR2_flyHudGui and AR2_flyHudGui.Parent then return end
    local host = (typeof(AR2_gethui) == "function" and AR2_gethui()) or game:GetService("CoreGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "juju_flyHud"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999997
    gui.Parent = host
    AR2_flyHudGui = gui

    local frame = Instance.new("Frame")
    frame.Name = "Container"
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 12)
    frame.Size = UDim2.fromOffset(360, 62)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(10, 6)
    title.Size = UDim2.new(1, -20, 0, 18)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(80, 255, 140)
    title.Text = "Fly [F]: ON"
    title.Parent = frame
    AR2_flyHudLabel = title

    local sub = Instance.new("TextLabel")
    sub.Name = "Sub"
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(10, 24)
    sub.Size = UDim2.new(1, -20, 0, 16)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextColor3 = Color3.fromRGB(200, 200, 210)
    sub.Text = "..."
    sub.Parent = frame
    AR2_flyHudSub = sub

    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.Position = UDim2.fromOffset(10, 46)
    barBg.Size = UDim2.new(1, -20, 0, 8)
    barBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    barBg.BorderSizePixel = 0
    barBg.Parent = frame
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Position = UDim2.fromOffset(0, 0)
    barFill.Size = UDim2.fromScale(0, 1)
    barFill.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    AR2_flyHudBarFill = barFill
end

local function AR2_updateFlyHud()
    if not AR2_flyHudGui then return end
    local frame = AR2_flyHudGui:FindFirstChild("Container")
    if not frame then return end
    if not AR2_CFG.misc.fly or not AR2_flyActive then frame.Visible = false return end
    frame.Visible = true
    local color, status
    if AR2_flyRevalidating then
        color = Color3.fromRGB(255, 80, 80)
        status = "REVALIDATING..."
    elseif AR2_flySnapSlowdown < 0.95 then
        color = Color3.fromRGB(255, 220, 60)
        status = string.format("throttle:%.0f%%", AR2_flySnapSlowdown * 100)
    else
        color = Color3.fromRGB(80, 255, 140)
        status = "clean"
    end
    AR2_flyHudLabel.TextColor3 = color
    AR2_flyHudLabel.Text = string.format("Fly [F]: ON  ·  %s  ·  speed %d", status, AR2_flySpeed)
    AR2_flyHudSub.Text = string.format("snaps:%d  ·  hover  ·  no-fall:ON  ·  scroll / +/- = speed", AR2_flySnapCount)
    AR2_flyHudSub.TextColor3 = color
    AR2_flyHudBarFill.BackgroundColor3 = color
    AR2_flyHudBarFill.Size = UDim2.fromScale(math.clamp(AR2_flySpeed / AR2_FLY_MAX_SPEED, 0, 1), 1)
end

local function AR2_flyHudStart()
    if AR2_flyHudConn then return end
    AR2_buildFlyHud()
    AR2_flyHudConn = AR2_RunService.RenderStepped:Connect(function()
        pcall(AR2_updateFlyHud)
    end)
end

local function AR2_flyHudStop()
    if AR2_flyHudConn then AR2_flyHudConn:Disconnect() AR2_flyHudConn = nil end
    if AR2_flyHudGui then
        local frame = AR2_flyHudGui:FindFirstChild("Container")
        if frame then frame.Visible = false end
    end
end

AR2_flyHudStart()


AR2_CFG.car.fly      = AR2_CFG.car.fly or false
AR2_CFG.car.flySpeed = AR2_CFG.car.flySpeed or 100

AR2_carFlyActive        = false
AR2_carFlyConn          = nil
AR2_carFlyVel           = Vector3.zero
AR2_carFlyModel         = nil
AR2_carFlyRoot          = nil
AR2_carFlySavedParts    = nil
AR2_carFlyInitialHealth = nil
AR2_carFlyHealthWatch   = 0


AR2_carFlyBV            = nil
AR2_carFlyBG            = nil

local AR2_CAR_FLY_MIN_SPEED = 10
local AR2_CAR_FLY_MAX_SPEED = 200

local function AR2_carFlyGetModel()
    local char = AR2_LocalPlayer.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.SeatPart then
        local node = hum.SeatPart
        while node and node.Parent do
            if node.Parent == AR2_Vehicles then return node end
            node = node.Parent
        end
    end
    if AR2_carPick then
        local ok, m = pcall(AR2_carPick)
        if ok then return m end
    end
    return nil
end

function AR2_carFlyStop()
    AR2_carFlyActive        = false
    AR2_CFG.car.fly         = false
    AR2_carFlyInitialHealth = nil
    if AR2_carFlyConn then AR2_carFlyConn:Disconnect() AR2_carFlyConn = nil end
    AR2_carFlyVel = Vector3.zero


    pcall(function() if AR2_carFlyBV and AR2_carFlyBV.Parent then AR2_carFlyBV:Destroy() end end)
    pcall(function() if AR2_carFlyBG and AR2_carFlyBG.Parent then AR2_carFlyBG:Destroy() end end)
    AR2_carFlyBV, AR2_carFlyBG = nil, nil

    if AR2_carFlySavedParts then
        for part, wasCollide in pairs(AR2_carFlySavedParts) do
            pcall(function()
                if part and part.Parent then
                    part.CanCollide = wasCollide
                    part.AssemblyLinearVelocity  = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        end
    end
    AR2_carFlyModel      = nil
    AR2_carFlyRoot       = nil
    AR2_carFlySavedParts = nil
end

local function AR2_carFlyDamageEject()
    local model = AR2_carFlyModel
    AR2_carFlyStop()
    AR2_ejectFromVehicle()
    AR2_stopVehicleVelocity(model)
    pcall(function()
        local NL = getgenv and getgenv().OriginHUB_NL
        if NL then
            local Notif = NL:CreateNotification()
            Notif.new({Title="juju",Content="Car took damage — auto-ejected",Duration=3})
        end
    end)
end

function AR2_carFlyStart()
    if AR2_carFlyActive then return true end
    local model = AR2_carFlyGetModel()
    if not model then return false end
    local char = AR2_LocalPlayer.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if not hum or not hum.Sit then return false end

    local root = model.PrimaryPart or model:FindFirstChild("Base")
    if not root then
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then root = p break end
        end
    end
    if not root then return false end

    AR2_carFlyInitialHealth = AR2_carHealth(model)
    AR2_carFlyHealthWatch   = 0


    local savedParts = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            savedParts[p] = p.CanCollide
            p.CanCollide  = false
        end
    end

    AR2_carFlyModel      = model
    AR2_carFlyRoot       = root
    AR2_carFlySavedParts = savedParts
    AR2_carFlyVel        = Vector3.zero
    AR2_carFlyActive     = true
    AR2_CFG.car.fly      = true


    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.Name      = "AR2_carFlyBV"
        bv.MaxForce  = Vector3.new(1, 1, 1) * 1e6
        bv.P         = 1250
        bv.Velocity  = Vector3.zero
        bv.Parent    = root
        AR2_carFlyBV = bv

        local bg = Instance.new("BodyGyro")
        bg.Name       = "AR2_carFlyBG"
        bg.MaxTorque  = Vector3.new(1, 1, 1) * 1e6
        bg.P          = 3000
        bg.D          = 500
        bg.CFrame     = root.CFrame
        bg.Parent     = root
        AR2_carFlyBG  = bg
    end)
    if not AR2_carFlyBV then


        AR2_carFlyStop()
        return false
    end

    AR2_carFlyConn = AR2_RunService.Heartbeat:Connect(function(dt)
        if not AR2_CFG.car.fly then AR2_carFlyStop() return end
        local m = AR2_carFlyModel
        if not m or not m.Parent then AR2_carFlyStop() return end
        local r = AR2_carFlyRoot
        if not r or not r.Parent then AR2_carFlyStop() return end

        local c = AR2_LocalPlayer.Character
        local h = c and c:FindFirstChildWhichIsA("Humanoid")
        if not h or not h.Sit then AR2_carFlyStop() return end

        AR2_carFlyHealthWatch = AR2_carFlyHealthWatch + dt
        if AR2_carFlyHealthWatch >= 0.1 then
            AR2_carFlyHealthWatch = 0
            local hp = AR2_carHealth(m)
            if hp then
                if not AR2_carFlyInitialHealth then
                    AR2_carFlyInitialHealth = hp
                elseif hp < AR2_carFlyInitialHealth then
                    AR2_carFlyDamageEject()
                    return
                end
            end
        end

        local cam    = workspace.CurrentCamera
        local target = Vector3.zero
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.W) then target = target + cam.CFrame.LookVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.S) then target = target - cam.CFrame.LookVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.D) then target = target + cam.CFrame.RightVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.A) then target = target - cam.CFrame.RightVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.Space) then target = target + Vector3.new(0, 1, 0) end
        local descend = AR2_UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.Q)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        if descend then target = target - Vector3.new(0, 1, 0) end


        AR2_CFG.car.flySpeed = math.clamp(AR2_CFG.car.flySpeed or 100, AR2_CAR_FLY_MIN_SPEED, AR2_CAR_FLY_MAX_SPEED)
        local speed = AR2_CFG.car.flySpeed
        local targetVel = target.Magnitude > 0.01 and target.Unit * speed or Vector3.zero

        AR2_carFlyVel = AR2_carFlyVel:Lerp(targetVel, math.min(1, dt * 6))

        local flatFwd
        if target.Magnitude > 0.01 then
            flatFwd = Vector3.new(targetVel.X, 0, targetVel.Z)
        else
            flatFwd = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
        end


        local bv, bg = AR2_carFlyBV, AR2_carFlyBG
        if not (bv and bv.Parent and bg and bg.Parent) then AR2_carFlyStop() return end
        bv.Velocity = AR2_carFlyVel
        if flatFwd.Magnitude > 0.01 then
            bg.CFrame = CFrame.lookAt(r.Position, r.Position + flatFwd.Unit)
        end


        pcall(function()
            if h.SeatPart and h.SeatPart:IsA("VehicleSeat") then
                h.SeatPart.ThrottleFloat = 0
                h.SeatPart.SteerFloat    = 0
            end
        end)
    end)

    return true
end

function AR2_carFlySetEnabled(on)
    if on then
        pcall(function() if AR2_3pAds and AR2_3pAds.stop then AR2_3pAds.stop() end end)
        local ok = AR2_carFlyStart()
        if not ok then AR2_CFG.car.fly = false end
        return ok
    else
        AR2_carFlyStop()
        return true
    end
end


function AR2_rageBotPanic()
    pcall(AR2_rageBotSetEnabled, false)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(0,0,0,false,game,1)
        VIM:SendMouseButtonEvent(0,0,1,false,game,1)
    end)
    AR2_rbHeld, AR2_adsHeld = false, false
    AR2_lastFireParams = nil
    AR2_hasRealWD = false
    AR2_autoSeeding, AR2_autoSeeded = false, false
end


local TAN = Color3.fromRGB(210, 163, 100)
local BODY_PARTS = {
    "Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg",
    "LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"
}
local originalParts = {}
local tungGlobalConns = {}
local tungEnabled = false
local tungGlobal = false

local function clearTung(char)
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if typeof(d) == "Instance" and d.Name:sub(1,4) == "Tung" then
            pcall(function() d:Destroy() end)
        end
    end
end
local function weld(p0,p1)
    local w = Instance.new("WeldConstraint") w.Part0 = p0 w.Part1 = p1 w.Parent = p1
end
local function makePart(props)
    local p = Instance.new("Part")
    p.Name = props.name or "TungPart"
    p.Size = props.size or Vector3.new(1,1,1)
    p.Color = props.color or TAN
    p.Material = props.material or Enum.Material.SmoothPlastic
    p.Transparency = props.transparency or 0
    p.Anchored = false
    p.CanCollide = false
    p.Massless = true
    p.CastShadow = false
    if props.shape then p.Shape = props.shape end
    p.Parent = props.parent
    p.CFrame = props.cframe or CFrame.new()
    return p
end
local function applyTungTung(char)
    if not char then return end
    clearTung(char)
    for _, name in ipairs(BODY_PARTS) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if char == AR2_LocalPlayer.Character and not originalParts[part] then
                originalParts[part] = { Color = part.Color, Material = part.Material, Transparency = part.Transparency }
            end
            part.Material = Enum.Material.ForceField
            part.Color = TAN
            part.Transparency = 0.5
        end
    end
    local head = char:FindFirstChild("Head")
    local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("RightLowerArm")
    if head then
        local function makeEye(name, xOffset)
            local eye = makePart({ name=name, shape=Enum.PartType.Ball, size=Vector3.new(0.30,0.30,0.30), color=Color3.fromRGB(255,255,255), material=Enum.Material.SmoothPlastic, transparency=0, parent=char, cframe=head.CFrame*CFrame.new(xOffset,0.22,-0.53) })
            local pupil = makePart({ name=name.."Pupil", shape=Enum.PartType.Ball, size=Vector3.new(0.13,0.13,0.13), color=Color3.fromRGB(0,0,0), material=Enum.Material.SmoothPlastic, transparency=0, parent=char, cframe=eye.CFrame*CFrame.new(0,0,-0.12) })
            weld(head,eye) weld(eye,pupil)
        end
        makeEye("TungLeftEye",-0.22) makeEye("TungRightEye",0.22)
    end
    if rightHand then
        local handleLen, handleW, barrelLen, barrelW, tapeH = 2.2,0.18,1.0,0.55,0.30
        local handle = makePart({ name="TungBatHandle", size=Vector3.new(handleW,handleLen,handleW), color=Color3.fromRGB(88,52,12), material=Enum.Material.Wood, parent=char, cframe=rightHand.CFrame*CFrame.new(0,-(handleLen/2),0) })
        local barrel = makePart({ name="TungBatBarrel", size=Vector3.new(barrelW,barrelLen,barrelW), color=Color3.fromRGB(88,52,12), material=Enum.Material.Wood, parent=char, cframe=handle.CFrame*CFrame.new(0,-(handleLen/2+barrelLen/2),0) })
        local tape = makePart({ name="TungBatTape", size=Vector3.new(handleW+0.06,tapeH,handleW+0.06), color=Color3.fromRGB(20,20,20), material=Enum.Material.SmoothPlastic, parent=char, cframe=handle.CFrame*CFrame.new(0,handleLen/2-tapeH/2-0.1,0) })
        weld(rightHand,handle) weld(handle,barrel) weld(handle,tape)
    end
end
local function removeTungTung(char)
    clearTung(char)
    if not char then return end
    for part, orig in pairs(originalParts) do
        if part and part.Parent then
            part.Color = orig.Color
            part.Material = orig.Material
            part.Transparency = orig.Transparency
        end
    end
    table.clear(originalParts)
end
local function applyTungToAll(on)
    for _, conn in pairs(tungGlobalConns) do pcall(function() conn:Disconnect() end) end
    tungGlobalConns = {}
    if not on then
        for _, p in ipairs(AR2_Players:GetPlayers()) do
            if p~=AR2_LocalPlayer and p.Character then clearTung(p.Character) end
        end
        return
    end
    for _, p in ipairs(AR2_Players:GetPlayers()) do
        if p~=AR2_LocalPlayer and p.Character then applyTungTung(p.Character) end
    end
    for _, p in ipairs(AR2_Players:GetPlayers()) do
        if p~=AR2_LocalPlayer then
            tungGlobalConns[p] = p.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if tungGlobal then applyTungTung(char) end
            end)
        end
    end
    tungGlobalConns["PlayerAdded"] = AR2_Players.PlayerAdded:Connect(function(p)
        tungGlobalConns[p] = p.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if tungGlobal then applyTungTung(char) end
        end)
    end)
end
function toggleTungSelf(enabled)
    tungEnabled = enabled
    if enabled then applyTungTung(AR2_LocalPlayer.Character) else removeTungTung(AR2_LocalPlayer.Character) end
end
function toggleTungGlobal(enabled)
    tungGlobal = enabled
    applyTungToAll(enabled)
end
AR2_LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if tungEnabled then applyTungTung(char) end
end)


local AR2_fovZoomConn = nil
local AR2_fovZoomOriginal = nil
AR2_zoomFOV = AR2_CFG.misc.zoomFOV

function AR2_toggleFOVZoom(enabled)
    AR2_CFG.misc.fovZoom = enabled
    if AR2_fovZoomConn then AR2_fovZoomConn:Disconnect() AR2_fovZoomConn = nil end
    if AR2_fovZoomOriginal then
        AR2_Camera.FieldOfView = AR2_fovZoomOriginal
        AR2_fovZoomOriginal = nil
    end
    if not enabled then return end
    AR2_fovZoomConn = AR2_RunService.RenderStepped:Connect(function()
        local holding = AR2_UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        local cam = AR2_Camera
        if holding then
            AR2_fovZoomOriginal = AR2_fovZoomOriginal or cam.FieldOfView
            cam.FieldOfView = AR2_zoomFOV
        elseif AR2_fovZoomOriginal then
            cam.FieldOfView = AR2_fovZoomOriginal
            AR2_fovZoomOriginal = nil
        end
    end)
end

local AR2_distZoomConn = nil
local AR2_distZoomActive = AR2_CFG.misc.distZoomActive or false
local AR2_normalDist = AR2_CFG.misc.normalDist
local AR2_zoomedDist = AR2_CFG.misc.zoomedDist
local targetDist = AR2_normalDist

function AR2_toggleDistZoomEnabled(enabled)
    AR2_CFG.misc.distZoomEnabled = enabled
    if AR2_distZoomConn then AR2_distZoomConn:Disconnect() AR2_distZoomConn = nil end
    if not enabled then
        pcall(function()
            local humanoid = AR2_LocalPlayer.Character and AR2_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            workspace.CurrentCamera.CameraSubject = humanoid
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end)
        return
    end
    AR2_distZoomConn = AR2_RunService.RenderStepped:Connect(function()
        local char = AR2_LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not (root and cam) then return end
        local dist = targetDist
        local look = cam.CFrame.LookVector
        local desiredPos = root.Position + Vector3.new(0, 2, 0) - look * dist
        cam.CFrame = CFrame.new(desiredPos, root.Position + Vector3.new(0, 2, 0))
    end)
end

function AR2_toggleDistanceZoom(active)
    AR2_CFG.misc.distZoomActive = active
    AR2_distZoomActive = active
    targetDist = active and AR2_zoomedDist or AR2_normalDist
    if active and not AR2_CFG.misc.distZoomEnabled then AR2_toggleDistZoomEnabled(true) end
end

function AR2_setNormalDistance(value)
    AR2_normalDist = value
    AR2_CFG.misc.normalDist = value
    if not AR2_distZoomActive then targetDist = value end
end

function AR2_setZoomedDistance(value)
    AR2_zoomedDist = value
    AR2_CFG.misc.zoomedDist = value
    if AR2_distZoomActive then targetDist = value end
end

AR2_3pAds = {
    active     = false,
    normalFOV  = 70,
    currentPos = nil,
    fovConn    = nil,
    geoParams  = RaycastParams.new(),
}
AR2_3pAds.geoParams.FilterType = Enum.RaycastFilterType.Exclude

function AR2_3pAds.safePos(charPos, targetPos, char)
    pcall(function()
        AR2_3pAds.geoParams.FilterDescendantsInstances = { char, AR2_Camera }
    end)
    local dir  = targetPos - charPos
    local dist = dir.Magnitude
    if dist < 0.1 then return targetPos end
    local hit = AR2_Workspace:Raycast(charPos, dir.Unit * (dist + 0.5), AR2_3pAds.geoParams)
    if hit then
        return charPos + dir.Unit * math.max(0.5, hit.Distance - 0.5)
    end
    return targetPos
end

function AR2_3pAds.start()
    local c = AR2_CFG.misc.thirdPersonADS
    if not c.enabled or AR2_3pAds.active then return end

    if AR2_CFG.misc.fly or AR2_flyActive or AR2_CFG.car.fly or AR2_carFlyActive then return end
    local char = AR2_LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    AR2_3pAds.active     = true
    AR2_3pAds.normalFOV  = AR2_Camera.FieldOfView
    AR2_3pAds.currentPos = AR2_Camera.CFrame.Position

    AR2_RunService:BindToRenderStep(
        "AR2_3PADS",
        Enum.RenderPriority.Camera.Value + 1,
        function()
            if not AR2_3pAds.active then return end
            local ch = AR2_LocalPlayer.Character
            local r  = ch and ch:FindFirstChild("HumanoidRootPart")
            if not r then return end

            local ar2Look = AR2_Camera.CFrame.LookVector

            pcall(function()
                local anim = ch:FindFirstChild("Animator")
                if anim then
                    local fp = anim:FindFirstChild("FirstPerson")
                    if fp and fp.Value then fp.Value = false end
                end
            end)

            AR2_Camera.FieldOfView = AR2_Camera.FieldOfView
                + (c.adsFOV - AR2_Camera.FieldOfView) * 0.15

            local flatLook = Vector3.new(ar2Look.X, 0, ar2Look.Z)
            if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(0, 0, -1) end
            flatLook = flatLook.Unit

            local right   = flatLook:Cross(Vector3.new(0, 1, 0)).Unit
            local charPos = r.Position + Vector3.new(0, 1, 0)

            local rawTarget = charPos
                + right * c.offsetRight
                + Vector3.new(0, c.offsetUp, 0)
                - flatLook * c.offsetBack

            local safeTarget = AR2_3pAds.safePos(charPos, rawTarget, ch)

            if not AR2_3pAds.currentPos then AR2_3pAds.currentPos = safeTarget end
            AR2_3pAds.currentPos = AR2_3pAds.currentPos:Lerp(safeTarget, c.smooth)

            local aimPoint = charPos + ar2Look * 500
            AR2_Camera.CFrame = CFrame.new(AR2_3pAds.currentPos, aimPoint)
        end
    )
end

function AR2_3pAds.stop()
    if not AR2_3pAds.active then return end
    AR2_3pAds.active     = false
    AR2_3pAds.currentPos = nil
    AR2_RunService:UnbindFromRenderStep("AR2_3PADS")

    local target = AR2_3pAds.normalFOV
    if AR2_3pAds.fovConn then AR2_3pAds.fovConn:Disconnect() end
    AR2_3pAds.fovConn = AR2_RunService.RenderStepped:Connect(function()
        local diff = target - AR2_Camera.FieldOfView
        if math.abs(diff) < 0.3 then
            AR2_Camera.FieldOfView = target
            AR2_3pAds.fovConn:Disconnect()
            AR2_3pAds.fovConn = nil
        else
            AR2_Camera.FieldOfView = AR2_Camera.FieldOfView + diff * 0.2
        end
    end)
end

function AR2_set3pAds(enabled)
    AR2_CFG.misc.thirdPersonADS.enabled = enabled
    if not enabled and AR2_3pAds.active then AR2_3pAds.stop() end
end

AR2_UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if AR2_CFG.misc.thirdPersonADS.enabled then AR2_3pAds.start() end
    end
end)

AR2_UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if AR2_3pAds.active then AR2_3pAds.stop() end
    end
end)

AR2_LocalPlayer.CharacterAdded:Connect(function()
    if AR2_3pAds.active then AR2_3pAds.stop() end
end)


local AR2_autoReloadEnabled = false
local AR2_autoReloadConn = nil
local AR2_autoReloadLast = 0

function AR2_setAutoReload(enabled)
    AR2_autoReloadEnabled = enabled
    AR2_CFG.weapon.autoReload = enabled
    if AR2_autoReloadConn then AR2_autoReloadConn:Disconnect() AR2_autoReloadConn = nil end
    if not enabled then return end
    AR2_autoReloadConn = AR2_RunService.Heartbeat:Connect(function()
        if not AR2_autoReloadEnabled then return end
        local now = os.clock()
        if now - AR2_autoReloadLast < 1 then return end
        AR2_autoReloadLast = now
        pcall(function()
            local inner = AR2_getEquippedInner()
            if inner and inner.Attachments and inner.Attachments.Ammo then
                local ammo = inner.Attachments.Ammo.__item.WorkingAmount
                if ammo == 0 then
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                end
            end
        end)
    end)
end


AR2_morph = AR2_morph or { model = nil }

local function AR2_morphToast(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",
            { Title = "juju", Text = tostring(text), Duration = 4 })
    end)
end

function AR2_removeMorph()
    if AR2_morph.model then
        pcall(function() AR2_morph.model:Destroy() end)
        AR2_morph.model = nil
    end

    pcall(AR2_refreshHideState)
end

function AR2_applyMorph()
    AR2_removeMorph()

    local id = tostring(AR2_CFG.misc.morphId or ""):gsub("%D", "")
    if id == "" then AR2_morphToast("Enter a model ID first") return false end

    local char = AR2_LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AR2_morphToast("No character") return false end


    local anchor = char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("Torso")
                or char:FindFirstChild("LowerTorso")
                or hrp

    local objs
    local ok = pcall(function() objs = game:GetObjects("rbxassetid://" .. id) end)
    if not ok or type(objs) ~= "table" or #objs == 0 then
        objs = nil
        pcall(function()
            local m = game:GetService("InsertService"):LoadAsset(tonumber(id))
            if m then objs = m:GetChildren() end
        end)
    end
    if type(objs) ~= "table" or #objs == 0 then
        AR2_morphToast("Couldn't load model " .. id .. " (private or invalid?)")
        return false
    end

    local model = objs[1]
    for _, o in ipairs(objs) do if o:IsA("Model") then model = o break end end
    model.Name = "oh_morph"
    model.Parent = workspace
    pcall(function()
        if model:IsA("Model") then model:PivotTo(hrp.CFrame)
        elseif model:IsA("BasePart") then model.CFrame = hrp.CFrame end
    end)


    pcall(function()
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Humanoid")
            or d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D")
            or d:IsA("Snap") or d:IsA("ManualWeld") then d:Destroy() end
        end
    end)

    local parts = {}
    if model:IsA("Model") then
        for _, d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then parts[#parts+1] = d end end
    elseif model:IsA("BasePart") then parts[1] = model end
    if #parts == 0 then
        pcall(function() model:Destroy() end)
        AR2_morphToast("That asset has no parts to weld")
        return false
    end

    for _, p in ipairs(parts) do
        pcall(function()
            p.Anchored = false p.CanCollide = false p.Massless = true
            local w = Instance.new("Weld")
            w.Part0 = anchor w.Part1 = p
            w.C0 = anchor.CFrame:ToObjectSpace(p.CFrame)
            w.Parent = p
        end)
    end

    AR2_morph.model = model

    pcall(AR2_refreshHideState)
    AR2_morphToast("Morph applied (" .. #parts .. " parts)")
    return true
end

AR2_LocalPlayer.CharacterAdded:Connect(function()
    if AR2_morph.model then
        task.wait(1.5)
        pcall(AR2_applyMorph)
    end

    task.wait(0.1)
    pcall(AR2_refreshHideState)
end)


local ORANGE = Color3.fromRGB(255, 140, 30)

function AR2_promptConfigName(callback)
    local gui = Instance.new("ScreenGui") gui.Name="juju_ConfigPrompt" gui.ResetOnSpawn=false gui.Parent=(AR2_gethui and AR2_gethui()) or game:GetService("CoreGui")
    local frame = Instance.new("Frame") frame.Size=UDim2.fromOffset(300,100) frame.Position=UDim2.fromScale(0.5,0.5) frame.AnchorPoint=Vector2.new(0.5,0.5) frame.BackgroundColor3=Color3.fromRGB(20,20,20) frame.BorderSizePixel=0 frame.Parent=gui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)
    local stroke = Instance.new("UIStroke") stroke.Color = ORANGE stroke.Thickness = 1.5 stroke.Parent = frame
    local title = Instance.new("TextLabel") title.Size=UDim2.new(1,-20,0,20) title.Position=UDim2.fromOffset(10,5) title.BackgroundTransparency=1 title.Text="Enter name:" title.TextColor3=ORANGE title.Font=Enum.Font.GothamBold title.TextSize=14 title.TextXAlignment=Enum.TextXAlignment.Center title.Parent=frame
    local input = Instance.new("TextBox") input.Size=UDim2.new(1,-40,0,30) input.Position=UDim2.fromOffset(20,30) input.BackgroundColor3=Color3.fromRGB(35,35,35) input.TextColor3=Color3.fromRGB(255,255,255) input.PlaceholderText="Name" input.Font=Enum.Font.SourceSans input.TextSize=14 input.TextXAlignment=Enum.TextXAlignment.Center input.Parent=frame
    local confirm = Instance.new("TextButton") confirm.Size=UDim2.fromOffset(100,25) confirm.Position=UDim2.fromOffset(55,65) confirm.BackgroundColor3=ORANGE confirm.TextColor3=Color3.fromRGB(0,0,0) confirm.Text="Save" confirm.Font=Enum.Font.GothamBold confirm.TextSize=12 confirm.Parent=frame
    Instance.new("UICorner",confirm).CornerRadius=UDim.new(0,5)
    local cancel = Instance.new("TextButton") cancel.Size=UDim2.fromOffset(100,25) cancel.Position=UDim2.fromOffset(165,65) cancel.BackgroundColor3=Color3.fromRGB(60,60,60) cancel.TextColor3=Color3.fromRGB(255,255,255) cancel.Text="Cancel" cancel.Font=Enum.Font.GothamBold cancel.TextSize=12 cancel.Parent=frame
    Instance.new("UICorner",cancel).CornerRadius=UDim.new(0,5)
    confirm.MouseButton1Click:Connect(function() local name=input.Text gui:Destroy() if callback then callback(name) end end)
    cancel.MouseButton1Click:Connect(function() gui:Destroy() end)
end

function AR2_promptLoadoutName(title_text, callback)
    local gui = Instance.new("ScreenGui") gui.Name="juju_CosPrompt" gui.ResetOnSpawn=false gui.Parent=(AR2_gethui and AR2_gethui()) or game:GetService("CoreGui")
    local frame = Instance.new("Frame") frame.Size=UDim2.fromOffset(300,100) frame.Position=UDim2.fromScale(0.5,0.5) frame.AnchorPoint=Vector2.new(0.5,0.5) frame.BackgroundColor3=Color3.fromRGB(20,20,20) frame.BorderSizePixel=0 frame.Parent=gui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)
    local stroke = Instance.new("UIStroke") stroke.Color = ORANGE stroke.Thickness = 1.5 stroke.Parent = frame
    local title = Instance.new("TextLabel") title.Size=UDim2.new(1,-20,0,20) title.Position=UDim2.fromOffset(10,5) title.BackgroundTransparency=1 title.Text=title_text or "Loadout name:" title.TextColor3=ORANGE title.Font=Enum.Font.GothamBold title.TextSize=14 title.TextXAlignment=Enum.TextXAlignment.Center title.Parent=frame
    local input = Instance.new("TextBox") input.Size=UDim2.new(1,-40,0,30) input.Position=UDim2.fromOffset(20,30) input.BackgroundColor3=Color3.fromRGB(35,35,35) input.TextColor3=Color3.fromRGB(255,255,255) input.PlaceholderText="Name" input.Font=Enum.Font.SourceSans input.TextSize=14 input.TextXAlignment=Enum.TextXAlignment.Center input.Parent=frame
    local confirm = Instance.new("TextButton") confirm.Size=UDim2.fromOffset(100,25) confirm.Position=UDim2.fromOffset(55,65) confirm.BackgroundColor3=ORANGE confirm.TextColor3=Color3.fromRGB(0,0,0) confirm.Text="OK" confirm.Font=Enum.Font.GothamBold confirm.TextSize=12 confirm.Parent=frame
    Instance.new("UICorner",confirm).CornerRadius=UDim.new(0,5)
    local cancel = Instance.new("TextButton") cancel.Size=UDim2.fromOffset(100,25) cancel.Position=UDim2.fromOffset(165,65) cancel.BackgroundColor3=Color3.fromRGB(60,60,60) cancel.TextColor3=Color3.fromRGB(255,255,255) cancel.Text="Cancel" cancel.Font=Enum.Font.GothamBold cancel.TextSize=12 cancel.Parent=frame
    Instance.new("UICorner",cancel).CornerRadius=UDim.new(0,5)
    confirm.MouseButton1Click:Connect(function() local name=input.Text gui:Destroy() if callback then callback(name) end end)
    cancel.MouseButton1Click:Connect(function() gui:Destroy() end)
    input:CaptureFocus()
end

function AR2_promptSoundPath(callback)
    local gui = Instance.new("ScreenGui") gui.Name="juju_SoundPathPrompt" gui.ResetOnSpawn=false gui.Parent=(AR2_gethui and AR2_gethui()) or game:GetService("CoreGui")
    local frame = Instance.new("Frame") frame.Size=UDim2.fromOffset(300,100) frame.Position=UDim2.fromScale(0.5,0.5) frame.AnchorPoint=Vector2.new(0.5,0.5) frame.BackgroundColor3=Color3.fromRGB(20,20,20) frame.BorderSizePixel=0 frame.Parent=gui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)
    local stroke = Instance.new("UIStroke") stroke.Color = ORANGE stroke.Thickness = 1.5 stroke.Parent = frame
    local title = Instance.new("TextLabel") title.Size=UDim2.new(1,-20,0,20) title.Position=UDim2.fromOffset(10,5) title.BackgroundTransparency=1 title.Text="Enter sound file path:" title.TextColor3=ORANGE title.Font=Enum.Font.GothamBold title.TextSize=14 title.TextXAlignment=Enum.TextXAlignment.Center title.Parent=frame
    local input = Instance.new("TextBox") input.Size=UDim2.new(1,-40,0,30) input.Position=UDim2.fromOffset(20,30) input.BackgroundColor3=Color3.fromRGB(35,35,35) input.TextColor3=Color3.fromRGB(255,255,255) input.PlaceholderText="e.g. hit.ogg or rbxassetid://123" input.Font=Enum.Font.SansSerif input.TextSize=14 input.TextXAlignment=Enum.TextXAlignment.Center input.Parent=frame
    local confirm = Instance.new("TextButton") confirm.Size=UDim2.fromOffset(100,25) confirm.Position=UDim2.fromOffset(55,65) confirm.BackgroundColor3=ORANGE confirm.TextColor3=Color3.fromRGB(0,0,0) confirm.Text="Set" confirm.Font=Enum.Font.GothamBold confirm.TextSize=12 confirm.Parent=frame
    Instance.new("UICorner",confirm).CornerRadius=UDim.new(0,5)
    local cancel = Instance.new("TextButton") cancel.Size=UDim2.fromOffset(100,25) cancel.Position=UDim2.fromOffset(165,65) cancel.BackgroundColor3=Color3.fromRGB(60,60,60) cancel.TextColor3=Color3.fromRGB(255,255,255) cancel.Text="Cancel" cancel.Font=Enum.Font.GothamBold cancel.TextSize=12 cancel.Parent=frame
    Instance.new("UICorner",cancel).CornerRadius=UDim.new(0,5)
    confirm.MouseButton1Click:Connect(function() local path=input.Text gui:Destroy() if callback then callback(path) end end)
    cancel.MouseButton1Click:Connect(function() gui:Destroy() end)
end

function AR2_promptKeybind(featureName, currentKey, callback)
    local gui = Instance.new("ScreenGui") gui.Name="juju_KbPrompt" gui.ResetOnSpawn=false gui.Parent=(AR2_gethui and AR2_gethui()) or game:GetService("CoreGui")
    local frame = Instance.new("Frame") frame.Size=UDim2.fromOffset(320,130) frame.Position=UDim2.fromScale(0.5,0.5) frame.AnchorPoint=Vector2.new(0.5,0.5) frame.BackgroundColor3=Color3.fromRGB(20,20,20) frame.BorderSizePixel=0 frame.Parent=gui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)
    local stroke = Instance.new("UIStroke") stroke.Color = ORANGE stroke.Thickness = 1.5 stroke.Parent = frame
    local title = Instance.new("TextLabel") title.Size=UDim2.new(1,-20,0,20) title.Position=UDim2.fromOffset(10,8) title.BackgroundTransparency=1 title.Text="Keybind — "..tostring(featureName) title.TextColor3=ORANGE title.Font=Enum.Font.GothamBold title.TextSize=14 title.TextXAlignment=Enum.TextXAlignment.Left title.Parent=frame
    local hint = Instance.new("TextLabel") hint.Size=UDim2.new(1,-20,0,16) hint.Position=UDim2.fromOffset(10,28) hint.BackgroundTransparency=1 hint.Text="Q · F5 · Space · LeftShift · MouseButton3 · ctrl · None" hint.TextColor3=Color3.fromRGB(170,170,180) hint.Font=Enum.Font.Gotham hint.TextSize=10 hint.TextXAlignment=Enum.TextXAlignment.Left hint.Parent=frame
    local input = Instance.new("TextBox") input.Size=UDim2.new(1,-40,0,30) input.Position=UDim2.fromOffset(20,48) input.BackgroundColor3=Color3.fromRGB(35,35,35) input.TextColor3=Color3.fromRGB(255,255,255) input.PlaceholderText=currentKey or "None" input.Text=(currentKey and currentKey~="None") and currentKey or "" input.Font=Enum.Font.SourceSans input.TextSize=13 input.TextXAlignment=Enum.TextXAlignment.Center input.ClearTextOnFocus=false input.Parent=frame
    Instance.new("UICorner",input).CornerRadius=UDim.new(0,5)
    local confirm = Instance.new("TextButton") confirm.Size=UDim2.fromOffset(110,26) confirm.Position=UDim2.fromOffset(55,92) confirm.BackgroundColor3=ORANGE confirm.TextColor3=Color3.fromRGB(0,0,0) confirm.Text="Save" confirm.Font=Enum.Font.GothamBold confirm.TextSize=12 confirm.Parent=frame
    Instance.new("UICorner",confirm).CornerRadius=UDim.new(0,5)
    local cancel = Instance.new("TextButton") cancel.Size=UDim2.fromOffset(110,26) cancel.Position=UDim2.fromOffset(175,92) cancel.BackgroundColor3=Color3.fromRGB(60,60,60) cancel.TextColor3=Color3.fromRGB(255,255,255) cancel.Text="Cancel" cancel.Font=Enum.Font.GothamBold cancel.TextSize=12 cancel.Parent=frame
    Instance.new("UICorner",cancel).CornerRadius=UDim.new(0,5)
    local function submit()
        local newKey = AR2_normalizeKey(input.Text)
        gui:Destroy()
        if callback then callback(newKey) end
    end
    confirm.MouseButton1Click:Connect(submit)
    cancel.MouseButton1Click:Connect(function() gui:Destroy() end)
    input.FocusLost:Connect(function(enter) if enter then submit() end end)
    input:CaptureFocus()
end


function AR2_morphPrompt(title, current, callback)
    local host = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "oh_morph_prompt" gui.ResetOnSpawn = false gui.DisplayOrder = 999999 gui.Parent = host
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(300,100) frame.Position = UDim2.fromScale(0.5,0.5)
    frame.AnchorPoint = Vector2.new(0.5,0.5) frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0 frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = AR2_CFG.ui.accent stroke.Thickness = 1.5
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,20) lbl.Position = UDim2.fromOffset(10,5) lbl.BackgroundTransparency = 1
    lbl.Text = title lbl.TextColor3 = AR2_CFG.ui.accent lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.Parent = frame
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1,-40,0,30) input.Position = UDim2.fromOffset(20,30)
    input.BackgroundColor3 = Color3.fromRGB(35,35,35) input.TextColor3 = Color3.fromRGB(255,255,255)
    input.Text = current or "" input.Font = Enum.Font.SourceSans input.TextSize = 14
    input.ClearTextOnFocus = false input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)
    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.fromOffset(100,25) okBtn.Position = UDim2.fromOffset(55,65)
    okBtn.BackgroundColor3 = AR2_CFG.ui.accent okBtn.TextColor3 = Color3.new(0,0,0)
    okBtn.Text = "OK" okBtn.Font = Enum.Font.GothamBold okBtn.TextSize = 12 okBtn.Parent = frame
    Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0,5)
    local cancel = Instance.new("TextButton")
    cancel.Size = UDim2.fromOffset(100,25) cancel.Position = UDim2.fromOffset(165,65)
    cancel.BackgroundColor3 = Color3.fromRGB(60,60,60) cancel.TextColor3 = Color3.new(1,1,1)
    cancel.Text = "Cancel" cancel.Font = Enum.Font.GothamBold cancel.TextSize = 12 cancel.Parent = frame
    Instance.new("UICorner", cancel).CornerRadius = UDim.new(0,5)
    local function submit() local v = input.Text gui:Destroy() if callback then callback(v) end end
    okBtn.MouseButton1Click:Connect(submit)
    cancel.MouseButton1Click:Connect(function() gui:Destroy() end)
    input.FocusLost:Connect(function(enter) if enter then submit() end end)
    input:CaptureFocus()
end


AR2_keybindActions = {}
function AR2_registerKeybind(name,fn) AR2_keybindActions[name]=fn end

local function AR2_fireKeybind(keyName)
    local fired = false
    for feature,key in pairs(AR2_CFG.keybinds) do
        if key and key ~= "None" and key ~= "" then
            local norm = AR2_normalizeKey(key)
            if norm == keyName then
                local action = AR2_keybindActions[feature]
                if action then pcall(action) fired = true end
            end
        end
    end
    if fired then
        if type(AR2_refreshUI) == "function" then pcall(AR2_refreshUI) end
    end
end

AR2_UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    local keyName
    if input.UserInputType==Enum.UserInputType.MouseButton3 then keyName="MouseButton3" else keyName=input.KeyCode.Name end
    AR2_fireKeybind(keyName)
end)

local function AR2_registerAllKeybinds()
    AR2_registerKeybind("playerESP",function() AR2_CFG.players.on=not AR2_CFG.players.on AR2_esp.update() end)
    AR2_registerKeybind("zombieESP",function() AR2_CFG.zombies.on=not AR2_CFG.zombies.on AR2_esp.update() end)
    AR2_registerKeybind("lootESP",function() AR2_CFG.loot.on=not AR2_CFG.loot.on AR2_esp.update() end)
    AR2_registerKeybind("silentAim",function() AR2_CFG.magicAim.on=not AR2_CFG.magicAim.on AR2_magicUpdate() end)
    AR2_registerKeybind("rageBot",function() AR2_rageBotSetEnabled(not AR2_CFG.rageBot.on) end)
    AR2_registerKeybind("hbe",function() AR2_hbeSetEnabled(not AR2_CFG.weapon.hbeOn) end)
    AR2_registerKeybind("noSpread",function() AR2_CFG.weapon.noSpread=not AR2_CFG.weapon.noSpread end)
    AR2_registerKeybind("instantReload",function() setInstantReloadEnabled(not AR2_CFG.weapon.instantReload) end)
    AR2_registerKeybind("allFireModes",function() AR2_applyAllFireModes(not AR2_CFG.weapon.allFireModes) end)
    AR2_registerKeybind("wallbang",function() AR2_CFG.weapon.wallbang=not AR2_CFG.weapon.wallbang if AR2_CFG.weapon.wallbang then startWallbangTagging() else stopWallbangTagging() end end)
    AR2_registerKeybind("alwaysSuppressed",function() AR2_setAlwaysSuppressed(not AR2_CFG.weapon.alwaysSuppressed) end)
    AR2_registerKeybind("vehicleEquip",function() AR2_setVehicleEquip(not AR2_CFG.weapon.vehicleEquip) end)
    AR2_registerKeybind("boatMode",function() AR2_setBoatMode(not AR2_CFG.car.boatMode) end)
    AR2_registerKeybind("removeDrag",function() AR2_setRemoveDrag(not AR2_CFG.car.removeDrag) end)
    AR2_registerKeybind("fullSteer",function() AR2_setFullSteer(not AR2_CFG.car.fullSteer) end)
    AR2_registerKeybind("antiFallStun",function() AR2_setAntiFallStun(not AR2_CFG.misc.antiFallStun) end)
    AR2_registerKeybind("hitmarker",function() AR2_toggleHitmarker(not AR2_CFG.hitmarker.enabled) end)
    AR2_registerKeybind("crosshair",function() AR2_toggleCrosshair(not AR2_CFG.crosshair.enabled) end)
    AR2_registerKeybind("tracers",function() AR2_CFG.misc.tracers=not AR2_CFG.misc.tracers AR2_tracersUpdate() end)
    AR2_registerKeybind("speedHack",function() AR2_CFG.speed.on=not AR2_CFG.speed.on if AR2_CFG.speed.on then AR2_speed.start() else AR2_speed.stop() end end)
    AR2_registerKeybind("infJump",function() AR2_CFG.misc.infJump=not AR2_CFG.misc.infJump if AR2_CFG.misc.infJump then AR2_startInfJump() else AR2_stopInfJump() end end)
    AR2_registerKeybind("spinBot",function() AR2_setSpin(not AR2_CFG.misc.spinOn) end)
    AR2_registerKeybind("noclip",function() AR2_toggleNoclip(not AR2_CFG.misc.noclip) end)
    AR2_registerKeybind("bhop",function() AR2_CFG.misc.bhop=not AR2_CFG.misc.bhop if AR2_CFG.misc.bhop then AR2_startBhop() else AR2_stopBhop() end end)
    AR2_registerKeybind("tpDash",function() AR2_CFG.misc.tpDash=not AR2_CFG.misc.tpDash if AR2_CFG.misc.tpDash then AR2_startTpDash() else AR2_stopTpDash() end end)
    AR2_registerKeybind("carTpDash",function() AR2_CFG.car.tpDash=not AR2_CFG.car.tpDash if AR2_CFG.car.tpDash then AR2_startCarDash() else AR2_stopCarDash() end end)
    AR2_registerKeybind("carFly",function() AR2_carFlySetEnabled(not AR2_CFG.car.fly) end)
    AR2_registerKeybind("fly",function() AR2_setFly(not AR2_CFG.misc.fly) end)
    AR2_registerKeybind("flyRecover",function() AR2_resetFallState() end)
    AR2_registerKeybind("freezeZombies",function() AR2_CFG.misc.freeze=not AR2_CFG.misc.freeze if AR2_CFG.misc.freeze then AR2_freeze.start() else AR2_freeze.stop() end end)
    AR2_registerKeybind("fullbright",function() AR2_CFG.visuals.fullbright=not AR2_CFG.visuals.fullbright AR2_visuals.apply() end)
    AR2_registerKeybind("antiAim",function() AR2_toggleAntiAim(not AR2_CFG.misc.antiAim.enabled) end)
    AR2_registerKeybind("zombieCircle",function() AR2_setZombieCircle(not AR2_CFG.misc.zombieCircle.enabled) end)
    AR2_registerKeybind("jumpCircle",function() AR2_setJumpCircle(not AR2_CFG.misc.jumpCircle.enabled) end)
    AR2_registerKeybind("selfBacktrack",function() AR2_setSelfBacktrack(not AR2_CFG.misc.selfBacktrack.enabled) end)
    AR2_registerKeybind("instantInteract",function() AR2_setInstantInteract(not AR2_CFG.misc.instantInteract) end)
    AR2_registerKeybind("playerJesus",function() AR2_setPlayerJesus(not AR2_CFG.misc.playerJesus) end)
    AR2_registerKeybind("thirdPersonADS",function() AR2_set3pAds(not AR2_CFG.misc.thirdPersonADS.enabled) AR2_refreshUI() end)
    AR2_registerKeybind("resetConfig",function() AR2_resetConfig() end)
    AR2_registerKeybind("minimizeUI",function() AR2_toggleUIMinimized() end)
end


AR2_UI_ELEMENTS     = {}
AR2_configDropdown  = nil
AR2_uiGuisToDestroy = AR2_uiGuisToDestroy or {}
AR2_uiWindowRef     = nil
AR2_cosLoadoutDropdown = nil
AR2_uiSyncing       = false

AR2_minimizeGui = nil
AR2_minimizeStroke = nil
AR2_uiMinimized = false

function AR2_buildMinimizeButton()
    if AR2_minimizeGui and AR2_minimizeGui.Parent then return AR2_minimizeGui end
    local host = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
    AR2_minimizeGui = Instance.new("ScreenGui")
    AR2_minimizeGui.Name = "juju_restore"
    AR2_minimizeGui.ResetOnSpawn = false
    AR2_minimizeGui.IgnoreGuiInset = true
    AR2_minimizeGui.DisplayOrder = 1000000
    AR2_minimizeGui.Enabled = false
    AR2_minimizeGui.Parent = host
    table.insert(AR2_uiGuisToDestroy, AR2_minimizeGui)

    local btn = Instance.new("TextButton")
    btn.Name = "restore"
    btn.Size = UDim2.fromOffset(136, 30)
    btn.Position = UDim2.fromOffset(14, 14)
    btn.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    btn.BackgroundTransparency = 0.08
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = "ORIGIN  —  open"
    btn.TextColor3 = Color3.fromRGB(235, 235, 245)
    btn.Parent = AR2_minimizeGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    AR2_minimizeStroke = Instance.new("UIStroke")
    AR2_minimizeStroke.Color = (AR2_CFG.ui and AR2_CFG.ui.accent) or Color3.fromRGB(255, 140, 40)
    AR2_minimizeStroke.Thickness = 1
    AR2_minimizeStroke.Transparency = 0.2
    AR2_minimizeStroke.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    end)

    local dragging, moved, dragStart, startPos = false, false, nil, nil

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    AR2_minimizeDragConn = AR2_UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then moved = true end
            btn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    AR2_minimizeUpConn = AR2_UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                AR2_setUIMinimized(false)
            end
            dragging = false
        end
    end)

    return AR2_minimizeGui
end

function AR2_setUIMinimized(state)
    local win = AR2_uiWindowRef or (getgenv and getgenv().OriginHUB_Window) or nil
    if type(win) ~= "table" then return false end

    local applied = pcall(function()
        if win.Signal and win.Signal.SetValue then
            win.Signal:SetValue(not state)
        elseif win.ToggleInterface then
            win:ToggleInterface()
        end
    end)
    if not applied then return false end

    AR2_uiMinimized = state and true or false

    if state then
        AR2_buildMinimizeButton()
        pcall(function()
            if AR2_minimizeStroke then
                AR2_minimizeStroke.Color = (AR2_CFG.ui and AR2_CFG.ui.accent)
                    or Color3.fromRGB(255, 140, 40)
            end
            if AR2_minimizeGui then AR2_minimizeGui.Enabled = true end
        end)
    else
        pcall(function()
            if AR2_minimizeGui then AR2_minimizeGui.Enabled = false end
        end)
    end
    return true
end
]=]
local __juju_origin_fn, __juju_origin_err = loadstring(__juju_origin_src, "juju_origin")
if not __juju_origin_fn then
	__juju_origin_fn, __juju_origin_err = load(__juju_origin_src, "juju_origin")
end
assert(__juju_origin_fn, "[juju] origin engine failed to compile: " .. tostring(__juju_origin_err))
__juju_origin_fn()

-- kill Origin FOV circle drawers (juju owns FOV rings)
pcall(function()
	if AR2_CFG then
		AR2_CFG.magicAim.showFov = false
		AR2_CFG.aim.showFov = false
	end
end)
pcall(function()
	-- Origin magic FOV loop often stored on AR2_magicAim
	if AR2_magicAim then
		AR2_magicAim.showFov = false
	end
end)
-- ######## END ORIGIN ENGINE ########
-- > ( luraph variables )

if not LPH_OBFUSCATED then
	LPH_JIT_MAX = function(...)
		return ...
	end
	LPH_NO_VIRTUALIZE = function(...)
		return ...
	end
	LPH_ENCSTR = function(...)
		return ...
	end
	LPH_NO_UPVALUES = function(...)
		return ...
	end
	LPH_JIT = function(...)
		return ...
	end
end

-- > ( global cheat variables )

local file_path = getgenv().custom_folder or "juju recode"
local user_input_service = cloneref(game:GetService("UserInputService"))
local get_mouse_location = user_input_service["GetMouseLocation"]
local players_service = cloneref(game:GetService("Players"))
local local_player = players_service["LocalPlayer"]
local lighting_service = cloneref(game:GetService("Lighting"))
local mouse = local_player:GetMouse()
local tween_service = cloneref(game:GetService("TweenService"))
local get_value = tween_service["GetValue"]
local run_service = cloneref(game:GetService("RunService"))
local http_service = cloneref(game:GetService("HttpService"))
local workspace = workspace
local camera = cloneref(workspace["CurrentCamera"])
local hui = cloneref(gethui())

local color3_fromrgb = Color3["fromRGB"]
local color3_lerp = function(start_color, end_color, alpha)
	return start_color:Lerp(end_color, alpha)
end
local vector2_new = Vector2["new"]
local udim2_new = UDim2["new"]

local math_random = math["random"]
local clock = os["clock"]
local delay = task["delay"]
local spawn = task["spawn"]
local clamp = math["clamp"]
local floor = math["floor"]
local wait = task["wait"]
local sqrt = math["sqrt"]
local type = type

local shadow_image_data = base64_decode(
	"iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAQAAABpN6lAAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAAmJLR0QA/4ePzL8AAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAHdElNRQfiAQkTIxqKm+UhAAACvElEQVR42u2dzY7aMBhFjxPHEzJQBolRq77/27XSwBCSkD/PwinS7LpBVwrfeYLjI4Ozuy6Cw+HIyHBkOMCxTiIQmYnMzEQi0S9Hz/EUePIlxDpJB58YGRiZmJlTgIKCQMkLYYmwTtLhe2509AwM6QbkFJRUbKnYEChWHGCgp6WhpoF0AzI8gYodB/bs2BDI1aYPYqKn5cIZR7oPkyejoGTLgZ+888aOEq82fRAjHRdOlEBkZGTwODwvVOx55zdH9rxSqE0fxMCVMxXQ0dHS4TwZOYENO9448osDW4La9EH01GyAhhOfBHKy9Ar4JcGeA0d2Kw5QAu3yT+fJcB7IyJdn8JUtO36sOAB0vFISKNJz7+9fgelTKBAIlGrThxEI3z743Fpf/P/GAqgF1FgAtYAaC6AWUGMB1AJqLIBaQI0FUAuosQBqATUWQC2gxgKoBdRYALWAGgugFlBjAdQCaiyAWkCNBVALqLEAagE1FkAtoMYCqAXUWAC1gBoLoBZQYwHUAmosgFpAjQVQC6ixAGoBNRZALaDGAqgF1FgAtYAaC6AWUGMB1AJqLIBaQI0FUAuosQBqATUWQC2gxgKoBdRYALWAGgugFlBjAdQCaiyAWkCNBVALqLEAagE1FkAtoMYCqAXUWAC1gBoLoBZQYwHUAmosgFpAjQVQC6ixAGoBNRZALaDGAqgF1FgAtYAaC6AWUGMB1AJqLIBaQI0nfpsi7enp1VIPI53uPriaVmfT9ORAT8eVmhJWvDZ3oea6TK5OzOkGzIz3Lc4N0K04QM0HZy609IzMRM98nyI9UQHt6ic3/3JaEkzMnsjIjYYzJdA8xejqH8403BjTDRjoqHFAx+lJZnc/qOkYmP3yD9AAkY7PJxpe7hnTT2BiAGZG2ieb3p6ILj75+LqL4O7Dq245/HoDpAjx32cQ8QtpRORenSWX2AAAABl0RVh0U29mdHdhcmUAcGFpbnQubmV0IDQuMC4xOdTWsmQAAAAASUVORK5CYII="
)
local pixel_image_data = base64_decode(
	"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAA8nYBAOgDAADydgEA6AMAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAACOO8FX0xe8TgAAAAxJREFUGFdj+P//PwAF/gL+pzWBhAAAAABJRU5ErkJggg=="
)
local exponential = Enum["EasingStyle"]["Exponential"]
local circular = Enum["EasingStyle"]["Circular"]
local quad = Enum["EasingStyle"]["Quad"]

local show_transparency = { Transparency = 1 }
local hide_transparency = { Transparency = 0 }
local menu_references = {}

local out = Enum["EasingDirection"]["Out"]

local connections = {}
local addon_data = {}
local heartbeat = {}

local flags = {
	["keybinds_position"] = { 15, camera["ViewportSize"]["Y"] / 2 - 10 },
	["loaded_addons"] = {},
	["favorites"] = {},
	["esp_enabled"] = false,
	["esp_team_check"] = false,
	["esp_names"] = false,
	["esp_name_size"] = 14,
	["esp_name_mode"] = { "display name" },
	["esp_boxes"] = false,
	["esp_box_fill"] = false,
	["esp_box_style"] = { "corner" },
	["esp_box_corner_size"] = 0.25,
	["esp_box_outline"] = false,
	["esp_box_thickness"] = 1.2,
	["esp_box_fill_transparency"] = 0.15,
	["esp_box_fill_color"] = color3_fromrgb(255, 255, 255),
	["esp_box_color"] = color3_fromrgb(255, 255, 255),
	["esp_box_color_transparency"] = 0,
	["esp_npc_enabled"] = false,
	["esp_npc_box"] = false,
	["esp_npc_box_color"] = color3_fromrgb(255, 255, 255),
	["esp_npc_box_color_transparency"] = 0,
	["esp_npc_health"] = false,
	["esp_npc_health_color"] = color3_fromrgb(255, 255, 255),
	["esp_npc_health_color_transparency"] = 0,
	["esp_npc_skeleton"] = false,
	["esp_npc_skeleton_color"] = color3_fromrgb(255, 255, 255),
	["esp_npc_skeleton_color_transparency"] = 0,
	["esp_npc_chams"] = false,
	["esp_vehicle_enabled"] = false,
	["esp_vehicle_box"] = false,
	["esp_vehicle_box_color"] = color3_fromrgb(255, 255, 255),
	["esp_vehicle_box_color_transparency"] = 0,
	["esp_vehicle_name"] = false,
	["esp_vehicle_name_color"] = color3_fromrgb(255, 255, 255),
	["esp_vehicle_name_color_transparency"] = 0,
	["misc_zombie_freeze"] = false,
	["misc_no_fog"] = false,
	["misc_fullbright"] = false,
	["misc_remove_clouds"] = false,
	["misc_clear_atmosphere"] = false,
	["misc_world_time"] = 12,
	["esp_healthbar"] = false,
	["esp_healthbar_position"] = { "left" },
	["esp_health_text"] = false,
	["esp_health_text_color"] = color3_fromrgb(255, 255, 255),
	["esp_health_high"] = color3_fromrgb(255, 255, 255),
	["esp_health_low"] = color3_fromrgb(255, 255, 255),
	["esp_distance"] = false,
	["esp_distance_limit"] = false,
	["esp_max_distance"] = 1000,
	["esp_distance_color"] = color3_fromrgb(255, 255, 255),
	["esp_weapon"] = false,
	["esp_weapon_color"] = color3_fromrgb(255, 255, 255),
	["esp_skeletons"] = false,
	["esp_skeleton_color"] = color3_fromrgb(255, 255, 255),
	["esp_tracers"] = false,
	["esp_tracer_color"] = color3_fromrgb(255, 255, 255),
	["esp_head_dot"] = false,
	["esp_head_dot_color"] = color3_fromrgb(255, 255, 255),
	["esp_chams"] = false,
	["esp_chams_color"] = color3_fromrgb(255, 255, 255),
	["esp_chams_outline_color"] = color3_fromrgb(255, 255, 255),
	["esp_chams_transparency"] = 0.45,
	["main_aimbot"] = false,
	["misc_world_time_enabled"] = false,
	["combat_saim"] = false,
	["combat_saim_fov"] = 120,
	["combat_saim_show_fov"] = false,
	["combat_saim_fov_color"] = color3_fromrgb(154, 213, 222),
	["combat_saim_fov_transparency"] = 0.5,
	["combat_saim_hitpart"] = { "Head" },
	["combat_saim_players"] = false,
	["combat_saim_zombies"] = false,
	["combat_saim_team_check"] = false,
	["combat_saim_visible_only"] = false,
	["combat_saim_sticky"] = false,
	["combat_saim_wallcheck"] = false,
	["combat_saim_max_distance"] = 1000,
	["combat_saim_prediction"] = false,
	["combat_saim_prediction_factor"] = 0.12,
	["combat_saim_priority"] = { "crosshair" },
	["combat_saim_target_line"] = false,
	["combat_saim_target_line_color"] = color3_fromrgb(154, 213, 222),
	["combat_saim_target_line_from"] = { "mouse" },
	["combat_aimbot"] = false,
	["combat_aimbot_fov"] = 120,
	["combat_aimbot_show_fov"] = false,
	["combat_aimbot_fov_color"] = color3_fromrgb(154, 213, 222),
	["combat_aimbot_fov_transparency"] = 0.5,
	["combat_aimbot_hitpart"] = { "Head" },
	["combat_aimbot_method"] = { "camera" },
	["combat_aimbot_smooth"] = 8,
	["combat_aimbot_instant"] = false,
	["combat_aimbot_sticky"] = false,
	["combat_aimbot_prediction"] = false,
	["combat_aimbot_prediction_factor"] = 0.12,
	["combat_aimbot_priority"] = { "crosshair" },
	["combat_aimbot_players"] = false,
	["combat_aimbot_zombies"] = false,
	["combat_aimbot_team_check"] = false,
	["combat_aimbot_visible_only"] = false,
	["combat_aimbot_wallcheck"] = false,
	["combat_aimbot_max_distance"] = 1000,
	["combat_aimbot_target_line"] = false,
	["combat_aimbot_target_line_color"] = color3_fromrgb(154, 213, 222),
	["combat_aimbot_target_line_from"] = { "mouse" },
	["combat_saim_show_accuracy"] = false,
	["combat_saim_manual_left"] = false,
	["combat_saim_manual_right"] = false,
	["misc_fly"] = false,
	["misc_fly_value"] = 16,
	["misc_spiderman"] = false,
	["misc_spiderman_value"] = 16,
	["misc_speedometer"] = false,
	["misc_noclip"] = false,
	["misc_car_noclip"] = false,
	["weapon_magic_bullet"] = false,
	["weapon_magic_max_bend"] = 45,
	["weapon_hbe"] = false,
	["weapon_hbe_size"] = 3,
	["weapon_vehicle_equip"] = false,
	["misc_bhop"] = false,
	["misc_bhop_height"] = 15,
	["misc_spinbot"] = false,
	["misc_spinbot_speed"] = 20,
	["misc_spinbot_tilt"] = false,
	["misc_anti_fall"] = false,
	["misc_spoof_state"] = false,
	["misc_spoof_state_as"] = { "Running" },
	["misc_car_boat"] = false,
	["misc_car_remove_drag"] = false,
	["misc_car_full_steer"] = false,
	["misc_car_god"] = false,
	["misc_car_fuel"] = false,
	["misc_car_boost"] = false,
	["misc_car_boost_speed"] = 120,
	["misc_car_torque"] = 3,
	["misc_car_max_traction"] = false,
	["misc_car_tp_dash"] = false,
	["misc_car_tp_dash_studs"] = 30,
	["misc_morph"] = false,
	["misc_morph_id"] = "",
	["misc_morph_preset"] = { "Custom" },
	["misc_morph_hide"] = false,
	["misc_fov_zoom"] = false,
	["misc_zoom_fov"] = 30,
	["misc_camera_fov"] = false,
	["misc_camera_fov_value"] = 70,
	["weapon_no_recoil"] = false,
	["weapon_no_spread"] = false,
	["weapon_wallbang"] = false,
	["weapon_instabullet"] = false,
	["weapon_instabullet_mult"] = 3,
	["misc_carspeed"] = false,
	["misc_carspeed_mult"] = 1.5,
	["misc_cargrip"] = false,
	["misc_cargrip_mult"] = 1.5,
	["misc_carsteer"] = false,
	["misc_carsteer_mult"] = 1.0,
	["combat_trigger"] = false,
	["combat_trigger_fov"] = 25,
	["combat_trigger_delay"] = 0.05,
	["combat_trigger_wallcheck"] = false,
	["combat_trigger_team_check"] = false,
	["combat_trigger_players"] = false,
	["combat_trigger_zombies"] = false,
	["combat_trigger_hitpart"] = { "Head" },
	["aa_enabled"] = false,
	["aa_mode"] = { "spin" },
	["aa_yaw"] = 180,
	["aa_pitch"] = 0,
	["aa_spin_speed"] = 180,
	["aa_jitter_range"] = 45,
	["aa_invert"] = false,
	["misc_bullet_tracers"] = false,
	["misc_bullet_tracer_color"] = color3_fromrgb(154, 213, 222),
	["misc_bullet_tracer_life"] = 0.55,
	["misc_bullet_tracer_width"] = 1.8,
	["misc_bullet_tracer_segments"] = 12,
	["misc_bullet_tracer_wallcheck"] = false,
	["esp_visible_only"] = false,
	["esp_offscreen"] = false,
	["esp_offscreen_color"] = color3_fromrgb(154, 213, 222),
	["esp_offscreen_size"] = 12,
	["esp_tracer_origin"] = { "bottom" },
	["esp_box_glow"] = false,
	["esp_rainbow"] = false,
	["esp_flags"] = false,
	["esp_flags_color"] = color3_fromrgb(255, 200, 80),
}

local player_esp_state = {
	objects = {},
	chams = {},
}

local zombie_esp_state = {
	objects = {},
	frozen_parts = {},
}

local world_settings_state = {
	fog_blocks = {},
	fog_values = nil,
	fullbright_values = nil,
	cloud = nil,
	cloud_enabled = nil,
	atmosphere_values = {},
}

local CHAMS_TRANSPARENCY = 0
local viewport_chams = { models = {} }

local function is_viewport_cham_excluded(part)
	if not part:IsA("BasePart") then
		return true
	end
	if part.Material == Enum.Material.Neon then
		return true
	end
	local color = part.Color
	if color.G > 0.7 and color.R < 0.3 and color.B < 0.3 then
		return true
	end
	return part.Name:find("VR") ~= nil or part.Name:find("Controller") ~= nil or part.Name == "HumanoidRootPart"
end

local function destroy_viewport_cham(key)
	local entry = viewport_chams.models[key]
	if not entry then
		return
	end
	if entry.added then entry.added:Disconnect() end
	if entry.removing then entry.removing:Disconnect() end
	if entry.model then entry.model:Destroy() end
	viewport_chams.models[key] = nil
	if next(viewport_chams.models) == nil then
		if viewport_chams.connection then
			viewport_chams.connection:Disconnect()
			viewport_chams.connection = nil
		end
		if viewport_chams.gui then
			viewport_chams.gui:Destroy()
		end
		viewport_chams.gui = nil
		viewport_chams.frame = nil
		viewport_chams.camera = nil
	end
end

local function add_viewport_cham_item(entry, object)
	if object:IsA("BasePart") then
		if is_viewport_cham_excluded(object) or entry.parts[object] then
			return
		end
		local ok, clone_part = pcall(function()
			return object:Clone()
		end)
		if not ok or not clone_part then
			return
		end
		for _, descendant in ipairs(clone_part:GetDescendants()) do
			if descendant:IsA("JointInstance") or descendant:IsA("Script") or descendant:IsA("LocalScript") then
				descendant:Destroy()
			end
		end
		clone_part.CanCollide = false
		clone_part.Anchored = true
		clone_part.CastShadow = false
		clone_part.Transparency = object.Parent and (object.Parent:IsA("Accessory") or object.Parent:IsA("Tool"))
			and CHAMS_TRANSPARENCY
			or math.max(object.Transparency, CHAMS_TRANSPARENCY)
		clone_part.Parent = entry.model
		entry.parts[object] = clone_part
	elseif object:IsA("Shirt") or object:IsA("Pants") or object:IsA("CharacterMesh") or object:IsA("BodyColors") or object:IsA("ShirtGraphic") then
		local ok, clone_object = pcall(function()
			return object:Clone()
		end)
		if ok and clone_object then
			clone_object.Parent = entry.model
		end
	end
end

local function update_viewport_cham(key, character, enabled)
	if not enabled or not character or not character.Parent then
		destroy_viewport_cham(key)
		return
	end

	local current = viewport_chams.models[key]
	if current and current.character == character then
		return
	end
	destroy_viewport_cham(key)

	if not viewport_chams.gui or not viewport_chams.gui.Parent then
		local screen_gui = Instance.new("ScreenGui")
		screen_gui.Name = "ViewportXRay"
		screen_gui.ResetOnSpawn = false
		screen_gui.IgnoreGuiInset = true
		screen_gui.DisplayOrder = -1
		screen_gui.Parent = hui

		local viewport = Instance.new("ViewportFrame")
		viewport.Name = "Chams"
		viewport.Size = UDim2.new(1, 0, 1, 0)
		viewport.BackgroundTransparency = 1
		viewport.LightColor = Color3.fromRGB(255, 255, 255)
		viewport.LightDirection = Vector3.new(-1, -1, -1)
		viewport.Ambient = Color3.fromRGB(200, 200, 200)
		viewport.Parent = screen_gui

		local viewport_camera = Instance.new("Camera")
		viewport_camera.Name = "ChamsCamera"
		viewport_camera.Parent = viewport
		viewport_camera.CFrame = camera.CFrame
		viewport_camera.FieldOfView = camera.FieldOfView
		viewport.CurrentCamera = viewport_camera
		viewport_chams.gui = screen_gui
		viewport_chams.frame = viewport
		viewport_chams.camera = viewport_camera
	end

	local clone_model = Instance.new("Model")
	clone_model.Name = character.Name .. "_Cham"
	clone_model.Parent = viewport_chams.frame
	local entry = { character = character, model = clone_model, parts = {} }
	viewport_chams.models[key] = entry
	for _, object in ipairs(character:GetDescendants()) do
		add_viewport_cham_item(entry, object)
	end
	entry.added = character.DescendantAdded:Connect(function(object)
		add_viewport_cham_item(entry, object)
	end)
	entry.removing = character.DescendantRemoving:Connect(function(object)
		for original, clone_part in pairs(entry.parts) do
			if original == object or original:IsDescendantOf(object) then
				clone_part:Destroy()
				entry.parts[original] = nil
			end
		end
	end)

	if not viewport_chams.connection then
		viewport_chams.connection = run_service.RenderStepped:Connect(function()
			local live_camera = workspace.CurrentCamera
			local view_camera = viewport_chams.camera
			if live_camera and view_camera then
				view_camera.CFrame = live_camera.CFrame
				view_camera.FieldOfView = live_camera.FieldOfView
			end
			for cham_key, cham in pairs(viewport_chams.models) do
				if not cham.character.Parent or not cham.model.Parent then
					destroy_viewport_cham(cham_key)
				else
					for original, clone_part in pairs(cham.parts) do
						if original.Parent and clone_part.Parent then
							clone_part.CFrame = original.CFrame
						else
							if clone_part.Parent then clone_part:Destroy() end
							cham.parts[original] = nil
						end
					end
				end
			end
		end)
		connections[#connections + 1] = viewport_chams.connection
	end
end

local vehicle_esp_state = {
	objects = {},
}

local function hide_player_esp_entry(player)
	local entry = player_esp_state.objects[player]
	if not entry then
		return
	end

	for key, object in pairs(entry) do
		if key == "smoothed_health" then
			continue
		end
		if type(object) == "table" then
			for _, line in pairs(object) do
				if type(line) == "userdata" or (type(line) == "table" and line.Visible ~= nil) then
					pcall(function()
						line.Visible = false
					end)
				end
			end
		elseif object ~= nil then
			pcall(function()
				object.Visible = false
			end)
		end
	end
end

local function ensure_player_esp(player)
	if player_esp_state.objects[player] then
		return player_esp_state.objects[player]
	end

	local entry = {
		box_fill = Drawing.new("Square"),
		box = Drawing.new("Square"),
		box_outline = Drawing.new("Square"),
		name = Drawing.new("Text"),
		distance = Drawing.new("Text"),
		weapon = Drawing.new("Text"),
		flags_text = Drawing.new("Text"),
		health_text = Drawing.new("Text"),
		health_back = Drawing.new("Square"),
		health_fill = Drawing.new("Square"),
		health_outline = Drawing.new("Square"),
		tracer = Drawing.new("Line"),
		head_dot = Drawing.new("Circle"),
		offscreen_lines = { Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line") },
		skeleton = {},
		box_corners = {},
		box_corner_outlines = {},
		smoothed_health = 1,
	}

	for i = 1, 8 do
		entry.box_corners[i] = Drawing.new("Line")
		entry.box_corners[i].Visible = false
		entry.box_corners[i].Thickness = 1.4
		entry.box_corner_outlines[i] = Drawing.new("Line")
		entry.box_corner_outlines[i].Visible = false
		entry.box_corner_outlines[i].Thickness = 2.6
		entry.box_corner_outlines[i].Color = Color3.new(0, 0, 0)
	end

	for i = 1, 19 do
		entry.skeleton[i] = Drawing.new("Line")
		entry.skeleton[i].Visible = false
		entry.skeleton[i].Thickness = 1.4
	end

	for _, key in ipairs({ "name", "distance", "weapon", "health_text", "flags_text" }) do
		entry[key].Outline = true
		entry[key].Font = 2
		entry[key].Center = true
	end
	entry.health_text.Center = false
	entry.flags_text.Center = false
	entry.flags_text.Size = 12
	for _, ol in ipairs(entry.offscreen_lines) do
		ol.Thickness = 1.5
		ol.Visible = false
	end
	entry.box_outline.Filled = false
	entry.box_outline.Thickness = 2.6
	entry.box_outline.Color = Color3.new(0, 0, 0)
	entry.health_outline.Filled = false
	entry.health_outline.Thickness = 1
	entry.health_outline.Color = Color3.new(0, 0, 0)

	player_esp_state.objects[player] = entry
	return entry
end

local function clear_player_chams(player)
	player_esp_state.chams[player] = nil
	destroy_viewport_cham(player)
end

local function update_player_chams(player, character)
	local enabled = flags["esp_enabled"] and flags["esp_chams"]
	update_viewport_cham(player, character, enabled)
	player_esp_state.chams[player] = enabled and character or nil
end

local function remove_player_esp(player)
	hide_player_esp_entry(player)
	clear_player_chams(player)

	local entry = player_esp_state.objects[player]
	if entry then
		for _, object in pairs(entry) do
			if type(object) == "table" then
				for _, drawing in pairs(object) do
					if drawing then
						pcall(function()
							drawing:Remove()
						end)
					end
				end
			elseif object then
				pcall(function()
					object:Remove()
				end)
			end
		end
		player_esp_state.objects[player] = nil
	end
end

local function esp_is_visible(origin, target_pos, character)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { local_player.Character, camera, character }
	params.IgnoreWater = true
	local dir = target_pos - origin
	local dist = dir.Magnitude
	if dist < 0.1 then
		return true
	end
	local result = workspace:Raycast(origin, dir.Unit * dist, params)
	return result == nil
end

local function esp_rainbow_color(t)
	return Color3.fromHSV((t * 0.15) % 1, 0.85, 1)
end

local function update_player_esp()
	if not flags["esp_enabled"] then
		for player in pairs(player_esp_state.objects) do
			hide_player_esp_entry(player)
			clear_player_chams(player)
		end
		return
	end

	for _, player in ipairs(players_service:GetPlayers()) do
		if player == local_player then
			continue
		end
		if flags["esp_team_check"] and local_player.Team ~= nil and player.Team == local_player.Team then
			hide_player_esp_entry(player)
			clear_player_chams(player)
			continue
		end

		local character = player.Character
		local entry = ensure_player_esp(player)
		if not character then
			hide_player_esp_entry(player)
			clear_player_chams(player)
			continue
		end
		local head = character:FindFirstChild("Head")
		local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not head or not root or not humanoid then
			hide_player_esp_entry(player)
			clear_player_chams(player)
			continue
		end
		local distance = math.floor((root.Position - camera.CFrame.Position).Magnitude)
		if flags["esp_distance_limit"] and distance > flags["esp_max_distance"] then
			hide_player_esp_entry(player)
			clear_player_chams(player)
			continue
		end
		if flags["esp_visible_only"] and not esp_is_visible(camera.CFrame.Position, head.Position, character) then
			hide_player_esp_entry(player)
			clear_player_chams(player)
			continue
		end
		update_player_chams(player, character)

		local bounds_frame, bounds_size = character:GetBoundingBox()
		local min_x, min_y = math.huge, math.huge
		local max_x, max_y = -math.huge, -math.huge
		local front_corners = 0
		for _, x_sign in ipairs({ -1, 1 }) do
			for _, y_sign in ipairs({ -1, 1 }) do
				for _, z_sign in ipairs({ -1, 1 }) do
					local corner = bounds_frame:PointToWorldSpace(Vector3.new(
						bounds_size.X * x_sign / 2,
						bounds_size.Y * y_sign / 2,
						bounds_size.Z * z_sign / 2
					))
					local point = camera:WorldToViewportPoint(corner)
					if point.Z > 0 then
						front_corners += 1
						min_x = math.min(min_x, point.X)
						min_y = math.min(min_y, point.Y)
						max_x = math.max(max_x, point.X)
						max_y = math.max(max_y, point.Y)
					end
				end
			end
		end

		local viewport = camera.ViewportSize
		if front_corners == 0 or max_x < 0 or min_x > viewport.X or max_y < 0 or min_y > viewport.Y then
			hide_player_esp_entry(player)
			continue
		end

		local head_pos = camera:WorldToViewportPoint(head.Position)
		local width = math.max(max_x - min_x, 1)
		local height = math.max(max_y - min_y, 1)
		local center_x = (min_x + max_x) / 2
		local box_color = flags["esp_rainbow"] and esp_rainbow_color(clock()) or flags["esp_box_color"]
		local box_corner_size = math.clamp(flags["esp_box_corner_size"], 0.08, 0.5)
		local corner_length = math.min(width, height) * box_corner_size

		local boxes_on = flags["esp_boxes"]
		local style = flags["esp_box_style"][1] or "corner"
		local use_full = style == "full"

		entry.box.Visible = boxes_on and use_full
		entry.box_outline.Visible = boxes_on and use_full and flags["esp_box_outline"]
		if entry.box.Visible then
			entry.box.Color = box_color
			entry.box.Thickness = flags["esp_box_thickness"]
			entry.box_outline.Thickness = (flags["esp_box_thickness"] or 1.2) + 1.4
			entry.box_outline.Color = Color3.new(0, 0, 0)
			entry.box_outline.Size = Vector2.new(width + 2, height + 2)
			entry.box_outline.Position = Vector2.new(min_x - 1, min_y - 1)
			entry.box_outline.Filled = false
			entry.box.Filled = false
			entry.box.Size = Vector2.new(width, height)
			entry.box.Position = Vector2.new(min_x, min_y)
		end

		entry.box_fill.Visible = boxes_on and flags["esp_box_fill"]
		if entry.box_fill.Visible then
			entry.box_fill.Color = flags["esp_box_fill_color"]
			entry.box_fill.Transparency = flags["esp_box_fill_transparency"]
			entry.box_fill.Filled = true
			entry.box_fill.Size = Vector2.new(width, height)
			entry.box_fill.Position = Vector2.new(min_x, min_y)
		end

		local corner_segments = {
			{ Vector2.new(min_x, min_y), Vector2.new(min_x + corner_length, min_y) },
			{ Vector2.new(min_x, min_y), Vector2.new(min_x, min_y + corner_length) },
			{ Vector2.new(max_x - corner_length, min_y), Vector2.new(max_x, min_y) },
			{ Vector2.new(max_x, min_y), Vector2.new(max_x, min_y + corner_length) },
			{ Vector2.new(min_x, max_y - corner_length), Vector2.new(min_x, max_y) },
			{ Vector2.new(min_x, max_y), Vector2.new(min_x + corner_length, max_y) },
			{ Vector2.new(max_x, max_y - corner_length), Vector2.new(max_x, max_y) },
			{ Vector2.new(max_x - corner_length, max_y), Vector2.new(max_x, max_y) },
		}
		local corner_on = boxes_on and not use_full
		local thick = flags["esp_box_thickness"] or 1.2
		if not entry.box_corner_outlines then
			entry.box_corner_outlines = {}
			for i = 1, 8 do
				entry.box_corner_outlines[i] = Drawing.new("Line")
				entry.box_corner_outlines[i].Visible = false
			end
		end
		for i, segment in ipairs(corner_segments) do
			local outline = entry.box_corner_outlines[i]
			local line = entry.box_corners[i]
			local show = corner_on
			outline.Visible = show and flags["esp_box_outline"]
			line.Visible = show
			if show then
				outline.From = segment[1]
				outline.To = segment[2]
				outline.Color = Color3.new(0, 0, 0)
				outline.Thickness = thick + 1.4
				line.From = segment[1]
				line.To = segment[2]
				line.Color = box_color
				line.Thickness = thick
			end
		end

		entry.name.Visible = flags["esp_names"]
		entry.name.Text = flags["esp_name_mode"][1] == "username" and player.Name or (player.DisplayName or player.Name)
		entry.name.Color = box_color
		entry.name.Position = Vector2.new(center_x, min_y - 16)
		entry.name.Size = flags["esp_name_size"]
		entry.name.Font = 2
		entry.name.Center = true
		entry.name.Outline = true

		entry.distance.Visible = flags["esp_distance"]
		entry.distance.Text = tostring(distance) .. "m"
		entry.distance.Color = flags["esp_distance_color"]
		entry.distance.Position = Vector2.new(center_x, max_y + 4)
		entry.distance.Size = 13
		entry.distance.Font = 2
		entry.distance.Center = true
		entry.distance.Outline = true

		local equipped_tool = character:FindFirstChildOfClass("Tool")
		entry.weapon.Visible = flags["esp_weapon"] and equipped_tool ~= nil
		entry.weapon.Text = equipped_tool and equipped_tool.Name or ""
		entry.weapon.Color = flags["esp_weapon_color"]
		local weapon_y = math.clamp(max_y + (flags["esp_distance"] and 18 or 4), 18, viewport.Y - 20)
		entry.weapon.Position = Vector2.new(center_x, weapon_y)
		entry.weapon.Size = 12
		entry.weapon.Font = 2
		entry.weapon.Center = true

		local health_ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
		local healthbar_right = flags["esp_healthbar_position"][1] == "right"
		local healthbar_x = healthbar_right and max_x + 3 or min_x - 6
		entry.smoothed_health = entry.smoothed_health + (health_ratio - entry.smoothed_health) * 0.22
		local sh = entry.smoothed_health
		local hb_on = flags["esp_healthbar"]
		entry.health_outline.Visible = hb_on
		entry.health_outline.Size = Vector2.new(5, height + 2)
		entry.health_outline.Position = Vector2.new(healthbar_x - 1, min_y - 1)
		entry.health_back.Visible = hb_on
		entry.health_back.Color = Color3.fromRGB(15, 15, 15)
		entry.health_back.Filled = true
		entry.health_back.Transparency = 0.15
		entry.health_back.Size = Vector2.new(3, height)
		entry.health_back.Position = Vector2.new(healthbar_x, min_y)
		entry.health_fill.Visible = hb_on
		entry.health_fill.Color = flags["esp_health_low"]:Lerp(flags["esp_health_high"], sh)
		entry.health_fill.Filled = true
		entry.health_fill.Size = Vector2.new(3, math.max(1, height * sh))
		entry.health_fill.Position = Vector2.new(healthbar_x, max_y - (height * sh))

entry.health_text.Visible = flags["esp_health_text"]
		entry.health_text.Text = tostring(math.floor(humanoid.Health))
		entry.health_text.Color = flags["esp_health_text_color"]
		entry.health_text.Position = Vector2.new(healthbar_right and max_x + 9 or min_x - 22, max_y - (height * health_ratio) - 6)
		entry.health_text.Size = 12
		entry.health_text.Font = 2
		entry.health_text.Center = false

		entry.tracer.Visible = flags["esp_tracers"]
		if flags["esp_tracers"] then
			local origin_mode = flags["esp_tracer_origin"][1] or "bottom"
			local from
			if origin_mode == "top" then
				from = Vector2.new(viewport.X / 2, 0)
			elseif origin_mode == "mouse" then
				from = get_mouse_location(user_input_service)
			elseif origin_mode == "center" then
				from = Vector2.new(viewport.X / 2, viewport.Y / 2)
			else
				from = Vector2.new(viewport.X / 2, viewport.Y)
			end
			entry.tracer.From = from
			entry.tracer.To = Vector2.new(center_x, max_y)
			entry.tracer.Color = flags["esp_rainbow"] and box_color or flags["esp_tracer_color"]
			entry.tracer.Thickness = 1.2
		end

		entry.head_dot.Visible = flags["esp_head_dot"] and head_pos.Z > 0
		entry.head_dot.Position = Vector2.new(head_pos.X, head_pos.Y)
		entry.head_dot.Radius = 3
		entry.head_dot.Filled = true
		entry.head_dot.Color = flags["esp_rainbow"] and box_color or flags["esp_head_dot_color"]

		local flag_bits = {}
		if flags["esp_flags"] then
			local tool = character:FindFirstChildOfClass("Tool")
			if tool then
				flag_bits[#flag_bits + 1] = tool.Name
			end
			if humanoid.Health < humanoid.MaxHealth * 0.35 then
				flag_bits[#flag_bits + 1] = "LOW"
			end
			if humanoid.MoveDirection.Magnitude > 0.05 then
				flag_bits[#flag_bits + 1] = "MOVE"
			end
		end
		entry.flags_text.Visible = flags["esp_flags"] and #flag_bits > 0
		if entry.flags_text.Visible then
			entry.flags_text.Text = table.concat(flag_bits, " | ")
			entry.flags_text.Color = flags["esp_flags_color"]
			entry.flags_text.Position = Vector2.new(max_x + 6, min_y)
			entry.flags_text.Outline = true
		end

		local on_screen = head_pos.Z > 0 and head_pos.X > 0 and head_pos.X < viewport.X and head_pos.Y > 0 and head_pos.Y < viewport.Y
		local show_off = flags["esp_offscreen"] and not on_screen
		if entry.offscreen_lines then
			for _, ol in ipairs(entry.offscreen_lines) do
				ol.Visible = false
			end
			if show_off then
				local dir = Vector2.new(head_pos.X - viewport.X / 2, head_pos.Y - viewport.Y / 2)
				if head_pos.Z < 0 then
					dir = -dir
				end
				local mag = dir.Magnitude
				if mag < 1 then
					dir = Vector2.new(0, -1)
				end
				dir = dir.Unit
				local radius = math.min(viewport.X, viewport.Y) * 0.42
				local tip = Vector2.new(viewport.X / 2, viewport.Y / 2) + dir * radius
				local size = flags["esp_offscreen_size"] or 12
				local perp = Vector2.new(-dir.Y, dir.X)
				local b = tip - dir * size + perp * (size * 0.55)
				local c = tip - dir * size - perp * (size * 0.55)
				local col = flags["esp_rainbow"] and box_color or flags["esp_offscreen_color"]
				local pts = { { tip, b }, { tip, c }, { b, c } }
				for i, seg in ipairs(pts) do
					local ol = entry.offscreen_lines[i]
					ol.From = seg[1]
					ol.To = seg[2]
					ol.Color = col
					ol.Visible = true
				end
			end
		end

		if flags["esp_skeletons"] then
			local pairs = {
				{ "Head", "UpperTorso" },
				{ "UpperTorso", "LowerTorso" },
				{ "UpperTorso", "LeftUpperArm" },
				{ "LeftUpperArm", "LeftLowerArm" },
				{ "LeftLowerArm", "LeftHand" },
				{ "UpperTorso", "RightUpperArm" },
				{ "RightUpperArm", "RightLowerArm" },
				{ "RightLowerArm", "RightHand" },
				{ "LowerTorso", "LeftUpperLeg" },
				{ "LeftUpperLeg", "LeftLowerLeg" },
				{ "LeftLowerLeg", "LeftFoot" },
				{ "LowerTorso", "RightUpperLeg" },
				{ "RightUpperLeg", "RightLowerLeg" },
				{ "RightLowerLeg", "RightFoot" },
				{ "Head", "Torso" },
				{ "Torso", "Left Arm" },
				{ "Torso", "Right Arm" },
				{ "Torso", "Left Leg" },
				{ "Torso", "Right Leg" },
			}
			for i, pair in ipairs(pairs) do
				entry.skeleton[i].Visible = false
				local a = character:FindFirstChild(pair[1])
				local b = character:FindFirstChild(pair[2])
				if a and b then
					local pa, pb = camera:WorldToViewportPoint(a.Position), camera:WorldToViewportPoint(b.Position)
					if pa.Z > 0 and pb.Z > 0 then
						local line = entry.skeleton[i]
						line.Visible = true
						line.From = Vector2.new(pa.X, pa.Y)
						line.To = Vector2.new(pb.X, pb.Y)
						line.Color = flags["esp_skeleton_color"]
						line.Thickness = 1.2
					end
				end
			end
		else
			for i = 1, 19 do
				if entry.skeleton[i] then
					entry.skeleton[i].Visible = false
				end
			end
		end
	end
end

local function watch_player_esp()
	if player_esp_state.loop then
		return
	end

	player_esp_state.loop = run_service.Heartbeat:Connect(function()
		pcall(update_player_esp)
	end)
	connections[#connections + 1] = player_esp_state.loop
	player_esp_state.removing = players_service.PlayerRemoving:Connect(remove_player_esp)
	connections[#connections + 1] = player_esp_state.removing
end

local function get_zombie_folder()
	local folder = workspace:FindFirstChild("Zombies") or workspace:FindFirstChild("zombies")
	if folder then
		return folder
	end

	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Folder") and child.Name:lower():find("zombie") then
			return child
		end
	end

	return nil
end

local function get_zombie_models(folder)
	local models = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Model") then
			models[#models + 1] = child
		end
		for _, descendant in ipairs(child:GetDescendants()) do
			if descendant:IsA("Model") then
				models[#models + 1] = descendant
			end
		end
	end
	return models
end

local function restore_zombie_part(part)
	local state = zombie_esp_state.frozen_parts[part]
	if state then
		if part.Parent then
			part.Anchored = state.anchored
		end
		zombie_esp_state.frozen_parts[part] = nil
	end
end

local function restore_frozen_zombies()
	for part in pairs(zombie_esp_state.frozen_parts) do
		restore_zombie_part(part)
	end
end

local function anchor_zombie_part(part, seen)
	if not part or not part:IsA("BasePart") then
		return
	end

	seen[part] = true
	if not zombie_esp_state.frozen_parts[part] then
		zombie_esp_state.frozen_parts[part] = { anchored = part.Anchored }
	end
	part.Anchored = true
	part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

local function clear_zombie_esp()
	for model, entry in pairs(zombie_esp_state.objects) do
		destroy_viewport_cham(model)
		if entry then
			for _, object in pairs(entry) do
				if type(object) == "table" then
					for _, drawing in pairs(object) do
						if drawing then
							pcall(function()
								drawing:Remove()
							end)
						end
					end
				else
					if object and object.Visible ~= nil then
						pcall(function()
							object:Remove()
						end)
					end
				end
			end
		end
		zombie_esp_state.objects[model] = nil
	end
end

local function ensure_zombie_esp(model)
	if zombie_esp_state.objects[model] then
		return zombie_esp_state.objects[model]
	end

	local entry = {
		health_back = Drawing.new("Square"),
		health_fill = Drawing.new("Square"),
		name = Drawing.new("Text"),
		skeleton = {},
		box_corners = {},
	}
	for i = 1, 8 do
		entry.box_corners[i] = Drawing.new("Line")
		entry.box_corners[i].Visible = false
	end

	for i = 1, 19 do
		entry.skeleton[i] = Drawing.new("Line")
		entry.skeleton[i].Visible = false
		entry.skeleton[i].Thickness = 1.2
	end

	zombie_esp_state.objects[model] = entry
	return entry
end

local function remove_zombie_esp(model)
	local entry = zombie_esp_state.objects[model]
	if not entry then
		return
	end
	destroy_viewport_cham(model)

	for _, object in pairs(entry) do
		if type(object) == "table" then
			for _, drawing in pairs(object) do
				if drawing then
					pcall(function()
						drawing:Remove()
					end)
				end
			end
		else
			if object and object.Visible ~= nil then
				pcall(function()
					object:Remove()
				end)
			end
		end
	end
	zombie_esp_state.objects[model] = nil
end

local function update_zombie_esp()
	if not flags["esp_npc_enabled"] then
		clear_zombie_esp()
		return
	end

	local folder = get_zombie_folder()
	if not folder then
		clear_zombie_esp()
		return
	end

	local seen = {}
	for _, child in ipairs(get_zombie_models(folder)) do
		if child:IsA("Model") then
			local humanoid = child:FindFirstChildOfClass("Humanoid")
			local root = child:FindFirstChild("HumanoidRootPart", true)
				or child:FindFirstChild("LeftUpperLeg", true)
				or child:FindFirstChild("UpperTorso", true)
				or child:FindFirstChild("Torso", true)
			if not root or not root:IsA("BasePart") then
				continue
			end

			seen[child] = true
			local entry = ensure_zombie_esp(child)
			update_viewport_cham(child, child, flags["esp_npc_chams"])
			local bounds_frame, bounds_size = child:GetBoundingBox()
			local min_x, min_y = math.huge, math.huge
			local max_x, max_y = -math.huge, -math.huge
			for _, x_sign in ipairs({ -1, 1 }) do
				for _, y_sign in ipairs({ -1, 1 }) do
					for _, z_sign in ipairs({ -1, 1 }) do
						local corner = bounds_frame:PointToWorldSpace(Vector3.new(
							bounds_size.X * x_sign / 2,
							bounds_size.Y * y_sign / 2,
							bounds_size.Z * z_sign / 2
						))
						local point = camera:WorldToViewportPoint(corner)
						if point.Z > 0 then
							min_x = math.min(min_x, point.X)
							min_y = math.min(min_y, point.Y)
							max_x = math.max(max_x, point.X)
							max_y = math.max(max_y, point.Y)
						end
					end
				end
			end

			local viewport = camera.ViewportSize
			if max_x == -math.huge or min_x == math.huge or max_x < 0 or min_x > viewport.X or max_y < 0 or min_y > viewport.Y then
				for _, object in pairs(entry) do
					if type(object) == "table" then
						for _, drawing in pairs(object) do
							if drawing then
								drawing.Visible = false
							end
						end
					else
						if object and object.Visible ~= nil then
							object.Visible = false
						end
					end
				end
				continue
			end

			local width = math.max(max_x - min_x, 1)
			local height = math.max(max_y - min_y, 1)
			local center_x = (min_x + max_x) / 2
			local health_ratio = humanoid and math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1) or 1
			local box_color = flags["esp_npc_box_color"]
			local corner_length = math.min(width, height) * math.clamp(flags["esp_box_corner_size"], 0.08, 0.5)
			local corner_segments = {
				{ Vector2.new(min_x, min_y), Vector2.new(min_x + corner_length, min_y) },
				{ Vector2.new(min_x, min_y), Vector2.new(min_x, min_y + corner_length) },
				{ Vector2.new(max_x - corner_length, min_y), Vector2.new(max_x, min_y) },
				{ Vector2.new(max_x, min_y), Vector2.new(max_x, min_y + corner_length) },
				{ Vector2.new(min_x, max_y - corner_length), Vector2.new(min_x, max_y) },
				{ Vector2.new(min_x, max_y), Vector2.new(min_x + corner_length, max_y) },
				{ Vector2.new(max_x, max_y - corner_length), Vector2.new(max_x, max_y) },
				{ Vector2.new(max_x - corner_length, max_y), Vector2.new(max_x, max_y) },
			}
			for i, segment in ipairs(corner_segments) do
				local line = entry.box_corners[i]
				line.Visible = flags["esp_npc_box"]
				line.From = segment[1]
				line.To = segment[2]
				line.Color = box_color
				line.Thickness = 1.2
			end

			entry.health_back.Visible = false
			entry.health_fill.Visible = false

			entry.name.Visible = false
			if flags["esp_npc_skeleton"] then
				local pairs = {
					{ "Head", "UpperTorso" },
					{ "UpperTorso", "LowerTorso" },
					{ "UpperTorso", "LeftUpperArm" },
					{ "LeftUpperArm", "LeftLowerArm" },
					{ "LeftLowerArm", "LeftHand" },
					{ "UpperTorso", "RightUpperArm" },
					{ "RightUpperArm", "RightLowerArm" },
					{ "RightLowerArm", "RightHand" },
					{ "LowerTorso", "LeftUpperLeg" },
					{ "LeftUpperLeg", "LeftLowerLeg" },
					{ "LeftLowerLeg", "LeftFoot" },
					{ "LowerTorso", "RightUpperLeg" },
					{ "RightUpperLeg", "RightLowerLeg" },
					{ "RightLowerLeg", "RightFoot" },
				}
				for i, pair in ipairs(pairs) do
					local a = child:FindFirstChild(pair[1], true)
					local b = child:FindFirstChild(pair[2], true)
					local line = entry.skeleton[i]
					line.Visible = false
					if a and a:IsA("BasePart") and b and b:IsA("BasePart") then
						local pa, pb = camera:WorldToViewportPoint(a.Position), camera:WorldToViewportPoint(b.Position)
						if pa.Z > 0 and pb.Z > 0 then
							line.Visible = true
							line.From = Vector2.new(pa.X, pa.Y)
							line.To = Vector2.new(pb.X, pb.Y)
							line.Color = flags["esp_npc_skeleton_color"]
							line.Thickness = 1.2
						end
					end
				end
			else
				for i = 1, 19 do
					if entry.skeleton[i] then
						entry.skeleton[i].Visible = false
					end
				end
			end
		end
	end

	for model in pairs(zombie_esp_state.objects) do
		if not seen[model] then
			remove_zombie_esp(model)
		end
	end
end

local function freeze_zombies()
	if not flags["misc_zombie_freeze"] then
		restore_frozen_zombies()
		return
	end

	local folder = get_zombie_folder()
	if not folder then
		restore_frozen_zombies()
		return
	end

	local seen = {}
	for _, child in ipairs(get_zombie_models(folder)) do
		if child:IsA("Model") then
			anchor_zombie_part(child:FindFirstChild("LeftUpperLeg", true), seen)
			anchor_zombie_part(child:FindFirstChild("HumanoidRootPart", true), seen)
		end
	end

	for part in pairs(zombie_esp_state.frozen_parts) do
		if not seen[part] then
			restore_zombie_part(part)
		end
	end
end

local function find_fog_block()
	local player_gui = local_player:FindFirstChildOfClass("PlayerGui")
	local damage_corners = player_gui and player_gui:FindFirstChild("DamageCorners")
	return damage_corners and damage_corners:FindFirstChild("FogBlock")
end

local function set_no_fog(enabled)
	local state = world_settings_state
	if enabled then
		if not state.fog_values then
			state.fog_values = {
				FogStart = lighting_service.FogStart,
				FogEnd = lighting_service.FogEnd,
			}
		end
		lighting_service.FogStart = 0
		lighting_service.FogEnd = 1000000

		local fog_block = find_fog_block()
		if fog_block and fog_block.Parent then
			state.fog_blocks[fog_block] = fog_block.Parent
			fog_block.Parent = nil
		end
	else
		if state.fog_values then
			lighting_service.FogStart = state.fog_values.FogStart
			lighting_service.FogEnd = state.fog_values.FogEnd
			state.fog_values = nil
		end
		for fog_block, parent in pairs(state.fog_blocks) do
			pcall(function()
				fog_block.Parent = parent
			end)
			state.fog_blocks[fog_block] = nil
		end
	end
end

local function set_fullbright(enabled)
	local state = world_settings_state
	if enabled then
		if not state.fullbright_values then
			state.fullbright_values = {
				Brightness = lighting_service.Brightness,
				Ambient = lighting_service.Ambient,
				OutdoorAmbient = lighting_service.OutdoorAmbient,
				GlobalShadows = lighting_service.GlobalShadows,
			}
		end
		lighting_service.Brightness = 3
		lighting_service.Ambient = Color3.new(1, 1, 1)
		lighting_service.OutdoorAmbient = Color3.new(1, 1, 1)
		lighting_service.GlobalShadows = false
	elseif state.fullbright_values then
		for property, value in pairs(state.fullbright_values) do
			lighting_service[property] = value
		end
		state.fullbright_values = nil
	end
end

local function set_clouds_disabled(disabled)
	local state = world_settings_state
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	local clouds = terrain and terrain:FindFirstChildOfClass("Clouds")
	if disabled then
		if clouds then
			if state.cloud ~= clouds then
				state.cloud = clouds
				state.cloud_enabled = clouds.Enabled
			end
			clouds.Enabled = false
		end
	elseif state.cloud then
		pcall(function()
			state.cloud.Enabled = state.cloud_enabled
		end)
		state.cloud = nil
		state.cloud_enabled = nil
	end
end

local function set_atmosphere_cleared(cleared)
	local state = world_settings_state
	if cleared then
		for _, effect in ipairs(lighting_service:GetChildren()) do
			if effect:IsA("Atmosphere") then
				if not state.atmosphere_values[effect] then
					state.atmosphere_values[effect] = {
						Density = effect.Density,
						Haze = effect.Haze,
						Glare = effect.Glare,
					}
				end
				effect.Density = 0
				effect.Haze = 0
				effect.Glare = 0
			end
		end
	else
		for effect, values in pairs(state.atmosphere_values) do
			pcall(function()
				for property, value in pairs(values) do
					effect[property] = value
				end
			end)
			state.atmosphere_values[effect] = nil
		end
	end
end

local function watch_zombie_esp()
	if zombie_esp_state.loop then
		return
	end

	zombie_esp_state.loop = run_service.Heartbeat:Connect(function()
		freeze_zombies()
		update_zombie_esp()
	end)
	connections[#connections + 1] = zombie_esp_state.loop
end

local world_loop_state = {
	loop = nil,
	time_hooked = false,
	fb_hooked = false,
	suppress_time = false,
	suppress_fb = false,
}

local function force_world_time()
	if not flags["misc_world_time_enabled"] then
		return
	end
	local target = (tonumber(flags["misc_world_time"]) or 12) % 24
	world_loop_state.suppress_time = true
	pcall(function()
		lighting_service.ClockTime = target
		-- TimeOfDay string format HH:MM:SS
		local h = math.floor(target)
		local m = math.floor((target - h) * 60)
		lighting_service.TimeOfDay = string.format("%02d:%02d:00", h % 24, m)
	end)
	world_loop_state.suppress_time = false
end

-- IY-style loop fullbright: hard overwrite every frame + on property change
local function force_fullbright()
	if not flags["misc_fullbright"] then
		return
	end
	world_loop_state.suppress_fb = true
	pcall(function()
		lighting_service.Brightness = 2
		lighting_service.ClockTime = lighting_service.ClockTime -- keep current unless time lock owns it
		lighting_service.FogEnd = 9e9
		lighting_service.FogStart = 0
		lighting_service.GlobalShadows = false
		lighting_service.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		lighting_service.Ambient = Color3.fromRGB(128, 128, 128)
		for _, child in ipairs(lighting_service:GetChildren()) do
			if child:IsA("BloomEffect") then
				child.Enabled = false
			elseif child:IsA("BlurEffect") then
				child.Enabled = false
			elseif child:IsA("ColorCorrectionEffect") then
				child.Enabled = false
			elseif child:IsA("SunRaysEffect") then
				child.Enabled = false
			elseif child:IsA("Atmosphere") then
				child.Density = 0
				child.Haze = 0
				child.Glare = 0
			end
		end
	end)
	world_loop_state.suppress_fb = false
end

local function apply_loop_clouds()
	if not flags["misc_remove_clouds"] then
		return
	end
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	local clouds = terrain and terrain:FindFirstChildOfClass("Clouds")
	if clouds and clouds.Enabled then
		clouds.Enabled = false
	end
end

local function apply_loop_atmosphere()
	if not flags["misc_clear_atmosphere"] then
		return
	end
	for _, effect in ipairs(lighting_service:GetChildren()) do
		if effect:IsA("Atmosphere") then
			effect.Density = 0
			effect.Offset = 0
			effect.Glare = 0
			effect.Haze = 0
		elseif effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
			pcall(function()
				effect.Enabled = false
			end)
		end
	end
end

local function install_lighting_hooks()
	if not world_loop_state.time_hooked then
		world_loop_state.time_hooked = true
		local function on_time_changed()
			if world_loop_state.suppress_time then
				return
			end
			if flags["misc_world_time_enabled"] then
				force_world_time()
			end
		end
		connections[#connections + 1] = lighting_service:GetPropertyChangedSignal("ClockTime"):Connect(on_time_changed)
		connections[#connections + 1] = lighting_service:GetPropertyChangedSignal("TimeOfDay"):Connect(on_time_changed)
	end
	if not world_loop_state.fb_hooked then
		world_loop_state.fb_hooked = true
		local function on_fb_prop()
			if world_loop_state.suppress_fb then
				return
			end
			if flags["misc_fullbright"] then
				force_fullbright()
			end
		end
		for _, prop in ipairs({ "Brightness", "Ambient", "OutdoorAmbient", "GlobalShadows", "FogEnd", "FogStart" }) do
			connections[#connections + 1] = lighting_service:GetPropertyChangedSignal(prop):Connect(on_fb_prop)
		end
		connections[#connections + 1] = lighting_service.ChildAdded:Connect(function()
			if flags["misc_fullbright"] then
				force_fullbright()
			end
		end)
	end
end

local function watch_world_settings()
	if world_loop_state.loop then
		return
	end
	install_lighting_hooks()
	-- RenderStepped = faster fight against game scripts that set lighting on Heartbeat
	world_loop_state.loop = run_service.RenderStepped:Connect(function()
		if flags["misc_world_time_enabled"] then
			force_world_time()
		end
		if flags["misc_fullbright"] then
			force_fullbright()
		end
		apply_loop_clouds()
		apply_loop_atmosphere()
	end)
	connections[#connections + 1] = world_loop_state.loop
end

local function get_vehicle_folder()
	local folder = workspace:FindFirstChild("Vehicles") or workspace:FindFirstChild("vehicles")
	if folder then
		return folder
	end

	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Folder") and child.Name:lower():find("vehicle") then
			return child
		end
	end

	return nil
end

local function get_vehicle_models(folder)
	local models = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Model") then
			models[#models + 1] = child
		end
	end
	return models
end

local function remove_vehicle_esp(model)
	local entry = vehicle_esp_state.objects[model]
	if not entry then
		return
	end

	for _, object in pairs(entry) do
		if type(object) == "table" then
			for _, drawing in pairs(object) do
				if drawing then
					pcall(function()
						drawing:Remove()
					end)
				end
			end
		else
			if object and object.Visible ~= nil then
				pcall(function()
					object:Remove()
				end)
			end
		end
	end
	vehicle_esp_state.objects[model] = nil
end

local function clear_vehicle_esp()
	for model in pairs(vehicle_esp_state.objects) do
		remove_vehicle_esp(model)
	end
end

local function ensure_vehicle_esp(model)
	if vehicle_esp_state.objects[model] then
		return vehicle_esp_state.objects[model]
	end

	local entry = {
		box = Drawing.new("Square"),
		name = Drawing.new("Text"),
	}
	vehicle_esp_state.objects[model] = entry
	return entry
end

local function update_vehicle_esp()
	if not flags["esp_vehicle_enabled"] then
		clear_vehicle_esp()
		return
	end

	local folder = get_vehicle_folder()
	if not folder then
		clear_vehicle_esp()
		return
	end

	local seen = {}
	for _, child in ipairs(get_vehicle_models(folder)) do
		if child:IsA("Model") then
			local root = child.PrimaryPart
				or child:FindFirstChild("PrimaryPart", true)
				or child:FindFirstChild("RootPart", true)
				or child:FindFirstChild("Root", true)
				or child:FindFirstChild("HumanoidRootPart", true)
				or child:FindFirstChildOfClass("BasePart")
			if not root or not root:IsA("BasePart") then
				continue
			end

			seen[child] = true
			local entry = ensure_vehicle_esp(child)
			local bounds_frame, bounds_size = child:GetBoundingBox()
			local min_x, min_y = math.huge, math.huge
			local max_x, max_y = -math.huge, -math.huge
			for _, x_sign in ipairs({ -1, 1 }) do
				for _, y_sign in ipairs({ -1, 1 }) do
					for _, z_sign in ipairs({ -1, 1 }) do
						local corner = bounds_frame:PointToWorldSpace(Vector3.new(
							bounds_size.X * x_sign / 2,
							bounds_size.Y * y_sign / 2,
							bounds_size.Z * z_sign / 2
						))
						local point = camera:WorldToViewportPoint(corner)
						if point.Z > 0 then
							min_x = math.min(min_x, point.X)
							min_y = math.min(min_y, point.Y)
							max_x = math.max(max_x, point.X)
							max_y = math.max(max_y, point.Y)
						end
					end
				end
			end

			local viewport = camera.ViewportSize
			if max_x == -math.huge or min_x == math.huge or max_x < 0 or min_x > viewport.X or max_y < 0 or min_y > viewport.Y then
				entry.box.Visible = false
				entry.name.Visible = false
				continue
			end

			local width = math.max(max_x - min_x, 1)
			local height = math.max(max_y - min_y, 1)
			local center_x = (min_x + max_x) / 2
			local group_name = child.Name
			if child.Parent and child.Parent:IsA("Folder") and child.Parent ~= workspace then
				group_name = child.Name
			end

			entry.box.Visible = flags["esp_vehicle_box"]
			entry.box.Color = flags["esp_vehicle_box_color"]
			entry.box.Thickness = 1.2
			entry.box.Filled = false
			entry.box.Size = Vector2.new(width, height)
			entry.box.Position = Vector2.new(min_x, min_y)

			entry.name.Visible = flags["esp_vehicle_name"]
			entry.name.Text = group_name
			entry.name.Color = flags["esp_vehicle_name_color"]
			entry.name.Position = Vector2.new(center_x, min_y - 16)
			entry.name.Size = 14
			entry.name.Font = 2
			entry.name.Center = true
		end
	end

	for model in pairs(vehicle_esp_state.objects) do
		if not seen[model] then
			remove_vehicle_esp(model)
		end
	end
end

local function watch_vehicle_esp()
	if vehicle_esp_state.loop then
		return
	end

	vehicle_esp_state.loop = run_service.Heartbeat:Connect(function()
		update_vehicle_esp()
	end)
	connections[#connections + 1] = vehicle_esp_state.loop
end

-- > ( global cheat functions )

local create_connection = LPH_NO_VIRTUALIZE(function(signal, callback)
	local connection = signal:Connect(callback)
	connections[#connections + 1] = connection

	return connection
end)

local create_instance = LPH_NO_VIRTUALIZE(function(class, properties)
	local instance = Instance["new"](class)

	for property, value in properties do
		instance[property] = value
	end

	return instance
end)

local round = LPH_NO_VIRTUALIZE(function(num, decimals)
	local mult = 10 ^ (decimals or 0)
	return floor(num * mult + 0.5 - (num < 0 and 1 or 0)) / mult
end)

local remove = LPH_NO_VIRTUALIZE(function(tbl, index)
	local length = #tbl
	for i = index, length - 1 do
		tbl[i] = tbl[i + 1]
	end
	tbl[length] = nil
end)

-- > ( signal library )

local signal = {}

do
	-- > ( connection class)

	local connection = {}

	connection["__index"] = connection

	function connection.new(signal, callback)
		local callbacks = signal["callbacks"]
		callbacks[#callbacks + 1] = callback

		return setmetatable({
			callback = callback,
			signal = signal,
		}, connection)
	end

	function connection:Disconnect()
		local callbacks = self["signal"]["callbacks"]
		local callback = self["callback"]

		for i = 1, #callbacks do
			if callbacks[i] == callback then
				remove(callbacks, i)

				break
			end
		end
	end

	-- > ( signal class )

	signal["__index"] = signal

	signal.new = LPH_JIT_MAX(function()
		return setmetatable({
			callbacks = {},
		}, signal)
	end)

	function signal:Fire(...)
		local callbacks = self["callbacks"]
		for i = 1, #callbacks do
			spawn(callbacks[i], ...)
		end
	end

	function signal:Connect(callback)
		return connection["new"](self, callback)
	end
end

-- > ( tween library )

local active_tweens = {
	Color = {},
	Color3 = {},
	Size = {},
	tween_position = {},
	Position = {},
	tween_size = {},
	Transparency = {},
	FillTransparency = {},
	OutlineTransparency = {},
	BackgroundTransparency = {},
	ImageTransparency = {},
	FillColor = {},
	OutlineColor = {},
	[11] = {},
	[15] = {},
}

local tween = nil
do
	local sqrt = math["sqrt"]

	tween = LPH_NO_VIRTUALIZE(function(object, properties, easing_style, _, tween_duration)
		local start_time = clock()

		local tween_functions = {}

		for property, value in properties do
			local tweens = active_tweens[property]
			local old_tween = tweens[object]

			if old_tween then
				for i = 1, #heartbeat do
					if heartbeat[i] == old_tween then
						remove(heartbeat, i)
						break
					end
				end
			end

			local old_value = object[property]

			if property == "Color" or property == "Color3" or property == "FillColor" or property == "OutlineColor" then
				tween_functions[property] = function()
					local t = ((clock() - start_time) / tween_duration)
					local alpha = easing_style == exponential and (t == 1 and 1 or 1 - 2 ^ (-10 * t))
						or easing_style == quad and t ^ 2
						or sqrt(1 - (t - 1) ^ 2)
					if easing_style == "sine" then
						alpha = t < 0.5 and 0.5 * math.sin(clamp(t, 0, 1) * 355 / 113) or 0.5 + 0.5 * (1 - math.cos(
							(clamp(t, 0, 1) - 0.5) * 355 / 113
						))
					end
					object[property] = color3_lerp(old_value, value, alpha)
				end
			elseif property == "tween_position" or property == "tween_size" then
				tween_functions[property] = function()
					local t = ((clock() - start_time) / tween_duration)
					local tween_value = easing_style == exponential and (t == 1 and 1 or 1 - 2 ^ (-10 * t))
						or easing_style == quad and t ^ 2
						or sqrt(1 - (t - 1) ^ 2)

					local new = (value - old_value)
					new = udim2_new(
						new["X"]["Scale"] * tween_value,
						new["X"]["Offset"] * tween_value,
						new["Y"]["Scale"] * tween_value,
						new["Y"]["Offset"] * tween_value
					)

					object[property] = old_value + new
				end
			else
				tween_functions[property] = function()
					local t = ((clock() - start_time) / tween_duration)

					object[property] = old_value
						+ (value - old_value)
							* (easing_style == exponential and (t == 1 and 1 or 1 - 2 ^ (-10 * t)) or easing_style == quad and t ^ 2 or sqrt(
								1 - (t - 1) ^ 2
							))
				end
			end
		end

		for property, tween in tween_functions do
			heartbeat[#heartbeat + 1] = tween
			active_tweens[property][object] = tween
		end

		delay(tween_duration, function()
			for property, tween in tween_functions do
				for i = 1, #heartbeat do
					if heartbeat[i] == tween then
						remove(heartbeat, i)

						object[property] = properties[property]
						break
					end
				end
			end
		end)
	end)
end

-- > ( menu )

-- > ( menu )

local menu = {
	on_config_loaded = signal["new"](),
	accent = color3_fromrgb(154, 213, 222),
	colors = {
		["shadow"] = color3_fromrgb(154, 213, 222),
		["accent"] = color3_fromrgb(154, 213, 222),
		["active_text"] = color3_fromrgb(197, 197, 197),
		["keybind_text"] = color3_fromrgb(197, 197, 197),
		["border"] = color3_fromrgb(24, 25, 24),
		["inactive_text"] = color3_fromrgb(75, 72, 72),
		["highlighted"] = color3_fromrgb(51, 65, 70),
		["dark_text"] = color3_fromrgb(70, 85, 87),
		["image"] = color3_fromrgb(89, 89, 89),
		["section"] = color3_fromrgb(6, 6, 6),
		["background"] = color3_fromrgb(0, 0, 0),
		["success"] = color3_fromrgb(154, 213, 222),
		["error"] = color3_fromrgb(39, 60, 96),
		["alert"] = color3_fromrgb(30, 51, 61),
		["logo"] = color3_fromrgb(154, 213, 222),
		["juju"] = color3_fromrgb(154, 213, 222),
		["build"] = color3_fromrgb(154, 213, 222),
		["cursor"] = color3_fromrgb(154, 213, 222),
	},
	settings = {},
	notifications = {},
	groups = {},
	favorites = {},
	autoload = nil,
	initial_base_offset = 75,
	ordered_groups = {},
	theme = "",
}


-- > ( combat / silent aim )

local saim_state = {
	hooked = false,
	old_fire = nil,
	fov_circle = nil,
	target_line = nil,
	accuracy_text = nil,
	loop = nil,
	sticky_model = nil,
	sticky_part = nil,
	last_accuracy = "—",
	tracers = {},
	autospin_active = false,
	autorotate_cached = nil,
	spin_loop = nil,
}

local function get_saim_hitpart(model)
	local preferred = flags["combat_saim_hitpart"][1] or "Head"
	local part = model:FindFirstChild(preferred)
	if part and part:IsA("BasePart") then
		return part
	end
	for _, name in ipairs({ "Head", "HumanoidRootPart", "UpperTorso", "Torso" }) do
		part = model:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

local function saim_wall_blocked(origin, target_pos)
	local direction = target_pos - origin
	local distance = direction.Magnitude
	if distance < 0.1 then
		return false
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { local_player.Character, camera }
	params.IgnoreWater = true
	local result = workspace:Raycast(origin, direction.Unit * distance, params)
	if not result then
		return false
	end
	local hit = result.Instance
	if not hit then
		return false
	end
	local model = hit:FindFirstAncestorOfClass("Model")
	if model and (model:FindFirstChildOfClass("Humanoid") or model:FindFirstChild("HumanoidRootPart")) then
		return false
	end
	return true
end

local function get_predicted_position(part)
	local pos = part.Position
	if not flags["combat_saim_prediction"] then
		return pos
	end
	local velocity = part.AssemblyLinearVelocity
	if velocity.Magnitude < 0.05 then
		return pos
	end
	return pos + velocity * flags["combat_saim_prediction_factor"]
end

local function get_closest_saim_target(radius)
	local closest_model, closest_part
	local best_score = math.huge
	local mouse_pos = get_mouse_location(user_input_service)
	local cam_pos = camera.CFrame.Position
	local priority = flags["combat_saim_priority"][1] or "crosshair"

	if flags["combat_saim_sticky"] and saim_state.sticky_model and saim_state.sticky_model.Parent and saim_state.sticky_part and saim_state.sticky_part.Parent then
		local sticky_hum = saim_state.sticky_model:FindFirstChildOfClass("Humanoid")
		if sticky_hum and sticky_hum.Health > 0 then
			local screen = camera:WorldToViewportPoint(saim_state.sticky_part.Position)
			if screen.Z > 0 then
				local dist = (Vector2.new(screen.X, screen.Y) - mouse_pos).Magnitude
				if dist <= (radius or math.huge) then
					return saim_state.sticky_model, saim_state.sticky_part
				end
			end
		end
		saim_state.sticky_model = nil
		saim_state.sticky_part = nil
	end

	local function consider(model)
		if not model or model == local_player.Character then
			return
		end
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= 0 then
			return
		end
		if flags["combat_saim_team_check"] then
			local player = players_service:GetPlayerFromCharacter(model)
			if player and local_player.Team and player.Team == local_player.Team then
				return
			end
		end
		local hitpart = get_saim_hitpart(model)
		if not hitpart then
			return
		end
		local world_pos = get_predicted_position(hitpart)
		local world_distance = (world_pos - cam_pos).Magnitude
		if world_distance > flags["combat_saim_max_distance"] then
			return
		end
		local screen, on_screen = camera:WorldToViewportPoint(world_pos)
		if flags["combat_saim_visible_only"] and not on_screen then
			return
		end
		if screen.Z <= 0 then
			return
		end
		local crosshair_dist = (Vector2.new(screen.X, screen.Y) - mouse_pos).Magnitude
		if crosshair_dist > (radius or math.huge) then
			return
		end
		if flags["combat_saim_wallcheck"] and saim_wall_blocked(cam_pos, world_pos) then
			return
		end

		local score
		if priority == "distance" then
			score = world_distance
		elseif priority == "health" then
			score = humanoid and humanoid.Health or 100
		else
			score = crosshair_dist
		end

		if score < best_score then
			best_score = score
			closest_model = model
			closest_part = hitpart
		end
	end

	if flags["combat_saim_players"] then
		local characters = workspace:FindFirstChild("Characters")
		if characters then
			for _, model in ipairs(characters:GetChildren()) do
				if model:IsA("Model") then
					consider(model)
				end
			end
		else
			for _, player in ipairs(players_service:GetPlayers()) do
				if player ~= local_player and player.Character then
					consider(player.Character)
				end
			end
		end
	end

	if flags["combat_saim_zombies"] then
		local zombies = workspace:FindFirstChild("Zombies") or workspace:FindFirstChild("zombies")
		if zombies then
			for _, model in ipairs(zombies:GetChildren()) do
				if model:IsA("Model") then
					consider(model)
				end
			end
		end
	end

	if closest_model and flags["combat_saim_sticky"] then
		saim_state.sticky_model = closest_model
		saim_state.sticky_part = closest_part
	end

	return closest_model, closest_part
end

local function ensure_saim_fov_circle()
	if saim_state.fov_circle then
		return saim_state.fov_circle
	end
	local circle = Drawing.new("Circle")
	circle.Filled = false
	circle.Thickness = 1.2
	circle.NumSides = 64
	circle.Visible = false
	saim_state.fov_circle = circle
	return circle
end

local function ensure_saim_target_line()
	if saim_state.target_line then
		return saim_state.target_line
	end
	local line = Drawing.new("Line")
	line.Thickness = 1.2
	line.Visible = false
	saim_state.target_line = line
	return line
end

local function ensure_saim_accuracy_text()
	if saim_state.accuracy_text then
		return saim_state.accuracy_text
	end
	local text = Drawing.new("Text")
	text.Size = 13
	text.Font = 2
	text.Center = true
	text.Outline = true
	text.Visible = false
	saim_state.accuracy_text = text
	return text
end

local function update_saim_visuals()
	local circle = ensure_saim_fov_circle()
	local line = ensure_saim_target_line()
	local acc = ensure_saim_accuracy_text()
	local enabled = flags["combat_saim"]
	local mouse_pos = get_mouse_location(user_input_service)
	local cam_pos = camera.CFrame.Position

	local show_fov = (flags["combat_saim"] and flags["combat_saim_show_fov"])
	circle.Visible = show_fov
	if show_fov then
		circle.Position = mouse_pos
		circle.Radius = flags["combat_saim_fov"]
		circle.Color = flags["combat_saim_fov_color"]
		circle.Transparency = 1 - (flags["combat_saim_fov_transparency"] or 0.5)
	end

	local fov = flags["combat_saim_fov"]
	local _, hitpart = get_closest_saim_target(fov)

	local accuracy_label = "0%"
	local accuracy_color = color3_fromrgb(180, 80, 80)
	if hitpart then
		local aim_pos = get_predicted_position(hitpart)
		local blocked = saim_wall_blocked(cam_pos, aim_pos)
		if blocked then
			accuracy_label = "0% wall"
			accuracy_color = color3_fromrgb(220, 160, 40)
		else
			-- estimated hit probability from geometry (not the hitchance slider)
			local screen = camera:WorldToViewportPoint(aim_pos)
			local cross = (Vector2.new(screen.X, screen.Y) - mouse_pos).Magnitude
			local fov_r = math.max(flags["combat_saim_fov"] or 1, 1)
			local center_factor = math.clamp(1 - (cross / fov_r), 0, 1)
			local dist = (aim_pos - cam_pos).Magnitude
			local dist_factor = math.clamp(1 - (dist / math.max(flags["combat_saim_max_distance"] or 1000, 1)), 0.15, 1)
			local chance = math.floor(center_factor * dist_factor * 100 + 0.5)
			accuracy_label = string.format("%d%%", chance)
			if chance >= 70 then
				accuracy_color = color3_fromrgb(80, 220, 120)
			elseif chance >= 35 then
				accuracy_color = color3_fromrgb(220, 200, 60)
			else
				accuracy_color = color3_fromrgb(220, 100, 80)
			end
		end
	end
	saim_state.last_accuracy = accuracy_label

	local show_acc = enabled and flags["combat_saim_show_accuracy"]
	acc.Visible = show_acc
	if show_acc then
		acc.Text = accuracy_label
		acc.Color = accuracy_color
		acc.Position = Vector2.new(mouse_pos.X, mouse_pos.Y + (show_fov and flags["combat_saim_fov"] or 20) + 8)
	end

	local show_line = flags["combat_saim"] and flags["combat_saim_target_line"]
	if not show_line or not hitpart then
		line.Visible = false
		return
	end
	local aim_pos = get_predicted_position(hitpart)
	local screen, on_screen = camera:WorldToViewportPoint(aim_pos)
	if not on_screen or screen.Z <= 0 then
		line.Visible = false
		return
	end

	local from = mouse_pos
	if flags["combat_saim_target_line_from"][1] == "center" then
		local viewport = camera.ViewportSize
		from = Vector2.new(viewport.X / 2, viewport.Y / 2)
	end

	line.Visible = true
	line.From = from
	line.To = Vector2.new(screen.X, screen.Y)
	line.Color = flags["combat_saim_target_line_color"]
	line.Thickness = 1.2
end

local function clip_tracer_to_wall(from_pos, to_pos)
	if not flags["misc_bullet_tracer_wallcheck"] then
		return to_pos
	end
	local dir = to_pos - from_pos
	local dist = dir.Magnitude
	if dist < 0.05 then
		return to_pos
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { local_player.Character, camera }
	params.IgnoreWater = true
	local result = workspace:Raycast(from_pos, dir.Unit * dist, params)
	if result and result.Position then
		return result.Position
	end
	return to_pos
end

local function spawn_bullet_tracer(from_pos, to_pos)
	if not flags["misc_bullet_tracers"] then
		return
	end
	to_pos = clip_tracer_to_wall(from_pos, to_pos)
	local segs = math.clamp(math.floor(flags["misc_bullet_tracer_segments"] or 12), 4, 24)
	local life = flags["misc_bullet_tracer_life"] or 0.55
	local width = flags["misc_bullet_tracer_width"] or 1.8
	local color = flags["misc_bullet_tracer_color"]
	local lines = {}
	for i = 1, segs do
		local line = Drawing.new("Line")
		line.Thickness = width
		line.Color = color
		line.Visible = true
		lines[i] = line
	end
	saim_state.tracers[#saim_state.tracers + 1] = {
		lines = lines,
		from = from_pos,
		to = to_pos,
		born = clock(),
		life = life,
		segs = segs,
		phase = math.random() * 10,
	}
end

local function update_bullet_tracers()
	local now = clock()
	local i = 1
	while i <= #saim_state.tracers do
		local tr = saim_state.tracers[i]
		local age = now - tr.born
		if age >= tr.life then
			for _, line in ipairs(tr.lines) do
				pcall(function()
					line:Remove()
				end)
			end
			table.remove(saim_state.tracers, i)
		else
			local alpha = 1 - (age / tr.life)
			local scroll = (age * 8 + tr.phase) % 1
			local segs = tr.segs
			-- dashed "texture" that scrolls along the beam
			for s = 1, segs do
				local line = tr.lines[s]
				local a0 = ((s - 1) / segs + scroll) % 1
				local a1 = (s / segs + scroll) % 1
				-- only draw "on" dashes (odd segments relative to scroll)
				local dash_on = ((s + math.floor(scroll * segs)) % 2) == 0
				if not dash_on then
					line.Visible = false
				else
					local p0 = tr.from:Lerp(tr.to, a0)
					local p1 = tr.from:Lerp(tr.to, math.min(a0 + (1 / segs) * 0.85, 1))
					-- keep order along beam
					if a1 < a0 then
						p0 = tr.from:Lerp(tr.to, (s - 1) / segs)
						p1 = tr.from:Lerp(tr.to, s / segs)
					end
					local s0, o0 = camera:WorldToViewportPoint(p0)
					local s1, o1 = camera:WorldToViewportPoint(p1)
					if s0.Z > 0 and s1.Z > 0 then
						line.From = Vector2.new(s0.X, s0.Y)
						line.To = Vector2.new(s1.X, s1.Y)
						line.Transparency = 1 - alpha
						line.Thickness = (flags["misc_bullet_tracer_width"] or 1.8) * (0.7 + 0.3 * math.sin(age * 20 + s))
						line.Color = flags["misc_bullet_tracer_color"]
						line.Visible = true
					else
						line.Visible = false
					end
				end
			end
			i += 1
		end
	end
end

local function find_fire_vectors(args)
	local origin_idx, dir_idx
	for i = 1, #args do
		if typeof(args[i]) == "Vector3" then
			if not origin_idx then
				origin_idx = i
			elseif not dir_idx then
				dir_idx = i
				break
			end
		end
	end
	-- fallback to classic indices from Framework Bullets.Fire
	if not origin_idx and typeof(args[4]) == "Vector3" then
		origin_idx = 4
	end
	if not dir_idx and typeof(args[5]) == "Vector3" then
		dir_idx = 5
	end
	return origin_idx, dir_idx
end

local function get_bullets_lib()
	local ok, framework = pcall(function()
		return require(game:GetService("ReplicatedFirst"):FindFirstChild("Framework"))
	end)
	if ok and framework and framework.Libraries and framework.Libraries.Bullets then
		return framework.Libraries.Bullets
	end
	local ok2, libs = pcall(function()
		return require(game:GetService("ReplicatedStorage"):FindFirstChild("Libraries"))
	end)
	if ok2 and libs and libs.Bullets then
		return libs.Bullets
	end
	return nil
end

local function install_saim_hook()
	if saim_state.hooked then
		return true
	end
	local bullets = get_bullets_lib()
	if not bullets or type(bullets.Fire) ~= "function" then
		return false
	end

	-- Origin-style weapon table patch (FireConfig / weaponData in Fire args)
	local function find_weapon_tables(args)
		local weapon_data, fire_config
		for _, a in ipairs(args) do
			if type(a) == "table" then
				if a.FireConfig and type(a.FireConfig) == "table" then
					weapon_data = a
					fire_config = a.FireConfig
				elseif a.MuzzleVelocity or a.BulletSpeed or a.SpreadBase or a.RecoilModifier or a.Penetration then
					fire_config = fire_config or a
				end
			end
		end
		return weapon_data, fire_config
	end

	local function thaw_table(tbl)
		if type(tbl) ~= "table" then
			return false
		end
		local was_frozen = false
		pcall(function()
			if table.isfrozen and table.isfrozen(tbl) then
				was_frozen = true
			end
		end)
		pcall(function()
			if isreadonly and isreadonly(tbl) then
				was_frozen = true
			end
		end)
		if setreadonly then
			pcall(setreadonly, tbl, false)
		end
		-- table.freeze has no official unfreeze; setreadonly is the executor path
		return was_frozen
	end

	local function apply_weapon_mods(weapon_data, fire_config)
		local fc = fire_config or (weapon_data and weapon_data.FireConfig)
		if not fc and not weapon_data then
			return nil
		end
		-- no mods on = skip entirely (guns fire normal)
		if not (flags["weapon_no_recoil"] or flags["weapon_no_spread"] or flags["weapon_wallbang"] or flags["weapon_instabullet"]) then
			return nil
		end
		local saved = {}
		local thawed = {}
		local function ensure_writable(tbl)
			if not tbl or thawed[tbl] then
				return
			end
			thawed[tbl] = true
			thaw_table(tbl)
		end
		local function save_set(tbl, key, val)
			if not tbl then
				return
			end
			ensure_writable(tbl)
			local ok, err = pcall(function()
				local old = tbl[key]
				tbl[key] = val
				saved[#saved + 1] = { tbl, key, old }
			end)
			-- readonly failure is non-fatal; gun still fires
			if not ok then
				return
			end
		end
		if flags["weapon_no_spread"] and fc then
			ensure_writable(fc)
			for _, k in ipairs({ "SpreadBase", "SpreadMin", "SpreadMax", "Spread", "HipSpread", "AimSpread" }) do
				save_set(fc, k, 0)
			end
			if type(fc.SpreadAdd) == "table" then
				ensure_writable(fc.SpreadAdd)
				pcall(function()
					for sk, sv in pairs(fc.SpreadAdd) do
						if type(sv) == "number" then
							save_set(fc.SpreadAdd, sk, 0)
						elseif typeof(sv) == "Vector2" then
							save_set(fc.SpreadAdd, sk, Vector2.zero)
						end
					end
				end)
			end
		end
		if flags["weapon_no_recoil"] and fc then
			ensure_writable(fc)
			for _, k in ipairs({ "Recoil", "RecoilKick", "VerticalRecoil", "HorizontalRecoil" }) do
				save_set(fc, k, 0)
			end
			if type(fc.RecoilModifier) == "table" then
				ensure_writable(fc.RecoilModifier)
				pcall(function()
					local rm = fc.RecoilModifier
					for rk, rv in pairs(rm) do
						if type(rv) == "number" then
							save_set(rm, rk, 0)
						elseif typeof(rv) == "Vector2" or typeof(rv) == "Vector3" then
							save_set(rm, rk, rv * 0)
						end
					end
				end)
			end
		end
		if flags["weapon_wallbang"] then
			for _, tbl in ipairs({ weapon_data, fc }) do
				if type(tbl) == "table" then
					ensure_writable(tbl)
					for _, k in ipairs({
						"Penetration", "PenetrationPower", "WallPenetration", "WallPenetrationPower",
						"PierceCount", "Piercing", "BulletPenetration", "ArmorPenetration", "PenPower",
					}) do
						save_set(tbl, k, 9999)
					end
					save_set(tbl, "CanPenetrate", true)
					save_set(tbl, "PenetrateWalls", true)
				end
			end
		end
		if flags["weapon_instabullet"] and fc then
			ensure_writable(fc)
			local mult = math.clamp(tonumber(flags["weapon_instabullet_mult"]) or 3, 1, 20)
			if type(fc.BulletSpeed) == "number" then
				save_set(fc, "BulletSpeed", fc.BulletSpeed * mult)
			end
			if type(fc.MuzzleVelocity) == "number" then
				save_set(fc, "MuzzleVelocity", fc.MuzzleVelocity * mult)
			end
			if fc.Gravity ~= nil then
				save_set(fc, "Gravity", 0)
			end
			if fc.BulletDrop ~= nil then
				save_set(fc, "BulletDrop", 0)
			end
			if fc.ProjectileGravity ~= nil then
				save_set(fc, "ProjectileGravity", 0)
			end
		end
		return saved
	end

	local function restore_weapon_mods(saved)
		if not saved then
			return
		end
		for i = #saved, 1, -1 do
			local e = saved[i]
			pcall(function()
				if setreadonly then
					pcall(setreadonly, e[1], false)
				end
				e[1][e[2]] = e[3]
			end)
		end
	end

	local old_fire
	old_fire = hookfunction(bullets.Fire, function(self, ...)
		local args = { ... }
		local saim_on = flags["combat_saim"]
		local tracers_on = flags["misc_bullet_tracers"]
		local weapon_data, fire_config = find_weapon_tables(args)
		local saved_mods = apply_weapon_mods(weapon_data, fire_config)

		-- prefer classic Framework layout, then scan
		local origin_idx, dir_idx = 4, 5
		local origin = args[4]
		local direction = args[5]
		if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
			origin_idx, dir_idx = find_fire_vectors(args)
			origin = origin_idx and args[origin_idx]
			direction = dir_idx and args[dir_idx]
		end

		local function finish(...)
			restore_weapon_mods(saved_mods)
			return ...
		end

		if flags["weapon_magic_bullet"] and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
			local ok_m, mpart = pcall(function()
				local _, hp = get_closest_saim_target(flags["combat_saim_fov"] or 250)
				return hp
			end)
			if ok_m and mpart then
				local aim_pos = get_predicted_position(mpart)
				local bend = aim_pos - origin
				if bend.Magnitude > 0.001 then
					local angle = math.deg(math.acos(math.clamp(bend.Unit:Dot(direction.Unit), -1, 1)))
					local max_bend = tonumber(flags["weapon_magic_max_bend"]) or 45
					if angle <= max_bend then
						local unit = bend.Unit
						if dir_idx then args[dir_idx] = unit end
						args[5] = unit
						direction = unit
					end
				end
			end
		end
		if not saim_on then
			if tracers_on and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
				spawn_bullet_tracer(origin, origin + direction.Unit * 400)
			end
			return finish(old_fire(self, unpack(args)))
		end

		if typeof(origin) ~= "Vector3" then
			return finish(old_fire(self, unpack(args)))
		end

		local ok_t, hitpart = pcall(function()
			local _, hp = get_closest_saim_target(flags["combat_saim_fov"])
			return hp
		end)
		if ok_t and hitpart then
			local aim_pos = get_predicted_position(hitpart)
			local preferred = (flags["combat_saim_hitpart"] and flags["combat_saim_hitpart"][1]) or "Head"
			local parent = hitpart.Parent
			local part = parent and parent:FindFirstChild(preferred)
			if part and part:IsA("BasePart") then
				aim_pos = get_predicted_position(part)
			end
			local dir = aim_pos - origin
			if dir.Magnitude > 0.001 then
				local unit = dir.Unit
				if dir_idx then
					args[dir_idx] = unit
				end
				args[5] = unit
			end
			if tracers_on then
				pcall(spawn_bullet_tracer, origin, aim_pos)
			end
			return finish(old_fire(self, unpack(args)))
		end

		if tracers_on and typeof(direction) == "Vector3" then
			pcall(spawn_bullet_tracer, origin, origin + direction.Unit * 400)
		end
		return finish(old_fire(self, unpack(args)))
	end)
	saim_state.old_fire = old_fire
	saim_state.hooked = true
	return true
end

local function restore_manual_yaw_humanoid()
	local character = local_player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and saim_state.autorotate_cached ~= nil then
		humanoid.AutoRotate = saim_state.autorotate_cached
		saim_state.autorotate_cached = nil
	end
end

-- manual left = +90° static yaw, manual right = -90° static yaw (camera-relative, pitch 0)
local function apply_saim_manual_yaw()
	local left = flags["combat_saim_manual_left"]
	local right = flags["combat_saim_manual_right"]
	if not flags["combat_saim"] or (not left and not right) then
		if saim_state.autospin_active then
			restore_manual_yaw_humanoid()
			saim_state.autospin_active = false
		end
		return
	end

	local character = local_player.Character
	if not character then
		saim_state.autospin_active = false
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		saim_state.autospin_active = false
		return
	end

	if saim_state.autorotate_cached == nil then
		saim_state.autorotate_cached = humanoid.AutoRotate
	end
	humanoid.AutoRotate = false

	local look = camera.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.05 then
		flat = Vector3.new(0, 0, -1)
	else
		flat = flat.Unit
	end
	local yaw_deg = left and 90 or -90
	local pos = root.Position
	if pos.Magnitude > 1e6 or pos ~= pos then
		return
	end
	local base = CFrame.lookAt(pos, pos + flat)
	root.CFrame = base * CFrame.Angles(0, math.rad(yaw_deg), 0)
	saim_state.autospin_active = true
end

local trigger_state = {
	loop = nil,
	last_fire = 0,
}

local function trigger_click()
	if mouse1click then
		pcall(mouse1click)
		return
	end
	if mouse1press and mouse1release then
		pcall(mouse1press)
		task.delay(0.02, function()
			pcall(mouse1release)
		end)
		return
	end
	pcall(function()
		local vim = game:GetService("VirtualInputManager")
		vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
		task.delay(0.02, function()
			vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
		end)
	end)
end

local function get_trigger_target()
	local mouse_pos = get_mouse_location(user_input_service)
	local cam_pos = camera.CFrame.Position
	local closest_part
	local best = flags["combat_trigger_fov"] or 25

	local function consider(model)
		if not model or model == local_player.Character then
			return
		end
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= 0 then
			return
		end
		if flags["combat_trigger_team_check"] then
			local player = players_service:GetPlayerFromCharacter(model)
			if player and local_player.Team and player.Team == local_player.Team then
				return
			end
		end
		local preferred = flags["combat_trigger_hitpart"][1] or "Head"
		local part = model:FindFirstChild(preferred) or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
		if not part or not part:IsA("BasePart") then
			return
		end
		local screen, on_screen = camera:WorldToViewportPoint(part.Position)
		if not on_screen or screen.Z <= 0 then
			return
		end
		local dist = (Vector2.new(screen.X, screen.Y) - mouse_pos).Magnitude
		if dist > best then
			return
		end
		if flags["combat_trigger_wallcheck"] then
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { local_player.Character, camera }
			params.IgnoreWater = true
			local dir = part.Position - cam_pos
			local result = workspace:Raycast(cam_pos, dir.Unit * dir.Magnitude, params)
			if result then
				local hit_model = result.Instance:FindFirstAncestorOfClass("Model")
				if hit_model ~= model then
					return
				end
			end
		end
		best = dist
		closest_part = part
	end

	if flags["combat_trigger_players"] then
		local characters = workspace:FindFirstChild("Characters")
		if characters then
			for _, model in ipairs(characters:GetChildren()) do
				if model:IsA("Model") then
					consider(model)
				end
			end
		else
			for _, player in ipairs(players_service:GetPlayers()) do
				if player ~= local_player and player.Character then
					consider(player.Character)
				end
			end
		end
	end
	if flags["combat_trigger_zombies"] then
		local zombies = workspace:FindFirstChild("Zombies") or workspace:FindFirstChild("zombies")
		if zombies then
			for _, model in ipairs(zombies:GetChildren()) do
				if model:IsA("Model") then
					consider(model)
				end
			end
		end
	end
	return closest_part
end

local function update_triggerbot()
	if not flags["combat_trigger"] then
		return
	end
	local delay = flags["combat_trigger_delay"] or 0.05
	if clock() - trigger_state.last_fire < delay then
		return
	end
	local part = get_trigger_target()
	if part then
		trigger_state.last_fire = clock()
		trigger_click()
	end
end

local function watch_triggerbot()
	if trigger_state.loop then
		return
	end
	trigger_state.loop = run_service.Heartbeat:Connect(function()
		update_triggerbot()
	end)
	connections[#connections + 1] = trigger_state.loop
end

local function watch_saim()
	if saim_state.loop then
		return
	end
	install_saim_hook()
	saim_state.loop = run_service.Heartbeat:Connect(function()
		update_saim_visuals()
		update_bullet_tracers()
		local gun_mods_on = flags["weapon_no_recoil"] or flags["weapon_no_spread"] or flags["weapon_wallbang"] or flags["weapon_instabullet"]
		if (flags["combat_saim"] or flags["misc_bullet_tracers"] or gun_mods_on) and not saim_state.hooked then
			install_saim_hook()
		end
		if not flags["combat_saim"] then
			saim_state.sticky_model = nil
			saim_state.sticky_part = nil
			if saim_state.autospin_active then
				restore_manual_yaw_humanoid()
				saim_state.autospin_active = false
			end
		end
	end)
	connections[#connections + 1] = saim_state.loop
	-- RenderStepped so orientation is re-applied after tool/character scripts
	if not saim_state.spin_loop then
		saim_state.spin_loop = run_service.RenderStepped:Connect(function()
			apply_saim_manual_yaw()
		end)
		connections[#connections + 1] = saim_state.spin_loop
	end
end


-- > ( combat / aimbot )

local aimbot_state = {
	fov_circle = nil,
	target_line = nil,
	loop = nil,
	sticky_model = nil,
	sticky_part = nil,
}

local function get_aimbot_hitpart(model)
	local preferred = flags["combat_aimbot_hitpart"][1] or "Head"
	local part = model:FindFirstChild(preferred)
	if part and part:IsA("BasePart") then
		return part
	end
	for _, name in ipairs({ "Head", "HumanoidRootPart", "UpperTorso", "Torso" }) do
		part = model:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

local function aimbot_wall_blocked(origin, target_pos)
	local direction = target_pos - origin
	local distance = direction.Magnitude
	if distance < 0.1 then
		return false
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { local_player.Character, camera }
	params.IgnoreWater = true
	local result = workspace:Raycast(origin, direction.Unit * distance, params)
	if not result or not result.Instance then
		return false
	end
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	if model and (model:FindFirstChildOfClass("Humanoid") or model:FindFirstChild("HumanoidRootPart")) then
		return false
	end
	return true
end

local function get_aimbot_predicted(part)
	local pos = part.Position
	if not flags["combat_aimbot_prediction"] then
		return pos
	end
	local velocity = part.AssemblyLinearVelocity
	if velocity.Magnitude < 0.05 then
		return pos
	end
	return pos + velocity * flags["combat_aimbot_prediction_factor"]
end

local function get_closest_aimbot_target(radius)
	local closest_model, closest_part
	local best_score = math.huge
	local mouse_pos = get_mouse_location(user_input_service)
	local cam_pos = camera.CFrame.Position
	local priority = flags["combat_aimbot_priority"][1] or "crosshair"

	if flags["combat_aimbot_sticky"] and aimbot_state.sticky_model and aimbot_state.sticky_model.Parent and aimbot_state.sticky_part and aimbot_state.sticky_part.Parent then
		local sticky_hum = aimbot_state.sticky_model:FindFirstChildOfClass("Humanoid")
		if sticky_hum and sticky_hum.Health > 0 then
			local screen = camera:WorldToViewportPoint(aimbot_state.sticky_part.Position)
			if screen.Z > 0 then
				local dist = (Vector2.new(screen.X, screen.Y) - mouse_pos).Magnitude
				if dist <= (radius or math.huge) then
					return aimbot_state.sticky_model, aimbot_state.sticky_part
				end
			end
		end
		aimbot_state.sticky_model = nil
		aimbot_state.sticky_part = nil
	end

	local function consider(model)
		if not model or model == local_player.Character then
			return
		end
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= 0 then
			return
		end
		if flags["combat_aimbot_team_check"] then
			local player = players_service:GetPlayerFromCharacter(model)
			if player and local_player.Team and player.Team == local_player.Team then
				return
			end
		end
		local hitpart = get_aimbot_hitpart(model)
		if not hitpart then
			return
		end
		local world_pos = get_aimbot_predicted(hitpart)
		local world_distance = (world_pos - cam_pos).Magnitude
		if world_distance > flags["combat_aimbot_max_distance"] then
			return
		end
		local screen, on_screen = camera:WorldToViewportPoint(world_pos)
		if flags["combat_aimbot_visible_only"] and not on_screen then
			return
		end
		if screen.Z <= 0 then
			return
		end
		local crosshair_dist = (Vector2.new(screen.X, screen.Y) - mouse_pos).Magnitude
		if crosshair_dist > (radius or math.huge) then
			return
		end
		if flags["combat_aimbot_wallcheck"] and aimbot_wall_blocked(cam_pos, world_pos) then
			return
		end

		local score
		if priority == "distance" then
			score = world_distance
		elseif priority == "health" then
			score = humanoid and humanoid.Health or 100
		else
			score = crosshair_dist
		end

		if score < best_score then
			best_score = score
			closest_model = model
			closest_part = hitpart
		end
	end

	if flags["combat_aimbot_players"] then
		local characters = workspace:FindFirstChild("Characters")
		if characters then
			for _, model in ipairs(characters:GetChildren()) do
				if model:IsA("Model") then
					consider(model)
				end
			end
		else
			for _, player in ipairs(players_service:GetPlayers()) do
				if player ~= local_player and player.Character then
					consider(player.Character)
				end
			end
		end
	end

	if flags["combat_aimbot_zombies"] then
		local zombies = workspace:FindFirstChild("Zombies") or workspace:FindFirstChild("zombies")
		if zombies then
			for _, model in ipairs(zombies:GetChildren()) do
				if model:IsA("Model") then
					consider(model)
				end
			end
		end
	end

	if closest_model and flags["combat_aimbot_sticky"] then
		aimbot_state.sticky_model = closest_model
		aimbot_state.sticky_part = closest_part
	end

	return closest_model, closest_part
end

local function ensure_aimbot_fov_circle()
	if aimbot_state.fov_circle then
		return aimbot_state.fov_circle
	end
	local circle = Drawing.new("Circle")
	circle.Filled = false
	circle.Thickness = 1.2
	circle.NumSides = 64
	circle.Visible = false
	aimbot_state.fov_circle = circle
	return circle
end

local function ensure_aimbot_target_line()
	if aimbot_state.target_line then
		return aimbot_state.target_line
	end
	local line = Drawing.new("Line")
	line.Thickness = 1.2
	line.Visible = false
	aimbot_state.target_line = line
	return line
end

local function aimbot_look_at(target_pos)
	local method = flags["combat_aimbot_method"][1] or "camera"
	local cam_cf = camera.CFrame
	local desired = CFrame.new(cam_cf.Position, target_pos)

	if flags["combat_aimbot_instant"] then
		if method == "mouse" and mousemoverel then
			local screen = camera:WorldToViewportPoint(target_pos)
			local mouse_pos = get_mouse_location(user_input_service)
			mousemoverel(screen.X - mouse_pos.X, screen.Y - mouse_pos.Y)
		else
			camera.CFrame = desired
		end
		return
	end

	local smooth = math.max(flags["combat_aimbot_smooth"] or 1, 1)
	local alpha = math.clamp(1 / smooth, 0.01, 1)

	if method == "mouse" and mousemoverel then
		local screen = camera:WorldToViewportPoint(target_pos)
		local mouse_pos = get_mouse_location(user_input_service)
		local dx = (screen.X - mouse_pos.X) * alpha
		local dy = (screen.Y - mouse_pos.Y) * alpha
		mousemoverel(dx, dy)
	else
		camera.CFrame = cam_cf:Lerp(desired, alpha)
	end
end

local function update_aimbot()
	local enabled = flags["combat_aimbot"]
	local circle = ensure_aimbot_fov_circle()
	local line = ensure_aimbot_target_line()
	local mouse_pos = get_mouse_location(user_input_service)

	local show_fov = enabled and flags["combat_aimbot_show_fov"]
	circle.Visible = show_fov
	if show_fov then
		circle.Position = mouse_pos
		circle.Radius = flags["combat_aimbot_fov"]
		circle.Color = flags["combat_aimbot_fov_color"]
		circle.Transparency = 1 - (flags["combat_aimbot_fov_transparency"] or 0.5)
	end

	if not enabled then
		line.Visible = false
		aimbot_state.sticky_model = nil
		aimbot_state.sticky_part = nil
		return
	end

	local _, hitpart = get_closest_aimbot_target(flags["combat_aimbot_fov"])
	if not hitpart then
		line.Visible = false
		return
	end

	local aim_pos = get_aimbot_predicted(hitpart)
	aimbot_look_at(aim_pos)

	if flags["combat_aimbot_target_line"] then
		local screen, on_screen = camera:WorldToViewportPoint(aim_pos)
		if on_screen and screen.Z > 0 then
			local from = mouse_pos
			if flags["combat_aimbot_target_line_from"][1] == "center" then
				local viewport = camera.ViewportSize
				from = Vector2.new(viewport.X / 2, viewport.Y / 2)
			end
			line.Visible = true
			line.From = from
			line.To = Vector2.new(screen.X, screen.Y)
			line.Color = flags["combat_aimbot_target_line_color"]
		else
			line.Visible = false
		end
	else
		line.Visible = false
	end
end

local function watch_aimbot()
	if aimbot_state.loop then
		return
	end
	aimbot_state.loop = run_service.RenderStepped:Connect(function()
		update_aimbot()
	end)
	connections[#connections + 1] = aimbot_state.loop
end


-- > ( misc / antiaim )

local aa_state = {
	loop = nil,
	base_yaw = 0,
	waist_c0 = nil,
	neck_c0 = nil,
	tracked_char = nil,
}

local function aa_cache_motors(character)
	if aa_state.tracked_char == character and aa_state.waist_c0 then
		return
	end
	aa_state.tracked_char = character
	aa_state.waist_c0 = nil
	aa_state.neck_c0 = nil
	local upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if upper then
		local waist = upper:FindFirstChild("Waist")
		if waist and waist:IsA("Motor6D") then
			aa_state.waist_c0 = waist.C0
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		local neck = head:FindFirstChild("Neck")
		if neck and neck:IsA("Motor6D") then
			aa_state.neck_c0 = neck.C0
		elseif upper then
			local neck2 = upper:FindFirstChild("Neck")
			if neck2 and neck2:IsA("Motor6D") then
				aa_state.neck_c0 = neck2.C0
			end
		end
	end
end

local function apply_antiaim()
	local character = local_player.Character
	if saim_state.autospin_active then
		return
	end
	if not flags["aa_enabled"] then
		if character and aa_state.tracked_char == character then
			local upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
			if upper and aa_state.waist_c0 then
				local waist = upper:FindFirstChild("Waist")
				if waist and waist:IsA("Motor6D") then
					waist.C0 = aa_state.waist_c0
				end
			end
			if aa_state.neck_c0 then
				local head = character:FindFirstChild("Head")
				local neck = head and head:FindFirstChild("Neck")
				if not neck and upper then
					neck = upper:FindFirstChild("Neck")
				end
				if neck and neck:IsA("Motor6D") then
					neck.C0 = aa_state.neck_c0
				end
			end
		end
		return
	end
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end

	aa_cache_motors(character)

	local mode = flags["aa_mode"][1] or "spin"
	local yaw = flags["aa_yaw"] or 0
	local pitch = math.clamp(flags["aa_pitch"] or 0, -89, 89)
	local invert = flags["aa_invert"]

	if mode == "spin" then
		aa_state.base_yaw = (aa_state.base_yaw + (flags["aa_spin_speed"] or 180) * 0.016) % 360
		yaw = aa_state.base_yaw
	elseif mode == "jitter" then
		local range = flags["aa_jitter_range"] or 45
		yaw = yaw + (math.random() * 2 - 1) * range
	elseif mode == "invert" then
		yaw = yaw + 180
	end

	if invert and mode ~= "invert" then
		yaw = yaw + 180
	end

	local look = camera.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.05 then
		flat = Vector3.new(0, 0, -1)
	else
		flat = flat.Unit
	end
	local pos = root.Position
	local base = CFrame.lookAt(pos, pos + flat)
	root.CFrame = base * CFrame.Angles(0, math.rad(yaw), 0)

	local pitch_cf = CFrame.Angles(math.rad(pitch), 0, 0)
	local upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if upper and aa_state.waist_c0 then
		local waist = upper:FindFirstChild("Waist")
		if waist and waist:IsA("Motor6D") then
			waist.C0 = aa_state.waist_c0 * pitch_cf
		end
	end
	if aa_state.neck_c0 then
		local head = character:FindFirstChild("Head")
		local neck = head and head:FindFirstChild("Neck")
		if not neck and upper then
			neck = upper:FindFirstChild("Neck")
		end
		if neck and neck:IsA("Motor6D") then
			neck.C0 = aa_state.neck_c0 * pitch_cf
		end
	end
end


-- > ( misc / movement )

local movement_state = {
	car_tp_dash_last = 0,
	loop = nil,
	speedo = nil,
	was_flying = false,
	framework = nil,
	classes = nil,
}

-- weak-key cache of original vehicle Physics tables
local vehicle_originals = setmetatable({}, { __mode = "k" })

local function get_framework_classes()
	if movement_state.classes then
		return movement_state.classes
	end
	local ok, fw = pcall(function()
		local mod = game:GetService("ReplicatedFirst"):FindFirstChild("Framework")
		if mod then
			return require(mod)
		end
		return nil
	end)
	if ok and fw and fw.Classes then
		movement_state.framework = fw
		movement_state.classes = fw.Classes
		return fw.Classes
	end
	return nil
end

-- Framework character controller table
local function get_controller()
	local classes = get_framework_classes()
	if not (classes and classes.Players and classes.Players.LocalPlayer) then
		return nil
	end
	local ctrl = classes.Players.LocalPlayer.Character
	return type(ctrl) == "table" and ctrl or nil
end

-- resolve driven vehicle model (SeatPart is ground truth; ctrl.Vehicle is often nil)
local function get_driven_vehicle_model()
	local character = local_player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	local container = workspace:FindFirstChild("Vehicles") or workspace:FindFirstChild("vehicles")
	if seat and container then
		local node = seat
		while node and node.Parent do
			if node.Parent == container then
				return node
			end
			node = node.Parent
		end
	end
	local model = seat and seat:FindFirstAncestorOfClass("Model")
	if not model then
		local ctrl = get_controller()
		model = ctrl and ctrl.Vehicle or nil
	end
	if typeof(model) ~= "Instance" then
		return nil
	end
	return model
end

local function get_driven_vehicle()
	local model = get_driven_vehicle_model()
	if not model then
		return nil, nil, nil
	end
	local vroot = model.PrimaryPart
		or model:FindFirstChild("Chassis")
		or model:FindFirstChild("Body")
		or model:FindFirstChildWhichIsA("BasePart")
	return model, vroot, nil
end

-- Origin path: model.Config ModuleScript is the real physics/fuel/health table
local function get_vehicle_config(model)
	model = model or get_driven_vehicle_model()
	if not model then
		return nil, nil
	end
	local mod = model:FindFirstChild("Config")
	if mod and mod:IsA("ModuleScript") then
		local ok, tbl = pcall(require, mod)
		if ok and type(tbl) == "table" then
			return tbl, model
		end
	end
	local classes = get_framework_classes()
	if classes and classes.VehicleControler and classes.VehicleControler.get then
		local ok, vc = pcall(classes.VehicleControler.get, model)
		if ok and type(vc) == "table" then
			local cfg = vc.Config or vc
			if type(cfg) == "table" then
				return cfg, model
			end
		end
	end
	return nil, model
end

local function get_vehicle_controller()
	local cfg, model = get_vehicle_config()
	if not cfg then
		return nil
	end
	return { Config = cfg, Instance = model }
end

local function snapshot_vehicle_physics(P)
	local orig = vehicle_originals[P]
	if orig then
		return orig
	end
	orig = {
		DriveSpeed = P.DriveSpeed,
		ReverseSpeed = P.ReverseSpeed,
		ThrottleResponce = P.ThrottleResponce,
		FullSteeringUntil = P.FullSteeringUntil,
		NoSteeringAfter = P.NoSteeringAfter,
		MaterialGripFriction = {},
	}
	if type(P.MaterialGrip) == "table" then
		for surface, g in pairs(P.MaterialGrip) do
			if type(g) == "table" and tonumber(g.Friction) then
				orig.MaterialGripFriction[surface] = g.Friction
			end
		end
	end
	vehicle_originals[P] = orig
	return orig
end

-- vehicle physics mods: speed / grip / steering each independent
local function apply_vehicle_mods()
	local vc = get_vehicle_controller()
	if not vc then
		return false
	end
	local cfg = vc.Config
	local P = cfg and cfg.Physics
	if type(P) ~= "table" then
		return false
	end
	-- Config modules are often frozen
	pcall(function()
		if setreadonly then
			setreadonly(cfg, false)
			setreadonly(P, false)
		end
	end)
	local orig = snapshot_vehicle_physics(P)
	local speed_m = flags["misc_carspeed"] and math.clamp(tonumber(flags["misc_carspeed_mult"]) or 1.5, 1, 5) or 1
	local grip_m = flags["misc_cargrip"] and math.clamp(tonumber(flags["misc_cargrip_mult"]) or 1.5, 1, 5) or 1
	local steer_m = flags["misc_carsteer"] and math.clamp(tonumber(flags["misc_carsteer_mult"]) or 1.0, 0.25, 3) or 1
	pcall(function()
		P.DriveSpeed = orig.DriveSpeed * speed_m
		P.ReverseSpeed = orig.ReverseSpeed * speed_m
		P.ThrottleResponce = orig.ThrottleResponce * math.max(1, speed_m)
		if type(P.MaterialGrip) == "table" then
			for surface, f in pairs(orig.MaterialGripFriction) do
				local g = P.MaterialGrip[surface]
				if type(g) == "table" then
					g.Friction = f * grip_m
				end
			end
		end
		P.FullSteeringUntil = orig.FullSteeringUntil * steer_m
		P.NoSteeringAfter = orig.NoSteeringAfter * steer_m
	end)
	return true
end

local function restore_vehicle_configs()
	for P, orig in pairs(vehicle_originals) do
		pcall(function()
			P.DriveSpeed = orig.DriveSpeed
			P.ReverseSpeed = orig.ReverseSpeed
			P.ThrottleResponce = orig.ThrottleResponce
			P.FullSteeringUntil = orig.FullSteeringUntil
			P.NoSteeringAfter = orig.NoSteeringAfter
			if type(P.MaterialGrip) == "table" and type(orig.MaterialGripFriction) == "table" then
				for surface, f in pairs(orig.MaterialGripFriction) do
					local g = P.MaterialGrip[surface]
					if type(g) == "table" then
						g.Friction = f
					end
				end
			end
		end)
	end
end

local function ensure_speedometer()
	if movement_state.speedo then
		return movement_state.speedo
	end
	local t = Drawing.new("Text")
	t.Size = 18
	t.Font = 2
	t.Center = true
	t.Outline = true
	t.Color = Color3.fromRGB(154, 213, 222)
	t.Visible = false
	movement_state.speedo = t
	return t
end

local function get_move_keys()
	local uis = user_input_service
	local forward = 0
	local right = 0
	local up = 0
	if uis:IsKeyDown(Enum.KeyCode.W) then forward += 1 end
	if uis:IsKeyDown(Enum.KeyCode.S) then forward -= 1 end
	if uis:IsKeyDown(Enum.KeyCode.D) then right += 1 end
	if uis:IsKeyDown(Enum.KeyCode.A) then right -= 1 end
	if uis:IsKeyDown(Enum.KeyCode.Space) then up += 1 end
	if uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.C) then up -= 1 end
	return forward, right, up
end

local function flat_camera_axes()
	local look = camera.CFrame.LookVector
	local right_v = camera.CFrame.RightVector
	local flat_look = Vector3.new(look.X, 0, look.Z)
	if flat_look.Magnitude > 0.05 then
		flat_look = flat_look.Unit
	else
		flat_look = Vector3.new(0, 0, -1)
	end
	local flat_right = Vector3.new(right_v.X, 0, right_v.Z)
	if flat_right.Magnitude > 0.05 then
		flat_right = flat_right.Unit
	else
		flat_right = Vector3.new(1, 0, 0)
	end
	return flat_look, flat_right
end


--# HBE / magic / movement extras (Origin ports)
local hbe_state = {
	parts = {},
	folder = nil,
	loop = nil,
}
local spin_state = {
	joint = nil,
	base_c0 = nil,
	angle = 0,
}

local function get_hbe_folder()
	if hbe_state.folder and hbe_state.folder.Parent then
		return hbe_state.folder
	end
	local f = Instance.new("Folder")
	f.Name = "juju_hbe"
	f.Parent = workspace
	hbe_state.folder = f
	return f
end

local function hbe_clear()
	for model, part in pairs(hbe_state.parts) do
		pcall(function()
			if part and part.Parent then
				part:Destroy()
			end
		end)
		hbe_state.parts[model] = nil
	end
	if hbe_state.folder then
		pcall(function()
			hbe_state.folder:Destroy()
		end)
		hbe_state.folder = nil
	end
end

local function hbe_add(model)
	if hbe_state.parts[model] then
		return
	end
	if model == local_player.Character then
		return
	end
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end
	local size = math.clamp(tonumber(flags["weapon_hbe_size"]) or 3, 1, 5)
	local v = Instance.new("Part")
	v.Name = "juju_hbe_head"
	v.Size = Vector3.new(size, size, size)
	v.Transparency = 1
	v.CanCollide = false
	v.CanTouch = false
	v.CanQuery = true
	v.Massless = true
	v.Anchored = true
	v.CastShadow = false
	v.CFrame = head.CFrame
	v.Parent = get_hbe_folder()
	hbe_state.parts[model] = v
end

local function update_hbe()
	if not flags["weapon_hbe"] then
		hbe_clear()
		return
	end
	local folder = workspace:FindFirstChild("Characters")
	if not folder then
		return
	end
	local size = math.clamp(tonumber(flags["weapon_hbe_size"]) or 3, 1, 5)
	local seen = {}
	for _, model in ipairs(folder:GetChildren()) do
		if model:IsA("Model") and model ~= local_player.Character then
			seen[model] = true
			hbe_add(model)
			local v = hbe_state.parts[model]
			local head = model:FindFirstChild("Head")
			if v and head then
				v.Size = Vector3.new(size, size, size)
				v.CFrame = head.CFrame
			end
		end
	end
	for model, v in pairs(hbe_state.parts) do
		if not seen[model] then
			pcall(function()
				v:Destroy()
			end)
			hbe_state.parts[model] = nil
		end
	end
end

local function apply_spinbot(dt)
	if not flags["misc_spinbot"] then
		if spin_state.joint and spin_state.base_c0 then
			pcall(function()
				spin_state.joint.C0 = spin_state.base_c0
			end)
		end
		spin_state.joint = nil
		spin_state.base_c0 = nil
		spin_state.angle = 0
		return
	end
	local char = local_player.Character
	if not char then
		return
	end
	if not spin_state.joint or not spin_state.joint.Parent then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local joint = hrp and hrp:FindFirstChild("RootJoint")
		if joint and joint:IsA("Motor6D") then
			spin_state.joint = joint
			spin_state.base_c0 = joint.C0
		else
			return
		end
	end
	local speed = tonumber(flags["misc_spinbot_speed"]) or 20
	spin_state.angle = (spin_state.angle + speed * (dt or 0.016)) % (math.pi * 2)
	local cf = CFrame.Angles(0, spin_state.angle, 0)
	if flags["misc_spinbot_tilt"] then
		cf = cf * CFrame.Angles(math.rad(25) * math.sin(spin_state.angle * 2), 0, 0)
	end
	pcall(function()
		spin_state.joint.C0 = spin_state.base_c0 * cf
	end)
end

local function apply_bhop()
	if not flags["misc_bhop"] then
		return
	end
	local char = local_player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then
		return
	end
	local moving = user_input_service:IsKeyDown(Enum.KeyCode.W)
		or user_input_service:IsKeyDown(Enum.KeyCode.A)
		or user_input_service:IsKeyDown(Enum.KeyCode.S)
		or user_input_service:IsKeyDown(Enum.KeyCode.D)
	if moving and hum.FloorMaterial ~= Enum.Material.Air then
		local h = math.clamp(tonumber(flags["misc_bhop_height"]) or 15, 5, 40)
		local v = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(v.X, h * 3, v.Z)
	end
end

local function apply_anti_fall(humanoid)
	if not flags["misc_anti_fall"] or not humanoid then
		return
	end
	pcall(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		local st = humanoid:GetState()
		if st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
	-- Framework character controller fields if present
	pcall(function()
		if Classes and Classes.Players and Classes.Players.LocalPlayer then
			local gc = Classes.Players.LocalPlayer.Character
			if type(gc) == "table" then
				if rawget(gc, "FallImpacting") ~= nil then
					rawset(gc, "FallImpacting", false)
				end
				if rawget(gc, "Staggered") ~= nil then
					rawset(gc, "Staggered", false)
				end
				if type(rawget(gc, "RagdollTimer")) == "number" then
					rawset(gc, "RagdollTimer", 0)
				end
			end
		end
	end)
end

local function apply_spoof_state(humanoid)
	if not flags["misc_spoof_state"] or not humanoid then
		return
	end
	local name = (flags["misc_spoof_state_as"] and flags["misc_spoof_state_as"][1]) or "Running"
	local map = {
		Running = Enum.HumanoidStateType.Running,
		Falling = Enum.HumanoidStateType.Freefall,
		Jumping = Enum.HumanoidStateType.Jumping,
		Landed = Enum.HumanoidStateType.Landed,
		Seated = Enum.HumanoidStateType.Seated,
	}
	local st = map[name] or Enum.HumanoidStateType.Running
	pcall(function()
		humanoid:ChangeState(st)
	end)
end

local function apply_vehicle_extra_mods()
	local vc = get_vehicle_controller()
	if not vc then
		return
	end
	local cfg = vc.Config
	local P = cfg and cfg.Physics
	pcall(function()
		if setreadonly and type(cfg) == "table" then
			setreadonly(cfg, false)
			if type(P) == "table" then setreadonly(P, false) end
			if type(cfg.Fuel) == "table" then setreadonly(cfg.Fuel, false) end
			if type(cfg.Health) == "table" then setreadonly(cfg.Health, false) end
		end
	end)
	if type(P) ~= "table" and not (cfg and type(cfg) == "table") then
		return
	end
	-- infinite fuel
	if flags["misc_car_fuel"] and type(cfg) == "table" and type(cfg.Fuel) == "table" then
		pcall(function()
			cfg.Fuel.BurnRate = 0
			cfg.Fuel.ConsumptionRate = 0
		end)
	end
	-- god: zero all DamageModifiers under Health
	if flags["misc_car_god"] and type(cfg) == "table" and type(cfg.Health) == "table" then
		local function zero_dmg(t)
			if type(t) ~= "table" then return end
			if type(t.DamageModifiers) == "table" then
				for k in pairs(t.DamageModifiers) do
					t.DamageModifiers[k] = 0
				end
			else
				for _, v in pairs(t) do
					zero_dmg(v)
				end
			end
		end
		pcall(zero_dmg, cfg.Health)
	end
	-- boost: absolute drive speed + torque mult
	if flags["misc_car_boost"] and type(P) == "table" then
		local spd = math.clamp(tonumber(flags["misc_car_boost_speed"]) or 120, 20, 300)
		local tq = math.clamp(tonumber(flags["misc_car_torque"]) or 3, 1, 10)
		pcall(function()
			P.DriveSpeed = spd
			P.ReverseSpeed = math.floor(spd * 0.4)
			if type(P.Wheels) == "table" then
				for _, wheel in pairs(P.Wheels) do
					if type(wheel) == "table" and type(wheel.Shock) == "table" and wheel.Shock.DriveMotorTorque then
						wheel.Shock.DriveMotorTorque = (wheel.Shock.DriveMotorTorque or 1) * tq
					end
				end
			end
			if type(cfg.ExitDamage) == "table" then
				cfg.ExitDamage.MaxSpeed = 99999
			end
		end)
	end
	-- max traction
	if flags["misc_car_max_traction"] and type(P) == "table" and type(P.MaterialGrip) == "table" then
		pcall(function()
			for _, mat in pairs(P.MaterialGrip) do
				if type(mat) == "table" then
					if mat.Speed ~= nil then mat.Speed = 1 end
					if mat.Friction ~= nil then mat.Friction = 1 end
				end
			end
		end)
	end
	if type(P) ~= "table" then
		return
	end
	if flags["misc_car_remove_drag"] then
		pcall(function()
			if type(P.MaterialGrip) == "table" then
				for _, mat in pairs(P.MaterialGrip) do
					if type(mat) == "table" then
						if mat.Speed ~= nil then
							mat.Speed = 1
						end
						if mat.Friction ~= nil then
							mat.Friction = math.max(mat.Friction or 1, 1)
						end
					end
				end
			end
			if type(P.Wheels) == "table" then
				for _, wheel in pairs(P.Wheels) do
					if type(wheel) == "table" then
						if wheel.Elasticity ~= nil then
							wheel.Elasticity = 0
						end
						if wheel.Friction ~= nil then
							wheel.Friction = 1
						end
					end
				end
			end
		end)
	end
	if flags["misc_car_full_steer"] then
		pcall(function()
			if P.FullSteeringUntil ~= nil then
				P.FullSteeringUntil = 999
			end
			if P.NoSteeringAfter ~= nil then
				P.NoSteeringAfter = 9999
			end
			if P.SteerResponce ~= nil then
				P.SteerResponce = 1
			end
			if type(P.Wheels) == "table" then
				for _, wheel in pairs(P.Wheels) do
					if type(wheel) == "table" and wheel.SteerAngle ~= nil then
						wheel.SteerAngle = math.max(wheel.SteerAngle or 30, 45)
					end
				end
			end
		end)
	end
	if flags["misc_car_boat"] then
		pcall(function()
			local water = workspace:FindFirstChild("Water")
				or (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Water"))
			if water then
				for _, part in ipairs(water:GetDescendants()) do
					if part:IsA("BasePart") then
						if part:HasTag("Swim Surface") then
							part:RemoveTag("Swim Surface")
							part:AddTag("Boat Surface")
						end
					end
				end
			end
		end)
	end
end

--# morph (Origin-style client model weld)
local morph_state = {
	model = nil,
	last_id = "",
}

local MORPH_PRESETS = {
	Custom = "",
	Verity = "140105640267431",
	["Tung Tung Tung"] = "138151705692565",
	["Gucci Morty"] = "82766930708256",
}

local function remove_morph()
	if morph_state.model then
		pcall(function()
			morph_state.model:Destroy()
		end)
		morph_state.model = nil
	end
	-- restore local transparency if we hid
	local char = local_player.Character
	if char and flags["misc_morph_hide"] == false then
		-- no-op restore handled on toggle off
	end
end

local function apply_morph()
	if not flags["misc_morph"] then
		remove_morph()
		return
	end
	local preset = (flags["misc_morph_preset"] and flags["misc_morph_preset"][1]) or "Custom"
	local id = tostring(flags["misc_morph_id"] or "")
	if MORPH_PRESETS[preset] and MORPH_PRESETS[preset] ~= "" then
		id = MORPH_PRESETS[preset]
	end
	id = id:gsub("%D", "")
	if id == "" then
		return
	end
	if morph_state.model and morph_state.last_id == id and morph_state.model.Parent then
		return
	end
	remove_morph()
	local char = local_player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	local anchor = char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("LowerTorso")
		or hrp
	local objs
	local ok = pcall(function()
		objs = game:GetObjects("rbxassetid://" .. id)
	end)
	if not ok or type(objs) ~= "table" or #objs == 0 then
		objs = nil
		pcall(function()
			local m = game:GetService("InsertService"):LoadAsset(tonumber(id))
			if m then
				objs = m:GetChildren()
			end
		end)
	end
	if type(objs) ~= "table" or #objs == 0 then
		return
	end
	local model = objs[1]
	for _, o in ipairs(objs) do
		if o:IsA("Model") then
			model = o
			break
		end
	end
	model.Name = "juju_morph"
	model.Parent = workspace
	pcall(function()
		if model:IsA("Model") then
			model:PivotTo(hrp.CFrame)
		elseif model:IsA("BasePart") then
			model.CFrame = hrp.CFrame
		end
	end)
	pcall(function()
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Humanoid")
				or d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D")
				or d:IsA("Snap") or d:IsA("ManualWeld") then
				d:Destroy()
			end
		end
	end)
	local parts = {}
	if model:IsA("Model") then
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then
				parts[#parts + 1] = d
			end
		end
	elseif model:IsA("BasePart") then
		parts[1] = model
	end
	if #parts == 0 then
		pcall(function()
			model:Destroy()
		end)
		return
	end
	for _, part in ipairs(parts) do
		pcall(function()
			part.Anchored = false
			part.CanCollide = false
			part.Massless = true
			local w = Instance.new("Weld")
			w.Part0 = anchor
			w.Part1 = part
			w.C0 = anchor.CFrame:ToObjectSpace(part.CFrame)
			w.Parent = part
		end)
	end
	if flags["misc_morph_hide"] then
		for _, d in ipairs(char:GetDescendants()) do
			if d:IsA("BasePart") or d:IsA("Decal") then
				pcall(function()
					d.Transparency = 1
				end)
			end
		end
	end
	morph_state.model = model
	morph_state.last_id = id
end

local fov_state = {
	original = nil,
	zoom_original = nil,
}

local function apply_camera_fov()
	if flags["misc_camera_fov"] then
		if fov_state.original == nil then
			fov_state.original = camera.FieldOfView
		end
		pcall(function()
			camera.FieldOfView = math.clamp(tonumber(flags["misc_camera_fov_value"]) or 70, 1, 120)
		end)
	elseif fov_state.original ~= nil and not flags["misc_fov_zoom"] then
		pcall(function()
			camera.FieldOfView = fov_state.original
		end)
		fov_state.original = nil
	end
	if flags["misc_fov_zoom"] then
		local holding = user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		if holding then
			if fov_state.zoom_original == nil then
				fov_state.zoom_original = camera.FieldOfView
			end
			pcall(function()
				camera.FieldOfView = math.clamp(tonumber(flags["misc_zoom_fov"]) or 30, 1, 120)
			end)
		elseif fov_state.zoom_original ~= nil then
			pcall(function()
				camera.FieldOfView = fov_state.zoom_original
			end)
			fov_state.zoom_original = nil
		end
	end
end

local function apply_movement(dt)
	if AR2_CFG then
		-- Origin engine owns movement / vehicles
		return
	end
	local character = local_player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		local speedo = movement_state.speedo
		if speedo then
			speedo.Visible = false
		end
		return
	end

	local pos = root.Position
	-- abort if already invalid (prevents abyss cascade)
	if pos ~= pos or pos.Magnitude > 1e6 then
		return
	end

	apply_anti_fall(humanoid)
	apply_morph()
	apply_camera_fov()
	apply_spoof_state(humanoid)
	apply_bhop()
	apply_spinbot(dt)
	apply_vehicle_extra_mods()
	update_hbe()

	local fly_on = flags["misc_fly"]
	local spidey_on = flags["misc_spiderman"]
	local fly_val = math.clamp(tonumber(flags["misc_fly_value"]) or 14, 0, 50)
	local spidey_val = math.clamp(tonumber(flags["misc_spiderman_value"]) or 14, 0, 50)

	-- noclip: local character only (CanCollide off)
	if flags["misc_noclip"] then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	-- vehicle physics + car noclip + car fly (Origin-style velocity, no BodyMovers)
	local car_fly_on = flags["misc_car_fly"]
	local car_noclip_on = flags["misc_car_noclip"]
	local any_vehicle_mod = flags["misc_carspeed"] or flags["misc_cargrip"] or flags["misc_carsteer"] or car_noclip_on or car_fly_on or flags["misc_car_god"] or flags["misc_car_fuel"] or flags["misc_car_boost"] or flags["misc_car_max_traction"] or flags["misc_car_tp_dash"] or flags["misc_car_boat"] or flags["misc_car_remove_drag"] or flags["misc_car_full_steer"]
	local vehicle_model = get_driven_vehicle_model()
	local in_vehicle = vehicle_model ~= nil
	if in_vehicle then
		apply_vehicle_mods()
		local _, vroot = get_driven_vehicle()
		if car_noclip_on or car_fly_on then
			for _, part in ipairs(vehicle_model:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
		if car_fly_on and vroot then
			local speed = math.clamp(tonumber(flags["misc_car_fly_value"]) or 60, 5, 200)
			local f, r, u = get_move_keys()
			local cam_cf = camera.CFrame
			local dir = cam_cf.LookVector * f + cam_cf.RightVector * r + Vector3.new(0, 1, 0) * u
			local target = Vector3.zero
			if dir.Magnitude > 0.05 then
				target = dir.Unit * speed
			else
				target = Vector3.new(0, 0.5, 0) -- soft hover
			end
			if target == target then
				vroot.AssemblyLinearVelocity = target
				-- zero seat controls so game physics doesn't fight us
				local seat = humanoid.SeatPart
				if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
					pcall(function()
						if seat:IsA("VehicleSeat") then
							seat.ThrottleFloat = 0
							seat.SteerFloat = 0
						end
					end)
				end
			end
		end

		-- car tp dash (Origin)
		if flags["misc_car_tp_dash"] and vroot then
			local now = clock()
			if now - (movement_state.car_tp_dash_last or 0) >= 2 then
				movement_state.car_tp_dash_last = now
				local fwd = camera.CFrame.LookVector
				local flat = Vector3.new(fwd.X, 0, fwd.Z)
				if flat.Magnitude > 0.01 then
					local studs = math.clamp(tonumber(flags["misc_car_tp_dash_studs"]) or 30, 5, 100)
					vroot.CFrame = vroot.CFrame + flat.Unit * studs
				end
			end
		end

		if any_vehicle_mod or flags["misc_speedometer"] or car_fly_on then
			local sps = vroot and vroot.AssemblyLinearVelocity.Magnitude or 0
			local speedo = ensure_speedometer()
			speedo.Visible = true
			local viewport = camera.ViewportSize
			speedo.Text = string.format("%.2f sps", sps)
			speedo.Position = Vector2.new(viewport.X / 2, viewport.Y - 72)
			speedo.Color = sps > 80 and Color3.fromRGB(220, 80, 80)
				or (sps > 40 and Color3.fromRGB(220, 200, 60) or Color3.fromRGB(154, 213, 222))
		end
		if any_vehicle_mod or car_fly_on then
			return
		end
	elseif not any_vehicle_mod then
		if next(vehicle_originals) then
			restore_vehicle_configs()
		end
	end

	local vel = root.AssemblyLinearVelocity
	local sps = (fly_on or spidey_on) and vel.Magnitude or Vector3.new(vel.X, 0, vel.Z).Magnitude

	local speedo = ensure_speedometer()
	local show_speedo = flags["misc_speedometer"] or fly_on or spidey_on
	speedo.Visible = show_speedo
	if show_speedo then
		local viewport = camera.ViewportSize
		speedo.Text = string.format("%.2f sps", sps)
		speedo.Position = Vector2.new(viewport.X / 2, viewport.Y - 72)
		if sps > 24 then
			speedo.Color = Color3.fromRGB(220, 80, 80)
		elseif sps > 16 then
			speedo.Color = Color3.fromRGB(220, 200, 60)
		else
			speedo.Color = Color3.fromRGB(154, 213, 222)
		end
	end

	local f, r, u = get_move_keys()
	local flat_look, flat_right = flat_camera_axes()

	-- Origin-style player fly: camera-relative WASD + Space/Ctrl, velocity only (no BodyMovers)
	if fly_on or spidey_on then
		movement_state.was_flying = true
		local speed = math.clamp(fly_on and fly_val or spidey_val, 0, 50)
		local dir
		if fly_on then
			-- full 3D along camera look (Origin AR2_startFly)
			local cam_cf = camera.CFrame
			dir = cam_cf.LookVector * f + cam_cf.RightVector * r + Vector3.new(0, 1, 0) * u
		else
			-- spiderman: flat horizontal + vertical
			dir = flat_look * f + flat_right * r + Vector3.new(0, 1, 0) * u
		end
		local target = Vector3.zero
		if dir.Magnitude > 0.05 then
			target = dir.Unit * speed
		elseif fly_on then
			target = Vector3.new(0, 0.5, 0) -- soft hover
		end
		if target == target then
			root.AssemblyLinearVelocity = target
		end
		return
	end

	if movement_state.was_flying then
		movement_state.was_flying = false
	end
end

local function watch_movement()
	if movement_state.loop then
		return
	end
	-- Heartbeat aligns with physics step = steadier sps + less fly rubberband
	movement_state.loop = run_service.Heartbeat:Connect(function(dt)
		apply_movement(dt)
	end)
	connections[#connections + 1] = movement_state.loop
end

local function watch_antiaim()
	if aa_state.loop then
		return
	end
	aa_state.loop = run_service.RenderStepped:Connect(function()
		apply_antiaim()
	end)
	connections[#connections + 1] = aa_state.loop
end


local function build_visuals_menu()
	local combat_group = menu.create_group("combat")
	combat_group:create_tab("silent aim")
	local saim_section = combat_group:create_section("silent aim", "silent aim", 1, 0.9, 0)
	local saim_extra = combat_group:create_section("silent aim", "targeting", 2, 0.9, 0)

	saim_section:create_element({ ["name"] = "enabled" }, { ["toggle"] = { ["flag"] = "combat_saim", ["default"] = false } })
	saim_section:create_element({ ["name"] = "show accuracy" }, { ["toggle"] = { ["flag"] = "combat_saim_show_accuracy", ["default"] = false } })
	saim_section:create_element({ ["name"] = "fov" }, { ["slider"] = { ["flag"] = "combat_saim_fov", ["default"] = 120, ["min"] = 1, ["max"] = 500, ["decimals"] = 0, ["suffix"] = "px" } })
	saim_section:create_element({ ["name"] = "show fov" }, { ["toggle"] = { ["flag"] = "combat_saim_show_fov", ["default"] = false } })
	saim_section:create_element({ ["name"] = "fov color" }, { ["colorpicker"] = { ["color_flag"] = "combat_saim_fov_color", ["transparency_flag"] = "combat_saim_fov_transparency", ["default_color"] = flags["combat_saim_fov_color"], ["default_transparency"] = flags["combat_saim_fov_transparency"] } })
	saim_section:create_element({ ["name"] = "hit part" }, { ["dropdown"] = { ["flag"] = "combat_saim_hitpart", ["options"] = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }, ["default"] = { "Head" }, ["requires_one"] = true } })
	saim_section:create_element({ ["name"] = "priority" }, { ["dropdown"] = { ["flag"] = "combat_saim_priority", ["options"] = { "crosshair", "distance", "health" }, ["default"] = { "crosshair" }, ["requires_one"] = true } })
	saim_section:create_element({ ["name"] = "sticky aim" }, { ["toggle"] = { ["flag"] = "combat_saim_sticky", ["default"] = false } })
	saim_section:create_element({ ["name"] = "manual left (+90)" }, { ["toggle"] = { ["flag"] = "combat_saim_manual_left", ["default"] = false } })
	saim_section:create_element({ ["name"] = "manual right (-90)" }, { ["toggle"] = { ["flag"] = "combat_saim_manual_right", ["default"] = false } })
	saim_section:create_element({ ["name"] = "prediction" }, { ["toggle"] = { ["flag"] = "combat_saim_prediction", ["default"] = false } })
	saim_section:create_element({ ["name"] = "prediction factor" }, { ["slider"] = { ["flag"] = "combat_saim_prediction_factor", ["default"] = 0.12, ["min"] = 0, ["max"] = 1, ["decimals"] = 2, ["suffix"] = "" } })
	saim_section:create_element({ ["name"] = "target line" }, { ["toggle"] = { ["flag"] = "combat_saim_target_line", ["default"] = false } })
	saim_section:create_element({ ["name"] = "target line color" }, { ["colorpicker"] = { ["color_flag"] = "combat_saim_target_line_color", ["transparency_flag"] = "combat_saim_target_line_transparency", ["default_color"] = flags["combat_saim_target_line_color"], ["default_transparency"] = 0 } })
	saim_section:create_element({ ["name"] = "line from" }, { ["dropdown"] = { ["flag"] = "combat_saim_target_line_from", ["options"] = { "mouse", "center" }, ["default"] = { "mouse" }, ["requires_one"] = true } })
	saim_extra:create_element({ ["name"] = "players" }, { ["toggle"] = { ["flag"] = "combat_saim_players", ["default"] = false } })
	saim_extra:create_element({ ["name"] = "zombies" }, { ["toggle"] = { ["flag"] = "combat_saim_zombies", ["default"] = false } })
	saim_extra:create_element({ ["name"] = "team check" }, { ["toggle"] = { ["flag"] = "combat_saim_team_check", ["default"] = false } })
	saim_extra:create_element({ ["name"] = "visible only" }, { ["toggle"] = { ["flag"] = "combat_saim_visible_only", ["default"] = false } })
	saim_extra:create_element({ ["name"] = "wall check" }, { ["toggle"] = { ["flag"] = "combat_saim_wallcheck", ["default"] = false } })
	saim_extra:create_element({ ["name"] = "max distance" }, { ["slider"] = { ["flag"] = "combat_saim_max_distance", ["default"] = 1000, ["min"] = 50, ["max"] = 5000, ["decimals"] = 0, ["suffix"] = "m" } })

	combat_group:create_tab("aimbot")
	local aimbot_section = combat_group:create_section("aimbot", "aimbot", 1, 0.9, 0)
	local aimbot_extra = combat_group:create_section("aimbot", "targeting", 2, 0.9, 0)

	aimbot_section:create_element({ ["name"] = "enabled" }, { ["toggle"] = { ["flag"] = "combat_aimbot", ["default"] = false } })
	aimbot_section:create_element({ ["name"] = "fov" }, { ["slider"] = { ["flag"] = "combat_aimbot_fov", ["default"] = 120, ["min"] = 1, ["max"] = 500, ["decimals"] = 0, ["suffix"] = "px" } })
	aimbot_section:create_element({ ["name"] = "show fov" }, { ["toggle"] = { ["flag"] = "combat_aimbot_show_fov", ["default"] = false } })
	aimbot_section:create_element({ ["name"] = "fov color" }, { ["colorpicker"] = { ["color_flag"] = "combat_aimbot_fov_color", ["transparency_flag"] = "combat_aimbot_fov_transparency", ["default_color"] = flags["combat_aimbot_fov_color"], ["default_transparency"] = flags["combat_aimbot_fov_transparency"] } })
	aimbot_section:create_element({ ["name"] = "method" }, { ["dropdown"] = { ["flag"] = "combat_aimbot_method", ["options"] = { "camera", "mouse" }, ["default"] = { "camera" }, ["requires_one"] = true } })
	aimbot_section:create_element({ ["name"] = "smoothness" }, { ["slider"] = { ["flag"] = "combat_aimbot_smooth", ["default"] = 8, ["min"] = 1, ["max"] = 40, ["decimals"] = 1, ["suffix"] = "" } })
	aimbot_section:create_element({ ["name"] = "instant snap" }, { ["toggle"] = { ["flag"] = "combat_aimbot_instant", ["default"] = false } })
	aimbot_section:create_element({ ["name"] = "hit part" }, { ["dropdown"] = { ["flag"] = "combat_aimbot_hitpart", ["options"] = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }, ["default"] = { "Head" }, ["requires_one"] = true } })
	aimbot_section:create_element({ ["name"] = "priority" }, { ["dropdown"] = { ["flag"] = "combat_aimbot_priority", ["options"] = { "crosshair", "distance", "health" }, ["default"] = { "crosshair" }, ["requires_one"] = true } })
	aimbot_section:create_element({ ["name"] = "sticky aim" }, { ["toggle"] = { ["flag"] = "combat_aimbot_sticky", ["default"] = false } })
	aimbot_section:create_element({ ["name"] = "prediction" }, { ["toggle"] = { ["flag"] = "combat_aimbot_prediction", ["default"] = false } })
	aimbot_section:create_element({ ["name"] = "prediction factor" }, { ["slider"] = { ["flag"] = "combat_aimbot_prediction_factor", ["default"] = 0.12, ["min"] = 0, ["max"] = 1, ["decimals"] = 2, ["suffix"] = "" } })
	aimbot_section:create_element({ ["name"] = "target line" }, { ["toggle"] = { ["flag"] = "combat_aimbot_target_line", ["default"] = false } })
	aimbot_section:create_element({ ["name"] = "target line color" }, { ["colorpicker"] = { ["color_flag"] = "combat_aimbot_target_line_color", ["transparency_flag"] = "combat_aimbot_target_line_transparency", ["default_color"] = flags["combat_aimbot_target_line_color"], ["default_transparency"] = 0 } })
	aimbot_section:create_element({ ["name"] = "line from" }, { ["dropdown"] = { ["flag"] = "combat_aimbot_target_line_from", ["options"] = { "mouse", "center" }, ["default"] = { "mouse" }, ["requires_one"] = true } })
	aimbot_extra:create_element({ ["name"] = "players" }, { ["toggle"] = { ["flag"] = "combat_aimbot_players", ["default"] = false } })
	aimbot_extra:create_element({ ["name"] = "zombies" }, { ["toggle"] = { ["flag"] = "combat_aimbot_zombies", ["default"] = false } })
	aimbot_extra:create_element({ ["name"] = "team check" }, { ["toggle"] = { ["flag"] = "combat_aimbot_team_check", ["default"] = false } })
	aimbot_extra:create_element({ ["name"] = "visible only" }, { ["toggle"] = { ["flag"] = "combat_aimbot_visible_only", ["default"] = false } })
	aimbot_extra:create_element({ ["name"] = "wall check" }, { ["toggle"] = { ["flag"] = "combat_aimbot_wallcheck", ["default"] = false } })
	aimbot_extra:create_element({ ["name"] = "max distance" }, { ["slider"] = { ["flag"] = "combat_aimbot_max_distance", ["default"] = 1000, ["min"] = 50, ["max"] = 5000, ["decimals"] = 0, ["suffix"] = "m" } })

	combat_group:create_tab("gun mods")
	local gun_section = combat_group:create_section("gun mods", "recoil / spread", 1, 0.9, 0)
	local gun_extra = combat_group:create_section("gun mods", "pen / magic / hbe", 2, 0.9, 0)
	gun_section:create_element({ ["name"] = "no recoil" }, { ["toggle"] = { ["flag"] = "weapon_no_recoil", ["default"] = false } })
	gun_section:create_element({ ["name"] = "no spread" }, { ["toggle"] = { ["flag"] = "weapon_no_spread", ["default"] = false } })
	gun_section:create_element({ ["name"] = "instabullet" }, { ["toggle"] = { ["flag"] = "weapon_instabullet", ["default"] = false } })
	gun_section:create_element({ ["name"] = "gun in vehicle" }, { ["toggle"] = { ["flag"] = "weapon_vehicle_equip", ["default"] = false } })
	gun_extra:create_element({ ["name"] = "wallbang" }, { ["toggle"] = { ["flag"] = "weapon_wallbang", ["default"] = false } })
	combat_group:create_tab("triggerbot")
	local trigger_section = combat_group:create_section("triggerbot", "triggerbot", 1, 0.9, 0)
	trigger_section:create_element({ ["name"] = "enabled" }, { ["toggle"] = { ["flag"] = "combat_trigger", ["default"] = false } })
	trigger_section:create_element({ ["name"] = "fov" }, { ["slider"] = { ["flag"] = "combat_trigger_fov", ["default"] = 25, ["min"] = 1, ["max"] = 150, ["decimals"] = 0, ["suffix"] = "px" } })
	trigger_section:create_element({ ["name"] = "delay" }, { ["slider"] = { ["flag"] = "combat_trigger_delay", ["default"] = 0.05, ["min"] = 0, ["max"] = 0.5, ["decimals"] = 3, ["suffix"] = "s" } })
	trigger_section:create_element({ ["name"] = "hit part" }, { ["dropdown"] = { ["flag"] = "combat_trigger_hitpart", ["options"] = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }, ["default"] = { "Head" }, ["requires_one"] = true } })
	trigger_section:create_element({ ["name"] = "wall check" }, { ["toggle"] = { ["flag"] = "combat_trigger_wallcheck", ["default"] = false } })
	trigger_section:create_element({ ["name"] = "team check" }, { ["toggle"] = { ["flag"] = "combat_trigger_team_check", ["default"] = false } })
	trigger_section:create_element({ ["name"] = "players" }, { ["toggle"] = { ["flag"] = "combat_trigger_players", ["default"] = false } })
	trigger_section:create_element({ ["name"] = "zombies" }, { ["toggle"] = { ["flag"] = "combat_trigger_zombies", ["default"] = false } })

	local visuals_group = menu.create_group("visuals")
	visuals_group:create_tab("player esp")
	local visuals_section = visuals_group:create_section("player esp", "player esp", 1, 0.9, 0)
	visuals_group:create_tab("npc/items")
	local zombie_esp_section = visuals_group:create_section("npc/items", "npc/items zombie esp", 1, 0.9, 0)
	local misc_group = menu.create_group("misc")
	misc_group:create_tab("player")
	local move_section = misc_group:create_section("player", "movement", 1, 0.9, 0)
	local aa_section = misc_group:create_section("player", "antiaim", 2, 0.9, 0)
	move_section:create_element({ ["name"] = "spiderman" }, { ["toggle"] = { ["flag"] = "misc_spiderman", ["default"] = false } })
	move_section:create_element({ ["name"] = "spiderman value" }, { ["slider"] = { ["flag"] = "misc_spiderman_value", ["default"] = 16, ["min"] = 0, ["max"] = 50, ["decimals"] = 1, ["suffix"] = "sps" } })
	move_section:create_element({ ["name"] = "noclip" }, { ["toggle"] = { ["flag"] = "misc_noclip", ["default"] = false } })
	move_section:create_element({ ["name"] = "anti fall" }, { ["toggle"] = { ["flag"] = "misc_anti_fall", ["default"] = false } })
	move_section:create_element({ ["name"] = "speedometer" }, { ["toggle"] = { ["flag"] = "misc_speedometer", ["default"] = false } })
	move_section:create_element({ ["name"] = "bullet tracers" }, { ["toggle"] = { ["flag"] = "misc_bullet_tracers", ["default"] = false } })
	aa_section:create_element({ ["name"] = "enabled" }, { ["toggle"] = { ["flag"] = "aa_enabled", ["default"] = false } })
	aa_section:create_element({ ["name"] = "mode" }, { ["dropdown"] = { ["flag"] = "aa_mode", ["options"] = { "spin", "jitter", "static", "invert" }, ["default"] = { "spin" }, ["requires_one"] = true } })
	aa_section:create_element({ ["name"] = "yaw" }, { ["slider"] = { ["flag"] = "aa_yaw", ["default"] = 180, ["min"] = -180, ["max"] = 180, ["decimals"] = 0, ["suffix"] = "°" } })
	aa_section:create_element({ ["name"] = "pitch" }, { ["slider"] = { ["flag"] = "aa_pitch", ["default"] = 0, ["min"] = -89, ["max"] = 89, ["decimals"] = 0, ["suffix"] = "°" } })
	aa_section:create_element({ ["name"] = "jitter range" }, { ["slider"] = { ["flag"] = "aa_jitter_range", ["default"] = 45, ["min"] = 5, ["max"] = 180, ["decimals"] = 0, ["suffix"] = "°" } })
	aa_section:create_element({ ["name"] = "invert" }, { ["toggle"] = { ["flag"] = "aa_invert", ["default"] = false } })

	misc_group:create_tab("vehicles")
	local veh_tune = misc_group:create_section("vehicles", "tuning", 1, 0.9, 0)
	local veh_fly = misc_group:create_section("vehicles", "flight / noclip", 2, 0.9, 0)
	veh_tune:create_element({ ["name"] = "speed multiplier" }, { ["toggle"] = { ["flag"] = "misc_carspeed", ["default"] = false } })
	veh_tune:create_element({ ["name"] = "speed mult value" }, { ["slider"] = { ["flag"] = "misc_carspeed_mult", ["default"] = 1.5, ["min"] = 1, ["max"] = 5, ["decimals"] = 2, ["suffix"] = "x" } })
	veh_tune:create_element({ ["name"] = "grip multiplier" }, { ["toggle"] = { ["flag"] = "misc_cargrip", ["default"] = false } })
	veh_tune:create_element({ ["name"] = "grip mult value" }, { ["slider"] = { ["flag"] = "misc_cargrip_mult", ["default"] = 1.5, ["min"] = 1, ["max"] = 5, ["decimals"] = 2, ["suffix"] = "x" } })
	veh_tune:create_element({ ["name"] = "steering curve" }, { ["toggle"] = { ["flag"] = "misc_carsteer", ["default"] = false } })
	veh_tune:create_element({ ["name"] = "steering mult" }, { ["slider"] = { ["flag"] = "misc_carsteer_mult", ["default"] = 1.0, ["min"] = 0.25, ["max"] = 3, ["decimals"] = 2, ["suffix"] = "x" } })
	veh_tune:create_element({ ["name"] = "boost" }, { ["toggle"] = { ["flag"] = "misc_car_boost", ["default"] = false } })
	veh_tune:create_element({ ["name"] = "boost speed" }, { ["slider"] = { ["flag"] = "misc_car_boost_speed", ["default"] = 120, ["min"] = 20, ["max"] = 300, ["decimals"] = 0, ["suffix"] = "sps" } })
	veh_tune:create_element({ ["name"] = "torque mult" }, { ["slider"] = { ["flag"] = "misc_car_torque", ["default"] = 3, ["min"] = 1, ["max"] = 10, ["decimals"] = 1, ["suffix"] = "x" } })
	veh_tune:create_element({ ["name"] = "max traction" }, { ["toggle"] = { ["flag"] = "misc_car_max_traction", ["default"] = false } })
	veh_tune:create_element({ ["name"] = "remove drag" }, { ["toggle"] = { ["flag"] = "misc_car_remove_drag", ["default"] = false } })
	veh_tune:create_element({ ["name"] = "full steer" }, { ["toggle"] = { ["flag"] = "misc_car_full_steer", ["default"] = false } })
	veh_fly:create_element({ ["name"] = "vehicle noclip" }, { ["toggle"] = { ["flag"] = "misc_car_noclip", ["default"] = false } })
	veh_fly:create_element({ ["name"] = "vehicle fly" }, { ["toggle"] = { ["flag"] = "misc_car_fly", ["default"] = false } })
	veh_fly:create_element({ ["name"] = "vehicle fly speed" }, { ["slider"] = { ["flag"] = "misc_car_fly_value", ["default"] = 60, ["min"] = 5, ["max"] = 200, ["decimals"] = 0, ["suffix"] = "sps" } })

	misc_group:create_tab("zombie")
	local zombie_section = misc_group:create_section("zombie", "zombie", 1, 0.9, 0)
	misc_group:create_tab("world")
	local world_lighting_section = misc_group:create_section("world", "lighting", 1, 0.9, 0)
	local world_environment_section = misc_group:create_section("world", "environment", 2, 0.9, 0)
	local visuals_extra_section = visuals_group:create_section("player esp", "player extras & chams", 2, 0.9, 0)

	visuals_section:create_element({ ["name"] = "enabled" }, { ["toggle"] = { ["flag"] = "esp_enabled", ["default"] = false } })
	visuals_section:create_element({ ["name"] = "bounding box" }, { ["toggle"] = { ["flag"] = "esp_boxes", ["default"] = false } })
	visuals_section:create_element({ ["name"] = "box style" }, { ["dropdown"] = { ["flag"] = "esp_box_style", ["options"] = { "corner", "full" }, ["default"] = { "corner" }, ["requires_one"] = true } })
	visuals_section:create_element({ ["name"] = "box color" }, { ["colorpicker"] = { ["color_flag"] = "esp_box_color", ["transparency_flag"] = "esp_box_color_transparency", ["default_color"] = flags["esp_box_color"], ["default_transparency"] = flags["esp_box_color_transparency"] } })
	visuals_section:create_element({ ["name"] = "fill box" }, { ["toggle"] = { ["flag"] = "esp_box_fill", ["default"] = false } })
	visuals_section:create_element({ ["name"] = "fill color" }, { ["colorpicker"] = { ["color_flag"] = "esp_box_fill_color", ["transparency_flag"] = "esp_box_fill_transparency", ["default_color"] = flags["esp_box_fill_color"], ["default_transparency"] = flags["esp_box_fill_transparency"] } })
	visuals_section:create_element({ ["name"] = "names" }, { ["toggle"] = { ["flag"] = "esp_names", ["default"] = false } })
	visuals_section:create_element({ ["name"] = "name mode" }, { ["dropdown"] = { ["flag"] = "esp_name_mode", ["options"] = { "display name", "username" }, ["default"] = { "display name" }, ["requires_one"] = true } })
	visuals_section:create_element({ ["name"] = "healthbar" }, { ["toggle"] = { ["flag"] = "esp_healthbar", ["default"] = false } })
	visuals_section:create_element({ ["name"] = "health high" }, { ["colorpicker"] = { ["color_flag"] = "esp_health_high", ["transparency_flag"] = "esp_health_high_transparency", ["default_color"] = flags["esp_health_high"], ["default_transparency"] = 0 } })
	visuals_section:create_element({ ["name"] = "health low" }, { ["colorpicker"] = { ["color_flag"] = "esp_health_low", ["transparency_flag"] = "esp_health_low_transparency", ["default_color"] = flags["esp_health_low"], ["default_transparency"] = 0 } })
	visuals_section:create_element({ ["name"] = "distance" }, { ["toggle"] = { ["flag"] = "esp_distance", ["default"] = false } })
	visuals_section:create_element({ ["name"] = "weapon" }, { ["toggle"] = { ["flag"] = "esp_weapon", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "team check" }, { ["toggle"] = { ["flag"] = "esp_team_check", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "tracers" }, { ["toggle"] = { ["flag"] = "esp_tracers", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "tracer color" }, { ["colorpicker"] = { ["color_flag"] = "esp_tracer_color", ["transparency_flag"] = "esp_tracer_color_transparency", ["default_color"] = flags["esp_tracer_color"], ["default_transparency"] = 0 } })
	visuals_extra_section:create_element({ ["name"] = "health text" }, { ["toggle"] = { ["flag"] = "esp_health_text", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "health text color" }, { ["colorpicker"] = { ["color_flag"] = "esp_health_text_color", ["transparency_flag"] = "esp_health_text_color_transparency", ["default_color"] = flags["esp_health_text_color"], ["default_transparency"] = 0 } })
	visuals_extra_section:create_element({ ["name"] = "skeletons" }, { ["toggle"] = { ["flag"] = "esp_skeletons", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "skeleton color" }, { ["colorpicker"] = { ["color_flag"] = "esp_skeleton_color", ["transparency_flag"] = "esp_skeleton_color_transparency", ["default_color"] = flags["esp_skeleton_color"], ["default_transparency"] = 0 } })
	visuals_extra_section:create_element({ ["name"] = "head dot color" }, { ["colorpicker"] = { ["color_flag"] = "esp_head_dot_color", ["transparency_flag"] = "esp_head_dot_color_transparency", ["default_color"] = flags["esp_head_dot_color"], ["default_transparency"] = 0 } })
	visuals_extra_section:create_element({ ["name"] = "viewport chams" }, { ["toggle"] = { ["flag"] = "esp_chams", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "visible only" }, { ["toggle"] = { ["flag"] = "esp_visible_only", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "rainbow" }, { ["toggle"] = { ["flag"] = "esp_rainbow", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "offscreen arrows" }, { ["toggle"] = { ["flag"] = "esp_offscreen", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "offscreen color" }, { ["colorpicker"] = { ["color_flag"] = "esp_offscreen_color", ["transparency_flag"] = "esp_offscreen_color_transparency", ["default_color"] = flags["esp_offscreen_color"], ["default_transparency"] = 0 } })
	visuals_extra_section:create_element({ ["name"] = "offscreen size" }, { ["slider"] = { ["flag"] = "esp_offscreen_size", ["default"] = 12, ["min"] = 6, ["max"] = 28, ["decimals"] = 0, ["suffix"] = "px" } })
	visuals_extra_section:create_element({ ["name"] = "tracer origin" }, { ["dropdown"] = { ["flag"] = "esp_tracer_origin", ["options"] = { "bottom", "top", "center", "mouse" }, ["default"] = { "bottom" }, ["requires_one"] = true } })
	visuals_extra_section:create_element({ ["name"] = "flags" }, { ["toggle"] = { ["flag"] = "esp_flags", ["default"] = false } })
	visuals_extra_section:create_element({ ["name"] = "flags color" }, { ["colorpicker"] = { ["color_flag"] = "esp_flags_color", ["transparency_flag"] = "esp_flags_color_transparency", ["default_color"] = flags["esp_flags_color"], ["default_transparency"] = 0 } })

	zombie_esp_section:create_element({ ["name"] = "enabled" }, { ["toggle"] = { ["flag"] = "esp_npc_enabled", ["default"] = false } })
	zombie_esp_section:create_element({ ["name"] = "corners" }, { ["toggle"] = { ["flag"] = "esp_npc_box", ["default"] = false } })
	zombie_esp_section:create_element({ ["name"] = "box color" }, { ["colorpicker"] = { ["color_flag"] = "esp_npc_box_color", ["transparency_flag"] = "esp_npc_box_color_transparency", ["default_color"] = flags["esp_npc_box_color"], ["default_transparency"] = flags["esp_npc_box_color_transparency"] } })
	zombie_esp_section:create_element({ ["name"] = "viewport chams" }, { ["toggle"] = { ["flag"] = "esp_npc_chams", ["default"] = false } })
	zombie_esp_section:create_element({ ["name"] = "skeleton" }, { ["toggle"] = { ["flag"] = "esp_npc_skeleton", ["default"] = false } })
	zombie_esp_section:create_element({ ["name"] = "skeleton color" }, { ["colorpicker"] = { ["color_flag"] = "esp_npc_skeleton_color", ["transparency_flag"] = "esp_npc_skeleton_color_transparency", ["default_color"] = flags["esp_npc_skeleton_color"], ["default_transparency"] = flags["esp_npc_skeleton_color_transparency"] } })
	local vehicle_esp_section = visuals_group:create_section("npc/items", "npc/items vehicle esp", 2, 0.9, 0)
	vehicle_esp_section:create_element({ ["name"] = "enabled" }, { ["toggle"] = { ["flag"] = "esp_vehicle_enabled", ["default"] = false } })
	vehicle_esp_section:create_element({ ["name"] = "box" }, { ["toggle"] = { ["flag"] = "esp_vehicle_box", ["default"] = false } })
	vehicle_esp_section:create_element({ ["name"] = "name" }, { ["toggle"] = { ["flag"] = "esp_vehicle_name", ["default"] = false } })
	vehicle_esp_section:create_element({ ["name"] = "box color" }, { ["colorpicker"] = { ["color_flag"] = "esp_vehicle_box_color", ["transparency_flag"] = "esp_vehicle_box_color_transparency", ["default_color"] = flags["esp_vehicle_box_color"], ["default_transparency"] = flags["esp_vehicle_box_color_transparency"] } })
	vehicle_esp_section:create_element({ ["name"] = "name color" }, { ["colorpicker"] = { ["color_flag"] = "esp_vehicle_name_color", ["transparency_flag"] = "esp_vehicle_name_color_transparency", ["default_color"] = flags["esp_vehicle_name_color"], ["default_transparency"] = flags["esp_vehicle_name_color_transparency"] } })
	zombie_section:create_element({ ["name"] = "zombie freeze" }, { ["toggle"] = { ["flag"] = "misc_zombie_freeze", ["default"] = false } })
	local no_fog_toggle = world_lighting_section:create_element({ ["name"] = "no fog" }, { ["toggle"] = { ["flag"] = "misc_no_fog", ["default"] = false } })
	local fullbright_toggle = world_lighting_section:create_element({ ["name"] = "fullbright" }, { ["toggle"] = { ["flag"] = "misc_fullbright", ["default"] = false } })
	local world_time_toggle = world_lighting_section:create_element({ ["name"] = "lock time" }, { ["toggle"] = { ["flag"] = "misc_world_time_enabled", ["default"] = false } })
	local world_time_slider = world_lighting_section:create_element({ ["name"] = "time of day" }, { ["slider"] = { ["flag"] = "misc_world_time", ["default"] = lighting_service.ClockTime, ["min"] = 0, ["max"] = 24, ["decimals"] = 1, ["suffix"] = "h" } })
	local clouds_toggle = world_environment_section:create_element({ ["name"] = "disable clouds" }, { ["toggle"] = { ["flag"] = "misc_remove_clouds", ["default"] = false } })
	local atmosphere_toggle = world_environment_section:create_element({ ["name"] = "clear atmosphere" }, { ["toggle"] = { ["flag"] = "misc_clear_atmosphere", ["default"] = false } })
	create_connection(no_fog_toggle["on_toggle_change"], set_no_fog)
	create_connection(fullbright_toggle["on_toggle_change"], function(enabled)
		flags["misc_fullbright"] = enabled
		if enabled then
			local state = world_settings_state
			if not state.fullbright_values then
				state.fullbright_values = {
					Brightness = lighting_service.Brightness,
					Ambient = lighting_service.Ambient,
					OutdoorAmbient = lighting_service.OutdoorAmbient,
					GlobalShadows = lighting_service.GlobalShadows,
					FogEnd = lighting_service.FogEnd,
					FogStart = lighting_service.FogStart,
				}
			end
			force_fullbright()
		else
			set_fullbright(false)
		end
	end)
	create_connection(world_time_toggle["on_toggle_change"], function(enabled)
		flags["misc_world_time_enabled"] = enabled
		if enabled then
			force_world_time()
		end
	end)
	create_connection(clouds_toggle["on_toggle_change"], set_clouds_disabled)
	create_connection(atmosphere_toggle["on_toggle_change"], set_atmosphere_cleared)
	create_connection(world_time_slider["on_slider_change"], function(value)
		flags["misc_world_time"] = value % 24
		if flags["misc_world_time_enabled"] then
			force_world_time()
		else
			pcall(function()
				lighting_service.ClockTime = value % 24
			end)
		end
	end)
	world_time_slider:set_slider(lighting_service.ClockTime)

	local function watch_player_gui(player_gui)
		if world_settings_state.player_gui == player_gui then
			return
		end
		world_settings_state.player_gui = player_gui
		connections[#connections + 1] = player_gui.DescendantAdded:Connect(function(descendant)
			if flags["misc_no_fog"] and descendant.Name == "FogBlock" and descendant.Parent and descendant.Parent.Name == "DamageCorners" then
				world_settings_state.fog_blocks[descendant] = descendant.Parent
				descendant.Parent = nil
			end
		end)
		if flags["misc_no_fog"] then
			set_no_fog(true)
		end
	end

	local player_gui = local_player:FindFirstChildOfClass("PlayerGui")
	if player_gui then
		watch_player_gui(player_gui)
	end
	create_connection(local_player.ChildAdded, function(child)
		if child:IsA("PlayerGui") then
			watch_player_gui(child)
		end
	end)
	watch_player_esp()
	watch_zombie_esp()
	watch_vehicle_esp()
	watch_world_settings()
	watch_saim()
	watch_aimbot()
	watch_triggerbot()
	watch_antiaim()
	watch_movement()
end

local drawing
local drawing_proxy

(function()
	-- > ( file system )

	do
		local function safeHttp(url)
			local ok, res = pcall(function()
				return game:HttpGet(url)
			end)
			if not ok or not res then
				warn("Failed to fetch:", url)
				return nil
			end
			return res
		end

		local function debugRBXM(folder, name, url)
			local ok, data = pcall(safeHttp, url)
			if not ok or not data then
				warn("[RBXM DEBUG] Failed to download:", folder, name, url)
				return nil
			end
			return data -- always returns string, never a function
		end

		local files = {
			["assets"] = {
				["api.lua"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/api.lua"),
				["sparkle.ogg"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/sparkle.ogg"),
				["skeet.ogg"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/skeet.ogg"),
				["neverlose.ogg"] = safeHttp(
					"https://raw.githubusercontent.com/panduh16/juju/main/assets/neverlose.ogg"
				),
				["break.ogg"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/break.ogg"),
				["mc bow.ogg"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/mc%20bow.ogg"),
				["primordial.ogg"] = safeHttp(
					"https://raw.githubusercontent.com/panduh16/juju/main/assets/primordial.ogg"
				),
				["rust.ogg"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/rust.ogg"),
				["sexy.ogg"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/sexy.ogg"),
				["jaydes.png"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/jaydes.png"),
				["1.png"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/1.png"),
				["2.png"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/2.png"),
				["logo.png"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/logo.png"),
				["saturation.png"] = safeHttp(
					"https://raw.githubusercontent.com/panduh16/juju/main/assets/saturation.png"
				),
			},
			["custom"] = {
				["textures.json"] = safeHttp(
					"https://raw.githubusercontent.com/panduh16/juju/main/assets/textures.json"
				),
				["character.rbxm"] = debugRBXM(
					"custom",
					"character.rbxm",
					"https://raw.githubusercontent.com/panduh16/juju/main/assets/character.rbxm"
				),
				["pinksky.rbxm"] = debugRBXM(
					"custom",
					"pinksky.rbxm",
					"https://raw.githubusercontent.com/panduh16/juju/main/assets/pinksky.rbxm"
				),
				["crunch.ogg"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/juju.ogg"),
				["scar.ogg"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/scar.ogg"),
				["x hit.rbxm"] = debugRBXM(
					"custom",
					"x hit.rbxm",
					"https://raw.githubusercontent.com/panduh16/juju/main/assets/x%20hit.rbxm"
				),
				["blossom aura.rbxm"] = debugRBXM(
					"custom",
					"blossom aura.rbxm",
					"https://raw.githubusercontent.com/panduh16/juju/main/assets/blossom%20aura.rbxm"
				),
				["spam.json"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/spam.json"),
			},
			["themes"] = {
				["default.th"] = safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/default.th"),
			},
			["addons"] = {},
			["configs"] = {},
			["data.dat"] = [[{"notifications":true,"theme":"","favorites":[]}]],
		}
		if not isfolder(file_path) then
			makefolder(file_path)
		end

		local recursive_check

		recursive_check = function(path, array)
			for file, data in array do
				local path = path .. file
				local data_type = type(data)

				if data_type == "table" then
					if not isfolder(path) then
						makefolder(path)
					end
					recursive_check(path .. "/", data)
				elseif not isfile(path) then
					writefile(path, type(data) == "function" and data() or data)
				end
			end
		end

		recursive_check(file_path .. "/", files)
	end

	-- > ( custom drawing )

	drawing = Drawing
	LPH_NO_VIRTUALIZE(function()
		drawing = _G.FORCE_REAL_DRAWING and Drawing or loadstring(readfile(file_path .. "/assets/api.lua"))()
	end)()

	getgenv()["fake_drawing"] = drawing

	-- > ( global menu variables )

	local context_action_service = cloneref(game:GetService("ContextActionService"))
	local context_action_click = tostring({}):sub(math_random(8, 12))
	local context_action_scroll = tostring({}):sub(math_random(8, 12))
	local context_action_typing = tostring({}):sub(math_random(8, 12))
	local context_action_typing_core = tostring({}):sub(math_random(8, 12))

	local shortened_characters = {
		[Enum.KeyCode.LeftShift] = "lshift",
		[Enum.KeyCode.RightShift] = "rshift",
		[Enum.UserInputType.MouseButton1] = "m1",
		[Enum.UserInputType.MouseButton2] = "m2",
		[Enum.UserInputType.MouseButton3] = "m3",
		[Enum.KeyCode.ButtonX] = "xb",
		[Enum.KeyCode.ButtonY] = "yb",
		[Enum.KeyCode.ButtonA] = "ab",
		[Enum.KeyCode.ButtonB] = "bb",
		[Enum.KeyCode.ButtonR1] = "r1",
		[Enum.KeyCode.ButtonR2] = "r2",
		[Enum.KeyCode.ButtonR1] = "l1",
		[Enum.KeyCode.ButtonR2] = "l2",
		[Enum.KeyCode.DPadLeft] = "dpl",
		[Enum.KeyCode.DPadRight] = "dpr",
		[Enum.KeyCode.DPadUp] = "dpup",
		[Enum.KeyCode.DPadDown] = "dpdn",
		[Enum.KeyCode.Thumbstick1] = "ts1",
		[Enum.KeyCode.Thumbstick2] = "ts2",
		[Enum.KeyCode.Delete] = "delete",
		[Enum.KeyCode.Insert] = "insert",
		[Enum.KeyCode.PageUp] = "pgup",
		[Enum.KeyCode.PageDown] = "pgdw",
		[Enum.KeyCode.LeftControl] = "lctrl",
		[Enum.KeyCode.RightControl] = "rctrl",
		[Enum.KeyCode.RightAlt] = "ralt",
		[Enum.KeyCode.LeftAlt] = "lalt",
		[Enum.KeyCode.CapsLock] = "caps",
		[Enum.KeyCode.ScrollLock] = "slock",
		[Enum.KeyCode.Backspace] = "bspace",
		[Enum.KeyCode.Space] = "space",
		[Enum.KeyCode.Backquote] = "bqte",
		[Enum.KeyCode.BackSlash] = "bsls",
	}

	local on_keybind_created = signal["new"]()
	local on_keybind_deleted = signal["new"]()
	local on_keybind_updated = signal["new"]()
	local on_keybind_change = signal["new"]()
	local transparency_image_data = base64_decode(
		"iVBORw0KGgoAAAANSUhEUgAAABkAAAAMBAMAAABl3At4AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///8rKyoNe1IIAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADp1fY4ytpsegAAABdJREFUGNNjYBBEgmg8ZI4AGo+u+hgEAKy7BSkQOa/KAAAAAElFTkSuQmCC"
	)
	local checkmark_image_data = base64_decode(
		"iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADp1fY4ytpsegAAAEFJREFUKFOFj0EOACEIxMD//3ncTsSDYbUXDFMhpKS4MVbt4Kf+BI/Nj07YIesRPIpm1QoBIf1qQqgVls4QHmdGTFexGgt5dAJMAAAAAElFTkSuQmCC"
	)
	local config_image_data = base64_decode(
		"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADp1fY4ytpsegAAAFFJREFUKFOdz8ERwCAIBEC0x6QmuzYcORlkhofuB0VEbKKmQoya4tJ0xuzNl6tC64hiNZj6n04eHvlY5YyRz4tCsE3A9FnH7TNILEy5u441kQ8rkEMeEE8J7QAAAABJRU5ErkJggg=="
	)
	local button_image_data = base64_decode(
		"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAMAAAC67D+PAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAOxAAADsQBlSsOGwAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAAAMdwEA6AMAAAx3AQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAO7qLRjGzAACAAAAK0lEQVQYVz3KQRIAAAQCwPr/p5WiQ9YAfkDcZiph7HnUucyD3V/RWqbaCjkOewBGmBH+OgAAAABJRU5ErkJggg=="
	)
	local arrow_image_data = base64_decode(
		"iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAA8nYBAOgDAADydgEA6AMAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAACOO8FX0xe8TgAAABdJREFUKFNj/A8EDHgAE5QmHwwBKxgYAJzaC/5K6BlzAAAAAElFTkSuQmCC"
	)
	local cog_image_data = base64_decode(
		"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAMAAAC67D+PAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAQKAAAECgBJz8A6wAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAAB3mgEA6AMAAHeaAQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAEyPNqYn0aVIAAAALElEQVQYV2NgBAIGCAmioQhIQACQCZaGYBAJoZGYSApgUhATYAiikJGRkREACr4AMZ+SUSoAAAAASUVORK5CYII="
	)
	local menu_position =
		udim2_new(0, camera["ViewportSize"]["X"] / 2 - 575 / 2, 0, camera["ViewportSize"]["Y"] / 2 - 450 * 0.5)

	local half_transparency = { Transparency = 0.5 }
	local stop_panel_search = nil
	local do_notifications = true
	local set_active_tab = nil
	local theme_section = nil
	local close_context = nil
	local menu_open = true
	local menu_tick = clock()
	local pop_menu = nil
	local old_text = ""
	local searching = nil
	local hud_frames = {}

	local actives = {
		["colorpicker"] = nil,
		["dropdown"] = nil,
		["settings"] = nil,
		["binding"] = nil,
		["keybind"] = nil,
		["context"] = nil,
		["panel"] = nil,
		["tab"] = nil,
		["colorpicker_saturation"] = 0,
		["colorpicker_hue"] = 0,
		["colorpicker_value"] = 0,
	}

	-- > ( drawing proxy )

	drawing_proxy = {}
	local create1 = identifyexecutor() == "AWP" and Drawing["new"] or drawing["new"]

	drawing_proxy.new = identifyexecutor() == "AWP"
			and LPH_NO_VIRTUALIZE(function(class, properties)
				local object = create1(class)

				local proxy = setmetatable({
					["position"] = udim2_new(0, 0, 0, 0),
					["real_position"] = vector2_new(0, 0),
					["size"] = class == "Text" and 12 or udim2_new(0, 0, 0, 0),
					["real_size"] = class == "Text" and 12 or vector2_new(0, 0),
					["object"] = object,
					["children"] = {},
					["parent"] = false,
					["is_rendering"] = false,
					["skip"] = class == "Circle",
					["visible"] = false,
					["destroy"] = function()
						object:Destroy()
					end,
				}, drawing_proxy)

				local size = properties["Size"]
				if size and type(size) == "number" then
					properties["Size"] = size + 2
				end

				local z_index = properties["ZIndex"]
				properties["ZIndex"] = z_index and z_index + 20 or 20

				for property, value in properties do
					proxy[property] = value
				end

				return proxy
			end)
		or LPH_NO_VIRTUALIZE(function(class, properties)
			local object = create1(class)

			local proxy = setmetatable({
				["position"] = udim2_new(0, 0, 0, 0),
				["real_position"] = vector2_new(0, 0),
				["size"] = class == "Text" and 12 or udim2_new(0, 0, 0, 0),
				["real_size"] = class == "Text" and 12 or vector2_new(0, 0),
				["object"] = object,
				["children"] = {},
				["parent"] = false,
				["is_rendering"] = false,
				["skip"] = class == "Circle",
				["visible"] = false,
				["destroy"] = function()
					object:Destroy()
				end,
			}, drawing_proxy)

			local z_index = properties["ZIndex"]
			properties["ZIndex"] = z_index and z_index + 20 or 20

			for property, value in properties do
				proxy[property] = value
			end

			return proxy
		end)

	getgenv()["_PROXY"] = drawing_proxy
	menu["create_proxy_drawing"] = drawing_proxy["new"]

	do
		local rawget = rawget
		local type = type

		local update_proxy_position
		update_proxy_position = LPH_NO_VIRTUALIZE(function(proxy, position)
			local parent = rawget(proxy, "parent")
			local real_position = parent and parent["real_position"]
				or vector2_new(position["X"]["Offset"], position["Y"]["Offset"])

			if parent then
				local parent_position = parent["real_position"]
				local real_parent_size = parent["real_size"]

				real_position = vector2_new(
					(parent_position["X"] + real_parent_size["X"] * position["X"]["Scale"]) + position["X"]["Offset"],
					(parent_position["Y"] + real_parent_size["Y"] * position["Y"]["Scale"]) + position["Y"]["Offset"]
				)
			end

			proxy["object"]["Position"] = real_position
			proxy["real_position"] = real_position

			local children = proxy["children"]
			for i = 1, #children do
				local child = children[i]
				update_proxy_position(child, child["position"])
			end
		end)

		local update_proxy_visibility
		update_proxy_visibility = LPH_NO_VIRTUALIZE(function(proxy, visible)
			local children = proxy["children"]
			local parent = rawget(proxy, "parent")
			local object = proxy["object"]

			if parent and not parent["is_rendering"] then
				proxy["is_rendering"] = false
				object["Visible"] = false
			else
				object["Visible"] = visible
				proxy["is_rendering"] = visible
			end

			for i = 1, #children do
				local child = children[i]
				update_proxy_visibility(child, child["visible"])
			end
		end)

		local update_proxy_size
		update_proxy_size = LPH_NO_VIRTUALIZE(function(proxy, size)
			if type(proxy) ~= "table" or type(proxy["real_size"]) == "number" then -- ??
				return
			end

			local parent = rawget(proxy, "parent")
			local real_size = parent and parent["real_size"] or vector2_new(size["X"]["Offset"], size["Y"]["Offset"])

			if parent then
				local parent_size = parent["real_size"]

				real_size = vector2_new(
					(parent_size["X"] * size["X"]["Scale"]) + size["X"]["Offset"],
					(parent_size["Y"] * size["Y"]["Scale"]) + size["Y"]["Offset"]
				)
			end

			proxy["object"]["Size"] = real_size
			proxy["real_size"] = real_size

			local children = proxy["children"]
			for i = 1, #children do
				local child = children[i]
				local old = child["real_size"]
				update_proxy_size(child, child["size"])

				update_proxy_position(child, child["position"])
			end
		end)

		function drawing_proxy:__newindex(property, value)
			if property == "Position" or property == "tween_position" then
				self["position"] = value
				update_proxy_position(self, value)
			elseif property == "Parent" then
				if value then
					local children = value["children"]
					children[#children + 1] = self
				end

				self["parent"] = value
				update_proxy_position(self, self["position"])
				update_proxy_visibility(self, self["visible"])

				if type(self["size"]) ~= "number" and not self["skip"] then
					update_proxy_size(self, self["size"])
				end
			elseif property == "Visible" then
				self["visible"] = value
				update_proxy_visibility(self, value)
			elseif
				(property == "Size" or property == "tween_size")
				and type(value) ~= "number"
				and not self["skip"]
			then
				self["size"] = value
				update_proxy_size(self, value)
			else
				self["object"][property] = value
			end
		end

		function drawing_proxy:__index(property)
			return property == "tween_size" and self["size"]
				or property == "tween_position" and self["position"]
				or property == "Destroy" and self["destroy"]
				or self["object"][property]
		end
	end

	-- > ( menu creation )

	local cursor = drawing_proxy["new"]("Image", {
		["Position"] = menu_position,
		["Size"] = udim2_new(0, 24, 0, 24),
		["Color"] = menu["colors"]["cursor"],
		["Rounding"] = 0,
		["Data"] = base64_decode(
			"iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAACHUExURaWlpdTV1cDBwbq6uv///+Li4q6ursPDw9vc3Nna2sTExLCwsNPT09bW1tXV1bGxsdLT083OzrKyss/Pz7Ozs8jIyLS1tcbHx7W1tcnJybm5ufDw8JKSkpmZmaqrq6ipqaWmpqanp4aGhpqamszMzMLCwuLh4Xx8fL29vfHw8Hl5eY+OjgAAAAqocEsAAAAtdFJOU///////////////////////////////////////////////////////////AKXvC/0AAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuNBLfpoMAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuNAADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADX5rshveZftAAAALhJREFUOE/V0scWgjAQhWHUK2JX7L33vP/zmcilJRNd+6+Yme+w4BCoH2kQVKocpDSoAfWQo5sGDQCRVxCg6RMatAxA1ObGKgPoyCIHHlEA6EqiCNDrc1uoBDBwRRlgGHOfZQGMxjyk2QCTKS/MAZjNeUpyARY8JQmgLCSAJY8mCax4+5SD9WYbx+Fufyh/8AwcubBLwYmzkwbmjzr7XmDABbjeOLppcMfjyUlIA/VKHuUM+NofAKXelaSKsWMM5jMAAAAASUVORK5CYII="
		),
		["Transparency"] = 0,
		["ZIndex"] = 1011,
		["Visible"] = true,
	})

	local frame = drawing_proxy["new"]("Image", {
		["Position"] = menu_position,
		["Size"] = udim2_new(0, 575, 0, 450),
		["Color"] = menu["colors"]["background"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 1,
		["Visible"] = false,
	})

	local inside = drawing_proxy["new"]("Image", {
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(1, -2, 1, -2),
		["Color"] = menu["colors"]["section"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 1,
		["Parent"] = frame,
		["Visible"] = false,
	})

	local logo = drawing_proxy["new"]("Image", {
		["Color"] = menu["colors"]["accent"],
		["Data"] = readfile(file_path .. "/assets/logo.png"),
		["Position"] = udim2_new(0, 15, 0, 15),
		["Parent"] = inside,
		["Size"] = udim2_new(0, 35, 0, 35),
		["Visible"] = true,
		["Transparency"] = 1,
	})

	local juju_text = drawing_proxy["new"]("Text", {
		["Font"] = 1,
		["Color"] = color3_fromrgb(255, 255, 255),
		["Text"] = getgenv().script_name or "juju",
		["Parent"] = logo,
		["Position"] = udim2_new(1, 5, 0, 3),
		["Size"] = 14,
		["Visible"] = true,
		["Transparency"] = 1,
	})

	local build_text = drawing_proxy["new"]("Text", {
		["Font"] = 1,
		["Color"] = menu["colors"]["accent"],
		["Text"] = getgenv().script_version or "live",
		["Parent"] = logo,
		["Position"] = udim2_new(1, 5, 0, 19),
		["Size"] = 14,
		["Visible"] = true,
		["Transparency"] = 1,
	})

	local right_side = drawing_proxy["new"]("Square", {
		["Parent"] = inside,
		["Position"] = udim2_new(0, 101, 0, 0),
		["Size"] = udim2_new(1, -101, 1, 0),
		["Color"] = menu["colors"]["background"],
		["Visible"] = true,
		["Filled"] = true,
		["Transparency"] = 1,
	})

	local right_side_cover = drawing_proxy["new"]("Square", {
		["Parent"] = inside,
		["Position"] = udim2_new(0, 101, 0, 0),
		["Size"] = udim2_new(1, -101, 1, 0),
		["Color"] = menu["colors"]["background"],
		["Visible"] = true,
		["Filled"] = true,
		["ZIndex"] = 999,
		["Transparency"] = 0,
	})

	local right_side_divider = drawing_proxy["new"]("Square", {
		["Parent"] = inside,
		["Position"] = udim2_new(0, 100, 0, 0),
		["Size"] = udim2_new(0, 1, 1, 0),
		["Color"] = menu["colors"]["background"],
		["Visible"] = true,
		["Thickness"] = 1,
		["Filled"] = true,
		["Transparency"] = 1,
	})

	local search_image = drawing_proxy["new"]("Image", {
		["Color"] = menu["colors"]["image"],
		["Data"] = base64_decode(
			"iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADp1fY4ytpsegAAAGdJREFUKFONkGEWgCAIg5GTdP9LlqPBA8Pq+yFuOvA5JHFOuDXGhNvAjPVipgtZAFAGtIuvbrSdRA4sJQQBKB/wOM6V9TevAe+cn6su8liwaieSuwuONy4/k0PdZHglsKOEWD+5QyIX+wJP/y1yP3IAAAAASUVORK5CYII="
		),
		["Position"] = udim2_new(0, 27, 1, -27),
		["Parent"] = inside,
		["Size"] = udim2_new(0, 12, 0, 12),
		["Transparency"] = 1,
		["ZIndex"] = 999,
		["Visible"] = true,
	})

	local themes_image = drawing_proxy["new"]("Image", {
		["Color"] = menu["colors"]["image"],
		["Data"] = base64_decode(
			"iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADdYAAA3WAZBveZwAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAiF8BAOgDAACIXwEA6AMAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAAC1cWHl18YwawAAAH5JREFUKFOFkAsOgCAMQwE5lIfx/qeA4Do7ZCL6ErOWtHwMb7TWinyN1pE4Owxul5uJnAp2ljGFo0B5F1Zhw0p6JVxDfIZegQymtroRTK9wj0bYjl5QtTCGPkqHLGcXpFRQGtYqwhDuDU9YKhYGaQwjAGix0S7W/z0UAO0PIZyip02b2JexIAAAAABJRU5ErkJggg=="
		),
		["Position"] = udim2_new(0, 44, 1, -27),
		["Parent"] = inside,
		["Size"] = udim2_new(0, 12, 0, 12),
		["Transparency"] = 1,
		["Visible"] = true,
	})

	local settings_image = drawing_proxy["new"]("Image", {
		["Color"] = menu["colors"]["image"],
		["Data"] = base64_decode(
			"iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAALEwAACxMBAJqcGAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAABJGQEA6AMAAEkZAQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAC/Sb/YZ+v7JAAAAMklEQVQYV1WLARIAQAQC9f9Pn65oNAZpFajyUHn0MtJZWkbdt+QxBwtA47X1kzDk9QY8FowASc0mZqAAAAAASUVORK5CYII="
		),
		["Position"] = udim2_new(0, 61, 1, -27),
		["Parent"] = inside,
		["Size"] = udim2_new(0, 12, 0, 12),
		["Transparency"] = 1,
		["Visible"] = true,
	})

	local tab_line = drawing_proxy["new"]("Square", {
		["Parent"] = inside,
		["Position"] = udim2_new(0, 0, 0, 0),
		["Size"] = udim2_new(0, 1, 0, 12),
		["Filled"] = true,
		["Transparency"] = 0.5,
		["Color"] = menu["colors"]["accent"],
		["Visible"] = true,
	})

	local search_border = drawing_proxy["new"]("Image", {
		["Parent"] = frame,
		["Position"] = udim2_new(0, 11, 1, -32),
		["Size"] = udim2_new(0, 78, 0, 20),
		["Color"] = menu["colors"]["border"],
		["Transparency"] = 1,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Visible"] = false,
	})

	local search_inside = drawing_proxy["new"]("Image", {
		["Parent"] = search_border,
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(1, -2, 1, -2),
		["Color"] = menu["colors"]["background"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 1,
		["Visible"] = true,
	})

	local search_out_border = drawing_proxy["new"]("Image", {
		["Parent"] = frame,
		["Position"] = udim2_new(0, 11, 1, -57),
		["Size"] = udim2_new(0, 78, 0, 20),
		["Color"] = menu["colors"]["border"],
		["Transparency"] = 1,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["ZIndex"] = 999,
		["Visible"] = false,
	})

	local search_out = drawing_proxy["new"]("Image", {
		["Parent"] = search_out_border,
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(1, -2, 1, -2),
		["Color"] = menu["colors"]["background"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 1,
		["ZIndex"] = 1000,
		["Visible"] = true,
	})

	local search_text = drawing_proxy["new"]("Text", {
		["Color"] = menu["colors"]["active_text"],
		["Text"] = "",
		["Size"] = 12,
		["Font"] = 1,
		["Transparency"] = 1,
		["Visible"] = true,
		["Parent"] = search_inside,
		["Center"] = false,
		["Position"] = udim2_new(0, 18, 0, 2),
	})

	local drag_frame = drawing_proxy["new"]("Image", {
		["Position"] = menu_position,
		["Size"] = udim2_new(0, 575, 0, 450),
		["Color"] = menu["colors"]["background"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 0,
		["ZIndex"] = 1000,
		["Visible"] = false,
	})

	local drag_inside = drawing_proxy["new"]("Image", {
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(1, -2, 1, -2),
		["Color"] = menu["colors"]["section"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 1,
		["Parent"] = drag_frame,
		["ZIndex"] = 1001,
		["Visible"] = true,
	})

	local drag_logo = drawing_proxy["new"]("Image", {
		["Color"] = menu["colors"]["accent"],
		["Data"] = readfile(file_path .. "/assets/logo.png"),
		["Position"] = udim2_new(0.5, -40, 0.5, -40),
		["Parent"] = drag_inside,
		["Size"] = udim2_new(0, 80, 0, 80),
		["Visible"] = true,
		["ZIndex"] = 1002,
		["Transparency"] = 1,
	})

	-- > ( keybinds )

	local keybind_data = {
		[1] = {
			["key"] = Enum["KeyCode"]["Delete"],
			["value"] = true,
			["original_value"] = false,
			["set_activated"] = LPH_NO_VIRTUALIZE(function()
				pop_menu()
			end),
		},
	}

	local keybind = {}
	keybind["__index"] = keybind

	function keybind:set_activated(activated)
		local new_value = activated and self["value"] or (not activated and self["original_value"])
		local element = self["element"]
		local type = self["type"]

		if type == 1 then
			element:set_dropdown(new_value, true)
		elseif type == 2 then
			element:set_slider(new_value, true)
		elseif type == 3 then
			element:set_toggle(activated, true)
		elseif type == 4 then
			return element["on_clicked"]:Fire()
		end

		self["activated"] = activated

		on_keybind_change:Fire(self, element, activated)
	end

	-- > ( keybinds list )

	local list_frame = drawing_proxy["new"]("Image", {
		["Position"] = udim2_new(0, 15, 0, camera["ViewportSize"]["Y"] / 2 - 10),
		["Size"] = udim2_new(0, 74, 0, 20),
		["Color"] = menu["colors"]["border"],
		["Transparency"] = 0,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["ZIndex"] = 10,
		["Visible"] = false,
	})

	hud_frames["keybinds_position"] = list_frame

	local list_shadow = drawing_proxy["new"]("Image", {
		["Parent"] = list_frame,
		["Data"] = shadow_image_data,
		["Rounding"] = 7,
		["Color"] = menu["colors"]["shadow"],
		["Transparency"] = 0,
		["Size"] = udim2_new(1, 6, 1, 4),
		["ZIndex"] = 9,
		["Visible"] = true,
		["Position"] = udim2_new(0, -3, 0, -2),
	})

	local list_inside = drawing_proxy["new"]("Image", {
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(0, 72, 0, 18),
		["Color"] = color3_fromrgb(15, 15, 15),
		["Transparency"] = 0,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Parent"] = list_frame,
		["ZIndex"] = 11,
		["Visible"] = true,
	})

	local list_icon = drawing_proxy["new"]("Image", {
		["Color"] = menu["colors"]["accent"],
		["Data"] = base64_decode(
			"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAMAAAC67D+PAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAOwwAADsMBx2+oZAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAABgAAAAAQAAAGAAAAABAAAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAOnV9jjK2mx6AAAAKklEQVQYV2NghANkJhCAKCgGUUAazIUCiBiIAVEAFoLwIQgsCgZwJiMjABBLAEmFjHpsAAAAAElFTkSuQmCC"
		),
		["Transparency"] = 0,
		["Position"] = udim2_new(0, 4, 0, 4),
		["Parent"] = list_inside,
		["Size"] = udim2_new(0, 10, 0, 10),
		["ZIndex"] = 12,
		["Visible"] = true,
	})

	local list_divider = drawing_proxy["new"]("Square", {
		["Position"] = udim2_new(0, 20, 0, 4),
		["Size"] = udim2_new(0, 1, 0, 10),
		["Color"] = menu["colors"]["accent"],
		["Transparency"] = 0,
		["Filled"] = true,
		["Parent"] = list_inside,
		["ZIndex"] = 12,
		["Visible"] = true,
	})

	local list_text = drawing_proxy["new"]("Text", {
		["Color"] = color3_fromrgb(255, 255, 255),
		["Text"] = "hotkeys",
		["Size"] = 12,
		["Font"] = 1,
		["Transparency"] = 0,
		["Visible"] = true,
		["Parent"] = list_inside,
		["Position"] = udim2_new(0, 26, 0, identifyexecutor() == "AWP" and 2 or 3),
		["ZIndex"] = 12,
	})

	local list_drawings = {}
	local active_binds = {}

	menu["show_bind"] = function(keybind, just_visual)
		local found = nil

		for i = 1, #active_binds do
			local bind = active_binds[i]
			if bind == keybind then
				found = i
				break
			end
		end

		if not just_visual then
			if not found then
				active_binds[#active_binds + 1] = keybind
				found = #active_binds
			end
		end

		local drawings = list_drawings[keybind]
		local frame = drawings["frame"]
		local y = 24 + (found - 1) * 21

		frame["Position"] = udim2_new(0, -5, 0, y)
		tween(frame, { Transparency = 0 or 0.2, tween_position = udim2_new(0, 0, 0, y) }, circular, out, 0.15)
		tween(drawings["inside"], { Transparency = 0.7 }, circular, out, 0.15)
		tween(drawings["text"], { Transparency = 0.9 }, circular, out, 0.15)
		tween(drawings["value"], { Transparency = 0.7 }, circular, out, 0.15)
		tween(drawings["shadow"], { Transparency = 0.16 }, circular, out, 0.15)
		frame["Visible"] = true
	end

	menu["get_active_binds"] = LPH_NO_VIRTUALIZE(function()
		return active_binds
	end)

	local create_hover_connection = nil

	menu["hide_bind"] = function(keybind, just_visual)
		if not just_visual then
			for i = 1, #active_binds do
				if active_binds[i] == keybind then
					remove(active_binds, i)
					break
				end
			end

			for i = 1, #active_binds do
				local frame = list_drawings[active_binds[i]]["frame"]
				local old_position = frame["tween_position"]
				local new_position = udim2_new(0, 0, 0, 24 + (i - 1) * 21)

				if old_position ~= new_position then
					tween(frame, { tween_position = new_position }, circular, out, 0.15)
				end
			end
		end

		local drawings = list_drawings[keybind]

		if drawings then
			local frame = drawings["frame"]

			tween(
				drawings["frame"],
				{ Transparency = 0, tween_position = frame["tween_position"] - udim2_new(0, 5, 0, 0) },
				circular,
				out,
				0.15
			)
			tween(drawings["inside"], hide_transparency, circular, out, 0.15)
			tween(drawings["text"], hide_transparency, circular, out, 0.15)
			tween(drawings["value"], hide_transparency, circular, out, 0.15)
			tween(drawings["shadow"], hide_transparency, circular, out, 0.15)

			delay(0.15, function()
				local found = nil

				if not just_visual then
					for i = 1, #active_binds do
						local bind = active_binds[i]
						if bind == keybind then
							found = i
							break
						end
					end
				end

				if not found then
					frame["Visible"] = false
				end
			end)
		end
	end

	function menu:show_keybinds()
		list_frame["Visible"] = true
		tween(list_frame, { Transparency = 0.7 }, circular, out, 0.15)
		tween(list_inside, show_transparency, circular, out, 0.15)
		tween(list_shadow, { Transparency = 0.16 }, circular, out, 0.15)
		local children = list_inside["children"]
		for i = 1, #children do
			local child = children[i]
			if child["Visible"] then
				tween(child, child == list_text and show_transparency or half_transparency, circular, out, 0.15)
			end
		end

		for i = 1, #active_binds do
			menu["show_bind"](active_binds[i], true)
		end

		menu["keybinds_visible"] = true
	end

	function menu:hide_keybinds()
		list_frame["Visible"] = true
		tween(list_frame, hide_transparency, circular, out, 0.15)
		tween(list_inside, hide_transparency, circular, out, 0.15)
		tween(list_shadow, hide_transparency, circular, out, 0.15)
		local children = list_inside["children"]
		for i = 1, #children do
			local child = children[i]
			if child["Visible"] then
				tween(child, hide_transparency, circular, out, 0.15)
			end
		end

		local old_tick = clock()

		for i = 1, #active_binds do
			local keybind = active_binds[i]
			menu["hide_bind"](keybind, true)
		end

		menu["keybinds_visible"] = old_tick

		delay(0.15, function()
			if old_tick == menu["keybinds_visible"] then
				menu["keybinds_visible"] = false
				list_frame["Visible"] = false
			end
		end)
	end

	function menu:load_theme(theme)
		if theme then
			local path = file_path .. "/themes/" .. theme .. ".th"
			if isfile(path) then
				local s, data = pcall(function()
					return http_service:JSONDecode(readfile(path))
				end)

				if s and data then
					local elements = theme_section["elements"]
					for i = 1, #elements do
						local element = elements[i]
						local flag = element["color_flag"]
						if flag then
							local color = data[flag]

							if color then
								element:set_colorpicker(color3_fromrgb(color[1], color[2], color[3]))
							end
						end
					end

					menu["new_notification"]("loaded theme " .. theme, 1)
					menu["did_action"] = true
					menu["theme"] = theme
					menu["saved"] = true
				else
					menu["new_notification"]("failed to load theme " .. theme, 3)
				end
			else
				menu["theme"] = ""
				menu["saved"] = true
			end
		end
	end

	local offset = identifyexecutor() == "AWP" and 1 or 2

	create_connection(on_keybind_created, function(keybind, element)
		local type = keybind["type"]

		if type == 1 then
			local keybind_frame = drawing_proxy["new"]("Image", {
				["Position"] = udim2_new(0, 0, 0, 25),
				["Size"] = udim2_new(0, 74, 0, 18),
				["Color"] = menu["colors"]["border"],
				["Transparency"] = 0,
				["Rounding"] = 4,
				["Parent"] = list_frame,
				["Data"] = pixel_image_data,
				["Visible"] = false,
			})

			local keybind_inside = drawing_proxy["new"]("Image", {
				["Position"] = udim2_new(0, 1, 0, 1),
				["Size"] = udim2_new(0, 72, 0, 18),
				["Color"] = menu["colors"]["background"],
				["Transparency"] = 0,
				["Rounding"] = 4,
				["Data"] = pixel_image_data,
				["Parent"] = keybind_frame,
				["Visible"] = true,
			})

			local value_image = drawing_proxy["new"]("Image", {
				["Color"] = menu["colors"]["accent"],
				["Size"] = udim2_new(0, 10, 0, 10),
				["Data"] = arrow_image_data,
				["Transparency"] = 0,
				["Visible"] = true,
				["Parent"] = keybind_inside,
				["Position"] = udim2_new(0, 3, 0, 3),
				["ZIndex"] = 2,
			})

			local keybind_text = drawing_proxy["new"]("Text", {
				["Color"] = menu["colors"]["keybind_text"],
				["Text"] = element["name"],
				["Size"] = 12,
				["Font"] = 1,
				["Transparency"] = 0,
				["Visible"] = true,
				["Parent"] = keybind_inside,
				["Position"] = udim2_new(0, 23, 0, offset),
				["ZIndex"] = 2,
			})

			local keybind_shadow = drawing_proxy["new"]("Image", {
				["Parent"] = keybind_frame,
				["Data"] = shadow_image_data,
				["Rounding"] = 7,
				["Color"] = menu["colors"]["shadow"],
				["Transparency"] = 0,
				["Visible"] = true,
				["Position"] = udim2_new(0, 0, 0, 0),
				["ZIndex"] = 3,
			})

			local x_size = keybind_text["TextBounds"]["X"] + 31

			keybind_frame["Size"] = udim2_new(0, x_size, 0, 18)
			keybind_inside["Size"] = udim2_new(0, x_size - 2, 0, 16)

			local shadow_size = floor(x_size / 11)
			keybind_shadow["Size"] = udim2_new(1, shadow_size - 1, 1, 4)
			keybind_shadow["Position"] = udim2_new(0, -shadow_size / 2, 0, -2)

			list_drawings[keybind] = {
				["frame"] = keybind_frame,
				["inside"] = keybind_inside,
				["text"] = keybind_text,
				["value"] = value_image,
				["shadow"] = keybind_shadow,
			}
		elseif type == 2 then
			local keybind_frame = drawing_proxy["new"]("Image", {
				["Position"] = udim2_new(0, 0, 0, 25),
				["Size"] = udim2_new(0, 74, 0, 18),
				["Color"] = menu["colors"]["border"],
				["Transparency"] = 0,
				["Rounding"] = 4,
				["Parent"] = list_frame,
				["Data"] = pixel_image_data,
				["Visible"] = false,
			})

			local keybind_inside = drawing_proxy["new"]("Image", {
				["Position"] = udim2_new(0, 1, 0, 1),
				["Size"] = udim2_new(0, 72, 0, 18),
				["Color"] = menu["colors"]["background"],
				["Transparency"] = 0,
				["Rounding"] = 4,
				["Data"] = pixel_image_data,
				["Parent"] = keybind_frame,
				["Visible"] = true,
			})

			local value_text = drawing_proxy["new"]("Text", {
				["Color"] = menu["colors"]["accent"],
				["Text"] = element["drawings"]["slider_text"]["Text"],
				["Size"] = 12,
				["Font"] = 1,
				["Transparency"] = 0,
				["Visible"] = true,
				["Parent"] = keybind_inside,
				["Position"] = udim2_new(0, 3, 0, offset),
			})

			local value = keybind["value"]

			if value == element["slider_min"] then
				value_text["Text"] = element["slider_min_text"]
					or element["slider_prefix"] .. value .. element["slider_suffix"]
			else
				value_text["Text"] = (value == element["slider_max"] and element["slider_max_text"])
					or element["slider_prefix"] .. value .. element["slider_suffix"]
			end

			local keybind_text = drawing_proxy["new"]("Text", {
				["Color"] = menu["colors"]["keybind_text"],
				["Text"] = element["name"],
				["Size"] = 12,
				["Font"] = 1,
				["Transparency"] = 0,
				["Visible"] = true,
				["Parent"] = keybind_inside,
				["Position"] = udim2_new(0, 23, 0, offset),
			})

			local keybind_shadow = drawing_proxy["new"]("Image", {
				["Parent"] = keybind_frame,
				["Data"] = shadow_image_data,
				["Rounding"] = 7,
				["Color"] = menu["colors"]["shadow"],
				["Transparency"] = 0,
				["Visible"] = true,
				["Position"] = udim2_new(0, 0, 0, 0),
				["ZIndex"] = 3,
			})

			local text_bounds = value_text["TextBounds"]["X"]
			local x_size = text_bounds + keybind_text["TextBounds"]["X"] + 18

			keybind_text["Position"] = udim2_new(0, text_bounds + 13, 0, 2)
			keybind_frame["Size"] = udim2_new(0, x_size, 0, 18)
			keybind_inside["Size"] = udim2_new(0, x_size - 2, 0, 16)

			local shadow_size = floor(x_size / 11)
			keybind_shadow["Size"] = udim2_new(1, shadow_size - 1, 1, 4)
			keybind_shadow["Position"] = udim2_new(0, -shadow_size / 2, 0, -2)

			list_drawings[keybind] = {
				["frame"] = keybind_frame,
				["inside"] = keybind_inside,
				["text"] = keybind_text,
				["value"] = value_text,
				["shadow"] = keybind_shadow,
			}
		elseif type == 3 then
			local keybind_frame = drawing_proxy["new"]("Image", {
				["Position"] = UDim2.new(0, 0, 0, 25),
				["Size"] = UDim2.new(0, 74, 0, 18),
				["Color"] = menu["colors"]["border"],
				["Transparency"] = 0,
				["Rounding"] = 4,
				["Parent"] = list_frame,
				["Data"] = pixel_image_data,
				["Visible"] = false,
			})

			local keybind_inside = drawing_proxy["new"]("Image", {
				["Position"] = UDim2.new(0, 1, 0, 1),
				["Size"] = UDim2.new(0, 72, 0, 18),
				["Color"] = menu["colors"]["background"],
				["Transparency"] = 0,
				["Rounding"] = 4,
				["Data"] = pixel_image_data,
				["Parent"] = keybind_frame,
				["Visible"] = true,
			})

			local keybind_shadow = drawing_proxy["new"]("Image", {
				["Parent"] = keybind_frame,
				["Data"] = shadow_image_data,
				["Rounding"] = 7,
				["Color"] = menu["colors"]["shadow"],
				["Transparency"] = 0,
				["Visible"] = true,
				["Position"] = udim2_new(0, 0, 0, 0),
				["ZIndex"] = 3,
			})

			local value_image = drawing_proxy["new"]("Image", {
				["Color"] = menu["colors"]["accent"],
				["Size"] = UDim2.new(0, 10, 0, 10),
				["Data"] = checkmark_image_data,
				["Transparency"] = 0,
				["Visible"] = true,
				["Parent"] = keybind_inside,
				["Position"] = UDim2.new(0, 3, 0, 3),
				["ZIndex"] = 2,
			})

			local keybind_text = drawing_proxy["new"]("Text", {
				["Color"] = menu["colors"]["keybind_text"],
				["Text"] = element["name"],
				["Size"] = 12,
				["Font"] = 1,
				["Transparency"] = 0,
				["Visible"] = true,
				["Parent"] = keybind_inside,
				["Position"] = UDim2.new(0, 23, 0, offset),
				["ZIndex"] = 2,
			})

			local x_size = keybind_text["TextBounds"]["X"] + 31

			keybind_frame["Size"] = UDim2.new(0, x_size, 0, 18)
			keybind_inside["Size"] = UDim2.new(0, x_size - 2, 0, 16)

			local shadow_size = floor(x_size / 11)
			keybind_shadow["Size"] = udim2_new(1, shadow_size - 1, 1, 4)
			keybind_shadow["Position"] = udim2_new(0, -shadow_size / 2, 0, -2)

			list_drawings[keybind] = {
				["frame"] = keybind_frame,
				["inside"] = keybind_inside,
				["text"] = keybind_text,
				["value"] = value_image,
				["shadow"] = keybind_shadow,
			}

			if keybind["value"] then
				menu["show_bind"](keybind)
			end
		end
	end)

	create_connection(on_keybind_updated, function(keybind, element)
		local type = keybind["type"]

		if type == 2 then
			local drawings = list_drawings[keybind]
			local value_text = drawings["value"]
			local value = keybind["value"]

			if value == element["slider_min"] then
				value_text["Text"] = element["slider_min_text"]
					or element["slider_prefix"] .. value .. element["slider_suffix"]
			else
				value_text["Text"] = (value == element["slider_max"] and element["slider_max_text"])
					or element["slider_prefix"] .. value .. element["slider_suffix"]
			end

			local text_bounds = value_text["TextBounds"]["X"]
			local x_size = text_bounds + drawings["text"]["TextBounds"]["X"] + 18

			drawings["text"]["Position"] = udim2_new(0, text_bounds + 13, 0, 2)
			drawings["frame"]["Size"] = udim2_new(0, x_size, 0, 18)
			drawings["inside"]["Size"] = udim2_new(0, x_size - 2, 0, 16)
		end
	end)

	create_connection(on_keybind_change, function(keybind, element, activated)
		if menu["keybinds_visible"] then
			if activated then
				menu["show_bind"](keybind)
			else
				menu["hide_bind"](keybind)
			end
		end
	end)

	create_connection(on_keybind_deleted, function(keybind, element, force)
		if menu["keybinds_visible"] or force then
			menu["hide_bind"](keybind)

			delay(0.15, function()
				local data = list_drawings[keybind]

				if data then
					for _, drawing in data do
						drawing:Destroy()
						data[_] = nil
					end
					list_drawings[keybind] = nil
				end
			end)
		else
			local data = list_drawings[keybind]

			if data then
				for _, drawing in data do
					drawing:Destroy()
					data[_] = nil
				end
				list_drawings[keybind] = nil
			end
		end
	end)

	-- > ( elements )

	local element = {}
	element["__index"] = element

	local section = {}
	section["__index"] = section

	local item = {}
	item["__index"] = item

	-- > ( inputs )

	local moving = nil

	local right_click_connections = {}
	local scroll_connections = {}
	local hover_connections = {}
	local click_connections = {}
	local hovering_objects = {}
	local active_typing = nil

	local type_line = drawing_proxy["new"]("Square", {
		["Position"] = udim2_new(0, 0, 0, 0),
		["Size"] = udim2_new(0, 1, 0, 12),
		["Filled"] = true,
		["Transparency"] = 0,
		["Color"] = menu["colors"]["inactive_text"],
		["Visible"] = true,
		["ZIndex"] = 999,
	})

	local type_function = LPH_NO_VIRTUALIZE(function()
		local position = active_typing["real_position"]
		type_line["Transparency"] = 0.5 + 0.5 * math["sin"](clock() * math["pi"] * 2.5)
		type_line["Position"] = udim2_new(0, position["X"] + active_typing["TextBounds"]["X"] + 3, 0, position["Y"] + 1)
	end)

	local create_click_connection = function(new_handle, object, callback)
		local handle = click_connections[new_handle]

		if not handle then
			click_connections[new_handle] = {}
			handle = click_connections[new_handle]
		end

		local new_handle = handle[object]
		if not new_handle then
			handle[object] = {
				callback,
			}
		else
			new_handle[#new_handle + 1] = callback
		end
	end

	local create_scroll_connection = function(new_handle, object, callback)
		local handle = scroll_connections[new_handle]

		if not handle then
			scroll_connections[new_handle] = {}
			handle = scroll_connections[new_handle]
		end

		local new_handle = handle[object]
		if not new_handle then
			handle[object] = {
				callback,
			}
		else
			new_handle[#new_handle + 1] = callback
		end
	end

	local create_right_click_connection = function(new_handle, object, callback)
		local handle = right_click_connections[new_handle]

		if not handle then
			right_click_connections[new_handle] = {}
			handle = right_click_connections[new_handle]
		end

		local new_handle = handle[object]
		if not new_handle then
			handle[object] = {
				callback,
			}
		else
			new_handle[#new_handle + 1] = callback
		end
	end

	create_hover_connection = function(new_handle, object, hover_callback, leave_callback)
		local handle = hover_connections[new_handle]

		if not handle then
			hover_connections[new_handle] = {}
			handle = hover_connections[new_handle]
		end

		local new_handle = handle[object]
		if not new_handle then
			handle[object] = {
				{
					hover_callback,
					leave_callback,
				},
			}
		else
			new_handle[#new_handle + 1] = {
				hover_callback,
				leave_callback,
			}
		end
	end

	local open_settings = function(settings)
		local border = settings["border"]
		for _, element in settings["elements"] do
			for _, drawing in element["drawings"] do
				tween(
					drawing,
					_ == "slider_fill" and half_transparency
						or _ == "slider_line" and half_transparency
						or _ == "checkmark" and (flags[element["toggle_flag"]] and half_transparency or hide_transparency)
						or _ == "colorpicker_transparency" and {
							Transparency = -flags[element["transparency_flag"]] + 1,
						}
						or show_transparency,
					exponential,
					out,
					0.18
				)
			end
		end

		local position = border["real_position"]
		local x_position = position["X"] + 30
		local screen_size = camera["ViewportSize"]
		local x_size = screen_size["X"]
		local y_size = screen_size["Y"]

		local x_overlap = (x_position + border["real_size"]["X"]) - x_size
		local y_overlap = (position["Y"] + border["real_size"]["Y"]) - y_size

		if x_overlap > 0 then
			x_position -= (x_overlap + 5)
		elseif x_overlap < -x_size then
			x_position += (-x_overlap + 5)
		else
			x_overlap = 0
		end

		if y_overlap > 0 then
			position -= vector2_new(0, y_overlap + 5)
		elseif y_overlap < -y_size then
			position += vector2_new(0, y_overlap - 5)
		else
			y_overlap = 0
		end

		tween(settings["inside"], show_transparency, circular, out, 0.15)
		tween(
			border,
			{ tween_position = udim2_new(1, 5 - x_overlap, 0, -y_overlap), Transparency = 1 },
			circular,
			out,
			0.15
		)
		border["Visible"] = true
		actives["settings"] = settings
	end

	local close_settings = function(settings)
		local border = settings["border"]
		for _, element in settings["elements"] do
			for _, drawing in element["drawings"] do
				tween(drawing, hide_transparency, circular, out, 0.15)
			end
		end
		tween(settings["inside"], hide_transparency, circular, out, 0.15)
		tween(border, { tween_position = udim2_new(1, 5, 0, -5), Transparency = 0 }, circular, out, 0.15)
		actives["settings"] = nil
		delay(0.15, function()
			if actives["settings"] ~= settings then
				border["Visible"] = false
			end
		end)

		if menu["saved"] then
			menu["saved"] = false
			writefile(
				file_path .. "/data.dat",
				http_service:JSONEncode({
					["notifications"] = do_notifications,
					["favorites"] = menu["favorites"],
					["theme"] = menu["theme"],
					["hide_on_load"] = menu["hide_on_load"],
					["autoload"] = menu["autoload"],
				})
			)
		end
	end

	local stop_typing = function()
		for i = 1, #heartbeat do
			if heartbeat[i] == type_function then
				remove(heartbeat, i)
				break
			end
		end

		if active_typing then
			active_typing["Text"] = old_text
			active_typing = false
			type_line["Visible"] = false
		end

		context_action_service:UnbindAction(context_action_typing)
	end

	local stop_search = function()
		local children = search_out["children"]
		click_connections[search_out] = nil
		hover_connections[search_out] = nil

		for _, child in children do
			children[_] = nil
			child:Destroy()
		end

		search_out_border["Visible"] = false

		searching = nil

		tween(
			search_image,
			{ tween_position = udim2_new(0, 27, 1, -27), Color = menu["colors"]["image"] },
			circular,
			out,
			0.15
		)
		tween(search_border, { Color = menu["colors"]["border"], ["Transparency"] = 0 }, circular, out, 0.15)
		tween(search_inside, hide_transparency, circular, out, 0.15)
		tween(search_text, hide_transparency, circular, out, 0.15)

		delay(0.15, function()
			if not searching then
				search_border["Visible"] = false
			end
		end)
	end

	local start_typing = LPH_JIT_MAX(
		function(label, limit, callback, numbers, allow_enter, allow_all, only_on_enter) -- > LOL dont ask im too lazy to rewrite this >->
			if active_typing then
				stop_typing()
				return
			end

			type_line["Size"] = udim2_new(0, 1, 0, label["Size"] - 1)
			active_typing = label
			type_line["Visible"] = true
			heartbeat[#heartbeat + 1] = type_function

			local current_input = ""

			old_text = label["Text"]

			local items = Enum["KeyCode"]:GetEnumItems()

			local backspace = Enum["KeyCode"]["Backspace"]
			local enter = Enum["KeyCode"]["Return"]
			local shift = Enum["KeyCode"]["LeftShift"]

			context_action_service:BindAction(context_action_typing, function(_, state, input)
				if state == Enum["UserInputState"]["Begin"] then
					local keycode = input["KeyCode"]
					local is_enter = keycode == enter
					local last_input = current_input

					if is_enter and allow_enter then
						stop_typing()

						if searching then
							stop_search()
						end

						if actives["panel"] then
							stop_panel_search()
						end

						callback(current_input, input)

						return
					elseif keycode == backspace and #current_input > 0 then
						current_input = current_input:sub(1, #current_input - 1)
					elseif
						user_input_service:IsKeyDown(Enum["KeyCode"]["LeftControl"])
						and user_input_service:IsKeyDown(Enum["KeyCode"]["V"])
					then
						local textbox = create_instance("TextBox", {
							["Name"] = "\0",
							["Parent"] = hui,
						})
						textbox:CaptureFocus()
						keypress(0xA2)
						keypress(0x56)
						wait()
						keyrelease(0xA2)
						keyrelease(0x56)
						local text = textbox["Text"]
						if text and #text > 0 then
							current_input ..= text
						end
						textbox["Parent"] = nil
						textbox:Destroy()
					elseif keycode then
						if label["TextBounds"]["X"] > limit then
							return
						end

						local letter = user_input_service:GetStringForKeyCode(keycode):lower()
						local byte = string["byte"](letter)

						if
							(allow_all and byte)
							or (
								byte
								and (
									not numbers
										and (byte == 32 or byte == 44 or byte == 46 or byte >= 97 and byte <= 122)
									or numbers and (byte == 44 or byte == 46 or byte >= 48 and byte <= 57)
								)
							)
						then
							current_input ..= (
								user_input_service:IsKeyDown(shift) and string["upper"] or string["lower"]
							)(letter)
						end

						callback(current_input)
					end

					label["Text"] = current_input

					if is_enter and only_on_enter or not only_on_enter then
						local ignore = callback(current_input, input)

						if ignore then
							current_input = last_input
						end
					end
				end
			end, false, unpack(items))

			label["Text"] = ""
		end
	)

	local do_search = LPH_JIT_MAX(function(text)
		local children = search_out["children"]
		hover_connections[search_out] = nil
		click_connections[search_out] = nil

		for _, child in children do
			children[_] = nil
			child:Destroy()
		end

		search_out_border["Visible"] = false

		if #text < 2 then
			return
		end

		local results = {}

		text = text:lower()

		for name, group in menu["groups"] do
			for name, tab in group["tabs"] do
				for _, section in tab["sections"] do
					local elements = section["elements"]
					for i = 1, #elements do
						local element = elements[i]
						local test = (element["name"] or "f"):lower():gsub(" ", "")
						if test:find(text) then
							results[#results + 1] = {
								group,
								tab,
								section,
								element,
							}
						end
					end
				end
			end
		end

		for element_settings, settings in menu["settings"] do
			local elements = settings["elements"]
			for i = 1, #elements do
				local element = elements[i]
				if (element["name"]:lower()):find(text) then
					results[#results + 1] = {
						element_settings,
						element,
						settings,
					}
				end
			end
		end

		local max_textbounds = 0

		if #results > 0 then
			search_out_border["Visible"] = true

			local size = 8 + #results * 12

			for i = 1, #results do
				local result = results[i]
				local path = nil
				local tab = nil
				local settings = nil
				local settings_element = nil
				local element = nil
				if #result == 3 then
					path = result[1]["name"] .. " > " .. result[2]["name"]
					settings = result[3]
					settings_element = result[1]
					element = result[2]
				else
					tab = result[2]
					path = result[3]["name"] .. " > " .. result[4]["name"]
					element = result[4]
				end

				local position = udim2_new(0, 3, 0, 3 + (i - 1) * 12)
				local text_click = drawing_proxy["new"]("Square", {
					["Size"] = udim2_new(1, -6, 0, 12),
					["Position"] = position,
					["Visible"] = true,
					["Filled"] = true,
					["Transparency"] = 0,
					["Parent"] = search_out,
				})
				local text = drawing_proxy["new"]("Text", {
					["Color"] = menu["colors"]["inactive_text"],
					["Text"] = path,
					["Size"] = 12,
					["Font"] = 1,
					["Transparency"] = 1,
					["Visible"] = true,
					["Parent"] = search_out,
					["Position"] = udim2_new(0, 3, 0, 3 + (i - 1) * 12),
					["ZIndex"] = 1001,
				})

				local textbounds = text["TextBounds"]
				if textbounds["X"] > max_textbounds then
					max_textbounds = textbounds["X"]
				end

				create_hover_connection(search_out, text_click, function()
					tween(text, { ["Color"] = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end, function()
					tween(text, { ["Color"] = menu["colors"]["inactive_text"] }, circular, out, 0.17)
				end)

				create_click_connection(search_out, text_click, function()
					stop_search()
					stop_typing()
					if not tab then
						for name, group in menu["groups"] do
							for name, potential_tab in group["tabs"] do
								for _, section in potential_tab["sections"] do
									local elements = section["elements"]
									for i = 1, #elements do
										if elements[i] == settings_element then
											tab = potential_tab
											break
										end
									end
								end
							end
						end
					end
					if tab and actives["tab"] ~= tab then
						set_active_tab(tab)
					end
					if settings then
						if tab then
							wait(0.075)
						end
						open_settings(settings)
					end
					local drawings = element["drawings"]
					local label = drawings["button_text"] or drawings["text"]
					tween(label, hide_transparency, circular, out, 0.33)
					delay(0.33, function()
						if menu_open then
							tween(label, show_transparency, circular, out, 0.33)
							delay(0.33, function()
								if menu_open then
									tween(label, hide_transparency, circular, out, 0.33)
									delay(0.33, function()
										if menu_open then
											tween(label, show_transparency, circular, out, 0.33)
										end
									end)
								end
							end)
						end
					end)
				end)
			end

			search_out_border["Size"] = udim2_new(0, max_textbounds + 8, 0, size)
			search_out_border["Position"] = udim2_new(0, 11, 1, -42 - size)
			search_out["Size"] = udim2_new(1, -2, 1, -2)

			local children = search_out["children"]
			for i = 1, #children do
				local child = children[i]
				if child["Size"] ~= 12 then
					child["Size"] = udim2_new(1, -6, 0, 12)
				end
			end
		end
	end)

	local start_search = function()
		tween(
			search_image,
			{ tween_position = udim2_new(0, 14, 1, -27), Color = menu["colors"]["highlighted"] },
			circular,
			out,
			0.15
		)
		tween(search_border, { ["Transparency"] = 1, ["Color"] = menu["colors"]["highlighted"] }, circular, out, 0.15)
		tween(search_inside, show_transparency, circular, out, 0.15)
		tween(search_text, show_transparency, circular, out, 0.15)
		search_border["Visible"] = true

		searching = true

		start_typing(search_text, 51, do_search, false, true, true, false)
	end

	local stop_binding = function(key)
		context_action_service:UnbindCoreAction(context_action_typing_core)
		tween(
			actives["binding"]["drawings"]["keybind_text"],
			{ ["Color"] = menu["colors"]["dark_text"] },
			circular,
			out,
			0.17
		)
		actives["binding"] = nil
	end

	local start_binding = function(element)
		actives["binding"] = element

		local drawings = element["drawings"]
		local keybind_border = drawings["keybind_border"]
		local keybind_inside = drawings["keybind_inside"]
		local keybind_text = drawings["keybind_text"]

		keybind_text["Text"] = "..."

		local size = keybind_text["TextBounds"]["X"] + 8

		keybind_border["Size"] = udim2_new(0, size, 0, 12)
		keybind_border["Position"] = udim2_new(1, -size, 0, 0)
		keybind_inside["Size"] = udim2_new(0, size - 2, 0, 10)
		keybind_text["Position"] = udim2_new(0, (size - 2) / 2, 0, -2)

		local escape = Enum["KeyCode"]["Escape"]
		local tilde = Enum["KeyCode"]["Tilde"]
		local items = Enum["KeyCode"]:GetEnumItems()

		for _, a in Enum["UserInputType"]:GetEnumItems() do
			items[#items + 1] = a
		end

		context_action_service:BindCoreAction(context_action_typing_core, function(_, state, input)
			local key = shortened_characters[input["UserInputType"]] and input["UserInputType"] or input["KeyCode"]

			if state == Enum["UserInputState"]["Begin"] and key ~= Enum["KeyCode"]["Unknown"] then
				if key == escape or key == tilde then
					key = nil
				end

				element:set_key(key)

				stop_binding()
			end
		end, false, unpack(items))

		tween(keybind_text, { Color = menu["colors"]["accent"] }, circular, out, 0.17)
	end

	local dropdown_border = drawing_proxy["new"]("Image", {
		["Position"] = udim2_new(0, 0, 0, 14),
		["Size"] = udim2_new(0, 0, 0, 15),
		["Color"] = menu["colors"]["border"],
		["Transparency"] = 0,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["ZIndex"] = 1003,
		["Visible"] = false,
	})

	local dropdown_inside = drawing_proxy["new"]("Image", {
		["Parent"] = dropdown_border,
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(1, -2, 1, -2),
		["Color"] = menu["colors"]["background"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 0,
		["ZIndex"] = 1004,
		["Visible"] = true,
	})

	local close_dropdown = function()
		local position = dropdown_border["real_position"]
		tween(
			dropdown_border,
			{ tween_position = udim2_new(0, position["X"], 0, position["Y"] - 5), Transparency = 0 },
			circular,
			out,
			0.15
		)
		tween(dropdown_inside, hide_transparency, circular, out, 0.15)
		local connections = click_connections[dropdown_border]

		if connections then
			for object, callback in connections do
				click_connections[object] = nil
			end
			click_connections[dropdown_border] = nil
		end

		local connections = hover_connections[dropdown_border]

		if connections then
			for object, callback in hover_connections[dropdown_border] do
				hover_connections[object] = nil
			end
		end

		local children = dropdown_inside["children"]
		for _, child in children do
			local children = child["children"]
			for i = 1, #children do
				tween(children[i], hide_transparency, circular, out, 0.15)
			end
		end

		local children = dropdown_inside["children"]
		for _, child in children do
			children[_] = nil

			delay(0.14, function()
				child:Destroy()
				local children = child["children"]
				for i = 1, #children do
					children[i]:Destroy()
				end
			end)
		end

		hover_connections[dropdown_border] = nil
		actives["dropdown"] = nil
	end

	local open_dropdown = function(element)
		actives["dropdown"] = element

		local border = element["drawings"]["dropdown_border"]
		local position = border["real_position"]
		local size = border["real_size"]
		dropdown_border["Position"] = udim2_new(0, position["X"], 0, position["Y"] + 15)
		dropdown_border["Visible"] = true
		tween(
			dropdown_border,
			{ tween_position = udim2_new(0, position["X"], 0, position["Y"] + 18), Transparency = 1 },
			circular,
			out,
			0.15
		)
		tween(dropdown_inside, show_transparency, circular, out, 0.15)

		local options = element["options"]
		dropdown_border["Size"] = udim2_new(0, size["X"], 0, (8 + #options * 12))
		dropdown_inside["Size"] = udim2_new(0, size["X"] - 2, 0, (8 + #options * 12) - 2)

		local selected_options = flags[element["dropdown_flag"]]

		local multi = element["multi"]

		for i = 1, #options do
			local option = options[i]
			local selected = nil
			if selected_options then
				for i = 1, #selected_options do
					if selected_options[i] == option then
						selected = true
						break
					end
				end
			end

			local option_click = drawing_proxy["new"]("Square", {
				["Parent"] = dropdown_inside,
				["Size"] = udim2_new(1, -6, 0, 12),
				["Transparency"] = 0,
				["Visible"] = true,
				["Filled"] = true,
				["Position"] = udim2_new(0, 3, 0, 3 + (i - 1) * 12),
			})
			local option_checkmark = drawing_proxy["new"]("Image", {
				["Parent"] = option_click,
				["Position"] = udim2_new(1, -8, 0, 2),
				["Size"] = udim2_new(0, 8, 0, 8),
				["Data"] = checkmark_image_data,
				["Transparency"] = 0,
				["ZIndex"] = 1005,
				["Color"] = menu["colors"]["highlighted"],
				["Visible"] = true,
			})
			local option_text = drawing_proxy["new"]("Text", {
				["Color"] = menu["colors"]["inactive_text"],
				["Text"] = option,
				["Size"] = 12,
				["Font"] = 1,
				["Transparency"] = 0,
				["Visible"] = true,
				["Parent"] = option_click,
				["ZIndex"] = 1005,
				["Position"] = udim2_new(0, 0, 0, 0),
			})

			tween(option_text, show_transparency, circular, out, 0.15)

			create_hover_connection(dropdown_border, option_click, function()
				if not selected then
					tween(option_text, { ["Color"] = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end
			end, function()
				if not selected then
					tween(option_text, { Color = menu["colors"]["inactive_text"] }, circular, out, 0.17)
				end
			end)

			create_click_connection(dropdown_border, option_click, function()
				local result = element:update_dropdown_value(option)
				if result then
					selected = true
					tween(option_checkmark, show_transparency, circular, out, 0.15)
					if not multi then
						close_dropdown(actives["dropdown"])
					end
				elseif result == false then
					selected = false
					tween(option_checkmark, hide_transparency, circular, out, 0.15)
					if not multi then
						close_dropdown(actives["dropdown"])
					end
				end
			end)

			if selected then
				option_text["Color"] = menu["colors"]["highlighted"]
				tween(option_checkmark, show_transparency, circular, out, 0.15)
			end
		end
	end

	local context_border = drawing_proxy["new"]("Image", {
		["Position"] = udim2_new(0, 0, 0, 14),
		["Size"] = udim2_new(0, 100, 0, 15),
		["Color"] = menu["colors"]["border"],
		["Transparency"] = 0,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["ZIndex"] = 998,
		["Visible"] = false,
	})

	local context_inside = drawing_proxy["new"]("Image", {
		["Parent"] = context_border,
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(1, -2, 1, -2),
		["Color"] = menu["colors"]["background"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 0,
		["ZIndex"] = 999,
		["Visible"] = true,
	})

	local keybind_border = drawing_proxy["new"]("Image", {
		["Position"] = udim2_new(0, 0, 0, 14),
		["Size"] = udim2_new(0, 170, 0, 20),
		["Color"] = menu["colors"]["border"],
		["Transparency"] = 0,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["ZIndex"] = 998,
		["Visible"] = false,
	})

	local keybind_inside = drawing_proxy["new"]("Image", {
		["Parent"] = keybind_border,
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(1, -2, 1, -2),
		["Color"] = menu["colors"]["background"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 0,
		["ZIndex"] = 999,
		["Visible"] = true,
	})

	local keybind_holder = drawing_proxy["new"]("Square", {
		["Parent"] = keybind_inside,
		["Position"] = udim2_new(0, 10, 0, 10),
		["Size"] = udim2_new(1, -20, 1, -20),
		["Transparency"] = 0,
		["Filled"] = true,
		["Visible"] = true,
	})

	local keybind_section = nil
	local copied_transparency = nil
	local copied_color = nil

	local close_keybind = function()
		local position = keybind_border["real_position"]
		tween(
			keybind_border,
			{ tween_position = udim2_new(0, position["X"], 0, position["Y"] - 5), Transparency = 0 },
			circular,
			out,
			0.15
		)
		tween(keybind_inside, hide_transparency, circular, out, 0.15)

		local keybind_elements = keybind_section["elements"]
		for i = #keybind_elements, 1, -1 do
			keybind_elements[i]:remove()
		end

		click_connections[keybind_inside] = nil
		hover_connections[keybind_inside] = nil

		actives["keybind"] = nil

		delay(0.15, function()
			if not actives["keybind"] then
				keybind_border["Visible"] = false
			end
		end)
	end

	local star = base64_decode(
		"iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAALGAAACxgBiam1EAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAADIGQEA6AMAAMgZAQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAACaOS8o1uPhvAAAALklEQVQYV2NgRAIQDgOUgpBIHAYggNE4AEISogfGxuBA2FBlEBrCASsAqWFgBAAZ8wBLe9n4/wAAAABJRU5ErkJggg=="
	)
	local autoload = base64_decode(
		"iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAMAAADz0U65AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAN1gAADdYBkG95nAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS40Et+mgwAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAACIXwEA6AMAAIhfAQDoAwAAUGFpbnQuTkVUIDUuMS40AAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAItCLPyg+gOlAAAAJklEQVQYV2NgBAIQAcQMQABiAEkoAyQJZ4BkIQwQBCkA80G6GBkBBlgAKnvLiKoAAAAASUVORK5CYII="
	)
	local context_buttons = {
		[1] = {
			"create keybind",
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAFE0AABRNAZTKjS8AAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAvQMCAOgDAAC9AwIA6AMAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAACZvWRFEAE3KwAAACtJREFUKFNjQAb/oQDKBQMmKI0TEFTAiG4kOiBoAgoAuxAIoFwwoNSRDAwA1K8T+Ha/C0cAAAAASUVORK5CYII="
			),
			LPH_JIT_MAX(function()
				local new_keybind_data = keybind_data[actives["context"]]
				local do_fire = false

				if not new_keybind_data then
					new_keybind_data = setmetatable({
						["key"] = nil,
						["method"] = 1,
						["value"] = nil,
						["activated"] = false,
						["original_value"] = nil,
						["type"] = nil,
						["element"] = actives["context"],
					}, keybind)

					do_fire = true
				end

				keybind_data[actives["context"]] = new_keybind_data

				local position = context_border["real_position"]
				local y_position = position["Y"] + context_border["real_size"]["Y"]
				keybind_border["Position"] = udim2_new(0, position["X"], 0, y_position)
				tween(
					keybind_border,
					{ tween_position = udim2_new(0, position["X"], 0, y_position + 5), Transparency = 1 },
					circular,
					out,
					0.15
				)
				tween(keybind_inside, show_transparency, circular, out, 0.15)
				keybind_border["Visible"] = true

				actives["keybind"] = actives["context"]

				local new_keybind = keybind_section:create_element({
					["name"] = "key",
				}, {
					["keybind"] = {
						["flag"] = tostring({}):sub(math_random(8, 12)),
					},
				}, true)

				new_keybind:set_key(new_keybind_data["key"])

				local activate_when = keybind_section:create_element({
					["name"] = "activate when",
				}, {
					["dropdown"] = {
						["flag"] = tostring({}):sub(math_random(8, 12)),
						["requires_one"] = true,
						["options"] = { "toggled", "not held", "held" },
						["default"] = { "toggled" },
					},
				}, true)

				local method = new_keybind_data["method"]

				activate_when:set_dropdown(
					method == 1 and { "toggled" } or method == 2 and { "not held" } or { "held" }
				)

				create_connection(activate_when["on_dropdown_change"], function(value)
					local value = value[1]
					new_keybind_data["method"] = value == "toggled" and 1 or value == "not held" and 2 or 3
					new_keybind_data:set_activated(value == "not held" and true or false)
				end)

				local active = actives["keybind"]

				if active["options"] then
					local was_nil = new_keybind_data["type"] == nil
					new_keybind_data["type"] = 1

					if was_nil then
						new_keybind_data["value"] = flags[active["dropdown_flag"]]
						new_keybind_data["original_value"] = new_keybind_data["value"]
					end

					local new_dropdown = keybind_section:create_element({
						["name"] = "new value",
					}, {
						["dropdown"] = {
							["default"] = new_keybind_data["value"],
							["flag"] = tostring({}):sub(math_random(8, 12)),
							["options"] = active["options"],
							["requires_one"] = active["requires_one"],
							["multi"] = active["multi"],
						},
					}, true)

					create_connection(new_dropdown["on_dropdown_change"], function(value)
						new_keybind_data["value"] = value

						if new_keybind_data["activated"] then
							actives["context"]:set_dropdown(value, true)
						end
					end)
				elseif active["slider_flag"] then
					local was_nil = new_keybind_data["type"] == nil

					new_keybind_data["type"] = 2

					if was_nil then
						new_keybind_data["value"] = flags[active["slider_flag"]]
						new_keybind_data["original_value"] = new_keybind_data["value"]
					end

					local new_slider = keybind_section:create_element({
						name = "new value",
					}, {
						["slider"] = {
							["default"] = new_keybind_data["value"],
							["flag"] = tostring({}):sub(math_random(8, 12)),
							["min"] = active["slider_min"],
							["max"] = active["slider_max"],
							["min_text"] = active["slider_min_text"],
							["prefix"] = active["slider_prefix"],
							["suffix"] = active["slider_suffix"],
							["max_text"] = active["slider_max_text"],
							["decimals"] = active["slider_decimals"],
						},
					}, true)

					create_connection(new_slider["on_slider_change"], function(value)
						new_keybind_data["value"] = value
						on_keybind_updated:Fire(new_keybind_data, actives["context"])

						if new_keybind_data["activated"] then
							actives["context"]:set_slider(value, true)
						end
					end)
				elseif active["toggle_flag"] then
					new_keybind_data["type"] = 3

					new_keybind_data["value"] = flags[active["toggle_flag"]]
					new_keybind_data["original_value"] = flags[active["toggle_flag"]]
				else
					activate_when:set_visible(false)
					new_keybind_data["type"] = 4
					new_keybind_data["method"] = 1
				end

				create_connection(new_keybind["on_key_change"], function(key)
					new_keybind_data["key"] = key
				end)

				if do_fire then
					on_keybind_created:Fire(new_keybind_data, actives["context"])
				end
			end),
		},
		[2] = {
			"delete keybind",
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAADHcBAOgDAAAMdwEA6AMAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADu6i0YxswAAgAAAChJREFUKFNjQAb/oQDKBQNGEIEuCAOMQABl4gYETWCCsnECmitgYAAAtW8QA/NoRH8AAAAASUVORK5CYII="
			),
			function()
				local data = keybind_data[actives["context"]]

				if data then
					if data["type"] ~= 4 then
						data:set_activated(false)
					end
					keybind_data[actives["context"]] = nil
					on_keybind_deleted:Fire(data, actives["context"])
				end

				close_context()
			end,
		},
		[3] = {
			"paste color",
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAMAAAC67D+PAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAN1gAADdYBkG95nAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAACIXwEA6AMAAIhfAQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAALVxYeXXxjBrAAAALklEQVQYV2NgBAMGBgZGCBPEAGIIC04ASRgBkgeqBdPI4ig6wAIQFlgtmMXICAAM5AA7FWCogwAAAABJRU5ErkJggg=="
			),
			function()
				if copied_color and copied_transparency then
					actives["context"]:set_colorpicker(copied_color)
					actives["context"]:set_colorpicker_transparency(copied_transparency)
				end
				close_context()
			end,
		},
		[4] = {
			"copy color",
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAASRkBAOgDAABJGQEA6AMAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAAAv0m/2Gfr+yQAAAEFJREFUKFNjZEAC/4EAykQBjCAAZYMBLoUgwAQi8CmAASZiFIEA2ERiAPUVMiK7ET0UkAGKQmwAppkJnykIwMAAAFFQGAl6/FkNAAAAAElFTkSuQmCC"
			),
			function()
				copied_color = flags[actives["context"]["color_flag"]]
				copied_transparency = flags[actives["context"]["transparency_flag"]]
				close_context()
			end,
		},
		[5] = {
			"favorite",
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAMAAADz0U65AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAALGAAACxgBiam1EAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAADIGQEA6AMAAMgZAQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAACaOS8o1uPhvAAAAH0lEQVQYV2NghAIQgwFMwBlwAGWCpMA0MgOkkpGBEQAF1gAlfZ5svQAAAABJRU5ErkJggg=="
			),
			function()
				local active = actives["context"]
				local favorites = menu["favorites"]
				local flag = active["favorite_flag"]

				if not favorites[flag] then
					favorites[flag] = true
					menu["saved"] = true
					active["favorited"] = true
					active["parent"]:add_icon(active["drawings"]["text"]["Text"], star)

					writefile(
						file_path .. "/data.dat",
						http_service:JSONEncode({
							["notifications"] = do_notifications,
							["favorites"] = menu["favorites"],
							["theme"] = menu["theme"],
							["autoload"] = menu["autoload"],
						})
					)
				end

				close_context()
			end,
		},
		[6] = {
			"unfavorite",
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAMAAADz0U65AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAALGAAACxgBiam1EAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAADIGQEA6AMAAMgZAQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAACaOS8o1uPhvAAAAH0lEQVQYV2NghAIQgwFMwBlwAGWCpMA0MgOkkpGBEQAF1gAlfZ5svQAAAABJRU5ErkJggg=="
			),
			function()
				local active = actives["context"]

				local favorites = menu["favorites"]
				local flag = active["favorite_flag"]
				if favorites[flag] then
					favorites[flag] = nil
					active["favorited"] = false
					active["parent"]:remove_icon(active["drawings"]["text"]["Text"], star)
					menu["saved"] = true

					writefile(
						file_path .. "/data.dat",
						http_service:JSONEncode({
							["notifications"] = do_notifications,
							["favorites"] = menu["favorites"],
							["theme"] = menu["theme"],
							["autoload"] = menu["autoload"],
						})
					)
				end

				close_context()
			end,
		},
		[7] = {
			"paste clipboard",
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAOxAAADsQBlSsOGwAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS40Et+mgwAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAAAMdwEA6AMAAAx3AQDoAwAAUGFpbnQuTkVUIDUuMS40AAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAANDZYAGx8DPMAAAAHklEQVQYV2NgBAEGKAVhQ3hAAsyCEBBxEKAXh5ERABXWAD2lxbDCAAAAAElFTkSuQmCC"
			),
			function()
				local textbox = create_instance("TextBox", {
					["Parent"] = hui,
				})
				textbox:CaptureFocus()
				keypress(0xA2)
				keypress(0x56)
				wait()
				wait()
				keyrelease(0xA2)
				keyrelease(0x56)
				local text = textbox["Text"]
				textbox:Destroy()

				local r, g, b = 255, 255, 255
				local a = 0

				local trimmed_text = (text:match("^%s*(.-)%s*$") or ""):lower():gsub("%s+", "")

				local parsed = false

				local hex_digits = trimmed_text:match("^#?([0-9a-f]+)$")
				if hex_digits then
					local len = #hex_digits
					if len == 6 then
						local r_val = tonumber(hex_digits:sub(1, 2), 16)
						local g_val = tonumber(hex_digits:sub(3, 4), 16)
						local b_val = tonumber(hex_digits:sub(5, 6), 16)
						if r_val and g_val and b_val then
							r, g, b = r_val, g_val, b_val
							parsed = true
						end
					elseif len == 8 then
						local r_val = tonumber(hex_digits:sub(1, 2), 16)
						local g_val = tonumber(hex_digits:sub(3, 4), 16)
						local b_val = tonumber(hex_digits:sub(5, 6), 16)
						local a_val = tonumber(hex_digits:sub(7, 8), 16)
						if r_val and g_val and b_val and a_val then
							r, g, b = r_val, g_val, b_val
							a = 1 - (math["min"](math["max"](a_val, 0), 255) / 255)
							parsed = true
						end
					end
				end

				if not parsed then
					local r_str, g_str, b_str, a_str = trimmed_text:match("^(%d+),(%d+),(%d+),?(%d*)$")
					if r_str and g_str and b_str then
						local r_val = tonumber(r_str)
						local g_val = tonumber(g_str)
						local b_val = tonumber(b_str)
						if r_val and g_val and b_val then
							r, g, b = r_val, g_val, b_val
							if a_str and #a_str > 0 then
								local a_val = tonumber(a_str)
								if a_val then
									a = 1 - (math["min"](math["max"](a_val, 0), 255) / 255)
								end
							end
						end
					end
				end

				if r and g and b then
					actives["context"]:set_colorpicker(color3_fromrgb(r, g, b))
					actives["context"]:set_colorpicker_transparency(a or 0)
					close_context()
				end
			end,
		},
		[8] = {
			"autoload config",
			autoload,
			function()
				local active = actives["context"]
				local name = active["name"]

				if menu["autoload"] ~= name then
					menu["autoload"] = name
					menu["saved"] = true
					local parent = active["parent"]
					local elements = parent["elements"]

					for _, element in next, elements do
						parent:remove_icon(element["name"], autoload)
					end

					active["parent"]:add_icon(active["drawings"]["text"]["Text"], autoload)

					writefile(
						file_path .. "/data.dat",
						http_service:JSONEncode({
							["notifications"] = do_notifications,
							["favorites"] = menu["favorites"],
							["theme"] = menu["theme"],
							["autoload"] = menu["autoload"],
						})
					)
				end

				close_context()
			end,
		},
		[9] = {
			"stop autoload",
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAMAAADz0U65AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAPhwAAD4cBYAYLnAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS40Et+mgwAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAAB+igEA6AMAAH6KAQDoAwAAUGFpbnQuTkVUIDUuMS40AAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAANdbGZi1Ab9fAAAAJElEQVQYV2NgYGAEAiAFZoFJMBtIQbnIDBANVQERBNGMjAwMAAOoABlFkxrMAAAAAElFTkSuQmCC"
			),
			function()
				local active = actives["context"]
				local active = actives["context"]
				local name = active["name"]

				if menu["autoload"] == name then
					menu["autoload"] = nil
					menu["saved"] = true
					active["parent"]:remove_icon(active["drawings"]["text"]["Text"], autoload)

					writefile(
						file_path .. "/data.dat",
						http_service:JSONEncode({
							["notifications"] = do_notifications,
							["favorites"] = menu["favorites"],
							["theme"] = menu["theme"],
							["autoload"] = menu["autoload"],
						})
					)
				end

				close_context()
			end,
		},
	}

	for i = 1, #context_buttons do
		local button = context_buttons[i]

		local button_click = drawing_proxy["new"]("Image", {
			["Parent"] = context_inside,
			["Size"] = udim2_new(1, 0, 0, 16),
			["Transparency"] = 0,
			["Color"] = menu["colors"]["background"],
			["Visible"] = true,
			["ZIndex"] = 999,
			["Data"] = pixel_image_data,
			["Rounding"] = 4,
		})

		local button_text = drawing_proxy["new"]("Text", {
			["Color"] = menu["colors"]["inactive_text"],
			["Text"] = button[1],
			["Size"] = 12,
			["Font"] = 1,
			["Transparency"] = 0,
			["Visible"] = true,
			["Parent"] = button_click,
			["Center"] = false,
			["Position"] = udim2_new(0, 18, 0, 1),
			["ZIndex"] = 1000,
		})

		local button_icon = drawing_proxy["new"]("Image", {
			["Data"] = button[2],
			["Color"] = menu["colors"]["accent"],
			["Size"] = udim2_new(0, 8, 0, 8),
			["Transparency"] = 0,
			["Visible"] = true,
			["Parent"] = button_click,
			["Position"] = udim2_new(0, 5, 0, 4),
			["ZIndex"] = 1000,
		})

		create_hover_connection(context_border, button_click, function()
			local h, s, v = menu["colors"]["background"]:ToHSV()

			tween(button_click, { Color = Color3["fromHSV"](h, s, clamp(v * 1.5, 0.1, 1)) }, circular, out, 0.15)
		end, function()
			tween(button_click, { Color = menu["colors"]["background"] }, circular, out, 0.15)
		end)

		create_click_connection(context_border, button_click, button[3])

		context_buttons[i] = {
			["frame"] = button_click,
			["text"] = button_text,
			["icon"] = button_icon,
		}
	end

	local open_context = function(buttons, element, position)
		local x_position = position["X"] + 15
		local y_position = 0

		context_border["Visible"] = true
		context_border["Position"] = udim2_new(0, x_position, 0, position["Y"] - 5)
		tween(
			context_border,
			{ Transparency = 1, tween_position = udim2_new(0, x_position, 0, position["Y"]) },
			circular,
			out,
			0.15
		)
		tween(context_inside, show_transparency, circular, out, 0.15)

		for i = 1, #context_buttons do
			context_buttons[i]["frame"]["Visible"] = false
		end

		local textbounds = 0

		for i = 1, #buttons do
			local index = buttons[i]
			local button = context_buttons[index]
			local callback = buttons[i]

			if callback then
				local frame = button["frame"]

				frame["Visible"] = true
				tween(frame, show_transparency, circular, out, 0.15)
				tween(button["text"], show_transparency, circular, out, 0.15)
				tween(button["icon"], half_transparency, circular, out, 0.15)
				frame["Position"] = udim2_new(0, 0, 0, y_position)

				if index == 1 then
					button["text"]["Text"] = keybind_data[element] and "edit keybind" or "create keybind"
				end

				local button_textbounds = button["text"]["TextBounds"]["X"]
				if button_textbounds > textbounds then
					textbounds = button_textbounds
				end
			end

			y_position = y_position + 16
		end

		context_border["Size"] = udim2_new(0, textbounds + 25, 0, y_position + 2)
		context_inside["Size"] = udim2_new(0, textbounds + 23, 0, y_position)

		for i = 1, #buttons do
			context_buttons[buttons[i]]["frame"]["Size"] = udim2_new(1, 0, 0, 16)
		end

		actives["context"] = element
	end

	close_context = function()
		local position = context_border["real_position"]

		tween(
			context_border,
			{ Transparency = 0, tween_position = udim2_new(0, position["X"], 0, position["Y"] - 5) },
			circular,
			out,
			0.15
		)
		tween(context_inside, hide_transparency, circular, out, 0.15)

		for i = 1, #context_buttons do
			local button = context_buttons[i]
			local frame = button["frame"]

			if frame["Visible"] then
				tween(frame, hide_transparency, circular, out, 0.15)
				tween(button["text"], hide_transparency, circular, out, 0.15)
				tween(button["icon"], hide_transparency, circular, out, 0.15)
			end
		end

		delay(0.15, function()
			if actives["context"] == nil then
				context_border["Visible"] = false
			end
		end)

		actives["context"] = nil
	end

	local colorpicker_border = drawing_proxy["new"]("Image", {
		["Position"] = udim2_new(0, 0, 0, 14),
		["Size"] = udim2_new(0, 185, 0, 221),
		["Color"] = menu["colors"]["border"],
		["Transparency"] = 0,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["ZIndex"] = 998,
		["Visible"] = false,
	})

	local colorpicker_inside = drawing_proxy["new"]("Image", {
		["Parent"] = colorpicker_border,
		["Position"] = udim2_new(0, 1, 0, 1),
		["Size"] = udim2_new(1, -2, 1, -2),
		["Color"] = menu["colors"]["background"],
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["Transparency"] = 0,
		["ZIndex"] = 999,
		["Visible"] = true,
	})

	local colorpicker_saturation_background = drawing_proxy["new"]("Image", {
		["Parent"] = colorpicker_inside,
		["Position"] = udim2_new(0, 10, 0, 10),
		["Size"] = udim2_new(0, 163, 0, 163),
		["Color"] = color3_fromrgb(255, 255, 255),
		["Transparency"] = 1,
		["Rounding"] = 4,
		["Data"] = pixel_image_data,
		["ZIndex"] = 1000,
		["Visible"] = true,
	})

	local colorpicker_saturation = drawing_proxy["new"]("Image", {
		["Parent"] = colorpicker_saturation_background,
		["Position"] = udim2_new(0, 0, 0, 0),
		["Size"] = udim2_new(0, 163, 0, 163),
		["Color"] = color3_fromrgb(255, 0, 0),
		["Transparency"] = 1,
		["Rounding"] = 4,
		["Data"] = readfile(file_path .. "/assets/saturation.png"),
		["ZIndex"] = 1001,
		["Visible"] = true,
	})

	local colorpicker_saturation_dragger = drawing_proxy["new"]("Circle", {
		["Radius"] = identifyexecutor() == "AWP" and 5 or 6,
		["Color"] = color3_fromrgb(255, 255, 255),
		["Position"] = udim2_new(0, 159, 0, 4),
		["Transparency"] = 0,
		["Thickness"] = identifyexecutor() == "AWP" and 2 or 4,
		["Parent"] = colorpicker_saturation,
		["Visible"] = true,
		["ZIndex"] = 1002,
	})

	local colorpicker_transparency = drawing_proxy["new"]("Image", {
		["Parent"] = colorpicker_inside,
		["Position"] = udim2_new(0, 10, 0, 183),
		["Size"] = udim2_new(0, 163, 0, 8),
		["Color"] = color3_fromrgb(255, 255, 255),
		["Transparency"] = 1,
		["Rounding"] = 4,
		["Data"] = base64_decode(
			"iVBORw0KGgoAAAANSUhEUgAAAKAAAAAICAIAAADx4mP5AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADp1fY4ytpsegAAAEVJREFUWEftkTEKACAQw6r/f7TgrTf0EJeSTA10yyr2pUarzmekzuefOp8XdT4jdT69CqIhcDgEDofA4RA4HAKHQ+BopAN55gMK+LqL+AAAAABJRU5ErkJggg=="
		),
		["ZIndex"] = 1001,
		["Visible"] = true,
	})

	local colorpicker_transparency_dragger = drawing_proxy["new"]("Circle", {
		["Radius"] = identifyexecutor() == "AWP" and 3 or 5,
		["Color"] = color3_fromrgb(0, 0, 0),
		["Position"] = udim2_new(0, 4, 0, 4),
		["Transparency"] = 0,
		["Thickness"] = identifyexecutor() == "AWP" and 1 or 4,
		["Filled"] = true,
		["Parent"] = colorpicker_transparency,
		["Visible"] = true,
		["ZIndex"] = 1002,
	})

	local colorpicker_transparency_dragger_overlay = drawing_proxy["new"]("Circle", {
		["Radius"] = identifyexecutor() == "AWP" and 2 or 7,
		["Color"] = color3_fromrgb(255, 255, 255),
		["Transparency"] = 0,
		["Radius"] = identifyexecutor() == "AWP" and 2 or 4,
		["Parent"] = colorpicker_transparency_dragger,
		["Position"] = udim2_new(0, 0, 0, 0),
		["Visible"] = true,
		["ZIndex"] = 1003,
	})

	local colorpicker_hue = drawing_proxy["new"]("Image", {
		["Parent"] = colorpicker_inside,
		["Position"] = udim2_new(0, 10, 0, 201),
		["Size"] = udim2_new(0, 163, 0, 8),
		["Color"] = color3_fromrgb(255, 255, 255),
		["Transparency"] = 1,
		["Rounding"] = 4,
		["Data"] = base64_decode(
			"iVBORw0KGgoAAAANSUhEUgAAAKAAAAAICAIAAADx4mP5AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADp1fY4ytpsegAAAHJJREFUWEftkW0LgCAMhM9ArP7/b60gSmlGWOILfRz3cIzbhDE54y0wieak5qZ7fjiswIKr5ubHfIOR7U3FI1ra7Wv7Y0q18iTVnenvb6Vt5enTRj/Cy/ZOxVOKGkBUw4CVw4CVw4CVw4CVw4CVw4BVAwRG9lMU6VQQuwAAAABJRU5ErkJggg=="
		),
		["ZIndex"] = 1001,
		["Visible"] = true,
	})

	local colorpicker_hue_dragger = drawing_proxy["new"]("Circle", {
		["Radius"] = identifyexecutor() == "AWP" and 3 or 5,
		["Color"] = color3_fromrgb(255, 255, 255),
		["Position"] = udim2_new(0, 4, 0, 4),
		["Transparency"] = 0,
		["Thickness"] = identifyexecutor() == "AWP" and 2 or 4,
		["Parent"] = colorpicker_hue,
		["Visible"] = true,
		["ZIndex"] = 1002,
	})

	local set_colorpicker_color = function(color, set)
		colorpicker_saturation["Color"] = Color3.fromHSV(actives["colorpicker_hue"], 1, 1)

		tween(
			colorpicker_hue_dragger,
			{ tween_position = udim2_new(0, clamp(actives["colorpicker_hue"] * 163, 6, 157), 0, 4) },
			circular,
			out,
			0.1
		)
		tween(colorpicker_saturation_dragger, {
			tween_position = udim2_new(
				0,
				clamp(actives["colorpicker_saturation"] * 163, 6, 157),
				0,
				clamp((1 - actives["colorpicker_value"]) * 163, 6, 157)
			),
		}, circular, out, 0.1)

		if set then
			actives["colorpicker"]:set_colorpicker(color)
		end
	end

	local set_colorpicker_transparency = function(transparency, set)
		tween(
			colorpicker_transparency_dragger,
			{ tween_position = udim2_new(0, clamp((1 - transparency) * 163, 6, 157), 0, 4) },
			circular,
			out,
			0.1
		)

		if set then
			actives["colorpicker"]:set_colorpicker_transparency(transparency)
		end
	end

	create_click_connection(colorpicker_border, colorpicker_saturation, function(position)
		local frame_position = colorpicker_saturation["real_position"]
		local frame_position_x = frame_position["X"]
		local frame_position_y = frame_position["Y"]

		actives["colorpicker_saturation"] = clamp((position["X"] - frame_position_x) / 163, 0, 1)
		actives["colorpicker_value"] = clamp((163 - (position["Y"] - frame_position_y)) / 163, 0, 1)

		set_colorpicker_color(
			Color3.fromHSV(actives["colorpicker_hue"], actives["colorpicker_saturation"], actives["colorpicker_value"]),
			true
		)

		moving = create_connection(mouse["Move"], function()
			local position = get_mouse_location(user_input_service)

			actives["colorpicker_saturation"] = clamp((position["X"] - frame_position_x) / 163, 0, 1)
			actives["colorpicker_value"] = clamp((163 - (position["Y"] - frame_position_y)) / 163, 0, 1)

			set_colorpicker_color(
				Color3.fromHSV(
					actives["colorpicker_hue"],
					actives["colorpicker_saturation"],
					actives["colorpicker_value"]
				),
				true
			)
		end)
	end)

	create_click_connection(colorpicker_border, colorpicker_hue, function(position)
		local frame_position_x = colorpicker_hue["real_position"]["X"]

		actives["colorpicker_hue"] = clamp((position["X"] - frame_position_x) / 163, 0, 1)

		set_colorpicker_color(
			Color3.fromHSV(actives["colorpicker_hue"], actives["colorpicker_saturation"], actives["colorpicker_value"]),
			true
		)

		moving = create_connection(mouse["Move"], function()
			actives["colorpicker_hue"] =
				clamp((get_mouse_location(user_input_service)["X"] - frame_position_x) / 158, 0, 1)
			set_colorpicker_color(
				Color3.fromHSV(
					actives["colorpicker_hue"],
					actives["colorpicker_saturation"],
					actives["colorpicker_value"]
				),
				true
			)
		end)
	end)

	create_click_connection(colorpicker_border, colorpicker_transparency, function(position)
		local frame_position_x = colorpicker_transparency["real_position"]["X"]

		set_colorpicker_transparency(clamp(1 - (position["X"] - frame_position_x) / 163, 0, 1), true)

		moving = create_connection(mouse["Move"], function()
			set_colorpicker_transparency(
				clamp(1 - (get_mouse_location(user_input_service)["X"] - frame_position_x) / 163, 0, 1),
				true
			)
		end)
	end)

	local open_colorpicker = function(element)
		local position = element["drawings"]["colorpicker_border"]["real_position"]
		local x_position = position["X"] + 30
		local screen_size = camera["ViewportSize"]
		local x_size = screen_size["X"]
		local y_size = screen_size["Y"]

		local x_overlap = (x_position + colorpicker_inside["real_size"]["X"]) - x_size
		local y_overlap = (position["Y"] + colorpicker_inside["real_size"]["Y"]) - y_size

		if x_overlap > 0 then
			x_position -= (x_overlap + 5)
		elseif x_overlap < -x_size then
			x_position += (-x_overlap + 5)
		end

		if y_overlap > 0 then
			position -= vector2_new(0, y_overlap + 5)
		elseif y_overlap < -y_size then
			position += vector2_new(0, y_overlap + 5)
		end

		colorpicker_border["Visible"] = true
		colorpicker_border["Position"] = udim2_new(0, x_position, 0, position["Y"] - 5)

		tween(
			colorpicker_border,
			{ Transparency = 1, tween_position = udim2_new(0, x_position, 0, position["Y"]) },
			circular,
			out,
			0.15
		)
		tween(colorpicker_inside, show_transparency, circular, out, 0.15)
		tween(colorpicker_saturation_background, show_transparency, circular, out, 0.15)
		tween(colorpicker_saturation, show_transparency, circular, out, 0.15)
		tween(colorpicker_transparency, show_transparency, circular, out, 0.15)
		tween(colorpicker_hue, show_transparency, circular, out, 0.15)
		tween(colorpicker_transparency_dragger, show_transparency, circular, out, 0.15)
		tween(colorpicker_transparency_dragger_overlay, show_transparency, circular, out, 0.15)
		tween(colorpicker_hue_dragger, show_transparency, circular, out, 0.15)
		tween(colorpicker_saturation_dragger, show_transparency, circular, out, 0.15)

		local color = flags[element["color_flag"]]

		actives["colorpicker_hue"], actives["colorpicker_saturation"], actives["colorpicker_value"] = color:ToHSV()

		if actives["colorpicker_saturation"] < 0.001 then
			actives["colorpicker_hue"] = 1
		end

		set_colorpicker_color(color)
		set_colorpicker_transparency(flags[element["transparency_flag"]])

		actives["colorpicker"] = element
	end

	local close_colorpicker = function()
		local position = colorpicker_border["real_position"]
		tween(
			colorpicker_border,
			{ Transparency = 0, tween_position = udim2_new(0, position["X"], 0, position["Y"] - 5) },
			circular,
			out,
			0.15
		)
		tween(colorpicker_inside, hide_transparency, circular, out, 0.15)
		tween(colorpicker_saturation_background, hide_transparency, circular, out, 0.15)
		tween(colorpicker_saturation, hide_transparency, circular, out, 0.15)
		tween(colorpicker_transparency, hide_transparency, circular, out, 0.15)
		tween(colorpicker_hue, hide_transparency, circular, out, 0.15)
		tween(colorpicker_transparency_dragger, hide_transparency, circular, out, 0.15)
		tween(colorpicker_transparency_dragger_overlay, hide_transparency, circular, out, 0.15)
		tween(colorpicker_hue_dragger, hide_transparency, circular, out, 0.15)
		tween(colorpicker_saturation_dragger, hide_transparency, circular, out, 0.15)

		actives["colorpicker"] = nil

		delay(0.15, function()
			if actives["colorpicker"] == nil then
				colorpicker_border["Visible"] = false
			end
		end)
	end

	stop_panel_search = function()
		tween(actives["panel"]["search_border"], { Color = menu["colors"]["border"] }, circular, out, 0.15)
		tween(actives["panel"]["search_image"], { Color = menu["colors"]["border"] }, circular, out, 0.15)
		tween(actives["panel"]["search_text"], { Color = menu["colors"]["inactive_text"] }, circular, out, 0.15)

		local panel = actives["panel"]
		actives["panel"] = nil
		panel:update_position()
	end

	local do_panel_search = function(search_text)
		if not actives["panel"] then
			return
		end

		actives["panel"]["scroll_index"] = 1

		local elements = actives["panel"]["elements"]
		local search_text = search_text:lower()
		local search_index = 0

		for i = 1, #elements do
			local element = elements[i]
			local drawings = element["drawings"]
			local frame = drawings["border"]
			local text = drawings["text"]
			local text2 = element["text2"]
			if
				search_index < 13
				and (text["Text"]:lower():find(search_text) or text2 and text2:lower():find(search_text))
			then
				search_index += 1
				frame["Visible"] = true
				frame["Position"] = udim2_new(0, 0, 0, 30 + (search_index - 1) * 30)
			else
				frame["Visible"] = false
			end
		end
	end

	local start_panel_search = function(element)
		actives["panel"] = element

		start_typing(actives["panel"]["search_text"], 150, do_panel_search, false, true, true, false)

		tween(actives["panel"]["search_border"], { Color = menu["colors"]["highlighted"] }, circular, out, 0.15)
		tween(actives["panel"]["search_image"], { Color = menu["colors"]["highlighted"] }, circular, out, 0.15)
		tween(actives["panel"]["search_text"], { Color = menu["colors"]["active_text"] }, circular, out, 0.15)
	end

	menu_references["input_handlers"] = (function()
	local function point_in_bounds(x, y, position, size)
		return x > position["X"]
			and x < position["X"] + size["X"]
			and y > position["Y"]
			and y < position["Y"] + size["Y"]
	end

	local function finish_drag()
		if not moving then
			return
		end
		moving:Disconnect()
		moving = nil
		if not drag_frame["Visible"] then
			return
		end
		frame["Position"] = menu_position
		frame["Visible"] = true
		tween(drag_frame, hide_transparency, circular, out, 0.12)
		tween(drag_logo, hide_transparency, circular, out, 0.12)
		tween(drag_inside, hide_transparency, circular, out, 0.12)
		delay(0.12, function()
			if not moving then
				drag_frame["Visible"] = false
			end
		end)
	end

	local function dismiss_outside_popup(mouse_x, mouse_y)
		if actives["dropdown"] then
			local border = actives["dropdown"]["drawings"]["dropdown_border"]
			local position = border["real_position"] + vector2_new(0, 18)
			if not point_in_bounds(mouse_x, mouse_y, position, dropdown_border["real_size"]) then
				close_dropdown(actives["dropdown"])
				return true
			end
		elseif actives["colorpicker"] then
			if not point_in_bounds(mouse_x, mouse_y, colorpicker_border["real_position"], colorpicker_border["real_size"]) then
				close_colorpicker(actives["colorpicker"])
				return true
			end
		elseif actives["keybind"] then
			if not point_in_bounds(mouse_x, mouse_y, keybind_border["real_position"], keybind_border["real_size"]) then
				close_keybind(actives["keybind"])
				close_context(actives["context"])
				return true
			end
		elseif actives["context"] then
			if not point_in_bounds(mouse_x, mouse_y, context_border["real_position"], context_border["real_size"]) then
				close_context(actives["context"])
				return true
			end
		elseif actives["settings"] then
			local border = actives["settings"]["border"]
			if not point_in_bounds(mouse_x, mouse_y, border["real_position"], border["real_size"]) then
				close_settings(actives["settings"])
				return true
			end
		end
		return false
	end

	local function dispatch_registered_clicks(connections, mouse_position, mouse_x, mouse_y)
		for object, callbacks in connections do
			if object["is_rendering"] and point_in_bounds(mouse_x, mouse_y, object["real_position"], object["real_size"]) then
				for i = 1, #callbacks do
					callbacks[i](mouse_position)
				end
				return true
			end
		end
		return false
	end

	local function dispatch_menu_click(mouse_position, mouse_x, mouse_y)
		for object, children in click_connections do
			if object["is_rendering"] and point_in_bounds(mouse_x, mouse_y, object["real_position"], object["real_size"]) then
				for child, callbacks in children do
					if child["is_rendering"] and point_in_bounds(mouse_x, mouse_y, child["real_position"], child["real_size"]) then
						for i = 1, #callbacks do
							callbacks[i](mouse_position)
						end
						return true
					end
				end
			end
		end
		return false
	end

	local function start_menu_drag(mouse_x, mouse_y)
		local original_position = frame["real_position"]
		moving = create_connection(mouse["Move"], function()
			if not drag_frame["Visible"] then
				drag_frame["Visible"] = true
				tween(drag_frame, show_transparency, circular, out, 0.05)
				tween(drag_logo, show_transparency, circular, out, 0.05)
				tween(drag_inside, show_transparency, circular, out, 0.05)
				drag_frame["Position"] = menu_position
				delay(0.02, function()
					if moving then
						frame["Visible"] = false
					end
				end)
			end
			local position = get_mouse_location(user_input_service)
			local new_position = udim2_new(0, original_position["X"] - (mouse_x - position["X"]), 0, original_position["Y"] - (mouse_y - position["Y"]))
			if math["abs"](menu_position["X"]["Offset"] - new_position["X"]["Offset"]) > 1.1 or math["abs"](menu_position["Y"]["Offset"] - new_position["Y"]["Offset"]) > 1.1 then
				drag_frame["Position"] = new_position
				menu_position = new_position
			end
		end)
	end

	local function start_hud_drag(flag, hud, mouse_x, mouse_y)
		local original_position = hud["real_position"]
		moving = create_connection(mouse["Move"], function()
			local position = get_mouse_location(user_input_service)
			local new_x = original_position["X"] - (mouse_x - position["X"])
			local new_y = original_position["Y"] - (mouse_y - position["Y"])
			list_frame["Position"] = udim2_new(0, new_x, 0, new_y)
			flags[flag] = { new_x, new_y }
		end)
	end

	local function dispatch_hud_click(mouse_x, mouse_y)
		for flag, hud in hud_frames do
			if hud["is_rendering"] and point_in_bounds(mouse_x, mouse_y, hud["real_position"], hud["real_size"]) then
				start_hud_drag(flag, hud, mouse_x, mouse_y)
				return
			end
		end
	end

	local function handle_click(_, state, input)
		finish_drag()

		if input["UserInputType"] ~= Enum["UserInputType"]["MouseButton1"] and input["UserInputType"] ~= Enum["UserInputType"]["Touch"] then
			return
		end
		if state ~= Enum["UserInputState"]["Begin"] then
			return
		end

		if active_typing then
			delay(0, function()
				stop_typing(active_typing)
				if searching then
					stop_search()
				end
				if actives["panel"] then
					stop_panel_search()
				end
			end)
		end

		local mouse_position = get_mouse_location(user_input_service)
		local mouse_x = mouse_position["X"]
		local mouse_y = mouse_position["Y"]
		if dismiss_outside_popup(mouse_x, mouse_y) then
			return
		end

		local connections = searching and click_connections[search_out]
			or actives["colorpicker"] and click_connections[colorpicker_border]
			or actives["dropdown"] and click_connections[dropdown_border]
			or actives["keybind"] and click_connections[keybind_inside]
			or actives["context"] and click_connections[context_border]
			or actives["settings"] and click_connections[actives["settings"]["inside"]]
			or nil

		if connections or point_in_bounds(mouse_x, mouse_y, frame["real_position"], frame["real_size"]) then
			if not connections then
				if not dispatch_menu_click(mouse_position, mouse_x, mouse_y) then
					start_menu_drag(mouse_x, mouse_y)
				end
			else
				dispatch_registered_clicks(connections, mouse_position, mouse_x, mouse_y)
			end
		else
			dispatch_hud_click(mouse_x, mouse_y)
		end
	end

	local function handle_scroll(_, state, input)
		if state ~= Enum["UserInputState"]["Change"] or input["UserInputType"] ~= Enum["UserInputType"]["MouseWheel"] then
			return
		end

		local mouse_position = get_mouse_location(user_input_service)
		local mouse_x = mouse_position["X"]
		local mouse_y = mouse_position["Y"]
		local is_up = input["Position"]["Z"] > 0

		if
			mouse_x > menu_position["X"]["Offset"]
			and mouse_x < menu_position["X"]["Offset"] + frame["Size"]["X"]
			and mouse_y > menu_position["Y"]["Offset"]
			and mouse_y < menu_position["Y"]["Offset"] + frame["Size"]["Y"]
		then
			for object, connections in scroll_connections do
				if object["is_rendering"] and point_in_bounds(mouse_x, mouse_y, object["real_position"], object["real_size"]) then
					for child, data in connections do
						if child["is_rendering"] and point_in_bounds(mouse_x, mouse_y, child["real_position"], child["real_size"]) then
							for i = 1, #data do
								data[i](is_up)
							end
							return
						end
					end
				end
			end
		end
	end

	local function handle_hover()
		local mouse_position = get_mouse_location(user_input_service)
		local mouse_x = mouse_position["X"]
		local mouse_y = mouse_position["Y"]

		cursor["Position"] = udim2_new(0, mouse_x, 0, mouse_y)
		user_input_service["MouseIconEnabled"] = false

		local connections = searching and hover_connections[search_out]
			or actives["colorpicker"] and hover_connections[colorpicker_border]
			or actives["dropdown"] and hover_connections[dropdown_border]
			or actives["keybind"] and hover_connections[keybind_inside]
			or actives["context"] and hover_connections[context_border]
			or actives["settings"] and hover_connections[actives["settings"]["inside"]]
			or nil

		local in_menu = mouse_x > menu_position["X"]["Offset"]
			and mouse_x < menu_position["X"]["Offset"] + frame["Size"]["X"]
			and mouse_y > menu_position["Y"]["Offset"]
			and mouse_y < menu_position["Y"]["Offset"] + frame["Size"]["Y"]

		if connections or in_menu then
			if not connections then
				for object, data in hover_connections do
					if object["is_rendering"] and point_in_bounds(mouse_x, mouse_y, object["real_position"], object["real_size"]) then
						for child, cb in data do
							if child["is_rendering"] and point_in_bounds(mouse_x, mouse_y, child["real_position"], child["real_size"]) then
								if hovering_objects[child] then
									return
								end
								for hover_object, hover_data in hovering_objects do
									for _, iter in hover_data do
										iter[2]()
									end
									hovering_objects[hover_object] = nil
								end
								hovering_objects[child] = cb
								for _, iter in cb do
									iter[1](mouse_position)
								end
								return
							end
						end
					end
				end
			else
				for object, data in connections do
					if object["is_rendering"] and point_in_bounds(mouse_x, mouse_y, object["real_position"], object["real_size"]) then
						if hovering_objects[object] then
							return
						end
						for hover_object, hover_data in hovering_objects do
							for _, iter in hover_data do
								iter[2]()
							end
							hovering_objects[hover_object] = nil
						end
						hovering_objects[object] = data
						for _, iter in data do
							iter[1](mouse_position)
						end
						return
					end
				end
			end

			for object, data in hovering_objects do
				for _, iter in data do
					iter[2]()
				end
				hovering_objects[object] = nil
			end
		else
			for flag, hud in hud_frames do
				if hud["is_rendering"] then
					local pos = hud["real_position"]
					local size = hud["real_size"]
					if point_in_bounds(mouse_x, mouse_y, pos, size) then
						if hovering_objects[hud] then
							return
						end
						local data = hover_connections[hud][hud]
						if data then
							for object, hover_data in hovering_objects do
								for _, iter in hover_data do
									iter[2]()
								end
								hovering_objects[object] = nil
							end
							hovering_objects[hud] = data
							for _, iter in data do
								iter[1](mouse_position)
							end
							return
						end
					end
				end
			end
		end
	end

	local function handle_right_click(_, input)
		if actives["dropdown"] then
			return
		end

		local mouse_position = get_mouse_location(user_input_service)
		local mouse_x = mouse_position["X"]
		local mouse_y = mouse_position["Y"]

		if
			mouse_x > menu_position["X"]["Offset"]
			and mouse_x < menu_position["X"]["Offset"] + frame["Size"]["X"] * 1.5
			and mouse_y > menu_position["Y"]["Offset"]
			and mouse_y < menu_position["Y"]["Offset"] + frame["Size"]["Y"] * 1.5
		then
			for object, connections in right_click_connections do
				if object["is_rendering"] and point_in_bounds(mouse_x, mouse_y, object["real_position"], object["real_size"]) then
					for child, data in connections do
						if child["is_rendering"] and point_in_bounds(mouse_x, mouse_y, child["real_position"], child["real_size"]) then
							for i = 1, #data do
								data[i](mouse_position)
							end
							return
						end
					end
				end
			end
		end
	end

	return {
		handle_click = handle_click,
		handle_scroll = handle_scroll,
		handle_hover = handle_hover,
		handle_right_click = handle_right_click,
	}
	end)()

	local hovering = nil

	pop_menu = LPH_JIT_MAX(function(a)
		if moving then
			moving:Disconnect()
			moving = nil
		end

		if drag_frame["Visible"] then
			drag_frame["Visible"] = false
			frame["Visible"] = true
			frame["Position"] = menu_position
		end

		if hovering then
			hovering:Disconnect()
			hovering = nil
		end

		if actives["settings"] then
			close_settings(actives["settings"])
		end

		if searching then
			stop_search()
		end

		if actives["binding"] then
			stop_binding(actives["binding"])
		end

		if actives["dropdown"] then
			close_dropdown(actives["dropdown"])
		end

		if actives["context"] then
			close_context(actives["context"])
		end

		if actives["keybind"] then
			close_keybind(actives["keybind"])
		end

		if actives["panel"] then
			stop_panel_search(actives["panel"])
		end

		if actives["colorpicker"] then
			close_colorpicker(actives["colorpicker"])
		end

		if active_typing then
			stop_typing()
		end

		for object, data in hovering_objects do
			for _, data in data do
				data[2]()
			end
			hovering_objects[object] = nil
		end

		menu_open = not menu_open

		local half_transparency = menu_open and half_transparency or hide_transparency
		local transparency = menu_open and show_transparency or hide_transparency

		tween(cursor, transparency, exponential, out, 0.18)

		local mouse_position = get_mouse_location(user_input_service)
		user_input_service["MouseIconEnabled"] = not menu_open
		cursor["Position"] = udim2_new(0, mouse_position["X"], 0, mouse_position["Y"])

		frame["Visible"] = not a
		inside["Visible"] = not a

		tween(frame, transparency, exponential, out, 0.18)
		tween(inside, transparency, exponential, out, 0.18)
		tween(logo, transparency, exponential, out, 0.18)
		tween(juju_text, transparency, exponential, out, 0.18)
		tween(build_text, transparency, exponential, out, 0.18)
		tween(right_side, transparency, exponential, out, 0.18)
		tween(right_side_divider, transparency, exponential, out, 0.18)
		tween(search_image, transparency, exponential, out, 0.18)
		tween(themes_image, transparency, exponential, out, 0.18)

		tween(settings_image, transparency, exponential, out, 0.18)
		tween(tab_line, half_transparency, exponential, out, 0.18)
		tween(search_border, transparency, exponential, out, 0.18)
		tween(search_inside, transparency, exponential, out, 0.18)
		tween(search_text, transparency, exponential, out, 0.18)

		for name, group in menu["groups"] do
			tween(group["text"], half_transparency, exponential, out, 0.18)
			tween(group["line"], half_transparency, exponential, out, 0.18)

			for name, tab in group["tabs"] do
				tween(tab["text"], transparency, exponential, out, 0.18)

				if actives["tab"] == tab then
					for _, section in tab["sections"] do
						tween(section["border"], transparency, exponential, out, 0.18)
						tween(section["line_two"], half_transparency, exponential, out, 0.18)
						tween(section["inside"], transparency, exponential, out, 0.18)
						tween(section["label"], half_transparency, exponential, out, 0.18)
						tween(section["line"], half_transparency, exponential, out, 0.18)

						local search_border = section["search_border"]

						if search_border then
							tween(search_border, transparency, exponential, out, 0.18)
							tween(section["search_inside"], transparency, exponential, out, 0.18)
							tween(section["search_text"], transparency, exponential, out, 0.18)
							tween(section["search_image"], transparency, exponential, out, 0.18)
						end

						for _, element in section["elements"] do
							for _, drawing in element["drawings"] do
								tween(
									drawing,
									_ == "slider_fill" and half_transparency
										or _ == "slider_line" and half_transparency
										or _ == "checkmark" and (flags[element["toggle_flag"]] and half_transparency or hide_transparency)
										or _ == "colorpicker_transparency" and (menu_open and {
											Transparency = -flags[element["transparency_flag"]] + 1,
										} or transparency)
										or transparency,
									exponential,
									out,
									0.18
								)
							end
						end
					end
				end
			end
		end

		context_action_service:BindAction(
			context_action_click,
			menu_references["input_handlers"]["handle_click"],
			false,
			Enum["UserInputType"]["MouseButton1"],
			Enum["UserInputType"]["Touch"]
		)
		context_action_service:BindAction(
			context_action_scroll,
			menu_references["input_handlers"]["handle_scroll"],
			false,
			Enum["UserInputType"]["MouseWheel"]
		)

		local old_tick = clock()
		menu_tick = old_tick

		if not menu_open then
			context_action_service:UnbindAction(context_action_click)
			context_action_service:UnbindAction(context_action_scroll)

			delay(0.17, function()
				if old_tick == menu_tick then
					frame["Visible"] = false
					inside["Visible"] = false
				end
			end)
		else
			hovering = create_connection(mouse["Move"], menu_references["input_handlers"]["handle_hover"])
		end
	end)

	create_connection(
		user_input_service["InputBegan"],
		LPH_NO_VIRTUALIZE(function(input, gpe)
			local user_input_type = input["UserInputType"]

			if not gpe then
				for element, keybind in keybind_data do
					local key = keybind["key"]
					local is_key = user_input_type == key or input["KeyCode"] == key

					if is_key then
						local method = keybind["method"]

						if method == 1 then
							keybind:set_activated(not keybind["activated"])
						else
							keybind:set_activated(method == 3 and true or false)
						end
					end
				end

				if menu_open and user_input_type == Enum["UserInputType"]["MouseButton2"] then
					menu_references["input_handlers"]["handle_right_click"](nil, input)
				end
			end
		end)
	)

	create_connection(
		user_input_service["InputEnded"],
		LPH_NO_VIRTUALIZE(function(input, gpe)
			if not gpe then
				for _, keybind in keybind_data do
					local key = keybind["key"]
					local is_key = input["UserInputType"] == key or input["KeyCode"] == key

					if is_key then
						local method = keybind["method"]
						if method == 2 then
							keybind:set_activated(true)
						elseif method == 3 then
							keybind:set_activated(false)
						end
					end
				end
			end
		end)
	)

	-- > ( other )

	menu.is_menu_open = LPH_NO_VIRTUALIZE(function()
		return menu_open
	end)

	-- > ( groups )

	set_active_tab = function(tab)
		actives["old_tab"] = actives["tab"]
		local last_group = actives["old_tab"] and actives["old_tab"]["group"]

		tween(right_side_cover, show_transparency, circular, out, 0.15)

		if actives["old_tab"] then
			tween(actives["old_tab"]["frame"], { ["tween_position"] = udim2_new(0, 10, 0, 20) }, circular, out, 0.15)
			tween(
				actives["old_tab"]["text"],
				{ ["Color"] = menu["colors"]["inactive_text"], ["tween_position"] = actives["old_tab"]["position"] },
				circular,
				out,
				0.15
			)
		end

		local tab_position = tab["position"]

		if last_group == tab["group"] then
			tween(
				tab_line,
				{ ["tween_position"] = udim2_new(0, tab_position["X"]["Offset"], 0, tab_position["Y"]["Offset"] + 1) },
				circular,
				out,
				0.15
			)
		else
			tab_line["Transparency"] = 0
			tab_line["Position"] = udim2_new(0, tab_position["X"]["Offset"], 0, tab_position["Y"]["Offset"] + 1)
			tween(tab_line, half_transparency, circular, out, 0.2)
		end

		tween(tab["text"], {
			["Color"] = menu["colors"]["active_text"],
			["tween_position"] = udim2_new(0, tab_position["X"]["Offset"] + 5, 0, tab_position["Y"]["Offset"]),
		}, circular, out, 0.15)

		delay(0.14, function()
			if actives["tab"] == tab then
				if actives["old_tab"] then
					actives["old_tab"]["frame"]["Visible"] = false
				end

				tween(right_side_cover, hide_transparency, circular, out, 0.15)

				local new_frame = tab["frame"]
				new_frame["Visible"] = true
				new_frame["Position"] = udim2_new(0, 10, 0, 20)
				tween(new_frame, { ["tween_position"] = udim2_new(0, 10, 0, 10) }, circular, out, 0.15)
			elseif actives["old_tab"] and actives["tab"] ~= actives["old_tab"] then
				actives["old_tab"]["frame"]["Visible"] = false
			end
		end)
		actives["tab"] = tab
	end

	local group_header_height = 30
	local tab_vertical_step = 15

	function menu.update_layout()
		local current_y_offset = menu["initial_base_offset"]
		local ordered_groups = menu["ordered_groups"]
		local num_groups = #ordered_groups

		for i = 1, num_groups do
			local group = ordered_groups[i]
			local should_be_visible = group["is_visible"]
			local group_text = group["text"]
			local group_line = group["line"]
			local ordered_tabs = group["ordered_tabs"]
			local num_tabs = #ordered_tabs

			group["initial_offset"] = current_y_offset

			if group_text then
				group_text["Visible"] = should_be_visible
			end
			if group_line then
				group_line["Visible"] = should_be_visible
			end

			for tab_index = 1, num_tabs do
				local tab = ordered_tabs[tab_index]
				local tab_text = tab["text"]
				local tab_text_frame = tab["text_frame"]
				if tab_text then
					tab_text["Visible"] = should_be_visible
				end
				if tab_text_frame then
					tab_text_frame["Visible"] = should_be_visible
				end
			end

			if should_be_visible then
				if group_text then
					group_text["Position"] = udim2_new(0, 15, 0, current_y_offset)
				end
				if group_line then
					group_line["Position"] = udim2_new(0, 15, 0, current_y_offset + 15)
				end

				local base_tab_y = current_y_offset + 20
				for tab_index = 1, num_tabs do
					local tab = ordered_tabs[tab_index]
					local tab_text = tab["text"]
					local tab_text_frame = tab["text_frame"]
					local new_tab_y = base_tab_y + (tab_index - 1) * tab_vertical_step
					local new_tab_position = udim2_new(0, 15, 0, new_tab_y)

					tab["position"] = new_tab_position
					if tab_text then
						tab_text["Position"] = actives["tab"] == tab and udim2_new(0, 20, 0, new_tab_y)
							or new_tab_position
					end
					if tab_text_frame then
						tab_text_frame["Position"] = new_tab_position
						if tab_text then
							tab_text_frame["Size"] = udim2_new(0, 70, 0, tab_text["TextBounds"]["Y"])
						end
					end
				end
				current_y_offset = current_y_offset + group["current_height"]
			end
		end

		local size = current_y_offset > 405 and udim2_new(0, 575, 0, 450 + (current_y_offset - 405))
			or udim2_new(0, 575, 0, 450)
		drag_frame["Size"] = size
		frame["Size"] = size
	end

	local group = {}
	group["__index"] = group

	function menu.create_group(name)
		local new_tabs = {}
		local ordered_tabs = {}
		local initial_offset
		local ordered_groups = menu["ordered_groups"]
		local num_groups = #ordered_groups

		if num_groups > 0 then
			local previous_group = nil
			for i = num_groups, 1, -1 do
				local g = ordered_groups[i]
				if g["is_visible"] then
					previous_group = g
					break
				end
			end

			if previous_group then
				initial_offset = previous_group["initial_offset"] + previous_group["current_height"]
			else
				initial_offset = menu["initial_base_offset"]
			end
		else
			initial_offset = menu["initial_base_offset"]
		end

		local new_group = setmetatable({
			["tabs"] = new_tabs,
			["ordered_tabs"] = ordered_tabs,
			["initial_offset"] = initial_offset,
			["current_height"] = group_header_height,
			["is_visible"] = true,
			["name"] = name,
			["text"] = drawing_proxy["new"]("Text", {
				["Color"] = menu["colors"]["accent"],
				["Transparency"] = 0.5,
				["Text"] = name,
				["Parent"] = inside,
				["Size"] = 14,
				["Font"] = 1,
				["Position"] = udim2_new(0, 15, 0, initial_offset),
				["Visible"] = true,
			}),
			["line"] = drawing_proxy["new"]("Square", {
				["Parent"] = inside,
				["Transparency"] = 0.5,
				["Position"] = udim2_new(0, 15, 0, initial_offset + 15),
				["Size"] = udim2_new(0, 70, 0, 1),
				["Color"] = menu["colors"]["accent"],
				["Filled"] = true,
				["Visible"] = true,
			}),
		}, group)

		menu["groups"][name] = new_group
		ordered_groups[#ordered_groups + 1] = new_group

		return new_group
	end

	function group:create_tab(name)
		local group_initial_offset = self["initial_offset"]
		local ordered_tabs = self["ordered_tabs"]
		local index = #ordered_tabs + 1
		local position = udim2_new(0, 15, 0, group_initial_offset + 20 + (index - 1) * tab_vertical_step)
		local is_group_visible = self["is_visible"]

		local new_tab = {
			["text"] = drawing_proxy["new"]("Text", {
				["Color"] = menu["colors"]["inactive_text"],
				["Text"] = name:sub(1, 12),
				["Size"] = 12,
				["Font"] = 1,
				["Visible"] = is_group_visible,
				["Parent"] = inside,
				["Position"] = position,
			}),
			["frame"] = drawing_proxy["new"]("Square", {
				["Parent"] = right_side,
				["Position"] = udim2_new(0, 10, 0, 10),
				["Size"] = udim2_new(1, -20, 1, -20),
				["Filled"] = true,
				["Transparency"] = 0,
				["Visible"] = false,
			}),
			["sections"] = {},
			["position"] = position,
			["group"] = self,
			["name"] = name,
		}

		new_tab["destroy"] = function(self)
			if not self or not self["text"] then
				error("attempt to destroy nil tab")
				return
			end
			self["text"]:Destroy()
			self["frame"]:Destroy()
			for _, section in self["sections"] do
				section:destroy()
			end

			self["group"]:remove_tab(name)
		end

		local text = new_tab["text"]

		local text_frame = drawing_proxy["new"]("Square", {
			["Parent"] = inside,
			["Position"] = position,
			["Size"] = udim2_new(0, 70, 0, text["TextBounds"]["Y"]),
			["Filled"] = true,
			["Transparency"] = 0,
			["Visible"] = is_group_visible,
		})
		new_tab["text_frame"] = text_frame

		self["tabs"][name] = new_tab
		ordered_tabs[#ordered_tabs + 1] = new_tab

		self["current_height"] = group_header_height + #ordered_tabs * tab_vertical_step

		create_click_connection(text_frame, text_frame, function()
			if actives["tab"] ~= new_tab then
				set_active_tab(new_tab)
			end
		end)
		create_hover_connection(text_frame, text_frame, function()
			if actives["tab"] ~= new_tab then
				tween(text, { ["Color"] = menu["colors"]["highlighted"] }, circular, out, 0.17)
			end
		end, function()
			if actives["tab"] ~= new_tab then
				tween(text, { ["Color"] = menu["colors"]["inactive_text"] }, circular, out, 0.17)
			end
		end)

		if actives["tab"] == nil then
			set_active_tab(new_tab)
		end

		if is_group_visible then
			menu.update_layout()
		end

		return new_tab
	end

	function group:remove_tab(name)
		local tab_to_remove = self["tabs"][name]
		if not tab_to_remove then
			return
		end

		local remove_index = nil
		local ordered_tabs = self["ordered_tabs"]
		local num_tabs = #ordered_tabs
		for i = 1, num_tabs do
			local tab = ordered_tabs[i]
			if tab == tab_to_remove then
				remove_index = i
				break
			end
		end

		if not remove_index then
			return
		end

		local text_obj = tab_to_remove["text"]
		local text_frame_obj = tab_to_remove["text_frame"]
		local frame_obj = tab_to_remove["frame"]

		if text_obj then
			text_obj["Visible"] = false
			text_obj["Parent"] = nil
		end
		if text_frame_obj then
			text_frame_obj["Visible"] = false
			text_frame_obj["Parent"] = nil
		end
		if frame_obj then
			frame_obj["Visible"] = false
			frame_obj["Parent"] = nil
		end

		if actives["tab"] == tab_to_remove then
			actives["tab"] = nil
		end

		self["tabs"][name] = nil
		remove(ordered_tabs, remove_index)

		self["current_height"] = group_header_height + #ordered_tabs * tab_vertical_step

		if self["is_visible"] then
			menu.update_layout()
		end
	end

	function group:hide()
		if not self["is_visible"] then
			return
		end
		self["is_visible"] = false
		menu.update_layout()
	end

	function group:show()
		if self["is_visible"] then
			return
		end
		self["is_visible"] = true
		menu.update_layout()
	end

	local section = {}
	section["__index"] = section

	function group:create_section(tab_name, name, side, size, y_position)
		local tab = self["tabs"][tab_name]
		if not tab then
			return nil
		end

		local new_section = setmetatable({
			["tab"] = tab,
			["name"] = name,
			["side"] = side,
			["size"] = size,
			["total_y_size"] = 10,
			["elements"] = {},
		}, section)

		local tab_frame = tab["frame"]
		local y_position = y_position or 0

		local section_border = drawing_proxy["new"]("Image", {
			["Parent"] = tab_frame,
			["Position"] = udim2_new(
				side == 1 and 0 or 0.5,
				side == 1 and 0 or 5,
				y_position,
				y_position ~= 0 and 10 or 0
			),
			["Size"] = udim2_new(0.5, -5, size, y_position ~= 0 and -10 or 0),
			["Color"] = menu["colors"]["border"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = 2,
			["Visible"] = true,
		})
		local section_inside = drawing_proxy["new"]("Image", {
			["Parent"] = section_border,
			["Position"] = udim2_new(0, 1, 0, 0),
			["Size"] = udim2_new(1, -2, 1, -1),
			["Color"] = menu["colors"]["section"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = 3,
			["Visible"] = true,
		})
		local section_line = drawing_proxy["new"]("Square", {
			["Parent"] = section_inside,
			["Size"] = udim2_new(0, 9, 0, 1),
			["Position"] = udim2_new(0, 1, 0, 0),
			["Color"] = menu["colors"]["accent"],
			["Transparency"] = 0.5,
			["Filled"] = true,
			["ZIndex"] = 4,
			["Visible"] = true,
		})
		local section_label = drawing_proxy["new"]("Text", {
			["Color"] = menu["colors"]["accent"],
			["Transparency"] = 0.5,
			["Text"] = name,
			["Parent"] = section_inside,
			["Position"] = udim2_new(0, 15, 0, -8),
			["Size"] = 12,
			["Font"] = 1,
			["ZIndex"] = 4,
			["Visible"] = true,
		})
		local text_bounds = section_label["TextBounds"]["X"] + 20
		local section_line_two = drawing_proxy["new"]("Square", {
			["Parent"] = section_inside,
			["Position"] = udim2_new(0, text_bounds, 0, 0),
			["Size"] = udim2_new(1, -(text_bounds + 1), 0, 1),
			["Color"] = menu["colors"]["accent"],
			["Filled"] = true,
			["Transparency"] = 0.5,
			["ZIndex"] = 4,
			["Visible"] = true,
		})
		local element_holder = drawing_proxy["new"]("Square", {
			["Parent"] = section_inside,
			["Position"] = udim2_new(0, 10, 0, 10),
			["Size"] = udim2_new(1, -20, 1, -20),
			["Transparency"] = 0,
			["Filled"] = true,
			["Visible"] = true,
		})

		new_section["border"] = section_border
		new_section["line_two"] = section_line_two
		new_section["inside"] = section_inside
		new_section["label"] = section_label
		new_section["line"] = section_line
		new_section["holder"] = element_holder

		tab["sections"][name] = new_section

		return new_section
	end

	local panel_section = {}
	panel_section["__index"] = panel_section

	function group:create_panel_section(tab_name, name, side, favorites, configs)
		local tab = self["tabs"][tab_name]
		if not tab then
			return nil
		end

		local new_section = setmetatable({
			["tab"] = tab,
			["name"] = name,
			["total_y_size"] = 30,
			["scroll_index"] = 1,
			["elements"] = {},
			["selected"] = nil,
			["on_selection_change"] = signal["new"](),
			["favorites"] = favorites,
			["configs"] = configs,
		}, panel_section)

		local tab_frame = tab["frame"]

		local section_border = drawing_proxy["new"]("Image", {
			["Parent"] = tab_frame,
			["Position"] = udim2_new(side == 1 and 0 or 0.5, side == 1 and 0 or 5, 0, 0),
			["Size"] = udim2_new(0.5, -5, 1, 0),
			["Color"] = menu["colors"]["border"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["Visible"] = true,
		})
		local section_inside = drawing_proxy["new"]("Image", {
			["Parent"] = section_border,
			["Position"] = udim2_new(0, 1, 0, 0),
			["Size"] = udim2_new(1, -2, 1, -1),
			["Color"] = menu["colors"]["section"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["Visible"] = true,
		})
		local section_line = drawing_proxy["new"]("Square", {
			["Parent"] = section_inside,
			["Size"] = udim2_new(0, 9, 0, 1),
			["Position"] = udim2_new(0, 1, 0, 0),
			["Color"] = menu["colors"]["accent"],
			["Transparency"] = 0.5,
			["Filled"] = true,
			["Visible"] = true,
		})
		local section_label = drawing_proxy["new"]("Text", {
			["Color"] = menu["colors"]["accent"],
			["Transparency"] = 0.5,
			["Text"] = name,
			["Parent"] = section_inside,
			["Position"] = udim2_new(0, 15, 0, -8),
			["Size"] = 12,
			["Font"] = 1,
			["Visible"] = true,
		})
		local text_bounds = section_label["TextBounds"]["X"] + 20
		local section_line_two = drawing_proxy["new"]("Square", {
			["Parent"] = section_inside,
			["Position"] = udim2_new(0, text_bounds, 0, 0),
			["Size"] = udim2_new(1, -(text_bounds + 1), 0, 1),
			["Color"] = menu["colors"]["accent"],
			["Filled"] = true,
			["Transparency"] = 0.5,
			["Visible"] = true,
		})
		local element_holder = drawing_proxy["new"]("Square", {
			["Parent"] = section_inside,
			["Position"] = udim2_new(0, 10, 0, 10),
			["Size"] = udim2_new(1, -20, 1, -20),
			["Transparency"] = 0,
			["Filled"] = true,
			["Visible"] = true,
		})
		local search_border = drawing_proxy["new"]("Image", {
			["Parent"] = element_holder,
			["Position"] = udim2_new(0, 0, 0, 0),
			["Size"] = udim2_new(1, 0, 0, 20),
			["Color"] = menu["colors"]["border"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = zindex,
			["Visible"] = true,
		})
		local search_inside = drawing_proxy["new"]("Image", {
			["Parent"] = search_border,
			["Position"] = udim2_new(0, 1, 0, 1),
			["Size"] = udim2_new(1, -2, 1, -2),
			["Color"] = menu["colors"]["background"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = zindex,
			["Visible"] = true,
		})
		local search_text = drawing_proxy["new"]("Text", {
			["Color"] = menu["colors"]["inactive_text"],
			["Text"] = "search",
			["Size"] = 12,
			["Font"] = 1,
			["Transparency"] = 1,
			["Visible"] = true,
			["Parent"] = search_inside,
			["Position"] = udim2_new(0, 22, 0, 3),
		})
		local search_image = drawing_proxy["new"]("Image", {
			["Color"] = menu["colors"]["inactive_text"],
			["Data"] = base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADp1fY4ytpsegAAAGdJREFUKFONkGEWgCAIg5GTdP9LlqPBA8Pq+yFuOvA5JHFOuDXGhNvAjPVipgtZAFAGtIuvbrSdRA4sJQQBKB/wOM6V9TevAe+cn6su8liwaieSuwuONy4/k0PdZHglsKOEWD+5QyIX+wJP/y1yP3IAAAAASUVORK5CYII="
			),
			["Position"] = udim2_new(0, 4, 0, 4),
			["Parent"] = search_inside,
			["Size"] = udim2_new(0, 12, 0, 12),
			["Transparency"] = 1,
			["Visible"] = true,
		})

		new_section["border"] = section_border
		new_section["line_two"] = section_line_two
		new_section["inside"] = section_inside
		new_section["label"] = section_label
		new_section["line"] = section_line
		new_section["holder"] = element_holder
		new_section["search_image"] = search_image
		new_section["search_border"] = search_border
		new_section["search_inside"] = search_inside
		new_section["search_text"] = search_text
		new_section["search_image"] = search_image

		tab["sections"][name] = new_section

		create_hover_connection(element_holder, search_border, function()
			if not actives["panel"] then
				tween(search_border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.15)
			end
		end, function()
			if not actives["panel"] then
				tween(search_border, { Color = menu["colors"]["border"] }, circular, out, 0.15)
			end
		end)

		create_click_connection(element_holder, search_border, function()
			start_panel_search(new_section)
		end)

		create_scroll_connection(section_border, section_border, function(is_up)
			local old_scroll_index = new_section["scroll_index"]
			new_section["scroll_index"] =
				clamp(old_scroll_index + (is_up and -1 or 1), 1, 1 + clamp(#new_section["elements"] - 13, 0, 1000))
			new_section:update_position()
		end)

		return new_section
	end

	-- > ( panel sections )

	function panel_section:add_item(info)
		local new_item = setmetatable({
			["drawings"] = {},
			["color"] = color,
			["name"] = info["text"],
			["parent"] = self["name"],
			["icons"] = {},
		}, item)

		local border = drawing_proxy["new"]("Image", {
			["Parent"] = self["holder"],
			["Position"] = udim2_new(0, 0, 0, self["total_y_size"]),
			["Size"] = udim2_new(1, 0, 0, 20),
			["Color"] = menu["colors"]["border"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["Visible"] = false,
		})
		local inside = drawing_proxy["new"]("Image", {
			["Parent"] = border,
			["Position"] = udim2_new(0, 1, 0, 1),
			["Size"] = udim2_new(1, -2, 1, -2),
			["Color"] = menu["colors"]["background"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = 2,
			["Visible"] = true,
		})
		local text = drawing_proxy["new"]("Text", {
			["Color"] = menu["colors"]["inactive_text"],
			["Text"] = info["text"],
			["Size"] = 12,
			["Font"] = 1,
			["Transparency"] = 1,
			["Visible"] = true,
			["Parent"] = inside,
			["ZIndex"] = 3,
			["Position"] = udim2_new(0, 5, 0, 3),
		})

		new_item["drawings"]["border"] = border
		new_item["drawings"]["inside"] = inside
		new_item["drawings"]["text"] = text

		self["total_y_size"] += 30
		self["elements"][#self["elements"] + 1] = new_item

		local icons = info["icons"] or {}
		for i = 1, #icons do
			local icon = icons[i]
			local name = "icon_" .. tostring(clock())

			new_item["drawings"][name] = drawing_proxy["new"]("Image", {
				["Parent"] = inside,
				["Position"] = udim2_new(0, 4 + (#icons - i) * 15, 0, 4),
				["Size"] = udim2_new(0, 10, 0, 10),
				["Color"] = menu["colors"]["accent"],
				["Visible"] = true,
				["Transparency"] = 1,
				["ZIndex"] = 4,
				["Data"] = icon,
			})

			new_item["icons"][i] = { icon, name }
		end

		self["scroll_index"] = clamp(self["scroll_index"], 1, 1 + clamp(#self["elements"] - 13, 0, 1000))

		local x = 4 + #icons * 15
		text["Position"] = udim2_new(0, x, 0, 3)
		local text2_text = info["text2"]
		if text2_text then
			local text2 = drawing_proxy["new"]("Text", {
				["Color"] = menu["colors"]["dark_text"],
				["Text"] = text2_text,
				["Size"] = 12,
				["Font"] = 1,
				["Transparency"] = 1,
				["Visible"] = true,
				["Parent"] = inside,
				["ZIndex"] = 4,
				["Position"] = udim2_new(0, x + text["TextBounds"]["X"] + 3, 0, 3),
			})

			local size = text2["Position"]["X"] + text2["TextBounds"]["X"] + 9
			local border_size = border["Position"]["X"] + border["Size"]["X"]
			if size > border_size then
				local overlap = 2 + math["ceil"]((size - border_size) / 6)
				text2["Text"] = text2["Text"]:sub(1, -overlap) .. ".."
			end
			new_item["drawings"]["text2"] = text2
			new_item["text2"] = text2_text
		end

		self:update_position()

		create_hover_connection(self["holder"], border, function()
			if self["selected"] ~= new_item then
				tween(border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
			end
		end, function()
			if self["selected"] ~= new_item then
				tween(border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
			end
		end)

		if self["favorites"] then
			local flag = info["text"] .. self["name"]
			new_item["favorite_flag"] = flag
			new_item["parent"] = self
			local favorited = menu["favorites"][flag]
			if favorited then
				new_item["favorited"] = true
				self:add_icon(info["text"], star)
			end
			create_right_click_connection(self["holder"], border, function(position)
				open_context({ menu["favorites"][flag] and 6 or 5 }, new_item, position)
			end)
		elseif self["configs"] then
			new_item["parent"] = self
			create_right_click_connection(self["holder"], border, function(position)
				open_context({ menu["autoload"] == new_item["name"] and 9 or 8 }, new_item, position)
			end)
		end

		create_click_connection(self["holder"], border, function()
			if not self["locked"] then
				local selected = self["selected"]
				if selected ~= new_item then
					tween(border, { ["Color"] = menu["colors"]["highlighted"] }, circular, out, 0.17)
					self["selected"] = new_item
					self["on_selection_change"]:Fire(text["Text"])

					local elements = self["elements"]
					local index = nil
					for i = 1, #elements do
						if elements[i] == new_item then
							index = i
						end
					end

					local elements = self["elements"]
					local old_item = elements[1]
					elements[1] = new_item
					elements[index or #elements + 1] = old_item

					if selected then
						tween(selected["drawings"]["border"], { Color = menu["colors"]["border"] }, circular, out, 0.17)
					end

					self["scroll_index"] = 1
					self:update_position()
				else
					tween(border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
					self["selected"] = nil
					self["on_selection_change"]:Fire(nil)
				end
			end
		end)

		return new_item
	end

	function panel_section:remove_item(text, delay, skip)
		local elements = self["elements"]
		local holder = self["holder"]
		local object = nil

		for i = 1, #elements do
			local element = elements[i]

			if element and element["drawings"]["text"]["Text"] == text then
				object = element
				if not delay then
					remove(elements, i)
				end
				break
			end
		end

		if not object then
			return
		end

		local drawings = object["drawings"]
		local frame = drawings["border"]

		local connections = click_connections[holder]

		if connections then
			connections[frame] = nil
		end

		local connections = hover_connections[holder]

		if connections then
			connections[frame] = nil
		end

		local connections = right_click_connections[holder]

		if connections then
			connections[frame] = nil
		end

		for _, drawing in drawings do
			drawing:Destroy()
			drawings[_] = nil
		end

		self["scroll_index"] = clamp(self["scroll_index"], 1, 1 + clamp(#self["elements"] - 13, 0, 1000))

		if not delay then
			self:update_position()
		end

		if self["selected"] == object then
			self["selected"] = nil
			if not skip then
				self["on_selection_change"]:Fire(nil)
			end
		end
	end

	function panel_section:edit_item_color(text, color)
		local elements = self["elements"]
		local object = nil

		for i = 1, #elements do
			local element = elements[i]["drawings"]["text"]

			if element["Text"] == text then
				object = element
				break
			end
		end

		if not object then
			return
		end

		object["Color"] = color
	end

	function panel_section:remove_icon(text, icon)
		local elements = self["elements"]
		local object = nil

		for i = 1, #elements do
			local element = elements[i]
			local label = elements[i]["drawings"]["text"]

			if label["Text"] == text then
				object = element
				break
			end
		end

		if not object then
			return
		end

		local drawings = object["drawings"]
		local icons = object["icons"]

		local has_icon = false

		for i = 1, #icons do
			local icon_data = icons[i]
			if icon_data[1] == icon then
				has_icon = true
				break
			end
		end

		if not has_icon then
			return
		end

		for i = 1, #icons do
			local icon_data = icons[i]
			if icon_data[1] == icon then
				local name = icon_data[2]
				remove(icons, i)
				drawings[name]:Destroy()
				drawings[name] = nil
				break
			else
				drawings[icon_data[2]]["tween_position"] -= udim2_new(0, 15, 0, 0)
			end
		end

		drawings["text"]["tween_position"] = udim2_new(0, 5 + 15 * #icons, 0, 3)

		self:update_position()
	end

	function panel_section:add_icon(text, icon)
		local elements = self["elements"]
		local object = nil

		for i = 1, #elements do
			local element = elements[i]
			local label = elements[i]["drawings"]["text"]

			if label["Text"] == text then
				object = element
				break
			end
		end

		if not object then
			return
		end

		local drawings = object["drawings"]
		local icons = object["icons"]

		for i = 1, #icons do
			drawings[icons[i][2]]["tween_position"] += udim2_new(0, 15, 0, 0)
		end

		local name = "icon_" .. clock()

		drawings[name] = drawing_proxy["new"]("Image", {
			["Parent"] = drawings["inside"],
			["Position"] = udim2_new(0, 4, 0, 4),
			["Size"] = udim2_new(0, 10, 0, 10),
			["Color"] = menu["colors"]["accent"],
			["Visible"] = true,
			["Transparency"] = 1,
			["ZIndex"] = 4,
			["Data"] = icon,
		})

		icons[#icons + 1] = { icon, name }

		drawings["text"]["tween_position"] = udim2_new(0, 5 + 15 * #icons, 0, 3)

		self:update_position()
	end

	function panel_section:update_position()
		if actives["panel"] then
			return
		end

		local scroll_index = self["scroll_index"]
		local elements = self["elements"]
		local fake_elements = {}

		for i = 1, #elements do
			local element = elements[i]
			if element["favorited"] then
				local frame = elements[i]["drawings"]["border"]
				frame["Visible"] = true
				frame["Position"] = udim2_new(0, 0, 0, 30 + (i - scroll_index) * 30)
				fake_elements[#fake_elements + 1] = element
			end
		end

		for i = 1, #elements do
			local element = elements[i]
			if not element["favorited"] then
				fake_elements[#fake_elements + 1] = element
			end
		end

		for i = 1, #fake_elements do
			local frame = fake_elements[i]["drawings"]["border"]
			if i >= scroll_index and i < scroll_index + 13 then
				frame["Visible"] = true
				frame["Position"] = udim2_new(0, 0, 0, 30 + (i - scroll_index) * 30)
			else
				frame["Visible"] = false
			end
		end
	end

	-- > ( elements )

	function element.new(info, elements)
		local position = info["position"]
		local parent = info["parent"]

		local frame = drawing_proxy["new"]("Square", {
			["Parent"] = parent,
			["Position"] = position,
			["Size"] = udim2_new(1, -20, 0, 12),
			["Transparency"] = 0,
			["Visible"] = true,
		})

		local zindex = parent["ZIndex"] + 1

		local new_element = setmetatable({
			["drawings"] = {
				["text"] = drawing_proxy["new"]("Text", {
					["Color"] = menu["colors"]["inactive_text"],
					["Text"] = info["text"],
					["Size"] = 12,
					["Font"] = 1,
					["Transparency"] = 1,
					["Visible"] = true,
					["Parent"] = frame,
					["Position"] = udim2_new(0, 0, 0, -1),
					["ZIndex"] = zindex,
				}),
			},
			["frame"] = frame,
			["visible"] = true,
			["section"] = info["section"],
			["name"] = info["text"],
			["old_visible"] = true,
		}, element)

		local text = new_element["drawings"]["text"]
		local total_y_size = 17

		for element, properties in elements do
			if element == "toggle" then
				text["tween_position"] += udim2_new(0, 17, 0, 0)

				local toggle_border = drawing_proxy["new"]("Image", {
					["Parent"] = frame,
					["Position"] = udim2_new(0, 0, 0, 0),
					["Size"] = udim2_new(0, 12, 0, 12),
					["Color"] = menu["colors"]["border"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["ZIndex"] = zindex + 1,
					["Visible"] = true,
				})
				local toggle_inside = drawing_proxy["new"]("Image", {
					["Parent"] = toggle_border,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Color"] = menu["colors"]["background"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["ZIndex"] = zindex + 2,
					["Visible"] = true,
				})
				local toggle_click = drawing_proxy["new"]("Square", {
					["Parent"] = frame,
					["Size"] = udim2_new(0, 17 + new_element["drawings"]["text"]["TextBounds"]["X"], 1, 0),
					["Transparency"] = 0,
					["Visible"] = true,
					["ZIndex"] = zindex + 3,
					["Position"] = udim2_new(0, 0, 0, 0),
				})
				local checkmark = drawing_proxy["new"]("Image", {
					["Parent"] = toggle_inside,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Data"] = checkmark_image_data,
					["Transparency"] = 0,
					["ZIndex"] = zindex + 3,
					["Color"] = menu["colors"]["accent"],
					["Visible"] = true,
				})

				new_element["drawings"]["toggle_border"] = toggle_border
				new_element["drawings"]["toggle_inside"] = toggle_inside
				new_element["drawings"]["checkmark"] = checkmark

				create_hover_connection(parent, toggle_click, function()
					tween(toggle_border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end, function()
					tween(toggle_border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
				end)

				new_element["on_toggle_change"] = signal["new"]()
				new_element["toggle_flag"] = properties["flag"]

				if properties["default"] then
					new_element:set_toggle(true)
				else
					flags[properties["flag"]] = false
				end

				create_click_connection(parent, toggle_click, function()
					new_element:set_toggle(not flags[properties["flag"]])
				end)

				if not info["fake"] then
					create_right_click_connection(parent, toggle_click, function(position)
						open_context(keybind_data[new_element] and { 2, 1 } or { 1 }, new_element, position)
					end)
				end
			elseif element == "slider" then
				total_y_size += 14

				local slider_border = drawing_proxy["new"]("Image", {
					["Parent"] = frame,
					["Position"] = udim2_new(0, 0, 0, 14),
					["Size"] = udim2_new(1, 0, 0, 12),
					["Color"] = menu["colors"]["border"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["ZIndex"] = zindex + 1,
					["Visible"] = true,
				})
				local slider_inside = drawing_proxy["new"]("Image", {
					["Parent"] = slider_border,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Color"] = menu["colors"]["background"],
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["Transparency"] = 1,
					["ZIndex"] = zindex + 2,
					["Visible"] = true,
				})
				local slider_fill = drawing_proxy["new"]("Image", {
					["Parent"] = slider_inside,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(0, 0, 1, -2),
					["Color"] = menu["colors"]["accent"],
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["Transparency"] = 0.5,
					["ZIndex"] = zindex + 3,
					["Visible"] = true,
				})
				local slider_line = drawing_proxy["new"]("Square", {
					["Parent"] = frame,
					["Position"] = udim2_new(0, text["TextBounds"]["X"] + (elements["toggle"] and 20 or 3), 0, 2),
					["Size"] = udim2_new(0, 1, 0, 8),
					["Color"] = menu["colors"]["dark_text"],
					["Visible"] = true,
					["Filled"] = true,
					["Transparency"] = 0.5,
					["ZIndex"] = zindex + 4,
				})
				local slider_text = drawing_proxy["new"]("Text", {
					["Color"] = menu["colors"]["dark_text"],
					["Text"] = "",
					["Size"] = 12,
					["Font"] = 1,
					["Transparency"] = 1,
					["Visible"] = true,
					["Parent"] = frame,
					["ZIndex"] = zindex + 5,
					["Position"] = udim2_new(0, text["TextBounds"]["X"] + (elements["toggle"] and 24 or 7), 0, -1),
				})
				local slider_click = drawing_proxy["new"]("Square", {
					["Parent"] = slider_line,
					["Position"] = udim2_new(0, 0, 0, -1),
					["Size"] = udim2_new(0, 50, 0, 10),
					["Transparency"] = 0,
					["Filled"] = true,
					["ZIndex"] = zindex + 5,
					["Visible"] = true,
				})

				new_element["drawings"]["slider_border"] = slider_border
				new_element["drawings"]["slider_inside"] = slider_inside
				new_element["drawings"]["slider_fill"] = slider_fill
				new_element["drawings"]["slider_line"] = slider_line
				new_element["drawings"]["slider_text"] = slider_text

				new_element["on_slider_change"] = signal["new"]()
				new_element["slider_max"] = properties["max"]
				new_element["slider_min"] = properties["min"]
				new_element["slider_min_text"] = properties["min_text"]
				new_element["slider_max_text"] = properties["max_text"]
				new_element["slider_suffix"] = properties["suffix"] or ""
				new_element["slider_decimals"] = properties["decimals"] or 0

				new_element["slider_prefix"] = properties["prefix"] or ""
				new_element["slider_flag"] = properties["flag"]

				create_hover_connection(parent, slider_border, function()
					tween(slider_border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end, function()
					tween(slider_border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
				end)

				create_click_connection(parent, slider_click, function()
					start_typing(slider_text, 100, function(value)
						if tonumber(value) then
							new_element:set_slider(value)
						end
					end, true, true)
				end)

				create_click_connection(parent, slider_border, function(mouse_position)
					local min, max, decimals = properties["min"], properties["max"], properties["decimals"]
					moving = create_connection(mouse["Move"], function()
						new_element:set_slider(
							round(
								min
									+ (max - min)
										* (get_mouse_location(user_input_service)["X"] - slider_inside["real_position"]["X"])
										/ slider_inside["real_size"]["X"],
								decimals
							)
						)
					end)
					new_element:set_slider(
						round(
							min
								+ (max - min)
									* (mouse_position["X"] - slider_inside["real_position"]["X"])
									/ slider_inside["real_size"]["X"],
							decimals
						)
					)
				end)

				if not info["fake"] then
					create_right_click_connection(parent, slider_border, function(position)
						open_context(keybind_data[new_element] and { 2, 1 } or { 1 }, new_element, position)
					end)
				end

				new_element:set_slider(properties["default"] or properties["min"])
			elseif element == "textbox" then
				total_y_size += 18

				local textbox_border = drawing_proxy["new"]("Image", {
					["Parent"] = frame,
					["Position"] = udim2_new(0, 0, 0, 14),
					["Size"] = udim2_new(1, 0, 0, 16),
					["Color"] = menu["colors"]["border"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["Visible"] = true,
					["ZIndex"] = zindex + 1,
				})
				local textbox_inside = drawing_proxy["new"]("Image", {
					["Parent"] = textbox_border,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Color"] = menu["colors"]["background"],
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["Transparency"] = 1,
					["ZIndex"] = zindex + 2,
					["Visible"] = true,
				})
				local textbox_text = drawing_proxy["new"]("Text", {
					["Color"] = menu["colors"]["dark_text"],
					["Text"] = "...",
					["Size"] = 12,
					["Font"] = 1,
					["Transparency"] = 1,
					["Visible"] = true,
					["Parent"] = textbox_inside,
					["Center"] = false,
					["ZIndex"] = zindex + 3,
					["Position"] = udim2_new(0, 2, 0, 0),
				})
				new_element["drawings"]["textbox_border"] = textbox_border
				new_element["drawings"]["textbox_inside"] = textbox_inside
				new_element["drawings"]["textbox_text"] = textbox_text

				new_element["on_textbox_change"] = signal["new"]()
				new_element["textbox_flag"] = properties["flag"]

				create_hover_connection(parent, textbox_border, function()
					tween(textbox_border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end, function()
					tween(textbox_border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
				end)

				create_click_connection(parent, textbox_border, function()
					start_typing(textbox_text, textbox_border["real_size"]["X"] - 15, function(value)
						new_element:set_textbox(tostring(value))
					end, false, true, true, true)
				end)

				new_element:set_textbox(properties["default"] or nil)
			elseif element == "dropdown" then
				total_y_size += 18

				local dropdown_border = drawing_proxy["new"]("Image", {
					["Parent"] = frame,
					["Position"] = udim2_new(0, 0, 0, 14),
					["Size"] = udim2_new(1, 0, 0, 16),
					["Color"] = menu["colors"]["border"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["Visible"] = true,
					["ZIndex"] = zindex + 1,
				})
				local dropdown_inside = drawing_proxy["new"]("Image", {
					["Parent"] = dropdown_border,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Color"] = menu["colors"]["background"],
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["Transparency"] = 1,
					["ZIndex"] = zindex + 2,
					["Visible"] = true,
				})
				local dropdown_text = drawing_proxy["new"]("Text", {
					["Color"] = menu["colors"]["dark_text"],
					["Text"] = "none",
					["Size"] = 12,
					["Font"] = 1,
					["Transparency"] = 1,
					["Visible"] = true,
					["Parent"] = dropdown_inside,
					["Center"] = false,
					["ZIndex"] = zindex + 3,
					["Position"] = udim2_new(0, 3, 0, 0),
				})
				local dropdown_arrow = drawing_proxy["new"]("Image", {
					["Color"] = menu["colors"]["dark_text"],
					["Data"] = arrow_image_data,
					["Size"] = udim2_new(0, 8, 0, 8),
					["Position"] = udim2_new(1, -11, 0.5, -4),
					["Transparency"] = 1,
					["Visible"] = true,
					["ZIndex"] = zindex + 3,
					["Parent"] = dropdown_inside,
				})

				new_element["drawings"]["dropdown_border"] = dropdown_border
				new_element["drawings"]["dropdown_inside"] = dropdown_inside
				new_element["drawings"]["dropdown_arrow"] = dropdown_arrow
				new_element["drawings"]["dropdown_text"] = dropdown_text
				new_element["on_dropdown_change"] = signal["new"]()
				new_element["dropdown_flag"] = properties["flag"]
				new_element["multi"] = properties["multi"]
				new_element["requires_one"] = properties["requires_one"]

				new_element["options"] = properties["options"]

				create_hover_connection(parent, dropdown_border, function()
					tween(dropdown_border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
					tween(dropdown_arrow, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end, function()
					tween(dropdown_border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
					tween(dropdown_arrow, { Color = menu["colors"]["dark_text"] }, circular, out, 0.17)
				end)

				local extensions = properties["use_custom_extensions"]
				if extensions then
					local original_options = properties["options"]
					local new_options = {}

					for i = 1, #original_options do
						new_options[#new_options + 1] = original_options[i]
					end

					for _, file in listfiles(file_path .. "/custom") do
						local extension = file:match("%.([^%.]+)$")

						if extension then
							for i = 1, #extensions do
								if extensions[i] == extension then
									local file_name = file:match("([^/\\]+)$")
									local found = false
									for i = 1, #original_options do
										if original_options[i] == file_name then
											found = true
											break
										end
									end
									if not found then
										new_options[#new_options + 1] = file_name
									end
									break
								end
							end
						end
					end

					new_element["options"] = new_options

					create_click_connection(parent, dropdown_border, function()
						local original_options = properties["options"]
						local new_options = {}

						for i = 1, #original_options do
							new_options[#new_options + 1] = original_options[i]
						end

						for _, file in listfiles(file_path .. "/custom") do
							local extension = file:match("%.([^%.]+)$")

							if extension then
								for i = 1, #extensions do
									if extensions[i] == extension then
										local file_name = file:match("([^/\\]+)$")
										local found = false
										for i = 1, #original_options do
											if original_options[i] == file_name then
												found = true
												break
											end
										end
										if not found then
											new_options[#new_options + 1] = file_name
										end
										break
									end
								end
							end
						end

						new_element["options"] = new_options

						open_dropdown(new_element)
					end)
				else
					create_click_connection(parent, dropdown_border, function()
						open_dropdown(new_element)
					end)
				end

				if not info["fake"] then
					create_right_click_connection(parent, dropdown_border, function(position)
						open_context(keybind_data[new_element] and { 2, 1 } or { 1 }, new_element, position)
					end)
				end

				local default = properties["default"]
				new_element["dropdown_default"] = default
				new_element["requires_one"] = properties["requires_one"]

				if default then
					new_element:set_dropdown(default)
				end
			elseif element == "keybind" then
				local keybind_border = drawing_proxy["new"]("Image", {
					["Parent"] = frame,
					["Position"] = udim2_new(1, -40, 0, 0),
					["Size"] = udim2_new(0, 40, 0, 12),
					["Color"] = menu["colors"]["border"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["ZIndex"] = zindex + 1,
					["Visible"] = true,
				})
				local keybind_inside = drawing_proxy["new"]("Image", {
					["Parent"] = keybind_border,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Color"] = menu["colors"]["background"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["ZIndex"] = zindex + 2,
					["Visible"] = true,
				})
				local keybind_text = drawing_proxy["new"]("Text", {
					["Color"] = menu["colors"]["dark_text"],
					["Text"] = "none",
					["Size"] = 12,
					["Font"] = 1,
					["Transparency"] = 1,
					["Visible"] = true,
					["Parent"] = keybind_inside,
					["Center"] = true,
					["ZIndex"] = zindex + 3,
					["Position"] = udim2_new(0.5, 0, 0, -1),
				})

				local size = keybind_text["TextBounds"]["X"] + 8

				keybind_border["Size"] = udim2_new(0, size, 0, 12)
				keybind_border["Position"] = udim2_new(1, -size, 0, 0)
				keybind_inside["Size"] = udim2_new(0, size - 2, 0, 10)

				new_element["drawings"]["keybind_border"] = keybind_border
				new_element["drawings"]["keybind_inside"] = keybind_inside
				new_element["drawings"]["keybind_text"] = keybind_text
				new_element["on_key_change"] = signal["new"]()
				new_element["on_key_press"] = signal["new"]()

				create_hover_connection(parent, frame, function()
					tween(keybind_border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end, function()
					tween(keybind_border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
				end)

				create_click_connection(parent, frame, function()
					start_binding(new_element)
				end)

				if properties["flag"] then
					new_element["keybind_flag"] = properties["flag"]

					local data = math_random(9000000, 90000000)
					keybind_data[data] = {
						["key"] = properties["default"],
						["value"] = true,
						["original_value"] = false,
						["set_activated"] = function()
							new_element["on_key_press"]:Fire()
						end,
					}
					create_connection(new_element["on_key_change"], function(key)
						keybind_data[data]["key"] = key
						flags[properties["flag"]] = key
					end)
				end
			elseif element == "colorpicker" then
				local transparency = properties["default_transparency"] or 0
				local color = properties["default_color"] or color3_fromrgb(255, 0, 0)

				local colorpicker_border = drawing_proxy["new"]("Image", {
					["Parent"] = frame,
					["Position"] = udim2_new(1, -25, 0, 0),
					["Size"] = udim2_new(0, 25, 0, 12),
					["Color"] = menu["colors"]["border"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["ZIndex"] = zindex + 1,
					["Visible"] = true,
				})
				local colorpicker_inside = drawing_proxy["new"]("Image", {
					["Parent"] = colorpicker_border,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Color"] = menu["colors"]["background"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["ZIndex"] = zindex + 2,
					["Visible"] = true,
				})
				local colorpicker_transparency = drawing_proxy["new"]("Image", {
					["Parent"] = colorpicker_inside,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Color"] = color3_fromrgb(255, 255, 255),
					["Transparency"] = -transparency + 1,
					["Rounding"] = 4,
					["Data"] = transparency_image_data,
					["ZIndex"] = zindex + 3,
					["Visible"] = true,
				})
				local colorpicker_fill = drawing_proxy["new"]("Image", {
					["Parent"] = colorpicker_transparency,
					["Position"] = udim2_new(0, 0, 0, 0),
					["Size"] = udim2_new(1, 0, 1, 0),
					["Color"] = color,
					["Transparency"] = 1,
					["Rounding"] = 2,
					["Data"] = pixel_image_data,
					["ZIndex"] = zindex + 3,
					["Visible"] = true,
				})

				new_element["drawings"]["colorpicker_transparency"] = colorpicker_transparency
				new_element["drawings"]["colorpicker_border"] = colorpicker_border
				new_element["drawings"]["colorpicker_inside"] = colorpicker_inside
				new_element["drawings"]["colorpicker_fill"] = colorpicker_fill

				new_element["transparency_flag"] = properties["transparency_flag"]
				new_element["color_flag"] = properties["color_flag"]
				new_element["on_transparency_change"] = signal["new"]()
				new_element["on_color_change"] = signal["new"]()

				create_hover_connection(parent, colorpicker_border, function()
					tween(colorpicker_border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end, function()
					tween(colorpicker_border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
				end)

				create_click_connection(parent, colorpicker_border, function()
					open_colorpicker(new_element)
				end)

				create_right_click_connection(parent, colorpicker_border, function(position)
					open_context({ 7, 3, 4 }, new_element, position)
				end)

				new_element:set_colorpicker(properties["default_color"] or color3_fromrgb(255, 0, 0))
				new_element:set_colorpicker_transparency(properties["default_transparency"] or 0)
			elseif element == "info" then
				new_element["drawings"]["info_text"] = drawing_proxy["new"]("Text", {
					["Color"] = menu["colors"]["inactive_text"],
					["Text"] = "",
					["Size"] = 12,
					["Font"] = 1,
					["Transparency"] = 1,
					["Visible"] = true,
					["Parent"] = frame,
					["Position"] = udim2_new(0, 0, 0, -1),
					["ZIndex"] = zindex + 1,
				})
			elseif element == "button" then
				total_y_size += 4
				local button_border = drawing_proxy["new"]("Image", {
					["Parent"] = frame,
					["Position"] = udim2_new(0, 0, 0, 0),
					["Size"] = udim2_new(1, 0, 0, 16),
					["Color"] = menu["colors"]["border"],
					["Transparency"] = 1,
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["Visible"] = true,
					["ZIndex"] = zindex + 1,
				})
				local button_inside = drawing_proxy["new"]("Image", {
					["Parent"] = button_border,
					["Position"] = udim2_new(0, 1, 0, 1),
					["Size"] = udim2_new(1, -2, 1, -2),
					["Color"] = menu["colors"]["background"],
					["Rounding"] = 4,
					["Data"] = pixel_image_data,
					["Transparency"] = 1,
					["ZIndex"] = zindex + 2,
					["Visible"] = true,
				})
				local button_icon = drawing_proxy["new"]("Image", {
					["Parent"] = button_border,
					["Position"] = udim2_new(1, -14, 0, 3),
					["Size"] = udim2_new(0, 10, 0, 10),
					["Color"] = menu["colors"]["dark_text"],
					["Rounding"] = 4,
					["Data"] = button_image_data,
					["Transparency"] = 1,
					["ZIndex"] = zindex + 3,
					["Visible"] = true,
				})
				local button_text = drawing_proxy["new"]("Text", {
					["Color"] = menu["colors"]["dark_text"],
					["Text"] = info["text"],
					["Size"] = 12,
					["Font"] = 1,
					["Transparency"] = 1,
					["Visible"] = true,
					["Parent"] = button_inside,
					["Center"] = false,
					["ZIndex"] = zindex + 3,
					["Position"] = udim2_new(0, 3, 0, 0),
				})

				local cooldown = clock()

				new_element["on_clicked"] = signal["new"]()

				local drawings = new_element["drawings"]
				drawings["button_border"] = button_border
				drawings["button_inside"] = button_inside
				drawings["button_text"] = button_text
				drawings["button_icon"] = button_icon
				drawings["text"]["Text"] = ""

				create_hover_connection(parent, button_border, function()
					tween(button_border, { Color = menu["colors"]["highlighted"] }, circular, out, 0.17)
				end, function()
					tween(button_border, { Color = menu["colors"]["border"] }, circular, out, 0.17)
				end)

				if properties["confirmation"] then
					local in_confirmation = false

					create_click_connection(parent, button_border, function()
						if clock() - cooldown > 0.15 and not actives["typing"] then
							cooldown = clock()
							if in_confirmation then
								new_element["on_clicked"]:Fire()
								tween(button_inside, { Color = color3_fromrgb(40, 40, 40) }, circular, out, 0.075)
								delay(0.075, function()
									tween(button_inside, { Color = menu["colors"]["background"] }, circular, out, 0.075)
								end)
								tween(button_text, { ["Color"] = menu["colors"]["dark_text"] }, circular, out, 0.075)
								tween(button_text, { ["tween_position"] = udim2_new(0, 3, 0, 0) }, circular, out, 0.075)
								in_confirmation = false
							else
								tween(button_text, { Color = menu["colors"]["accent"] }, circular, out, 0.075)
								local old = cooldown
								in_confirmation = cooldown
								for i = 1, 3 do
									if in_confirmation ~= old then
										break
									end
									button_text["Text"] = "are you sure? (" .. (4 - i) .. "s left)"
									tween(
										button_text,
										{ ["tween_position"] = udim2_new(0, 3, 0, -1) },
										circular,
										out,
										0.075
									)
									wait(0.075)
									if in_confirmation ~= old then
										break
									end
									tween(
										button_text,
										{ ["tween_position"] = udim2_new(0, 3, 0, 0) },
										circular,
										out,
										0.075
									)
									wait(0.925)
								end
								button_text["Text"] = info["text"]
								tween(button_text, { ["Color"] = menu["colors"]["dark_text"] }, circular, out, 0.075)
								tween(button_text, { ["tween_position"] = udim2_new(0, 3, 0, 0) }, circular, out, 0.075)
								in_confirmation = false
							end
						end
					end)
				else
					create_click_connection(parent, button_border, function()
						if clock() - cooldown > 0.15 then
							cooldown = clock()
							new_element["on_clicked"]:Fire()
							tween(button_inside, { Color = color3_fromrgb(40, 40, 40) }, circular, out, 0.075)
							delay(0.075, function()
								tween(button_inside, { Color = menu["colors"]["background"] }, circular, out, 0.075)
							end)
						end
					end)

					if not info["fake"] then
						create_right_click_connection(parent, button_border, function(position)
							open_context(keybind_data[new_element] and { 2, 1 } or { 1 }, new_element, position)
						end)
					end
				end
			end
		end

		local tip = info["tip"]

		if tip then
			create_hover_connection(parent, button_border, function()
				show_tooltip(new_element, tip)
			end, function()
				hide_tooltip(new_element, tip)
			end)
		end

		new_element["total_y_size"] = total_y_size

		frame["Size"] = udim2_new(1, -20, 0, total_y_size)

		return new_element, total_y_size
	end

	function element:set_info(property, value)
		local text = self["drawings"]["info_text"]
		text[property] = value

		if property == "Text" then
			text["Position"] = udim2_new(1, -text["TextBounds"]["X"], 0, -1)
		end
	end

	function element:set_options(options)
		self:set_dropdown()
		self["options"] = options
	end

	function element:set_toggle(value, just_keybind)
		local keybind = keybind_data[self]
		if keybind then
			if not just_keybind then
				local is_on_not_held = keybind["method"] == 2
				keybind["value"] = value
				keybind["activated"] = is_on_not_held or value
				spawn(on_keybind_change["Fire"], on_keybind_change, keybind, self, is_on_not_held or value)

				if is_on_not_held then
					return
				end
			end
		end

		local drawings = self["drawings"]
		tween(
			drawings["text"],
			{ Color = value and menu["colors"]["active_text"] or menu["colors"]["inactive_text"] },
			exponential,
			out,
			0.2
		)
		tween(drawings["checkmark"], { Transparency = value and 0.5 or 0 }, exponential, out, 0.2)

		flags[self["toggle_flag"]] = value
		self["on_toggle_change"]:Fire(value)
	end

	function element:set_slider(value, just_keybind)
		local drawings = self["drawings"]
		local max = self["slider_max"]
		local min = self["slider_min"]
		value = clamp(value, min, max)

		tween(
			drawings["slider_fill"],
			{ tween_size = udim2_new((value - min) / (max - min), value == max and -2 or 0, 1, -2) },
			exponential,
			out,
			0.2
		)

		local text = drawings["slider_text"]
		if value == min then
			tween(drawings["slider_line"], { Color = menu["colors"]["dark_text"] }, circular, out, 0.2)
			text["Text"] = self["slider_min_text"] or self["slider_prefix"] .. value .. self["slider_suffix"]
		else
			tween(drawings["slider_line"], { Color = menu["colors"]["accent"] }, circular, out, 0.2)
			text["Text"] = (value == max and self["slider_max_text"])
				or self["slider_prefix"] .. value .. self["slider_suffix"]
		end

		local keybind = keybind_data[self]

		if keybind then
			if not just_keybind then
				keybind["original_value"] = value
			end
		end

		flags[self["slider_flag"]] = value
		self["on_slider_change"]:Fire(value)
	end

	function element:set_textbox(value)
		flags[self["textbox_flag"]] = value
		self["drawings"]["textbox_text"]["Text"] = value == nil and "..." or value == "" and "..." or value
		self["on_textbox_change"]:Fire(value)
	end

	function element:set_colorpicker(value)
		flags[self["color_flag"]] = value
		self["drawings"]["colorpicker_fill"]["Color"] = value

		self["on_color_change"]:Fire(value)
	end

	function element:set_colorpicker_transparency(value)
		flags[self["transparency_flag"]] = value
		self["drawings"]["colorpicker_fill"]["Transparency"] = -value + 1

		self["on_transparency_change"]:Fire(value)
	end

	function element:set_dropdown(value, just_keybind, no_fire)
		local drawings = self["drawings"]
		local dropdown_text = drawings["dropdown_text"]
		local max_textbounds = drawings["dropdown_inside"]["real_size"]["X"]

		local text = ""
		local last_text = ""

		value = type(value) == "table" and value or { value }

		local options = self["options"]

		for i = 1, #value do
			local option = value[i]
			local found = false
			for i = 1, #options do
				if options[i] == option then
					found = true
					break
				end
			end
			if not found then
				for i = 1, #value do
					if value[i] == option then
						remove(value, i)
						break
					end
				end
			end
		end

		if value and #value ~= 0 then
			for i = 1, #value do
				local option = value[i]
				text = i == 1 and option or text .. ", " .. option
				dropdown_text["Text"] = text

				if dropdown_text["TextBounds"]["X"] + 8 > max_textbounds then
					dropdown_text["Text"] = last_text .. "..."
					break
				end

				last_text = text
			end
		else
			dropdown_text["Text"] = "none"
		end

		local keybind = keybind_data[self]

		if keybind then
			if not just_keybind then
				keybind["original_value"] = value
			end
		end

		flags[self["dropdown_flag"]] = value

		if not no_fire then
			self["on_dropdown_change"]:Fire(value)
		end
	end

	function element:update_dropdown_value(option)
		local value = flags[self["dropdown_flag"]]
		local multi = self["multi"]
		local requires_one = self["requires_one"]

		if multi then
			local count = value and #value or 0
			for i = 1, count do
				if value[i] == option then
					if requires_one and count == 1 then
						return nil
					end

					remove(value, i)

					self:set_dropdown(value)

					return false
				end
			end

			if value then
				value[#value + 1] = option
			else
				value = { option }
				flags[self["dropdown_flag"]] = value
			end

			self:set_dropdown(value)

			return true
		else
			if value and option == value[1] then
				if requires_one then
					return nil
				end

				self:set_dropdown(nil)

				return false
			else
				self:set_dropdown({ option })

				return true
			end
		end
	end

	function element:set_key(value)
		local drawings = self["drawings"]
		local keybind_border = drawings["keybind_border"]
		local keybind_inside = drawings["keybind_inside"]
		local keybind_text = drawings["keybind_text"]

		keybind_text["Text"] = value
				and (shortened_characters[value] and shortened_characters[value] or value["Name"]:lower())
			or "none"

		local size = keybind_text["TextBounds"]["X"] + 8

		keybind_border["Size"] = udim2_new(0, size, 0, 12)
		keybind_border["Position"] = udim2_new(1, -size, 0, 0)
		keybind_inside["Size"] = udim2_new(0, size - 2, 0, 10)
		keybind_text["Position"] = udim2_new(0, (size - 2) / 2, 0, -2)

		local flag = self["keybind_flag"]

		if flag then
			flags[flag] = value
		end

		self["on_key_change"]:Fire(value)
	end

	local settings = {}
	settings["__index"] = settings

	function settings:create_element(a, b, c)
		return self["sections"][a["section"] or 1]:create_element(a, b, c)
	end

	function element:create_settings(count)
		local frame = self["frame"]
		local cog_icon = drawing_proxy["new"]("Image", {
			["Data"] = cog_image_data,
			["Visible"] = true,
			["Transparency"] = 1,
			["Color"] = menu["colors"]["inactive_text"],
			["Size"] = udim2_new(0, 10, 0, 10),
			["Position"] = udim2_new(1, -10, 0, 1),
			["ZIndex"] = frame["ZIndex"] + 4,
			["Parent"] = frame,
		})

		self["drawings"]["cog_icon"] = cog_icon

		create_hover_connection(frame, cog_icon, function()
			tween(cog_icon, { ["Color"] = menu["colors"]["highlighted"] }, circular, out, 0.17)
		end, function()
			tween(cog_icon, { Color = menu["colors"]["inactive_text"] }, circular, out, 0.17)
		end)

		local section_border = drawing_proxy["new"]("Image", {
			["Parent"] = cog_icon,
			["Position"] = udim2_new(1, 5, 0, -5),
			["Size"] = udim2_new(0, 170, 0, 10),
			["Color"] = menu["colors"]["border"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = 500,
			["Visible"] = false,
		})
		local section_inside = drawing_proxy["new"]("Image", {
			["Parent"] = section_border,
			["Position"] = udim2_new(0, 1, 0, 1),
			["Size"] = udim2_new(1, -2, 1, -2),
			["Color"] = menu["colors"]["section"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = 501,
			["Visible"] = true,
		})

		local new_settings = setmetatable({
			["sections"] = {},
			["elements"] = {},
			["border"] = section_border,
			["inside"] = section_inside,
		}, settings)

		for i = 1, type(count) == "number" and count or 1 do
			local new_section = setmetatable({
				["tab"] = self["section"]["tab"],
				["total_y_size"] = 10,
				["frame"] = self["frame"],
				["elements"] = new_settings["elements"],
			}, section)

			local element_holder = drawing_proxy["new"]("Square", {
				["Parent"] = section_inside,
				["Position"] = udim2_new(0, 10 + i * 180, 0, 10),
				["Size"] = udim2_new(1, -20, 1, -20),
				["Transparency"] = 0,
				["Filled"] = true,
				["ZIndex"] = 502,
				["Visible"] = true,
			})

			new_section["border"] = section_border
			new_section["inside"] = section_inside
			new_section["holder"] = element_holder

			new_settings["sections"][i] = new_section
		end

		create_click_connection(self["frame"], cog_icon, function()
			if actives["settings"] == new_settings then
				close_settings(new_settings)
			else
				open_settings(new_settings)
			end
		end)

		menu["settings"][self] = new_settings

		return new_settings
	end

	function element:remove()
		local parent = self["parent"]
		local object = self["frame"]

		local connections = click_connections[parent]

		if connections then
			connections[object] = nil
		end

		local connections = hover_connections[parent]

		if connections then
			connections[object] = nil
		end

		local connections = right_click_connections[parent]

		if connections then
			connections[object] = nil
		end

		local drawings = self["drawings"]

		for _, drawing in drawings do
			drawing:Destroy()
			drawings[_] = nil
		end

		local section = self["section"]
		local elements = section["elements"]

		for i = 1, #elements do
			if elements[i] == self then
				remove(elements, i)
				break
			end
		end

		section:recalculate_size()
	end

	function element:set_visible(visible, old)
		if not old then
			self["old_visible"] = visible
		end
		self["visible"] = visible
		self["frame"]["Visible"] = visible
		self["section"]:recalculate_size()
	end

	function section:create_element(info, elements, fake)
		local position = self["total_y_size"]
		local new_element, total_y_size = element["new"]({
			["text"] = info["name"],
			["parent"] = self["inside"],
			["position"] = udim2_new(0, 10, 0, position),
			["fake"] = fake,
			["old_visible"] = true,
			["section"] = self,
		}, elements)

		self["total_y_size"] += total_y_size

		self["elements"][#self["elements"] + 1] = new_element

		if not self["side"] then
			self["border"]["Size"] = udim2_new(0, 170, 0, self["total_y_size"] + 7)
			self["inside"]["Size"] = udim2_new(1, -2, 1, -2)
		end

		return new_element
	end

	function section:recalculate_size()
		local elements = self["elements"]
		local total_size = 10

		for i = 1, #elements do
			local element = elements[i]
			if element["visible"] then
				element["frame"]["Position"] = udim2_new(0, 10, 0, total_size)
				total_size += element["total_y_size"]
			end
		end

		if not self["side"] then
			self["border"]["Size"] = udim2_new(0, 170, 0, total_size + 7)
			self["inside"]["Size"] = udim2_new(1, -2, 1, -2)
		end

		self["total_y_size"] = total_size
	end

	function section:destroy()
		if not self["border"] then
			return
		end
		for _, element in self["elements"] do
			element:remove()
		end
		for _, drawing in self do
			local type = typeof(drawing)
			if (type == "Drawing" or type == "Table") and rawget(drawing, "Destroy") then
				drawing["Destroy"](drawing)
				self[_] = nil
			end
		end
	end

	-- > ( notifications )

	menu_references["notification_types"] = {
		[1] = {
			color3_fromrgb(174, 255, 0),
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAADp1fY4ytpsegAAAFFJREFUOE/NzEsOgCAMRdGy/0UrlxSDtY90RDwD/hc7rvlccnW+rIdrhFL4ieBrKYvGzDAv40cqQlOXuwjpoyhGeA5UnEV4HcZYRSli+PY3zG4fbDP68uskQAAAAABJRU5ErkJggg=="
			),
		},
		[2] = {
			color3_fromrgb(255, 225, 0),
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADdYAAA3WAZBveZwAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAiF8BAOgDAACIXwEA6AMAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAAC1cWHl18YwawAAAGdJREFUOE+dkUsOgDAIRMWd9z+sSxUyNAKZ/t5mSmBKoQfjAQgLAg1kg3zg2Dihy5Sb2PNyV9pRCxWEhWBk3ZSca8aeyfnXbC/HjDPdHK+14VeMim2tY7qgNzRAjf4VNM8SIzZnFHkB8alA8IwiGIYAAAAASUVORK5CYII="
			),
		},
		[3] = {
			color3_fromrgb(255, 60, 63),
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAMAAAAolt3jAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAPgAAAD4ABMkKt4wAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAADMiQEA6AMAAMyJAQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAAd06aoHBh5lAAAAPElEQVQYV22LQQ4AMAjC8P+fHqg4l4yDthERQHRIUGzONd9rGTLk9SRcb38tc7mFkRpy5VTtKY1zltERByNGAFUDKq+CAAAAAElFTkSuQmCC"
			),
		},
		[4] = {
			color3_fromrgb(255, 60, 63),
			base64_decode(
				"iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAMAAAAolt3jAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAOwgAADsIBFShKgAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAADydgEA6AMAAPJ2AQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAI47wVfTF7xOAAAAP0lEQVQYV22NSQoAIBDDnP9/WpNW8GBwaZyCa2TdO+choQJRgouM2vN2UFLx1V0eNQUkk9rnI4IQ21OuUj7MbDBmAHXXCP83AAAAAElFTkSuQmCC"
			),
		},
	}

	do
		menu_references["update_notifications"] = LPH_NO_VIRTUALIZE(function()
			local notifications = menu["notifications"]
			local size = camera["ViewportSize"]["Y"] * 0.88
			if #notifications > 6 then
				notifications[1]:dismiss()
			end
			for i = 1, #notifications do
				local notification = notifications[i]
				local inside = notification["inside"]
				local position = inside["Position"]
				local new_position = udim2_new(0, position["X"], 0, size - (i * 29))
				if position ~= new_position then
					tween(inside, { tween_position = new_position }, exponential, out, 0.14)
				end
			end
		end)

		menu_references["notification_colors"] = menu["colors"]
		menu_references["notification"] = {}
		menu_references["notification"]["__index"] = menu_references["notification"]

		menu["new_notification"] = function(text, type, time, data)
			if do_notifications then
				local color = typeof(time) == "Color3" and time
					or (type == 1 and menu_references["notification_colors"]["success"])
					or (type == 2 and menu_references["notification_colors"]["alert"])
					or (type == 3 and menu_references["notification_colors"]["error"])
					or menu_references["notification_colors"]["accent"]
				local inside = drawing_proxy["new"]("Image", {
					["Data"] = pixel_image_data,
					["Rounding"] = 7,
					["Size"] = udim2_new(1, -2, 1, -2),
					["Position"] = udim2_new(0, 1, 0, 1),
					["Color"] = menu_references["notification_colors"]["background"],
					["Transparency"] = 0,
					["ZIndex"] = 1101,
					["Visible"] = true,
				})
				local image = drawing_proxy["new"]("Image", {
					["Parent"] = inside,
					["Position"] = udim2_new(0, 5, 0, 5),
					["Size"] = udim2_new(0, 12, 0, 12),
					["Color"] = color,
					["Transparency"] = 0,
					["Data"] = data or menu_references["notification_types"][type][2],
					["Rounding"] = 4,
					["ZIndex"] = 1102,
					["Visible"] = true,
				})
				local text = drawing_proxy["new"]("Text", {
					["Parent"] = inside,
					["Position"] = udim2_new(0, 26, 0, 5),
					["Color"] = menu_references["notification_colors"]["active_text"],
					["Text"] = text,
					["Size"] = 12,
					["Font"] = 1,
					["ZIndex"] = 1102,
					["Transparency"] = 0,
					["Visible"] = true,
				})
				local shadow = drawing_proxy["new"]("Image", {
					["Parent"] = inside,
					["Data"] = shadow_image_data,
					["Rounding"] = 8,
					["Color"] = color,
					["Transparency"] = 0,
					["ZIndex"] = 1100,
					["Visible"] = true,
					["Position"] = udim2_new(0, 0, 0, 0),
				})

				local x_size = 32 + text["TextBounds"]["X"]
				local size = udim2_new(0, x_size, 0, 24)

				inside["Size"] = size

				local shadow_size = floor(x_size / 13)
				shadow["Size"] = size + udim2_new(0, shadow_size, 0, 6)
				shadow["Position"] = udim2_new(0, -shadow_size / 2, 0, -3)

				local new_notification = setmetatable({
					["inside"] = inside,
					["image"] = image,
					["text"] = text,
					["shadow"] = shadow,
					["start"] = clock(),
					["active"] = true,
				}, menu_references["notification"])

				delay(clamp(time and typeof(time) == "number" and time or 2, 0.5, 7), function()
					if new_notification["active"] then
						new_notification:dismiss()
					end
				end)

				local notifications = menu["notifications"]
				local viewport_size = camera["ViewportSize"]

				inside["Position"] = udim2_new(
					0,
					(viewport_size["X"] * 0.5) - (x_size * 0.5),
					0,
					viewport_size["Y"] * 0.88 - (#notifications * 29 - 5)
				)

				tween(inside, { Transparency = 0.89 }, circular, out, 0.12)
				tween(image, show_transparency, circular, out, 0.12)
				tween(text, show_transparency, circular, out, 0.12)
				tween(shadow, { Transparency = 0.16 }, circular, out, 0.12)

				notifications[#notifications + 1] = new_notification

				spawn(menu_references["update_notifications"])
			end
		end

		menu_references["notification"]["dismiss"] = function(self)
			local inside = self["inside"]
			local image = self["image"]
			local text = self["text"]
			local shadow = self["shadow"]
			tween(inside, hide_transparency, circular, out, 0.12)
			tween(image, hide_transparency, circular, out, 0.12)
			tween(text, hide_transparency, circular, out, 0.12)
			tween(shadow, hide_transparency, circular, out, 0.12)
			self["active"] = false

			local notifications = menu["notifications"]
			for i = 1, #notifications do
				if notifications[i] == self then
					remove(notifications, i)
					break
				end
			end

			delay(0.12, function()
				inside:Destroy()
				image:Destroy()
				text:Destroy()
				shadow:Destroy()
				spawn(menu_references["update_notifications"])
			end)
		end
	end

	-- > ( finalization )

	do
		-- >> ( menu finalization )

		keybind_section = setmetatable({
			["name"] = name,
			["side"] = side,
			["size"] = size,
			["total_y_size"] = 10,
			["holder"] = keybind_holder,
			["border"] = keybind_border,
			["inside"] = keybind_inside,
			["elements"] = {},
		}, section)

		create_hover_connection(list_frame, list_frame, function()
			tween(list_frame, { Color = menu["colors"]["highlighted"], Transparency = 1 }, circular, out, 0.15)
		end, function()
			tween(list_frame, { Color = menu["colors"]["border"], Transparency = 0.2 }, circular, out, 0.15)
		end)

		menu.set_accent_color = LPH_JIT_MAX(function(color)
			menu["colors"]["accent"] = color

			tab_line["Color"] = color
			drag_logo["Color"] = color
			for name, group in menu["groups"] do
				group["text"]["Color"] = color
				group["line"]["Color"] = color

				for name, tab in group["tabs"] do
					for _, section in tab["sections"] do
						section["line_two"]["Color"] = color
						section["line"]["Color"] = color
						section["label"]["Color"] = color

						for _, element in section["elements"] do
							local drawings = element["drawings"]
							local checkmark = drawings["checkmark"]
							local slider_fill = drawings["slider_fill"]
							local slider_text = drawings["slider_text"]

							local icons = element["icons"]

							if icons then
								for i = 1, #icons do
									local icon = icons[i]
									drawings[icon[2]]["Color"] = color
								end
							end

							if slider_fill then
								slider_fill["Color"] = color

								if flags[element["slider_flag"]] > element["slider_min"] then
									drawings["slider_line"]["Color"] = color
								end
							end

							if checkmark then
								checkmark["Color"] = color
							end
						end
					end
				end
			end

			for _, settings in menu["settings"] do
				for _, element in settings["elements"] do
					local drawings = element["drawings"]
					local checkmark = drawings["checkmark"]
					local slider_fill = drawings["slider_fill"]

					if slider_fill then
						slider_fill["Color"] = color

						if flags[element["slider_flag"]] > element["slider_min"] then
							drawings["slider_line"]["Color"] = color
						end
					end

					if checkmark then
						checkmark["Color"] = color
					end
				end
			end

			for i = 1, #context_buttons do
				context_buttons[i]["icon"]["Color"] = color
			end

			list_divider["Color"] = color
			list_icon["Color"] = color

			for _, drawing in list_drawings do
				drawing["value"]["Color"] = color
			end
		end)

		-- >> ( config system )

		menu.get_config_list = function()
			local list = {}
			local folder = file_path .. "/configs/"
			local prefix_len = #folder

			local files = listfiles(folder)
			for _, file in ipairs(files) do
				local ext = file:match("%.([^%.]+)$")
				if ext and ext:lower() == "cfg" then
					local name = file:sub(prefix_len + 1, -5)
					if name ~= "" then
						list[#list + 1] = name
					end
				end
			end

			return list
		end
		menu.get_addon_list = function()
			local list = {}

			local files = listfiles(file_path .. "/addons/")
			for _, file in files do
				if string["match"](file, "%.(.*)") == "luau" then
					list[#list + 1] = string["sub"](file, 20, #file - 5)
				end
			end

			return list
		end

		menu.get_skins_list = function()
			local list = {}

			local files = listfiles(file_path .. "/custom/")
			for _, file in files do
				if string["match"](file, "%.(.*)") == "skin" then
					list[#list + 1] = string["sub"](file, 20, #file - 5)
				end
			end

			return list
		end

		menu.get_theme_list = function()
			local list = {}

			local files = listfiles(file_path .. "/themes/")
			for _, file in files do
				if string["match"](file, "%.(.*)") == "th" then
					list[#list + 1] = string["sub"](file, 20, #file - 3)
				end
			end

			return list
		end

		menu.save_config = LPH_JIT(function(name)
			if string["find"](name, "%/") or string["find"](name, "%.") then
				return
			end

			local keybinds = {}

			local config = {
				["keybinds"] = keybinds,
				["author"] = flags["author"] or LRM_LinkedDiscordID or "Unknown",
				["date"] = os["date"]("%x"),
			}

			for flag, data in flags do
				local data = data
				local type_of = typeof(data)
				if type_of == "Color3" then
					data = { floor(data["R"] * 255), floor(data["G"] * 255), floor(data["B"] * 255) }
				elseif type_of == "EnumItem" then
					data = data["Name"]
				end

				if flag:sub(1, 1) == "!" then
					continue
				end

				config[flag] = data
			end

			for element, data in keybind_data do
				if type(element) == "table" then
					local type = data["type"]
					local flag =
						data["element"][type == 1 and "dropdown_flag" or type == 2 and "slider_flag" or type == 3 and "toggle_flag" or type == 4 and "name"]
					local original_value = data["original_value"]

					keybinds[#keybinds + 1] = {
						["flag"] = flag,
						["og_value"] = original_value,
						["value"] = data["value"],
						["method"] = data["method"],
						["key"] = data["key"]["Name"],
						["type"] = type,
					}

					config[flag] = original_value
				end
			end

			writefile(file_path .. "/configs/" .. name .. ".cfg", http_service:JSONEncode(config))
		end)

		menu["get_config_data"] = LPH_JIT(function(data)
			local success, json = pcall(function()
				return http_service:JSONDecode(data)
			end)

			if success then
				return json
			end
		end)

		menu["load_config"] = LPH_JIT_MAX(function(name)
			if string["find"](name, "%/") or string["find"](name, "%.") then
				return
			end

			local path = file_path .. "/configs/" .. name .. ".cfg"

			if isfile(path) then
				local new_flags = menu["get_config_data"](readfile(path))

				if new_flags then
					local loaded_addons = new_flags["loaded_addons"]

					if loaded_addons then
						for _, addon in addon_data do
							for i = 1, #loaded_addons do
								if addon == loaded_addons[i] then
									continue
								end
								menu["unload_addon"](loaded_addons[i])
							end
						end

						for _, addon in loaded_addons do
							if not addon_data[addon] then
								menu["load_addon"](addon)
							end
						end
					else
						for _, addon in addon_data do
							menu["unload_addon"](addon)
						end
					end

					for element, keybind in keybind_data do
						if element ~= 1 then
							on_keybind_deleted:Fire(keybind, element, true)
						end
					end

					local colors = menu["colors"]
					for color, old in colors do
						local value = new_flags[color .. "_color"]

						if value then
							colors[color] = color3_fromrgb(value[1], value[2], value[3])
						end
					end

					local keybinds = new_flags["keybinds"]

					if keybinds then
						for _, data in keybind_data do
							if type(_) == "table" then
								keybind_data[_] = nil
							end
						end

						for _, new_keybind in keybinds do
							local flag = new_keybind["flag"]
							local type = new_keybind["type"]
							local flag_name = type == 1 and "dropdown_flag"
								or type == 2 and "slider_flag"
								or type == 3 and "toggle_flag"
								or type == 4 and "name"
							local new_keybind_data = nil

							local key = new_keybind["key"]

							local s = pcall(function()
								key = Enum["UserInputType"][key]
							end)
							if not s then
								s = pcall(function()
									key = Enum["KeyCode"][key]
								end)
							end

							if s then
								for _, group in menu["groups"] do
									for name, tab in group["tabs"] do
										for _, section in tab["sections"] do
											local elements = section["elements"]
											for i = 1, #elements do
												local element = elements[i]
												if element[flag_name] == flag then
													local method = new_keybind["method"]

													new_keybind_data = setmetatable({
														["method"] = type == 2 and 1 or method,
														["original_value"] = new_keybind["og_value"],
														["value"] = (type == 4 and "")
															or (type == 3 and new_flags[element[flag_name]])
															or (type ~= 3 and new_keybind["value"]),
														["type"] = type,
														["activated"] = method == 2,
														["element"] = element,
														["key"] = key,
													}, keybind)

													break
												end
											end
										end
									end
								end

								for _, settings in menu["settings"] do
									local elements = settings["elements"]
									for i = 1, #elements do
										local element = elements[i]
										if element[flag_name] == flag then
											local method = new_keybind["method"]
											new_keybind_data = setmetatable({
												["method"] = type == 2 and 1 or method,
												["original_value"] = new_keybind["og_value"],
												["value"] = (type == 4 and "")
													or (type == 3 and new_flags[element[flag_name]])
													or (type ~= 3 and new_keybind["value"]),
												["type"] = type,
												["activated"] = method == 2,
												["element"] = element,
												["key"] = key,
											}, keybind)
											break
										end
									end
								end

								if new_keybind_data then
									local element = new_keybind_data["element"]
									keybind_data[element] = new_keybind_data

									on_keybind_created:Fire(new_keybind_data, element)
								end
							end
						end
					end

					for name, group in menu["groups"] do
						for name, tab in group["tabs"] do
							for _, section in tab["sections"] do
								local elements = section["elements"]
								for i = 1, #elements do
									local element = elements[i]
									local slider_flag = element["slider_flag"]
									local toggle_flag = element["toggle_flag"]
									local dropdown_flag = element["dropdown_flag"]
									local textbox_flag = element["textbox_flag"]
									local colorpicker_flag = element["color_flag"]
									local keybind_flag = element["keybind_flag"]

									if slider_flag then
										local value = flags[slider_flag]
										local new_value = new_flags[slider_flag]

										if new_value ~= nil and value ~= new_value then
											element:set_slider(new_value)
										end
									end

									if toggle_flag then
										local value = flags[toggle_flag]
										local new_value = new_flags[toggle_flag]

										if new_value ~= nil and value ~= new_value then
											element:set_toggle(new_value)
										end
									end

									if dropdown_flag then
										local value = flags[dropdown_flag]
										local new_value = new_flags[dropdown_flag]

										if value ~= new_value then
											if new_value then
												local options = element["options"]

												for _, value in new_value do
													local found = false
													for i = 1, #options do
														if options[i] == value then
															found = true
															break
														end
													end
													if not found then
														remove(new_value, _)
													end
												end
											end

											element:set_dropdown(
												(new_value and #new_value > 0 and new_value)
													or (element["requires_one"] and element["dropdown_default"])
											)
										end
									end

									if textbox_flag then
										local value = flags[textbox_flag]
										local new_value = new_flags[textbox_flag]

										if new_value ~= nil and value ~= new_value then
											element:set_textbox(new_value)
										end
									end

									if colorpicker_flag then
										local color_value = flags[colorpicker_flag]
										local new_color_value = new_flags[colorpicker_flag]
										new_color_value = new_color_value
												and color3_fromrgb(
													new_color_value[1],
													new_color_value[2],
													new_color_value[3]
												)
											or nil
										local transparency_flag = element["transparency_flag"]
										local transparency_value = flags[transparency_flag]
										local new_transparency_value = new_flags[transparency_flag]

										if new_color_value ~= nil and color_value ~= new_color_value then
											element:set_colorpicker(new_color_value)
										end

										if
											new_transparency_value ~= nil
											and transparency_value ~= new_transparency_value
										then
											element:set_colorpicker_transparency(new_transparency_value)
										end
									end

									if keybind_flag then
										local value = flags[keybind_flag]
										local new_value = new_flags[keybind_flag]

										if new_value ~= nil and value ~= new_value then
											local s, err = pcall(function()
												new_value = Enum["UserInputType"][new_value]
											end)
											if not s then
												new_value = Enum["KeyCode"][new_value]
											end
											element:set_key(new_value)
										end
									end
								end
							end
						end
					end

					for element_settings, settings in menu["settings"] do
						local elements = settings["elements"]
						for i = 1, #elements do
							local element = elements[i]
							local slider_flag = element["slider_flag"]
							local toggle_flag = element["toggle_flag"]
							local dropdown_flag = element["dropdown_flag"]
							local textbox_flag = element["textbox_flag"]
							local colorpicker_flag = element["color_flag"]
							local keybind_flag = element["keybind_flag"]

							if slider_flag then
								local value = flags[slider_flag]
								local new_value = new_flags[slider_flag]

								if new_value ~= nil and value ~= new_value then
									element:set_slider(new_value)
								end
							end

							if toggle_flag then
								local value = flags[toggle_flag]
								local new_value = new_flags[toggle_flag]

								if new_value ~= nil and value ~= new_value then
									element:set_toggle(new_value)
								end
							end

							if dropdown_flag then
								local value = flags[dropdown_flag]
								local new_value = new_flags[dropdown_flag]

								if value ~= new_value then
									if new_value then
										local options = element["options"]

										for _, value in new_value do
											local found = false
											for i = 1, #options do
												if options[i] == value then
													found = true
													break
												end
											end
											if not found then
												remove(new_value, _)
											end
										end
									end

									element:set_dropdown(
										(new_value and #new_value > 0 and new_value)
											or (element["requires_one"] and element["dropdown_default"])
									)
								end
							end

							if textbox_flag then
								local value = flags[textbox_flag]
								local new_value = new_flags[textbox_flag]

								if new_value ~= nil and value ~= new_value then
									element:set_textbox(new_value)
								end
							end

							if colorpicker_flag then
								local color_value = flags[colorpicker_flag]
								local new_color_value = new_flags[colorpicker_flag]

								new_color_value = new_color_value
										and color3_fromrgb(new_color_value[1], new_color_value[2], new_color_value[3])
									or nil
								local transparency_flag = element["transparency_flag"]
								local transparency_value = flags[transparency_flag]
								local new_transparency_value = new_flags[transparency_flag]

								if new_color_value ~= nil and color_value ~= new_color_value then
									element:set_colorpicker(new_color_value)
								end

								if new_transparency_value ~= nil and transparency_value ~= new_transparency_value then
									element:set_colorpicker_transparency(new_transparency_value)
								end
							end

							if keybind_flag then
								local value = flags[keybind_flag]
								local new_value = new_flags[keybind_flag]

								if new_value ~= nil and value ~= new_value then
									local s, err = pcall(function()
										new_value = Enum["UserInputType"][new_value]
									end)
									if not s then
										new_value = Enum["KeyCode"][new_value]
									end
									element:set_key(new_value)
								end
							end
						end
					end

					local keybinds_position = new_flags["keybinds_position"]

					if keybinds_position then
						list_frame["Position"] = udim2_new(0, keybinds_position[1], 0, keybinds_position[2])
					end

					local skins = new_flags["skins"]

					if skins and type(skins) == "table" then
						flags["skins"] = skins
					end

					menu["on_config_loaded"]:Fire()
				end
			end
		end)

		do
			menu["unload_addon"] = function(name)
				local data = addon_data[name]

				if data then
					local thread = data[1]
					local on_unload = data[4]
					if on_unload then
						on_unload()
					end
					if data[2]["destroy"] then
						data[2]["destroy"](data[2])
						local addons_group = menu["groups"]["addons"]

						local count = #addons_group["ordered_tabs"]
						local is_visible = addons_group["is_visible"]
						if count == 0 and is_visible then
							addons_group["hide"](addons_group)
						elseif count > 0 and not is_visible then
							addons_group["show"](addons_group)
						end
					end
					for _, connection in data[3] do
						connection:Disconnect()
					end
					local loaded_addons = flags["loaded_addons"]
					local found = nil
					for i = 1, #loaded_addons do
						if loaded_addons[i] == name then
							found = i
							break
						end
					end
					if found then
						remove(loaded_addons, found)
					end

					coroutine["close"](thread)
					addon_data[name] = nil
				end
			end

			menu["load_addon"] = function(name)
				local path = file_path .. "/addons/" .. name .. ".luau"

				if not isfile(path) then
					return "file does not exist"
				end

				local data = readfile(path)

				local s, err = pcall(function()
					data = loadstring(data)
				end)

				if not s then
					return "juju: addon " .. name .. " experienced an error while loading: " .. err
				end

				if addon_data[name] then
					menu["unload_addon"](name)
				end

				getfenv(data).__IDENTIFIER = name

				local thread = coroutine["create"](data)

				addon_data[name] = {
					thread,
					{},
					{},
					function() end,
					name,
				}
				local loaded_addons = flags["loaded_addons"]
				loaded_addons[#loaded_addons + 1] = name

				local s, err = coroutine["resume"](thread)

				if not s then
					spawn(menu["unload_addon"], name)
					error("juju: addon " .. name .. " experienced an error while loading: " .. err)
				end
			end
		end

		-- >> ( fake settings )

		menu_references["settings_section"] = setmetatable({
			["total_y_size"] = 10,
			["elements"] = {},
		}, section)

		menu_references["settings_section"]["border"] = drawing_proxy["new"]("Image", {
			["Parent"] = settings_image,
			["Position"] = udim2_new(1, 5, 0, -5),
			["Size"] = udim2_new(0, 170, 0, 10),
			["Color"] = menu["colors"]["border"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = 500,
			["Visible"] = false,
		})
		menu_references["settings_section"]["inside"] = drawing_proxy["new"]("Image", {
			["Parent"] = menu_references["settings_section"]["border"],
			["Position"] = udim2_new(0, 1, 0, 1),
			["Size"] = udim2_new(1, -2, 1, -2),
			["Color"] = menu["colors"]["background"],
			["Transparency"] = 1,
			["Rounding"] = 4,
			["Data"] = pixel_image_data,
			["ZIndex"] = 501,
			["Visible"] = true,
		})
		menu_references["settings_section"]["holder"] = drawing_proxy["new"]("Square", {
			["Parent"] = menu_references["settings_section"]["inside"],
			["Position"] = udim2_new(0, 10, 0, 10),
			["Size"] = udim2_new(1, -20, 1, -20),
			["Transparency"] = 0,
			["Filled"] = true,
			["ZIndex"] = 502,
			["Visible"] = true,
		})

		menu["settings"][{ ["name"] = "settings" }] = menu_references["settings_section"]

		-- >> ( settings )

		do
			menu_references["settings_section"]["menu_keybind"] = menu_references["settings_section"]:create_element({
				["name"] = "toggle bind",
			}, {
				["keybind"] = {
					["flag"] = "menu_key",
				},
			})

			menu_references["settings_section"]["menu_keybind"]:set_key(Enum["KeyCode"]["Delete"])
			create_connection(menu_references["settings_section"]["menu_keybind"]["on_key_change"], function(key)
				keybind_data[1]["key"] = key
			end)

			create_connection(
				menu_references["settings_section"]:create_element({
					["name"] = "keybinds list",
				}, {
					["toggle"] = {
						["default"] = false,
						["flag"] = "keybind_list",
					},
				})["on_toggle_change"],
				function(bool)
					if bool then
						menu:show_keybinds()
					else
						menu:hide_keybinds()
					end
				end
			)

			menu_references["notifications"] = menu_references["settings_section"]:create_element({
				["name"] = "notifications",
			}, {
				["toggle"] = {
					["default"] = do_notifications,
					["flag"] = "!notifications",
				},
			})

			menu_references["hide_on_load"] = menu_references["settings_section"]:create_element({
				["name"] = "hide on load",
			}, {
				["toggle"] = {
					["default"] = false,
					["flag"] = "!hide_on_load",
				},
			})

			create_connection(menu_references["notifications"]["on_toggle_change"], function(bool)
				do_notifications = bool
				menu["saved"] = true
			end)

			create_connection(menu_references["hide_on_load"]["on_toggle_change"], function(bool)
				menu["hide_on_load"] = bool
				menu["saved"] = true
			end)

			menu_references["settings_section"]:create_element({
				["name"] = "custom kick screen",
			}, {
				["toggle"] = {
					["default"] = false,
					["flag"] = "custom_kick_screen",
				},
				["textbox"] = {
					["flag"] = "custom_kick_screen_background",
					["default"] = "2.png",
				},
				["colorpicker"] = {
					["color_flag"] = "custom_kick_screen_color",
					["transparency_flag"] = "custom_kick_screen_color_transparency",
					["default_color"] = menu["colors"]["accent"],
					["default_transparency"] = 0,
				},
			})

			create_connection(
				menu_references["settings_section"]:create_element({
					["name"] = "unload juju",
				}, {
					["button"] = {
						["confirmation"] = true,
					},
				})["on_clicked"],
				function()
					getgenv()["_JUJU"]()

					if identifyexecutor() == "AWP" then
						cleardrawcache()
					end
				end
			)
		end

		-- >> ( fake theme )

		do
			theme_section = setmetatable({
				["total_y_size"] = 10,
				["elements"] = {},
			}, section)

			theme_section["border"] = drawing_proxy["new"]("Image", {
				["Parent"] = themes_image,
				["Position"] = udim2_new(1, 5, 0, -5),
				["Size"] = udim2_new(0, 170, 0, 10),
				["Color"] = menu["colors"]["border"],
				["Transparency"] = 1,
				["Rounding"] = 4,
				["Data"] = pixel_image_data,
				["ZIndex"] = 500,
				["Visible"] = false,
			})
			theme_section["inside"] = drawing_proxy["new"]("Image", {
				["Parent"] = theme_section["border"],
				["Position"] = udim2_new(0, 1, 0, 1),
				["Size"] = udim2_new(1, -2, 1, -2),
				["Color"] = menu["colors"]["background"],
				["Transparency"] = 1,
				["Rounding"] = 4,
				["Data"] = pixel_image_data,
				["ZIndex"] = 501,
				["Visible"] = true,
			})
			theme_section["holder"] = drawing_proxy["new"]("Square", {
				["Parent"] = theme_section["inside"],
				["Position"] = udim2_new(0, 10, 0, 10),
				["Size"] = udim2_new(1, -20, 1, -20),
				["Transparency"] = 0,
				["Filled"] = true,
				["ZIndex"] = 502,
				["Visible"] = true,
			})

			menu["settings"][{ ["name"] = "theming" }] = theme_section

			build_visuals_menu()

			-- >> ( settings )

			create_connection(
				theme_section:create_element({
					["name"] = "juju color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["juju"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!juju_transparency",
						["color_flag"] = "!juju_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["juju"] = color
					juju_text["Color"] = color
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "logo color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["logo"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!logo_transparency",
						["color_flag"] = "!logo_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["logo"] = color
					logo["Color"] = color
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "error color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["error"],
						["default_transparency"] = 0,
						["transparency_flag"] = "e!rror_transparency",
						["color_flag"] = "!error_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["error"] = color
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "build color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["build"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!build_transparency",
						["color_flag"] = "!build_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["build"] = color
					build_text["Color"] = color
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "image color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["image"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!image_transparency",
						["color_flag"] = "!image_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["image"] = color
					themes_image["Color"] = color
					settings_image["Color"] = color
					search_image["Color"] = color
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "border color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["border"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!border_transparency",
						["color_flag"] = "!border_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["border"] = color
					context_border["Color"] = color
					dropdown_border["Color"] = color
					list_frame["Color"] = color
					search_out_border["Color"] = color
					for _, drawings in list_drawings do
						drawings["inside"]["Color"] = color
					end

					for _, settings in menu["settings"] do
						settings["border"]["Color"] = color
					end

					for name, group in menu["groups"] do
						for name, tab in group["tabs"] do
							for _, section in tab["sections"] do
								local search_border = section["search_border"]
								if search_border then
									search_border["Color"] = color
								end
								section["border"]["Color"] = color
								for _, element in section["elements"] do
									local drawings = element["drawings"]
									local toggle_border = drawings["toggle_border"]
									local dropdown_border = drawings["dropdown_border"]
									local slider_border = drawings["slider_border"]
									local colorpicker_border = drawings["colorpicker_border"]
									local keybind_border = drawings["keybind_border"]
									local button_border = drawings["button_border"]
									local textbox_border = drawings["textbox_border"]
									local border = drawings["border"]

									if toggle_border then
										toggle_border["Color"] = color
									end

									if dropdown_border then
										dropdown_border["Color"] = color
									end

									if slider_border then
										slider_border["Color"] = color
									end

									if colorpicker_border then
										colorpicker_border["Color"] = color
									end

									if keybind_border then
										keybind_border["Color"] = color
									end

									if button_border then
										button_border["Color"] = color
									end

									if border and section["selected"] ~= element then
										border["Color"] = color
									end

									if textbox_border then
										textbox_border["Color"] = color
									end
								end
							end
						end
					end

					for _, settings in menu["settings"] do
						for _, element in settings["elements"] do
							local drawings = element["drawings"]
							local toggle_border = drawings["toggle_border"]
							local dropdown_border = drawings["dropdown_border"]
							local slider_border = drawings["slider_border"]
							local colorpicker_border = drawings["colorpicker_border"]
							local keybind_border = drawings["keybind_border"]
							local button_border = drawings["button_border"]
							local textbox_border = drawings["textbox_border"]

							if toggle_border then
								toggle_border["Color"] = color
							end

							if dropdown_border then
								dropdown_border["Color"] = color
							end

							if slider_border then
								slider_border["Color"] = color
							end

							if colorpicker_border then
								colorpicker_border["Color"] = color
							end

							if keybind_border then
								keybind_border["Color"] = color
							end

							if button_border then
								button_border["Color"] = color
							end

							if textbox_border then
								textbox_border["Color"] = color
							end
						end
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "alert color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["alert"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!alert_transparency",
						["color_flag"] = "!alert_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["alert"] = color
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "cursor color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["cursor"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!cursor_transparency",
						["color_flag"] = "!cursor_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["cursor"] = color
					cursor["Color"] = color
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "accent color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["accent"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!accent_transparency",
						["color_flag"] = "!accent_color",
					},
				})["on_color_change"],
				function(color)
					menu.set_accent_color(color)
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "shadow color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["shadow"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!shadow_transparency",
						["color_flag"] = "!shadow_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["shadow"] = color

					list_shadow["Color"] = color

					for _, drawing in list_drawings do
						drawing["shadow"]["Color"] = color
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "success color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["success"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!success_transparency",
						["color_flag"] = "!success_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["success"] = color
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "dark text color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["dark_text"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!dark_text_transparency",
						["color_flag"] = "!dark_text_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["dark_text"] = color

					for name, group in menu["groups"] do
						for name, tab in group["tabs"] do
							for _, section in tab["sections"] do
								for _, element in section["elements"] do
									local drawings = element["drawings"]
									local text = drawings["dropdown_text"]
									local dropdown_arrow = drawings["dropdown_arrow"]
									local button_text = drawings["button_text"]
									local button_icon = drawings["button_icon"]
									local textbox_text = drawings["textbox_text"]
									local keybind_text = drawings["keybind_text"]
									local slider_text = drawings["slider_text"]

									local text2 = drawings["text2"]

									if text then
										text["Color"] = color
									end

									if text2 then
										text2["Color"] = color
									end

									if button_text then
										button_text["Color"] = color
									end

									if textbox_text then
										textbox_text["Color"] = color
									end

									if button_icon then
										button_icon["Color"] = color
									end

									if keybind_text then
										keybind_text["Color"] = color
									end

									if dropdown_arrow then
										dropdown_arrow["Color"] = color
									end

									if slider_text then
										slider_text["Color"] = color
									end
								end
							end
						end
					end

					for _, settings in menu["settings"] do
						for _, element in settings["elements"] do
							local drawings = element["drawings"]
							local text = drawings["dropdown_text"]
							local dropdown_arrow = drawings["dropdown_arrow"]
							local slider_text = drawings["slider_text"]
							local text2 = drawings["text2"]
							local button_text = drawings["button_text"]
							local button_icon = drawings["button_icon"]
							local textbox_text = drawings["textbox_text"]
							local keybind_text = drawings["keybind_text"]

							if text then
								text["Color"] = color
							end

							if textbox_text then
								textbox_text["Color"] = color
							end

							if dropdown_arrow then
								dropdown_arrow["Color"] = color
							end

							if keybind_text then
								keybind_text["Color"] = color
							end

							if text2 then
								text2["Color"] = color
							end

							if button_text then
								button_text["Color"] = color
							end

							if button_icon then
								button_icon["Color"] = color
							end

							if slider_text then
								slider_text["Color"] = color
							end
						end
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "section color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["section"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!section_transparency",
						["color_flag"] = "!section_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["section"] = color
					inside["Color"] = color

					for name, group in menu["groups"] do
						for name, tab in group["tabs"] do
							for _, section in tab["sections"] do
								section["inside"]["Color"] = color
							end
						end
					end

					for _, settings in menu["settings"] do
						settings["inside"]["Color"] = color
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "active text color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["active_text"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!active_text_transparency",
						["color_flag"] = "!active_text_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["active_text"] = color
					search_text["Color"] = color
					list_text["Color"] = color
					actives["tab"]["text"]["Color"] = color

					for name, group in menu["groups"] do
						for name, tab in group["tabs"] do
							if actives["tab"] == tab then
								tab["text"]["Color"] = color
							end
							for _, section in tab["sections"] do
								for _, element in section["elements"] do
									local toggle_flag = element["toggle_flag"]

									if toggle_flag then
										if flags[toggle_flag] then
											element["drawings"]["text"]["Color"] = color
										end
									end
								end
							end
						end
					end

					for _, settings in menu["settings"] do
						for _, element in settings["elements"] do
							local toggle_flag = element["toggle_flag"]

							if toggle_flag then
								if flags[toggle_flag] then
									element["drawings"]["text"]["Color"] = color
								end
							end
						end
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "inactive text color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["inactive_text"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!inactive_text_transparency",
						["color_flag"] = "!inactive_text_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["inactive_text"] = color
					type_line["Color"] = color

					for name, group in menu["groups"] do
						for name, tab in group["tabs"] do
							if actives["tab"] ~= tab then
								tab["text"]["Color"] = color
							end
							for _, section in tab["sections"] do
								local search_image = section["search_image"]

								if search_image then
									search_image["Color"] = color
								end
								for _, element in section["elements"] do
									local drawings = element["drawings"]
									local cog_icon = drawings["cog_icon"]

									local toggle_flag = element["toggle_flag"]

									if not toggle_flag or not flags[toggle_flag] then
										element["drawings"]["text"]["Color"] = color
									end

									if cog_icon then
										cog_icon["Color"] = color
									end
								end
							end
						end
					end

					for _, settings in menu["settings"] do
						for _, element in settings["elements"] do
							local drawings = element["drawings"]
							local dropdown_arrow = drawings["dropdown_arrow"]

							if dropdown_arrow then
								dropdown_arrow["Color"] = color
							end

							local toggle_flag = element["toggle_flag"]

							if not toggle_flag or not flags[toggle_flag] then
								element["drawings"]["text"]["Color"] = color
							end
						end
					end

					for i = 1, #context_buttons do
						context_buttons[i]["text"]["Color"] = color
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "keybind text color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["keybind_text"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!keybind_text_transparency",
						["color_flag"] = "!keybind_text_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["keybind_text"] = color
					for _, drawings in list_drawings do
						drawings["text"]["Color"] = color
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "background color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["background"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!background_transparency",
						["color_flag"] = "!background_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["background"] = color
					context_inside["Color"] = color
					right_side["Color"] = color
					right_side_cover["Color"] = color
					right_side_divider["Color"] = color
					search_inside["Color"] = color
					search_out["Color"] = color
					keybind_inside["Color"] = color
					search_inside["Color"] = color
					colorpicker_inside["Color"] = color
					right_side["Color"] = color
					right_side_cover["Color"] = color
					right_side_divider["Color"] = color
					search_inside["Color"] = color
					search_out["Color"] = color
					dropdown_inside["Color"] = color
					context_inside["Color"] = color
					keybind_inside["Color"] = color
					search_inside["Color"] = color
					list_inside["Color"] = color
					search_out["Color"] = color
					drag_frame["Color"] = color

					for _, drawings in list_drawings do
						drawings["inside"]["Color"] = color
					end

					for _, button in context_buttons do
						button["frame"]["Color"] = color
					end

					for name, group in menu["groups"] do
						for name, tab in group["tabs"] do
							for _, section in tab["sections"] do
								local search_inside = section["search_inside"]
								if search_inside then
									search_inside["Color"] = color
								end
								for _, element in section["elements"] do
									local drawings = element["drawings"]
									local toggle_inside = drawings["toggle_inside"]
									local dropdown_inside = drawings["dropdown_inside"]
									local slider_inside = drawings["slider_inside"]
									local colorpicker_inside = drawings["colorpicker_inside"]
									local keybind_inside = drawings["keybind_inside"]
									local button_inside = drawings["button_inside"]
									local textbox_inside = drawings["textbox_inside"]
									local inside = drawings["inside"]

									if toggle_inside then
										toggle_inside["Color"] = color
									end

									if dropdown_inside then
										dropdown_inside["Color"] = color
									end

									if slider_inside then
										slider_inside["Color"] = color
									end

									if colorpicker_inside then
										colorpicker_inside["Color"] = color
									end

									if keybind_inside then
										keybind_inside["Color"] = color
									end

									if button_inside then
										button_inside["Color"] = color
									end

									if textbox_inside then
										textbox_inside["Color"] = color
									end

									if inside then
										inside["Color"] = color
									end
								end
							end
						end
					end

					for _, settings in menu["settings"] do
						for _, element in settings["elements"] do
							local drawings = element["drawings"]
							local toggle_inside = drawings["toggle_inside"]
							local dropdown_inside = drawings["dropdown_inside"]
							local slider_inside = drawings["slider_inside"]
							local colorpicker_inside = drawings["colorpicker_inside"]
							local keybind_inside = drawings["keybind_inside"]
							local button_inside = drawings["button_inside"]
							local textbox_inside = drawings["textbox_inside"]
							local inside = drawings["inside"]

							if toggle_inside then
								toggle_inside["Color"] = color
							end

							if dropdown_inside then
								dropdown_inside["Color"] = color
							end

							if slider_inside then
								slider_inside["Color"] = color
							end

							if colorpicker_inside then
								colorpicker_inside["Color"] = color
							end

							if keybind_inside then
								keybind_inside["Color"] = color
							end

							if button_inside then
								button_inside["Color"] = color
							end

							if textbox_inside then
								textbox_inside["Color"] = color
							end

							if inside then
								inside["Color"] = color
							end
						end
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "active border color",
				}, {
					["colorpicker"] = {
						["default_color"] = menu["colors"]["highlighted"],
						["default_transparency"] = 0,
						["transparency_flag"] = "!active_border_transparency",
						["color_flag"] = "!active_border_color",
					},
				})["on_color_change"],
				function(color)
					menu["colors"]["highlighted"] = color
				end
			)

			theme_section:create_element({
				["name"] = "themes",
				["section"] = 2,
			}, {
				["dropdown"] = {
					["options"] = menu["get_theme_list"](),
					["flag"] = "!themes",
					["default"] = menu["theme"] and { menu["theme"] } or nil,
				},
			})

			create_connection(
				theme_section:create_element({
					["name"] = "refresh themes",
					["section"] = 2,
				}, {
					["button"] = {
						["fake"] = true,
					},
				})["on_clicked"],
				function()
					local elements = theme_section["elements"]

					for i = 1, #elements do
						local element = elements[i]
						if element["dropdown_flag"] then
							element:set_options(menu["get_theme_list"]())
							break
						end
					end
				end
			)

			create_connection(
				theme_section:create_element({
					["name"] = "load theme",
					["section"] = 2,
				}, {
					["button"] = {
						["fake"] = true,
					},
				})["on_clicked"],
				function()
					menu:load_theme(flags["!themes"][1])
				end
			)

			theme_section:create_element({
				["name"] = "name",
				["section"] = 2,
			}, {
				["textbox"] = {
					["flag"] = "!name",
				},
			})

			create_connection(
				theme_section:create_element({
					["name"] = "save theme",
					["section"] = 2,
				}, {
					["button"] = {},
				})["on_clicked"],
				function()
					local file = file_path .. "/themes/" .. flags["!name"] .. ".th"
					local data = {}

					local elements = theme_section["elements"]

					for i = 1, #elements do
						local element = elements[i]
						local flag = element["color_flag"]
						if flag then
							local color = flags[flag]
							data[flag] = { floor(color["R"] * 255), floor(color["G"] * 255), floor(color["B"] * 255) }
						end
					end

					writefile(file, http_service:JSONEncode(data))

					menu["new_notification"]("successfully saved theme " .. flags["!name"], 1)

					local elements = theme_section["elements"]

					for i = 1, #elements do
						local element = elements[i]
						if element["dropdown_flag"] then
							element:set_options(menu["get_theme_list"]())
							break
						end
					end
				end
			)

			create_click_connection(frame, themes_image, function()
				if actives["settings"] == theme_section then
					close_settings(theme_section)
				else
					open_settings(theme_section)
				end
			end)

			create_hover_connection(frame, themes_image, function()
				tween(themes_image, { Color = menu["colors"]["highlighted"] }, circular, out, 0.15)
			end, function()
				tween(themes_image, { Color = menu["colors"]["image"] }, circular, out, 0.15)
			end)
		end

		-- >> ( buttons )

		create_click_connection(frame, settings_image, function()
			if actives["settings"] == theme_section then
				close_settings(menu_references["settings_section"])
			else
				open_settings(menu_references["settings_section"])
			end
		end)

		create_hover_connection(frame, settings_image, function()
			tween(settings_image, { Color = menu["colors"]["highlighted"] }, circular, out, 0.15)
		end, function()
			tween(settings_image, { Color = menu["colors"]["image"] }, circular, out, 0.15)
		end)

		create_hover_connection(frame, search_image, function()
			if not searching then
				tween(search_image, { Color = menu["colors"]["highlighted"] }, circular, out, 0.15)
			end
		end, function()
			if not searching then
				tween(search_image, { Color = menu["colors"]["image"] }, circular, out, 0.15)
			end
		end)

		create_click_connection(frame, search_image, start_search)

		-- >> ( configs )

		function menu:setup_configs(section_name)
			local config_list, config_info, config_editor = nil, nil, nil
			if type(section_name) == "string" then
				local config_tab = menu.create_group(section_name)
				config_tab:create_tab("configs")
				config_list =
					menu["groups"][section_name]:create_panel_section("configs", "config list", 1, false, true)
				config_info = menu["groups"][section_name]:create_section("configs", "config info", 2, 0.3, 0)
				config_editor = menu["groups"][section_name]:create_section("configs", "config editor", 2, 0.7, 0.3)
			else
				section_name:create_tab("configs")
				config_list = section_name:create_panel_section("configs", "config list", 1, false, true)
				config_info = section_name:create_section("configs", "config info", 2, 0.3, 0)
				config_editor = section_name:create_section("configs", "config editor", 2, 0.7, 0.3)
			end

			menu_references["config_list"] = config_list

			local config_author = config_info:create_element({
				["name"] = "creator: ",
			}, {
				["info"] = {},
			})

			local config_last_updated = config_info:create_element({
				["name"] = "last updated: ",
			}, {
				["info"] = {},
			})

			local config_name = config_editor:create_element({
				["name"] = "config name",
			}, {
				["textbox"] = {
					["flag"] = "!config_name",
				},
			})

			local create_config = config_editor:create_element({
				["name"] = "create config",
			}, {
				["button"] = {
					["fake"] = true,
				},
			})

			local delete_config = config_editor:create_element({
				["name"] = "delete config",
			}, {
				["button"] = {
					["confirmation"] = true,
					["fake"] = true,
				},
			})

			local update_config = config_editor:create_element({
				["name"] = "update config",
			}, {
				["button"] = {
					["confirmation"] = true,
					["fake"] = true,
				},
			})

			local load_config = config_editor:create_element({
				["name"] = "load config",
			}, {
				["button"] = {
					["confirmation"] = true,
					["fake"] = true,
				},
			})

			local refresh_config_list = config_editor:create_element({
				["name"] = "refresh config list",
			}, {
				["button"] = {
					["fake"] = true,
				},
			})

			create_connection(config_list["on_selection_change"], function(config)
				local config = config or "AbbbbAzbbbbA12z"
				local path = file_path .. "/configs/" .. config .. ".cfg"
				local data = nil
				if isfile(path) then
					data = menu["get_config_data"](readfile(path))
				end
				if not data then
					config_name:set_visible(true)
					create_config:set_visible(true)
					load_config:set_visible(false)
					update_config:set_visible(false)
					delete_config:set_visible(false)
					config_author:set_visible(false)

					config_last_updated:set_visible(false)
					refresh_config_list:set_visible(true)
				else
					config_name:set_visible(false)
					create_config:set_visible(false)
					load_config:set_visible(true)
					update_config:set_visible(true)
					delete_config:set_visible(true)
					refresh_config_list:set_visible(false)
					config_last_updated:set_visible(true)
					config_last_updated:set_info("Text", data["date"])

					local author = data["author"]
					local username = nil

					if author and tonumber(author) then
						local s, data = pcall(function()
							local body = request({
								["Url"] = "https://discord-lookup-api-pied.vercel.app/v1/user/" .. author,
								["Method"] = "GET",
								["Headers"] = {
									["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
									["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
									["Accept-Language"] = "en-US,en;q=0.9",
									["Connection"] = "keep-alive",
									["Referer"] = "https://www.google.com/",
									["DNT"] = "1",
									["Upgrade-Insecure-Requests"] = "1",
								},
							})

							if body and body["StatusCode"] == 200 then
								return http_service:JSONDecode(body["Body"])
							end
						end)
						username = (s and data) and "@" .. data["username"] or "failed to fetch"
						config_author:set_visible(true)
						config_author:set_info("Text", username)
					else
						config_author:set_visible(false)
						config_author:set_info("Text", "")
					end
				end
			end)

			create_connection(create_config["on_clicked"], function()
				local selected_config = flags["!config_name"]

				if selected_config and tostring(selected_config) and #selected_config > 0 then
					menu["save_config"](selected_config)

					config_list:add_item({
						["text"] = selected_config,
						["icons"] = {
							config_image_data,
						},
					})

					menu["new_notification"]("successfully created config " .. selected_config, 1)
				end
			end)

			create_connection(refresh_config_list["on_clicked"], function()
				local elements = config_list["elements"]
				for _, element in elements do
					config_list:remove_item(element["name"], true)
					elements[_] = nil
				end

				local configs = menu["get_config_list"]()
				local current_autoload = menu["autoload"]

				for i = 1, #configs do
					local config = configs[i]
					config_list:add_item({
						["text"] = config,
						["icons"] = current_autoload == config and {
							autoload,
							config_image_data,
						} or {
							config_image_data,
						},
					})
				end
			end)

			create_connection(delete_config["on_clicked"], function()
				local selected_config = config_list["selected"]["name"]

				if selected_config and tostring(selected_config) and #selected_config > 0 then
					config_list:remove_item(selected_config)
					delfile(file_path .. "/configs/" .. selected_config .. ".cfg")
					menu["new_notification"]("successfully deleted config " .. selected_config, 1)
				end
			end)

			create_connection(update_config["on_clicked"], function()
				local selected_config = config_list["selected"]["name"]

				if selected_config and tostring(selected_config) and #selected_config > 0 then
					menu["save_config"](selected_config)
					menu["new_notification"]("successfully updated config " .. selected_config, 1)
				end
			end)

			create_connection(load_config["on_clicked"], function()
				local selected_config = config_list["selected"]["name"]

				if selected_config and tostring(selected_config) and #selected_config > 0 then
					menu["load_config"](selected_config)
					menu["new_notification"]("successfully loaded config " .. selected_config, 1)
				end
			end)

			for _, config in menu.get_config_list() do
				config_list:add_item({
					["text"] = config,
					["icons"] = menu["autoload"] == config and {
						autoload,
						config_image_data,
					} or {
						config_image_data,
					},
				})
			end

			config_author:set_visible(false)
			update_config:set_visible(false)
			config_last_updated:set_visible(false)
			delete_config:set_visible(false)
			load_config:set_visible(false)
		end
	end

		menu:setup_configs("configs")

	-- > ( loading / unloading )

	do
		menu_references["previous_unload"] = getgenv()["_JUJU"]

		if menu_references["previous_unload"] then
			menu_references["previous_unload"]()
		end

		menu_references["runtime_env"] = getgenv()
		menu_references["old_drawing"] = menu_references["runtime_env"]["fake_drawing"]

		menu_references["metatables"] = {}

		menu_references["original_getrawmetatable"] = getrawmetatable
		menu_references["runtime_env"]["_OG"] = menu_references["original_getrawmetatable"]
		menu_references["runtime_env"]["getrawmetatable"] = newcclosure(function(instance)
			local mt = menu_references["original_getrawmetatable"](instance)
			menu_references["metatables"][instance] = mt

			return mt
		end)

		getrawmetatable = menu_references["runtime_env"]["getrawmetatable"]

		menu_references["runtime_env"]["_JUJU"] = function()
			menu_references["runtime_env"]["_JUJU"] = nil

			for _, group in menu["groups"] do
				for _, tab in group["tabs"] do
					for _, section in tab["sections"] do
						local elements = section["elements"]
						for i = 1, #elements do
							local element = elements[i]

							if element["toggle_flag"] then
								element:set_toggle(false)
							end
						end
					end
				end
			end

			for _, settings in menu["settings"] do
				local elements = settings["elements"]
				for i = 1, #elements do
					local element = elements[i]

					if element["toggle_flag"] then
						element:set_toggle(false)
					end
				end
			end

			restore_frozen_zombies()

			for player in pairs(player_esp_state.objects) do
				remove_player_esp(player)
			end

			for i = 1, #connections do
				connections[i]:Disconnect()
			end

			context_action_service:UnbindAction(context_action_click)
			context_action_service:UnbindAction(context_action_typing)
			context_action_service:UnbindCoreAction(context_action_typing_core)
			context_action_service:UnbindAction(context_action_scroll)

			menu_references["runtime_env"]["getrawmetatable"] = menu_references["original_getrawmetatable"]

			for instance, mt in menu_references["metatables"] do
				setrawmetatable(instance, mt)
			end

			menu_references["old_drawing"]["_UNLOAD"]()
		end

		-- >> ( render / tween loop )

		create_connection(
			run_service["Heartbeat"],
			LPH_NO_VIRTUALIZE(function(dt)
				for i = 1, #heartbeat do
					spawn(heartbeat[i], dt)
				end
			end)
		)

		-- >> ( data )

		menu_references["startup_data"] = { pcall(function()
			return http_service:JSONDecode(readfile(file_path .. "/data.dat"))
		end) }

		if menu_references["startup_data"][1] and menu_references["startup_data"][2] then
			menu["hide_on_load"] = menu_references["startup_data"][2]["hide_on_load"]

			pop_menu(true)

			if not menu_references["startup_data"][2]["hide_on_load"] then
				pop_menu()
			end

			menu["theme"] = menu_references["startup_data"][2]["theme"] or ""
			menu["favorites"] = menu_references["startup_data"][2]["favorites"] or {}
			menu["autoload"] = menu_references["startup_data"][2]["autoload"] or nil
			do_notifications = menu_references["startup_data"][2]["notifications"]
				or menu_references["startup_data"][2]["notifications"] == nil
				or false
			menu_references["notifications"]:set_toggle(do_notifications)
			menu_references["hide_on_load"]:set_toggle(menu_references["startup_data"][2]["hide_on_load"])

			if menu_references["startup_data"][2]["theme"] then
				menu:load_theme(menu_references["startup_data"][2]["theme"])
			end

			if menu_references["startup_data"][2]["autoload"] then
				menu_references["config_list"]:add_icon(menu_references["startup_data"][2]["autoload"], autoload)
			end
		else
			writefile(
				file_path .. "/data.dat",
				http_service:JSONEncode({
					["notifications"] = do_notifications,
					["favorites"] = {},
					["hide_on_load"] = false,
					["theme"] = "",
				})
			)
		end
	end
end)()


-- ============================================================

-- ============================================================
-- JUJU MENU → ORIGIN ENGINE (full wire)
-- ============================================================
local function juju_sync_origin()
	if type(AR2_CFG) ~= "table" then return end
	-- juju Drawing ESP owns visuals
	AR2_CFG.players.on = false
	AR2_CFG.zombies.on = false
	AR2_CFG.loot.on = false
	AR2_CFG.vehicles.on = false
	AR2_CFG.corpses.on = false

	-- magic / silent aim
	AR2_CFG.magicAim.on = flags["combat_saim"] == true
	AR2_CFG.magicAim.fov = tonumber(flags["combat_saim_fov"]) or AR2_CFG.magicAim.fov or 250
	-- juju draws FOV; never let Origin draw a second circle
	AR2_CFG.magicAim.showFov = false
	AR2_CFG.magicAim.showLockLine = false
	AR2_CFG.aim.showFov = false
	AR2_CFG.magicAim.players = flags["combat_saim_players"] == true
	AR2_CFG.magicAim.zombies = flags["combat_saim_zombies"] == true
	AR2_CFG.magicAim.visCheck = flags["combat_saim_visible_only"] == true or flags["combat_saim_wallcheck"] == true
	AR2_CFG.magicAim.maxDist = tonumber(flags["combat_saim_max_distance"]) or 1200
	AR2_CFG.magicAim.maxBend = tonumber(flags["weapon_magic_max_bend"]) or 45
	AR2_CFG.magicAim.killSpread = flags["weapon_no_spread"] == true
	AR2_CFG.magicAim.originShift = true
	AR2_CFG.magicAim.part = (flags["combat_saim_hitpart"] and flags["combat_saim_hitpart"][1]) or "Head"

	-- camera aimbot
	AR2_CFG.aim.on = flags["combat_aimbot"] == true
	AR2_CFG.aim.fov = tonumber(flags["combat_aimbot_fov"]) or 180
	AR2_CFG.aim.showFov = flags["combat_aimbot_show_fov"] == true
	AR2_CFG.aim.players = flags["combat_aimbot_players"] == true
	AR2_CFG.aim.zombies = flags["combat_aimbot_zombies"] == true
	AR2_CFG.aim.wallCheck = flags["combat_aimbot_wallcheck"] == true
	AR2_CFG.aim.smooth = tonumber(flags["combat_aimbot_smooth"]) or 18
	AR2_CFG.aim.maxDist = tonumber(flags["combat_aimbot_max_distance"]) or 1500
	AR2_CFG.aim.part = (flags["combat_aimbot_hitpart"] and flags["combat_aimbot_hitpart"][1]) or "HeadCollider"

	-- gun mods
	AR2_CFG.weapon.noRecoil = flags["weapon_no_recoil"] == true
	AR2_CFG.weapon.noSpread = flags["weapon_no_spread"] == true
	AR2_CFG.weapon.wallbang = flags["weapon_wallbang"] == true
	AR2_CFG.weapon.hbeOn = false
	AR2_CFG.weapon.hbeSize = math.clamp(tonumber(flags["weapon_hbe_size"]) or 3, 1, 5)
	AR2_CFG.weapon.vehicleEquip = flags["weapon_vehicle_equip"] == true
	AR2_CFG.weapon.instantReload = flags["weapon_instant_reload"] == true
	AR2_CFG.weapon.allFireModes = flags["weapon_all_fire_modes"] == true
	AR2_CFG.weapon.autoReload = flags["weapon_auto_reload"] == true
	AR2_CFG.weapon.alwaysSuppressed = flags["weapon_suppressed"] == true

	-- player movement
	AR2_CFG.misc.fly = false
	AR2_CFG.misc.flySpeedPct = math.clamp((tonumber(flags["misc_fly_value"]) or 16) * 12, 10, 1000)
	AR2_CFG.misc.noclip = flags["misc_noclip"] == true
	AR2_CFG.misc.bhop = false
	AR2_CFG.misc.bhopHeight = 15
	AR2_CFG.misc.spinOn = false
	AR2_CFG.misc.spinSpeed = 20
	AR2_CFG.misc.spinTilt = false
	AR2_CFG.misc.antiFallStun = flags["misc_anti_fall"] == true
	AR2_CFG.misc.infJump = flags["misc_inf_jump"] == true
	AR2_CFG.misc.fovZoom = false
	AR2_CFG.misc.zoomFOV = tonumber(flags["misc_zoom_fov"]) or 30
	AR2_CFG.misc.tracers = flags["misc_bullet_tracers"] == true
	AR2_CFG.misc.freeze = flags["misc_zombie_freeze"] == true
	AR2_CFG.misc.carNoclip = flags["misc_car_noclip"] == true
	AR2_CFG.misc.morphHideSelf = flags["misc_morph_hide"] == true
	if flags["misc_morph_preset"] and flags["misc_morph_preset"][1] then
		local preset = flags["misc_morph_preset"][1]
		AR2_CFG.misc.morphPreset = preset
		if preset == "Verity" then AR2_CFG.misc.morphId = "140105640267431"
		elseif preset == "Tung Tung Tung" then AR2_CFG.misc.morphId = "138151705692565"
		elseif preset == "Gucci Morty" then AR2_CFG.misc.morphId = "82766930708256"
		end
	end

	-- vehicles
	AR2_CFG.car.fly = flags["misc_car_fly"] == true
	AR2_CFG.car.flySpeed = tonumber(flags["misc_car_fly_value"]) or 100
	AR2_CFG.car.god = false
	AR2_CFG.car.fuel = false
	AR2_CFG.car.boost = flags["misc_car_boost"] == true or flags["misc_carspeed"] == true
	AR2_CFG.car.speed = tonumber(flags["misc_car_boost_speed"]) or ((tonumber(flags["misc_carspeed_mult"]) or 1.5) * 80)
	AR2_CFG.car.torque = tonumber(flags["misc_car_torque"]) or 3
	AR2_CFG.car.maxTraction = flags["misc_car_max_traction"] == true or flags["misc_cargrip"] == true
	AR2_CFG.car.boatMode = false
	AR2_CFG.car.removeDrag = flags["misc_car_remove_drag"] == true
	AR2_CFG.car.fullSteer = flags["misc_car_full_steer"] == true or flags["misc_carsteer"] == true
	AR2_CFG.car.tpDash = false
	AR2_CFG.car.tpDashStuds = tonumber(flags["misc_car_tp_dash_studs"]) or 30

	-- world
	AR2_CFG.visuals.fullbright = flags["misc_fullbright"] == true
	AR2_CFG.visuals.nofog = flags["misc_no_fog"] == true
	AR2_CFG.visuals.setTime = flags["misc_world_time_enabled"] == true
	AR2_CFG.visuals.time = tonumber(flags["misc_world_time"]) or 12
end

local juju_origin_prev = {}
local function juju_apply_origin(force)
	if type(AR2_CFG) ~= "table" then return end
	juju_sync_origin()
	local snap = {
		fly = AR2_CFG.misc.fly,
		noclip = AR2_CFG.misc.noclip,
		bhop = AR2_CFG.misc.bhop,
		spin = AR2_CFG.misc.spinOn,
		afs = AR2_CFG.misc.antiFallStun,
		fovz = AR2_CFG.misc.fovZoom,
		hbe = AR2_CFG.weapon.hbeOn,
		wb = AR2_CFG.weapon.wallbang,
		ve = AR2_CFG.weapon.vehicleEquip,
		carfly = AR2_CFG.car.fly,
		boat = AR2_CFG.car.boatMode,
		drag = AR2_CFG.car.removeDrag,
		steer = AR2_CFG.car.fullSteer,
		tpd = AR2_CFG.car.tpDash,
		god = AR2_CFG.car.god,
		fuel = AR2_CFG.car.fuel,
		boost = AR2_CFG.car.boost,
		magic = AR2_CFG.magicAim.on,
		aim = AR2_CFG.aim.on,
		morph = flags["misc_morph"] == true,
		freeze = AR2_CFG.misc.freeze,
		fb = AR2_CFG.visuals.fullbright,
		fog = AR2_CFG.visuals.nofog,
		time = AR2_CFG.visuals.setTime,
	}
	local changed = force
	if not changed then
		for k, v in pairs(snap) do
			if juju_origin_prev[k] ~= v then changed = true break end
		end
	end
	-- always refresh continuous systems
	pcall(function()
		AR2_CFG.magicAim.showFov = false
		AR2_CFG.aim.showFov = false
		AR2_magicUpdate()
	end)
	pcall(function() AR2_visuals.apply() end)
	pcall(function() AR2_carMods.apply() end)
	if not changed and not force then
		juju_origin_prev = snap
		return
	end
	juju_origin_prev = snap

	-- removed fly/fov
	pcall(function()
		if AR2_CFG.misc.noclip then AR2_startNoclip() else AR2_stopNoclip() end
	end)
	-- removed
	-- removed
	pcall(function() AR2_setAntiFallStun(AR2_CFG.misc.antiFallStun) end)
	-- removed fly/fov
	-- removed
	pcall(function() AR2_setVehicleEquip(AR2_CFG.weapon.vehicleEquip) end)
	pcall(function()
		if AR2_CFG.weapon.wallbang then startWallbangTagging() else stopWallbangTagging() end
	end)
	pcall(function()
		if AR2_carFlySetEnabled then AR2_carFlySetEnabled(AR2_CFG.car.fly) end
	end)
	-- removed
	pcall(function() AR2_setRemoveDrag(AR2_CFG.car.removeDrag) end)
	pcall(function() AR2_setFullSteer(AR2_CFG.car.fullSteer) end)
	-- removed
	pcall(function()
		if AR2_CFG.aim.on then AR2_aim.start() else AR2_aim.stop() end
	end)
	pcall(function()
		if AR2_CFG.misc.freeze then AR2_freeze.start() else AR2_freeze.stop() end
	end)
	pcall(function()
		if flags["misc_morph"] then AR2_applyMorph() else AR2_removeMorph() end
	end)
	pcall(function()
		if AR2_CFG.misc.tracers then AR2_tracersUpdate() end
	end)
	pcall(function()
		if setInstantReloadEnabled then setInstantReloadEnabled(AR2_CFG.weapon.instantReload) end
	end)
	pcall(function()
		if AR2_applyAllFireModes then AR2_applyAllFireModes(AR2_CFG.weapon.allFireModes) end
	end)
	pcall(function()
		if AR2_setAlwaysSuppressed then AR2_setAlwaysSuppressed(AR2_CFG.weapon.alwaysSuppressed) end
	end)
end

-- drive Origin from menu flags
task.spawn(function()
	task.wait(1)
	juju_apply_origin(true)
	while true do
		task.wait(0.12)
		pcall(juju_apply_origin, false)
	end
end)

-- QoL: soft load banner
task.spawn(function()
	task.wait(2)
	pcall(function()
		if Library and Library.Notify then
			Library:Notify("juju loaded — right shift for menu", 4)
		end
	end)
end)

return {
	["menu"] = menu,
	["signal"] = signal,
	["tween"] = tween,
	["drawing_proxy"] = drawing_proxy,
	["drawing"] = drawing,
	["create_connection"] = create_connection,
	["create_instance"] = create_instance,
	["round"] = round,
	["remove"] = remove,
	["flags"] = flags,
	["connections"] = connections,
	["heartbeat"] = heartbeat,
	["addon_data"] = addon_data,
	["menu_references"] = menu_references,
}
