function startupMenu()
    return [[
        <table>
        <tr><td colspan=2><h1>Galcon 2 Server</h1>
        <tr><td><p>&nbsp;</p>
        <tr><td><input type='text' name='port' value='$PORT' />
        <tr><td><p>&nbsp;</p>
        <tr><td><input type='button' value='Start Server' onclick='host' />"
        </table>
        ]]
end
function resetLobbyHtml(e)
    if g2.state ~= "lobby" then
        return
    end
	lobby_tabs(e)
    --params_set("tabs","<table class='box3' width=160><tr><td><h2>SaandCon</h2></table>")
    params_set(
        "html", [[
                <table>
                <tr><td><h1>Play in the Saandbox!</h1></td></tr>
                <tr><td><div color='0xff88ff' font='font-gui2:18'>By TyCho2, Edited by Saand and VividerAphid</div></td></tr>
                <tr><td></td></tr>
                <tr><td colspan=2><input type='button' value='Start' onclick='/start' class='button1' /></td></tr>
                <tr><td></td></tr>
                <tr><td><input type='button' value='Play' onclick='/play' class='button2' /></td>
                <tr><td><input type='button' value='Away' onclick='/away' class='button2' /></td></tr>
                <tr><td><input type='button' value='Wardrobe' icon='icon-store' onclick='/wardrobe' class='button2' /></td></tr>
                <tr><td colspan=2></td></tr>
                <tr><td><div font='font-gui:12'>Type /help for a list of commands, gamemodes,...</div></td></tr>
            ]]..
            [[
                <tr><td></td></tr>
                <tr><td class='box3'><h4>GAME MODE: ]]..GAME.galcon.gamemode..[[
            ]]..
                gamemodeDescription()..
                settingsBar()..
            [[
                <tr><td>
                <tr><td class='box2'><h2>PLAYERS</h2></td></tr>
                <tr><td>
            ]]..
            
                playerInState("play")..
                playerInState("queue")..
                playerInState("away")..
            [[
                <tr><td><p>&nbsp;</p>
            ]]
    )

        -- <tr><td>
        --         <tr><td><h3>PLAY:</h3></td></tr>
        --     ]]..
        --         playerInState("play")..playerInState("queue")..
        --     [[
        --         <tr><td>
        --         <tr><td><h3>SPECTATORS:</h3></td></tr>
        --     ]]..
        --         playerInState("away")..
        --     [[
        --       <tr><td><p>&nbsp;</p>
        --     ]]
end

function lobby_tabs(e)
    local tabs = [[
        <table>
            <td><input type='button' class='tab' width='15%' pseudo='first'      disabled='true'                                           />
			<td><input type='button' class='tab' width='22%' value='Lobby'       icon='icon-new_game'  onclick='/lobby'                    />
            <td><input type='button' class='tab' width='22%' value='Modes'       icon='icon-new_map'  onclick='/mode'                      />
            <td><input type='button' class='tab' width='22%' value='Ranks' icon='icon-queue'    onclick='/leaderboard'               />
            <td><input type='button' class='tab' width='22%' value='Settings'    icon='icon-options'  onclick='/settings'    pseudo='last' />
        </table>
    ]]

    if e == nil then
        params_set("tabs", tabs)
    else
        net_send(e.uid, "tabs", tabs)
        --print(e.uid)
    end
end

function getLadderTable()
    local html = ""

    local ladder = getLadderSorted()

    for k, v in ipairs(ladder) do
        html = html .. "<tr><td><h3>" .. v.username .. "</h3><td>" .. common_utils.round(v.value)
    end

    html = html .. "</tr></td>"
    return html
end

function getLadderSorted()
    local ladder = {}
    for k, v in pairs(elo.get_elos()) do
        table.insert(ladder, {username = k, value = v})
    end
    table.sort(
        ladder,
        function(a, b)
            return a.value > b.value
        end
    )
    return ladder
end

function loadScoreboard(e)
    local html = [[
              <table>
              <tr><td><p>&nbsp;</p>
              <tr><td><h2>Leaderboard
            ]] ..
                getLadderTable() .. [[
                </table>
            ]]
    if e == nil then
        params_set("html", html)
    else
        net_send(e.uid, "html", html)
    end
