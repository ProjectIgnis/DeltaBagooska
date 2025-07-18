--No.54 反骨の闘士ライオンハート (Amime)
--Number 54: Lion Heart (Anime)
Duel.LoadCardScript("c54366836.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,1,3)
	--Cannot be destroyed by battle, except with a "Number" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle while in Attack Position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(function(e) return e:GetHandler():IsAttackPos() end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Your opponent also takes battle damage from battles involving this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_BOTH_BATTLE_DAMAGE)
	e3:SetCondition(function(e) return Duel.GetBattleDamage(e:GetHandlerPlayer())>0 end)
	c:RegisterEffect(e3)
	--If your LP would become 0 from battle damage, make your LP 100
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54366836,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetCondition(function(e,tp) return Duel.GetBattleDamage(tp)>=Duel.GetLP(tp) end)
	e4:SetCost(Cost.DetachFromSelf(1))
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_NUMBER}
s.xyz_number=54
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(function(_,tp) Duel.ChangeBattleDamage(tp,0) end)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	Duel.SetLP(tp,100,REASON_EFFECT)
end
