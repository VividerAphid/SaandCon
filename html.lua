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
function resetLobbyHtml()
    if g2.state ~= "lobby" then
        return
    end
	lobby_tabs()
    --params_set("tabs","<table class='box3' width=160><tr><td><h2>SaandCon</h2></table>")
    params_set(
        "html", [[
                <table>
                <tr><td><h1>Play in the Saandbox!</h1></td></tr>
                <tr><td><div color='0xff88ff' font='font-gui2:18'>By TyCho2, Edited by Saand and VividerAphid</div></td></td>
                <tr><td>
                <tr><td colspan=2><input type='button' value='Start' onclick='/start' class='button1' />
                <tr><td>
                <tr><td colspan=2><input type='button' value='Play' onclick='/play' class='button2' />
                <tr><td colspan=2><input type='button' value='Away' onclick='/away' class='button2' />
                <tr><td><div font='font-gui:12'>Type /help for a list of commands, gamemodes,...</div></td></tr>
            ]]..
            [[
                <tr><td>
                <tr><td class='box3'><h4>GAME MODE: ]]..GAME.galcon.gamemode..[[
            ]]..
                gamemodeDescription()..
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

function loadScoreboard()
	params_set("html", [[
              --<tr><td><p>&nbsp;</p>
              <tr><td><h2>Leaderboard
            ]] ..
                getLadderTable() .. [[
                </table>
            ]]
	)
end

function modeTab()
	params_set("html", [[]])
end

function settingsTab()
	params_set("html", [[]])
end

function gamemodeDescription()
    local description = ""
    if GAME.galcon.gamemode == "Float" then
        description = [[
        <tr><td class='box3'><h4>Don't let your float fleet hit planets or the red line in the middle.<br/>
        Score points by feeding ships to the planet with a green circle <br/> with 100% of your ships.</h4>
        ]]
    end
    if GAME.galcon.gamemode == "Grid" then
        description = [[
            <tr><td class='box3'><h4>SETTINGS: ]]..GAME.galcon.gametype..[[
        ]]
    end
    return description
end

function ingamePauseMenu()
    --TODO: Make rage quit button leave lobby
    return [[<table>
    <tr><td colspan=2><input type='button' value='Resume' onclick='resume' class='ibutton1' icon='icon-resume'/>
    <tr><td><input type='button' value='Surrender' onclick='/surrender' class='ibutton1' icon='icon-surrender'/>
    <tr><td><input type='button' value='Rage Quit' onclick='*leave' class='ibutton1' icon='icon-leave'/>
    </table>]]

    --Buttons to be added?
    --    <tr><td><input type='button' value='Away' onclick='/away' class='ibutton1' icon='icon-away'/>
    --    <tr><td><input type='button' value='Players' onclick='/players?' class='ibutton1' icon='icon-lobby'/>

end