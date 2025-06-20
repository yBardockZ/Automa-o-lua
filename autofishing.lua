-- Helper para usar item com algo (compatível com número ou Thing)
function useWith(thing, target, subtype)
  if type(thing) == 'number' then  
    return g_game.useInventoryItemWith(thing, target, subtype)
  else
    return g_game.useWith(thing, target, subtype)
  end
end

-- ID do tile de água
local WATER_TILE_ID = 4814
local tilePos = nil
local fishingEnabled = false

-- Busca o primeiro tile de água visível na tela
local function findWaterTile()
  local centerPos = pos()
  for x = -7, 7 do
    for y = -5, 5 do
      local checkPos = {x = centerPos.x + x, y = centerPos.y + y, z = centerPos.z}
      local tile = g_map.getTile(checkPos)
      if tile then
        local topThing = tile:getTopUseThing()
        if topThing and topThing:getId() == WATER_TILE_ID then
          return tile:getPosition()
        end
      end
    end
  end
  return nil
end

UI.Label("Auto Fishing: Procurando tile de agua (ID 4814)")

UI.Button("Ativar/Desativar Pesca Automática", function()
  fishingEnabled = not fishingEnabled
  if fishingEnabled then
    tilePos = findWaterTile()
    if tilePos then
      info("Auto Fishing: ATIVADO. Tile de agua encontrado em: " .. posToString(tilePos))
    else
      fishingEnabled = false
      warn("Tile de agua (ID 4814) não encontrado na tela!")
    end
  else
    warn("Auto Fishing: DESATIVADO")
  end
end)

UI.Separator()
UI.Label(function()
  return fishingEnabled and "Fishing: ON" or "Fishing: OFF"
end)

-- Macro de pesca (a cada 500ms)
macro(500, "Auto Fishing", function()
  if fishingEnabled and tilePos then
    local tile = g_map.getTile(tilePos)
    if tile then
      local thing = tile:getTopUseThing()
      if thing and thing:getId() == WATER_TILE_ID then
        useWith(3483, thing)
      end
    end
  end
end)

-- Macro de ataques m1 até m10 (a cada 3000ms)
macro(3000, "Auto Attacks (m1~m10)", function()
  if fishingEnabled then
    for i = 1, 10 do
      say("m" .. i)
    end
  end
end)
