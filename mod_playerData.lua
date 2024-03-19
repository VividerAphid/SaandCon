function _playerDataInit()
    local playerData = {}
    local PDATA = {}

    function playerData.updateCoins(uid, coins)
        PDATA[uid].coins = PDATA[uid].coins + coins
    end

    function playerData.updateShipList(uid, ship)
        PDATA[uid].ships
    end

    function playerData.getUserData(uid)
        return PDATA[uid]
    end

    function playerData.saveData()
        local data = json.decode(g2.data)
        data.playerData = PDATA
        g2.data = json.encode(data)
    end
    
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