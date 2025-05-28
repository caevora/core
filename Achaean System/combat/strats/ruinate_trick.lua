--Ruinate Trick Lock
--Ruinate Creator > Moon > Aeon > Heretic > Devil (Moon)
return {
  name = "Ruinate Trick Lock",
  tags = { "burst", "chaos", "lock" },
  requirements = {
    hasCard = "creator",
    hasCardSecondary = "heretic"
  },
  steps = {
    { card = "creator", action = "ruinate" },
    { card = "moon" },
    { card = "aeon" },
    { card = "heretic" },
    { card = "devil" }
  }
}
