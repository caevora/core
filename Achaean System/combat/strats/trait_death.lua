--Low HP + Lockdown = Death
return {
  name = "Trait Execute - Death",
  tags = { "trait", "execute" },
  requirements = {
    deathRubCount = 7,
    enemyHealthBelow = 25,
    hasAfflictions = { "aeon", "paralysis" }
  },
  steps = {
    { card = "death", action = "rub" },
    { card = "death", action = "rub" }
  }
}
