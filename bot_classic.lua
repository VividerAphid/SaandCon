function bot_classic(user)return{loop=function(self)
	find("planet owner:"..user,function(f)if f.ships_value<10 then return end
		local t=find("planet -owner:"..user,function(o)return-o.ships_value+o.ships_production-o:distance(f)/5 end)
		if not t then return end
		f:fleet_send(65,find("planet owner:"..user,function(p)
			local ft,pt,fp=f:distance(t),p:distance(t),f:distance(p)
			if p~=f and pt<ft and(pt+fp-p.planet_r*2)<ft then return-fp end
		end)or t)
	end)
	find("fleet owner:"..user,function(f)
		local t=find("planet -owner:"..user,function(o)return-o.ships_value+o.ships_production-o:distance(f)/5 end)
		if t and f.fleet_target~=t then
			f:fleet_redirect(find("planet owner:"..user,function(p)
				local ft,pt,fp=f:distance(t),p:distance(t),f:distance(p)
				if p~=f and pt<ft and(pt+fp-p.planet_r*2)<ft then return-fp end
			end)or t)
		end
	end)
end}end

-- Return the number of ships "planet" will have "time" seconds from now
function future_ships(planet, time)
    local ships = planet.ships_value
    if planet.ships_production_enabled then
        ships = ships + prod_to_ships(planet.ships_production) * time
    end
    return ships
end

-- convert distance to time (assumes constant ship movement speed)
function dist_to_time(dist)
	return dist/40
end

-- convert time to distance (assumes constant ship movement speed)
function time_to_dist(time)
	return time*40
end

-- convert planet production to ships per second 
function prod_to_ships(prod)
    return prod / 50
end

-- convert ships per second to planet production
function ships_to_prod(ships)
    return ships * 50
end

-- try to send an amount of ships, return the amount sent
function send_exact(user, from, to, ships)
    if from.ships_value < ships then
        from:fleet_send(100, to)
        return from.ships_value
    end
    local perc = ships / from.ships_value * 100
    if perc > 100 then perc = 100 end
    from:fleet_send(perc, to)
    return ships
end

-- create a deep copy of the object, return the copy
function deep_copy(obj)
    local copy = {}
    if type(obj) ~= 'table' then return obj end
    for k,v in pairs(obj) do
        copy[k] = deep_copy(v)
    end
    return copy
end

-- find the best item described by "query" using a evaluation function "eval"
function find(query,eval)
    local res = g2.search(query)
    local best = nil; local value = nil
    for _i,item in pairs(res) do
        local _value = eval(item)
        if _value ~= nil and (value == nil or _value > value) then
            best = item
            value = _value
        end
    end
    return best
end