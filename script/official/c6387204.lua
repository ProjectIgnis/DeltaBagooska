--CNo.6 先史遺産カオス・アトランタル
--Number C6: Chronomaly Chaos Atlandis
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,7,3)
	c:EnableReviveLimit()
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,_,tp) return ec:IsControler(1-tp) end,s.equipop,e1)
	--lp
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.lpcon)
	e2:SetCost(s.lpcost)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2,false,EFFECT_MARKER_DETACH_XMAT)
end
s.listed_series={SET_NUMBER}
s.xyz_number=6
s.listed_names={9161357}
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	e2:SetValue(1000)
	tc:RegisterEffect(e2)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetValue(0)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e4,tp)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(1-tp)~=100 and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,9161357)
end
function s.filter(c)
	return c:GetFlagEffect(id)~=0 and c:IsSetCard(SET_NUMBER) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST)
		and e:GetHandler():GetEquipGroup():IsExists(s.filter,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
	local g=e:GetHandler():GetEquipGroup():Filter(s.filter,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(1-tp,100)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end