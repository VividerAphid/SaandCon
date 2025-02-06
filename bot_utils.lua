local BOT_NAMES = {"Gamaray200000", "GoodSaand", "Nando", "Yaster_Moda_", "Quasont", "Minzzz", "SirSpamAlot", "Botzooka", "Spamageddon","MrMakeYouRQ",
"RageQuitter", "GriefBot232", "BlitzBot", "Elimatron", "SirDeletesU", "Purge.exe"}

function getNewBotName()
    local usePresetName = math.random(1,2)
    local pickedName = "Bot"
    if(usePresetName == 2) then
        local pick = math.random(1, #BOT_NAMES)
        pickedName = BOT_NAMES[pick]
    else
        local pick = math.random(1, 999)
        pickedName = pickedName .. pick
    end
    return pickedName
end

function getNewBotUID()
    GAME.galcon.global.BOT_UID = GAME.galcon.global.BOT_UID-1
    return GAME.galcon.global.BOT_UID
end