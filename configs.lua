function loadConfigs()
    local configs = {
        saandCoins = {
            enableSaandCoins = false, 
            newPlayerSaandCoins = 15,
            currency_name = "SaandCoins"
        },
        startTimerLength = 3,
        maxPlayerLevel = 55,
        enableTrollModes = true, --Enables silly features like /ggwp, /father etc
        randRadiusMode = false,
        defaults = {
            WINNER_STAYS = true,
            TEAMS_MODE = false,
            RANKED = false,
            PLAYLIST_MODE = false,
            PLAYLIST = {},
            PLAYLIST_NAME = "",
            PLAYLIST_STYLE = "random", --order, no-repeat, random
            PLAYLIST_INDEX = 0,
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
        version = "25.10.6a", --Do not change unless you made changes to code
        wipeKeyWord = "25.10.5b", --Warning: Changing this if you have existing data will wipe that data!
        chat_keywords = {"Mins", "/addbot", "/away", "/awayall", "/defaults", "/givecoins", "/kickbot", "/kickallbots", "/replayseed", "/reset", "/rollcolor", "/start", "/surrender", "/version",},
    }
    return configs
end

function loadPlayLists()
    local playlists = {
        --Modes: Stages, Classic, Grid, Frenzy, Float, Race, Line
        --Variants: Classic: {Mix, Classic, Philbuff, 12 Planet, SaandBuff, Wonk, 1Ship}
        --Saandbuff versions: V1-V10
        --ex: {mode='Classic', variant='SaandBuff', v=1}
        -- v is specified only for SaandBuff, not specifying v will default to all v's
        -- names are not case sensitve, that is handled under the hood
        'ElimV2', 'AphidCon',
        ElimV2 = {{mode='Stages', variant=''}, {mode='Classic', variant='Philbuff'}, 
                  {mode='Classic', variant='Classic'}, {mode='Classic', variant='SaandBuff'},
                  {mode='Classic', variant='12 planet'}},
        AphidCon = {{mode='Classic', variant='Wonk'}, {mode='Classic', variant='1Ship'},
                    {mode='Frenzy', variant=''}},
    }
    return playlists
end