-- Modular strategy: Forced Ally Control
--Forced Ally Control
--Lust > Lovers > Empress > Tower > Moon spam
return {
  name = "Forced Movement ",
  tags = {"disrupt", "control"},
  requirements = {
    hasCard = "lust",
    targetAllied = false
  },
  steps = {
    {card = "lust"},
    {card = "lovers"},
    {card = "empress"},
    {card = "tower"},
    {card = "moon"},
    {card = "moon"}
  }
}

