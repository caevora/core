--Devil + Burst Finisher
--Devil active > Fling aggressive card (Moon, Star, Death)
--Devil + Unstable Enemy = Moon/Justice Burst
return {
  name = "Devil Burst Finisher",
  tags = { "trait", "burst", "chaos", "devil" },
  requirements = {
    devilActive = true
	enemyHealthBelow = 40
  },
  steps = {
    { card = "moon" } -- Devil will follow up with a second tarot
  }
}
