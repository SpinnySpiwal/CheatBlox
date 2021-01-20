------//    CheatBlox v5     //--
-----// Made By Stefan#6965 //--


--// Preload //--

if not syn then error("CheatBlox: Missing Synapse X Library.") end
if not game then
    repeat wait() until game ~= nil
end
 
--// Compatibility (no this doesnt meant it'll work on protosmasher lol) //--

local CheatBlox = {}

getgenv().make_writeable = function(m)
    setreadonly(m,false)
end

getgenv().make_readonly = function(m)
    setreadonly(m,true)
end

getgenv().LP = game:GetService("Players").LocalPlayer

getgenv().checkclosure = is_synapse_function
 
getgenv().getcontext = syn.get_thread_identity
 
getgenv().setcontext = syn.set_thread_identity

getgenv().get_namecall_method = getnamecallmethod

getgenv().set_namecall_method = setnamecallmethod

getgenv().detour_function = hookfunction

getgenv().protect_function = newcclosure

--// CheatBlox //--

CheatBlox.GetStackFunction = function(self,STK)
    return debug.getinfo(STK).Func or debug.getinfo(STK).func
end

CheatBlox.ClickTextButton = function(self,button)
    if typeof(button) ~= "Instance" then
        error("CheatBlox: Instance expected, got "..typeof(button)..".")
    end
    if button.ClassName ~= "TextButton" then
        error("CheatBlox: TextButton expected, got "..button.ClassName..".")
    end
    for i,v in pairs(getconnections(button.MouseButton1Down)) do
        v.Function()
    end
    for i,v in pairs(getconnections(button.MouseButton1Up)) do
        v.Function()
    end
    for i,v in pairs(getconnections(button.MouseButton1Click)) do
        v.Function()
    end
end
 
CheatBlox.UnlockMetatableOf = function(self,mt)
    if type(mt) ~= "table" and type(mt) ~= "userdata" then
        error("CheatBlox: table or userdata expected, got "..typeof(mt)..".")
    end
    setreadonly(getrawmetatable(mt),false)
    getrawmetatable(mt)["__metatable"] = nil
end

CheatBlox.GetMaxStack = function()
    local STK = 0
    local str = debug.traceback()
    for i = 1,#str do
        if string.byte(str,i) == 10 then 
            STK = STK + 1
        end
    end
    return STK - 1
end
 
CheatBlox.GetLocalPlayer = function()
    return game:GetService("Players").LocalPlayer
end

CheatBlox.GetLocalCharacter = function()
    return game:GetService("Players").LocalPlayer.Character
end
 
CheatBlox.Info = function(self,str)
    game:GetService("TestService"):Message(str)
end

local Parse
local DumpFunction
local IsFunction

