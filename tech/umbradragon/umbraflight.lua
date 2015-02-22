function init()
  self.lastJump = false
  self.lastBoost = nil
end

function uninit()
  tech.setParentState()
  self.active = false
  return 0
end

function input(args)
  local currentBoost = nil
  local activated = false
  
  if args.moves["special"] == 3 and not self.specialLast and not mcontroller.onGround() then
    if self.active then
	  self.specialLast = args.moves["special"] == 3
      return "flightDeactivate"
    else
	  self.specialLast = args.moves["special"] == 3
      return "flightActivate"
    end
  end 

  
  if not mcontroller.onGround() then
    if not mcontroller.canJump() then
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
    elseif currentJump and self.lastBoost then
      currentBoost = "hover"
    end
  end

  self.lastJump = currentJump
  self.lastBoost = currentBoost

  return currentBoost
end

function update(args)
  local boostControlForce = tech.parameter("boostControlForce")
  local boostSpeed = tech.parameter("boostSpeed")
  local energyUsagePerSecond = tech.parameter("energyUsagePerSecond")

  local diag = 1 / math.sqrt(2)
  local boostDirection = false

  local moving = true
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
  elseif args.actions["hover"] then
	boostDirection = {0, 0}
	moving = false
  end
  
  if activated then
	if moving and tech.consumeTechEnergy(energyUsagePerSecond * args.dt) then
		mcontroller.controlApproachVelocity(boostDirection, boostControlForce, true, true)
	elseif tech.consumeTechEnergy((energyUsagePerSecond * args.dt)/2) then
		mcontroller.controlApproachVelocity(boostDirection, boostControlForce, true, true)
	end
    tech.setAnimationState("flying", "on")
    tech.setParticleEmitterActive("boostParticles", true)
  else
    tech.setAnimationState("flying", "off")
    tech.setParticleEmitterActive("boostParticles", false)
  end
end
