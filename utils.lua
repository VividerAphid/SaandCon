function find_user(uid)
    for n,e in pairs(g2.search("user")) do
        if e.user_uid == uid then return e end
    end
end
function find_user_name(name)
    print("From start: "..name)
    print(#GAME.clients)
    for k,e in pairs(GAME.clients) do
        print("G.c[k]: "..GAME.clients[k].name)
        if GAME.clients[k].name == name then
            print("Match!")
            return GAME.clients[k].name
        end
    end
end
function radiusToProd(radius)
    local prod = (radius*17 - 168)*5/12
    return prod
end

function prodToRadius(p)
    return (p * 12 / 5 + 168) / 17
end

function searchString(string, pattern)
    local words = {}
    for word in string:gmatch(pattern) do
        table.insert(words, word)
    end
    return words
end

function getEventUid(e)
    if e.type == "net:message" then
        return e.uid
    else
        -- any unintended consequences?
        return g2.uid
    end
end

function isNetMessageOrButton(e)
    return e.type == "net:message" or e.type == "onclick"
end

function sendMessageGroup(group, message)
    --group is a list of uids
    for r=0, #group do
        net_send(group[r], "message", message)
    end
end

function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function checkNoSpecialChars(str)
    --Allow - . _ ~ but not other non-alphanumeric chars
    local safe = true
    local safeChars = {"-", "~", ".","_"}
    local nonNumeric = string.find(str, "%W")
    if nonNumeric ~= nil then
        for r=1, #str do
            local piece = string.sub(str, r,r)
            if string.find(piece, "%W") ~= nil and has_value(safeChars, piece) == false or string.find(piece, " ") ~= nil then
                safe = false
            end
        end
    end
    return safe
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

--NO NEED FOR THIS I JUST WANTED TO MAKE MY OWN
-- function hexToDecimalAphid(str)
--     local converted = 0
--     local r = 0
--     local length = string.len(str)
--     for r=0, length-1 do
--         local exponent = (length-1) - r
--         local multiple = 16 ^ exponent
--         local actual = multiple * stringToNumber(string.sub(str, r+1, r+1))
--         converted = converted + actual
--     end
--     return converted
-- end

function toNumberExtended(str)
    local finishedVal = 0
    for i = 1, string.len(str) do
        local byt = str.byte(str, i)
        finishedVal = finishedVal * 7
        finishedVal = finishedVal + byt
    end
    return finishedVal
end

function stringToNumber(str)
    local hexVal = {['0'] = 0, ['1'] = 1, ['2'] = 2, ['3'] = 3, ['4'] = 4, ['5'] = 5, ['6'] = 6, ['7'] = 7, 
    ['8'] = 8, ['9'] = 9, ['a'] = 10, ['b'] = 11, ['c'] = 12, ['d'] = 13, ['e'] = 14, ['f'] = 15}
    return hexVal[string.lower(str)]
end

function getDistance(x1, y1, x2, y2)
    local distx = x1 - x2
    local disty = y1 - y2

    local a = distx^2
    local b = disty^2

    local c = a + b
    local dist = math.sqrt(c)
    return dist
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function count_ships()
    local r = {}
    local items = g2.search("planet -neutral")
    for _i, o in ipairs(items) do
        local team = o:owner():team()
        r[team] = (r[team] or 0) + o.ships_value
    end

    local fleets = g2.search("fleet")
    for _i, o in ipairs(fleets) do
        local team = o:owner():team()
        r[team] = (r[team] or 0) + o.fleet_ships
    end
    return r
end

function count_production()
    local r = {}
    local items = g2.search("planet -neutral")
    for _i,o in ipairs(items) do
        if g2.item(o:owner().n).title_value ~= "neutral" then 
            local team = o:owner():team()
            r[team] = (r[team] or 0) + o.ships_production
        end
    end
    return r
end

function most_ships()
    local r = count_ships()
    local best_o = nil
    local best_v = 0
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
        end
    end
    return best_o
end

function most_ships_tie_check()
    local r = count_ships()
    local best_o = nil
    local best_v = 0
    local tie = false
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
            tie = false
        elseif v == best_v then
            tie = true
        elseif v < best_v then
            tie = false
        end
    end
    if tie then
        return "tie"
    else
        return best_o
    end
end

function most_production()
    local r = count_production()
    local best_o = nil
    local best_v = 0
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
        end
    end
    return best_o
end

function most_production_tie_check()
    local r = count_production()
    local best_o = nil
    local best_v = 0
    local tie = false
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
            tie = false
        elseif v == best_v then
            tie = true
        elseif v < best_v then
            tie = false
        end
    end
    if tie then
        return "tie"
    else
        return best_o
    end
end

function find_enemy(uid)
    for n, e in pairs(g2.search("user")) do
        -- user_neutral is not strictly necessary
        if e.user_uid ~= uid and not e.user_neutral and e.title_value ~= "neutral" then
            return e
        end
    end
end

function getUserItems(uid)
    print("Uid in: " .. uid)
    local planets = {}
    local items = g2.search("planet -neutral")
    for _i,o in ipairs(items) do
        print(g2.item(o:owner().n).user_uid)
        local id = g2.item(o:owner().n).user_uid
        if id == uid then
            print("Found")
            table.insert(planets, o)
        end
    end
    print(#planets)
    return planets
end

function hostUidFix(e)
    if e.uid == nil then 
       return g2.uid
    else
       return e.uid
    end
 end