end

function modeTab(e)
	local html = [[
        <table><tr><td>
        <h2>Modes</h2>
        <tr><td colspan=2><input type='button' value='Classic' onclick='/classic' class='button2' />
        <tr><td colspan=2><input type='button' value='Stages' onclick='/stages' class='button2' />
        <tr><td colspan=2><input type='button' value='Frenzy' onclick='/frenzy' class='button2' />
        <tr><td colspan=2><input type='button' value='Grid' onclick='/grid' class='button2' />
        <tr><td colspan=2><input type='button' value='Float' onclick='/float' class='button2' />
        <tr><td colspan=2><input type='button' value='Line' onclick='/line' class='button2' />
        <tr><td colspan=2><input type='button' value='Race' onclick='/race' class='button2' />
        </td></tr>
        </table>
        ]]
    if e == nil then
        params_set("html", html)
    else
        net_send(e.uid, "html", html)
    end
end

function settingsTab(e)
    local html = [[
        <table><tr><td>
        <h2>Settings</h2>
        <tr><td colspan=2><input type='button' value='Solo Mode' onclick='/solo' class='button2' />
        ]]
        .. 
        loadModeSpecificButtons() ..[[
        </td></tr>
        </table>
        ]]
    if e == nil then
        params_set("html", html)
    else
        net_send(e.uid, "html", html)
    end
end

function wardrobe(e)
    local html = [[<table><tr><td>
        <h2>Wardrobe</h2>
        <tr><td><input type='button' value='back' onclick='/lobby' icon="icon-restart" class='ibutton' />
        <tr><td><input type='button' value='Colors' onclick='/wardrobe colors' icon="icon-edit" class='ibutton' />
        <tr><td><input type='button' value='Ships' onclick='/wardrobe ships' icon="icon-clans" class='ibutton' />
        <tr><td><input type='button' value='Skins' onclick='/wardrobe skins' icon="icon-world" class='ibutton' />
        </table
    ]]
    net_send(e.uid, "html", html)
end

function wardrobeColors(e)
    local html = [[<table><tr><td>
        <td><h2>Colors</h2>
        <tr><td><td><input type='button' width=50 value='back' onclick='/wardrobe' class='button2' />
        <tr><td><input type='button' width=50 background='white:#8a0000' value='  ' onclick='/hex 0x8a0000' class='button2' /></td>
            <td><input type='button' width=50 background='white:#bb0000' value='  ' onclick='/hex 0xbb0000' class='button2' /></td>
            <td><input type='button' width=50 background='white:#ff0000' value='  ' onclick='/hex 0xff0000' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#008a00' value='  ' onclick='/hex 0x008a00' class='button2' /></td>
            <td><input type='button' width=50 background='white:#00bb00' value='  ' onclick='/hex 0x00bb00' class='button2' /></td>
            <td><input type='button' width=50 background='white:#00ff00' value='  ' onclick='/hex 0x00ff00' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#00008a' value='  ' onclick='/hex 0x00008a' class='button2' /></td>
            <td><input type='button' width=50 background='white:#0000bb' value='  ' onclick='/hex 0x0000bb' class='button2' /></td>
            <td><input type='button' width=50 background='white:#0000ff' value='  ' onclick='/hex 0x0000ff' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#8a8a00' value='  ' onclick='/hex 0x8a8a00' class='button2' /></td>
            <td><input type='button' width=50 background='white:#bbbb00' value='  ' onclick='/hex 0xbbbb00' class='button2' /></td>
            <td><input type='button' width=50 background='white:#ffff00' value='  ' onclick='/hex 0xffff00' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#008a8a' value='  ' onclick='/hex 0x008a8a' class='button2' /></td>
            <td><input type='button' width=50 background='white:#00bbbb' value='  ' onclick='/hex 0x00bbbb' class='button2' /></td>
            <td><input type='button' width=50 background='white:#00ffff' value='  ' onclick='/hex 0x00ffff' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#8a008a' value='  ' onclick='/hex 0x8a008a' class='button2' /></td>
            <td><input type='button' width=50 background='white:#bb00bb' value='  ' onclick='/hex 0xbb00bb' class='button2' /></td>
            <td><input type='button' width=50 background='white:#ff00ff' value='  ' onclick='/hex 0xff00ff' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#8a8a8a' value='  ' onclick='/hex 0x8a8a8a' class='button2' /></td>
            <td><input type='button' width=50 background='white:#bbbbbb' value='  ' onclick='/hex 0xbbbbbb' class='button2' /></td>
            <td><input type='button' width=50 background='white:#ffffff' value='  ' onclick='/hex 0xffffff' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#a84a02' value='  ' onclick='/hex 0xa84a02' class='button2' /></td>
            <td><input type='button' width=50 background='white:#cf5b02' value='  ' onclick='/hex 0xcf5b02' class='button2' /></td>
            <td><input type='button' width=50 background='white:#ff6f00' value='  ' onclick='/hex 0xff6f00' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#9e3c81' value='  ' onclick='/hex 0x9e3c81' class='button2' /></td>
            <td><input type='button' width=50 background='white:#c947a2' value='  ' onclick='/hex 0xc947a2' class='button2' /></td>
            <td><input type='button' width=50 background='white:#ff73d5' value='  ' onclick='/hex 0xff73d5' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#029e68' value='  ' onclick='/hex 0x029e68' class='button2' /></td>
            <td><input type='button' width=50 background='white:#02c481' value='  ' onclick='/hex 0x02c481' class='button2' /></td>
            <td><input type='button' width=50 background='white:#00ffa6' value='  ' onclick='/hex 0x00ffa6' class='button2' /></td>
        </tr>

         <tr><td><input type='button' width=50 background='white:#a14f3f' value='  ' onclick='/hex 0xa14f3f' class='button2' /></td>
             <td><input type='button' width=50 background='white:#cc6854' value='  ' onclick='/hex 0xcc6854' class='button2' /></td>
             <td><input type='button' width=50 background='white:#ff917a' value='  ' onclick='/hex 0xff917a' class='button2' /></td>
        </tr>
        
        </table
    ]]
    net_send(e.uid, "html", html)
