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

