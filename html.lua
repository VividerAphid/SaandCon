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
                <tr><td align='left'><input type='button' width=15 value='Play' onclick='/play' class='button2' /></td>
                    <td align='center'><input type='button' width=15 value='Away' onclick='/away' class='button2' /></td>
                    <td align='right'><input type='button' width=15 value='Wardrobe' icon='icon-store' onclick='/wardrobe' class='button2' /></td></tr>
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
                <tr><td><h3>PLAY:</h3></td></tr>
            ]]..
                playerInState("play")..playerInState("queue")..
            [[
                <tr><td>
                <tr><td><h3>SPECTATORS:</h3></td></tr>
            ]]..
                playerInState("away")..
            [[
              <tr><td><p>&nbsp;</p>
            ]]
    )
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
    </table>]]

    --    <tr><td><input type='button' value='Rage Quit' onclick='*leave' class='ibutton1' icon='icon-leave'/>

    --Buttons to be added?
    --    <tr><td><input type='button' value='Away' onclick='/away' class='ibutton1' icon='icon-away'/>
    --    <tr><td><input type='button' value='Players' onclick='/players?' class='ibutton1' icon='icon-lobby'/>

end

function playerInState(state)
    local players = ""
    local playersList = {}
    local playercolor = 0
    for k,e in pairs(GAME.clients) do
        local wins = 0
        if e.status == state then
            if e.color == 255 then
                playercolor = "#0000ff"         --temporary fix
            elseif e.color == 16711680 then
                playercolor = "#ff0000"
            elseif e.color == 5592405 then
                playercolor = "#555555"
            else 
                playercolor = string.sub(e.color,3)
                playercolor = "#"..playercolor
            end
            for j, u in pairs(GAME.galcon.scorecard) do
                if e.uid == j then
                    wins = u
                end
            end
            if isAdmin(e.name) then
                if string.sub(e.name,1,1) ~= "#" then
                    players = players.."<tr><td><div class='box' font='font-gui2:25' color="..playercolor..">".."#"..e.name.."&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"..wins
                end
            else 
                players = players.."<tr><td><div class='box' font='font-gui2:25' color="..playercolor..">" ..e.name.."&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"..wins
            end
        end
    end
    if players ~= nil then
    return players
    end
end