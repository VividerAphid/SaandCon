if(GAME.galcon.global.RANKED) then
    net_send("", "message", "Settings changes are disabled during ranked mode!")
    return
end