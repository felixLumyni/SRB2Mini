freeslot("s_play_ledge_grab", "s_play_ledge_release", "spr2_lgrb", "spr2_lrls")
spr2defaults[SPR2_LGRB] = SPR2_RIDE -- Ledge grab.
spr2defaults[SPR2_LRLS] = SPR2_FALL -- Ledge release.

function A_PlayerRidePAnim(mo, var1, var2)
	local player = mo.player
	if not (player) then return end
	
	player.panim = PA_RIDE
end
function A_PlayerFallPAnim(mo, var1, var2)
	local player = mo.player
	if not (player) then return end
	
	player.panim = PA_FALL
end
states[S_PLAY_LEDGE_GRAB] = {SPR_PLAY, SPR2_LGRB|FF_ANIMATE, 7, A_PlayerRidePAnim, 0, 4, S_PLAY_LEDGE_RELEASE}
states[S_PLAY_LEDGE_RELEASE] = {SPR_PLAY, SPR2_LRLS|FF_ANIMATE, TICRATE/2, A_PlayerFallPAnim, 0, 2, S_PLAY_FALL}

local function updateFollowMobj(p, mobj)
	if not (p and p.mo) then return end
	if (mobj == nil) then mobj = p.followmobj end
	if not (mobj) then return end
	if p.mo.state == S_PLAY_LEDGE_GRAB or p.mo.state == S_PLAY_LEDGE_RELEASE
        mobj.state = S_TAILSOVERLAY_PLUS60DEGREES
		P_TeleportMove(mobj,
		p.mo.x-P_ReturnThrustX(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustX(mobj, mobj.angle, mobj.scale),
		p.mo.y-P_ReturnThrustY(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustY(mobj, mobj.angle, mobj.scale),
		p.mo.z+FixedMul(4*p.mo.scale, mobj.scale)
		)
		mobj.angle = p.drawangle
		return true
    end
end
addHook("FollowMobj", updateFollowMobj)

addHook("MobjMoveBlocked", function(pmo)
	if not (pmo and pmo.valid) then return end
	if (P_IsObjectOnGround(pmo) or pmo.eflags & MFE_JUSTHITFLOOR) then return end
	
	local player = pmo.player
	if not (player and player.valid) then return end
	if P_PlayerInPain(player) then return end
	if player.powers[pw_carry] then return end
	
	if (player.isjettysyn or player.iseggrobo or player.revenge or player.actionstate) then return end -- BattleMod
	
	player.lastlinehit = -1
	player.lastsidehit = -1
	P_SlideMove(pmo)
	player.powers[pw_pushing] = 3
	
	local line = lines[player.lastlinehit]
	if (line and line.valid) then
		if (line.flags & ML_IMPASSIBLE) then return end -- Self explanatory. Nothing can pass it, so don't bother.
		
		local wallangle = R_PointToAngle2(pmo.x, pmo.y, P_ClosestPointOnLine(pmo.x, pmo.y, line))
		local gravitydirection = P_MobjFlip(pmo)
		local playerradius = FixedMul(skins[player.skin].radius, pmo.scale)
		local playerheight = FixedMul(skins[player.skin].height, pmo.scale)
		local playerspinheight = FixedMul(skins[player.skin].spinheight, pmo.scale)
		local playergrabrange = pmo.scale*60
		local playergrabz
		if (gravitydirection > 0) then
			playergrabz = pmo.z + pmo.height - (pmo.scale*10)
		elseif (gravitydirection < 0) then
			playergrabz = pmo.z + (pmo.scale*10)
		else
			return
		end
		
		local linex, liney = P_ClosestPointOnLine(pmo.x, pmo.y, line)
		local ledgex = linex + P_ReturnThrustX(nil, wallangle, playerradius)
		local ledgey = liney + P_ReturnThrustY(nil, wallangle, playerradius)
		local ledgez = pmo.z
		local ledgeheight = pmo.scale*4
		
		local floorz, ceilingz
		if (gravitydirection > 0) then -- Normal gravity.
			floorz = P_FloorzAtPos(ledgex, ledgey, ledgez, playerheight + ledgeheight)
			ceilingz = P_CeilingzAtPos(ledgex, ledgey, ledgez, playerheight + ledgeheight)
		elseif (gravitydirection < 0) then -- Reverse gravity.
			floorz = P_FloorzAtPos(ledgex, ledgey, ledgez, -ledgeheight)
			ceilingz = P_CeilingzAtPos(ledgex, ledgey, ledgez, -ledgeheight)
		else
			-- Failsafe.
			return
		end
		
		if (floorz == ceilingz) then
			-- This is a wall. Don't even DARE grabbing onto it.
			return
		end
		
		if (abs(floorz - ceilingz) <= playerspinheight) -- Can't fit in this space, it's too small!
		or (gravitydirection > 0) and (abs(pmo.z + pmo.height + playerheight) >= pmo.ceilingz) -- We're gonna bonk our head against the ceiling!
		or (gravitydirection < 0) and (abs(pmo.z - playerheight) <= pmo.floorz) -- Same case with ceiling, only in reverse gravity.
		or (gravitydirection == 0) -- Failsafe.
		then
			-- If conditions are met...
			-- ... Then don't bother.
			return
		end
		
		local ledgegrabrange, ledgegrabz
		if (gravitydirection > 0) then -- Normal gravity.
			ledgegrabrange = (playergrabz < floorz) and (playergrabz > (floorz - playergrabrange)) -- Z range where we can grab the ledge.
			ledgegrabz = floorz - playerheight -- Z position we'll snap to when grabbing the ledge.
		elseif (gravitydirection < 0) then -- Inverse gravity.
			ledgegrabrange = (playergrabz > ceilingz) and (playergrabz < (ceilingz + playergrabrange))
			ledgegrabz = ceilingz
		end
		
		if (ledgegrabrange and ledgegrabz)
		and ((pmo.momz*gravitydirection) < (pmo.scale*2))
		and not (player.cmd.buttons & BT_SPIN)
		and not (pmo.state == S_PLAY_LEDGE_RELEASE)
		then
			-- Let's grab onto the ledge if we found one!
			if (pmo.state != S_PLAY_LEDGE_GRAB) then
				S_StartSound(pmo, sfx_s3k4a)
				pmo.state = S_PLAY_LEDGE_GRAB
				P_ResetPlayer(player)
				if (player.actionstate) then player.actionstate = 0 end -- BattleMod.
				if (player.guard) then player.guard = 0 end -- BattleMod.
				if (player.airdodge) then player.airdodge = 0 end -- BattleMod.
			end
			if (pmo.state == S_PLAY_LEDGE_GRAB) then
				pmo.z = ledgegrabz
				pmo.tics = 7 -- Necessary to keep this state from switching to the release state.
				P_InstaThrust(pmo, wallangle, playerradius/4)
				pmo.momz = max(-pmo.scale*2, min($, pmo.scale*2))
				player.drawangle = wallangle
				
				if (player.cmd.buttons & BT_JUMP) then
					-- Execute a jump when we want to get up the ledge.
					P_DoJump(player, true)
				end
			end
			return true
		end
	end
end, MT_PLAYER)