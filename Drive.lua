--[[
		___      _______                _     
	   / _ |____/ ___/ /  ___ ____ ___ (_)__ 
	  / __ /___/ /__/ _ \/ _ `(_-<(_-</ (_-<
	 /_/ |_|   \___/_//_/\_,_/___/___/_/___/
 						SecondLogic @ Inspare


*I assume you know what you're doing if you're gonna change something here.* ]]--

--[[START]]

	script.Parent:WaitForChild("Car")
	script.Parent:WaitForChild("IsOn")
	script.Parent:WaitForChild("ControlsOpen")
	script.Parent:WaitForChild("Values")

--[[Dependencies]]

	local player = game.Players.LocalPlayer
	local mouse = player:GetMouse()
	local UserInputService = game:GetService("UserInputService")
	local car = script.Parent.Car.Value
	local _Tune = require(car["A-Chassis Tune"])

--[[Output Scaling Factor]]

	local hpScaling = _Tune.WeightScaling*10
	local FBrakeForce = _Tune.FBrakeForce
	local RBrakeForce = _Tune.RBrakeForce
	local PBrakeForce = _Tune.PBrakeForce
	if not workspace:PGSIsEnabled() then
		hpScaling = _Tune.LegacyScaling*10
		FBrakeForce = _Tune.FLgcyBForce
		RBrakeForce = _Tune.RLgcyBForce
		PBrakeForce = _Tune.LgcyPBForce
	end

--[[Status Vars]]

	local _IsOn = _Tune.AutoStart
	if _Tune.AutoStart then script.Parent.IsOn.Value=true end
	
	local _GSteerT=0
	local _GSteerC=0
	local _GThrot=0
	local _GThrotShift=1
	local _GBrake=0
	
	local _ClutchOn = true
	local _ClPressing = false
	local _RPM = 0
	local _HP = 0
	local _OutTorque = 0
	local _CGear = 0
	local _PGear = _CGear
	local _spLimit = 0
	
	local _Boost = 0
	local _TCount = 0
	local _TPsi = 0
	local _BH = 0
	local _BT = 0
	local _NH = 0
	local _NT = 0
	
	local _TMode = _Tune.TransModes[1]
	
	local _MSteer = false
	local _SteerL = false
	local _SteerR = false
	local _PBrake = false
	local _TCS = _Tune.TCSEnabled
	local _TCSActive = false
	local _TCSAmt = 0
	local _ABS = _Tune.ABSEnabled
	local _ABSActive = false
	
	local FlipWait=tick()
	local FlipDB=false
	
	local _InControls = false


--[[Shutdown]]

	car.DriveSeat.ChildRemoved:connect(function(child) if child.Name=="SeatWeld" and child:IsA("Weld") then script.Parent:Destroy() end end)

-- [[Autopilot Controls]] --

	local autoEvents = script.Parent.AutopilotEvents   
	local aCritical = script.Parent.AutopilotCritical
	

	autoEvents.LSTurn.Changed:Connect(function()
		if autoEvents.LSTurn.Value == true and script.Parent.Values.isOnAuto.Value == true then
				  
				_GSteerT = tonumber(script.Parent.TurningSpeed.Value)
				_SteerR = true
				wait(.3)
				_GSteerT = 0
				_SteerR = false
				autoEvents.LSTurn.Value = false
				  
				warn("Made Left Small Turn")	
			end	
		end)

	autoEvents.RSTurn.Changed:Connect(function()
		if autoEvents.RSTurn.Value == true and script.Parent.Values.isOnAuto.Value == true then
				  
				_GSteerT = tonumber(script.Parent.TurningSpeed.Value)
				_SteerL = true
				wait(.3)
				_GSteerT = 0
				_SteerL = false
				autoEvents.RSTurn.Value = false
				  	
				warn("Made Right Small Turn")
			end	
		end)

	autoEvents.LLTurn.Changed:Connect(function()
		if autoEvents.LLTurn.Value == true and script.Parent.Values.isOnAuto.Value == true   then
				  
				_GSteerT = tonumber(script.Parent.TurningSpeed.Value)
				_SteerR = true
				wait(.3)
				_GSteerT = 0
				_SteerR = false
				autoEvents.LLTurn.Value = false
				  	
				warn("Made Left Long Turn")
			end	
		end)

	autoEvents.RLTurn.Changed:Connect(function()
		if autoEvents.RLTurn.Value == true and script.Parent.Values.isOnAuto.Value == true   then
				  
				_GSteerT = tonumber(script.Parent.TurningSpeed.Value)
				_SteerL = true
				wait(.3)
				_GSteerT = 0
				_SteerL = false
				autoEvents.RLTurn.Value = false
				  	
				warn("Made Right Long Turn")
			end	
		end)

	autoEvents.SoftStop.Changed:Connect(function()
		if autoEvents.SoftStop.Value == true and script.Parent.Values.isOnAuto.Value == true   then	
				  
				_PBrake = true
				wait(.5)
				_PBrake = false
				autoEvents.SoftStop.Value = false
				  
				warn("Made Soft Stop")
			end
		end)

	autoEvents.HardStop.Changed:Connect(function()
		if autoEvents.SoftStop.Value == true and script.Parent.Values.isOnAuto.Value == true then	
				_PBrake = true
				wait(.2)
				_PBrake = false
				wait(.2)
				_PBrake  = true
				wait(.2)
				_PBrake = false
				_GBrake = 3
				autoEvents.SoftStop.Value = false
				warn("Made Hard Stop")
			end	
		end)

	autoEvents.LastStop.Changed:Connect(function()
		if autoEvents.LastStop.Value == true and script.Parent.Values.isOnAuto.Value == true then	
				_PBrake = true
				wait(.2)
				_PBrake = false
				wait(.2)
				_PBrake  = true
				wait(.2)
				_PBrake = true
				_GBrake = 0
				autoEvents.LastStop.Value = false
				warn("Made Last Stop")
				wait(.2)
				warn("Started Alarm ID: " .. math.random(1111, 9999))
				wait(.2)
				aCritical:Play()
				wait(2)
				_PBrake = false
				aCritical:Stop()
			end
		end)

	autoEvents.PartialStop.Changed:Connect(function()
		if autoEvents.LastStop.Value == true and script.Parent.Values.isOnAuto.Value == true then	
				_PBrake = true
				wait(.2)
				_PBrake = false
				wait(.2)
				_PBrake  = true
				wait(.2)
				_PBrake = false
				_GBrake = 4
				autoEvents.LastStop.Value = false
				warn("Made Partial Stop")
			end
		end)



--[[Controls]]

	local _CTRL = _Tune.Controls
	local Controls = Instance.new("Folder",script.Parent)
	Controls.Name = "Controls"
	for i,v in pairs(_CTRL) do
		local a=Instance.new("StringValue",Controls)
		a.Name=i
		a.Value=v.Name
		a.Changed:connect(function()
			if i=="MouseThrottle" or i=="MouseBrake" then
				if a.Value == "MouseButton1" or a.Value == "MouseButton2" then
					_CTRL[i]=Enum.UserInputType[a.Value]
				else
					_CTRL[i]=Enum.KeyCode[a.Value]
				end
			else
				_CTRL[i]=Enum.KeyCode[a.Value]
			end
		end)
	end
	
	--Deadzone Adjust
	local _PPH = _Tune.Peripherals
		for i,v in pairs(_PPH) do
		local a = Instance.new("IntValue",Controls)
		a.Name = i
		a.Value = v
		a.Changed:connect(function() 
			a.Value=math.min(100,math.max(0,a.Value))
			_PPH[i] = a.Value
		end)
	end
	
	--Input Handler
	function DealWithInput(input,IsRobloxFunction)
		if (UserInputService:GetFocusedTextBox()==nil) and not _InControls then --Ignore when UI Focus
			--Shift Down [Manual Transmission]
			if _IsOn and  (input.KeyCode ==_CTRL["ContlrShiftDown"] or (_MSteer and input.KeyCode==_CTRL["MouseShiftDown"]) or ((not _MSteer) and input.KeyCode==_CTRL["ShiftDown"])) and ((_TMode=="Auto" and _CGear<=1) or _TMode=="Semi" or (_TMode=="Manual" and (not _ClutchOn))) and input.UserInputState == Enum.UserInputState.Begin then
				if _CGear == 0 then _ClutchOn = true end
				if (_CGear ~= 0 and (_CGear ~= ((#_Tune.Ratios-3)-(#_Tune.Ratios-2)))) and _TMode=="Semi" then
					_GThrotShift = 0
					wait(_Tune.ShiftTime/2)
					_GThrotShift = 1
				end
				_CGear = math.max(_CGear-1,-1)
				if not _TMode=="Manual" then _ClutchOn = true end
				
			--Shift Up [Manual Transmission]
			elseif _IsOn and  (input.KeyCode ==_CTRL["ContlrShiftUp"] or (_MSteer and input.KeyCode==_CTRL["MouseShiftUp"]) or ((not _MSteer) and input.KeyCode==_CTRL["ShiftUp"])) and ((_TMode=="Auto" and _CGear<1) or _TMode=="Semi" or (_TMode=="Manual" and (not _ClutchOn))) and input.UserInputState == Enum.UserInputState.Begin then
				if _CGear == 0 then _ClutchOn = true end
				if ((_CGear ~= 0) and (_CGear ~= #_Tune.Ratios-2)) and _TMode=="Semi" then
					_GThrotShift = 0
					wait(_Tune.ShiftTime)
					_GThrotShift = 1
				end
				_CGear = math.min(_CGear+1,#_Tune.Ratios-2)
				if not _TMode=="Manual" then _ClutchOn = true end
				
			--Toggle Clutch
			elseif _IsOn and  (input.KeyCode ==_CTRL["ContlrClutch"] or (_MSteer and input.KeyCode==_CTRL["MouseClutch"]) or ((not _MSteer) and input.KeyCode==_CTRL["Clutch"])) and _TMode=="Manual" then
				if input.UserInputState == Enum.UserInputState.Begin then
					_ClutchOn = false
					_ClPressing = true
				elseif input.UserInputState == Enum.UserInputState.End then
					_ClutchOn = true
					_ClPressing = false
				end
				
			--Toggle PBrake
			elseif _IsOn and  input.KeyCode ==_CTRL["ContlrPBrake"] or (_MSteer and input.KeyCode==_CTRL["MousePBrake"]) or ((not _MSteer) and input.KeyCode==_CTRL["PBrake"]) then
				if input.UserInputState == Enum.UserInputState.Begin then
					_PBrake = not _PBrake
				elseif input.UserInputState == Enum.UserInputState.End then
					if car.DriveSeat.Velocity.Magnitude>5 then _PBrake = false end
				end
				
			--Toggle Transmission Mode
			elseif (input.KeyCode == _CTRL["ContlrToggleTMode"] or input.KeyCode==_CTRL["ToggleTransMode"]) and input.UserInputState == Enum.UserInputState.Begin then
				local n=1
				for i,v in pairs(_Tune.TransModes) do
					if v==_TMode then n=i break end
				end
				n=n+1
				if n>#_Tune.TransModes then n=1 end
				_TMode = _Tune.TransModes[n]
				
			--Throttle
			elseif _IsOn and ((not _MSteer) and (input.KeyCode==_CTRL["Throttle"] or input.KeyCode == _CTRL["Throttle2"])) or ((((_CTRL["MouseThrottle"]==Enum.UserInputType.MouseButton1 or _CTRL["MouseThrottle"]==Enum.UserInputType.MouseButton2) and input.UserInputType == _CTRL["MouseThrottle"]) or input.KeyCode == _CTRL["MouseThrottle"])and _MSteer) then
				if input.UserInputState == Enum.UserInputState.Begin then
					_GThrot = 1
				else
					_GThrot = _Tune.IdleThrottle/100
				end
				
			--Brake
			elseif ((not _MSteer) and (input.KeyCode==_CTRL["Brake"] or input.KeyCode == _CTRL["Brake2"])) or ((((_CTRL["MouseBrake"]==Enum.UserInputType.MouseButton1 or _CTRL["MouseBrake"]==Enum.UserInputType.MouseButton2) and input.UserInputType == _CTRL["MouseBrake"]) or input.KeyCode == _CTRL["MouseBrake"])and _MSteer) then
				if input.UserInputState == Enum.UserInputState.Begin then
					_GBrake = 1
				else
					_GBrake = 0
				end
				
			--Steer Left
			elseif (not _MSteer) and (input.KeyCode==_CTRL["SteerLeft"] or input.KeyCode == _CTRL["SteerLeft2"]) then
				if input.UserInputState == Enum.UserInputState.Begin then
					_GSteerT = -1
					_SteerL = true
				else
					if _SteerR then
						_GSteerT = 1
					else
						_GSteerT = 0
					end
					_SteerL = false
				end
				
			--Steer Right
			elseif (not _MSteer) and (input.KeyCode==_CTRL["SteerRight"] or input.KeyCode == _CTRL["SteerRight2"]) then
				if input.UserInputState == Enum.UserInputState.Begin then
					_GSteerT = 1
					_SteerR = true
				else
					if _SteerL then
						_GSteerT = -1
					else
						_GSteerT = 0
					end
					_SteerR = false
				end
				
			--Toggle Mouse Controls
			elseif input.KeyCode ==_CTRL["ToggleMouseDrive"] then
				if input.UserInputState == Enum.UserInputState.End then
					_MSteer = not _MSteer
					_GThrot = _Tune.IdleThrottle/100
					_GBrake = 0
					_GSteerT = 0
					_ClutchOn = true
				end
				
			--Toggle TCS
			elseif _Tune.TCSEnabled and _IsOn and input.KeyCode == _CTRL["ToggleTCS"] or input.KeyCode == _CTRL["ContlrToggleTCS"] then
				if input.UserInputState == Enum.UserInputState.End then _TCS = not _TCS end
			
			--Toggle ABS
			elseif _Tune.ABSEnabled and _IsOn and input.KeyCode == _CTRL["ToggleABS"] or input.KeyCode == _CTRL["ContlrToggleABS"] then
				if input.UserInputState == Enum.UserInputState.End then _ABS = not _ABS end
				
			end
			
			--Variable Controls
			if input.UserInputType.Name:find("Gamepad") then
				--Gamepad Steering
				if input.KeyCode == _CTRL["ContlrSteer"] then
					if input.Position.X>= 0 then
						local cDZone = math.min(.99,_Tune.Peripherals.ControlRDZone/100)
						if math.abs(input.Position.X)>cDZone then
							_GSteerT = (input.Position.X-cDZone)/(1-cDZone)
						else
							_GSteerT = 0
						end
					else
						local cDZone = math.min(.99,_Tune.Peripherals.ControlLDZone/100)
						if math.abs(input.Position.X)>cDZone then
							_GSteerT = (input.Position.X+cDZone)/(1-cDZone)
						else
							_GSteerT = 0
						end
					end
					
				--Gamepad Throttle
				elseif _IsOn and input.KeyCode == _CTRL["ContlrThrottle"] then
					_GThrot = math.max(_Tune.IdleThrottle/100,input.Position.Z)
					
				--Gamepad Brake
				elseif input.KeyCode == _CTRL["ContlrBrake"] then
					_GBrake = input.Position.Z
				end
			end
		else
			_GThrot = _Tune.IdleThrottle/100
			_GSteerT = 0
			_GBrake = 0
			if _CGear~=0 then _ClutchOn = true end
		end
	end
	UserInputService.InputBegan:connect(DealWithInput)
	UserInputService.InputChanged:connect(DealWithInput)
	UserInputService.InputEnded:connect(DealWithInput)



--[[Drivetrain Initialize]]

	local Drive={}
	
	--Power Front Wheels
		if _Tune.Config == "FWD" or _Tune.Config == "AWD" then for i,v in pairs(car.Wheels:GetChildren()) do if v.Name=="FL" or v.Name=="FR" or v.Name=="F" then table.insert(Drive,v) end end end
	
	--Power Rear Wheels
		if _Tune.Config == "RWD" or _Tune.Config == "AWD" then for i,v in pairs(car.Wheels:GetChildren()) do if v.Name=="RL" or v.Name=="RR" or v.Name=="R" then table.insert(Drive,v) end end end
	
	--Determine Wheel Size
	local wDia = 0 for i,v in pairs(Drive) do if v.Size.x>wDia then wDia = v.Size.x end end
	
	--Pre-Toggled PBrake
	for i,v in pairs(car.Wheels:GetChildren()) do if math.abs(v["#AV"].maxTorque.Magnitude-PBrakeForce)<1 then _PBrake=true end end
	
	

--[[Steering]]

	function Steering()
		--Mouse Steer
		if _MSteer then
			local msWidth = math.max(1,mouse.ViewSizeX*_Tune.Peripherals.MSteerWidth/200)
			local mdZone = _Tune.Peripherals.MSteerDZone/100
			local mST = ((mouse.X-mouse.ViewSizeX/2)/msWidth)
			if math.abs(mST)<=mdZone then
				_GSteerT = 0
			else
				_GSteerT = (math.max(math.min((math.abs(mST)-mdZone),(1-mdZone)),0)/(1-mdZone))^_Tune.MSteerExp * (mST / math.abs(mST))
			end
		end
		
		--Interpolate Steering
		if _GSteerC < _GSteerT then
			if _GSteerC<0 then
				_GSteerC = math.min(_GSteerT,_GSteerC+_Tune.ReturnSpeed)
			else
				_GSteerC = math.min(_GSteerT,_GSteerC+_Tune.SteerSpeed)
			end
		else
			if _GSteerC>0 then
				_GSteerC = math.max(_GSteerT,_GSteerC-_Tune.ReturnSpeed)
			else
				_GSteerC = math.max(_GSteerT,_GSteerC-_Tune.SteerSpeed)
			end
		end
		
		--Steer Decay Multiplier
		local sDecay = (1-math.min(car.DriveSeat.Velocity.Magnitude/_Tune.SteerDecay,1-(_Tune.MinSteer/100)))
		
		--Apply Steering
		for i,v in pairs(car.Wheels:GetChildren()) do
			if v.Name=="F" then
				v.Arm.Steer.CFrame=car.Wheels.F.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*_Tune.SteerInner*sDecay),0)
			elseif v.Name=="FL" then
				if _GSteerC>= 0 then
					v.Arm.Steer.CFrame=car.Wheels.FL.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*_Tune.SteerOuter*sDecay),0)
				else
					v.Arm.Steer.CFrame=car.Wheels.FL.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*_Tune.SteerInner*sDecay),0)
				end
			elseif v.Name=="FR" then
				if _GSteerC>= 0 then
					v.Arm.Steer.CFrame=car.Wheels.FR.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*_Tune.SteerInner*sDecay),0)
				else
					v.Arm.Steer.CFrame=car.Wheels.FR.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*_Tune.SteerOuter*sDecay),0)
				end
			end
		end
	end



--[[Engine]]

	local fFD = _Tune.FinalDrive*_Tune.FDMult
	local fFDr = fFD*30/math.pi
	local cGrav = workspace.Gravity*_Tune.InclineComp/32.2
	local wDRatio = wDia*math.pi/60
	local cfWRot = CFrame.Angles(math.pi/2,-math.pi/2,0)
	local cfYRot = CFrame.Angles(0,math.pi,0)
	local rtTwo = (2^.5)/2
	
	if _Tune.Aspiration == "Single" then
		_TCount = 1
		_TPsi = _Tune.Boost
	elseif _Tune.Aspiration == "Double" then
		_TCount = 2
		_TPsi = _Tune.Boost*2
	end

	--Horsepower Curve
	
	
	local HP=_Tune.Horsepower/100
	local HP_B=((_Tune.Horsepower*((_TPsi)*(_Tune.CompressRatio/10))/7.5)/2)/100
	local Peak=_Tune.PeakRPM/1000
	local Sharpness=_Tune.PeakSharpness
	local CurveMult=_Tune.CurveMult
	local EQ=_Tune.EqPoint/1000
	
	--Horsepower Curve
	
	function curveHP(RPM)
		RPM=RPM/1000
		return ((-(RPM-Peak)^2)*math.min(HP/(Peak^2),CurveMult^(Peak/HP))+HP)*(RPM-((RPM^Sharpness)/(Sharpness*Peak^(Sharpness-1))))
	end
	
	local PeakCurveHP = curveHP(_Tune.PeakRPM)
	
	function curvePSI(RPM)
		RPM=RPM/1000
		return ((-(RPM-Peak)^2)*math.min(HP_B/(Peak^2),CurveMult^(Peak/HP_B))+HP_B)*(RPM-((RPM^Sharpness)/(Sharpness*Peak^(Sharpness-1))))
	end
	local PeakCurvePSI = curvePSI(_Tune.PeakRPM)
	
	--Plot Current Horsepower
	function GetCurve(x,gear)
		local hp=(math.max(curveHP(x)/(PeakCurveHP/HP),0))*100
		return hp,((hp*(EQ/x))*_Tune.Ratios[gear+2]*fFD*hpScaling)*1000
	end
	
	--Plot Current Boost (addition to Horsepower)
	function GetPsiCurve(x,gear)
		local hp=(math.max(curvePSI(x)/(PeakCurvePSI/HP_B),0))*100
		return hp,((hp*(EQ/x))*_Tune.Ratios[gear+2]*fFD*hpScaling)*1000
	end	
	
	--Output Cache	
	local HPCache = {}
	local PSICache = {}
	
	for gear,ratio in pairs(_Tune.Ratios) do
		local nhpPlot = {}
		local bhpPlot = {}
		for rpm = math.floor(_Tune.IdleRPM/100),math.ceil((_Tune.Redline+100)/100) do
			local ntqPlot = {}
			local btqPlot = {}
			ntqPlot.Horsepower,ntqPlot.Torque = GetCurve(rpm*100,gear-2)
			btqPlot.Horsepower,btqPlot.Torque = GetPsiCurve(rpm*100,gear-2)
			hp1,tq1 = GetCurve((rpm+1)*100,gear-2)
			hp2,tq2 = GetPsiCurve((rpm+1)*100,gear-2)
			ntqPlot.HpSlope = (hp1 - ntqPlot.Horsepower)
			btqPlot.HpSlope = (hp2 - btqPlot.Horsepower)
			ntqPlot.TqSlope = (tq1 - ntqPlot.Torque)
			btqPlot.TqSlope = (tq2 - btqPlot.Torque)
			nhpPlot[rpm] = ntqPlot
			bhpPlot[rpm] = btqPlot
		end
		table.insert(HPCache,nhpPlot)
		table.insert(PSICache,bhpPlot)
	end

	--Powertrain
	wait()

	--Automatic Transmission
	function Auto()
		local maxSpin=0
		for i,v in pairs(Drive) do if v.RotVelocity.Magnitude>maxSpin then maxSpin = v.RotVelocity.Magnitude end end
		if _IsOn then
			_ClutchOn = true
			if _CGear >= 1 then
				if _GBrake > 0  and car.DriveSeat.Velocity.Magnitude < 5 then
					_CGear = 1
				else
					if _Tune.AutoShiftMode == "RPM" then
						if _RPM>(_Tune.PeakRPM+_Tune.AutoUpThresh) then
							if (_CGear ~= 0) and (_CGear ~= #_Tune.Ratios-2) then
								_GThrotShift = 0
								wait(_Tune.ShiftTime)
								_GThrotShift = 1
							end
							_CGear=math.min(_CGear+1,#_Tune.Ratios-2) 
						elseif math.max(math.min(maxSpin*_Tune.Ratios[_CGear+1]*fFDr,_Tune.Redline+100),_Tune.IdleRPM)<(_Tune.PeakRPM-_Tune.AutoDownThresh) then
							if _CGear ~= 1 then
								_GThrotShift = 0
								wait(_Tune.ShiftTime/2)
								_GThrotShift = 1
							end
							_CGear=math.max(_CGear-1,1)
						end
					else
						if car.DriveSeat.Velocity.Magnitude > math.ceil(wDRatio*(_Tune.PeakRPM+_Tune.AutoUpThresh)/_Tune.Ratios[_CGear+2]/fFD) then
							if (_CGear ~= 0) and (_CGear ~= #_Tune.Ratios-2) then
								_GThrotShift = 0
								wait(_Tune.ShiftTime)
								_GThrotShift = 1
							end
							_CGear=math.min(_CGear+1,#_Tune.Ratios-2)
						elseif car.DriveSeat.Velocity.Magnitude < math.ceil(wDRatio*(_Tune.PeakRPM-_Tune.AutoDownThresh)/_Tune.Ratios[_CGear+1]/fFD) then
							if _CGear ~= 1 then
								_GThrotShift = 0
								wait(_Tune.ShiftTime/2)
								_GThrotShift = 1
							end
							_CGear=math.max(_CGear-1,1)
						end
					end
				end
			end
		end 
	end
	
	local tqTCS = 1
	--Apply Power
	function Engine()
		--Neutral Gear
		if _CGear==0 then _ClutchOn = false end
	
		--Car Is Off
		local revMin = _Tune.IdleRPM
		if not _IsOn then 
			revMin = 0 
			_CGear = 0
			_ClutchOn = false
			_GThrot = _Tune.IdleThrottle/100
		end
		
		--Determine RPM
		local maxSpin=0
		local maxCount=0
		for i,v in pairs(Drive) do maxSpin = maxSpin + v.RotVelocity.Magnitude maxCount = maxCount + 1 end
		maxSpin=maxSpin/maxCount
		
		if _ClutchOn then
			local aRPM = math.max(math.min(maxSpin*_Tune.Ratios[_CGear+2]*fFDr,_Tune.Redline+100),revMin)
			local clutchP = math.min(math.abs(aRPM-_RPM)/_Tune.ClutchTol,.9)
			_RPM = _RPM*clutchP  +  aRPM*(1-clutchP)
		else
			if _GThrot-(_Tune.IdleThrottle/100)>0 then
				if _RPM>_Tune.Redline then
					_RPM = _RPM-_Tune.RevBounce*2
				else
					_RPM = math.min(_RPM+_Tune.RevAccel*_GThrot,_Tune.Redline+100)
				end
			else
				_RPM = math.max(_RPM-_Tune.RevDecay,revMin)
			end
		end
		
		--Rev Limiter
		_spLimit = (_Tune.Redline+100)/(fFDr*_Tune.Ratios[_CGear+2])
		if _RPM>_Tune.Redline then 
			if _CGear<#_Tune.Ratios-2 then
				_RPM = _RPM-_Tune.RevBounce
			else
				_RPM = _RPM-_Tune.RevBounce*.5
			end
		end
		
		local TPsi = _TPsi/_TCount
		_Boost = _Boost + ((((((_HP*(_GThrot*1.2)/_Tune.Horsepower)/8)-(((_Boost/TPsi*(TPsi/15)))))*((36/_Tune.TurboSize)*2))/TPsi)*15)
		if _Boost < 0.05 then _Boost = 0.05 elseif _Boost > 2 then _Boost = 2 end
		
		local cTq = HPCache[_CGear+2][math.floor(math.min(_Tune.Redline,math.max(_Tune.IdleRPM,_RPM))/100)]
		_NH = cTq.Horsepower+(cTq.HpSlope*((_RPM-math.floor(_RPM/100))/1000)%1)
		_NT = cTq.Torque+(cTq.TqSlope*((_RPM-math.floor(_RPM/100))/1000)%1)
		if _Tune.Aspiration ~= "Natural" then
			local bTq = PSICache[_CGear+2][math.floor(math.min(_Tune.Redline,math.max(_Tune.IdleRPM,_RPM))/100)]
			_BH = bTq.Horsepower+(bTq.HpSlope*((_RPM-math.floor(_RPM/100))/1000)%1)
			_BT = bTq.Torque+(bTq.TqSlope*((_RPM-math.floor(_RPM/100))/1000)%1)
			_HP = _NH + (_BH*(_Boost/2))
			_OutTorque = _NT + (_BT*(_Boost/2))
		else
			_HP = _NH
			_OutTorque = _NT
		end
		
		local iComp =(car.DriveSeat.CFrame.lookVector.y)*cGrav
		if _CGear==-1 then iComp=-iComp end
		_OutTorque = _OutTorque*math.max(1,(1+iComp))
		
		--Average Rotational Speed Calculation
		local fwspeed=0
		local fwcount=0
		local rwspeed=0
		local rwcount=0
		
		for i,v in pairs(car.Wheels:GetChildren()) do
			if v.Name=="FL" or v.Name=="FR" or v.Name == "F" then
				fwspeed=fwspeed+v.RotVelocity.Magnitude
				fwcount=fwcount+1
			elseif v.Name=="RL" or v.Name=="RR" or v.Name == "R" then
				rwspeed=rwspeed+v.RotVelocity.Magnitude
				rwcount=rwcount+1
			end
		end
		fwspeed=fwspeed/fwcount
		rwspeed=rwspeed/rwcount	
		local cwspeed=(fwspeed+rwspeed)/2
		
		--Update Wheels
		for i,v in pairs(car.Wheels:GetChildren()) do
			--Reference Wheel Orientation
			local Ref=(CFrame.new(v.Position-((v.Arm.CFrame*cfWRot).lookVector),v.Position)*cfYRot).lookVector
			local aRef=1
			local diffMult=1
			if v.Name=="FL" or v.Name=="RL" then aRef=-1 end
			
			--AWD Torque Scaling
			if _Tune.Config == "AWD" then _OutTorque = _OutTorque*rtTwo end
			
			--Differential/Torque-Vectoring
			if v.Name=="FL" or v.Name=="FR" then
				diffMult=math.max(0,math.min(1,1+((((v.RotVelocity.Magnitude-fwspeed)/fwspeed)/(math.max(_Tune.FDiffSlipThres,1)/100))*((_Tune.FDiffLockThres-50)/50))))
				if _Tune.Config == "AWD" then
					diffMult=math.max(0,math.min(1,diffMult*(1+((((fwspeed-cwspeed)/cwspeed)/(math.max(_Tune.CDiffSlipThres,1)/100))*((_Tune.CDiffLockThres-50)/50)))))
				end
			elseif v.Name=="RL" or v.Name=="RR" then
				diffMult=math.max(0,math.min(1,1+((((v.RotVelocity.Magnitude-rwspeed)/rwspeed)/(math.max(_Tune.RDiffSlipThres,1)/100))*((_Tune.RDiffLockThres-50)/50))))
				if _Tune.Config == "AWD" then
					diffMult=math.max(0,math.min(1,diffMult*(1+((((rwspeed-cwspeed)/cwspeed)/(math.max(_Tune.CDiffSlipThres,1)/100))*((_Tune.CDiffLockThres-50)/50)))))
				end
			end
			
			_TCSActive = false
			_ABSActive = false
			--Output
			if _PBrake and (v.Name=="RR" or v.Name=="RL") then
				--PBrake
				v["#AV"].maxTorque=Vector3.new(math.abs(Ref.x),math.abs(Ref.y),math.abs(Ref.z))*PBrakeForce
				v["#AV"].angularvelocity=Vector3.new()
			else
				--Apply Power
				if _GBrake==0 then
					local driven = false
					for _,a in pairs(Drive) do if a==v then driven = true end end
					if driven then
						local on=1
						if not script.Parent.IsOn.Value then on=0 end
						local clutch=1
						if not _ClutchOn then clutch=0 end
						local throt = _GThrot * _GThrotShift
						
						--Apply TCS
						tqTCS = 1
						if _TCS then
							tqTCS = 1-(math.min(math.max(0,math.abs(v.RotVelocity.Magnitude*(v.Size.x/2) - v.Velocity.Magnitude)-_Tune.TCSThreshold)/_Tune.TCSGradient,1)*(1-(_Tune.TCSLimit/100)))
						end
						if tqTCS < 1 then
							_TCSAmt = tqTCS
							_TCSActive = true
						end
						
						--Update Forces
						local dir=1
						if _CGear==-1 then dir = -1 end
						v["#AV"].maxTorque=Vector3.new(math.abs(Ref.x),math.abs(Ref.y),math.abs(Ref.z))*_OutTorque*(1+(v.RotVelocity.Magnitude/60)^1.15)*throt*tqTCS*diffMult*on*clutch
						v["#AV"].angularvelocity=Ref*aRef*_spLimit*dir
					else
						v["#AV"].maxTorque=Vector3.new()
						v["#AV"].angularvelocity=Vector3.new()
					end
					
				--Brakes
				else
					local brake = _GBrake
					
					--Apply ABS
					local tqABS = 1
					if _ABS and math.abs(v.RotVelocity.Magnitude*(v.Size.x/2) - v.Velocity.Magnitude)-_Tune.ABSThreshold>0 then
						tqABS = 0
					end
					_ABSActive = (tqABS<1)
					
					--Update Forces
					if v.Name=="FL" or v.Name=="FR" or v.Name=="F" then
						v["#AV"].maxTorque=Vector3.new(math.abs(Ref.x),math.abs(Ref.y),math.abs(Ref.z))*FBrakeForce*brake*tqABS
					else
						v["#AV"].maxTorque=Vector3.new(math.abs(Ref.x),math.abs(Ref.y),math.abs(Ref.z))*RBrakeForce*brake*tqABS
					end
					v["#AV"].angularvelocity=Vector3.new()
				end
			end
		end
	end
	
	
	
--[[Flip]]

	function Flip()
		--Detect Orientation
		if (car.DriveSeat.CFrame*CFrame.Angles(math.pi/2,0,0)).lookVector.y > .1 or FlipDB then
			FlipWait=tick()
			
		--Apply Flip
		else
			if tick()-FlipWait>=3 then
				FlipDB=true
				local gyro = car.DriveSeat.Flip
				gyro.maxTorque = Vector3.new(10000,0,10000)
				gyro.P=3000
				gyro.D=500
				wait(1)
				gyro.maxTorque = Vector3.new(0,0,0)
				gyro.P=0
				gyro.D=0
				FlipDB=false
			end
		end
	end


--[[Run]]

	--Print Version
	local ver=require(car["A-Chassis Tune"].README)
	print("Novena: AC6T Loaded - Build "..ver)
	
	--Runtime Loops
	
	-- ~60 c/s
	game["Run Service"].Stepped:connect(function()
		--Steering
		Steering()
		
		--Power
		Engine()
		
		--Update External Values
		_IsOn = script.Parent.IsOn.Value
		_InControls = script.Parent.ControlsOpen.Value
		script.Parent.Values.Gear.Value = _CGear
		script.Parent.Values.RPM.Value = _RPM
		script.Parent.Values.Boost.Value = (_Boost/2)*_TPsi
		script.Parent.Values.Horsepower.Value = _HP
		script.Parent.Values.HpNatural.Value = _NH
		script.Parent.Values.HpBoosted.Value = _BH*(_Boost/2)
		script.Parent.Values.Torque.Value = _HP * _Tune.EqPoint / _RPM
		script.Parent.Values.TqNatural.Value = _NT
		script.Parent.Values.TqBoosted.Value = _BT*(_Boost/2)
		script.Parent.Values.TransmissionMode.Value = _TMode
		script.Parent.Values.Throttle.Value = _GThrot*_GThrotShift
		script.Parent.Values.Brake.Value = _GBrake
		script.Parent.Values.SteerC.Value = _GSteerC*(1-math.min(car.DriveSeat.Velocity.Magnitude/_Tune.SteerDecay,1-(_Tune.MinSteer/100)))
		script.Parent.Values.SteerT.Value = _GSteerT
		script.Parent.Values.PBrake.Value = _PBrake
		script.Parent.Values.TCS.Value = _TCS
		script.Parent.Values.TCSActive.Value = _TCSActive
		script.Parent.Values.TCSAmt.Value = 1-_TCSAmt
		script.Parent.Values.ABS.Value = _ABS
		script.Parent.Values.ABSActive.Value = _ABSActive
		script.Parent.Values.MouseSteerOn.Value = _MSteer
		script.Parent.Values.Velocity.Value = car.DriveSeat.Velocity
	end)
	
	--15 c/s
	while wait(.0667) do
		--Automatic Transmission
		if _TMode == "Auto" then Auto() end
		
		--Flip
		if _Tune.AutoFlip then Flip() end
	end

--[[END]]
