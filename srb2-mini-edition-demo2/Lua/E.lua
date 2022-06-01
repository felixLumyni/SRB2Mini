local SpeedImage = CV_RegisterVar{
	name = "/speedimages",
	defaultvalue = 4,
	flags = CV_NETVAR,
	PossibleValue = {MIN = -10000, MAX = 10000}
}

addHook("PlayerThink", function(p)
	if p.powers[pw_sneakers] and p.mo
		local afterimagine = P_SpawnGhostMobj(p.mo)
	afterimagine.fuse = SpeedImage.value
	end
end)

--test