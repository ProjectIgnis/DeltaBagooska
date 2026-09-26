--ＲＵＭ－幻影騎士団ラウンチ (Anime)
--The Phantom Knights' Rank-Up-Magic Launch (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 face-up Xyz Monster you control; Special Summon from your Extra Deck, 1 monster that is 1 Rank higher than that target, by using that target as the Xyz Material.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.xyzsptg)
	e1:SetOperation(s.xyzspop)
	c:RegisterEffect(e1)
	--During your Standby Phase, if you control the Xyz Monster Special Summoned by this effect: You can target that Xyz Monster; attach this card from your Graveyard to that monster as Xyz Material.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(511000818,0))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.attachfromgycon)
	e2:SetTarget(s.attachfromgytg)
	e2:SetOperation(s.attachfromgyop)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
s.listed_series={SET_THE_PHANTOM_KNIGHTS}
s.listed_names={16195942} --"Dark Rebellion Xyz Dragon"
function s.xyzmatfilter(c,e,tp)
	local rk=c:GetRank()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return #pg<=1 and c:IsFaceup() and (rk>0 or c:IsStatus(STATUS_NO_LEVEL))
		and Duel.IsExistingMatchingCard(s.xyzspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,pg)
end
function s.xyzspfilter(c,e,tp,mc,rk,pg)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsRank(rk) and mc:IsCanBeXyzMaterial(c,tp) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and (#pg<=0 or pg:IsContains(mc)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyzsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzmatfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzmatfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzmatfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,pg)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		--If this effect was activated by targeting a "The Phantom Knights" Xyz Monster or "Dark Rebellion Xyz Dragon" you control: You can attach it to the Summoned monster as an Xyz Material.
		if (tc:IsSetCard(SET_THE_PHANTOM_KNIGHTS) or tc:IsCode(16195942)) and Duel.SelectYesNo(tp,aux.Stringid(95100814,0)) then
			Duel.BreakEffect()
			c:CancelToGrave()
			Duel.Overlay(sc,c)
		end
		sc:CompleteProcedure()
		e:GetLabelObject():SetLabelObject(sc)
	end
end
function s.attachfromgycon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return Duel.IsTurnPlayer(tp) and tc and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp)
end
function s.attachfromgytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if chkc then return chkc==tc and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT) end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.attachfromgyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end
