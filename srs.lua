repeat wait() until game and workspace and game:IsLoaded()
if game:GetService("CoreGui"):FindFirstChild("SRS") then return end
local LP = game:GetService("Players").LocalPlayer
for i,v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
    v:Disable()
end
for i,v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
    v:Disable()
end
local SRS = Instance.new("ScreenGui")
SRS.Name = "SRS"
SRS.ResetOnSpawn = false
local run_sv = game:GetService("RunService")
local DarkButtons = {}
local COLOR_SCHEME_OPTIONS = {
	["gray"] = {70,70,70},
	["cyan"] = {90,180,180},
	["red"] = {180,90,90},
	["green"] = {90,180,90}
}
local SRS_ENABLED = true
local COLOR_SCHEME
local COLOR_SCHEME_RAW
if type(_G.SRS_COLOR) == "string" and type(COLOR_SCHEME_OPTIONS[_G.SRS_COLOR]) == "table" then
	COLOR_SCHEME = Color3.fromRGB(COLOR_SCHEME_OPTIONS[_G.SRS_COLOR][1],COLOR_SCHEME_OPTIONS[_G.SRS_COLOR][2],COLOR_SCHEME_OPTIONS[_G.SRS_COLOR][3])
	COLOR_SCHEME_RAW = COLOR_SCHEME_OPTIONS[_G.SRS_COLOR]
else
	COLOR_SCHEME = Color3.fromRGB(COLOR_SCHEME_OPTIONS["gray"][1],COLOR_SCHEME_OPTIONS["gray"][2],COLOR_SCHEME_OPTIONS["gray"][3])
	COLOR_SCHEME_RAW = COLOR_SCHEME_OPTIONS["gray"]
end

--// Support //--

local getcallingfunction = function(stack)
    return debug.getinfo(stack + 1).func or debug.getinfo(stack + 1)["function"] or debug.getinfo(stack + 1)["Function"]
end
if not syn then syn = {} end
local getcontext = getcontext or syn.get_thread_identity or getthreadcontext
local setcontext = setcontext or syn.set_thread_identity or setthreadcontext
local toclipboard = syn.write_clipboard or setclipboard or toclipboard or write_clipboard
local is_synapse_function = is_synapse_function or isexecutorclosure
local decompile = function(...)
	local args1231 = {...}
	local ret
	pcall(function()
		ret = decompile(unpack(args1231))
	end)
	if type(ret) ~= "string" or #ret < 1 then
		return "Decompilation Error"
	end
	return ret
end
local function call_func(func,...)
	setcontext(6)
	return func(...)
end
local function GetMouse()
	return LP:GetMouse()
end
local old_rc_frame
local RightClick
local ValChanger
local function get_srv_a(inst)
    if not inst then return "ERR_NIL_INST" end
    if typeof(inst) == "userdata" then return "ERR_NIL_INST" end
    local srv = inst
    repeat srv = srv.Parent until srv.Parent == game
    return srv
end
local function ServiceToString(inst)
    return [[game:GetService("]]..inst.ClassName..[[")]]
