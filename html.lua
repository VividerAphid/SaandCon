function startupMenu()
    return [[
        <table>
        <tr><td colspan=2><h1>Galcon 2 Server</h1>
        <tr><td><p>&nbsp;</p>
        <tr><td><input type='text' name='title' value='$TITLE' />
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
                <tr><td></td></tr>
                <tr><td class='box'><h3>]]..GAME.data.title..
                gamemodeDescription()..
                settingsBar()..
                [[
                <tr><td></td></tr>
                <tr><td colspan=3><input type='button' value='Start' onclick='/start' class='button1' /></td></tr>
                <tr><td></td></tr>
                <tr><td colspan=3><input type='button' value='Toggle /Play' onclick='/toggleplay' class='button2' /></td>
                <tr><td><input type='button' value='GG' onclick='/gg' class='button2' /></td>
                <tr><td colspan=2></td></tr>
            ]]..
            [[
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

        -- <tr><td><div font='font-gui:12'>Type /help for a list of commands, gamemodes,...</div></td></tr>
        -- <tr><td><h1>Play in the Saandbox!</h1></td></tr>
        -- <tr><td><div color='0xff88ff' font='font-gui2:18'>By TyCho2, Edited by Saand and VividerAphid</div></td></tr>
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
            <td><input type='button' class='tab' width='22%' value='Ranks/Style' icon='icon-queue'    onclick='/leaderboard'               />
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
              <tr><td><input type='button' value='Wardrobe' icon='icon-store' onclick='/wardrobe' class='ibutton' icon='icon-store' /></td></tr>
              <tr><td><p>&nbsp;</p>
              <tr><td><h2>ELO Leaderboard</h2>
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
    local home_prod = GAME.galcon.global.HOME_PROD
    local start_ships = GAME.galcon.global.STARTING_SHIPS
    if(GAME.galcon.gamemode == "Grid") then
        home_prod = GAME.galcon.global.GRID.HOME_PROD
        start_ships = GAME.galcon.global.GRID.START_SHIPS
    end
    local html = [[
        <table><tr><td colspan=3>
        <h2>Settings</h2>
        <tr><td colspan=3><input type='button' value='Solo Mode' onclick='/solo' />
        <tr><td colspan=1><h3>Timer:</h3><td><input type='slider' onchange="/timer {$timer}" value=']]..GAME.galcon.global.TIMER_LENGTH..[[' name='timer' low=0 high=30/>
        <tr><td colspan=1><h3>Starting Ships:</h3><td><input type='slider' onchange="/startships {$ships}" value=']]..start_ships..[[' name='ships' low=0 high=200/>
        <tr><td colspan=1><h3>Home Prod:</h3><td><input type='slider' onchange="/homeprod {$prod}" value=']]..home_prod..[[' name='prod' low=0 high=200/>
        <tr><td colspan=1><h3>Home Count:</h3><td><input type='slider' onchange="/homes {$homes}" value=']]..GAME.galcon.global.HOME_COUNT..[[' name='homes' low=1 high=3/>
        <tr><td><input type='button' value="Change seed" onclick='/seed {$seedbox}' />
            <td><input type="text" name='seedbox' value=""/>
        <tr><td><input type='button' value='Replay seed' onclick='/replayseed' />
            <td><input type='button' value='Keep Seed' onclick='/keepseed' />
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
    local saandCoinHeader = [[]]
    local buyCoinBtn = [[]]
    if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
        saandCoinHeader = [[<tr><td><h2>Your SaandCoins: ]]..GAME.clients[e.uid].coins..[[</h2></td><td><img src="coin" width=50 height=50></tr>]]
        buyCoinBtn = [[<tr><td><input type='button' value='Buy Coins' onclick='/wardrobe coins' icon="icon-store" class='ibutton' />]]
    end
    local html = [[<table><tr><td>
        <h2>Wardrobe</h2>
        <tr><td><input type='button' value='back' onclick='/lobby' icon="icon-restart" class='ibutton' />]]
        ..saandCoinHeader..
        [[<tr><td><input type='button' value='Colors' onclick='/wardrobe colors' icon="icon-edit" class='ibutton' />
        <tr><td><input type='button' value='Ships' onclick='/wardrobe ships' icon="icon-clans" class='ibutton' />
        <tr><td><input type='button' value='Skins' onclick='/wardrobe skins' icon="icon-world" class='ibutton' />
        <tr><td><input type='button' value='Name Change' onclick='/wardrobe name' icon="icon-membership" class='ibutton' />
        <tr><td><input type='button' value='Title Change' onclick='/wardrobe title' icon="icon-admin" class='ibutton' />
        ]]..buyCoinBtn..[[
        </table
    ]]
    net_send(e.uid, "html", html)
end

function wardrobeColors(e)
    local headerText = "Colors"
    if(GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins) then
        headerText = headerText .. " (1 per)"
    end
    local html = [[<table><tr><td>
        <td><h2>]]..headerText..[[</h2>
        <tr><td><td><input type='button' width=50 value='back' onclick='/wardrobe' class='button2' />
        <tr><td><td><input type='button' width=50 value='Surprise Me' onclick='/rollcolor' class='button2' />
        
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
            <td><input type='button' width=50 background='white:#00d68c' value='  ' onclick='/hex 0x00d68c' class='button2' /></td>
            <td><input type='button' width=50 background='white:#00ffa6' value='  ' onclick='/hex 0x00ffa6' class='button2' /></td>
        </tr>
        <tr><td><input type='button' width=50 background='white:#0053ed' value='  ' onclick='/hex 0x0053ed' class='button2' /></td>
            <td><input type='button' width=50 background='white:#0080ff' value='  ' onclick='/hex 0x0080ff' class='button2' /></td>
            <td><input type='button' width=50 background='white:#59acff' value='  ' onclick='/hex 0x59acff' class='button2' /></td>
        </tr>
         <tr><td><input type='button' width=50 background='white:#ab5443' value='  ' onclick='/hex 0xab5443' class='button2' /></td>
             <td><input type='button' width=50 background='white:#cc6854' value='  ' onclick='/hex 0xcc6854' class='button2' /></td>
             <td><input type='button' width=50 background='white:#ff917a' value='  ' onclick='/hex 0xff917a' class='button2' /></td>
        </tr>
        
        </table
    ]]
    net_send(e.uid, "html", html)
end

function wardrobeSkins(e)
    local skinTexts = {'Normal','Honeycomb','Ice','Terrestrial','Gas Giant','Craters','Gaseous','Lava', 'Void', 'Disco','Swirls','Floral',
    'Hearts', 'Clovers', 'Zerba', 'Giraffe', 'Eyes', 'Cow', 'Fossil', 'Snowcaps', 'Smooth', 
    'Whisp', 'Charlie', 'Snowflake', 'Candycane', 'Snowglobe'}
    local headerText = "Planet Skins"
    if(GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins) then
        headerText = headerText .. " (30 each)"
    end
    local html = [[<table><tr><td colspan=3>
        <h2>]]..headerText..[[</h2>
        <tr><td colspan=3><input width=135 type='button' value='back' onclick='/wardrobe' />
        <tr><td>]]
    local planets = GAME.galcon.global.planets
    for r=1, #planets do
        if(math.fmod(r-1, 3) == 0) then
            html = html .. [[<tr>]]
        end
        local class = "button"
        if has_value(GAME.clients[e.uid].ownedSkins, planets[r]) then
            class = "button2"            
        end
        html = html .. [[<td><input type='button' width=135 value=']]..skinTexts[r]..[[' onclick='/setskin ]]..planets[r]..[[' class=']]..class..[['/>]]
    end
    net_send(e.uid, "html", html)
end

function wardrobeShips(e)
    local headerText = "Ships"
    if(GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins) then
        headerText = headerText .. " (15 each)"
    end
    local ownedShips = GAME.clients[e.uid].ownedShips
    local shiplist = GAME.galcon.global.ships
    local html = [[<table><tr><td colspan=3>
        <h2>]]..headerText..[[</h2>
        <tr><td colspan=3><input type='button' width=100 value='back' onclick='/wardrobe' />
        <tr><td>
        <tr>]]
    for r=1, #ownedShips do
        if(math.fmod(r-1, 3) == 0) then
            html = html .. [[<tr>]]
        end
        html = html .. [[<td><input type="button" width=20 height=20 onclick='/setship ]]..ownedShips[r]..[[' class='button2'><img src=']]..ownedShips[r]..[['></input></td>]]
    end
    html = html .. [[<tr><td><tr><td>]]
    for r=0, #shiplist do
        if has_value(ownedShips, shiplist[r]) == false then
            if(math.fmod(r, 3) == 0) then
                html = html .. [[<tr>]]
            end
            html = html .. [[<td><input type="button" width=20 height=20 onclick='/setship ]]..shiplist[r]..[[' class='button'><img src=']]..shiplist[r]..[['></input></td>]]
        end
    end
    html = html..[[
        </table>
    ]]
    net_send(e.uid, "html", html)
end

function wardrobeName(e)
    local headerText = "Name Change"
    if(GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins) then
        headerText = headerText .. " (50 per)"
    end
    local html = [[<table><tr><td colspan=3>
    <h2>]]..headerText..[[</h2>
    <tr><td colspan=3><input type='button' width=100 value='back' onclick='/wardrobe' />
    <tr>
    <tr><td>New Name:<td> <input type='text' name="newname" value=]]..e.name..[[/>
    <tr><td colspan=3><input type='button' class='ibutton' icon="coin" value="Confirm" onclick='/setname {$newname}'/>
    ]]

    net_send(e.uid, "html", html)
end

function wardrobeTitle(e)
    local headerText = "Title Change"
    if(GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins) then
        headerText = headerText .. " (5 per)"
    end
    local html = [[<table><tr><td colspan=3>
    <h2>]]..headerText..[[</h2>
    <tr><td colspan=3><input type='button' width=100 value='back' onclick='/wardrobe' />
    <tr>
    <tr><td>New Name:<td> <input type='text' name="newtitle" value=]]..GAME.clients[e.uid].title..[[/>
    <tr><td colspan=3><input type='button' class='ibutton' icon="coin" value="Confirm" onclick='/title {$newtitle}'/>
    ]]

    net_send(e.uid, "html", html)
end

function wardrobeCoins(e)
    local proceedsMessages = {"All proceeds go towards training <br/> for Yoda to deal with stupidity",
    "&nbsp;&nbsp;All proceeds go towards saving <br/>Saltkuna from his crippling addiction <br/>&nbsp;&nbsp;to obnoxious gaming hardware",
    "All proceeds go to buying <br/>nando a proper mouse and <br/>keyboard so he can't make <br/>&nbsp;&nbsp;excuses anymore",
    "All proceeds go towards therapy <br/>&nbsp;&nbsp;&nbsp;&nbsp;to help Saand figure out <br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;his optimal settings",
    "All proceeds go towards writing <br/>more fake fundraiser messages",
    "All proceeds go towards Recs <br/>extensive color changing",
    "All proceeds go towards making <br/>&nbsp;&nbsp;&nbsp;&nbsp;timers more resistant to <br/>&nbsp;&nbsp;&nbsp;&nbsp;galaxy always winning",
    "All proceeds go towards making <br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Saands ping lower",
    "All proceeds go towards helping <br/>&nbsp;&nbsp;&nbsp;&nbsp;gamaray show up on time"
    }
    local pick = proceedsMessages[math.random(#proceedsMessages)]
    local html = [[<table><tr><td>
    <h2>Buy Coins</h2>
    <tr><td><input type='button' value='back' onclick='/wardrobe' icon="icon-restart" class='ibutton' />
    <tr><td>
    <tr><td><div class=box2>]]..pick..[[</div>
    <tr><td>
    <tr><td><input type='button' value='$0.99 (99)' onclick='/buycoins' icon="coin" class='ibutton' />
    <tr><td><input type='button' value='$1.99 (199)' onclick='/buycoins' icon="coin" class='ibutton' />
    <tr><td><input type='button' value='$9.99 (999)' onclick='/buycoins' icon="coin" class='ibutton' />
    <tr><td><input type='button' value='$49.99 (4999)' onclick='/buycoins' icon="coin" class='ibutton' />
    <tr><td><input type='button' value='$69.69 (6969)(Nice)' onclick='/buycoins' icon="coin" class='ibutton' />
    <tr><td><input type='button' value='$420.69 (42069)(Lit)' onclick='/buycoins' icon="coin" class='ibutton' />
    <tr><td><input type='button' value='$1000.00 (100000)' onclick='/buycoins' icon="coin" class='ibutton' />
    ]]
    net_send(e.uid, "html", html)
end

function wardrobeCoinsSuccess(e)
    local html = [[<table>
        <tr><td><h2>Swindled</h2>
        <tr><td><input type='button' value='back' onclick='/wardrobe' icon="icon-restart" class='ibutton' />
        <tr><td>
        <tr><td><h2>You were really going to spend money?</h2>
        <tr><td><h2>Get gud noob.</h2>
    ]]
    net_send(e.uid, "html", html)
end

function buildShipList()
    local shiplist = {}
    for r=0, 22 do
        shiplist[r] = "ship-"..r
    end
    shiplist[23] = "ship-22b"
    shiplist[24] = "ship-22c"
    for r=25, 52 do
        shiplist[r] = "ship-"..r-2
    end
    shiplist[53] = "ship-58"
    shiplist[54] = "ship-59"
    shiplist[55] = "ship-60"
    shiplist[56] = "ship-66"
    shiplist[57] = "ship-67"
    shiplist[58] = "ship-68"
    shiplist[59] = "ship-69"
    shiplist[60] = "ship-70"
    shiplist[61] = "ship-76"
    shiplist[62] = "ship-77"
    shiplist[63] = "ship-78"
    shiplist[64] = "ship-79"
    shiplist[65] = "ship-80"
    for r=66, 75 do
        shiplist[r] = "ship-"..r+35
    end
    local t = 1
    for r=76, 81 do
        shiplist[r] = "ship-dec"..t
        t = t+1
    end
    shiplist[82] = "ship-dis1"
    t = 4
    for r=83, 100 do
        shiplist[r] = "ship-f"..t
        t = t+1
    end
    t = 86
    for r=101, 113 do
        shiplist[r] = "ship-f"..t
        t = t+1
    end
    shiplist[114] = "ship-jan1"
    shiplist[115] = "ship-jan2"
    shiplist[116] = "ship-nov1"
    t = 101
    for r=117, 146 do
        shiplist[r] = "ship-p"..t
        t = t+1
    end
    t = 201
    for r=147, 176 do
        shiplist[r] = "ship-p"..t
        t = t+1
    end
    t = 301
    for r=177, 206 do
        shiplist[r] = "ship-p"..t
        t = t+1
    end
    t = 401
    for r=207, 236 do
        shiplist[r] = "ship-p"..t
        t = t+1
    end
    shiplist[237] = "ship-pi"
    shiplist[238] = "ship-pl1"
    shiplist[239] = "ship-pl2"
    shiplist[240] = "ship-pl3"
    t = 1
    for r=241, 606 do
        if t < 10 then
            shiplist[r] = "ship-t00"..t
        elseif t < 100 and t > 9 then
            shiplist[r] = "ship-t0"..t
        else
            shiplist[r] = "ship-t"..t
        end
        t = t+1
    end
    -- for r=0, #shiplist do
    --     print(shiplist[r])
    -- end
    return shiplist
end

function loadModeSpecificButtons()
    local html = ""
    if(GAME.galcon.gamemode == "Grid") then
        html = "<tr><td colspan=3><h3>Map Type<tr><td colspan=2><input type='button' value='Mix' onclick='/gridstyle mix' class='button2' /><tr><td colspan=2><input type='button' value='Standard' onclick='/gridstyle standard' class='button2' /><tr><td colspan=2><input type='button' value='Donut' onclick='/gridstyle donut' class='button2' /><tr><td colspan=2><input type='button' value='Hexagon' onclick='/gridstyle hexagon' class='button2' />"
        html = html .. [[<tr><td colspan=1><h3>Neut Cost:</h3><td><input type='slider' onchange="/gridneutcost {$neutcost}" value=']]..GAME.galcon.global.GRID.NEUT_COST..[[' name='neutcost' low=0 high=200/>
                         <tr><td colspan=1><h3>Neut Prod:</h3><td><input type='slider' onchange="/gridneutprod {$neutprod}" value=']]..GAME.galcon.global.GRID.NEUT_PROD..[[' name='neutprod' low=0 high=200/>
                        ]]
    elseif (GAME.galcon.gamemode == "Classic") then
        html = "<tr><td colspan=3><h3>Map Style <tr><td colspan=1><input type='button' value='Mix' onclick='/mapstyle mix' class='button2' /><td colspan=1><input type='button' value='Classic' onclick='/mapstyle classic' class='button2' /><tr><td colspan=1><input type='button' value='PhilBuff' onclick='/mapstyle philbuff' class='button2' /><td colspan=1><input type='button' value='12 Planet' onclick='/mapstyle 12p' class='button2' /><tr><td colspan=1><input type='button' value='SaandBuff' onclick='/mapstyle saandbuff' class='button2' /><td colspan=1><input type='button' value='Wonk' onclick='/mapstyle wonk' class='button2' />"
        if(GAME.galcon.global.MAP_STYLE == 3) then
            html = html .. [[<tr><td colspan=3><h3>SaandBuff Versions</h3>]]
            local v_enableds = GAME.galcon.global.SAANDBUFF_DATA.VERSIONS_ENABLED
            local c_count = 0
            for i=1, #v_enableds do
                if c_count == 0 then
                    html = html .. [[<tr>]]
                end
                c_count = c_count + 1
                if v_enableds[i] == true then
                    html = html .. [[<td><input type='button' width=100 value='V]]..i..[[' onclick='/togglesaandbuff ]]..i..[[' class='button2' />]]
                else
                    html = html .. [[<td><input type='button' width=100 value='V]]..i..[[' onclick='/togglesaandbuff ]]..i..[[' class='button3' />]]
                end
                if c_count == 2 then
                    c_count = 0
                end
            end
        end
    end
    return html
end

function settingsBar()
    local html = [[
        <tr><td class='box3'><h4>SETTINGS:
        <br/>Game Mode: ]] .. GAME.galcon.gamemode ..
        [[<br/>Solo Mode: ]]..soloModeText() .. [[

        ]]
        if GAME.galcon.gamemode == "Grid" then
            html = html .. [[<br/>Map Type: ]]..GAME.galcon.gametype
        elseif GAME.galcon.gamemode == "Classic" then
            html = html .. [[<br/>Map Style: ]].. mapStyleText()
        end
        if GAME.galcon.global.SEED_DATA.KEEP_SEED or GAME.galcon.global.SEED_DATA.CUSTOMISED then
            if(GAME.galcon.global.SEED_DATA.SEED_STRING ~= nil) then
                html = html .. [[<br/>Seed: ]].. GAME.galcon.global.SEED_DATA.SEED_STRING
            else
                html = html .. [[<br/>Seed: ]].. GAME.galcon.global.SEED_DATA.SEED
            end    
        else
            html = html .. [[<br/>Seed: Random]]
        end
        if GAME.galcon.global.TIMER_LENGTH ~= 0 then
            html = html .. [[<br/>Timer: ]] .. GAME.galcon.global.TIMER_LENGTH / 60 .. " minutes"
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
    local table = {["mix"] = "Mix", [0] = "Classic", [1] = "PhilBuff", [2] = "12p", [3] = "SaandBuff", [4] = "Wonk",  [5] = "1 Ship"}
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
    <tr><td><input type='button' height=100 value='Surrender' onclick='/surrender' class='ibutton1' icon='icon-surrender'/>
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

function update_score(time)
    GAME.galcon.float.score = math.floor(GAME.galcon.float.score1 * GAME.galcon.float.score2 +0.5)
    
    if GAME.galcon.float.reinforceplanet.ships_value > GAME.galcon.float.reinforceplanet_cost then 
        GAME.galcon.float.reinforceplanet_cost = GAME.galcon.float.reinforceplanet_cost + 1
        GAME.galcon.float.score1 = GAME.galcon.float.reinforceplanet_cost
    end

    for i=1, #GAME.galcon.float.r do
        if GAME.galcon.float.r[i].ships_value < 1 then --cheated with shift spam
            GAME.galcon.float.score2 = GAME.galcon.float.score2 + 0.001
        end
    end
    if GAME.galcon.float.score ~= 0 then 
        g2.status = "Time: ".. math.floor(time).."              ".."Score: "..GAME.galcon.float.score
        g2.net_send("","status",g2.status)
    end
end

function displayFloatTimer(time)
    if time ~= 0 then
        g2.status = "Time: ".. math.floor(time).."              ".."Score: "..GAME.galcon.float.score
        g2.net_send("","status",g2.status)
    end
end

function print_scoreTime(time)
    net_send("","message","Time survived: "..math.floor(math.floor(time+0.5)).." seconds")
    net_send("","message","Score: "..GAME.galcon.float.score.." points")
end

function displayTimer(time)
    local minute = math.floor(time / 60)
    local second = math.floor(time % 60)
    if second < 10 then
        second = "0"..second
    end
    g2.status = get_formmatted_time(time)
    g2.net_send("","status",get_formmatted_time(time))
end

function get_formmatted_time(time)
    local minute = math.floor(time / 60)
    local second = math.floor(time % 60)
    if second < 10 then
        second = "0"..second
    end
    return minute..":"..second
end