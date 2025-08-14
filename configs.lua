function loadConfigs()
    local configs = {
        saandCoins = {
            enableSaandCoins = false, 
            newPlayerSaandCoins = 15,
            currency_name = "SaandCoins"
        },
        maxPlayerLevel = 55,
        enableTrollModes = true, --Enables silly features like /ggwp, /father etc
        randRadiusMode = false,
        defaults = {
            WINNER_STAYS = false,
            TEAMS_MODE = false,
            MAX_PLAYERS = 2,
            MAX_BOT_COUNT = 16,
            MAP_STYLE = 3,
            SAANDBUFF_DATA = {
                VERSIONS_ENABLED = {true, true, true, true, true, true, true, true, true, true}, --V1-V10
                DISTANCE_ENABLED = false,
            },
            TIMER_LENGTH = 0,
            STARTING_SHIPS = 100,
            HOME_COUNT = 1,
            HOME_PROD = 100,
            GRID={
                NEUT_COST = 5,
                NEUT_PROD = 30,
                HOME_PROD = 80,
                START_SHIPS = 100,
            },
            SEED_DATA = {
                SEED = 1,
                PREV_SEED = 1,
                CUSTOMISED = false,
                KEEP_SEED = false,
                SEED_STRING = "",
                PREV_SEED_STRING = "",
            },
            stupidSettings = {
                silverMode = false,
                yodaFilter = false,
                breadmode = false,
                saandmode = false,
                rechameleon = false,
                recID = 0, 
            },
        },
        version = "25.8.13a", --Do not change unless you made changes to code
        wipeKeyWord = "White Rabbit", --Warning: Changing this if you have existing data will wipe that data!
        chat_keywords = {"Mins", "/addbot", "/away", "/awayall", "/defaults", "/givecoins", "/kickbot", "/kickallbots", "/replayseed", "/reset", "/rollcolor", "/start", "/surrender", "/version",},
    }
    return configs
end
