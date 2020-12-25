--/ Project: custometamethods.lua
--/ Author: H3x0R
--/ Notes: None!

getgenv().__metamethodcustomizerran = true
local CustomMethodTable, CustomMetaHooktable = {}, {}
local HookedREvents, HookedRFunctions = {}, {}
local HookedBEvents, HookedBFunctions = {}, {}

local GameMeta = getrawmetatable(game)
local GameMetaROState = isreadonly(GameMeta)
local __bindex, __bnamecall = GameMeta.__index, GameMeta.__namecall
if not __metamethodcustomizerran then
    if GameMetaROState == true then setreadonly(GameMeta, false) end
    GameMeta.__namecall = newcclosure(function(self, ...)
        local Args, Method, Caller = {...}, getnamecallmethod(), getfenv(2).script
        local CMethod = CustomMethodTable[Method]
        if CMethod then 
            return CMethod(self, Args)
        else
            -- Hooking
            if (self.ClassName == "RemoteEvent" or self.ClassName == "RemoteFunction") and (Method == "FireServer" or Method == "InvokeServer") then
                local H1, H2 = HookedREvents[self], HookedRFunctions[self]
                local Res;
                if H1 then
                    Res = H1(Caller, Args)
                elseif H2 then
                    Res = H2(Caller, Args)
                end

                if type(Res) ~= "table" then warn("Invalid return for remote hook. Reset call.") return __bnamecall(self, ...) end
                Args = Res
            elseif (self.ClassName == "BindableEvent" or self.ClassName == "BindableFunction") and (Method == "Fire" or Method == "Invoke") then
                local H1, H2 = HookedREvents[self], HookedRFunctions[self]
                local Res;
                if H1 then
                    Res = H1(Caller, Args)
                elseif H2 then
                    Res = H2(Caller, Args)
                end

                if type(Res) ~= "table" then warn("Invalid return for bindable hook. Reset call.") return __bnamecall(self, ...) end
                Args = Res
            end
        
            for _, Callback in pairs(CustomMetaHooktable) do
                Callback(self, Args)
            end

            return __bnamecall(self, unpack(Args))
        end
    end)
    setreadonly(GameMeta, GameMetaROState)
end

local SafeCall = newcclosure(function(Closure, ...)
    local Args = {pcall(Closure, ...)}
    if Args[1] ~= true then
        warn("ERROR: "..Args[2])
        return
    end

    local RetArgs = {}
    local Debounce = false
    for _, Value in pairs(Args) do
        if Debounce == true then
            RetArgs[#RetArgs + 1] = Value
        else
            Debounce = true
        end
    end

    return unpack(RetArgs)
end)

local AddMethod = newcclosure(function(CallName, CheckFunc, Callback) -- Arguments: [self, Args]
    CustomMethodTable[CallName] = function(self, Args)
        if CheckFunc(self, Args) == true then
            return SafeCall(Callback, self, Args)
        else
            warn("Check closure failed for method '"..CallName.."'")
        end
    end
    return true
end)

local AddMetaHook = newcclosure(function(Callback)
    CustomMetaHooktable[#CustomMetaHooktable + 1] = Callback
    return true
end)

AddMethod("GetCharacters", function(self) return (self == workspace) end, function(self, Args)
    local Characters = {}
    for Idx, Inst in ipairs(self:GetChildren()) do
        if Inst.ClassName == "Model" and Inst:FindFirstChildOfClass("Humanoid") and Inst:FindFirstChild("HumanoidRootPart") then -- If valid character (Doesn't have to be linked to a player)
            Characters[#Characters + 1] = Inst
        end
    end
    
    return Characters
end)

-- Remote Hooking
AddMethod("RHook", function(self) return (self.ClassName == "RemoteEvent" or self.ClassName == "RemoteFunction") end, function(self, Args)
    if #Args > 1 then error("Too much arguments.") end
    if #Args < 1 then error("Not enough arguments.") end

    local IsRemoteEvent = (self.ClassName == "RemoteEvent")
    local Callback = Args[1]
    if type(Callback) ~= "function" then
        error("Expected argument 1 for 'RHook' to be a function, not a "..typeof(Callback))
    end
    
    if IsRemoteEvent then
        HookedREvents[self] = Callback
    else
        HookedRFunctions[self] = Callback
    end
    return true
end)

-- Bindable Hooking
AddMethod("BHook", function(self) return (self.ClassName == "BindableEvent" or self.ClassName == "BindableFunction") end, function(self, Args)
    if #Args > 1 then error("Too much arguments.") end
    if #Args < 1 then error("Not enough arguments.") end

    local IsBindableEvent = (self.ClassName == "BindableEvent")
    local Callback = Args[1]
    if type(Callback) ~= "function" then
        error("Expected argument 1 for 'BHook' to be a function, not a "..typeof(Callback))
    end
    
    if IsBindableEvent then
        HookedBEvents[self] = Callback
    else
        HookedBFunctions[self] = Callback
    end
    return true
end)

return {
    AddMethod = AddMethod;
    AddMetaHook = AddMetaHook;
    SafeCall = SafeCall;
}
