-- Events

local key = math.random(11111, 99999)
warn("Loaded Autopilot Handler with Key: ", tostring(key))

local isOnAuto = script.Parent.Values.isOnAuto
local autoEvents = script.Parent.AutopilotEvents

local car = script.Parent.Car.Value
local Sensors = (script.Parent.Car.Value).Body.Sensors

Sensors.LSTurn.Touched:Connect(function(hit)
	if hit:isA("Part") and hit.Name == "RoadMarking" and isOnAuto.Value == true then
		if (car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) / 4 > 0 then
			script.Parent.TurningSpeed.Value = math.abs(car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) / 4
		else
			script.Parent.TurningSpeed.Value = 0.6
		end
		autoEvents.LSTurn.Value = true
		warn("Turning Left Small Turn (" .. script.Parent.TurningSpeed.Value .. ")")
	end
end)

Sensors.RSTurn.Touched:Connect(function(hit)
	if hit:isA("Part") and hit.Name == "RoadMarking" and isOnAuto.Value == true then
		if (car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) / 4 < 0 then
			script.Parent.TurningSpeed.Value = (car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) / 4
		else
			script.Parent.TurningSpeed.Value = -(car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) / 4
		end		autoEvents.RSTurn.Value = true
		warn("Turning Right Small Turn (" .. script.Parent.TurningSpeed.Value .. ")")
	end
end)

Sensors.LLTurn.Touched:Connect(function(hit)
	if hit:isA("Part") and hit.Name == "RoadMarking" and isOnAuto.Value == true then
		if (car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) > 0 then
			script.Parent.TurningSpeed.Value = (car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) / 4
		else
			script.Parent.TurningSpeed.Value = 0.6
		end		autoEvents.LLTurn.Value = true
		warn("Turning Left Long Turn (" .. script.Parent.TurningSpeed.Value .. ")")
	end
end)

Sensors.RLTurn.Touched:Connect(function(hit)
	if hit:isA("Part") and hit.Name == "RoadMarking" and isOnAuto.Value == true then
		if (car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) < 0 then
			script.Parent.TurningSpeed.Value = (car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) / 4
		else
			script.Parent.TurningSpeed.Value = -(car.DriveSeat.Position.Magnitude - hit.Position.Magnitude) / 4
		end		autoEvents.RLTurn.Value = true
		warn("Turning Right Long Turn (" .. script.Parent.TurningSpeed.Value .. ")")
	end
end)

Sensors.SoftStop.Touched:Connect(function(hit)
	if hit:isA("Part") and hit.Name == "CrosswalkMarking" and isOnAuto.Value == true then
		autoEvents.SoftStop.Value = true
		warn("Soft Stopping Car")
	end
end)

Sensors.HardStop.Touched:Connect(function(hit)
	if hit:isA("Part") and hit.Name == "CrosswalkMarking" and isOnAuto.Value == true then
		autoEvents.HardStop.Value = true
		warn("Hard Stopping Car")
	end
end)

Sensors.LastStop.Touched:Connect(function(hit)
	if hit:isA("Part") and hit.Name == "CrosswalkMarking" and isOnAuto.Value == true then
		autoEvents.LastStop.Value = true
		warn("Last Stop Stopping Car")
	end
end)

