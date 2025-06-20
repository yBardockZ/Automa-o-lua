-- =====================
-- Auto Captura por LOOK (via chat) + useWith
-- =====================

allowedCorpseIds = {} -- Lista de IDs de corpos válidos
captureEnabled = false
lastCorpseThing = nil

-- IDs das pokebolas
local pokeBalls = {
  ["PokeBall"] = 3282,
  ["GreatBall"] = 3279,
  ["SuperBall"] = 3281,
  ["UltraBall"] = 3280
}

selectedBallId = pokeBalls["PokeBall"]

-- =====================
-- INTERFACE
-- =====================
UI.Separator()
UI.Label("Auto Captura por ID do corpse")

UI.Label("Selecionar Pokebola:")
UI.Button("Pokeball", function() selectedBallId = pokeBalls["PokeBall"]; info("Pokebola selecionada.") end)
UI.Button("Greatball", function() selectedBallId = pokeBalls["GreatBall"]; info("Greatball selecionada.") end)
UI.Button("Superball", function() selectedBallId = pokeBalls["SuperBall"]; info("Superball selecionada.") end)
UI.Button("Ultraball", function() selectedBallId = pokeBalls["UltraBall"]; info("Ultraball selecionada.") end)

UI.Button("Ativar/Desativar Autocaptura", function()
  captureEnabled = not captureEnabled
  if captureEnabled then
    info("Autocaptura ativada.")
  else
    info("Autocaptura desativada.")
  end
end)

UI.Separator()

local newIdInput = UI.TextEdit("", function() end)
UI.Label("Adicionar novo ID de corpse")
UI.Button("Adicionar ID", function()
  local newId = tonumber(newIdInput:getText())
  if newId then
    table.insert(allowedCorpseIds, newId)
    info("ID " .. newId .. " adicionado a lista de captura.")
  end
end)

-- =====================
-- ESCUTAR CHAT PARA CONFIRMAR CORPSE
-- =====================

onTextMessage(function(mode, text)
  if not captureEnabled then return end
  local lowered = text:lower()
  if lowered:find("this is a fainted") or lowered:find("isto e um fainted") then
    if lastCorpseThing then
      info("Corpse confirmado por look: usando pokebola com useWith")
      useWith(selectedBallId, lastCorpseThing)
      lastCorpseThing = nil
    end
  end
end)

-- =====================
-- MACRO PRINCIPAL DE VERIFICACAO DE CORPOS
-- =====================

macro(500, "Captura via look", function()
  if not captureEnabled then return end

  local center = pos()
  for x = -1, 1 do
    for y = -1, 1 do
      local checkPos = {x = center.x + x, y = center.y + y, z = center.z}
      local tile = g_map.getTile(checkPos)
      if tile then
        local things = tile:getThings()
        for _, thing in ipairs(things) do
          if thing and thing.getId and table.contains(allowedCorpseIds, thing:getId()) then
            info("Corpse suspeito detectado, usando look...")
            g_game.look(thing)
            lastCorpseThing = thing
            return
          end
        end
      end
    end
  end
end)