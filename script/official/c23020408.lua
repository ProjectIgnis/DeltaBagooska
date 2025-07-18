--魂のしもべ
--Soul Servant
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 card on top of the Deck from your hand, Deck, or GY, that is "Dark Magician" or mentions "Dark Magician" or "Dark Magician Girl"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Draw cards equal to the number of "Palladium" monsters, "Dark Magician", and/or "Dark Magician Girl" with different names
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL,id}
s.listed_series={SET_PALLADIUM}
function s.filter(c,deckCount)
	return not c:IsCode(id) and (c:IsCode(CARD_DARK_MAGICIAN) or c:ListsCode(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL))
		and (c:IsLocation(LOCATION_DECK) and deckCount>1 or not c:IsLocation(LOCATION_DECK) and c:IsAbleToDeck())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,ct):GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
			Duel.MoveToDeckTop(tc)
		else
			Duel.HintSelection(tc,true)
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		if not tc:IsLocation(LOCATION_EXTRA) then
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
function s.drfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and ((c:IsSetCard(SET_PALLADIUM) and c:IsMonster()) or c:IsCode(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL))
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil):GetClassCount(Card.GetCode)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil):GetClassCount(Card.GetCode)
	Duel.Draw(p,ct,REASON_EFFECT)
end