--Escape & Momentum Reset
--Activate Hermit > Fight > Hermit Fling > Universe Touch City > Heal
return {
  name = "Escape & Reset",
  tags = { "escape", "reset", "defensive" },
  requirements = {
    hasCard = "hermit",
    hasCardSecondary = "universe"
  },
  steps = {
    { card = "hermit", action = "activate" },
    { card = "universe", action = "touch", destination = "city" }
  }
}
