-- Modular strategy: Psych Lock (Heretic)
--Psych Lock (Heretic Vision)
--Moon (stupidity) > Moon (hallucination) > Aeon > Heretic > Order Witness
return {
  name = "Psych Lock (Heretic)",
  tags = {"lock", "mental"},
  requirements = {
    hasAfflictions = {"stupidity", "hallucinations"},
    aeonActive = true
  },
  steps = {
    {card = "moon", affliction = "stupidity"},
    {card = "moon", affliction = "hallucinations"},
    {card = "aeon"},
    {card = "heretic"},
    -- Followup assumed to be external WITNESS command
  }
}

