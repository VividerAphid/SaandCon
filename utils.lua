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

function stringToNumber(string)
    if string == "a" then string = 10 end
    if string == "b" then string = 11 end 
    if string == "c" then string = 12 end
    if string == "d" then string = 13 end
    if string == "e" then string = 14 end
    if string == "f" then string = 15 end
    return string
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
