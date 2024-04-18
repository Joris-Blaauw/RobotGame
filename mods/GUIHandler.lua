function load()
	isMouseJustDown = false
	GuiObjects = {}
	AddGuiObjects({text="TEST", Pos={x=20, y=20}, w=50, h=20, onclick=test})
end

function test()
	ChangeValue("Test", "True")
end

function AddGuiObjects(ObjectData)
	table.insert(GuiObjects, ObjectData)
end

function update(dt)
	MouseX, MouseY = love.mouse.getPosition()
	if love.mouse.isDown(1) then
		if not isMouseJustDown then
			for i,obj in pairs(GuiObjects) do
				if obj.onclick then
					if MouseX > obj.Pos.x and MouseX < obj.Pos.x + obj.w and MouseY > obj.Pos.y and MouseY < obj.Pos.y + obj.h then
						obj.onclick()
					end
				end
			end
		end
	else
		isMouseJustDown = false
	end
end

function draw()
	for i, obj in pairs(GuiObjects) do
		love.graphics.setColor(0, 0, 0, 0.3)
		love.graphics.rectangle("fill", obj.Pos.x, obj.Pos.y, obj.w, obj.h)
		love.graphics.setColor(1,1,1,1)
		love.graphics.print(obj.text, obj.Pos.x + 2, obj.Pos.y + 2)
	end
end

function cmd(CommandArgs)

end

return {load=load,update=update,draw=draw,cmd=cmd}