do
    function getGlobals(func) 
        return getrawmetatable(debug.getfenv(func)).__index
    end
    local EnvGlobals = getGlobals(1)
    function GetInstanceLocation(Instance)
        function GetInstances(Instance) 
            function GetParent(Child) 
                local Child = Child.Parent
                while Child == game do 
                    Child = Child.Parent
                end
                return Child
            end
            local Instances = {GetParent(Instance)}
            local CurrentChild = GetParent(Instance)
            local function CheckInstances(Child_2)
                for i, v in next, Child_2:GetChildren() do 
                    table.insert(Instances, v)
                    if v == Instance then 
                        break
                    else
                        CheckInstances(v)
                    end
                end
            end
            CheckInstances(CurrentChild)
            return Instances
        end
        local Instances = GetInstances(Instance)
        local Locations = {}
        for i, v in next, Instances do 
            if i == 1 then 
                table.insert(Locations, ("game:GetService(\"%s\")"):format(v.Name))
            else
                table.insert(Locations, v.Name)
            end
        end
        return table.concat(Locations, ".")
    end
    function count(Table) 
        local Elements = 0
        for i, v in next, Table do 
            Elements = Elements + 1
        end
        return Elements
    end
    function FilerTable(Table) 
        local NewTable = {}
        for i, v in next, Table do 
            if type(v) == "table" then 
                if v == Table then 
                    NewTable[i] = {}
                else
                    NewTable[i] = FilerTable(Table)
                end
            else
                NewTable[i] = v
            end
        end
        return NewTable
    end
    function Parse(Table) 
        whitespace = "    "
        ArrayStyle = "[%s]"
        amount = 1
        Close = "}"
        ValueClose = ""
        results = "{"
        function GenerateString(Value) 
            local UseString = true
            if type(Value) ~= "string" then 
                Value = ValueTypeLuaSec(Value)
            end
            local ListChange = {
                {from = "\\", to = "\\\\"},
                {from = "\"", to = "\\\""},
                {from = "\n", to = "\\n"},
                {from = "\a", to = "\\a"},
                {from = "\f", to = "\\f"},
                {from = "\b", to = "\\b"},
                {from = "\\J", to = "\\0"}
            }
            local FE = "\"%s\""
            local Val = {}
            for i, v in next, Value:split("") do 
                if v == "\0" then 
                    table.insert(Val, "")
                else
                    table.insert(Val, v)
                end
            end
            Value = table.concat(Val)
            for i, v in next, ListChange do 
                Value = Value:gsub(v.from, v.to)
            end
            return FE:format(Value)
        end
        function ValueTypeLuaSec(value, useString)
            local ok = ""
            if typeof(value) == "string" then 
                if useString then 
                    ok = GenerateString(value)
                else
                    ok = value
                end
            elseif typeof(value) == "function" then 
                ok = "function() end"
            elseif typeof(value) == "CFrame" then
                ok = GeneratePositionValue("CFrame", value)
            elseif typeof(value) == "Vector3" then
                ok = GeneratePositionValue("Vector3", value)
            elseif typeof(value) == "UDim2" then
                ok = GeneratePositionValue("UDim2", value)
            elseif typeof(value) == "Vector2" then
                ok = GeneratePositionValue("Vector2", value)
            elseif typeof(value) == "userdata" then
                ok = "userdata"
            elseif typeof(value) == "table" then
                ok = "table"
            else
                ok = tostring(value)
            end
            return ok
        end
        function GeneratePositionValue(name, value) 
            local Str = "%s.new(%s)"
            Str = Str:format(name, tostring(value))
            return Str
        end
        function ValueTypeLua(value)
            local ok = ""
            if typeof(value) == "string" then 
                ok = GenerateString(value)
            elseif typeof(value) == "function" then 
                ok = "function() end"
            elseif typeof(value) == "CFrame" then
                ok = GeneratePositionValue("CFrame", value)
            elseif typeof(value) == "Vector3" then
                ok = GeneratePositionValue("Vector3", value)
            elseif typeof(value) == "UDim2" then
                ok = GeneratePositionValue("UDim2", value)
            elseif typeof(value) == "Vector2" then
                ok = GeneratePositionValue("Vector2", value)
            elseif typeof(value) == "userdata" then
                ok = GenerateString("userdata")
            elseif typeof(value) == "table" then
                ok = GenerateString("table")
            else
                ok = tostring(value)
            end
            return ok..ValueClose
        end
        function shouldUseBrackets(Value) 
            local should = false
            if type(Value) ~= "string" then 
                Value = ValueTypeLuaSec(Value)
            end
            if #Value:split(" ") > 1 then 
                should = true
            end
            if Value:find("\\", 1, true) then 
                should = true
            end
            return should
        end
        function TableValueTemplete(index) 
            local okhand = ""
            if shouldUseBrackets(index) then 
                okhand = ArrayStyle:format(GenerateString(index)) .." = "
            elseif type(index) == "number" then 
                okhand = ArrayStyle:format(index) .." = "
            else
                okhand = ValueTypeLuaSec(index) .." = "
            end
            return okhand
        end
        function HasIndexNString(Val) 
            local indian = false
            local main = false
            local numberaaaa = false
            for i, v in next, Val do 
                if type(i) == "number" then 
                    indian = true
                end
                if type(i) == "string" then 
                    numberaaaa = true
                end
            end
            if indian and numberaaaa then 
                main = true
            end
            return main
        end
        function ValueTemplete(i, v, fat) 
            local okhand = ""
            if shouldUseBrackets(i) then 
                okhand = ArrayStyle:format(GenerateString(i)) .." = "..ValueTypeLua(v)
            elseif type(i) == "string" then 
                okhand = i .." = "..ValueTypeLua(v)
            elseif type(i) == "number" then 
                okhand = ArrayStyle:format(i) .." = " .. ValueTypeLua(v)
            else
                okhand = ValueTypeLuaSec(i) .." = "..ValueTypeLua(v)
            end
            local JOE = fat and "," or ""
            return okhand .. JOE
        end
        
        function HandleMoreList8(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if v ~= Table then
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            elseif NewTable == Table then
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        function HandleMoreList7(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if v ~= Table then
                    if typeof(v) == "table" then 
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList8(v)..JOE
                    else
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                    end
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            elseif NewTable == Table then
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        function HandleMoreList6(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if v ~= Table then
                    if typeof(v) == "table" then 
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList7(v)..JOE
                    else
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                    end
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            elseif NewTable == Table then
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        function HandleMoreList5(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if v ~= Table then
                    if typeof(v) == "table" then 
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList6(v)..JOE
                    else
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                    end
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            elseif NewTable == Table then
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        function HandleMoreList4(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if v ~= Table then
                    if typeof(v) == "table" then 
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList5(v)..JOE
                    else
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                    end
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            elseif NewTable == Table then
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        function HandleMoreList3(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if v ~= Table then
                    if typeof(v) == "table" then 
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList4(v)..JOE
                    else
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                    end
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            elseif NewTable == Table then
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        function HandleMoreList2(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if v ~= Table then
                    if typeof(v) == "table" then 
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList3(v)..JOE
                    else
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                    end
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            elseif NewTable == Table then
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        function HandleMoreList(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if v ~= Table then
                    if typeof(v) == "table" then 
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList2(v)..JOE
                    else
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                    end
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            elseif NewTable == Table then
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        local times = 0
        for i, v in pairs(Table) do
            times = times + 1
            local JOE = times ~= count(Table) and "," or ""
            if typeof(v) ~= "table" then
                results = results.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, times ~= count(Table))
            else
                results = results.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList(v)..JOE
            end
        end
        return results.."\n}"
    end
    function DumpFunction(func) 
        local ParsedTable = ""
        local Results = {}
        Results.Constants = debug.getconstants(func)
        Results.Upvalues = debug.getupvalues(func)
        if debug.getprotos then
            Results.Protos = debug.getprotos(func)
        end
        Results.GlobalsVars = getfenv(func)
        if not Sirhurt then
            Results.FunctionInfo = debug.getinfo(func)
        end
        ParsedTable = "DumpedFunction = "..Parse(Results)
        return ParsedTable
    end
end

CheatBlox.DumpFunction = function(self,func)
    if type(func) ~= "function" then error("CheatBlox: expected function, got "..typeof(func)) end
    return DumpFunction(func)
end

local function ConsoleError(txt)
    rconsoleprint("@@RED@@")
    rconsoleprint("ERROR: "..txt)
    rconsoleprint("@@WHITE@@")
    rconsoleprint("\n")
    return true
end

local function ConsoleAsk(txt)
    rconsoleprint("@@YELLOW@@")
    rconsoleprint(txt.." [Y/N]")
    rconsoleprint("@@WHITE@@")
    rconsoleprint("\n")
    rconsoleprint(">> ")
    local input = rconsoleinput()
    if string.lower(input) == "yes" or string.lower(input) == "y" then
        return true
    elseif string.lower(input) == "no" or string.lower(input) == "n" then
        return false
    end
    return nil
end

local function ConsolePrint(txt)
    rconsoleprint(txt.."\n")
    return true
end

local function ConsoleInfo(txt)
    rconsoleprint("[*] "..txt.."\n")
    return true
end
local remote_http = game:HttpGetAsync("https://raw.githubusercontent.com/ScriptingStefan/CheatBlox/main/srs.lua")
CheatBlox.Start = function()
    repeat wait() until game and workspace and game:GetService("Players").LocalPlayer
    rconsolename("CheatBlox - Made By Stefan#6965")
    local LP = game:GetService("Players").LocalPlayer
    local discard = true
    local selected = nil
    local tools = {
        ["playerdump"] = {
            "Writes a file containing info about all players in the current server.",
            function()
                local str = "Number of Players: "..tostring(#game:GetService("Players"):GetPlayers()).."\n\n\n"
                for i,v in pairs(game:GetService("Players"):GetPlayers()) do
                    str = str.."Name: "..v.Name.."\nUserId: "..tostring(LP.UserId).."\n\n"
                end
                local name = "RT_PLRS_"..tostring(math.random(1,9999999))..".txt"
                writefile(name,str)
                ConsolePrint("Wrote player info to [SYN_FOLDER]\\workspace\\"..name)
            end
        },
        ["remotedump"] = {
            "Writes a file containing info about all remotes.",
            function()
                local rems = {}
                for i,v in pairs(game:GetDescendants()) do --// ik getallinstances() is a thing, but it's kinda broken
                    local succ = pcall(function()
                        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
                            table.insert(rems,v)
                        end
                    end)
                end
                for i,v in pairs(getnilinstances()) do
                    local succ = pcall(function()
                        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
                            table.insert(rems,v)
                        end
                    end)
                end
                local str = "Number of Remotes: "..tostring(#rems).."\n\n"
                for i,v in pairs(rems) do
                    if v.Parent == nil then
                        str = str.."[NIL]."..tostring(v).."    ["..v.ClassName.."]\n"
                    else
                        str = str..v:GetFullName().."    ["..v.ClassName.."]\n"
                    end
                end
                local name = "RT_REMS_"..tostring(math.random(1,9999999))..".txt"
                writefile(name,str)
                ConsolePrint("Wrote remotes info to [SYN_FOLDER]\\workspace\\"..name)
            end
        },
        ["IY"] = {
            "Infinite Yield.",
            loadstring(game:HttpGet(("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"),true))
        },
        ["remotespy"] = {
            "Captures info sent to the server throughout remotes.",
            loadstring(remote_http)
        }
    }
    local commands
    commands = {
        ["help"] = {
            "Displays help.",
            function()
                for i,v in pairs(commands) do
                    ConsolePrint(i.." - "..v[1])
                end
                rconsoleprint("\n")
                return true
            end
        },
        ["tools"] = {
            "Shows all available tools.",
            function()
                for i,v in pairs(tools) do
                    ConsolePrint(i.." - "..v[1])
                end
                rconsoleprint("\n")
                return true
            end
        },
        ["exit"] = {
            "Closes the current roblox instance.",
            function()
                game:Shutdown()
                return true
            end
        },
        ["info"] = {
            "Displays info about the current roblox instance.",
            function()
                ConsolePrint("Client:\n\nName: "..LP.Name.."\nUserId: "..tostring(LP.UserId).."\n\nServer:\n\nPlace Id: "..tostring(game.PlaceId).."\nJob Id: "..tostring(game.JobId))
                return true
            end
        },
        ["clear"] = {
            "Clears the console.",
            function()
                rconsoleclear()
                return true
            end
        },
        ["run"] = {
            "run the selected tool.",
            function(tool)
                if not tool then
                    ConsoleError("CheatBlox: No tool selected.")
                    return true
                end
                tools[tool][2]()
                return true
            end
        }
    }
    local function OnInput(str)
        if type(str) ~= "string" or str == "" then return end
        local stuff = string.split(str," ")
        local cmd = table.remove(stuff,1)
        if commands[cmd] then
            discard = true
            local done = commands[cmd][2](unpack(stuff))
            discard = false
        else
            ConsoleError("CheatBlox: Unknown Command \""..cmd.."\".")
        end
    end
    spawn(function()
        local function InputCore()
            if not discard then
                rconsoleprint("@@YELLOW@@")
                rconsoleprint("Cheat")
                rconsoleprint("@@BLUE@@")
                rconsoleprint("Blox")
                rconsoleprint("@@WHITE@@")
                rconsoleprint(" ~# ")
                local input = rconsoleinput()
                OnInput(input)
                InputCore()
            else
                local input = rconsoleinput()
                OnInput(input)
            end
        end
        repeat wait() until discard == false
        InputCore()
    end)
    wait()
    discard = false
end

CheatBlox.Startup = CheatBlox.Start

getgenv().CheatBlox = CheatBlox
