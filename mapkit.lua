function getMapStyle(numMapStyles)
    local random = math.random(0,numMapStyles - 1)
    return random
end

function classicMapGen()
    
end

function getSaandbuffVals(version, prod)
    local cost = 0
    if version == 1 then
        if prod >= 30 and prod < 51 then
            cost = math.floor(math.random(5, 10))
        elseif prod >= 51 and prod < 76 then
            cost = math.floor(math.random(11, 30))
        elseif prod >= 76 and prod < 90 then
            cost = math.floor(math.random(30, 45))
        elseif prod >= 90 then
            cost = math.floor(math.random(45, 60))
        end
    elseif version == 2 then
        if prod >= 30 and prod < 46 then
            cost = math.floor(math.random(1, 5))
        elseif prod >= 46 and prod < 61 then
            cost = math.floor(math.random(5, 10))
        elseif prod >= 61 and prod < 75 then
            cost = math.floor(math.random(15, 30))
        elseif prod >= 75 and prod < 90 then
            cost = math.floor(math.random(30, 45))
        elseif prod >= 90 then
            cost = math.floor(math.random(45, 60))
        end
    elseif version == 3 then
        if prod >= 30 and prod < 46 then
            cost = math.floor(math.random(1, 5))
        elseif prod >= 46 and prod < 61 then
            cost = math.floor(math.random(5, 10))
        elseif prod >= 61 and prod < 75 then
            cost = math.floor(math.random(11, 29))
        elseif prod >= 75 and prod < 90 then
            cost = math.floor(math.random(30, 45))
        elseif prod >= 90 then
            cost = math.floor(math.random(45, 60))
        end
    elseif version == 4 then
        if prod >= 20 and prod < 40 then
            cost = math.floor(math.random(0, 5))
        elseif prod >= 40 and prod < 66 then
            cost = math.floor(math.random(6, 15))
        elseif prod >= 66 and prod < 86 then
            cost = math.floor(math.random(16, 40))
        elseif prod >= 86 and prod < 100 then
            cost = math.floor(math.random(41, 60))
        elseif prod >= 100 then
            cost = math.floor(math.random(60, 70))
        end
    elseif version == 5 then
        if prod >= 20 and prod < 41 then
            cost = math.floor(math.random(0, 5))
        elseif prod >= 41 and prod < 61 then
            cost = math.floor(math.random(5, 10))
        elseif prod >= 61 and prod < 81 then
            cost = math.floor(math.random(20, 35))
        elseif prod >= 81 and prod < 100 then
            cost = math.floor(math.random(36, 55))
        elseif prod >= 100 then
            cost = math.floor(math.random(56, 65))
        end
    end
    return cost
end