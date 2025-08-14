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

    function playerData.getUserData(uid, initialLoad)
        if(initialLoad and PDATA[uid] == nil) then
            print("Initial load")
            return nil
        else
            if(PDATA[uid] == nil) then
                print("Uh oh! No player data found for "..uid)
                return playerData.getErrorPlayer()
            else
                return PDATA[uid]
            end
        end
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
        print("New player data created for "..uid)
    end

    function playerData.getErrorPlayer()
        local colors = {
        '0x0000ff','0xff0000',
        '0xffff00','0x00ffff',
        '0xffffff','0xff8800',
        '0x99ff99','0xff9999',
        '0xbb00ff','0xff88ff',
        '0x9999ff','0x00ff00',
        }
        return {displayName="Error Player", title="", quote="Uh oh! Your data didn't load for some reason! X(", coins=100, 
        color=colors[math.random(1, #colors)], ship="ship-0", skin="normal", prestige=420, level=69, 
        ownedShips={"ship-0"}, ownedSkins={"normal"},stats=getNewStatTable()}
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