end
local GetPath
GetPath = function(Instance,pass)
	if Instance == game then return "game" end
	if Instance == workspace then return "workspace" end
	if Instance == LP and not pass then return "game:GetService(\"Players\").LocalPlayer" end
	if Instance == LP.Character and not pass then return "game:GetService(\"Players\").LocalPlayer.Character" end
    if typeof(Instance) == "Instance" then
        if Instance.Parent ~= nil then
            local stuff = string.split(Instance:GetFullName(),".")
            local passed = false
            local newstuff = {}
            for i,v in pairs(stuff) do
                if passed then
                    table.insert(newstuff,v)
                else
                    passed = true
                end
            end
            local almost = (Instance.Parent ~= game and ServiceToString(get_srv_a(Instance))) or ServiceToString(Instance)
            for i,v in pairs(newstuff) do
            	if not string.split(v,"")[1] then
            		almost = almost.."[\"\"]"
                elseif string.find(v," ") or not string.split(v,"")[1]:match("%a") or v:match("%p") then
                	almost = almost.."[\""..v.."\"]"
                else
                	almost = almost.."."..v
                end
            end
            if Instance:IsDescendantOf(LP.Character) then
            	almost = "game:GetService(\"Players\").LocalPlayer.Character"..string.sub(almost,1+#GetPath(LP.Character,true))
            end
            if Instance:IsDescendantOf(LP) then
            	almost = "game:GetService(\"Players\").LocalPlayer"..string.sub(almost,1+#GetPath(LP,true))
            end
            return almost
        else
            return "[NIL]."..Instance:GetFullName()
        end
    else
        return tostring(Instance)
    end
end
local GetType = function(Instance)
    local Types = {
        enumitem = function()
            return "Enum." .. tostring(Instance.EnumType) .. "." .. tostring(Instance.Name)
        end,
        instance = function()
            return GetPath(Instance)
        end,
        cframe = function()
            return "CFrame.new(" .. tostring(Instance) .. ")"
        end,
        vector3 = function()
            return "Vector3.new(" .. tostring(Instance) .. ")"
        end,
        brickcolor = function()
            return "BrickColor.new(\"" .. tostring(Instance) .. "\")"
        end,
        color3 = function()
            return "Color3.new(" .. tostring(Instance) .. ")"
        end,
        string = function()
            local S = tostring(Instance)
            if not S then
                S = "If you see this message, then this is a trap remote, an attempt to stop remotespys."
            end
            return [["]]..S..[["]]
        end,
        ray = function()
            return "Ray.new(Vector3.new(" .. tostring(Instance.Origin) .. "), Vector3.new(" .. tostring(Instance.Direction) .. "))"
        end,
        number = function()
            return tostring(Instance)
        end,
        userdata = function()
        	return "[USERDATA]"
        end
    }
    if Types[string.lower(typeof(Instance))] ~= nil then
        return Types[string.lower(typeof(Instance))]()
    else
        return tostring(Instance)
    end
end
local TableString
TableString = function(T,N)
	if not N then N = 1 end
    local M = {}
    for i, v in pairs(T) do
        local I = "\n"..string.rep("    ",N).. (type(i) == "number" and "[" .. tostring(i) .. "] = " or "[\"" .. tostring(i) .. "\"] = ")
        table.insert(M, tostring(I) .. (type(v) == "table" and  T ~= v and T ~= i and N < 100 and TableString(v,N+1) or GetType(v)))
    end
    local str_to_ret = "{" .. table.concat(M, ", ") .. "\n"..string.rep("    ",N-1).."}"
    if #str_to_ret > 150000 then
    	return "table too long"
    else	
    	return str_to_ret
    end
end
local TweenedButtons = {}
local function TweenButtonPress(button)
	spawn(function()
		wait()
		if old_rc_frame then
			old_rc_frame:Destroy()
		end
	end)
	spawn(function()
		for i,v in pairs(TweenedButtons) do
			if v == button then
				return
			end
		end
		table.insert(TweenedButtons,button)
		game:GetService("TweenService"):Create(button,TweenInfo.new(0.1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true,0),{["Position"] = button.Position + UDim2.new(0,3,0,3)}):Play()
		wait(0.21)
		for i,v in pairs(TweenedButtons) do
			if v == button then
				table.remove(TweenedButtons,i)
			end
		end
	end)
end
--// Bypass //--

if syn.protect_gui and not Sirhurt and not PROTOSMASHER_LOADED then
	syn.protect_gui(SRS)
end
SRS.Parent = game:GetService("CoreGui")

--// UI //--

local AllFrame

AllFrame = Instance.new("Frame")
local grad = Instance.new("UIGradient")
grad.Rotation = 90
local points = {
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(100,100,100))
}
grad.Color = ColorSequence.new(points)
grad.Parent = AllFrame
local ClickSound = Instance.new("Sound")
local ClickSound2 = Instance.new("Sound")
local EnterSound = Instance.new("Sound")
local ChangeSound = Instance.new("Sound")
local BeepSound = Instance.new("Sound")
local TitleFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TitleShadow = Instance.new("TextLabel")
local Options = Instance.new("TextButton")
local OptionsShadow = Instance.new("TextLabel")
local MainFrame = Instance.new("Frame")
local ButtonsFrame = Instance.new("Frame")
local Home = Instance.new("TextButton")
local HomeShadow = Instance.new("TextLabel")
local RemoteSpy = Instance.new("TextButton")
local RemoteSpyShadow = Instance.new("TextLabel")
local Remotes = Instance.new("TextButton")
local RemotesShadow = Instance.new("TextLabel")
local Namecall = Instance.new("TextButton")
local NamecallShadow = Instance.new("TextLabel")
local DebugShadow = Instance.new("TextLabel")
local Debug = Instance.new("TextButton")
local Clear = Instance.new("TextButton")
local UpScan = Instance.new("TextButton")
local ClearShadow = Instance.new("TextLabel")
local UpScanShadow = Instance.new("TextLabel")
local ScriptSpy = Instance.new("TextButton")
local ScriptSpyShadow = Instance.new("TextLabel")
local EnableSrs = Instance.new("TextButton")
local EnableSrsShadow = Instance.new("TextLabel")
local Injection = Instance.new("TextButton")
local InjectionShadow = Instance.new("TextLabel")
local HomeFrame = Instance.new("Frame")
local NewsText = Instance.new("TextLabel")
local RemoteSpyFrame = Instance.new("Frame")
local ScriptSpyFrame = Instance.new("Frame")
local RemoteLogsList = Instance.new("ScrollingFrame")
local ScriptLogsList = Instance.new("ScrollingFrame")
local RemoteSpyMain = Instance.new("Frame")
local ScriptSpyMain = Instance.new("Frame")
local RemoteSpyText = Instance.new("TextBox")
local ScriptSpyText = Instance.new("TextBox")
local RemoteFire = Instance.new("TextButton")
local SpyScript = Instance.new("TextButton")
local RemoteFireShadow = Instance.new("TextLabel")
local SpyScriptShadow = Instance.new("TextLabel")
local IgnoreRemote = Instance.new("TextButton")
local IgnoreIndCall = Instance.new("TextButton")
local UnSpyScript = Instance.new("TextButton")
local IgnoreRemoteCallShadow = Instance.new("TextLabel")
local IgnoreIndCallShadow = Instance.new("TextLabel")
local UnSpyScriptShadow = Instance.new("TextLabel")
local IgnoreRemoteCall = Instance.new("TextButton")
local IgnoreRemoteShadow = Instance.new("TextLabel")
local RemotesFrame = Instance.new("Frame")
local RemotesList = Instance.new("ScrollingFrame")
local Overlay = Instance.new("Frame")
local NamecallFrame = Instance.new("Frame")
local NamecallLogsList = Instance.new("ScrollingFrame")
local NamecallMain = Instance.new("Frame")
local NamecallText = Instance.new("TextBox")
local EnableNamecall = Instance.new("TextButton")
local EnableNamecallShadow = Instance.new("TextLabel")
local DebugFrame = Instance.new("Frame")
local DebugLogsList = Instance.new("ScrollingFrame")
local DebugMain = Instance.new("Frame")
local CText = Instance.new("TextLabel")
local UTextShadow = Instance.new("TextLabel")
local ULogs = Instance.new("ScrollingFrame")
local CLogs = Instance.new("ScrollingFrame")
local UText = Instance.new("TextLabel")
local CTextShadow = Instance.new("TextLabel")
local LTextShadow = Instance.new("TextLabel")
local EText = Instance.new("TextLabel")
local ETextShadow = Instance.new("TextLabel")
local ELogs = Instance.new("ScrollingFrame")
local LText = Instance.new("TextLabel")
local Darkness = Instance.new("Frame")
local ValChangerFrame = Instance.new("Frame")
local ChangerLabel = Instance.new("TextLabel")
local ChangerLabelShadow = Instance.new("TextLabel")
local ValChangerBox = Instance.new("TextBox")
local PrevValLabel = Instance.new("TextLabel")
local RightClickFrame = Instance.new("Frame")
local Hider = Instance.new("Frame")
local ChangerFrame = Instance.new("Frame")
local ChangerMain = Instance.new("Frame")
local SForShadow = Instance.new("TextLabel")
local SFor = Instance.new("TextLabel")
local SForBox = Instance.new("TextBox")
local TypeTextBox = Instance.new("TextBox")
local SearchButton = Instance.new("TextButton")
local SearchButtonShadow = Instance.new("TextLabel")
local ChangerLogsList = Instance.new("ScrollingFrame")
local RemoteLog = Instance.new("TextButton")
local RemoteLogShadow = Instance.new("TextLabel")

if GODDAM_SOUNDS then
	ClickSound.Volume = 0
	ClickSound2.Volume = 0
	EnterSound.Volume = 0
	ChangeSound.Volume = 0
	BeepSound.Volume = 0
end

grad:Clone().Parent = MainFrame
grad:Clone().Parent = HomeFrame
grad:Clone().Parent = RemoteSpyFrame
grad:Clone().Parent = ScriptSpyFrame
grad:Clone().Parent = RemotesFrame
grad:Clone().Parent = NamecallFrame
grad:Clone().Parent = DebugFrame
grad:Clone().Parent = ValChangerFrame
grad:Clone().Parent = ChangerFrame

RightClickFrame.Name = "RightClickFrame"
RightClickFrame.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
RightClickFrame.BorderSizePixel = 2
RightClickFrame.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]+30,COLOR_SCHEME_RAW[2]+30,COLOR_SCHEME_RAW[3]+30)
RightClickFrame.Size = UDim2.new(0,200,0,0)
RightClickFrame.ZIndex = 21000000
Hider.Name = "Hider"
Hider.Parent = RightClickFrame
Hider.AnchorPoint = Vector2.new(0,1)
Hider.Position = UDim2.new(0,0,1,0)
Hider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Hider.BorderSizePixel = 0
Hider.Size = UDim2.new(1,0,1,0)
Hider.ZIndex = 21000002
ClickSound.SoundId = "rbxassetid://5041171667"
ClickSound.Volume = 1
ClickSound.Parent = SRS
ClickSound2.SoundId = "rbxassetid://876939830"
ClickSound2.Volume = 4
ClickSound2.Parent = SRS
EnterSound.SoundId = "rbxassetid://177266782"
EnterSound.Volume = 1
EnterSound.Parent = SRS
ChangeSound.SoundId = "rbxassetid://4479083227"
ChangeSound.Volume = 1
ChangeSound.Parent = SRS
BeepSound.SoundId = "rbxassetid://138081500"
BeepSound.Volume = 0.5
BeepSound.Parent = SRS
AllFrame.Name = "AllFrame"
AllFrame.Parent = SRS
AllFrame.AnchorPoint = Vector2.new(0.5,0.5)
AllFrame.BackgroundColor3 = COLOR_SCHEME
AllFrame.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
AllFrame.BorderSizePixel = 5
AllFrame.Position = UDim2.new(0.5,0,0.5,0)
AllFrame.Size = UDim2.new(0,850,0,370)
AllFrame.BorderMode = Enum.BorderMode.Inset
AllFrame.ClipsDescendants = true
TitleFrame.Name = "TitleFrame"
TitleFrame.Parent = AllFrame
TitleFrame.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
TitleFrame.BorderSizePixel = 0
TitleFrame.AnchorPoint = Vector2.new(1,0)
TitleFrame.Position = UDim2.new(1,0,0,0)
TitleFrame.Size = UDim2.new(0, 250, 0, 30)
Title.Name = "Title"
Title.Parent = TitleFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.ZIndex = 10
Title.Font = Enum.Font.GothamSemibold
Title.Text = "CheatBlox"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.TextSize = 14
Title.TextWrapped = true
TitleShadow.Name = "TitleShadow"
TitleShadow.Parent = TitleFrame
TitleShadow.BackgroundTransparency = 1
TitleShadow.Position = UDim2.new(0, 3, 0, 3)
TitleShadow.Size = UDim2.new(1, 0, 1, 0)
TitleShadow.Font = Enum.Font.GothamSemibold
TitleShadow.Text = "CheatBlox"
TitleShadow.TextColor3 = Color3.new(0, 0, 0)
TitleShadow.TextScaled = true
TitleShadow.TextSize = 14
TitleShadow.TextWrapped = true
Options.Name = "Options"
Options.Parent = AllFrame
Options.BackgroundTransparency = 1
Options.Size = UDim2.new(0, 150, 0, 30)
Options.AutoButtonColor = false
Options.Text = "Menu"
Options.TextColor3 = Color3.new(0,1,0)
Options.TextScaled = true
Options.TextSize = 14
Options.TextWrapped = true
Options.ZIndex = 100000
OptionsShadow.Name = "OptionsShadow"
OptionsShadow.Parent = AllFrame
OptionsShadow.BackgroundTransparency = 1
OptionsShadow.Position = UDim2.new(0, 3, 0, 3)
OptionsShadow.Selectable = true
OptionsShadow.Size = UDim2.new(0, 150, 0, 30)
OptionsShadow.ZIndex = 10000
OptionsShadow.Text = "Menu"
OptionsShadow.TextColor3 = Color3.new(0, 0, 0)
OptionsShadow.TextScaled = true
OptionsShadow.TextSize = 14
OptionsShadow.TextWrapped = true
MainFrame.Name = "MainFrame"
MainFrame.Parent = AllFrame
MainFrame.AnchorPoint = Vector2.new(0, 1)
MainFrame.BackgroundColor3 = COLOR_SCHEME
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 0, 1, 0)
MainFrame.Size = UDim2.new(1, 0, 1, -30)
ButtonsFrame.Name = "ButtonsFrame"
ButtonsFrame.Parent = MainFrame
ButtonsFrame.AnchorPoint = Vector2.new(1,1)
ButtonsFrame.BackgroundColor3 = COLOR_SCHEME
ButtonsFrame.BorderColor3 = Color3.fromRGB(0,0,0)
ButtonsFrame.BorderSizePixel = 3
ButtonsFrame.Position = UDim2.new(0, -7, 1, 0)
ButtonsFrame.Size = UDim2.new(0, 150, 1, 0)
ButtonsFrame.ZIndex = 222222
Home.Name = "Home"
Home.Parent = ButtonsFrame
Home.BackgroundTransparency = 1
Home.Size = UDim2.new(1, 0, 0, 30)
Home.AutoButtonColor = false
Home.Text = "Home"
Home.TextColor3 = Color3.new(1, 1, 1)
Home.TextScaled = true
Home.TextSize = 14
Home.TextWrapped = true
Home.ZIndex = 10000000
HomeShadow.Name = "HomeShadow"
HomeShadow.Parent = ButtonsFrame
HomeShadow.BackgroundTransparency = 1
HomeShadow.Position = UDim2.new(0, 3, 0, 3)
HomeShadow.Size = UDim2.new(1, 0, 0, 30)
HomeShadow.ZIndex = 0
HomeShadow.Text = "Home"
HomeShadow.TextColor3 = Color3.new(0, 0, 0)
HomeShadow.TextScaled = true
HomeShadow.TextSize = 14
HomeShadow.TextWrapped = true
HomeShadow.ZIndex = 10000000 - 1
RemoteSpy.Name = "RemoteSpy"
RemoteSpy.Parent = ButtonsFrame
RemoteSpy.BackgroundTransparency = 1
RemoteSpy.Position = UDim2.new(0, 0, 0, 30)
RemoteSpy.Size = UDim2.new(1, 0, 0, 30)
RemoteSpy.AutoButtonColor = false
RemoteSpy.Text = "RemoteSpy"
RemoteSpy.TextColor3 = Color3.new(1, 1, 1)
RemoteSpy.TextScaled = true
RemoteSpy.TextSize = 14
RemoteSpy.TextWrapped = true
RemoteSpy.ZIndex = 10000000
RemoteSpyShadow.Name = "RemoteSpyShadow"
RemoteSpyShadow.Parent = ButtonsFrame
RemoteSpyShadow.BackgroundTransparency = 1
RemoteSpyShadow.Position = UDim2.new(0, 3, 0, 33)
RemoteSpyShadow.Size = UDim2.new(1, 0, 0, 30)
RemoteSpyShadow.ZIndex = 0
RemoteSpyShadow.Text = "RemoteSpy"
RemoteSpyShadow.TextColor3 = Color3.new(0, 0, 0)
RemoteSpyShadow.TextScaled = true
RemoteSpyShadow.TextSize = 14
RemoteSpyShadow.TextWrapped = true
RemoteSpyShadow.ZIndex = 10000000 - 1
Remotes.Name = "Remotes"
Remotes.Parent = ButtonsFrame
Remotes.BackgroundTransparency = 1
Remotes.Position = UDim2.new(0, 0, 0, 90)
Remotes.Size = UDim2.new(1, 0, 0, 30)
Remotes.AutoButtonColor = false
Remotes.Text = "Remotes"
Remotes.TextColor3 = Color3.new(1, 1, 1)
Remotes.TextScaled = true
Remotes.TextSize = 14
Remotes.TextWrapped = true
Remotes.ZIndex = 10000000
RemotesShadow.Name = "RemotesShadow"
RemotesShadow.Parent = ButtonsFrame
RemotesShadow.BackgroundTransparency = 1
RemotesShadow.Position = UDim2.new(0, 3, 0, 93)
RemotesShadow.Size = UDim2.new(1, 0, 0, 30)
RemotesShadow.ZIndex = 0
RemotesShadow.Text = "Remotes"
RemotesShadow.TextColor3 = Color3.new(0, 0, 0)
RemotesShadow.TextScaled = true
RemotesShadow.TextSize = 14
RemotesShadow.TextWrapped = true
RemotesShadow.ZIndex = 10000000 - 1
Namecall.Name = "Namecall"
Namecall.Parent = ButtonsFrame
Namecall.BackgroundTransparency = 1
Namecall.Position = UDim2.new(0, 0, 0, 120)
Namecall.Size = UDim2.new(1, 0, 0, 30)
Namecall.AutoButtonColor = false
Namecall.Text = "Ignored"
Namecall.TextColor3 = Color3.new(1, 1, 1)
Namecall.TextScaled = true
Namecall.TextSize = 14
Namecall.TextWrapped = true
Namecall.ZIndex = 10000000
NamecallShadow.Name = "NamecallShadow"
NamecallShadow.Parent = ButtonsFrame
NamecallShadow.BackgroundTransparency = 1
NamecallShadow.Position = UDim2.new(0, 3, 0, 123)
NamecallShadow.Size = UDim2.new(1, 0, 0, 30)
NamecallShadow.ZIndex = 0
NamecallShadow.Text = "Ignored"
NamecallShadow.TextColor3 = Color3.new(0, 0, 0)
NamecallShadow.TextScaled = true
NamecallShadow.TextSize = 14
NamecallShadow.TextWrapped = true
NamecallShadow.ZIndex = 10000000 - 1
DebugShadow.Name = "DebugShadow"
DebugShadow.Parent = ButtonsFrame
DebugShadow.BackgroundTransparency = 1
DebugShadow.Position = UDim2.new(0, 3, 0, 63)
DebugShadow.Size = UDim2.new(1, 0, 0, 30)
DebugShadow.ZIndex = 0
DebugShadow.Text = "Debug"
DebugShadow.TextColor3 = Color3.new(0, 0, 0)
DebugShadow.TextScaled = true
DebugShadow.TextSize = 14
DebugShadow.TextWrapped = true
DebugShadow.ZIndex = 10000000 - 1
Debug.Name = "Debug"
Debug.Parent = ButtonsFrame
Debug.BackgroundTransparency = 1
Debug.Position = UDim2.new(0, 0, 0, 60)
Debug.Size = UDim2.new(1, 0, 0, 30)
Debug.AutoButtonColor = false
Debug.Text = "Debug"
Debug.TextColor3 = Color3.new(1, 1, 1)
Debug.TextScaled = true
Debug.TextSize = 14
Debug.TextWrapped = true
Debug.ZIndex = 10000000
ScriptSpy.Name = "ScriptSpy"
ScriptSpy.Parent = ButtonsFrame
ScriptSpy.BackgroundTransparency = 1
ScriptSpy.Position = UDim2.new(0, 0, 0, 180)
ScriptSpy.Size = UDim2.new(1, 0, 0, 30)
ScriptSpy.AutoButtonColor = false
ScriptSpy.Text = "ScriptSpy"
ScriptSpy.TextColor3 = Color3.new(1,1,1)
ScriptSpy.TextScaled = true
ScriptSpy.TextSize = 14
ScriptSpy.TextWrapped = true
ScriptSpy.ZIndex = 10000000
EnableSrs.Name = "EnableSrs"
EnableSrs.Parent = ButtonsFrame
EnableSrs.BackgroundTransparency = 1
EnableSrs.Position = UDim2.new(0, 0, 0, 240)
EnableSrs.Size = UDim2.new(1, 0, 0, 30)
EnableSrs.AutoButtonColor = false
EnableSrs.Text = "Enabled"
EnableSrs.TextColor3 = Color3.new(0,1,0)
EnableSrs.TextScaled = true
EnableSrs.TextSize = 14
EnableSrs.TextWrapped = true
EnableSrs.ZIndex = 10000000
ScriptSpyShadow.Name = "ScriptSpyShadow"
ScriptSpyShadow.Parent = ButtonsFrame
ScriptSpyShadow.BackgroundTransparency = 1
ScriptSpyShadow.Position = UDim2.new(0, 3, 0, 183)
ScriptSpyShadow.Size = UDim2.new(1, 0, 0, 30)
ScriptSpyShadow.ZIndex = 0
ScriptSpyShadow.Text = "ScriptSpy"
ScriptSpyShadow.TextColor3 = Color3.new(0, 0, 0)
ScriptSpyShadow.TextScaled = true
ScriptSpyShadow.TextSize = 14
ScriptSpyShadow.TextWrapped = true
ScriptSpyShadow.ZIndex = 10000000 - 1
EnableSrsShadow.Name = "EnableSrsShadow"
EnableSrsShadow.Parent = ButtonsFrame
EnableSrsShadow.BackgroundTransparency = 1
EnableSrsShadow.Position = UDim2.new(0, 3, 0, 243)
EnableSrsShadow.Size = UDim2.new(1, 0, 0, 30)
EnableSrsShadow.ZIndex = 0
EnableSrsShadow.Text = "Enabled"
EnableSrsShadow.TextColor3 = Color3.new(0, 0, 0)
EnableSrsShadow.TextScaled = true
EnableSrsShadow.TextSize = 14
EnableSrsShadow.TextWrapped = true
EnableSrsShadow.ZIndex = 10000000 - 1
UpScan.Name = "UpScan"
UpScan.Parent = ButtonsFrame
UpScan.BackgroundTransparency = 1
UpScan.Position = UDim2.new(0, 0, 0, 210)
UpScan.Size = UDim2.new(1, 0, 0, 30)
UpScan.AutoButtonColor = false
UpScan.Text = "Val Finder"
UpScan.TextColor3 = Color3.new(1, 1, 1)
UpScan.TextScaled = true
UpScan.TextSize = 14
UpScan.TextWrapped = true
UpScan.ZIndex = 10000000
UpScanShadow.Name = "UpScanShadow"
UpScanShadow.Parent = ButtonsFrame
UpScanShadow.BackgroundTransparency = 1
UpScanShadow.Position = UDim2.new(0, 3, 0, 213)
UpScanShadow.Size = UDim2.new(1, 0, 0, 30)
UpScanShadow.ZIndex = 0
UpScanShadow.Text = "Val Finder"
UpScanShadow.TextColor3 = Color3.new(0, 0, 0)
UpScanShadow.TextScaled = true
UpScanShadow.TextSize = 14
UpScanShadow.TextWrapped = true
UpScanShadow.ZIndex = 10000000 - 1
Clear.Name = "Clear"
Clear.Parent = ButtonsFrame
Clear.BackgroundTransparency = 1
Clear.Position = UDim2.new(0, 0, 0, 270)
Clear.Size = UDim2.new(1, 0, 0, 30)
Clear.AutoButtonColor = false
Clear.Text = "Clear"
Clear.TextColor3 = Color3.new(1, 1, 1)
Clear.TextScaled = true
Clear.TextSize = 14
Clear.TextWrapped = true
Clear.ZIndex = 10000000
ClearShadow.Name = "ClearShadow"
ClearShadow.Parent = ButtonsFrame
ClearShadow.BackgroundTransparency = 1
ClearShadow.Position = UDim2.new(0, 3, 0, 273)
ClearShadow.Size = UDim2.new(1, 0, 0, 30)
ClearShadow.ZIndex = 0
ClearShadow.Text = "Clear"
ClearShadow.TextColor3 = Color3.new(0, 0, 0)
ClearShadow.TextScaled = true
ClearShadow.TextSize = 14
ClearShadow.TextWrapped = true
ClearShadow.ZIndex = 10000000 - 1
HomeFrame.Name = "HomeFrame"
HomeFrame.Parent = MainFrame
HomeFrame.BackgroundColor3 = COLOR_SCHEME
HomeFrame.BorderSizePixel = 0
HomeFrame.Size = UDim2.new(1, 0, 1, 0)
HomeFrame.Visible = true
NewsText.Name = "News"
NewsText.Parent = HomeFrame
NewsText.BackgroundTransparency = 1
NewsText.Size = UDim2.new(1, 0, 1, 0)
NewsText.Text = [[
F8 = hide/show; F6 = min/max

Changelog:
[+] Function names.



My Discord: Stefan#6965
My Discord Server Code: cRsEhnFqsW
]]
NewsText.TextColor3 = Color3.new(1, 1, 1)
NewsText.TextSize = 25
NewsText.TextYAlignment = Enum.TextYAlignment.Top
NewsText.ZIndex = NewsText.ZIndex + 1
RemoteSpyFrame.Name = "RemoteSpyFrame"
RemoteSpyFrame.Parent = MainFrame
RemoteSpyFrame.BackgroundColor3 = COLOR_SCHEME
RemoteSpyFrame.BorderSizePixel = 0
RemoteSpyFrame.Size = UDim2.new(1, 0, 1, 0)
RemoteSpyFrame.Visible = false
ScriptSpyFrame.Name = "ScriptSpyFrame"
ScriptSpyFrame.Parent = MainFrame
ScriptSpyFrame.BackgroundColor3 = COLOR_SCHEME
ScriptSpyFrame.BorderSizePixel = 0
ScriptSpyFrame.Size = UDim2.new(1, 0, 1, 0)
ScriptSpyFrame.Visible = false
RemoteLogsList.Name = "RemoteLogsList"
RemoteLogsList.Parent = RemoteSpyFrame
RemoteLogsList.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
RemoteLogsList.BorderSizePixel = 2
RemoteLogsList.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
RemoteLogsList.Size = UDim2.new(0, 196, 1, 0)
RemoteLogsList.ScrollBarThickness = 0
ScriptLogsList.Name = "ScriptLogsList"
ScriptLogsList.Parent = ScriptSpyFrame
ScriptLogsList.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
ScriptLogsList.BorderSizePixel = 2
ScriptLogsList.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
ScriptLogsList.Size = UDim2.new(0, 196, 1, 0)
ScriptLogsList.ScrollBarThickness = 0
RemoteSpyMain.Name = "RemoteSpyMain"
RemoteSpyMain.Parent = RemoteSpyFrame
RemoteSpyMain.AnchorPoint = Vector2.new(1, 0)
RemoteSpyMain.BackgroundTransparency = 1
RemoteSpyMain.Position = UDim2.new(1, 0, 0, 0)
RemoteSpyMain.Size = UDim2.new(1, -200, 1, 0)
ScriptSpyMain.Name = "ScriptSpyMain"
ScriptSpyMain.Parent = ScriptSpyFrame
ScriptSpyMain.AnchorPoint = Vector2.new(1, 0)
ScriptSpyMain.BackgroundTransparency = 1
ScriptSpyMain.Position = UDim2.new(1, 0, 0, 0)
ScriptSpyMain.Size = UDim2.new(1, -200, 1, 0)
RemoteSpyText.Name = "RemoteSpyText"
RemoteSpyText.Parent = RemoteSpyMain
RemoteSpyText.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
RemoteSpyText.BorderSizePixel = 2
RemoteSpyText.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
RemoteSpyText.Size = UDim2.new(1, 0, 0, 300)
RemoteSpyText.ClearTextOnFocus = false
RemoteSpyText.MultiLine = true
RemoteSpyText.PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.698039)
RemoteSpyText.PlaceholderText = "--// Remote Script Here"
RemoteSpyText.Text = ""
RemoteSpyText.TextWrapped = true
RemoteSpyText.TextColor3 = Color3.new(1, 1, 1)
RemoteSpyText.TextSize = 10
RemoteSpyText.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyText.TextYAlignment = Enum.TextYAlignment.Top
ScriptSpyText.Name = "ScriptSpyText"
ScriptSpyText.Parent = ScriptSpyMain
ScriptSpyText.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
ScriptSpyText.BorderSizePixel = 2
ScriptSpyText.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
ScriptSpyText.Size = UDim2.new(1, 0, 0, 300)
ScriptSpyText.ClearTextOnFocus = false
ScriptSpyText.MultiLine = true
ScriptSpyText.PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.698039)
ScriptSpyText.PlaceholderText = "--// Path To LocalScript Here"
ScriptSpyText.Text = ""
ScriptSpyText.TextColor3 = Color3.new(1, 1, 1)
ScriptSpyText.TextSize = 10
ScriptSpyText.TextWrapped = true
ScriptSpyText.TextXAlignment = Enum.TextXAlignment.Left
ScriptSpyText.TextYAlignment = Enum.TextYAlignment.Top
RemoteFire.Name = "RemoteFire"
RemoteFire.Parent = RemoteSpyMain
RemoteFire.BackgroundTransparency = 1
RemoteFire.Position = UDim2.new(-0, 0, 0, 300)
RemoteFire.Size = UDim2.new(0, 200, 0, 30)
RemoteFire.AutoButtonColor = false
RemoteFire.Text = "Fire Remote"
RemoteFire.TextColor3 = Color3.new(1, 1, 1)
RemoteFire.TextScaled = true
RemoteFire.TextSize = 14
RemoteFire.TextWrapped = true
RemoteFire.ZIndex = 100
RemoteFireShadow.Name = "RemoteFireShadow"
RemoteFireShadow.Parent = RemoteSpyMain
RemoteFireShadow.BackgroundTransparency = 1
RemoteFireShadow.Position = UDim2.new(0, 3, 0, 303)
RemoteFireShadow.Size = UDim2.new(0, 200, 0, 30)
RemoteFireShadow.ZIndex = 99
RemoteFireShadow.Text = "Fire Remote"
RemoteFireShadow.TextColor3 = Color3.new(0, 0, 0)
RemoteFireShadow.TextScaled = true
RemoteFireShadow.TextSize = 14
RemoteFireShadow.TextWrapped = true
SpyScript.Name = "SpyScript"
SpyScript.Parent = ScriptSpyMain
SpyScript.BackgroundTransparency = 1
SpyScript.Position = UDim2.new(-0, 0, 0, 300)
SpyScript.Size = UDim2.new(0, 200, 0, 30)
SpyScript.AutoButtonColor = false
SpyScript.Text = "Spy"
SpyScript.TextColor3 = Color3.new(1, 1, 1)
SpyScript.TextScaled = true
SpyScript.TextSize = 14
SpyScript.TextWrapped = true
SpyScript.ZIndex = 100
SpyScriptShadow.Name = "SpyScriptShadow"
SpyScriptShadow.Parent = ScriptSpyMain
SpyScriptShadow.BackgroundTransparency = 1
SpyScriptShadow.Position = UDim2.new(0, 3, 0, 303)
SpyScriptShadow.Size = UDim2.new(0, 200, 0, 30)
SpyScriptShadow.ZIndex = 99
SpyScriptShadow.Text = "Spy"
SpyScriptShadow.TextColor3 = Color3.new(0, 0, 0)
SpyScriptShadow.TextScaled = true
SpyScriptShadow.TextSize = 14
SpyScriptShadow.TextWrapped = true
UnSpyScript.Name = "UnSpyScript"
UnSpyScript.Parent = ScriptSpyMain
UnSpyScript.BackgroundTransparency = 1
UnSpyScript.Position = UDim2.new(0, 210, 0, 300)
UnSpyScript.Size = UDim2.new(0, 200, 0, 30)
UnSpyScript.AutoButtonColor = false
UnSpyScript.Text = "Unspy"
UnSpyScript.TextColor3 = Color3.new(1, 1, 1)
UnSpyScript.TextScaled = true
UnSpyScript.TextSize = 14
UnSpyScript.TextWrapped = true
UnSpyScript.ZIndex = 100
UnSpyScriptShadow.Name = "UnSpyScriptShadow"
UnSpyScriptShadow.Parent = ScriptSpyMain
UnSpyScriptShadow.BackgroundTransparency = 1
UnSpyScriptShadow.Position = UDim2.new(0, 213, 0, 303)
UnSpyScriptShadow.Size = UDim2.new(0, 200, 0, 30)
UnSpyScriptShadow.ZIndex = 99
UnSpyScriptShadow.Text = "Unspy"
UnSpyScriptShadow.TextColor3 = Color3.new(0, 0, 0)
UnSpyScriptShadow.TextScaled = true
UnSpyScriptShadow.TextSize = 14
UnSpyScriptShadow.TextWrapped = true
IgnoreRemote.Name = "IgnoreRemote"
IgnoreRemote.Parent = RemoteSpyMain
IgnoreRemote.BackgroundTransparency = 1
IgnoreRemote.Position = UDim2.new(0, 210, 0, 300)
IgnoreRemote.Size = UDim2.new(0, 200, 0, 30)
IgnoreRemote.AutoButtonColor = false
IgnoreRemote.Text = "Ignore Remote"
IgnoreRemote.TextColor3 = Color3.new(1, 1, 1)
IgnoreRemote.TextScaled = true
IgnoreRemote.TextSize = 14
IgnoreRemote.TextWrapped = true
IgnoreRemote.ZIndex = 100
IgnoreRemoteCallShadow.Name = "IgnoreRemoteCallShadow"
IgnoreRemoteCallShadow.Parent = RemoteSpyMain
IgnoreRemoteCallShadow.BackgroundTransparency = 1
IgnoreRemoteCallShadow.Position = UDim2.new(0, 423, 0, 303)
IgnoreRemoteCallShadow.Size = UDim2.new(0, 200, 0, 30)
IgnoreRemoteCallShadow.ZIndex = 99
IgnoreRemoteCallShadow.Text = "Ignore Call"
IgnoreRemoteCallShadow.TextColor3 = Color3.new(0, 0, 0)
IgnoreRemoteCallShadow.TextScaled = true
IgnoreRemoteCallShadow.TextSize = 14
IgnoreRemoteCallShadow.TextWrapped = true
IgnoreRemoteCall.Name = "IgnoreRemoteCall"
IgnoreRemoteCall.Parent = RemoteSpyMain
IgnoreRemoteCall.BackgroundTransparency = 1
IgnoreRemoteCall.Position = UDim2.new(0, 420, 0, 300)
IgnoreRemoteCall.Size = UDim2.new(0, 200, 0, 30)
IgnoreRemoteCall.AutoButtonColor = false
IgnoreRemoteCall.Text = "Ignore Call"
IgnoreRemoteCall.TextColor3 = Color3.new(1, 1, 1)
IgnoreRemoteCall.TextScaled = true
IgnoreRemoteCall.TextSize = 14
IgnoreRemoteCall.TextWrapped = true
IgnoreRemoteCall.ZIndex = 100
IgnoreIndCall.Name = "IgnoreIndCall"
IgnoreIndCall.Parent = ScriptSpyMain
IgnoreIndCall.BackgroundTransparency = 1
IgnoreIndCall.Position = UDim2.new(0, 420, 0, 300)
IgnoreIndCall.Size = UDim2.new(0, 200, 0, 30)
IgnoreIndCall.AutoButtonColor = false
IgnoreIndCall.Text = "Ignore Call"
IgnoreIndCall.TextColor3 = Color3.new(1, 1, 1)
IgnoreIndCall.TextScaled = true
IgnoreIndCall.TextSize = 14
IgnoreIndCall.TextWrapped = true
IgnoreIndCall.ZIndex = 100
IgnoreIndCallShadow.Name = "IgnoreRemoteShadow"
IgnoreIndCallShadow.Parent = ScriptSpyMain
IgnoreIndCallShadow.BackgroundTransparency = 1
IgnoreIndCallShadow.Position = UDim2.new(0, 423, 0, 303)
IgnoreIndCallShadow.Size = UDim2.new(0, 200, 0, 30)
IgnoreIndCallShadow.ZIndex = 99
IgnoreIndCallShadow.Text = "Ignore Call"
IgnoreIndCallShadow.TextColor3 = Color3.new(0, 0, 0)
IgnoreIndCallShadow.TextScaled = true
IgnoreIndCallShadow.TextSize = 14
IgnoreIndCallShadow.TextWrapped = true
IgnoreRemoteShadow.Name = "IgnoreRemoteShadow"
IgnoreRemoteShadow.Parent = RemoteSpyMain
IgnoreRemoteShadow.BackgroundTransparency = 1
IgnoreRemoteShadow.Position = UDim2.new(0, 213, 0, 303)
IgnoreRemoteShadow.Size = UDim2.new(0, 200, 0, 30)
IgnoreRemoteShadow.ZIndex = 99
IgnoreRemoteShadow.Text = "Ignore Remote"
IgnoreRemoteShadow.TextColor3 = Color3.new(0, 0, 0)
IgnoreRemoteShadow.TextScaled = true
IgnoreRemoteShadow.TextSize = 14
IgnoreRemoteShadow.TextWrapped = true
RemotesFrame.Name = "RemotesFrame"
RemotesFrame.Parent = MainFrame
RemotesFrame.BackgroundColor3 = COLOR_SCHEME
RemotesFrame.BorderSizePixel = 0
RemotesFrame.Size = UDim2.new(1, 0, 1, 0)
RemotesFrame.Visible = false
ChangerFrame.Name = "ChangerFrame"
ChangerFrame.Parent = MainFrame
ChangerFrame.BackgroundColor3 = COLOR_SCHEME
ChangerFrame.BorderSizePixel = 0
ChangerFrame.Size = UDim2.new(1, 0, 1, 0)
ChangerFrame.Visible = false
ChangerMain.Name = "ChangerMain"
ChangerMain.Parent = ChangerFrame
ChangerMain.AnchorPoint = Vector2.new(1, 0)
ChangerMain.BackgroundTransparency = 1
ChangerMain.Position = UDim2.new(1, 0, 0, 0)
ChangerMain.Size = UDim2.new(1, -200, 1, 0)
SFor.Name = "SFor"
SFor.Parent = ChangerMain
SFor.BackgroundTransparency = 1
SFor.Position = UDim2.new(0, 55, 0, 0)
SFor.Size = UDim2.new(0, 200, 0, 50)
SFor.ZIndex = 100
SFor.Text = "Search for..."
SFor.TextColor3 = Color3.new(1, 1, 1)
SFor.TextScaled = true
SFor.TextSize = 14
SFor.TextWrapped = true
SForBox.Name = "SForBox"
SForBox.Parent = ChangerMain
SForBox.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
SForBox.BorderSizePixel = 2
SForBox.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
SForBox.Position = UDim2.new(0.5,0, 0, 100)
SForBox.Size = UDim2.new(0, 300, 0, 60)
SForBox.ClearTextOnFocus = false
SForBox.MultiLine = true
SForBox.PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.698039)
SForBox.PlaceholderText = "eg: \"ammo\", 123"
SForBox.Text = ""
SForBox.TextColor3 = Color3.new(1, 1, 1)
SForBox.AnchorPoint = Vector2.new(0.5,0.5)
SForBox.TextSize = 15
TypeTextBox.Name = "TypeTextBox"
TypeTextBox.Parent = ChangerMain
TypeTextBox.AnchorPoint = Vector2.new(0.5,0.5)
TypeTextBox.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
TypeTextBox.BorderSizePixel = 2
TypeTextBox.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
TypeTextBox.Position = UDim2.new(0.5,0, 0, 170)
TypeTextBox.Size = UDim2.new(0, 300, 0, 60)
TypeTextBox.ClearTextOnFocus = false
TypeTextBox.MultiLine = true
TypeTextBox.PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.698039)
TypeTextBox.PlaceholderText = "eg:upvalue,global,prop,table"
TypeTextBox.Text = ""
TypeTextBox.TextColor3 = Color3.new(1, 1, 1)
TypeTextBox.TextSize = 15
SearchButton.Name = "SearchButton"
SearchButton.AnchorPoint = Vector2.new(0.5,0.5)
SearchButton.Parent = ChangerMain
SearchButton.BackgroundTransparency = 1
SearchButton.Position = UDim2.new(0.5,0,0,300)
SearchButton.Size = UDim2.new(0, 200, 0, 30)
SearchButton.ZIndex = 100
SearchButton.AutoButtonColor = false
SearchButton.Text = "Search"
SearchButton.TextColor3 = Color3.new(1, 1, 1)
SearchButton.TextScaled = true
SearchButton.TextSize = 14
SearchButton.TextWrapped = true
SearchButtonShadow.Name = "SearchButtonShadow"
SearchButtonShadow.Parent = ChangerMain
SearchButtonShadow.BackgroundTransparency = 1
SearchButtonShadow.AnchorPoint = Vector2.new(0.5,0.5)
SearchButtonShadow.Position = UDim2.new(0.5,3,0,303)
SearchButtonShadow.Size = UDim2.new(0, 200, 0, 30)
SearchButtonShadow.ZIndex = 99
SearchButtonShadow.Text = "Search"
SearchButtonShadow.TextColor3 = Color3.new(0, 0, 0)
SearchButtonShadow.TextScaled = true
SearchButtonShadow.TextSize = 14
SearchButtonShadow.TextWrapped = true
ChangerLogsList.Name = "ChangerLogsList"
ChangerLogsList.Parent = ChangerFrame
ChangerLogsList.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
ChangerLogsList.BorderSizePixel = 2
ChangerLogsList.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
ChangerLogsList.Size = UDim2.new(0, 200, 1, 0)
ChangerLogsList.ScrollBarThickness = 0
SForShadow.Name = "SForShadow"
SForShadow.Parent = ChangerMain
SForShadow.BackgroundTransparency = 1
SForShadow.Position = UDim2.new(0, 58, 0, 3)
SForShadow.Size = UDim2.new(0, 200, 0, 50)
SForShadow.ZIndex = 99
SForShadow.Text = "Search for..."
SForShadow.TextColor3 = Color3.new(0, 0, 0)
SForShadow.TextScaled = true
SForShadow.TextSize = 14
SForShadow.TextWrapped = true
RemotesList.Name = "RemotesList"
RemotesList.Parent = RemotesFrame
RemotesList.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
RemotesList.BorderSizePixel = 0
RemotesList.Size = UDim2.new(1, 0, 1, 0)
RemotesList.ScrollBarThickness = 0
Overlay.Name = "Overlay"
Overlay.Parent = MainFrame
Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
Overlay.BackgroundTransparency = 0.7
Overlay.BorderSizePixel = 0
Overlay.Size = UDim2.new(0, 0, 1, 0)
Overlay.ZIndex = 222
NamecallFrame.Name = "NamecallFrame"
NamecallFrame.Parent = MainFrame
NamecallFrame.BackgroundColor3 = COLOR_SCHEME
NamecallFrame.BorderSizePixel = 0
NamecallFrame.Size = UDim2.new(1, 0, 1, 0)
NamecallFrame.Visible = false
NamecallLogsList.Name = "NamecallLogsList"
NamecallLogsList.Parent = NamecallFrame
NamecallLogsList.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
NamecallLogsList.BorderSizePixel = 2
NamecallLogsList.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
NamecallLogsList.Size = UDim2.new(0, 196, 1, 0)
NamecallLogsList.ScrollBarThickness = 0
NamecallMain.Name = "NamecallMain"
NamecallMain.Parent = NamecallFrame
NamecallMain.AnchorPoint = Vector2.new(1, 0)
NamecallMain.BackgroundTransparency = 1
NamecallMain.Position = UDim2.new(1, 0, 0, 0)
NamecallMain.Size = UDim2.new(1, -200, 1, 0)
NamecallText.Name = "NamecallText"
NamecallText.Parent = NamecallMain
NamecallText.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
NamecallText.BorderSizePixel = 2
NamecallText.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
NamecallText.Size = UDim2.new(1, 0, 0, 300)
NamecallText.ClearTextOnFocus = false
NamecallText.MultiLine = true
NamecallText.PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.698039)
NamecallText.PlaceholderText = "--// Namecall Info Here"
NamecallText.Text = ""
NamecallText.TextColor3 = Color3.new(1, 1, 1)
NamecallText.TextSize = 20
NamecallText.TextXAlignment = Enum.TextXAlignment.Left
NamecallText.TextYAlignment = Enum.TextYAlignment.Top
EnableNamecall.Name = "EnableNamecall"
EnableNamecall.Parent = NamecallMain
EnableNamecall.BackgroundTransparency = 1
EnableNamecall.Position = UDim2.new(0, 0, 0, 300)
EnableNamecall.Size = UDim2.new(0, 200, 0, 30)
EnableNamecall.AutoButtonColor = false
EnableNamecall.Text = "Enable"
EnableNamecall.TextColor3 = Color3.new(0, 1, 0)
EnableNamecall.TextScaled = true
EnableNamecall.TextSize = 14
EnableNamecall.TextWrapped = true
EnableNamecall.ZIndex = 100
EnableNamecallShadow.Name = "EnableNamecallShadow"
EnableNamecallShadow.Parent = NamecallMain
EnableNamecallShadow.BackgroundTransparency = 1
EnableNamecallShadow.Position = UDim2.new(0, 3, 0, 303)
EnableNamecallShadow.Size = UDim2.new(0, 200, 0, 30)
EnableNamecallShadow.ZIndex = 99
EnableNamecallShadow.Text = "Enable"
EnableNamecallShadow.TextColor3 = Color3.new(0, 0, 0)
EnableNamecallShadow.TextScaled = true
EnableNamecallShadow.TextSize = 14
EnableNamecallShadow.TextWrapped = true
DebugFrame.Name = "DebugFrame"
DebugFrame.Parent = MainFrame
DebugFrame.BackgroundColor3 = COLOR_SCHEME
DebugFrame.BorderSizePixel = 0
DebugFrame.Size = UDim2.new(1, 0, 1, 0)
DebugFrame.Visible = false
DebugLogsList.Name = "DebugLogsList"
DebugLogsList.Parent = DebugFrame
DebugLogsList.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
DebugLogsList.BorderSizePixel = 2
DebugLogsList.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
DebugLogsList.Size = UDim2.new(0, 200, 1, 0)
DebugLogsList.ScrollBarThickness = 0
DebugMain.Name = "DebugMain"
DebugMain.Parent = DebugFrame
DebugMain.AnchorPoint = Vector2.new(1, 0)
DebugMain.BackgroundTransparency = 1
DebugMain.Position = UDim2.new(1, 0, 0, 0)
DebugMain.Size = UDim2.new(1, -200, 1, 0)
CText.Name = "CText"
CText.Parent = DebugMain
CText.BackgroundTransparency = 1
CText.Position = UDim2.new(0, 230, 0, 0)
CText.Size = UDim2.new(0, 180, 0, 50)
CText.Text = "Constants:"
CText.TextColor3 = Color3.new(1, 1, 1)
CText.TextScaled = true
CText.TextSize = 14
CText.TextWrapped = true
CText.ZIndex = 100
UTextShadow.Name = "UTextShadow"
UTextShadow.Parent = DebugMain
UTextShadow.BackgroundTransparency = 1
UTextShadow.Position = UDim2.new(0, 28, 0, 3)
UTextShadow.Size = UDim2.new(0, 180, 0, 50)
UTextShadow.ZIndex = 99
UTextShadow.Text = "Upvalues:"
UTextShadow.TextColor3 = Color3.new(0, 0, 0)
UTextShadow.TextScaled = true
UTextShadow.TextSize = 14
UTextShadow.TextWrapped = true
ULogs.Name = "ULogs"
ULogs.Parent = DebugMain
ULogs.AnchorPoint = Vector2.new(0, 1)
ULogs.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
ULogs.BorderSizePixel = 2
ULogs.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
ULogs.Position = UDim2.new(0, 25, 1, 0)
ULogs.Size = UDim2.new(0, 180, 1, -50)
ULogs.ScrollBarThickness = 0
CLogs.Name = "CLogs"
CLogs.Parent = DebugMain
CLogs.AnchorPoint = Vector2.new(0, 1)
CLogs.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
CLogs.BorderSizePixel = 2
CLogs.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
CLogs.Position = UDim2.new(0, 230, 1, 0)
CLogs.Size = UDim2.new(0, 180, 1, -50)
CLogs.ScrollBarThickness = 0
UText.Name = "UText"
UText.Parent = DebugMain
UText.BackgroundTransparency = 1
UText.Position = UDim2.new(0, 25, 0, 0)
UText.Size = UDim2.new(0, 180, 0, 50)
UText.Text = "Upvalues:"
UText.TextColor3 = Color3.new(1, 1, 1)
UText.TextScaled = true
UText.TextSize = 14
UText.TextWrapped = true
UText.ZIndex = 100
EText.Name = "EText"
EText.Parent = DebugMain
EText.BackgroundTransparency = 1
EText.Position = UDim2.new(0, 435, 0, 0)
EText.Size = UDim2.new(0, 180, 0, 50)
EText.Text = "Env:"
EText.TextColor3 = Color3.new(1, 1, 1)
EText.TextScaled = true
EText.TextSize = 14
EText.TextWrapped = true
EText.ZIndex = 100
ELogs.Name = "ELogs"
ELogs.Parent = DebugMain
ELogs.AnchorPoint = Vector2.new(0, 1)
ELogs.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
ELogs.BorderSizePixel = 2
ELogs.BorderColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
ELogs.Position = UDim2.new(0, 435, 1, 0)
ELogs.Size = UDim2.new(0, 180, 1, -50)
ELogs.ScrollBarThickness = 0
ETextShadow.Name = "CTextShadow"
ETextShadow.Parent = DebugMain
ETextShadow.BackgroundTransparency = 1
ETextShadow.Position = UDim2.new(0, 438, 0, 3)
ETextShadow.Size = UDim2.new(0, 180, 0, 50)
ETextShadow.ZIndex = 99
ETextShadow.Text = "Env:"
ETextShadow.TextColor3 = Color3.new(0, 0, 0)
ETextShadow.TextScaled = true
ETextShadow.TextSize = 14
ETextShadow.TextWrapped = true
CTextShadow.Name = "CTextShadow"
CTextShadow.Parent = DebugMain
CTextShadow.BackgroundTransparency = 1
CTextShadow.Position = UDim2.new(0, 233, 0, 3)
CTextShadow.Size = UDim2.new(0, 180, 0, 50)
CTextShadow.ZIndex = 99
CTextShadow.Text = "Constants:"
CTextShadow.TextColor3 = Color3.new(0, 0, 0)
CTextShadow.TextScaled = true
CTextShadow.TextSize = 14
CTextShadow.TextWrapped = true
Darkness.Name = "Darkness"
Darkness.Parent = MainFrame
Darkness.BackgroundColor3 = Color3.new(0, 0, 0)
Darkness.BorderSizePixel = 0
Darkness.Size = UDim2.new(0, 0, 1, 0)
Darkness.ZIndex = 99999999
RemoteLog.Name = "RemoteLog"
RemoteLog.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-30,COLOR_SCHEME_RAW[2]-30,COLOR_SCHEME_RAW[3]-30)
RemoteLog.BackgroundTransparency = 0
RemoteLog.Size = UDim2.new(1, -2, 0, 30)
RemoteLog.Text = ""
RemoteLog.TextColor3 = Color3.new(1, 1, 0)
RemoteLog.BorderColor3 = Color3.new(1, 1, 0)
RemoteLog.BorderMode = Enum.BorderMode.Inset
RemoteLog.TextScaled = true
RemoteLog.TextWrapped = true
RemoteLog.ZIndex = 222221
RemoteLogShadow.Name = "RemoteLogShadow"
RemoteLogShadow.BackgroundTransparency = 1
RemoteLogShadow.Position = UDim2.new(0, 3, 0, 3)
RemoteLogShadow.Size = UDim2.new(1, 0, 0, 30)
RemoteLogShadow.ZIndex = 0
RemoteLogShadow.Text = "???"
RemoteLogShadow.TextColor3 = Color3.new(0, 0, 0)
RemoteLogShadow.TextScaled = true
RemoteLogShadow.TextWrapped = true
RemoteLogShadow.ZIndex = RemoteLog.ZIndex - 1
ValChangerFrame.Name = "ValChangerFrame"
ValChangerFrame.Visible = false
ValChangerFrame.Parent = SRS
ValChangerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ValChangerFrame.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
ValChangerFrame.BorderColor3 = Color3.new(0, 0, 0)
ValChangerFrame.BorderSizePixel = 3
ValChangerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
ValChangerFrame.Size = UDim2.new(0, 500, 0, 300)
ValChangerFrame.ZIndex = 999999
ChangerLabel.Name = "ChangerLabel"
ChangerLabel.Parent = ValChangerFrame
ChangerLabel.BackgroundTransparency = 1
ChangerLabel.Selectable = true
ChangerLabel.Size = UDim2.new(1, 0, 0, 50)
ChangerLabel.ZIndex = -1
ChangerLabel.Font = Enum.Font.SourceSans
ChangerLabel.Text = "X Changer"
ChangerLabel.TextColor3 = Color3.new(1, 1, 1)
ChangerLabel.TextScaled = true
ChangerLabel.TextSize = 14
ChangerLabel.TextWrapped = true
ChangerLabelShadow.Name = "ChangerLabelShadow"
ChangerLabelShadow.Parent = ValChangerFrame
ChangerLabelShadow.BackgroundTransparency = 1
ChangerLabelShadow.Position = UDim2.new(0, 3, 0, 3)
ChangerLabelShadow.Selectable = true
ChangerLabelShadow.Size = UDim2.new(1, 0, 0, 50)
ChangerLabelShadow.ZIndex = -1
ChangerLabelShadow.Font = Enum.Font.SourceSans
ChangerLabelShadow.Text = "X Changer"
ChangerLabelShadow.TextColor3 = Color3.new(0, 0, 0)
ChangerLabelShadow.TextScaled = true
ChangerLabelShadow.TextSize = 14
ChangerLabelShadow.TextWrapped = true
ValChangerBox.Name = "ValChangerBox"
ValChangerBox.Parent = ValChangerFrame
ValChangerBox.AnchorPoint = Vector2.new(0.5, 1)
ValChangerBox.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
ValChangerBox.BorderColor3 = Color3.new(0, 0, 0)
ValChangerBox.BorderSizePixel = 2
ValChangerBox.Position = UDim2.new(0.5, 0, 0.899999976, 0)
ValChangerBox.Size = UDim2.new(0.800000012, 0, 0, 50)
ValChangerBox.Font = Enum.Font.SourceSans
ValChangerBox.PlaceholderText = "Enter new value here"
ValChangerBox.Text = ""
ValChangerBox.TextColor3 = Color3.new(0, 0, 0)
ValChangerBox.TextSize = 20
ValChangerBox.ZIndex = -1
PrevValLabel.Name = "PrevValLabel"
PrevValLabel.Parent = ValChangerFrame
PrevValLabel.AnchorPoint = Vector2.new(0.5, 1)
PrevValLabel.BackgroundColor3 = Color3.fromRGB(COLOR_SCHEME_RAW[1]-20,COLOR_SCHEME_RAW[2]-20,COLOR_SCHEME_RAW[3]-20)
PrevValLabel.BorderColor3 = Color3.new(0, 0, 0)
PrevValLabel.BorderSizePixel = 2
PrevValLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
PrevValLabel.Size = UDim2.new(0.800000012, 0, 0, 50)
PrevValLabel.Font = Enum.Font.SourceSans
PrevValLabel.Text = "Loading..."
PrevValLabel.TextColor3 = Color3.new(0, 0, 0)
PrevValLabel.TextSize = 20
PrevValLabel.ZIndex = 0

