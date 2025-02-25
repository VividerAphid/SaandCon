function _init_wintracker()
    local playerWinData = {}
    local pWDATA = {}

    function playerWinData.updateMatches(playerUid, opponentUid, isWin)
        local player = pWDATA[playerUid]
        if(player.stats[opponentUid] == nil) then
            player.stats[opponentUid] = {wins=0, losses=0}
        end
        if(isWin) then
            player.stats[opponentUid].wins = player.stats[opponentUid].wins + 1
            if(player.victim.wins < player.stats[opponentUid].wins) then
                player.victim = {uid=opponentUid, wins=player.stats[opponentUid].wins, losses=player.stats[opponentUid].losses}
            end
        else
            player.stats[opponentUid].losses = player.stats[opponentUid].losses + 1
            if(player.threat.losses < player.stats[opponentUid].losses) then
                player.threat = {uid=opponentUid, wins=player.stats[opponentUid].wins, losses=player.stats[opponentUid].losses}
            end
        end
        pWDATA[playerUid] = player
    end

    function playerWinData.initNewWinData(uid)
        --Set initial threat and victim to self to avoid crash and be funny
        pWDATA[uid] = {victim={uid=uid, wins=0, losses=0}, threat={uid=uid, wins=0, losses=0}, stats={}}
    end

    function playerWinData.saveData()
        local data = json.decode(g2.data)
        data.playerWinData = pWDATA
        g2.data = json.encode(data)
    end

    function playerWinData.getUserData(uid)
        return pWDATA[uid]
    end

    function playerWinData.wipeAllData()
        pWDATA = {}
    end 

    function playerWinData.clearPlayerEntry(uid)
        pWDATA[uid] = nil
    end

    function playerWinData.loadData(initialLoad)
        local data = json.decode(g2.data)
        local pwData = data.playerWinData
        if initialLoad then
            --print("playerData: Loaded data from g2.data.pData")
        else
            --print("Runtime load")
        end
        if(pwData == nil) then
            print("No player win data loaded!")
        else
            pWDATA = pwData
        end
    end

    return playerWinData
    
end

playerWinData = _init_wintracker()
_init_wintracker = nil

function getNewStatTable()
    local statTable = {
        total = {matches=0, wins=0, losses=0},
        classic = {matches=0, wins=0, losses=0},
        frenzy = {matches=0, wins=0, losses=0},
        grid = {matches=0, wins=0, losses=0},
        stages = {matches=0, wins=0, losses=0},
        float = {matches=0},
        line = {matches=0, wins=0, losses=0},
        race = {matches=0, wins=0, losses=0},
    }

    return statTable
end