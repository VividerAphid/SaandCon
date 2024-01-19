function stage2(uid)
    local G = GAME.galcon

    local user = find_user(uid)
    if user == nil then return end
    for n,e in pairs(g2.search("planet owner:"..G.neutral_hide)) do
        e:planet_chown(G.neutral)
    end
end

function stage3(uid)
    local G = GAME.galcon

    local user = find_user(uid)
    if user == nil then return end
    for n,e in pairs(g2.search("planet owner:"..G.neutral_hide2)) do
        e:planet_chown(G.neutral)
    end
end

function stage4()
    local G = GAME.galcon

    for n,e in pairs(g2.search("planet neutral")) do
        if e.ships_value > 0 then
            e.ships_value = e.ships_value - 1
        end
    end
end

function stage5()
    local G = GAME.galcon

    for n,e in pairs(g2.search("user")) do
        e.fleet_v_factor = 1.5
    end
end

function stage6()
    local G = GAME.galcon

    for n,e in pairs(g2.search("planet")) do
        if e.ships_production > 0 then
            e.ships_production = e.ships_production - 1
        end
    end
end