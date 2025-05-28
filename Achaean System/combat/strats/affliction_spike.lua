-- Modular strategy: Affliction Spike Chain
--Affliction Spike Chain
--Moon > Devil (Moon) > Moon > Aeon > Moon > Devil (Moon)
return {
  name = "Affliction Spike Chain",
  tags = {"affliction", "burst"},
  requirements = {
    hasCard = "moon",
    devilActive = true
  },
  steps = {
    {card = "moon"},
    {card = "moon", devil = true},
    {card = "moon"},
    {card = "aeon"},
    {card = "moon"},
    {card = "moon", devil = true}
  }
}


