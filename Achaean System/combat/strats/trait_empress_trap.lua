--Fleeing Target = Lust + Empress + Tower Trap
return {
  name = "Trait Execute - Empress Trap",
  tags = { "trap", "trait", "summon" },
  requirements = {
    targetFleeing = true,
    hasCard = "lust",
    hasCardSecondary = "tower"
  },
  steps = {
	{ card = "lust" },
    { card = "empress" },
    { card = "tower" }
  }
}
