--輝望道 (Manga)
--Shining Hope Road (Manga)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER,SET_NUMBER_S}
function s.matfilter(c,e)
	return c:IsSetCard(SET_NUMBER) and c:IsCanBeEffectTarget(e)
end
function s.rescon(xyzg)
	return function(sg,e,tp,g)
		if xyzg:IsExists(Card.IsXyzSummonable,1,nil,nil,sg,#sg,#sg) then return true end
		--If no xyz can be summoned using at least the currently seelcted cards as forced materials, stop
		return false,not xyzg:IsExists(Card.IsXyzSummonable,1,nil,sg,g,#sg,#g)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,e)
	local notSg=mg:Filter(aux.NOT(Card.IsSetCard),nil,SET_NUMBER_S)
	for _c in notSg:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetValue(SET_NUMBER_S)
		_c:RegisterEffect(e1,true)
		_c:AssumeProperty(ASSUME_RANK,_c:GetRank()+1)
	end
	local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if chk==0 then
		notSg:ForEach(function(_c) _c:ResetEffect(id,RESET_CARD) end)
		return #xyzg>0
	end
	local tg=aux.SelectUnselectGroup(mg,e,tp,1,#mg,s.rescon(xyzg),1,tp,HINTMSG_TARGET,s.rescon(xyzg))
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tg,#tg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	notSg:ForEach(function(_c) _c:ResetEffect(id,RESET_CARD) end)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetTargetCards(e)
	local c=e:GetHandler()
	local notSg=mg:Filter(aux.NOT(Card.IsSetCard),nil,SET_NUMBER_S)
	for _c in notSg:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetValue(SET_NUMBER_S)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		_c:RegisterEffect(e1,true)
		_c:AssumeProperty(ASSUME_RANK,_c:GetRank()+1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=Duel.SelectMatchingCard(tp,Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,1,nil,nil,mg,#mg,#mg):GetFirst()
	if xyz then
		Duel.XyzSummon(tp,xyz,mg,mg,#mg,#mg)
		notSg:KeepAlive()
		notSg:ForEach(function(_c) _c:Level((_c:Level()+1)) end)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_MOVE)
		e1:SetOperation(function(e)
			for _c in notSg:Iter() do
				_c:Level((_c:Level()-1))
			end
			e:Reset()
		end)
		xyz:RegisterEffect(e1,true)
	else
		notSg:ForEach(function(_c) _c:ResetEffect(id,RESET_CARD) end)
	end
end
