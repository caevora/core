--Low HP + LOS + Outdoors a'Drop Star meteor
return {
  name = "Star Finisher",
  tags = {  "trait", "finisher", "burst", "execute", "trait" },
  requirements = {
    enemyHealthBelow = 20,
    outdoors = true,
    hasLineOfSight = true
  },
  steps = {
    { card = "star" }
  }
}
