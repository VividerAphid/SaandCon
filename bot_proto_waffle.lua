--'Proto Waffle'
function bot_protowaffle(params)
	local G = g2.items
	local USER = g2.user
	local plist,players={},{}
	search(function(v)
		if not v.neutral and(v.type=="planet"or v.type=="fleet")then
			local o=v.owner
			local p=players[o]
			if not p and o~=USER then plist[#plist+1]=o end
			players[o]=(p or 0)+v.ships
		end
	end)
	if not players[USER]then return end
	while true do -- table.sort
		local k=true
		for i=1,#plist-1 do
			local a,b=plist[i+1],plist[i]
			if players[a]<players[b]then
				plist[i+1],plist[i]=b,a
				k=false
			end
		end
		if k then break end
	end
	local plistm,plistm2=plist[#plist],plist[#plist-1]
	local plistp,playeru=players[plistm],players[USER]
	local big=(plistp or 0)*2
	local selfc=(playeru or 0)-(plistp or 0)
	for i=1,#plist-1 do
		local v=players[plist[i]]
		big=big-v
		selfc=selfc-v
	end
	if big>(playeru or big)then
		local prod=0
		search(function(v)
			if v.type=="planet"then
				if v.owner==plistm then
					prod=prod+v.production
				elseif not v.neutral then
					prod=prod-v.production
				end
			end
		end)
		if prod<0 then prod=0 end
		big=(big+prod>(playeru or big))
	else
		big=false
	end
	local ships,planets={},my_planets()
	for _,v in pairs(planets)do
		local n=v.ships
		search(function(f)
			if f.type=="fleet"and f.target==v.n then
				if f.owner==USER then
					n=n+f.ships
				else
					n=n-f.ships
				end
			end
		end)
		ships[v]=n
	end
	while true do -- table.sort
		local k=true
		for i=1,#planets-1 do
			local a,b=planets[i+1],planets[i]
			if ships[a]>ships[b]then
				planets[i+1],planets[i]=b,a
				k=false
			end
		end
		if k then break end
	end
	local planetf,planett=planets[1],planets[#planets]
	if big or #plist==1 or selfc>0 then
		if not planetf then return end
		for _,f in pairs(planets)do
			local t=find(search(function(v)
				if v.type~="planet"then return end
				if big then return v.owner==plistm end
				return not v.neutral and v.owner~=USER
			end),function(o)return-distance(o,f)end)
			if not t then return end
			for _,p in pairs(planets)do
				local ft,fp=distance(f,t),distance(f,p)
				if fp<ft then
					local pt=distance(p,t)
					if p~=f and pt<ft and(pt+fp-p.r*2)<ft then
						t=p
					end
				end
			end
			return send(65,f,t)
		end
	elseif playeru and players[plistm2]then
		local r,capture,otherplanets=playeru-players[plistm2]*2/3
		if playeru>players[plistm2]then
			otherplanets=other_planets()
			local x=find(planets,function(a)local t=find(otherplanets,function(b)return-distance(a,b)/5-b.ships end)if t then return-distance(a,t)end end)
			local capture=false
			if x and playeru-x.ships>players[plistm2]then
				capture=x
			end
			if x and not big then r=HUGE end
		end
		if r>0 then
			local target=big and find(search(function(f)return f.type=="planet"and f.owner==plistp end),function(a)
					local t=find(planets,function(b)return-distance(a,b)end)
					if t then
						return-distance(a,t)/5-a.ships
					end
				end)
				or capture
				or find(neutral_planets(),function(a)
					local c=a.ships
					for _,v in pairs(search(function(f)return f.type=="fleet"and f.OWNER~=USER and f.target==a.n end))do
						c=c-v.ships
					end
					if c<0 then return end
					local t=find(planets,function(b)return-distance(a,b)end)
					if t then return-distance(a,t)/5-c end
				end)
				or find(otherplanets or other_planets(),function(a)
					local t=find(planets,function(b)return-distance(a,b)/5-a.ships end)
					if t then return-distance(a,t)end
				end)
			local planet=find(planets,function(p)return-distance(p,target)end)
			if not planet then return end
			if r>planet.ships and r*.35>target.ships then
				local f=planetf
				local tunnel={}
				for i=1,5 do -- tunnel limit
					if f==planet then break end
					local t=planet
					for _,p in pairs(planets)do
						local ft,fp=distance(f,t),distance(f,p)
						if fp<ft then
							local pt=distance(p,t)
							if p~=f and pt<ft and(pt+fp-p.r*2)<ft then
								t=p
							end
						end
					end
					tunnel[{f,t}]=f.ships
					f=t
				end
				local biggest,tun=-1
				for t,v in pairs(tunnel)do
					if v>biggest then
						biggest,tun=v,t
					end
				end
				if planet.ships>biggest then return send(100,planet,target)end
				return send(35,tun[1],tun[2])
			elseif r>target.ships then
				return send(r/planet.ships*100,planet,target)
			end
			local f,t=planetf,planett
			for _,t in pairs(planets)do
				if ships[f]and ships[t]and ships[f]>ships[t]*1.5 then
					local actions={}
					for i=1,5 do -- tunnel limit
						if ships[f]and ships[f]*1.5*.95>ships[planetf]then
							local redir
							for _,v in pairs(search(function(x)
								return x.type=="fleet"and x.owner==USER and x.target==f.n
							end))do
								if distance(v,f)+distance(f,t)-f.r*2>distance(v,t)then
									redir=v
									break
								end
							end
							if redir then f=redir end
							for _,p in pairs(my_fleets())do
								local ft,fp=distance(f,t),distance(f,p)
								if fp<ft then
									local pt=distance(p,t)
									if p~=f and pt<ft and(pt+fp-p.r*2)<ft then
										t=p
									end
								end
							end
							if redir then
								actions[{'redirect',redir,t}]=redir.ships
							else
								actions[{'send',f,t}]=f.ships*.05
							end
						end
						if t==planett then break end
						f,t=t,planett
					end
					local biggest,tun=-1
					for t,v in pairs(actions)do
						if v>biggest then
							biggest,tun=v,t
						end
					end
					if tun then
						if tun[1]=='redirect'then
							redirect(tun[2],tun[3])
						else
							send(5,tun[2],tun[3])
						end
					end
				end
			end
		end
		if big then
			for _,f in pairs(my_fleets())do
				local targ,target=f.target
				search(function(f)if f.n==target then target=f end end)
				if target then
					local t=find(search(function(x)return x.type=="planet"and x.owner==plistm end),function(p)return-distance(f,p)end)
					for _,p in pairs(planets)do
						local ft,fp=distance(f,t),distance(f,p)
						if fp<ft then
							local pt=distance(p,t)
							if p~=f and pt<ft and(pt+fp-p.r*2)<ft then
								t=p
							end
						end
					end
					if target~=t then
						return redirect(f,t)
					end
				end
			end
		end
	end
end

-- search G for all matches
function protowaffle_search(f) local r = {} for _,o in pairs(G) do if f(o) then r[#r+1] = o end end return r end

-- return lists of matching planets
function protowaffle_all_planets() return protowaffle_search(function (o) return o.type == 'planet' end) end
function protowaffle_my_planets() return protowaffle_search(function (o) return o.type == 'planet' and o.owner == USER end) end
function protowaffle_neutral_planets() return protowaffle_search(function (o) return o.type == 'planet' and o.neutral == true end) end
function protowaffle_enemy_planets() return protowaffle_search(function (o) return o.type == 'planet' and o.owner ~= USER and not o.neutral end) end
function protowaffle_other_planets() return protowaffle_search(function (o) return o.type == 'planet' and o.owner ~= USER end) end

-- return list of matching fleets
function protowaffle_all_fleets() return protowaffle_search(function(o) return o.type == 'fleet' end) end
function protowaffle_my_fleets() return protowaffle_search(function (o) return o.type == 'fleet' and o.owner == USER end) end
function protowaffle_enemy_fleets() return protowaffle_search(function(o) return o.type == 'fleet' and o.owner ~= USER end) end

-- issue a single redirect order
function protowaffle_redirect(from,to)
    return { {action='redirect',from=from.n,to=to.n} }
end
-- issue a single send order
function protowaffle_send(percent,from,to)
    return { {action='send',percent=percent,from=from.n,to=to.n} }
end

-- search list for the best match
function protowaffle_find(Q,eval)
    local r, v
    for _,o in pairs(Q) do
        _v = eval(o)
        if _v ~= nil and (r == nil or _v > v) then
            r = o ; v = _v
        end
    end
    return r
end

-- calculate simple distance between two items
function protowaffle_distance(a,b) 
    local dx = b.x-a.x ; local dy = b.y-a.y ;
    return sqrt(dx*dx+dy*dy)
end
