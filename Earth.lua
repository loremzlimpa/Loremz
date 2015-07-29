require("libs.HotkeyConfig2")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Animations")
require("libs.Skillshot")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Puck")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("hotkey","Key",SGC_TYPE_ONKEYDOWN,false,false,32)
ScriptConfig:AddParam("blink","Auto Blink To Enemy",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("ult","Auto Dream Coil",SGC_TYPE_TOGGLE,false,true,nil)

play, myhero, victim, start, resettime, castQueue, castsleep, move = false, nil, nil, false, false, {}, 0, 0

function Main(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myhero then return end

	for i=1,#castQueue,1 do
		local v = castQueue[1]
		table.remove(castQueue,1)
		local ability = v[2]
		if type(ability) == "string" then
			ability = me:FindItem(ability)
		end
		if ability and ((me:SafeCastAbility(ability,v[3],false)) or (v[4] and ability:CanBeCasted())) then
			if v[4] and ability:CanBeCasted() then
				me:CastAbility(ability,v[3],false)
			end
			castsleep = tick + v[1] + client.latency
			return
		end
	end
        if not Animations.CanMove(me) and victim and GetDistance2D(me,victim) <= 2000 then
		            if tick > castsleep then
		                    if not Animations.isAttacking(me) and victim.alive and victim.visible then
		                            local blink = me:FindItem("item_blink")
								    local R = me:Getability(4)
								    local soulring = me:FindItem("item_soul_ring")
								    local shiva = me:FindItem("item_shivas_guard")
								    local arcane = me:FindItem("item_arcane_boots")
		                            local Q = me:Getability(1)
								    local w = me:Getability(2)
								    if victim.alive and not victim:DoesHaveModifier("modifier_item_blade_mail_reflect") and not victim:DoesHaveModifier("modifier_item_lotus_orb_active") and not victim:IsMagicImmune() and victim:CanDie() then
							                if ScriptConfig.blink and blink and blink:CanBeCasted() and me:CanCast() and distance <= 1199 and distance >= me.attackRange then
								                    local xyz = SkillShot.SkillShotXYZ(me,victim,blink:FindCastPoint()*1000+client.latency+me:GetTurnTime(victim)*1000,blink:GetSpecialData("blink_range"))
								                    if xyz then
									                        table.insert(castQueue,{math.ceil(blink:FindCastPoint()*1000),blink,xyz})
								                    end
							                end
		                                    if Q and Q:CanBeCasted() and me:CanCast() then
							                        table.insert(castQueue,{100,W})
						                    end
		                                    if W and W:CanBeCasted() and me:CanCast() then 
							                        table.insert(castQueue,{math.ceil(Q:FindCastPoint()*1000),Q,victim,true})
						                    end
								            if me.mana < me.maxMana*0.5 and soulring and soulring:CanBeCasted() then
							                        table.insert(castQueue,{100,soulring})
								            end		
								            if shiva and shiva:CanBeCasted() and distance <= 600 then
							                        table.insert(castQueue,{100,shiva})
						                   end
		                                    if arcane and arcane:CanBeCasted() then 
								                     table.insert(castQueue,{100,arcane})
		                                    end
		                            end
                            end		
		                    me:Attack(victim)
					        castsleep = tick + 160
				    end
			elseif tick > move then
				    if victim then
					        if victim.visible then
						            local xyz = SkillShot.PredictedXYZ(victim,me:GetTurnTime(victim)*1000+client.latency+500)
						            me:Move(xyz)
					        else
						            me:Follow(victim)
					        end
				    else
					        me:Move(client.mousePosition)
				    end
				    move = tick + 160
				    start = false
			end
		elseif victim then
			    if not resettime then
				        resettime = client.gameTime
			    elseif (client.gameTime - resettime) >= 6 then
				        victim = nil		
			    end
			    start = false
		end 
	end
end

function Load()
	    if PlayingGame() then
		        local me = entityList:GetMyHero()
		        if me.classId ~= CDOTA_Unit_Hero_Earthshaker then 
			            script:Disable() 
		        else
			            ScriptConfig:SetVisible(true)
			            play, victim, start, resettime, myhero = true, nil, false, nil, me.classId
			            script:RegisterEvent(EVENT_FRAME, Main)
			            script:UnregisterEvent(Load)
		        end
	    end	
end

function Close()
	    myhero, victim, start, resettime = nil, nil, false, nil
	    ScriptConfig:SetVisible(false)
	    collectgarbage("collect")
	    if play then
		         script:UnregisterEvent(Main)
		         script:RegisterEvent(EVENT_TICK,Load)
		         play = false
	    end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
