function load()
	LineSpacing = 14
	InfoElements = {}
	InfoMenuEnabled = true
	ScrollOffset = 0
	ScrollAmount = 14
end

function update()
	ChangeValue("Position", "X = "..player.Position.x.."  -  Y = "..player.Position.y)
	ChangeValue("Velocity", "X = "..player.Velocity.x.."  -  Y = "..player.Velocity.y)
	if love.keyboard.isDown("up") then
		ScrollOffset = ScrollOffset + ScrollAmount
	elseif love.keyboard.isDown("down") then
	    ScrollOffset = ScrollOffset - ScrollAmount
	end
end

function ChangeValue(name, newValue)
	isInList = false
	for i,e in pairs(InfoElements) do
		if e.name == name then
			isInList = true
			InfoElements[i].data = newValue
		end
	end
	if not isInList then
		table.insert(InfoElements, {name=name, data=newValue})
	end
end

function RemoveValue(name)
	for i,e in pairs(InfoElements) do
		if e.name == name then
			table.remove(InfoElements, i)
		end
	end
end

function draw()
	WindowWidth, WindowHeight = love.graphics.getDimensions()
	if InfoMenuEnabled then
		ExtraOffset = 0
		for _,v in pairs(InfoElements) do
			local e = v.data
			local _,lines = string.gsub(e, "\n", "")
			_ = nil
			ExtraOffset = ExtraOffset + lines
		end
		love.graphics.setColor(1,1,1,0.3)
		love.graphics.rectangle("fill", 5, ScrollOffset + (WindowHeight - (5 + ((#InfoElements + ExtraOffset) * LineSpacing))), WindowWidth/3, LineSpacing*(#InfoElements+ExtraOffset))
		love.graphics.setColor(1,1,1,1)
		TotalLines = 0
		for i,E in pairs(InfoElements) do
			local _,lines = string.gsub(E.data, "\n", "")
			_ = nil
			TotalLines = TotalLines + lines
			love.graphics.print(E.name..": "..tostring(E.data), 8, ScrollOffset + (WindowHeight - (5 + (LineSpacing * (i + TotalLines)))))
		end
	end
end

function cmd(CMDArgs)
	if CMDArgs[1] == "info" then
		if InfoMenuEnabled then
			InfoMenuEnabled = false
		else
			InfoMenuEnabled = true
		end
	else
		return false
	end
	return true
end

return {load=load,update=update,draw=draw,cmd=cmd}