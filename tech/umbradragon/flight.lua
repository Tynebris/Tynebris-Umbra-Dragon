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
    if not mcontroller.canJump() and currentJump and not self.lastJump then
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
      currentBoost = self.lastBoost
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
  end
  
  if boostDirection and tech.consumeTechEnergy(energyUsagePerSecond * args.dt) then
    mcontroller.controlApproachVelocity(boostDirection, boostControlForce, true, true)

    tech.setAnimationState("boosting", "on")
    tech.setParticleEmitterActive("boostParticles", true)
  else
    tech.setAnimationState("boosting", "off")
    tech.setParticleEmitterActive("boostParticles", false)
  end
end
