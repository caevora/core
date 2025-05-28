-- Modular strategy: Summon & Trap Lock
--Summon + Trap + Moonburst
--Empress > Tower > Sun > Wheel > Moon > Devil ? (Moon)
return {
  name = "Summon & Trap Lock",
  tags = {"trap", "control"},
  requirements = {
    hasCard = "empress",
    targetInRoom = false -- Placeholder for future positioning logic
  },
  steps = {
    {card = "empress"},
    {card = "tower"},
    {card = "sun"},
    {card = "wheel"},
    {card = "moon"},
    {card = "moon", devil = true}
  }
}

