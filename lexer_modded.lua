local lexer = {}
local yield, wrap  = coroutine.yield, coroutine.wrap
local strfind      = string.find
local strsub       = string.sub
local append       = table.insert
local type         = type
local NUMBER1	= "^[%+%-]?%d+%.?%d*[eE][%+%-]?%d+"
local NUMBER2	= "^[%+%-]?%d+%.?%d*"
local NUMBER3	= "^0x[%da-fA-F]+"
local NUMBER4	= "^%d+%.?%d*[eE][%+%-]?%d+"
local NUMBER5	= "^%d+%.?%d*"
local IDEN		= "^[%a_][%w_]*"
local WSPACE	= "^%s+"
local STRING1	= "^(['\"])%1"							--Empty String
local STRING2	= [[^(['"])(\*)%2%1]]
local STRING3	= [[^(['"]).-[^\](\*)%2%1]]
local STRING4	= "^(['\"]).-.*"						--Incompleted String
local STRING5	= "^%[(=*)%[.-%]%1%]"					--Multiline-String
local STRING6	= "^%[%[.-.*"							--Incompleted Multiline-String
local CHAR1		= "^''"
local CHAR2		= [[^'(\*)%1']]
local CHAR3		= [[^'.-[^\](\*)%1']]
local PREPRO	= "^#.-[^\\]\n"
local MCOMMENT1	= "^%-%-%[(=*)%[.-%]%1%]"				--Completed Multiline-Comment
local MCOMMENT2	= "^%-%-%[%[.-.*"						--Incompleted Multiline-Comment
local SCOMMENT1	= "^%-%-.-\n"							--Completed Singleline-Comment
local SCOMMENT2	= "^%-%-.-.*"							--Incompleted Singleline-Comment

local lua_keyword = {
	["and"] = true,  ["break"] = true,  ["do"] = true,      ["else"] = true,      ["elseif"] = true,
	["end"] = true,  ["false"] = true,  ["for"] = true,     ["function"] = true,  ["if"] = true,
	["in"] = true,   ["local"] = true,  ["nil"] = true,     ["not"] = true,       ["while"] = true,
	["or"] = true,   ["repeat"] = true, ["return"] = true,  ["then"] = true,      ["true"] = true,
	["self"] = true, ["until"] = true,["continue"] = true
}

local lua_builtin = {
	["syn_websocket_close"] = true,
	["firesignal"] = true,
	["makefolder"] = true,
	["syn_io_append"] = true,
	["is_protosmasher_caller"] = true,
	["getsenv"] = true,
	["setrawmetatable"] = true,
	["syn_mouse2press"] = true,
	["debug"] = true,
	["getconstants"] = true,
	["getproto"] = true,
	["profilebegin"] = true,
	["traceback"] = true,
	["getstack"] = true,
	["setmetatable"] = true,
	["getmetatable"] = true,
	["getfenv"] = true,
	["getupvalue"] = true,
	["getupvalues"] = true,
	["getlocals"] = true,
	["getlocal"] = true,
	["setupvaluename"] = true,
	["getconstant"] = true,
	["getprotos"] = true,
	["setstack"] = true,
	["setproto"] = true,
	["profileend"] = true,
	["setlocal"] = true,
	["validlevel"] = true,
	["setupvalue"] = true,
	["setconstant"] = true,
	["getregistry"] = true,
	["getinfo"] = true,
	["syn_io_delfolder"] = true,
	["getrawmetatable"] = true,
	["getinstancefromstate"] = true,
	["syn_io_makefolder"] = true,
	["gethiddenprop"] = true,
	["setfflag"] = true,
	["gethiddenprops"] = true,
	["getcallingscript"] = true,
	["sethiddenprop"] = true,
	["mouse1press"] = true,
	["syn_crypt_b64_encode"] = true,
	["get_instances"] = true,
	["newcclosure"] = true,
	["gethiddenproperties"] = true,
	["getspecialinfo"] = true,
	["isluau"] = true,
	["shared"] = true,
	["cloneref"] = true,
	["setscriptable"] = true,
	["loadstring"] = true,
	["syn_io_isfolder"] = true,
	["hookfunction"] = true,
	["isfile"] = true,
	["getcontext"] = true,
	["print"] = true,
	["protect_function"] = true,
	["isrbxactive"] = true,
	["rconsoleinfo"] = true,
	["make_readonly"] = true,
	["rconsolename"] = true,
	["detour_function"] = true,
	["set_namecall_method"] = true,
	["unlockmodulescript"] = true,
	["get_namecall_method"] = true,
	["syn_getgc"] = true,
	["syn_getloadedmodules"] = true,
	["CheatBlox"] = true,
	["UnlockMetatableOf"] = true,
	["ClickTextButton"] = true,
	["GetLocalCharacter"] = true,
	["GetStackFunction"] = true,
	["Info"] = true,
	["GetLocalPlayer"] = true,
	["Start"] = true,
	["Startup"] = true,
	["DumpFunction"] = true,
	["GetMaxStack"] = true,
	["checkclosure"] = true,
	["syn_mouse2release"] = true,
	["mouse1click"] = true,
	["syn_io_read"] = true,
	["syn_io_delfile"] = true,
	["gethiddenproperty"] = true,
	["identifyexecutor"] = true,
	["getscripts"] = true,
	["get_loaded_modules"] = true,
	["messagebox"] = true,
	["rconsoleerr"] = true,
	["dumpstring"] = true,
	["warn"] = true,
	["getproperties"] = true,
	["keypress"] = true,
	["syn_mousescroll"] = true,
	["getprops"] = true,
	["syn_getinstances"] = true,
	["syn_mouse1click"] = true,
	["get_scripts"] = true,
	["rconsoleclear"] = true,
	["is_redirection_enabled"] = true,
	["syn_context_set"] = true,
	["syn_keyrelease"] = true,
	["syn_io_listdir"] = true,
	["isreadonly"] = true,
	["require"] = true,
	["mouse2click"] = true,
	["sethiddenproperty"] = true,
	["writefile"] = true,
	["get_nil_instances"] = true,
	["loadfile"] = true,
	["getnilinstances"] = true,
	["bit"] = true,
	["bdiv"] = true,
	["badd"] = true,
	["rshift"] = true,
	["band"] = true,
	["bor"] = true,
	["bnot"] = true,
	["bmul"] = true,
	["bswap"] = true,
	["arshift"] = true,
	["tobit"] = true,
	["ror"] = true,
	["rol"] = true,
	["lshift"] = true,
	["tohex"] = true,
	["bxor"] = true,
	["bsub"] = true,
	["syn_setfflag"] = true,
	["syn"] = true,
	["crypt"] = true,
	["encrypt"] = true,
	["decrypt"] = true,
	["derive"] = true,
	["random"] = true,
	["hash"] = true,
	["secrun"] = true,
	["is_beta"] = true,
	["secure_call"] = true,
	["cache_replace"] = true,
	["get_thread_identity"] = true,
	["request"] = true,
	["protect_gui"] = true,
	["run_secure_lua"] = true,
	["cache_invalidate"] = true,
	["queue_on_teleport"] = true,
	["is_cached"] = true,
	["set_thread_identity"] = true,
	["run_secure_function"] = true,
	["websocket"] = true,
	["connect"] = true,
	["unprotect_gui"] = true,
	["write_clipboard"] = true,
	["setclipboard"] = true,
	["setfpscap"] = true,
	["is_synapse_function"] = true,
	["getscriptclosure"] = true,
	["setsimulationradius"] = true,
	["getconnections"] = true,
	["checkcaller"] = true,
	["firetouchinterest"] = true,
	["fireproximityprompt"] = true,
	["hookfunc"] = true,
	["getrenv"] = true,
	["setreadonly"] = true,
	["rconsoleprint"] = true,
	["getstates"] = true,
	["syn_getsenv"] = true,
	["syn_io_isfile"] = true,
	["syn_crypt_encrypt"] = true,
	["syn_mouse1press"] = true,
	["validfgwindow"] = true,
	["saveinstance"] = true,
	["getinstances"] = true,
	["getloadedmodules"] = true,
	["readbinarystring"] = true,
	["_G"] = true,
	["isnetworkowner"] = true,
	["Drawing"] = true,
	["Fonts"] = true,
	["new"] = true,
	["delfile"] = true,
	["mouse1release"] = true,
	["getsynasset"] = true,
	["setnamecallmethod"] = true,
	["syn_getreg"] = true,
	["syn_dumpstring"] = true,
	["syn_websocket_connect"] = true,
	["syn_mousemoverel"] = true,
	["setuntouched"] = true,
	["replaceclosure"] = true,
	["syn_crypt_random"] = true,
	["XPROTECT"] = true,
	["get_calling_script"] = true,
	["appendfile"] = true,
	["isfolder"] = true,
	["delfolder"] = true,
	["getgenv"] = true,
	["keyrelease"] = true,
	["listfiles"] = true,
	["syn_islclosure"] = true,
	["readfile"] = true,
	["getscripthash"] = true,
	["mousescroll"] = true,
	["mousemoveabs"] = true,
	["getcallstack"] = true,
	["mouse2release"] = true,
	["syn_crypt_hash"] = true,
	["clonefunction"] = true,
	["is_protosmasher_closure"] = true,
	["syn_checkcaller"] = true,
	["syn_mouse2click"] = true,
	["mousemoverel"] = true,
	["mouse2press"] = true,
	["syn_mouse1release"] = true,
	["getpcdprop"] = true,
	["islclosure"] = true,
	["rconsolewarn"] = true,
	["getstateenv"] = true,
	["syn_clipboard_set"] = true,
	["syn_crypt_decrypt"] = true,
	["decompile"] = true,
	["getnamecallmethod"] = true,
	["syn_getmenv"] = true,
	["syn_crypt_b64_decode"] = true,
	["is_lclosure"] = true,
	["syn_getrenv"] = true,
	["getpropvalue"] = true,
	["syn_newcclosure"] = true,
	["syn_getgenv"] = true,
	["syn_keypress"] = true,
	["getgc"] = true,
	["syn_decompile"] = true,
	["getpointerfromstate"] = true,
	["isuntouched"] = true,
	["make_writeable"] = true,
	["syn_mousemoveabs"] = true,
	["setpropvalue"] = true,
	["rconsoleinputasync"] = true,
	["setcontext"] = true,
	["printconsole"] = true,
	["fireclickdetector"] = true,
	["syn_getcallingscript"] = true,
	["rconsoleinput"] = true,
	["getmenv"] = true,
	["getreg"] = true,
	["syn_io_write"] = true,
	["messageboxasync"] = true,
	["syn_crypt_derive"] = true,
	["iswindowactive"] = true,
	["syn_websocket_send"] = true,
	["syn_context_get"] = true,
	["syn_isactive"] = true,
	["tostring"] = true,
	["os"] = true,
	["len"] = true,
	["insert"] = true,
	["UDim"] = true,
	["pairs"] = true,
	["assert"] = true,
	["tonumber"] = true,
	["atan2"] = true,
	["format"] = true,
	["randomseed"] = true,
	["coroutine"] = true,
	["reverse"] = true,
	["spawn"] = true,
	["string"] = true,
	["min"] = true,
	["sinh"] = true,
	["abs"] = true,
	["UDim2"] = true,
	["table"] = true,
	["TweenInfo"] = true,
	["Vector3"] = true,
	["status"] = true,
	["rep"] = true,
	["elapsedTime"] = true,
	["sort"] = true,
	["ipairs"] = true,
	["sub"] = true,
	["collectgarbage"] = true,
	["game"] = true,
	["Faces"] = true,
	["Region3"] = true,
	["concat"] = true,
	["asin"] = true,
	["time"] = true,
	["math"] = true,
	["pcall"] = true,
	["dump"] = true,
	["type"] = true,
	["script"] = true,
	["create"] = true,
	["Axes"] = true,
	["ColorSequenceKeypoint"] = true,
	["remove"] = true,
	["fmod"] = true,
	["CFrame"] = true,
	["gcinfo"] = true,
	["tick"] = true,
	["cos"] = true,
	["NumberSequence"] = true,
	["wait"] = true,
	["Color3"] = true,
	["Enum"] = true,
	["difftime"] = true,
	["modf"] = true,
	["rad"] = true,
	["UserSettings"] = true,
	["noise"] = true,
	["NumberRange"] = true,
	["PhysicalProperties"] = true,
	["Ray"] = true,
	["NumberSequenceKeypoint"] = true,
	["Vector2"] = true,
	["delay"] = true,
	["char"] = true,
	["xpcall"] = true,
	["max"] = true,
	["_VERSION"] = true,
	["gsub"] = true,
	["gmatch"] = true,
	["unpack"] = true,
	["ldexp"] = true,
	["match"] = true,
	["lower"] = true,
	["newproxy"] = true,
	["Vector3int16"] = true,
	["next"] = true,
	["byte"] = true,
	["yield"] = true,
	["wrap"] = true,
	["atan"] = true,
	["running"] = true,
	["rawequal"] = true,
	["Region3int16"] = true,
	["resume"] = true,
	["tanh"] = true,
	["tan"] = true,
	["sqrt"] = true,
	["sin"] = true,
	["sign"] = true,
	["pow"] = true,
	["log10"] = true,
	["rawset"] = true,
	["log"] = true,
	["upper"] = true,
	["frexp"] = true,
	["floor"] = true,
	["workspace"] = true,
	["exp"] = true,
	["ColorSequence"] = true,
	["cosh"] = true,
	["clamp"] = true,
	["ceil"] = true,
	["find"] = true,
	["acos"] = true,
	["select"] = true,
	["Instance"] = true,
	["rawget"] = true,
	["Random"] = true,
	["Rect"] = true,
	["BrickColor"] = true,
	["setfenv"] = true,
	["deg"] = true,
	["typeof"] = true,
	["error"] = true,
	["date"] = true,
}

local function tdump(tok)
	return yield(tok, tok)
end

local function ndump(tok)
	return yield("number", tok)
end

local function sdump(tok)
	return yield("string", tok)
end

local function cdump(tok)
	return yield("comment", tok)
end

local function wsdump(tok)
	return yield("space", tok)
end

local function lua_vdump(tok)
	if (lua_keyword[tok]) then
		return yield("keyword", tok)
	elseif (lua_builtin[tok]) then
		return yield("builtin", tok)
	else
		return yield("iden", tok)
	end
end

local lua_matches = {
	{IDEN,      lua_vdump},        -- Indentifiers
	{WSPACE,    wsdump},           -- Whitespace
	{NUMBER3,   ndump},            -- Numbers
	{NUMBER4,   ndump},
	{NUMBER5,   ndump},
	{STRING1,   sdump},            -- Strings
	{STRING2,   sdump},
	{STRING3,   sdump},
	{STRING4,   sdump},
	{STRING5,   sdump},            -- Multiline-Strings
	{STRING6,   sdump},            -- Multiline-Strings
	
	{MCOMMENT1, cdump},            -- Multiline-Comments
	{MCOMMENT2, cdump},			
	{SCOMMENT1, cdump},            -- Singleline-Comments
	{SCOMMENT2, cdump},
	
	{"^==",     tdump},            -- Operators
	{"^~=",     tdump},
	{"^<=",     tdump},
	{"^>=",     tdump},
	{"^%.%.%.", tdump},
	{"^%.%.",   tdump},
	{"^.",      tdump}
}

local num_lua_matches = #lua_matches


--- Create a plain token iterator from a string.
-- @tparam string s a string.
function lexer.scan(s)

	local function lex(first_arg)

		local line_nr = 0
		local sz = #s
		local idx = 1

		-- res is the value used to resume the coroutine.
		local function handle_requests(res)
			while (res) do
				local tp = type(res)
				-- Insert a token list:
				if (tp == "table") then
					res = yield("", "")
					for i = 1,#res do
						local t = res[i]
						res = yield(t[1], t[2])
					end
				elseif (tp == "string") then -- Or search up to some special pattern:
					local i1, i2 = strfind(s, res, idx)
					if (i1) then
						local tok = strsub(s, i1, i2)
						idx = (i2 + 1)
						res = yield("", tok)
					else
						res = yield("", "")
						idx = (sz + 1)
					end
				else
					res = yield(line_nr, idx)
				end
			end
		end

		handle_requests(first_arg)
		line_nr = 1

		while (true) do

			if (idx > sz) then
				while (true) do
					handle_requests(yield())
				end
			end

			for i = 1,num_lua_matches do
				local m = lua_matches[i]
				local pat = m[1]
				local fun = m[2]
				local findres = {strfind(s, pat, idx)}
				local i1, i2 = findres[1], findres[2]
				if (i1) then
					local tok = strsub(s, i1, i2)
					idx = (i2 + 1)
					lexer.finished = (idx > sz)
					local res = fun(tok, findres)
					if (tok:find("\n")) then
						-- Update line number:
						local _,newlines = tok:gsub("\n", {})
						line_nr = (line_nr + newlines)
					end
					handle_requests(res)
					break
				end
			end

		end

	end

	return wrap(lex)

end

return lexer
