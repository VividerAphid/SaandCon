function _playerDataInit()
    local playerData = {}
    local PDATA = {}

    function playerData.setPlayerCoins(uid, coins)
        PDATA[uid].coins = coins
    end

    function playerData.updateCoins(uid, coins)
        PDATA[uid].coins = PDATA[uid].coins + coins
    end

    function playerData.updateShipList(uid, ship)
        PDATA[uid].ownedShips[#PDATA[uid].ownedShips+1] = ship
    end

    function playerData.updateSkinList(uid, skin)
        PDATA[uid].ownedSkins[#PDATA[uid].ownedSkins+1] = skin
    end

    function playerData.setPlayerColor(uid, color)
        PDATA[uid].color = color
    end

    function playerData.setPlayerPrestige(uid, prestige)
        PDATA[uid].prestige = prestige
    end

    function playerData.setPlayerLevel(uid, level)
        PDATA[uid].level = level
    end

    function playerData.setPlayerXP(uid, xp)
        PDATA[uid].xp = xp
    end

    function playerData.setPlayerDisplayName(uid, name)
        PDATA[uid].displayName = name
    end
    
    function playerData.setPlayerTitle(uid, title)
        PDATA[uid].title = title
    end

    function playerData.setPlayerQuote(uid, quote)
        PDATA[uid].quote = quote
    end

    function playerData.setPlayerShip(uid, ship)
        PDATA[uid].ship = ship
    end

    function playerData.setPlayerSkin(uid, skin)
        PDATA[uid].skin = skin
    end

    function playerData.setPlayerStats(uid, stats)
        PDATA[uid].stats = stats
    end

    function playerData.getUserData(uid)
        return PDATA[uid]
    end

    function playerData.saveData()
        local data = json.decode(g2.data)
        data.playerData = PDATA
        g2.data = json.encode(data)
        --print("data saved")
    end

    function playerData.wipeAllData()
        PDATA = {}
    end 

    function playerData.InitNewPlayer(uid)
        PDATA[uid] = {displayName="Player", title="", coins=0, color=0xff0000, ship="ship-0", skin="normal", ownedShips={"ship-0"}, ownedSkins={"normal"},stats={}}
    end

    function playerData.clearPlayerEntry(uid)
        PDATA[uid] = nil
    end

    --name
    --title
    --coins
    --color
    --ship
    --skin
    --shiplist
    --skinlist
    --totalWins
    --totalLosses
    
    function playerData.loadData(initialLoad)
        local data = json.decode(g2.data)
        local pData = data.playerData
        if initialLoad then
            --print("playerData: Loaded data from g2.data.pData")
        else
            --print("Runtime load")
        end
        if(pData == nil) then
            print("No player data loaded!")
        else
            PDATA = pData
        end
    end

    return playerData
end
playerData = _playerDataInit()
_playerDataInit = nil