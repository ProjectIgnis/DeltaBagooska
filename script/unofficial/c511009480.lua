--ギャラクシーアイズ ＦＡ・フォトン・ドラゴン (Manga)
--Galaxy-Eyes Full Armor Photon Dragon (Manga)
Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 8 monsters
	Xyz.AddProcedure(c,nil,8,3)
	--You can also Xyz Summon this card by Tributing a "Galaxy-Eyes Photon Dragon" you control that is equipped with 2 Equip Spells and using those Equip Spells as the Xyz Materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	--Destroy 1 monster your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Attach any number of equip cards equipped to this card as materials
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.mtcon)
	e3:SetTarget(s.mttg)
	e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
	--Banish both that opponent's monster and this card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.rmcon)
	e4:SetCost(Cost.DetachFromSelf(function(e,tp) return e:GetHandler():GetOverlayCount() end))
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_DETACH_MATERIAL)
		ge:SetOperation(s.checkop)
		Duel.RegisterEffect(ge,0)
	end)
end
s.listed_names={CARD_GALAXYEYES_P_DRAGON}
function s.ovfilter(c,tp,xyz)
	return c:IsFaceup() and c:IsCode(CARD_GALAXYEYES_P_DRAGON) and c:GetEquipCount()==2
		and Duel.GetLocationCountFromEx(tp,tp,c,xyz)>0
end
function s.xyzcon(e,c)
	if c==nil then return true end
	if og then return false end
	local tp=c:GetControler()
	local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local mustg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,mg,REASON_XYZ)
	if #mustg>0 or (min and min>1) then return false end
	return Duel.CheckReleaseGroup(c:GetControler(),s.ovfilter,1,false,1,true,c,c:GetControler(),nil,false,nil,tp,c)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.ovfilter,1,1,false,true,true,c,nil,nil,false,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	local eqg=g:GetFirst():GetEquipGroup()
	e:GetHandler():SetMaterial(eqg)
	Duel.Overlay(e:GetHandler(),eqg)
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
 end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0 and e:GetHandler():GetFlagEffect(id)~=0
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipCount()>0 end
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	if not c:IsRelateToEffect(e) or c:IsFacedown() or #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local tg=g:Select(tp,1,#g,nil)
	if #tg>0 then
		Duel.Overlay(c,tg)
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) and c:IsAbleToRemove() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	local mcount=0
	if tc:IsFaceup() then mcount=tc:GetOverlayCount() end
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local og=Duel.GetOperatedGroup()
		if not og:IsContains(tc) then mcount=0 end
		for tc in aux.Next(og) do
			tc:RegisterFlagEffect(CARD_GALAXYEYES_P_DRAGON,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
		end
		og:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetLabel(mcount)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retfilter(c)
	return c:GetFlagEffect(CARD_GALAXYEYES_P_DRAGON)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil)
	g:DeleteGroup()
	for tc in aux.Next(sg) do
		 Duel.ReturnToField(tc)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg and #eg>0 then
		for tc in aux.Next(eg) do
			if tc:IsFaceup() and (r&REASON_COST)==REASON_COST then
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
			end
		end
	end
end