--// Scripting //--

local GUI_OPENED = true
local GUI_MAX = true
local yo_chill = false
local UserInputService = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local OptionsOpened = false
local Debugs = {}
local IgnoredRemotes = {}
local SpiedScripts = {}
local ToClear = nil
local SelectedRemote
local SelectedRemoteArgs
local IgnoredCalls = {}
local SelectedNameCall
local OpenTween = ts:Create(ButtonsFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["AnchorPoint"] = Vector2.new(0,1),["Position"] = UDim2.new(0, -2, 1, 0)})
local CloseTween = ts:Create(ButtonsFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["AnchorPoint"] = Vector2.new(1,1),["Position"] = UDim2.new(0, -7, 1, 0)})
local DropOpenTween = ts:Create(Overlay,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Size"] = UDim2.new(1,0,1,0)})
local DropCloseTween = ts:Create(Overlay,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Size"] = UDim2.new(0,0,1,0)})
local BlackOpenTween = ts:Create(Darkness,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Size"] = UDim2.new(0,0,1,0)})
local BlackCloseTween = ts:Create(Darkness,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Size"] = UDim2.new(1,0,1,0)})
local MainOpenTween = ts:Create(AllFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Position"] = UDim2.new(0.5,0,0.5,0)})
local MainCloseTween = ts:Create(AllFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Position"] = UDim2.new(0.5,0,2,0)})
local MainCollapseTween = ts:Create(MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Position"] = UDim2.new(0,0,-1,0)})
local MainDecollapseTween = ts:Create(MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Position"] = UDim2.new(0,0,1,0)})
local button_options
button_options = {
	["Fire Remote"] = {
		[1] = {
			["Text"] = "Fire 10x",
			["Function"] = function()
				for i = 1,10 do
					if SelectedRemote then
				        if SelectedRemote:IsA("RemoteFunction") then
				            SelectedRemote:InvokeServer(unpack(SelectedRemoteArgs))
				        else
				            SelectedRemote:FireServer(unpack(SelectedRemoteArgs))
				        end
				    end
				end
			end
		},
		[2] = {
			["Text"] = "Fire 20x",
			["Function"] = function()
				for i = 1,20 do
					if SelectedRemote then
				        if SelectedRemote:IsA("RemoteFunction") then
				            SelectedRemote:InvokeServer(unpack(SelectedRemoteArgs))
				        else
				            SelectedRemote:FireServer(unpack(SelectedRemoteArgs))
				        end
				    end
				end
			end
		},
		[3] = {
			["Text"] = "Fire 50x",
			["Function"] = function()
				for i = 1,50 do
					if SelectedRemote then
				        if SelectedRemote:IsA("RemoteFunction") then
				            SelectedRemote:InvokeServer(unpack(SelectedRemoteArgs))
				        else
				            SelectedRemote:FireServer(unpack(SelectedRemoteArgs))
				        end
				    end
				end
			end
		}
	},
	["Function"] = {
		[1] = {
			["Text"] = "Copy",
			["Function"] = function(func)
				toclipboard(tostring(func))
			end
		},
		[2] = {
			["Text"] = "Decompile and Copy",
			["Function"] = function(func)
				if is_synapse_function(func) then return "Can't decompile synapse function!" end
				toclipboard(decompile(func))
			end
		},
		[3] = {
			["Text"] = "Send to Debug",
			["Function"] = function(func)
				local DebugTable = {
					["Name"] = tostring(func),
					["Function"] = func,
					["Upvalues"] = debug.getupvalues(func),
					["Constants"] = debug.getconstants(func)
				}
				button_options.DebugFunc[1].Function(DebugTable)
			end
		},
		[4] = {
			["Text"] = "To Script",
			["Function"] = function(func)
				local str = "local function ReturnFunc()\n    for i,v in pairs(getgc()) do\n        if type(v) == \"function\" and not is_synapse_function(v) and islclosure(v) then\n"
				str = str.."            if #debug.getupvalues(v) == "..tostring(#debug.getupvalues(func)).." and #debug.getconstants(v) == "..tostring(#debug.getconstants(func)) -- add more conds
				local capped_stuff = 0
				for i,v in pairs(debug.getconstants(func)) do
					if capped_stuff > 40 then break end
					if type(v) == "string" then
						str = str.." and debug.getconstants(v)["..tostring(i).."] == [["..tostring(v).."]]"
						capped_stuff = capped_stuff + 1
					elseif type(v) == "number" then
						str = str.." and debug.getconstants(v)["..tostring(i).."] == "..tostring(v)
						capped_stuff = capped_stuff + 1
					end
				end
				str = str.." then\n                return v\n            end\n"
				str = str.."        end\n    end\nend"
				toclipboard(str)
			end
		},
		[5] = {
			["Text"] = "Get Similar Functions",
			["Function"] = function(func)
				local found_funcs = {}
				for i,v in pairs(getgc()) do
					if type(v) == "function" and v ~= func and not is_synapse_function(v) and islclosure(v) and (#debug.getupvalues(v) == 0 or #debug.getconstants(v) == 0) then
						local dup = false
						for i2,v2 in pairs(found_funcs) do
							if v == v2 then
								dup = true
								break
							end
						end
						if not dup and not (tostring(getfenv(v)["script"]) ~= tostring(getfenv(func)["script"])) then
							table.insert(found_funcs,v)
						end
						for i2,v2 in pairs(debug.getupvalues(v)) do
							if type(v2) == "function" and not is_synapse_function(v2) and islclosure(v2) and tostring(v2) ~= tostring(func) then
								if not (tostring(getfenv(v2)["script"]) ~= tostring(getfenv(func)["script"])) then
									table.insert(found_funcs,v2)
								end
							elseif type(v2) == "table" then
								local rec
								rec = function(tbl,N)
									if type(N) == "number" and N > 5 then return end
									if not N then N = 0 end
									for i3,v3 in pairs(tbl) do
										if type(v3) == "function" and v3 ~= func and not is_synapse_function(v3) and islclosure(v3) and (#debug.getupvalues(v3) == 0 or #debug.getconstants(v3) == 0) then
											if not (tostring(getfenv(v3)["script"]) ~= tostring(getfenv(func)["script"])) then
												table.insert(found_funcs,v3)
											end
										elseif type(v) == "table" then
											rec(v,N+1)
										end
									end
								end
								rec(v2,0)
							end
						end
						for i2,v2 in pairs(debug.getconstants(v)) do
							if type(v2) == "function" and not is_synapse_function(v2) and islclosure(v2) and tostring(v2) ~= tostring(func) then
								if not (tostring(getfenv(v2)["script"]) ~= tostring(getfenv(func)["script"])) then
									table.insert(found_funcs,v2)
								end
							elseif type(v2) == "table" then
								local rec
								rec = function(tbl,N)
									if type(N) == "number" and N > 5 then return end
									if not N then N = 0 end
									for i3,v3 in pairs(tbl) do
										if type(v3) == "function" and v3 ~= func and not is_synapse_function(v3) and islclosure(v3) and (#debug.getupvalues(v3) == 0 or #debug.getconstants(v3) == 0) then
											if not (tostring(getfenv(v3)["script"]) ~= tostring(getfenv(func)["script"])) then
												table.insert(found_funcs,v3)
											end
										elseif type(v) == "table" then
											rec(v,N+1)
										end
									end
								end
								rec(v2,0)
							end
						end
					end
				end
				for i,v in pairs(found_funcs) do
					local DebugTable = {
						["Name"] = tostring(v),
						["Function"] = v,
						["Upvalues"] = debug.getupvalues(v),
						["Constants"] = debug.getconstants(v)
					}
					button_options.DebugFunc[1].Function(DebugTable)
				end
			end
		}
	},
	["DebugVal"] = {
		[1] = {
			["Text"] = "Copy",
			["Function"] = function(val,func)
				if type(val) == "string" then
					toclipboard([["]]..tostring(val)..[["]])
				elseif type(val) == "table" then
					toclipboard(TableString(val))
				elseif typeof(val) == "Instance" then
					toclipboard(val:GetFullName())
				else
					toclipboard(tostring(val))
				end
			end
		},
		[2] = {
			["Text"] = "Debug Func",
			["Function"] = function(val,func)
				local DebugTable = {
					["Name"] = tostring(func),
					["Function"] = func,
					["Upvalues"] = debug.getupvalues(func),
					["Constants"] = debug.getconstants(func)
				}
				local newfunc = RemoteLog:Clone()
	            newfunc.TextColor3 = Color3.new(0,1,1)
	            newfunc.BorderColor3 = Color3.new(0,1,1)
		    	local f_name
		    	pcall(function()
		    		f_name = debug.getinfo(func).name
		    	end)
		    	if f_name and type(f_name) == "string" and #f_name > 0 then
		    		for i,v in pairs(getrenv()) do
		    			if v == func then
		    				f_name = "getrenv()."..f_name
		    				break
		    			end
		    		end
		    		newfunc.Text = f_name.."()"
		    	else
		    		newfunc.Text = tostring(func)
		    	end
		    	if not islclosure(func) then
		    		newfunc.Text = newfunc.Text.." [C]"
		    	end
	            local others2 = #DebugLogsList:GetChildren()
	            newfunc.Position = UDim2.new(0,0,0,others2*31)
	            DebugLogsList.CanvasSize = UDim2.new(0,0,0,others2*31)
	            newfunc.MouseButton1Click:Connect(function()
	            	ClickSound:Play()
	            	TweenButtonPress(newfunc)
	                for x,y in pairs(CLogs:GetChildren()) do
	                    y:Destroy()
	                end
	                for x,y in pairs(ULogs:GetChildren()) do
	                    y:Destroy()
	                end
	                for x,y in pairs(ELogs:GetChildren()) do
	                    y:Destroy()
	                end
	                if DebugTable then
	                    for a,b in pairs(debug.getconstants(DebugTable.Function)) do
	                        local thingo = RemoteLog:Clone()
	                        thingo.TextColor3 = Color3.new(0,1,1)
	                        thingo.BorderColor3 = Color3.new(0,1,1)
	                        if type(b) == "string" then
	                            thingo.Text = [["]]..tostring(b)..[["]]
	                        elseif type(b) == "function" then
	                        	local f_name
	                        	pcall(function()
	                        		f_name = debug.getinfo(b).name
	                        	end)
	                        	if f_name and type(f_name) == "string" and #f_name > 0 then
	                        		for i,v in pairs(getrenv()) do
	                        			if v == b then
	                        				f_name = "getrenv()."..f_name
	                        				break
	                        			end
	                        		end
	                        		thingo.Text = f_name.."()"
	                        	else
	                        		thingo.Text = tostring(b)
	                        	end
	                        	if not islclosure(b) then
	                        		thingo.Text = thingo.Text.." [C]"
	                        	end
	                        else
	                        	thingo.Text = tostring(b)
	                        end
	                        local others3 = #CLogs:GetChildren()
	                        thingo.Position = UDim2.new(0,0,0,others3*31)
	                        thingo.Parent = CLogs
	                        CLogs.CanvasSize = UDim2.new(0,0,0,others3*31)
	                        thingo.MouseButton1Click:Connect(function()
	                        	ClickSound:Play()
	                        	TweenButtonPress(thingo)
	                        	ValChanger("Constant",a,b,DebugTable.Function,type(b))
	                        end)
	                        thingo.MouseButton2Click:Connect(function()
	                        	ClickSound2:Play()
								if type(b) == "function" then
									RightClick(thingo,"Function",b)
								else
									RightClick(thingo,"DebugVal",b,DebugTable.Function)
								end
	                        end)
	                        thingo.MouseEnter:Connect(function()
								EnterSound:Play()
								for i,v in pairs(DarkButtons) do
									if v[1] == thingo then
										return
									end
								end
								table.insert(DarkButtons,{thingo,thingo.TextColor3})
								local colors = {thingo.TextColor3.R-0.4,thingo.TextColor3.G-0.4,thingo.TextColor3.B-0.4}
								for i,v in pairs(colors) do
									if v < 0 then
										colors[i] = 0
									end
								end
								thingo.TextColor3 = Color3.new(unpack(colors))
							end)
							thingo.MouseLeave:Connect(function()
								for i,v in pairs(DarkButtons) do
									if v[1] == thingo then
										thingo.TextColor3 = v[2]
										table.remove(DarkButtons,i)
										break
									end
								end
							end)
	                    end
	                    if type(getfenv(DebugTable.Function)) == "table" then
		                    for a,b in pairs(getfenv(DebugTable.Function)) do
		                        local thingo = RemoteLog:Clone()
		                        thingo.TextColor3 = Color3.new(0,1,1)
		                        thingo.BorderColor3 = Color3.new(0,1,1)
		                        if type(b) == "string" then
		                            thingo.Text = tostring(a)..[[: "]]..tostring(b)..[["]]
		                        elseif type(b) == "function" then
		                        	local f_name
		                        	pcall(function()
		                        		f_name = debug.getinfo(b).name
		                        	end)
		                        	if f_name and type(f_name) == "string" and #f_name > 0 then
		                        		for i,v in pairs(getrenv()) do
		                        			if v == b then
		                        				f_name = "getrenv()."..f_name
		                        				break
		                        			end
		                        		end
		                        		thingo.Text = f_name.."()"
		                        	else
		                        		thingo.Text = tostring(b)
		                        	end
		                        	if not islclosure(b) then
		                        		thingo.Text = thingo.Text.." [C]"
		                        	end
		                        else
		                        	thingo.Text = tostring(a)..": "..tostring(b)
		                        end
		                        local others3 = #ELogs:GetChildren()
		                        thingo.Position = UDim2.new(0,0,0,others3*31)
		                        thingo.Parent = ELogs
		                        ELogs.CanvasSize = UDim2.new(0,0,0,others3*31)
		                        thingo.MouseButton1Click:Connect(function()
		                        	ClickSound:Play()
		                        	TweenButtonPress(thingo)
		                        	ValChanger("Env",a,b,DebugTable.Function,type(b))
		                        end)
		                        thingo.MouseButton2Click:Connect(function()
		                        	ClickSound2:Play()
									if type(b) == "function" then
										RightClick(thingo,"Function",b)
									else
										RightClick(thingo,"DebugVal",b,DebugTable.Function)
									end
		                        end)
		                        thingo.MouseEnter:Connect(function()
									EnterSound:Play()
									for i,v in pairs(DarkButtons) do
										if v[1] == thingo then
											return
										end
									end
									table.insert(DarkButtons,{thingo,thingo.TextColor3})
									local colors = {thingo.TextColor3.R-0.4,thingo.TextColor3.G-0.4,thingo.TextColor3.B-0.4}
									for i,v in pairs(colors) do
										if v < 0 then
											colors[i] = 0
										end
									end
									thingo.TextColor3 = Color3.new(unpack(colors))
								end)
								thingo.MouseLeave:Connect(function()
									for i,v in pairs(DarkButtons) do
										if v[1] == thingo then
											thingo.TextColor3 = v[2]
											table.remove(DarkButtons,i)
											break
										end
									end
								end)
		                    end
						end
	                    for a,b in pairs(debug.getupvalues(DebugTable.Function)) do
	                        local thingo = RemoteLog:Clone()
	                        thingo.TextColor3 = Color3.new(0,1,1)
	                        thingo.BorderColor3 = Color3.new(0,1,1)
	                        if type(b) == "string" then
	                            thingo.Text = [["]]..tostring(b)..[["]]
	                        elseif type(b) == "function" then
	                        	local f_name
	                        	pcall(function()
	                        		f_name = debug.getinfo(b).name
	                        	end)
	                        	if f_name and type(f_name) == "string" and #f_name > 0 then
	                        		for i,v in pairs(getrenv()) do
	                        			if v == b then
	                        				f_name = "getrenv()."..f_name
	                        				break
	                        			end
	                        		end
	                        		thingo.Text = f_name.."()"
	                        	else
	                        		thingo.Text = tostring(b)
	                        	end
	                        	if not islclosure(b) then
	                        		thingo.Text = thingo.Text.." [C]"
	                        	end
	                        else
	                        	thingo.Text = tostring(b)
	                        end
	                        local others3 = #ULogs:GetChildren()
	                        thingo.Position = UDim2.new(0,0,0,others3*31)
	                        thingo.Parent = ULogs
	                        ULogs.CanvasSize = UDim2.new(0,0,0,others3*31)
	                        thingo.MouseButton1Click:Connect(function()
	                        	ClickSound:Play()
	                        	TweenButtonPress(thingo)
	                        	ValChanger("Upvalue",a,b,DebugTable.Function,type(b))
	                        end)
	                        thingo.MouseButton2Click:Connect(function()
	                        	ClickSound2:Play()
								if type(b) == "function" then
									RightClick(thingo,"Function",b)
								else
									RightClick(thingo,"DebugVal",b,DebugTable.Function)
								end
	                        end)
	                        thingo.MouseEnter:Connect(function()
								EnterSound:Play()
								for i,v in pairs(DarkButtons) do
									if v[1] == thingo then
										return
									end
								end
								table.insert(DarkButtons,{thingo,thingo.TextColor3})
								local colors = {thingo.TextColor3.R-0.4,thingo.TextColor3.G-0.4,thingo.TextColor3.B-0.4}
								for i,v in pairs(colors) do
									if v < 0 then
										colors[i] = 0
									end
								end
								thingo.TextColor3 = Color3.new(unpack(colors))
							end)
							thingo.MouseLeave:Connect(function()
								for i,v in pairs(DarkButtons) do
									if v[1] == thingo then
										thingo.TextColor3 = v[2]
										table.remove(DarkButtons,i)
										break
									end
								end
							end)
	                    end
	                else
	                    --
	                end
	            end)
				newfunc.MouseEnter:Connect(function()
					EnterSound:Play()
					for i,v in pairs(DarkButtons) do
						if v[1] == newfunc then
							return
						end
					end
					table.insert(DarkButtons,{newfunc,newfunc.TextColor3})
					local colors = {newfunc.TextColor3.R-0.4,newfunc.TextColor3.G-0.4,newfunc.TextColor3.B-0.4}
					for i,v in pairs(colors) do
						if v < 0 then
							colors[i] = 0
						end
					end
					newfunc.TextColor3 = Color3.new(unpack(colors))
				end)
				newfunc.MouseLeave:Connect(function()
					for i,v in pairs(DarkButtons) do
						if v[1] == newfunc then
							newfunc.TextColor3 = v[2]
							table.remove(DarkButtons,i)
							break
						end
					end
				end)
				newfunc.MouseButton2Click:Connect(function()
					ClickSound2:Play()
					RightClick(newfunc,"Function",DebugTable.Function)
				end)
	            newfunc.Parent = DebugLogsList
			end
		}
	},
	["DebugFunc"] = {
		[1] = {
			["Text"] = "Send to Debug",
			["Function"] = function(DebugTable)
				local newfunc = RemoteLog:Clone()
	            newfunc.TextColor3 = Color3.new(0,1,1)
	            newfunc.BorderColor3 = Color3.new(0,1,1)
            	local f_name
            	pcall(function()
            		f_name = debug.getinfo(DebugTable.Function).name
            	end)
            	if f_name and type(f_name) == "string" and #f_name > 0 then
            		for i,v in pairs(getrenv()) do
            			if v == DebugTable.Function then
            				f_name = "getrenv()."..f_name
            				break
            			end
            		end
            		newfunc.Text = f_name.."()"
            	else
            		newfunc.Text = tostring(DebugTable.Function)
            	end
            	if not islclosure(DebugTable.Function) then
            		newfunc.Text = newfunc.Text.." [C]"
            	end
	            local others2 = #DebugLogsList:GetChildren()
	            newfunc.Position = UDim2.new(0,0,0,others2*31)
	            DebugLogsList.CanvasSize = UDim2.new(0,0,0,others2*31)
	            newfunc.MouseButton1Click:Connect(function()
	            	ClickSound:Play()
	            	TweenButtonPress(newfunc)
	                for x,y in pairs(CLogs:GetChildren()) do
	                    y:Destroy()
	                end
	                for x,y in pairs(ULogs:GetChildren()) do
	                    y:Destroy()
	                end
	                for x,y in pairs(ELogs:GetChildren()) do
	                    y:Destroy()
	                end
	                if DebugTable then
	                    for a,b in pairs(debug.getconstants(DebugTable.Function)) do
	                        local thingo = RemoteLog:Clone()
	                        thingo.TextColor3 = Color3.new(0,1,1)
	                        thingo.BorderColor3 = Color3.new(0,1,1)
	                        if type(b) == "string" then
	                            thingo.Text = [["]]..tostring(b)..[["]]
	                        elseif type(b) == "function" then
	                        	local f_name
	                        	pcall(function()
	                        		f_name = debug.getinfo(b).name
	                        	end)
	                        	if f_name and type(f_name) == "string" and #f_name > 0 then
	                        		for i,v in pairs(getrenv()) do
	                        			if v == b then
	                        				f_name = "getrenv()."..f_name
	                        				break
	                        			end
	                        		end
	                        		thingo.Text = f_name.."()"
	                        	else
	                        		thingo.Text = tostring(b)
	                        	end
	                        	if not islclosure(b) then
	                        		thingo.Text = thingo.Text.." [C]"
	                        	end
	                        else
	                        	thingo.Text = tostring(b)
	                        end
	                        local others3 = #CLogs:GetChildren()
	                        thingo.Position = UDim2.new(0,0,0,others3*31)
	                        thingo.Parent = CLogs
	                        CLogs.CanvasSize = UDim2.new(0,0,0,others3*31)
	                        thingo.MouseButton1Click:Connect(function()
	                        	ClickSound:Play()
	                        	TweenButtonPress(thingo)
	                        	ValChanger("Constant",a,b,DebugTable.Function,type(b))
	                        end)
	                        thingo.MouseButton2Click:Connect(function()
	                        	ClickSound2:Play()
								if type(b) == "function" then
									RightClick(thingo,"Function",b)
								else
									RightClick(thingo,"DebugVal",b,DebugTable.Function)
								end
	                        end)
	                        thingo.MouseEnter:Connect(function()
								EnterSound:Play()
								for i,v in pairs(DarkButtons) do
									if v[1] == thingo then
										return
									end
								end
								table.insert(DarkButtons,{thingo,thingo.TextColor3})
								local colors = {thingo.TextColor3.R-0.4,thingo.TextColor3.G-0.4,thingo.TextColor3.B-0.4}
								for i,v in pairs(colors) do
									if v < 0 then
										colors[i] = 0
									end
								end
								thingo.TextColor3 = Color3.new(unpack(colors))
							end)
							thingo.MouseLeave:Connect(function()
								for i,v in pairs(DarkButtons) do
									if v[1] == thingo then
										thingo.TextColor3 = v[2]
										table.remove(DarkButtons,i)
										break
									end
								end
							end)
	                    end
	                    if type(getfenv(DebugTable.Function)) == "table" then
		                    for a,b in pairs(getfenv(DebugTable.Function)) do
		                        local thingo = RemoteLog:Clone()
		                        thingo.TextColor3 = Color3.new(0,1,1)
		                        thingo.BorderColor3 = Color3.new(0,1,1)
		                        if type(b) == "string" then
		                            thingo.Text = [["]]..tostring(b)..[["]]
		                        elseif type(b) == "function" then
		                        	local f_name
		                        	pcall(function()
		                        		f_name = debug.getinfo(b).name
		                        	end)
		                        	if f_name and type(f_name) == "string" and #f_name > 0 then
		                        		for i,v in pairs(getrenv()) do
		                        			if v == b then
		                        				f_name = "getrenv()."..f_name
		                        				break
		                        			end
		                        		end
		                        		thingo.Text = f_name.."()"
		                        	else
		                        		thingo.Text = tostring(b)
		                        	end
		                        	if not islclosure(b) then
		                        		thingo.Text = thingo.Text.." [C]"
		                        	end
		                        else
		                        	thingo.Text = tostring(b)
		                        end
		                        local others3 = #ELogs:GetChildren()
		                        thingo.Position = UDim2.new(0,0,0,others3*31)
		                        thingo.Parent = ELogs
		                        ELogs.CanvasSize = UDim2.new(0,0,0,others3*31)
		                        thingo.MouseButton1Click:Connect(function()
		                        	ClickSound:Play()
		                        	TweenButtonPress(thingo)
		                        	ValChanger("Env",a,b,DebugTable.Function,type(b))
		                        end)
		                        thingo.MouseButton2Click:Connect(function()
		                        	ClickSound2:Play()
									if type(b) == "function" then
										RightClick(thingo,"Function",b)
									else
										RightClick(thingo,"DebugVal",b,DebugTable.Function)
									end
		                        end)
		                        thingo.MouseEnter:Connect(function()
									EnterSound:Play()
									for i,v in pairs(DarkButtons) do
										if v[1] == thingo then
											return
										end
									end
									table.insert(DarkButtons,{thingo,thingo.TextColor3})
									local colors = {thingo.TextColor3.R-0.4,thingo.TextColor3.G-0.4,thingo.TextColor3.B-0.4}
									for i,v in pairs(colors) do
										if v < 0 then
											colors[i] = 0
										end
									end
									thingo.TextColor3 = Color3.new(unpack(colors))
								end)
								thingo.MouseLeave:Connect(function()
									for i,v in pairs(DarkButtons) do
										if v[1] == thingo then
											thingo.TextColor3 = v[2]
											table.remove(DarkButtons,i)
											break
										end
									end
								end)
		                    end
						end
	                    for a,b in pairs(debug.getupvalues(DebugTable.Function)) do
	                        local thingo = RemoteLog:Clone()
	                        thingo.TextColor3 = Color3.new(0,1,1)
	                        thingo.BorderColor3 = Color3.new(0,1,1)
	                        if type(b) == "string" then
	                            thingo.Text = [["]]..tostring(b)..[["]]
	                        elseif type(b) == "function" then
	                        	local f_name
	                        	pcall(function()
	                        		f_name = debug.getinfo(b).name
	                        	end)
	                        	if f_name and type(f_name) == "string" and #f_name > 0 then
	                        		for i,v in pairs(getrenv()) do
	                        			if v == b then
	                        				f_name = "getrenv()."..f_name
	                        				break
	                        			end
	                        		end
	                        		thingo.Text = f_name.."()"
	                        	else
	                        		thingo.Text = tostring(b)
	                        	end
	                        	if not islclosure(b) then
	                        		thingo.Text = thingo.Text.." [C]"
	                        	end
	                        else
	                        	thingo.Text = tostring(b)
	                        end
	                        local others3 = #ULogs:GetChildren()
	                        thingo.Position = UDim2.new(0,0,0,others3*31)
	                        thingo.Parent = ULogs
	                        ULogs.CanvasSize = UDim2.new(0,0,0,others3*31)
	                        thingo.MouseButton1Click:Connect(function()
	                        	ClickSound:Play()
	                        	TweenButtonPress(thingo)
	                        	ValChanger("Upvalue",a,b,DebugTable.Function,type(b))
	                        end)
	                        thingo.MouseButton2Click:Connect(function()
	                        	ClickSound2:Play()
								if type(b) == "function" then
									RightClick(thingo,"Function",b)
								else
									RightClick(thingo,"DebugVal",b,DebugTable.Function)
								end
	                        end)
	                        thingo.MouseEnter:Connect(function()
								EnterSound:Play()
								for i,v in pairs(DarkButtons) do
									if v[1] == thingo then
										return
									end
								end
								table.insert(DarkButtons,{thingo,thingo.TextColor3})
								local colors = {thingo.TextColor3.R-0.4,thingo.TextColor3.G-0.4,thingo.TextColor3.B-0.4}
								for i,v in pairs(colors) do
									if v < 0 then
										colors[i] = 0
									end
								end
								thingo.TextColor3 = Color3.new(unpack(colors))
							end)
							thingo.MouseLeave:Connect(function()
								for i,v in pairs(DarkButtons) do
									if v[1] == thingo then
										thingo.TextColor3 = v[2]
										table.remove(DarkButtons,i)
										break
									end
								end
							end)
	                    end
	                else
	                    --
	                end
	            end)
				newfunc.MouseEnter:Connect(function()
					EnterSound:Play()
					for i,v in pairs(DarkButtons) do
						if v[1] == newfunc then
							return
						end
					end
					table.insert(DarkButtons,{newfunc,newfunc.TextColor3})
					local colors = {newfunc.TextColor3.R-0.4,newfunc.TextColor3.G-0.4,newfunc.TextColor3.B-0.4}
					for i,v in pairs(colors) do
						if v < 0 then
							colors[i] = 0
						end
					end
					newfunc.TextColor3 = Color3.new(unpack(colors))
				end)
				newfunc.MouseLeave:Connect(function()
					for i,v in pairs(DarkButtons) do
						if v[1] == newfunc then
							newfunc.TextColor3 = v[2]
							table.remove(DarkButtons,i)
							break
						end
					end
				end)
				newfunc.MouseButton2Click:Connect(function()
					ClickSound2:Play()
					RightClick(newfunc,"Function",DebugTable.Function)
				end)
	            newfunc.Parent = DebugLogsList
			end
		}
	}
}
local function GetOptions(button)
	return button_options[button]
end
UserInputService.InputBegan:Connect(function(Tinfo,bool)
	if bool then return end
	if yo_chill then return end
    if Tinfo.KeyCode == Enum.KeyCode.F8 then
    	yo_chill = true
        if GUI_OPENED then
            GUI_OPENED = false
            MainCloseTween:Play()
        else
            GUI_OPENED = true
            MainOpenTween:Play()
        end
        spawn(function()
        	wait(0.5)
        	yo_chill = false
        end)
    end
    if Tinfo.KeyCode == Enum.KeyCode.F6 then
    	yo_chill = true
        if GUI_MAX then
            GUI_MAX = false
            MainCollapseTween:Play()
            wait(0.3)
            MainFrame.Visible = false
            ts:Create(AllFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Size"] = UDim2.new(0,850,0,40),["Position"] = AllFrame.Position - UDim2.new(0,0,0,(370-40)/2)}):Play()
            wait(0.5)
        else
            GUI_MAX = true
            ts:Create(AllFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Size"] = UDim2.new(0,850,0,370),["Position"] = AllFrame.Position + UDim2.new(0,0,0,(370-40)/2)}):Play()
            wait(0.3)
            MainFrame.Visible = true
            MainDecollapseTween:Play()
            wait(0.5)
        end
        spawn(function()
        	wait(0.5)
        	yo_chill = false
        end)
    end
end)
Options.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(Options)
    if OptionsOpened == false then
        OptionsOpened = true
        OpenTween:Play()
        DropOpenTween:Play()
    else
        OptionsOpened = false
        CloseTween:Play()
        DropCloseTween:Play()
    end
end)
Options.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == Options then
			return
		end
	end
	table.insert(DarkButtons,{Options,Options.TextColor3})
	local colors = {Options.TextColor3.R-0.4,Options.TextColor3.G-0.4,Options.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	Options.TextColor3 = Color3.new(unpack(colors))
end)
Options.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == Options then
			Options.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
local HasSpecial = function(str)
    return (string.match(str,"%c") or string.match(str,"%s") or string.match(str,"%p")) ~= nil
end
local ToScript = function(object,scr,fnc,method, ...)
    local script = "--// Script: "..GetPath(scr)
    local f_name = tostring(fnc)
    pcall(function()
    	if type(debug.getinfo(fnc).name) == "string" and #debug.getinfo(fnc).name > 0 then
    		f_name = debug.getinfo(fnc).name
    	end
    end)
    script = script.."\n--// Function: "..f_name.."\n\n"
    local args = {}
    local stuff_idk = {...}
    for i = 1,#stuff_idk do
    	v = stuff_idk[i]
        script = script.."local v"..tostring(i).." = "
        if type(v) == "table" then
        	if getrawmetatable(v) then
        		local new_secure_table = {}
        		for i2,v2 in pairs(v) do
        			new_secure_table[i2] = v2
        		end
        		script = script..TableString(new_secure_table)
        	else
        		script = script..TableString(v)
        	end
        else
            script = script..GetType(v)
        end
        script = script.."\n"
        table.insert(args, "v" .. i)
    end
    if string.find(string.lower(object.ClassName),"remote") or string.find(string.lower(object.ClassName),"bindable") then
    	script = script .. "local rem = " .. GetPath(object) .. "\n\n"
    else
    	script = script .. "local thing = " .. GetPath(object) .. "\n\n"
    end
    if string.find(string.lower(object.ClassName),"remote") or string.find(string.lower(object.ClassName),"bindable") then
    	script = script .. "rem:" .. method .. "(" .. table.concat(args, ", ") .. ")"
    else
    	script = script .. "thing:" .. method .. "(" .. table.concat(args, ", ") .. ")"
    end
    return script
end
local function IsIgnored(rem13)
    if rem13 then
        for jk,kl in pairs(IgnoredRemotes) do
            if rem13 == kl then
                return true
            end
        end
    end
    return false
end
local function AreTheSameTables(tbl1,tbl2)
    if #tbl1 ~= #tbl2 then return false end
    for i,v in pairs(tbl1) do
        if type(v) == "number" or type(v) == "string" then
            if v ~= tbl2[i] then
                return false
            end
        end
    end
    return true
end
RightClick = function(Button,wat,...)
	local passed_stuff = {...}
	if old_rc_frame then
		old_rc_frame:Destroy()
	end
	local options = GetOptions(wat)
	local rc_frame = RightClickFrame:Clone()
	old_rc_frame = rc_frame
	rc_frame.Position = UDim2.new(0,GetMouse().X,0,GetMouse().Y)
	rc_frame.Parent = SRS
	ts:Create(rc_frame,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Size"] = UDim2.new(0,200,0,#options*30)}):Play()
	wait(0.2)
	for i,v in pairs(options) do
		local chs = RemoteLog:Clone()
		chs.Text = v["Text"]
		chs.ZIndex = 21000001
		chs.Position = UDim2.new(0,0,0,i*30-30)
		chs.TextColor3 = Color3.new(1,1,1)
		chs.BorderColor3 = Color3.new(1,1,1)
		chs.MouseButton1Click:Connect(function()
			ClickSound:Play()
			TweenButtonPress(chs)
			rc_frame:Destroy()
			v["Function"](unpack(passed_stuff))
		end)
		chs.Parent = rc_frame
	end
	ts:Create(rc_frame.Hider,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0),{["Size"] = UDim2.new(1,0,0,0)}):Play()
	wait(0.1)
	rc_frame.Hider:Destroy()
end
local UpdateRemotes
UpdateRemotes = function()

    local lastPos = -35
    local amount = 0
    for i,v in pairs(RemotesList:GetChildren()) do v:Destroy() end
    local insts = {}
    local FindRemotes
	FindRemotes = function(thing,already)
		local rems = (type(already) == "table" and already) or {}
		for i,v in pairs(thing:GetChildren()) do
			if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
				table.insert(insts,v)
			end
			FindRemotes(v)
		end
	end
	FindRemotes(game)
    for i,v in pairs(insts) do
    	if not typeof(v) == "Instance" or v:IsDescendantOf(game:GetService("RobloxReplicatedStorage")) then continue end
        pcall(function()
            if v:IsA("RemoteEvent") then
                local new = RemoteLog:Clone()
                new.Position = UDim2.new(0,0,0,lastPos + 35)
                new.Text = v:GetFullName()
                if IsIgnored(v) then
                    new.TextColor3 = Color3.fromRGB(100,100,100)
                    new.BorderColor3 = Color3.fromRGB(100,100,100)
                end
                lastPos = lastPos + 35
                amount = amount + 1
                new.MouseButton1Click:Connect(function()
                	ClickSound:Play()
                	TweenButtonPress(new)
                    if not IsIgnored(v) then
                        table.insert(IgnoredRemotes,v)
                        UpdateRemotes()
                    else
                        for a,b in pairs(IgnoredRemotes) do
                            if b == v then
                                IgnoredRemotes[a] = nil
                            end
                        end
                        UpdateRemotes()
                    end
                end)
				new.MouseEnter:Connect(function()
					EnterSound:Play()
					for i,v in pairs(DarkButtons) do
						if v[1] == new then
							return
						end
					end
					table.insert(DarkButtons,{new,new.TextColor3})
					local colors = {new.TextColor3.R-0.4,new.TextColor3.G-0.4,new.TextColor3.B-0.4}
					for i,v in pairs(colors) do
						if v < 0 then
							colors[i] = 0
						end
					end
					new.TextColor3 = Color3.new(unpack(colors))
				end)
				new.MouseLeave:Connect(function()
					for i,v in pairs(DarkButtons) do
						if v[1] == new then
							new.TextColor3 = v[2]
							table.remove(DarkButtons,i)
							break
						end
					end
				end)
                new.Parent = RemotesList
            end
            if v:IsA("RemoteFunction") then
                local new = RemoteLog:Clone()
                new.TextColor3 = Color3.new(1,0,1)
                new.BorderColor3 = Color3.new(1,0,1)
                new.Position = UDim2.new(0,0,0,lastPos + 35)
                new.Text = v:GetFullName()
                if IsIgnored(v) then
                    new.TextColor3 = Color3.fromRGB(100,100,100)
                    new.BorderColor3 = Color3.fromRGB(100,100,100)
                end
                lastPos = lastPos + 35
                amount = amount + 1
                new.MouseButton1Click:Connect(function()
                	ClickSound:Play()
                	TweenButtonPress(new)
                    if not IsIgnored(v) then
                        table.insert(IgnoredRemotes,v)
                        UpdateRemotes()
                    else
                        for a,b in pairs(IgnoredRemotes) do
                            if b == v then
                                IgnoredRemotes[a] = nil
                            end
                        end
                        UpdateRemotes()
                    end
                end)
                new.MouseEnter:Connect(function()
					EnterSound:Play()
					for i,v in pairs(DarkButtons) do
						if v[1] == new then
							return
						end
					end
					table.insert(DarkButtons,{new,new.TextColor3})
					local colors = {new.TextColor3.R-0.4,new.TextColor3.G-0.4,new.TextColor3.B-0.4}
					for i,v in pairs(colors) do
						if v < 0 then
							colors[i] = 0
						end
					end
					new.TextColor3 = Color3.new(unpack(colors))
				end)
				new.MouseLeave:Connect(function()
					for i,v in pairs(DarkButtons) do
						if v[1] == new then
							new.TextColor3 = v[2]
							table.remove(DarkButtons,i)
							break
						end
					end
				end)
                new.Parent = RemotesList
            end
        end)
    end
    RemotesList.CanvasSize = UDim2.new(0,0,0,amount*35)
end
local function UpdateNamecalls()

    local lastPos = -35
    local amount = 0
    for i,v in pairs(NamecallLogsList:GetChildren()) do
        v:Destroy()
    end
    for i,v in pairs(IgnoredCalls) do
        local new = RemoteLog:Clone()
        new.BorderColor3 = Color3.fromRGB(230,139,27)
        new.TextColor3 = Color3.fromRGB(230,139,27)
        new.Position = UDim2.new(0,0,0,lastPos + 35)
        new.Text = tostring(v["Remote"])
        lastPos = lastPos + 35
        amount = amount + 1
        new.MouseButton1Click:Connect(function()
            SelectedNameCall = i
            NamecallText.Text = v["Text"]
            ClickSound:Play()
            TweenButtonPress(new)
        end)
        new.MouseEnter:Connect(function()
			EnterSound:Play()
			for i,v in pairs(DarkButtons) do
				if v[1] == new then
					return
				end
			end
			table.insert(DarkButtons,{new,new.TextColor3})
			local colors = {new.TextColor3.R-0.4,new.TextColor3.G-0.4,new.TextColor3.B-0.4}
			for i,v in pairs(colors) do
				if v < 0 then
					colors[i] = 0
				end
			end
			new.TextColor3 = Color3.new(unpack(colors))
		end)
		new.MouseLeave:Connect(function()
			for i,v in pairs(DarkButtons) do
				if v[1] == new then
					new.TextColor3 = v[2]
					table.remove(DarkButtons,i)
					break
				end
			end
		end)
        new.Parent = NamecallLogsList
    end
end
local function ChangeFrame(frm)
	ChangerFrame.Visible = false
    HomeFrame.Visible = false
    DebugFrame.Visible = false
    RemotesFrame.Visible = false
    NamecallFrame.Visible = false
    RemoteSpyFrame.Visible = false
    ScriptSpyFrame.Visible = false
    frm.Visible = true
end
local function Transition(bool)
    if bool then
        BlackCloseTween:Play()
        ChangeSound:Play()
    else
        BlackOpenTween:Play()
    end
end
Clear.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(Clear)
    if typeof(ToClear) == "Instance" then
        for i,v in pairs(ToClear:GetChildren()) do
            v:Destroy()
        end
    end
end)
Clear.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == Clear then
			return
		end
	end
	table.insert(DarkButtons,{Clear,Clear.TextColor3})
	local colors = {Clear.TextColor3.R-0.4,Clear.TextColor3.G-0.4,Clear.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	Clear.TextColor3 = Color3.new(unpack(colors))
end)
Clear.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == Clear then
			Clear.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)

SearchButton.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(SearchButton)
	local to_search_val = loadstring("return "..SForBox.Text) and loadstring("return "..SForBox.Text)() or nil
	local to_search_val_type = TypeTextBox.Text or nil
	if not to_search_val or type(to_search_val_type) ~= "string" then return end
	if to_search_val_type ~= "constant" and to_search_val_type ~= "upvalue" and to_search_val_type ~= "global" and to_search_val_type ~= "prop" and to_search_val_type ~= "table" then return end
	for i,v in pairs(ChangerLogsList:GetChildren()) do
		v:Destroy()
	end
    for i,v in pairs(getgc(true)) do
    	if type(v) == "function" and not is_synapse_function(v) and islclosure(v) then
    		if to_search_val_type == "constant" then
    			for i2,v2 in pairs(debug.getconstants(v)) do
    				if v2 == to_search_val then
						local newfunc = RemoteLog:Clone()
			            newfunc.TextColor3 = Color3.new(0,1,1)
			            newfunc.BorderColor3 = Color3.new(0,1,1)
			            if type(v2) == "string" then
	                        newfunc.Text = [["]]..tostring(v2)..[["]]
                    	elseif type(v2) == "function" then
                        	local f_name
                        	pcall(function()
                        		f_name = debug.getinfo(v2).name
                        	end)
                        	if f_name and type(f_name) == "string" and #f_name > 0 then
                        		for i,v in pairs(getrenv()) do
                        			if v == v2 then
                        				f_name = "getrenv()."..f_name
                        				break
                        			end
                        		end
                        		newfunc.Text = f_name.."()"
                        	else
                        		newfunc.Text = tostring(v2)
                        	end
                        	if not islclosure(v2) then
                        		newfunc.Text = newfunc.Text.." [C]"
                        	end
	                    else
	                        newfunc.Text = tostring(v2)
	                    end
			            local others2 = #ChangerLogsList:GetChildren()
			            newfunc.Position = UDim2.new(0,0,0,others2*31)
			            newfunc.MouseButton1Click:Connect(function()
			            	ClickSound:Play()
			            	TweenButtonPress(newfunc)
			            	ValChanger("Constant",i2,v2,v,type(v2))
			            end)
						newfunc.MouseEnter:Connect(function()
							EnterSound:Play()
							for i,v in pairs(DarkButtons) do
								if v[1] == newfunc then
									return
								end
							end
							table.insert(DarkButtons,{newfunc,newfunc.TextColor3})
							local colors = {newfunc.TextColor3.R-0.4,newfunc.TextColor3.G-0.4,newfunc.TextColor3.B-0.4}
							for i,v in pairs(colors) do
								if v < 0 then
									colors[i] = 0
								end
							end
							newfunc.TextColor3 = Color3.new(unpack(colors))
						end)
						newfunc.MouseLeave:Connect(function()
							for i,v in pairs(DarkButtons) do
								if v[1] == newfunc then
									newfunc.TextColor3 = v[2]
									table.remove(DarkButtons,i)
									break
								end
							end
						end)
						newfunc.MouseButton2Click:Connect(function()
	                        ClickSound2:Play()
							if type(v2) == "function" then
								RightClick(newfunc,"Function",v2)
							else
								RightClick(newfunc,"DebugVal",v2,v)
							end
						end)
			            newfunc.Parent = ChangerLogsList
    				end
    			end
    		elseif to_search_val_type == "upvalue" then
    			for i2,v2 in pairs(debug.getupvalues(v)) do
    				if v2 == to_search_val then
    					local newfunc = RemoteLog:Clone()
			            newfunc.TextColor3 = Color3.new(0,1,1)
			            newfunc.BorderColor3 = Color3.new(0,1,1)
			            if type(v2) == "string" then
	                        newfunc.Text = [["]]..tostring(v2)..[["]]
	                    elseif type(v2) == "function" then
                        	local f_name
                        	pcall(function()
                        		f_name = debug.getinfo(v2).name
                        	end)
                        	if f_name and type(f_name) == "string" and #f_name > 0 then
                        		for i,v in pairs(getrenv()) do
                        			if v == v2 then
                        				f_name = "getrenv()."..f_name
                        				break
                        			end
                        		end
                        		newfunc.Text = f_name.."()"
                        	else
                        		newfunc.Text = tostring(v2)
                        	end
                        	if not islclosure(v2) then
                        		newfunc.Text = newfunc.Text.." [C]"
                        	end
	                    else
	                        newfunc.Text = tostring(v2)
	                    end
			            local others2 = #ChangerLogsList:GetChildren()
			            newfunc.Position = UDim2.new(0,0,0,others2*31)
			            newfunc.MouseButton1Click:Connect(function()
			            	ClickSound:Play()
			            	TweenButtonPress(newfunc)
			            	ValChanger("Constant",i2,v2,v,type(v2))
			            end)
						newfunc.MouseEnter:Connect(function()
							EnterSound:Play()
							for i,v in pairs(DarkButtons) do
								if v[1] == newfunc then
									return
								end
							end
							table.insert(DarkButtons,{newfunc,newfunc.TextColor3})
							local colors = {newfunc.TextColor3.R-0.4,newfunc.TextColor3.G-0.4,newfunc.TextColor3.B-0.4}
							for i,v in pairs(colors) do
								if v < 0 then
									colors[i] = 0
								end
							end
							newfunc.TextColor3 = Color3.new(unpack(colors))
						end)
						newfunc.MouseLeave:Connect(function()
							for i,v in pairs(DarkButtons) do
								if v[1] == newfunc then
									newfunc.TextColor3 = v[2]
									table.remove(DarkButtons,i)
									break
								end
							end
						end)
						newfunc.MouseButton2Click:Connect(function()
	                        ClickSound2:Play()
							if type(v2) == "function" then
								RightClick(newfunc,"Function",v2)
							else
								RightClick(newfunc,"DebugVal",v2,v)
							end
						end)
			            newfunc.Parent = ChangerLogsList
			        elseif type(v2) == "table" then
			        	--
    				end
    			end
    		elseif to_search_val_type == "global" then
    			for i2,v2 in pairs(getfenv(v)) do
    				if v2 == to_search_val or i2 == v2 then
						local newfunc = RemoteLog:Clone()
			            newfunc.TextColor3 = Color3.new(0,1,1)
			            newfunc.BorderColor3 = Color3.new(0,1,1)
			            if type(v2) == "string" then
	                        newfunc.Text = tostring(i2)..[[: ]]..tostring(v2)..[["]]
	                    elseif type(v2) == "function" then
                        	local f_name
                        	pcall(function()
                        		f_name = debug.getinfo(v2).name
                        	end)
                        	if f_name and type(f_name) == "string" and #f_name > 0 then
                        		for i,v in pairs(getrenv()) do
                        			if v == v2 then
                        				f_name = "getrenv()."..f_name
                        				break
                        			end
                        		end
                        		newfunc.Text = f_name.."()"
                        	else
                        		newfunc.Text = tostring(v2)
                        	end
                        	if not islclosure(v2) then
                        		newfunc.Text = newfunc.Text.." [C]"
                        	end
	                    else
	                        newfunc.Text = tostring(i2)..": "..tostring(v2)
	                    end
			            local others2 = #ChangerLogsList:GetChildren()
			            newfunc.Position = UDim2.new(0,0,0,others2*31)
			            newfunc.MouseButton1Click:Connect(function()
			            	ClickSound:Play()
			            	TweenButtonPress(newfunc)
			            	ValChanger("Env",i2,v2,v,type(v2))
			            end)
						newfunc.MouseEnter:Connect(function()
							EnterSound:Play()
							for i,v in pairs(DarkButtons) do
								if v[1] == newfunc then
									return
								end
							end
							table.insert(DarkButtons,{newfunc,newfunc.TextColor3})
							local colors = {newfunc.TextColor3.R-0.4,newfunc.TextColor3.G-0.4,newfunc.TextColor3.B-0.4}
							for i,v in pairs(colors) do
								if v < 0 then
									colors[i] = 0
								end
							end
							newfunc.TextColor3 = Color3.new(unpack(colors))
						end)
						newfunc.MouseLeave:Connect(function()
							for i,v in pairs(DarkButtons) do
								if v[1] == newfunc then
									newfunc.TextColor3 = v[2]
									table.remove(DarkButtons,i)
									break
								end
							end
						end)
						newfunc.MouseButton2Click:Connect(function()
	                        ClickSound2:Play()
							if type(v2) == "function" then
								RightClick(newfunc,"Function",v2)
							else
								RightClick(newfunc,"DebugVal",v2,v)
							end
						end)
			            newfunc.Parent = ChangerLogsList
    				end
    			end
    		elseif to_search_val_type == "prop" then
    			local literally_everything = {}
    			if LP.Character then
	    			for i2,v2 in pairs(LP.Character:GetDescendants()) do
	    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text") then
	    					table.insert(literally_everything,v2)
	    				end
	    			end
    			end
    			for i2,v2 in pairs(LP:GetDescendants()) do
    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text") then
    					table.insert(literally_everything,v2)
    				end
    			end
    			for i2,v2 in pairs(game.ReplicatedFirst:GetDescendants()) do
    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text") then
    					table.insert(literally_everything,v2)
    				end
    			end
    			for i2,v2 in pairs(game.ReplicatedStorage:GetDescendants()) do
    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text")then
    					table.insert(literally_everything,v2)
    				end
    			end
    			for i2,v2 in pairs(game.StarterGui:GetDescendants()) do
    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text") then
    					table.insert(literally_everything,v2)
    				end
    			end
    			for i2,v2 in pairs(game.StarterPack:GetDescendants()) do
    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text") then
    					table.insert(literally_everything,v2)
    				end
    			end
    			for i2,v2 in pairs(game:GetService("CoreGui"):GetDescendants()) do
    				if v2:IsDescendantOf(SRS) then continue end
    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text") then
    					table.insert(literally_everything,v2)
    				end
    			end
    			for i2,v2 in pairs(game.Lighting:GetDescendants()) do
    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text") then
    					table.insert(literally_everything,v2)
    				end
    			end
    			for i2,v2 in pairs(workspace:GetDescendants()) do
    				if v2.ClassName:sub(-5) == "Value" or v2.ClassName:find("Text") then
    					table.insert(literally_everything,v2)
    				end
    			end
    			for i2,v2 in pairs(literally_everything) do
    				if v2.ClassName:find("Text") and v2.ClassName ~= "UITextSizeConstraint" and v2.ClassName ~= "Texture" then
    					if string.find(string.lower(v2.Text),string.lower(tostring(to_search_val))) then
	    					local newfunc = RemoteLog:Clone()
				            newfunc.TextColor3 = Color3.new(0,1,1)
				            newfunc.BorderColor3 = Color3.new(0,1,1)
				            newfunc.Text = tostring(v2)..".Text"
				            local others2 = #ChangerLogsList:GetChildren()
				            newfunc.Position = UDim2.new(0,0,0,others2*31)
				            newfunc.MouseButton1Click:Connect(function()
				            	ClickSound:Play()
				            	TweenButtonPress(newfunc)
				            	ValChanger("Prop","Text",v2.Text,v2,"string")
				            end)
							newfunc.MouseEnter:Connect(function()
								EnterSound:Play()
								for i,v in pairs(DarkButtons) do
									if v[1] == newfunc then
										return
									end
								end
								table.insert(DarkButtons,{newfunc,newfunc.TextColor3})
								local colors = {newfunc.TextColor3.R-0.4,newfunc.TextColor3.G-0.4,newfunc.TextColor3.B-0.4}
								for i,v in pairs(colors) do
									if v < 0 then
										colors[i] = 0
									end
								end
								newfunc.TextColor3 = Color3.new(unpack(colors))
							end)
							newfunc.MouseLeave:Connect(function()
								for i,v in pairs(DarkButtons) do
									if v[1] == newfunc then
										newfunc.TextColor3 = v[2]
										table.remove(DarkButtons,i)
										break
									end
								end
							end)
				            newfunc.Parent = ChangerLogsList
				        else
    					end
    				elseif v2.ClassName:sub(-5) == "Value" then
    					if v2.Value == to_search_val then
    						local newfunc = RemoteLog:Clone()
				            newfunc.TextColor3 = Color3.new(0,1,1)
				            newfunc.BorderColor3 = Color3.new(0,1,1)
				            if type(v2.Value) == "string" then
		                        newfunc.Text = tostring("Value")..[[: "]]..tostring(v2)..[["]]
		                    else
		                        newfunc.Text = tostring("Value")..": "..tostring(v2)
		                    end
				            local others2 = #ChangerLogsList:GetChildren()
				            newfunc.Position = UDim2.new(0,0,0,others2*31)
				            newfunc.MouseButton1Click:Connect(function()
				            	ClickSound:Play()
				            	TweenButtonPress(newfunc)
				            	ValChanger("Prop","Value",v2.Value,v2,type(v2.Value))
				            end)
							newfunc.MouseEnter:Connect(function()
								EnterSound:Play()
								for i,v in pairs(DarkButtons) do
									if v[1] == newfunc then
										return
									end
								end
								table.insert(DarkButtons,{newfunc,newfunc.TextColor3})
								local colors = {newfunc.TextColor3.R-0.4,newfunc.TextColor3.G-0.4,newfunc.TextColor3.B-0.4}
								for i,v in pairs(colors) do
									if v < 0 then
										colors[i] = 0
									end
								end
								newfunc.TextColor3 = Color3.new(unpack(colors))
							end)
							newfunc.MouseLeave:Connect(function()
								for i,v in pairs(DarkButtons) do
									if v[1] == newfunc then
										newfunc.TextColor3 = v[2]
										table.remove(DarkButtons,i)
										break
									end
								end
							end)
				            newfunc.Parent = ChangerLogsList
    					end
    				end
    			end
    			break
    		elseif to_search_val_type == "table" then
    			local found_tbls = {}
    			local rec1337
    			rec1337 = function(TBL,M,how,ind)
    				if typeof(TBL) ~= "table" then return end
    				M = M + 1
    				table.insert(found_tbls,{TBL,how,ind})
    				if M >= 3 then return end
    				for abc,def in pairs(TBL) do
    					if type(def) ~= "table" then continue end
    					rec1337(def,M)
    				end
    			end
    			for i2,v2 in pairs(getgc(true)) do
    				if type(v2) == "function" and not is_synapse_function(v2) and islclosure(v2) then
    					for i3,v3 in pairs(debug.getupvalues(v2)) do
    						if typeof(v3) == "table" and v3 ~= {} then
    							rec1337(v3,0,"upval",i3)
    						end
    					end
    					for i3,v3 in pairs(debug.getconstants(v2)) do
    						if typeof(v3) == "table" and v3 ~= {} then
    							rec1337(v3,0,"const",i3)
    						end
    					end
    					for i3,v3 in pairs(getfenv(v2)) do
    						if typeof(v3) == "table" and v3 ~= {} then
    							rec1337(v3,0,"env",i3)
    						end
    					end
    				elseif v2 and typeof(v2) == "table" and v2 ~= {} and #v2 < 100 then
    					rec1337(v2,99,"gc",i2)
    				end
    			end
    			for i2,v2 in pairs(workspace:GetDescendants()) do
    				if v2 and v2:IsA("ModuleScript") and type(require(v2)) == "table" and require(v2) ~= {} then
    					table.insert(found_tbls,require(v2))
    				end
    			end
    			for i2,v2 in pairs(found_tbls) do
    				if type(v2[1]) == "table" then
    					local skip_this = false
    					for i3,v3 in pairs(v2[1]) do
    						for i4,v4 in pairs(ChangerLogsList:GetChildren()) do
    							if tostring(v2[1]) == v4.Text then
    								skip_this = true
    							end
    						end
    						if skip_this then continue end
    						if (i3 == to_search_val and type(to_search_val) ~= "number") or v3 == to_search_val or (tostring(i3) == tostring(to_search_val) and type(i3) ~= "number") or tostring(v3) == tostring(to_search_val) then
	    						local newfunc = RemoteLog:Clone()
					            newfunc.TextColor3 = Color3.new(0,1,1)
					            newfunc.BorderColor3 = Color3.new(0,1,1)
			                    newfunc.Text = tostring(v2[1])
					            local others2 = #ChangerLogsList:GetChildren()
					            newfunc.Position = UDim2.new(0,0,0,others2*31)
					            newfunc.MouseButton1Click:Connect(function()
					            	ClickSound:Play()
					            	TweenButtonPress(newfunc)
					            	ValChanger("Table","N/A",v2[1],"N/A","N/A")
					            end)
								newfunc.MouseEnter:Connect(function()
									EnterSound:Play()
									for i,v in pairs(DarkButtons) do
										if v[1] == newfunc then
											return
										end
									end
									table.insert(DarkButtons,{newfunc,newfunc.TextColor3})
									local colors = {newfunc.TextColor3.R-0.4,newfunc.TextColor3.G-0.4,newfunc.TextColor3.B-0.4}
									for i,v in pairs(colors) do
										if v < 0 then
											colors[i] = 0
										end
									end
									newfunc.TextColor3 = Color3.new(unpack(colors))
								end)
								newfunc.MouseLeave:Connect(function()
									for i,v in pairs(DarkButtons) do
										if v[1] == newfunc then
											newfunc.TextColor3 = v[2]
											table.remove(DarkButtons,i)
											break
										end
									end
								end)
								newfunc.MouseButton2Click:Connect(function()
			                        ClickSound2:Play()
									RightClick(newfunc,"DebugVal",v2[1],v)
								end)
					            newfunc.Parent = ChangerLogsList
    						end
    					end
    				end
    			end
    			break
    		end
    	end
    end
    ChangerLogsList.CanvasSize = UDim2.new(0,0,0,#ChangerLogsList:GetChildren()*31)
end)
SearchButton.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == SearchButton then
			return
		end
	end
	table.insert(DarkButtons,{SearchButton,SearchButton.TextColor3})
	local colors = {SearchButton.TextColor3.R-0.4,SearchButton.TextColor3.G-0.4,SearchButton.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	SearchButton.TextColor3 = Color3.new(unpack(colors))
end)
SearchButton.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == SearchButton then
			SearchButton.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
UpScan.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(UpScan)
    Transition(true)
    wait(0.3)
    ChangeFrame(ChangerFrame)
    wait(0.3)
    Transition(false)
    ToClear = ChangerLogsList
end)
UpScan.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == UpScan then
			print("ok")
			return
		end
	end
	table.insert(DarkButtons,{UpScan,UpScan.TextColor3})
	local colors = {UpScan.TextColor3.R-0.4,UpScan.TextColor3.G-0.4,UpScan.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	UpScan.TextColor3 = Color3.new(unpack(colors))
end)
UpScan.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == UpScan then
			UpScan.TextColor3 = v[2]
			table.remove(DarkButtons,i)
		end
	end
end)
Home.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(Home)
    Transition(true)
    wait(0.3)
    ChangeFrame(HomeFrame)
    wait(0.3)
    Transition(false)
end)
Home.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == Home then
			return
		end
	end
	table.insert(DarkButtons,{Home,Home.TextColor3})
	local colors = {Home.TextColor3.R-0.4,Home.TextColor3.G-0.4,Home.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	Home.TextColor3 = Color3.new(unpack(colors))
end)
Home.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == Home then
			Home.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
Remotes.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(Remotes)
    UpdateRemotes()
    Transition(true)
    wait(0.3)
    ChangeFrame(RemotesFrame)
    wait(0.3)
    Transition(false)
end)
Remotes.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == Remotes then
			return
		end
	end
	table.insert(DarkButtons,{Remotes,Remotes.TextColor3})
	local colors = {Remotes.TextColor3.R-0.4,Remotes.TextColor3.G-0.4,Remotes.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	Remotes.TextColor3 = Color3.new(unpack(colors))
end)
Remotes.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == Remotes then
			Remotes.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
RemoteSpy.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(RemoteSpy)
    ToClear = RemoteLogsList
    Transition(true)
    wait(0.3)
    ChangeFrame(RemoteSpyFrame)
    wait(0.3)
    Transition(false)
end)
RemoteSpy.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == RemoteSpy then
			return
		end
	end
	table.insert(DarkButtons,{RemoteSpy,RemoteSpy.TextColor3})
	local colors = {RemoteSpy.TextColor3.R-0.4,RemoteSpy.TextColor3.G-0.4,RemoteSpy.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	RemoteSpy.TextColor3 = Color3.new(unpack(colors))
end)
RemoteSpy.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == RemoteSpy then
			RemoteSpy.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
ScriptSpy.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(ScriptSpy)
    ToClear = ScriptLogsList
    Transition(true)
    wait(0.3)
    ChangeFrame(ScriptSpyFrame)
    wait(0.3)
    Transition(false)
end)
EnableSrs.MouseButton1Click:Connect(function()
	ClickSound:Play()
	SRS_ENABLED = not SRS_ENABLED
	if SRS_ENABLED then
		EnableSrs.TextColor3 = Color3.new(0-0.4,1-0.4,0-0.4)
		EnableSrs.Text = "Enabled"
		EnableSrsShadow.Text = "Enabled"
	else
		EnableSrs.TextColor3 = Color3.new(1-0.4,0-0.4,0-0.4)
		EnableSrs.Text = "Disabled"
		EnableSrsShadow.Text = "Disabled"
	end
	TweenButtonPress(EnableSrs)
end)
EnableSrs.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == EnableSrs then
			return
		end
	end
	table.insert(DarkButtons,{EnableSrs,EnableSrs.TextColor3})
	local colors = {EnableSrs.TextColor3.R-0.4,EnableSrs.TextColor3.G-0.4,EnableSrs.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	EnableSrs.TextColor3 = Color3.new(unpack(colors))
end)
EnableSrs.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == EnableSrs then
			EnableSrs.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
ScriptSpy.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == ScriptSpy then
			return
		end
	end
	table.insert(DarkButtons,{ScriptSpy,ScriptSpy.TextColor3})
	local colors = {ScriptSpy.TextColor3.R-0.4,ScriptSpy.TextColor3.G-0.4,ScriptSpy.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	ScriptSpy.TextColor3 = Color3.new(unpack(colors))
end)
ScriptSpy.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == ScriptSpy then
			ScriptSpy.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
Debug.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(Debug)
    ToClear = DebugLogsList
    Transition(true)
    wait(0.3)
    ChangeFrame(DebugFrame)
    wait(0.3)
    Transition(false)
end)
Debug.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == Debug then
			return
		end
	end
	table.insert(DarkButtons,{Debug,Debug.TextColor3})
	local colors = {Debug.TextColor3.R-0.4,Debug.TextColor3.G-0.4,Debug.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	Debug.TextColor3 = Color3.new(unpack(colors))
end)
Debug.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == Debug then
			Debug.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
Namecall.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(Namecall)
    UpdateNamecalls()
    Transition(true)
    wait(0.3)
    ChangeFrame(NamecallFrame)
    wait(0.3)
    Transition(false)
end)
Namecall.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == Namecall then
			return
		end
	end
	table.insert(DarkButtons,{Namecall,Namecall.TextColor3})
	local colors = {Namecall.TextColor3.R-0.4,Namecall.TextColor3.G-0.4,Namecall.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	Namecall.TextColor3 = Color3.new(unpack(colors))
end)
Namecall.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == Namecall then
			Namecall.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
RemoteFire.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(RemoteFire)
    if SelectedRemote then
        if SelectedRemote:IsA("RemoteFunction") then
            SelectedRemote:InvokeServer(unpack(SelectedRemoteArgs))
        else
            SelectedRemote:FireServer(unpack(SelectedRemoteArgs))
        end
    end
end)
RemoteFire.MouseButton2Click:Connect(function()
	RightClick(RemoteFire,"Fire Remote")
end)
RemoteFire.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == RemoteFire then
			return
		end
	end
	table.insert(DarkButtons,{RemoteFire,RemoteFire.TextColor3})
	local colors = {RemoteFire.TextColor3.R-0.4,RemoteFire.TextColor3.G-0.4,RemoteFire.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	RemoteFire.TextColor3 = Color3.new(unpack(colors))
end)
RemoteFire.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == RemoteFire then
			RemoteFire.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
SpyScript.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(SpyScript)
	local scr
	pcall(function()
    	scr = loadstring("return "..ScriptSpyText.Text)()
    end)
    if typeof(scr) == "Instance" and scr:IsA("LocalScript") then
    	for i,v in pairs(SpiedScripts) do
    		if v == scr then
    			return
    		end
    	end
    	table.insert(SpiedScripts,scr)
    end
end)
SpyScript.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == SpyScript then
			return
		end
	end
	table.insert(DarkButtons,{SpyScript,SpyScript.TextColor3})
	local colors = {SpyScript.TextColor3.R-0.4,SpyScript.TextColor3.G-0.4,SpyScript.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	SpyScript.TextColor3 = Color3.new(unpack(colors))
end)
SpyScript.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == SpyScript then
			SpyScript.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
UnSpyScript.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(UnSpyScript)
    local scr
	pcall(function()
    	scr = loadstring("return "..ScriptSpyText.Text)()
    end)
    if typeof(scr) == "Instance" and scr:IsA("LocalScript") then
    	for i,v in pairs(SpiedScripts) do
    		if v == scr then
    			table.remove(SpiedScripts,i)
    		end
    	end
    end
end)
UnSpyScript.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == UnSpyScript then
			return
		end
	end
	table.insert(DarkButtons,{UnSpyScript,UnSpyScript.TextColor3})
	local colors = {UnSpyScript.TextColor3.R-0.4,UnSpyScript.TextColor3.G-0.4,UnSpyScript.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	UnSpyScript.TextColor3 = Color3.new(unpack(colors))
end)
UnSpyScript.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == UnSpyScript then
			UnSpyScript.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
IgnoreRemote.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(IgnoreRemote)
    if not SelectedRemote then return end
    table.insert(IgnoredRemotes,SelectedRemote)
end)
IgnoreRemote.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == IgnoreRemote then
			return
		end
	end
	table.insert(DarkButtons,{IgnoreRemote,IgnoreRemote.TextColor3})
	local colors = {IgnoreRemote.TextColor3.R-0.4,IgnoreRemote.TextColor3.G-0.4,IgnoreRemote.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	IgnoreRemote.TextColor3 = Color3.new(unpack(colors))
end)
IgnoreRemote.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == IgnoreRemote then
			IgnoreRemote.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
IgnoreRemoteCall.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(IgnoreRemoteCall)
    if not SelectedRemoteArgs then return end
    table.insert(IgnoredCalls,{["Remote"] = SelectedRemote.Name,["Args"] = SelectedRemoteArgs,["Text"] = TableString(SelectedRemoteArgs)})
end)
IgnoreRemoteCall.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == IgnoreRemoteCall then
			return
		end
	end
	table.insert(DarkButtons,{IgnoreRemoteCall,IgnoreRemoteCall.TextColor3})
	local colors = {IgnoreRemoteCall.TextColor3.R-0.4,IgnoreRemoteCall.TextColor3.G-0.4,IgnoreRemoteCall.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	IgnoreRemoteCall.TextColor3 = Color3.new(unpack(colors))
end)
IgnoreRemoteCall.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == IgnoreRemoteCall then
			IgnoreRemoteCall.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
