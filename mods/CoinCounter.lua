function load()
	CoinsEnabled = true
end

function update()
	if ChangeValue then
		ChangeValue("Coins", player.Coins)
	end
end

function draw()

end

function cmd(CMDArgs)
	if CMDArgs[1] == "coin" then
		if CoinsEnabled then
			CoinsEnabled = false
		else
			CoinsEnabled = true
		end
		return true
	end
	return false
end

return {load=load,update=update,draw=draw,cmd=cmd}