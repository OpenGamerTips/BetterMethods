# BetterMethods
Custom Lua metamethods for Roblox Exploits written in Lua 5.1 (Luau), mainly for hooks and bypasses.

# Needed Functions
The list of needed functions to run this script are as follows:
- getgenv
- getrawmetatable
- isreadonly
- setreadonly
- newcclosure
- getnamecallmethod

# Use
This is made to make Roblox exploiting easier and more comfortable for scripters.
Library includes methods for hooking events (Remote and Bindable) plus returns functions for adding your own methods.

# API
As of now, the API is as follows:
### workspace:GetCharacters(_void_)
Gets all the characters in workspace __including non-player characters.__
### Instance\[BindableEvent or BindableFunction]:BHook(_Function_ Callback)
Calls _Callback_ when the event is fired with two arguments (The calling script instance and the arguments). Example:
```lua
local Bindable = Some.Bindable.Event
Bindable:BHook(function(Script, Arguments)
    warn("Caller: "..Script.Name.."\nArguments:")
    table.foreach(Arguments, print)
    Arguments[1] = "hacked!"
    warn("Argument 1 was changed from '"..tostring(Arguments[1]).."' to 'hacked!'.")
    return Arguments -- You MUST return the arguments or a warn will be raised and your arguments will not be spoofed.
end)

Bindable:Fire("i will be changed.")
```

### Instance\[RemoteEvent or RemoteFunction]:RHook(_Function_ Callback)
Has the same syntax and expectance of _BHook_.