IgnoreIndCall.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(IgnoreIndCall)
    if not SelectedRemoteArgs then return end
    table.insert(IgnoredCalls,{["Remote"] = SelectedRemote.Name,["Args"] = SelectedRemoteArgs,["Text"] = TableString(SelectedRemoteArgs)})
end)
IgnoreIndCall.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == IgnoreIndCall then
			return
		end
	end
	table.insert(DarkButtons,{IgnoreIndCall,IgnoreIndCall.TextColor3})
	local colors = {IgnoreIndCall.TextColor3.R-0.4,IgnoreIndCall.TextColor3.G-0.4,IgnoreIndCall.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	IgnoreIndCall.TextColor3 = Color3.new(unpack(colors))
end)
IgnoreIndCall.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == IgnoreIndCall then
			IgnoreIndCall.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
EnableNamecall.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenButtonPress(EnableNamecall)
    if not SelectedNameCall then return end
    table.remove(IgnoredCalls,SelectedNameCall)
    SelectedNameCall = nil
    UpdateNamecalls()
end)
EnableNamecall.MouseEnter:Connect(function()
	EnterSound:Play()
	for i,v in pairs(DarkButtons) do
		if v[1] == EnableNamecall then
			return
		end
	end
	table.insert(DarkButtons,{EnableNamecall,EnableNamecall.TextColor3})
	local colors = {EnableNamecall.TextColor3.R-0.4,EnableNamecall.TextColor3.G-0.4,EnableNamecall.TextColor3.B-0.4}
	for i,v in pairs(colors) do
		if v < 0 then
			colors[i] = 0
		end
	end
	EnableNamecall.TextColor3 = Color3.new(unpack(colors))
end)
EnableNamecall.MouseLeave:Connect(function()
	for i,v in pairs(DarkButtons) do
		if v[1] == EnableNamecall then
			EnableNamecall.TextColor3 = v[2]
			table.remove(DarkButtons,i)
			break
		end
	end
end)
ValChanger = function(what,index,value,func,valtype)
	if ValChangerFrame.Visible then return end
	ChangerLabel.Text = what.." Changer"
	ChangerLabelShadow.Text = what.." Changer"
	if valtype == "string" then
		PrevValLabel.Text = "\""..tostring(value).."\""
	else
		PrevValLabel.Text = tostring(value)
	end
	local trychange = function()
		if ValChangerBox.Text == nil or ValChangerBox.Text == "" or ValChangerBox.Text == " " then return end
		local newval = loadstring("return "..ValChangerBox.Text)()
		if not newval then error("invalid newval") end
		if what == "Upvalue" then
			if valtype == "table" and type(newval) == "table" then
				local hax_tbl = debug.getupvalue(func,index)
				for i,v in pairs(hax_tbl) do
					hax_tbl[i] = nil
				end
				for i,v in pairs(newval) do
					hax_tbl[i] = v
				end
			else
				debug.setupvalue(func,index,newval)
			end
		elseif what == "Constant" then
			if valtype == "table" and type(newval) == "table" then
				local hax_tbl = debug.getconstant(func,index)
				for i,v in pairs(hax_tbl) do
					hax_tbl[i] = nil
				end
				for i,v in pairs(newval) do
					hax_tbl[i] = v
				end
			else
				debug.setconstant(func,index,newval)
			end
		elseif what == "Env" then
			local env = getfenv(func)
			env[index] = newval
			setfenv(func,env)
		elseif what == "Prop" then
			func[index] = newval
		elseif what == "Table" then
			for i,v in pairs(value) do
				if type(i) == "number" then
					table.remove(value,i)
				else
					value[i] = nil
				end
			end
			if type(newval) == "table" then
				for i,v in pairs(newval) do
					value[i] = v
				end
			end
		end
		ValChangerFrame.ZIndex = -1
		ChangerLabel.ZIndex = -1
		ChangerLabelShadow.ZIndex = -1
		PrevValLabel.ZIndex = -1
		ValChangerBox.ZIndex = -1
		ValChangerFrame.Visible = false
	end
	local con
	con = ValChangerBox.InputBegan:Connect(function()
		local entered = false
		local con2 = game:GetService("UserInputService").InputBegan:Connect(function(tbl,bool)
			if bool == false then return end
			if tbl.KeyCode == Enum.KeyCode.Return then
				entered = true
			end
		end)
		local abort = false
		repeat wait() if not ValChangerFrame.Visible then abort = true end until entered
		spawn(trychange)
		ValChangerFrame.ZIndex = -1
		ChangerLabel.ZIndex = -1
		ChangerLabelShadow.ZIndex = -1
		PrevValLabel.ZIndex = -1
		ValChangerBox.ZIndex = -1
		ValChangerFrame.Visible = false
		con:Disconnect()
		con2:Disconnect()
	end)
	ValChangerFrame.Visible = true
	ValChangerFrame.ZIndex = 899999
	ChangerLabel.ZIndex = 999999
	ChangerLabelShadow.ZIndex = 999993
	PrevValLabel.ZIndex = 999999
	ValChangerBox.ZIndex = 999999
