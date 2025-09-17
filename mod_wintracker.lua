function _init_wintracker()
    local playerWinData = {}
    local pWDATA = {}

    function playerWinData.updateMatches(playerUid, opponentUid, isWin)
        local player = pWDATA[playerUid]
        if(player.stats[opponentUid] == nil) then
            player.stats[opponentUid] = {w=0, l=0}
        end
        if(isWin) then
            player.stats[opponentUid].w = player.stats[opponentUid].w + 1
            if(player.v.w < player.stats[opponentUid].w) then
                player.v = {uid=opponentUid, w=player.stats[opponentUid].w, l=player.stats[opponentUid].l}
            end
        else
            player.stats[opponentUid].l = player.stats[opponentUid].l + 1
            if(player.t.l < player.stats[opponentUid].l) then
                player.t = {uid=opponentUid, w=player.stats[opponentUid].w, l=player.stats[opponentUid].l}
            end
        end
        pWDATA[playerUid] = player
    end

    function playerWinData.initNewWinData(uid)
        --Set initial threat and victim to self to avoid crash and be funny
        pWDATA[uid] = {v={uid=uid, w=0, l=0}, t={uid=uid, w=0, l=0}, stats={}}
    end

    function playerWinData.getErrorWinData(uid)
        return {victim={uid=uid, wins=0, losses=0}, threat={uid=uid, wins=0, losses=0}, stats={}}
    end

    function playerWinData.saveData()
        local data = json.decode(g2.data)
        data.playerWinData = pWDATA
        g2.data = json.encode(data)
    end

    function playerWinData.getUserData(uid)
        if(pWDATA[uid] == nil) then
            print("Uh oh! No win stats found for "..uid)
            return playerWinData.getErrorWinData(uid)
        else
            return pWDATA[uid]
        end
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
    --print("New table!")
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

function convertStatTableFromSave(stats)
    --print("From save")
    local converted = {
        total = {matches= stats.to.m, wins=stats.to.w, losses=stats.to.l},
        classic = {matches= stats.cl.m, wins=stats.cl.w, losses=stats.cl.l},
        frenzy = {matches= stats.fr.m, wins=stats.fr.w, losses=stats.fr.l},
        grid = {matches= stats.gr.m, wins=stats.gr.w, losses=stats.gr.l},
        stages = {matches= stats.st.m, wins=stats.st.w, losses=stats.st.l},
        float = {matches= stats.fl.m},
        line = {matches= stats.li.m, wins=stats.li.w, losses=stats.li.l},
        race = {matches= stats.ra.m, wins=stats.ra.w, losses=stats.ra.l},
    }
    return converted
end

function convertStatTableToSave(stats)
    --print("To save")
    local statTable = {
        to = {m=stats.total.matches, w=stats.total.wins, l=stats.total.losses},
        cl = {m=stats.classic.matches, w=stats.classic.wins, l=stats.classic.losses},
        fr = {m=stats.frenzy.matches, w=stats.frenzy.wins, l=stats.frenzy.losses},
        gr = {m=stats.grid.matches, w=stats.grid.wins, l=stats.grid.losses},
        st = {m=stats.stages.matches, w=stats.stages.wins, l=stats.stages.losses},
        fl = {m=stats.float.matches},
        li = {m=stats.line.matches, w=stats.line.wins, l=stats.line.losses},
        ra = {m=stats.race.matches, w=stats.race.wins, l=stats.race.losses},
    }

    return statTable
end