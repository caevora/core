--Death Execute Setup
--Stack rubs + afflictions (aeon, entangled, paralysis, etc.) a'Rub Death (x2) 
return {
  name = "Trait Execute - Death",
  tags = { "trait", "execute" },
  requirements = {
    deathRubCount = 7,
    enemyHealthBelow = 25,
    hasAfflictions = { "aeon", "paralysis", "entangled" }
  },
  steps = {
    { card = "death", action = "rub" },
    { card = "death", action = "rub" }
  }
}
