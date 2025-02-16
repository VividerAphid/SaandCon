function admins_init()
    makeAdmin("esparano")
    makeAdmin("saand")
    makeAdmin("tycho2")
    makeAdmin("saand.-")
    makeAdmin("binah.")
	makeAdmin("vivideraphid")
    makeAdmin("villainaphid")
	makeAdmin("sukuna")
	makeAdmin("galaxy227")
	makeAdmin("silvershad0w")
	makeAdmin("reclamation-")
	makeAdmin("master_yoda_")
	makeAdmin("hurrinado334")
    makeAdmin("archidor")
    makeAdmin("bdt")
    makeAdmin("deadmoon")
end

function initAdmins()
    GAME.admins = GAME.admins or {}
    GAME.admins[cleansePlayerName(g2.name)] = true
end

function makeAdmin(name)
    name = cleansePlayerName(name)
    initAdmins()
    GAME.admins[name] = true
    return true
end

function unadmin(name)
    name = cleansePlayerName(name)
    initAdmins()
    if name ~= cleansePlayerName(g2.name) and GAME.admins[name] ~= nil then 
        GAME.admins[name] = nil
        return true
    end
    return false
end

function isAdmin(name) 
    name = cleansePlayerName(name)
    initAdmins()
    return GAME.admins[name] ~= nil
end

function cleansePlayerName(name)
    name = string.lower(name)
    if name == "gamaray1719" then
        return "Zen_Power17"
    elseif name == "saand.-" or name == "saand" then
        return "Saand"
    end
    return name
end 