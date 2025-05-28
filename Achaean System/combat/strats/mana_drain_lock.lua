--Mana Drain + Aeon Lock
--Aeon > Moon (hallucination) > Moon (hypersomnia) > Star/Justice
return {
  name = "Mana Drain + Aeon Lock",
  tags = { "pressure", "lock" },
  requirements = {
    hasCard = "aeon",
    enemyHealthBelow = 60
  },
  steps = {
    { card = "aeon" },
    { card = "moon", affliction = "hallucinations" },
    { card = "moon", affliction = "hypersomnia" },
    { card = "star" }
  }
}
