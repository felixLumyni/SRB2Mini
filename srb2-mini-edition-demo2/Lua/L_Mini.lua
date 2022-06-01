local mini = function(player)
	if not player.mo and player.mo.valid and player.playerstate == PST_LIVE then return end
	
	player.mo.scale = FRACUNIT/4
	if player.rings > 10 and not player.powers[pw_shield] then
		player.rings = $-10
		player.powers[pw_shield] = SH_WHIRLWIND
		P_SpawnShieldOrb(player)	
		S_StartSound(player.mo, sfx_antiri)
		S_StartSound(player.mo, sfx_wirlsg)
	end
	//print("X: "..player.mo.x/FRACUNIT.." Y: "..player.mo.y/FRACUNIT)
end

addHook("PlayerThink",mini)