end
local mt = getrawmetatable(game)
setreadonly(mt,false)
local backup = rawget(mt,"__namecall")
local backup2 = rawget(mt,"__index")
local backup3 = rawget(mt,"__newindex")
local OnRemote = function(MAIN_INFO)
    setcontext(6)
    local DebugTable = MAIN_INFO["dt"]
    local scr = MAIN_INFO["scr"]
    if not scr then scr = "NIL" end
    local remote = MAIN_INFO["rem"]
    local args = MAIN_INFO["args"]
    local method = MAIN_INFO["method"]
    local IsHidden = MAIN_INFO["Hidden"]
    local ToScript = MAIN_INFO["ToScript"]
    if MAIN_INFO then
    	BeepSound:Play()
        local key = DebugTable.Name
        local new = RemoteLog:Clone()
        new.Text = remote.Name or "???"
        new.Position = UDim2.new(0,0,0,#RemoteLogsList:GetChildren()*31)
        if method == "InvokeServer" then
            new.TextColor3 = Color3.new(1,0,1)
            new.BorderColor3 = Color3.new(1,0,1)
        end
        Debugs[key] = DebugTable
        local LastRemote = remote
        new.MouseButton1Click:Connect(function()
        	ClickSound:Play()
        	TweenButtonPress(new)
            local olds = {}
            RemoteSpyText.Text = (IsHidden and "--// Hidden\n"..ToScript) or ToScript
            SelectedRemote = LastRemote
            SelectedRemoteArgs = args
        end)
		new.MouseButton2Click:Connect(function()
			ClickSound2:Play()
			RightClick(new,"DebugFunc",DebugTable)
		end)
		new.MouseEnter:Connect(function()
			EnterSound:Play()
			for i,v in pairs(DarkButtons) do
				if v[1] == new then
					return
				end
			end
			table.insert(DarkButtons,{new,new.TextColor3})
			local colors = {new.TextColor3.R-0.4,new.TextColor3.G-0.4,new.TextColor3.B-0.4}
			for i,v in pairs(colors) do
				if v < 0 then
					colors[i] = 0
				end
			end
			new.TextColor3 = Color3.new(unpack(colors))
		end)
		new.MouseLeave:Connect(function()
			for i,v in pairs(DarkButtons) do
				if v[1] == new then
					new.TextColor3 = v[2]
					table.remove(DarkButtons,i)
					break
				end
			end
		end)
        new.Parent = RemoteLogsList
        RemoteLogsList.CanvasSize = UDim2.new(0,0,0,#RemoteLogsList:GetChildren()*31)
    end
end
local remote_bindable = Instance.new("BindableEvent")
remote_bindable.Event:Connect(function(what,...)
	if what == "OnRemote" then
		OnRemote(...)
	end
end)
local OnScript = function(MAIN_INFO)
    setcontext(6)
    local DebugTable = MAIN_INFO["dt"]
    local scr = MAIN_INFO["scr"]
    if not scr then scr = "NIL" end
    local Self = MAIN_INFO["Self"]
    local Index = MAIN_INFO["Index"]
    local Val = MAIN_INFO["Val"]
    local Method = MAIN_INFO["Method"]
    local Args = MAIN_INFO["Args"]
    local Type = MAIN_INFO["Type"]
    local Ret = MAIN_INFO["Return"]
    if MAIN_INFO then
    	BeepSound:Play()
        local key = DebugTable.Name
        local new = RemoteLog:Clone()
        if Type == 1 then
        	backup3(new,"Text","__index")
        elseif Type == 2 then
        	backup3(new,"Text","__newindex")
        else
        	backup3(new,"Text","__namecall")
        end
        backup3(new,"Position",UDim2.new(0,0,0,#ScriptLogsList:GetChildren()*31))
        backup3(new,"TextColor3",Color3.fromRGB(213, 115, 61))
        backup3(new,"BorderColor3",Color3.fromRGB(213, 115, 61))
        Debugs[key] = DebugTable
        backup2(new,"MouseButton1Click"):Connect(function()
        	ClickSound:Play()
        	TweenButtonPress(new)
            local olds = {}
            if Type == 1 then
            	backup3(ScriptSpyText,"Text","--// Script: "..GetPath(scr).."\nSelf: "..GetPath(Self).."\nIndex: "..tostring(Index).."\nReturn: "..GetType(Ret))
            elseif Type == 2 then
            	backup3(ScriptSpyText,"Text","--// Script: "..GetPath(scr).."\nSelf: "..GetPath(Self).."\nIndex: "..tostring(Index).."\nValue: "..GetType(Val))
			else
				backup3(ScriptSpyText,"Text",ToScript(Self,scr,tostring(Self[Method]),Method,unpack(Args)))
            end
            SelectedRemote = "__index"
            if Type ~= 1 then
            	SelectedRemote = "__newindex"
            end
            SelectedRemoteArgs = {tostring(Self),tostring(Index)}
        end)
        new.MouseButton2Click:Connect(function()
			ClickSound2:Play()
			RightClick(new,"DebugFunc",DebugTable)
		end)
		new.MouseEnter:Connect(function()
			EnterSound:Play()
			for i,v in pairs(DarkButtons) do
				if v[1] == new then
					return
				end
			end
			table.insert(DarkButtons,{new,new.TextColor3})
			local colors = {new.TextColor3.R-0.4,new.TextColor3.G-0.4,new.TextColor3.B-0.4}
			for i,v in pairs(colors) do
				if v < 0 then
					colors[i] = 0
				end
			end
			new.TextColor3 = Color3.new(unpack(colors))
		end)
		new.MouseLeave:Connect(function()
			for i,v in pairs(DarkButtons) do
				if v[1] == new then
					new.TextColor3 = v[2]
					table.remove(DarkButtons,i)
					break
				end
			end
		end)
        backup3(new,"Parent",ScriptLogsList)
        backup3(ScriptLogsList,"CanvasSize",UDim2.new(0,0,0,#ScriptLogsList:GetChildren()*31))
    end
end



local FireServerBackup
local InvokeServerBackup
local FireServerHook = newcclosure(function(self,...)
	if not SRS_ENABLED then return FireServerBackup(self,...) end
    local args = {...}
    for i,v in pairs(IgnoredRemotes) do
        if self == v then
            return FireServerBackup(self,...)
        end
    end

    for i,v in pairs(IgnoredCalls) do
        for i2,v2 in pairs(v["Args"]) do
        	if getrawmetatable(v2) ~= {} and getrawmetatable(v2) ~= nil then continue end
        	if getrawmetatable(args[i2]) ~= {} and getrawmetatable(args[i2]) ~= nil then continue end
        	if type(v2) == "string" and type(args[i2]) == "string" and v2 == args[i2] then
        		return FireServerBackup(self,...)
        	end
        end
    end
    local DebugTable = {}
    local upvals = {}
    for i,v in pairs(debug.getupvalues(3)) do
    	if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) ~= {} then
    		if typeof(v) == "userdata" then
    			upvals[i] = newproxy(false)
    		else
    			local new_protected_table = {}
    			for i2,v2 in pairs(v) do
    				if i2 == "__index" or i2 == "__newindex" or i2 == "__tostring" then continue end
    				new_protected_table[i2] = v2
    			end
    			upvals[i] = new_protected_table
    		end
    	else
    		upvals[i] = v
    	end
    end
    local cons = {}
    for i,v in pairs(debug.getconstants(3)) do
    	if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) ~= {} then
    		if typeof(v) == "userdata" then
    			cons[i] = newproxy(false)
    		else
    			local new_protected_table = {}
    			for i2,v2 in pairs(v) do
    				if i2 == "__index" or i2 == "__newindex" or i2 == "__tostring" then continue end
    				new_protected_table[i2] = v2
    			end
    			cons[i] = new_protected_table
    		end
    	else
    		cons[i] = v
    	end
    end
    DebugTable = {
        ["Name"] = tostring(getcallingfunction(3)),
        ["Function"] = getcallingfunction(3),
        ["Upvalues"] = upvals,
        ["Constants"] = cons
    }
    local scr = getcallingscript() or getfenv(3)["script"] or "Unknown"
    local RemoteStuff = {
        ["dt"] = DebugTable,
        ["scr"] = scr,
        ["rem"] = self,
        ["args"] = args,
        ["method"] = "FireServer",
        ["Hidden"] = true,
        ["ToScript"] = ToScript(self,scr,DebugTable.Function,"FireServer",unpack(args))
    }
	remote_bindable.Fire(remote_bindable,"OnRemote",RemoteStuff)
    return FireServerBackup(self,...)
end)
local InvokeServerHook = newcclosure(function(self,...)
	if not SRS_ENABLED then return InvokeServerBackup(self,...) end
    local args = {...}
    for i,v in pairs(IgnoredRemotes) do
        if self == v then
            return InvokeServerBackup(self,...)
        end
    end

	for i,v in pairs(IgnoredCalls) do
        for i2,v2 in pairs(v["Args"]) do
        	if getrawmetatable(v2) ~= {} and getrawmetatable(v2) ~= nil then continue end
        	if getrawmetatable(args[i2]) ~= {} and getrawmetatable(args[i2]) ~= nil then continue end
        	if type(v2) == "string" and type(args[i2]) == "string" and v2 == args[i2] then
        		return InvokeServerBackup(self,...)
        	end
        end
    end
    local DebugTable = {}
    local upvals = {}
    for i,v in pairs(debug.getupvalues(3)) do
    	if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) ~= {} then
    		if typeof(v) == "userdata" then
    			upvals[i] = newproxy(false)
    		else
    			local new_protected_table = {}
    			for i2,v2 in pairs(v) do
    				if i2 == "__index" or i2 == "__newindex" or i2 == "__tostring" then continue end
    				new_protected_table[i2] = v2
    			end
    		end
    	else
    		upvals[i] = v
    	end
    end
    local cons = {}
    for i,v in pairs(debug.getconstants(3)) do
    	if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) ~= {} then
    		if typeof(v) == "userdata" then
    			cons[i] = newproxy(false)
    		else
    			local new_protected_table = {}
    			for i2,v2 in pairs(v) do
    				if i2 == "__index" or i2 == "__newindex" or i2 == "__tostring" then continue end
    				new_protected_table[i2] = v2
    			end
    			cons[i] = new_protected_table
    		end
    	else
    		cons[i] = v
    	end
    end
    DebugTable = {
        ["Name"] = tostring(getcallingfunction(3)),
        ["Function"] = getcallingfunction(3),
        ["Upvalues"] = upvals,
        ["Constants"] = cons
    }
    local scr = getcallingscript() or getfenv(3)["script"] or "Unknown"
    local RemoteStuff = {
		["dt"] = DebugTable,
		["scr"] = scr,
		["rem"] = self,
		["args"] = args,
		["method"] = "InvokeServer",
		["Hidden"] = true,
		["ToScript"] = ToScript(self,scr,DebugTable.Function,"InvokeServer",unpack(args))
	}
    remote_bindable.Fire(remote_bindable,"OnRemote",RemoteStuff)
    return InvokeServerBackup(self,...)
end)
FireServerBackup = hookfunction(Instance.new("RemoteEvent").FireServer,FireServerHook)
InvokeServerBackup = hookfunction(Instance.new("RemoteFunction").InvokeServer,InvokeServerHook)
mt.__namecall = newcclosure(function(self,...)
	if not SRS_ENABLED then return backup(self,...) end
	if getcontext() == 6 or checkcaller() then return backup(self,...) end
    local args = {...}
    for i,v in pairs(IgnoredRemotes) do
        if self == v then
            return backup(self,...)
        end
    end
    local spy_it = false
    for i,v in pairs(SpiedScripts) do
    	if v == getfenv(3)["script"] then
    		spy_it = true
    		break
    	end
    end
    local OLD_NC = getnamecallmethod()
    if getnamecallmethod() == "Fire" then
    	return backup(self,...)
    end
    if getnamecallmethod() == "FireServer" and self.ClassName == "RemoteEvent" then
		for i,v in pairs(IgnoredCalls) do
	        for i2,v2 in pairs(v["Args"]) do
	        	if getrawmetatable(v2) ~= {} and getrawmetatable(v2) ~= nil then continue end
	        	if getrawmetatable(args[i2]) ~= {} and getrawmetatable(args[i2]) ~= nil then continue end
	        	if type(v2) == "string" and type(args[i2]) == "string" and v2 == args[i2] then
	        		return backup(self,...)
	        	end
	        end
	    end
        local DebugTable = {}
        local upvals = {}
        for i,v in pairs(debug.getupvalues(3)) do
        	if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) ~= {} then
        		if typeof(v) == "userdata" then
        			upvals[i] = newproxy(false)
        		else
        			local new_protected_table = {}
        			for i2,v2 in pairs(v) do
        				if i2 == "__index" or i2 == "__newindex" or i2 == "__tostring" then continue end
        				new_protected_table[i2] = v2
        			end
        		end
        	else
        		upvals[i] = v
        	end
        end
        local cons = {}
	    for i,v in pairs(debug.getconstants(3)) do
	    	if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) ~= {} then
	    		if typeof(v) == "userdata" then
	    			cons[i] = newproxy(false)
	    		else
	    			local new_protected_table = {}
	    			for i2,v2 in pairs(v) do
	    				if i2 == "__index" or i2 == "__newindex" or i2 == "__tostring" then continue end
	    				new_protected_table[i2] = v2
	    			end
	    			cons[i] = new_protected_table
	    		end
	    	else
	    		cons[i] = v
	    	end
	    end
        DebugTable = {
            ["Name"] = tostring(getcallingfunction(3)),
            ["Function"] = getcallingfunction(3),
            ["Upvalues"] = upvals,
            ["Constants"] = cons
        }
        local scr = getcallingscript() or getfenv(3)["script"] or "Unknown"
        local RemoteStuff = {
            ["dt"] = DebugTable,
            ["scr"] = scr,
            ["rem"] = self,
            ["args"] = args,
            ["method"] = "FireServer",
            ["ToScript"] = ToScript(self,scr,DebugTable.Function,"FireServer",unpack(args))
        }
        remote_bindable:Fire("OnRemote",RemoteStuff)
    end
    if getnamecallmethod() == "InvokeServer" and self.ClassName == "RemoteFunction" then
	    for i,v in pairs(IgnoredCalls) do
	        for i2,v2 in pairs(v["Args"]) do
	        	if getrawmetatable(v2) ~= {} and getrawmetatable(v2) ~= nil then continue end
	        	if getrawmetatable(args[i2]) ~= {} and getrawmetatable(args[i2]) ~= nil then continue end
	        	if type(v2) == "string" and type(args[i2]) == "string" and v2 == args[i2] then
	        		return backup(self,...)
	        	end
	        end
	    end
        local DebugTable = {}
        local upvals = {}
        for i,v in pairs(debug.getupvalues(3)) do
        	if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) ~= {} then
        		if typeof(v) == "userdata" then
        			upvals[i] = newproxy(false)
        		else
        			local new_protected_table = {}
        			for i2,v2 in pairs(v) do
        				if i2 == "__index" or i2 == "__newindex" or i2 == "__tostring" then continue end
        				new_protected_table[i2] = v2
        			end
        		end
        	else
        		upvals[i] = v
        	end
        end
        local cons = {}
	    for i,v in pairs(debug.getconstants(3)) do
	    	if (typeof(v) == "table" or typeof(v) == "userdata") and getrawmetatable(v) ~= {} then
	    		if typeof(v) == "userdata" then
	    			cons[i] = newproxy(false)
	    		else
	    			local new_protected_table = {}
	    			for i2,v2 in pairs(v) do
	    				if i2 == "__index" or i2 == "__newindex" or i2 == "__tostring" then continue end
	    				new_protected_table[i2] = v2
	    			end
	    			cons[i] = new_protected_table
	    		end
	    	else
	    		cons[i] = v
	    	end
	    end
        DebugTable = {
            ["Name"] = tostring(getcallingfunction(3)),
            ["Function"] = getcallingfunction(3),
            ["Upvalues"] = upvals,
            ["Constants"] = cons
        }
        local scr = getcallingscript() or getfenv(3)["script"] or "Unknown"
        local RemoteStuff = {
            ["dt"] = DebugTable,
            ["scr"] = scr,
            ["rem"] = self,
            ["args"] = args,
            ["method"] = "InvokeServer",
            ["ToScript"] = ToScript(self,scr,DebugTable.Function,"InvokeServer",unpack(args))
        }
        remote_bindable.Fire(remote_bindable,"OnRemote",RemoteStuff)
    end
    setnamecallmethod(OLD_NC)
    if not spy_it then
    	return backup(self,...)
    end
    local RET_VAL = backup(self,...)
    local DebugTable = {}
    DebugTable = {
        ["Name"] = tostring(getcallingfunction(3)),
        ["Function"] = getcallingfunction(3),
        ["Upvalues"] = upvals,
        ["Constants"] = cons
    }
    local scr = getfenv(3)["script"]
    local Stuff = {
        ["dt"] = DebugTable,
        ["scr"] = scr,
        ["Self"] = self,
        ["Method"] = getnamecallmethod(),
        ["Args"] = args,
        ["Return"] = RET_VAL,
        ["Type"] = 3
    }
    coroutine.resume(coroutine.create(OnScript),Stuff)
    return backup(self,...)
