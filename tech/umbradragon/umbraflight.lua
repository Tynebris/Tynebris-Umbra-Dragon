-- Init function, sets variables.
function init()
  self.active = false
  self.specialLast = false
end
  
-- input function, sets flight to enabled/disabled and determines direction
function input(args)
  local currentBoost = nil

  if args.moves["special"] == 3 and not self.specialLast and not mcontroller.onGround() then
    if self.active then
	  self.specialLast = args.moves["special"] == 3
      return "flightDeactivate"
    else
	  self.specialLast = args.moves["special"] == 3
      return "flightActivate"
    end
  end  

  
  self.specialLast = args.moves["special"] == 3
  
  if self.active then
    if args.moves["right"] and args.moves["up"] then
        currentBoost = "boostRightUp"
    elseif args.moves["right"] and args.moves["down"] then
        currentBoost = "boostRightDown"
    elseif args.moves["left"] and args.moves["up"] then
        currentBoost = "boostLeftUp"
    elseif args.moves["left"] and args.moves["down"] then
        currentBoost = "boostLeftDown"
    elseif args.moves["right"] then
        currentBoost = "boostRight"
    elseif args.moves["down"] then
        currentBoost = "boostDown"
    elseif args.moves["left"] then
        currentBoost = "boostLeft"
    elseif args.moves["up"] then
        currentBoost = "boostUp"
	end
  end
  

  return currentBoost
end
  
-- update function, handles movement
function update(args)
  local boostControlForce = tech.parameter("boostControlForce")
  local boostSpeed = tech.parameter("boostSpeed")
  local energyUsagePerSecond = tech.parameter("energyUsagePerSecond")
  local energyUsage = 0

  local moving = true
  local diag = 1 / math.sqrt(2)

  if not self.active and args.actions["flightActivate"] then
        self.active = true
  elseif self.active and args.actions["flightDeactivate"] then
		self.active = false
  end
  if not mcontroller.onGround() then
    if args.actions["boostRightUp"] then
      boostDirection = {boostSpeed * diag, boostSpeed * diag}
    elseif args.actions["boostRightDown"] then
      boostDirection = {boostSpeed * diag, -boostSpeed * diag}
    elseif args.actions["boostLeftUp"] then
      boostDirection = {-boostSpeed * diag, boostSpeed * diag}
    elseif args.actions["boostLeftDown"] then
      boostDirection = {-boostSpeed * diag, -boostSpeed * diag}
    elseif args.actions["boostRight"] then
      boostDirection = {boostSpeed, 0}
    elseif args.actions["boostDown"] then
      boostDirection = {0, -boostSpeed}
    elseif args.actions["boostLeft"] then
      boostDirection = {-boostSpeed, 0}
    elseif args.actions["boostUp"] then
      boostDirection = {0, boostSpeed}
    else
      moving = false
	  boostDirection = {0, 0}
    end
  else
    self.active = false
	moving = false
  end
  
  if self.active then
    if moving then
	  energyUsage = energyUsagePerSecond * args.dt
	else
	  energyUsage = (energyUsagePerSecond / 2) * args.dt
	end
	if tech.consumeTechEnergy(energyUsage) then
	  mcontroller.controlApproachVelocity(boostDirection, boostControlForce, true, true)
	else
	  self.active = false
	  moving = false
	end
  end
end