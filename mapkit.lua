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
    elseif version == 6 then
        if prod >= 20 and prod < 41 then
            cost = math.floor(math.random(0, 5))
        elseif prod >= 41 and prod < 66 then
            cost = math.floor(math.random(5, 15))
        elseif prod >= 66 and prod < 81 then
            cost = math.floor(math.random(12, 30))
        elseif prod >= 81 and prod < 100 then
            cost = math.floor(math.random(25, 60))
        elseif prod >= 100 then
            cost = math.floor(math.random(30, 70))
        end
    elseif version == 7 then
        if prod >= 30 and prod < 51 then
            cost = math.floor(math.random(5, 10))
        elseif prod >= 51 and prod < 71 then
            cost = math.floor(math.random(10, 20))
        elseif prod >= 71 and prod < 81 then
            cost = math.floor(math.random(20, 30))
        elseif prod >= 81 and prod < 100 then
            cost = math.floor(math.random(30, 60))
        elseif prod >= 100 then
            cost = math.floor(math.random(40, 70))
        end
    elseif version == 8 then
        if prod >= 20 and prod < 41 then
            cost = math.floor(math.random(0, 5))
        elseif prod >= 41 and prod < 61 then
            cost = math.floor(math.random(10, 20))
        elseif prod >= 61 and prod < 81 then
            cost = math.floor(math.random(20, 30))
        elseif prod >= 81 then
            cost = math.floor(math.random(35, 70))
        end
    elseif version == 9 then
        if prod >= 15 and prod < 41 then
            cost = math.floor(math.random(0, 5))
        elseif prod >= 41 and prod < 61 then
            cost = math.floor(math.random(5, 10))
        elseif prod >= 61 and prod < 71 then
            cost = math.floor(math.random(11, 20))
        elseif prod >= 71 then
            cost = math.floor(math.random(20, 40))
        end
    elseif version == 10 then
        if prod >= 15 and prod < 30 then
            cost = math.floor(math.random(0, 3))
        elseif prod >= 30 and prod < 51 then
            cost = math.floor(math.random(4, 9))
        elseif prod >= 51 and prod < 71 then
            cost = math.floor(math.random(10, 20))
        elseif prod >= 71 and prod < 80 then
            cost = math.floor(math.random(20, 35))
        elseif prod >= 80 then
            cost = math.floor(math.random(30, 40))
        end
    elseif version == 11 then
        cost = getV11Cost(prod)
    elseif version == 12 then
        -- Tiered breakpoints that create clear expansion strata.
        if prod >= 15 and prod < 40 then
            cost = math.floor(math.random(0, 8))
        elseif prod >= 40 and prod < 60 then
            cost = math.floor(math.random(8, 18))
        elseif prod >= 60 and prod < 80 then
            cost = math.floor(math.random(20, 28))
        elseif prod >= 80 and prod < 100 then
            cost = math.floor(math.random(35, 45))
        elseif prod >= 100 then
            cost = math.floor(math.random(50, 60))
        end
    elseif version == 13 then
        -- Controlled local variance: add a small random bias to each tier.
        -- Produces "hot/cold" zones while remaining fair in aggregate.
        local bias = math.random(-5, 5)
        local lo, hi

        if prod >= 0 and prod < 40 then
            lo, hi = 0 + bias, 8 + bias            
        elseif prod >= 40 and prod < 60 then
            lo, hi = 8 + bias, 20 + bias
        elseif prod >= 60 and prod < 80 then
            lo, hi = 20 + bias, 35 + bias
        elseif prod >= 80 then
            lo, hi = 35 + bias, 60 + bias
        end
        lo = math.max(0, lo)
        hi = math.max(lo, hi)
        cost = math.floor(math.random(lo, hi))
    end
    return cost
end

function getV11Cost(prod, meanProd)
    -- Elastic scaling: costs scale relative to the map's average production.
    -- Expect a variable 'meanProd' to be available (global or passed in).
    -- If it's not available, we fall back to 70 as a sensible default.
    local cost = -1
    local ref = meanProd or 70
    local ratio = prod / ref

    if ratio < 0.60 then
        cost = math.floor(math.random(0, 8))
    elseif ratio < 0.90 then
        cost = math.floor(math.random(8, 20))
    elseif ratio < 1.20 then
        cost = math.floor(math.random(20, 40))
    else
        cost = math.floor(math.random(40, 70))
    end
    return cost
end

function loopV11Planets(totalProd, planets)
    local meanProd = totalProd / #planets
    for r=3, #planets do
        local tmpCost = getV11Cost(planets[r].prod) --add meanProd in later 
        planets[r].cost = tmpCost
    end
end

function getSaandDistProd(version, distance, maxDistance)
    local prod = 50
    prod = (distance/maxDistance)*100
    print("picked prod: "..prod)
    return prod
end

function getSaandDistCost(version, prod)
    local cost = 15
    cost = prod
    return cost
end 