end)
mt.__index = newcclosure(function(tbl,idx)
	if not SRS_ENABLED then return backup2(tbl,idx) end
    if checkcaller() or getcontext() == 6 then return backup2(tbl,idx) end
    if idx == "CFrame" or idx == "Position" then return backup2(tbl,idx) end
    local spy_it = false
    for i,v in pairs(SpiedScripts) do
    	if v == getfenv(3)["script"] then
    		spy_it = true
    		break
    	end
    end
    for i,v in pairs(IgnoredCalls) do
		if tostring(v["Args"][1]) == tostring(tbl) and tostring(v["Args"][2]) == tostring(idx) then
			return backup2(tbl,idx)
		end
	end
    if not spy_it then
    	return backup2(tbl,idx)
    end
    local DebugTable = {}
    DebugTable = {
        ["Name"] = tostring(getcallingfunction(3)),
        ["Function"] = getcallingfunction(3),
        ["Upvalues"] = debug.getupvalues(3),
        ["Constants"] = debug.getconstants(3)
    }
    local scr = getfenv(3)["script"]
    local Stuff = {
        ["dt"] = DebugTable,
        ["scr"] = scr,
        ["Self"] = tbl,
        ["Index"] = idx,
        ["Return"] = backup2(tbl,idx),
        ["Type"] = 1
    }
    coroutine.resume(coroutine.create(OnScript),Stuff)
    return backup2(tbl,idx)
end)
mt.__newindex = newcclosure(function(tbl,idx,val)
	if not SRS_ENABLED then return backup3(tbl,idx,val) end
    if checkcaller() or getcontext() == 6 then return backup3(tbl,idx,val) end
    if idx == "CFrame" or idx == "Position" then return backup3(tbl,idx,val) end
    local spy_it = false
    for i,v in pairs(SpiedScripts) do
    	if v == getfenv(3)["script"] then
    		spy_it = true
    		break
    	end
    end
    for i,v in pairs(IgnoredCalls) do
		if tostring(v["Args"][1]) == tostring(tbl) and tostring(v["Args"][2]) == tostring(idx) then
			return backup3(tbl,idx,val)
		end
	end
    if not spy_it then
    	return backup3(tbl,idx,val)
    end
    local DebugTable = {}
    DebugTable = {
        ["Name"] = tostring(getcallingfunction(3)),
        ["Function"] = getcallingfunction(3),
        ["Upvalues"] = debug.getupvalues(3),
        ["Constants"] = debug.getconstants(3)
    }
    local scr = getfenv(3)["script"]
    local Stuff = {
        ["dt"] = DebugTable,
        ["scr"] = scr,
        ["Self"] = tbl,
        ["Index"] = idx,
        ["Val"] = val,
        ["Type"] = 2
    }
    coroutine.resume(coroutine.create(OnScript),Stuff)
    return backup3(tbl,idx,val)
end)
setreadonly(mt,true)

--// Finish //--

local UserInputService = game:GetService("UserInputService")

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	if yo_chill then return end
	local delta = input.Position - dragStart
	AllFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

AllFrame.InputBegan:Connect(function(input)
	if yo_chill then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = AllFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

AllFrame.InputChanged:Connect(function(input)
	if yo_chill then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if yo_chill then return end
	if input == dragInput and dragging then
		update(input)
	end
end)
