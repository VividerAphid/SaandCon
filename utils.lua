function find_user(uid)
    for n,e in pairs(g2.search("user")) do
        if e.user_uid == uid then return e end
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

function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function hexToDecimal(str)
    local converted = 0
    local r = 0
    local length = string.len(str)
    for r=0, length-1 do
        local exponent = (length-1) - r
        local multiple = 16 ^ exponent
        local actual = multiple * stringToNumber(string.sub(str, r+1, r+1))
        converted = converted + actual
    end
    return converted
end

function decimalToHex(str)
    
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