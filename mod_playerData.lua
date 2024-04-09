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

    function playerData.setPlayerName(uid, name)
        PDATA[uid].name = name
    end
    
    function playerData.setPlayerTitle(uid, title)
        PDATA[uid].title = title
    end

    function playerData.setPlayerShip(uid, ship)
        PDATA[uid].ship = ship
    end

    function playerData.setPlayerSkin(uid, skin)
        PDATA[uid].skin = skin
    end

    function playerData.getUserData(uid)
        return PDATA[uid]
    end

    function playerData.saveData()
        local data = json.decode(g2.data)
        data.playerData = PDATA
        g2.data = json.encode(data)
    end

    function playerData.wipeAllData()
        PDATA = {}
    end 

    function playerData.InitNewPlayer(uid)
        PDATA[uid] = {name="Player", title="", coins=0, color=0xff0000, ship="ship-0", skin="normal", ownedShips={"ship-0"}, ownedSkins={"normal"}}
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
    
    function playerData.loadData()
        local data = json.decode(g2.data)
        local pData = data.playerData
        print("playerData: Loaded data from g2.data.pData")
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