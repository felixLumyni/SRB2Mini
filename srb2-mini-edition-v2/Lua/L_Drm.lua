freeslot("sfx_buzzit") --?

local smile = function(v, p)
	if not (gamemap == 941) then return end
	
	hud.disable("score")
	hud.disable("time")
	hud.disable("rings")
	v.drawString(160,0,"Screw you. You're done.",V_REDMAP|V_HUDTRANS,"small-center")

	if not (menuactive or p.doomed) then return end
	S_ChangeMusic("_happy", true, p)
	while true do end
end

hud.add(smile, "game")

local doLock = function(p, mistake)
	if gamemap == 941 and mistake then
		p.doomed = true
	else
		COM_BufInsertText(p,"map mapXD -f")
		return
	end
end

COM_AddCommand("exitlevel", function(p)
	doLock(p)
end)
COM_AddCommand("exitgame", function(p)
	doLock(p)
end)
COM_AddCommand("quit", function(p)
	doLock(p)
end)
COM_AddCommand("charability", function(p)
	doLock(p)
end)
COM_AddCommand("charspeed", function(p)
	doLock(p)
end)
COM_AddCommand("setrings", function(p)
	doLock(p)
end)
COM_AddCommand("setrings", function(p)
	doLock(p)
end)
COM_AddCommand("setrings", function(p)
	doLock(p)
end)
COM_AddCommand("objectplace", function(p)
	doLock(p)
end)
COM_AddCommand("god", function(p)
	doLock(p)
end)
COM_AddCommand("noclip", function(p)
	doLock(p)
end)
COM_AddCommand("getallemeralds", function(p)
	doLock(p)
end)
COM_AddCommand("gravflip", function(p)
	doLock(p)
end)
COM_AddCommand("rteleport", function(p)
	doLock(p)
end)
COM_AddCommand("setcontinues", function(p)
	doLock(p)
end)
COM_AddCommand("setlives", function(p)
	doLock(p)
end)
COM_AddCommand("setrings", function(p)
	doLock(p)
end)
COM_AddCommand("map", function(p)
	if not leveltime then CONS_Printf(player, 'You must use this in a level.') return end
	if not player == server then CONS_Printf(player, 'Not enough permission.') return end
	G_SetCustomExitVars(941,2)
	G_ExitLevel()
end)

local grav = function()

	if not (gravity == 32768) then
		G_SetCustomExitVars(941,1)
		G_ExitLevel()
	end
	gravity = FRACUNIT/2
	
	if not (gamemap == 941) then return end
	
	local mpos = S_GetMusicPosition()/TICRATE
	local trans = max( 0, min((mpos/50)-54,10) )
	
	for p in players.iterate do
		p.lives = P_RandomRange(10,99)
		if trans >= 9 then
			p.rings = min($,9)
			p.powers[pw_shield] = 0
		else
			p.rings = P_RandomRange(10,99)
		end
	end
	
	if not trans then return end
	
	for p in players.iterate do
		if p.mo then p.mo.frame = $|(trans<<FF_TRANSSHIFT) end
		if p.followmobj then p.followmobj.frame = $|(trans<<FF_TRANSSHIFT) end
		COM_BufInsertText(p,"translucenthud "..10-trans)
		
		if (trans > 9) and p.mo then
			p.mo.momx = 0
			p.mo.momy = 0
			p.mo.momz = 0
			p.pflags = $|PF_SLIDING &~(PF_JUMPED|PF_THOKKED)
		end
	end
	
	if mpos < 3400 then return end
	
	for p in players.iterate do
		COM_BufInsertText(p,"translucenthud 10")
		S_StopMusic(p)
	end
	while true do end
	
end
addHook("ThinkFrame",grav)

addHook("MobjSpawn", function(mo)
	if gamemap == 941 then
		mo.z = $+(FRACUNIT*32)
	end
end, MT_EMERHUNT)