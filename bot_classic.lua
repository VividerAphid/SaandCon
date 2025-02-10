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