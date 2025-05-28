-- Modular strategy: Entanglement Death Prep
--Entanglement Death Prep
--Hangedman > Moon (paralysis) > Aeon > Rub Death > Moon (shivering) > Rub -> Death                                                                   

return {
  name = "Entanglement Death Prep",
  tags = {"setup", "kill"},
  requirements = {
    hasCard = "hangedman",
    hasAfflictions = {"aeon", "paralysis", "shivering"},
    targetEntangled = true
  },
  steps = {
    {card = "hangedman"},
    {card = "moon", affliction = "paralysis"},
    {card = "aeon"},
    {card = "death", action = "rub"},
    {card = "moon", affliction = "shivering"},
    {card = "death", action = "rub"}
  }
}