end

function wardrobeSkins(e)
    local html = [[<table><tr><td>
        <h2>Planet Skins</h2>
        <tr><td><input type='button' value='back' onclick='/wardrobe' class='button2' />
        <tr><td>No sunglasses for you yet silvershad0w :(((
        </table
    ]]
    net_send(e.uid, "html", html)
end

function wardrobeShips(e)
    local html = [[<table><tr><td>
        <h2>Ships</h2>
        <tr><td><input type='button' value='back' onclick='/wardrobe' class='button2' />
        <tr><td>Still working on the fastest ships in the game...
        </table
    ]]
    net_send(e.uid, "html", html)
end

function loadModeSpecificButtons()
    local html = ""
    if(GAME.galcon.gamemode == "Grid") then
        html = "<tr><td><h3>Map Type<tr><td colspan=2><input type='button' value='Standard' onclick='/standard' class='button2' /><tr><td colspan=2><input type='button' value='Donut' onclick='/donut' class='button2' /><tr><td colspan=2><input type='button' value='Hexagon' onclick='/hexagon' class='button2' />"
    elseif (GAME.galcon.gamemode == "Classic") then
        html = "<tr><td><h3>Map Style <tr><td colspan=2><input type='button' value='Mix' onclick='/mapstyle mix' class='button2' /><tr><td colspan=2><input type='button' value='Classic' onclick='/mapstyle classic' class='button2' /><tr><td colspan=2><input type='button' value='PhilBuff' onclick='/mapstyle philbuff' class='button2' /><tr><td colspan=2><input type='button' value='12 Planet' onclick='/mapstyle 12p' class='button2' /><tr><td colspan=2><input type='button' value='SaandBuff' onclick='/mapstyle saandbuff' class='button2' /><tr><td colspan=2><input type='button' value='Wonk' onclick='/mapstyle wonk' class='button2' />"
    end
    return html
end

function settingsBar()
    local html = [[
        <tr><td class='box3'><h4>SETTINGS:
        <br/>Solo Mode: ]]..soloModeText() .. [[

        ]]
        if GAME.galcon.gamemode == "Grid" then
            html = html .. [[<br/>Map Type: ]]..GAME.galcon.gametype
        elseif GAME.galcon.gamemode == "Classic" then
            html = html .. [[<br/>Map Style: ]].. mapStyleText()
        end
        if GAME.galcon.global.SEED_DATA.KEEP_SEED or GAME.galcon.global.SEED_DATA.CUSTOMISED then
            html = html .. [[<br/>Seed: ]].. GAME.galcon.global.SEED_DATA.SEED
        else
            html = html .. [[<br/>Seed: Random]]
        end
    return html
end

function soloModeText()
    if(GAME.galcon.global.SOLO_MODE) then
        return "On"
    else
        return "Off"
    end
end

function mapStyleText()
    local table = {["mix"] = "Mix", [0] = "Classic", [1] = "PhilBuff", [2] = "12p", [3] = "SaandBuff", [4] = "Wonk"}
    return table[GAME.galcon.global.MAP_STYLE]
end

function gamemodeDescription()
    local description = ""
    if GAME.galcon.gamemode == "Float" then
        description = [[
        <tr><td class='box3'><h4>Don't let your float fleet hit planets or the red line in the middle.<br/>
        Score points by feeding ships to the planet with a green circle <br/> with 100% of your ships.</h4>
        ]]
    end
    return description
end

function ingamePauseMenu()
    --TODO: Make rage quit button leave lobby AND not kick everyone else
    return [[<table>
    <tr><td colspan=2><input type='button' value='Resume' onclick='resume' class='ibutton1' icon='icon-resume'/>
    <tr><td><input type='button' value='Surrender' onclick='/surrender' class='ibutton1' icon='icon-surrender'/>
    <tr><td><input type='button' value='Rage Quit' onclick='/ragequit' class='ibutton1' icon='icon-leave'/>
    </table>]]

    --    

    --Buttons to be added?
    --    <tr><td><input type='button' value='Away' onclick='/away' class='ibutton1' icon='icon-away'/>
    --    <tr><td><input type='button' value='Players' onclick='/players?' class='ibutton1' icon='icon-lobby'/>

end

function playerInState(state)
    local players = ""
    local playersList = {}
    local playercolor = 0
    local darkColor = 0
    local queueNum = 1
    for k,e in pairs(GAME.clients) do
        local wins = 0
        if e.status == state then
            if e.color == 255 then
                playercolor = "#0000ff"         --temporary fix
                darkColor = "#0000aa"
            elseif e.color == 16711680 then
                playercolor = "#ff0000"
                darkColor = "#aa0000"
            elseif e.color == 5592405 then
                playercolor = "#666666"
                darkColor = "#333333"
            else 
                playercolor = string.sub(e.color,3)
                darkColor = darkenColor(e.color)
                playercolor = "#"..playercolor
            end
            for j, u in pairs(GAME.galcon.scorecard) do
                if e.uid == j then
                    wins = u
                end
            end
            local builtName = ""
            if(e.status == "queue") then
                builtName = e.name..stateString(e.status, queueNum)
                queueNum = queueNum + 1
            else
                builtName = e.name..stateString(e.status)
            end
            if isAdmin(e.name) then
                if string.sub(e.name,1,1) ~= "#" then
                    --TODO GET WIDTH WORKING FOR BOTH BARS
                    players = players.."<tr><td><div class='box' width=200 font='font-gui2:20' background='white:"..darkColor .."' color='"..playercolor.."'>".."#"..builtName..playerBarScoreSpacing("#"..builtName, true)..wins .. "<br/>["..e.title.."]"
                end
            else 
                players = players.."<tr><td><div class='box' width=200 font='font-gui2:20' background='white:"..darkColor .."' color='"..playercolor.."'>" ..builtName.. playerBarScoreSpacing(builtName, false)..wins .."<br/>["..e.title.."]"
            end
        end
    end
    if players ~= nil then
    return players
    end
end

function playerBarScoreSpacing(name)
    local space = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    local diff = 18 - string.len(name) --18 for max string length included from stateString()
    for i = 0, diff do 
        space = space .. "&nbsp;"
    end
    return space
end

function stateString(state, num)
    if state == "away" then
        return " (zzz)"
    elseif num ~= nil then
        return " (#"..num..")"
    else
        return ""
    end
end