--クリアー・ワールド (VG) 
--Clear World (VG)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--LIGHT: Play with your hand revealed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetTarget(function(e,c) return s.PlayerIsAffectedByClearWorld(c:GetControler(),ATTRIBUTE_LIGHT) end)
	c:RegisterEffect(e1)
	--DARK: Monsters you control cannot declare an attack
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetTargetRange(1,0)
	e2a:SetCondition(function(e) return s.PlayerIsAffectedByClearWorld(e:GetHandlerPlayer(),ATTRIBUTE_DARK) end)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCondition(function(e) return s.PlayerIsAffectedByClearWorld(1-e:GetHandlerPlayer(),ATTRIBUTE_DARK) end)
	e2b:SetTargetRange(0,1)
	c:RegisterEffect(e2b)
	--EARTH: Once per turn, during your turn: Destroy 1 monster you control
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(74131780,0))
	e3a:SetCategory(CATEGORY_DESTROY)
	e3a:SetType(EFFECT_TYPE_IGNITION)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3a:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e3a:SetCountLimit(1)
	e3a:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and s.PlayerControlsAttributeOrIsAffectedByClearWall(tp,ATTRIBUTE_EARTH) and Duel.GetFlagEffect(tp,id)==0 end)
	e3a:SetTarget(s.destg)
	e3a:SetOperation(s.desop)
	c:RegisterEffect(e3a)
	--EARTH: Force destruction during End Phase if monster was not destroyed by this effect
	local e3b=e3a:Clone()
	e3b:SetDescription(aux.Stringid(id,1))
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3b:SetCode(EVENT_PHASE+PHASE_END)
	c:RegisterEffect(e3b)
	--WATER: Once per turn, during your End Phase: Discard 1 card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and s.PlayerControlsAttributeOrIsAffectedByClearWall(tp,ATTRIBUTE_WATER) end)
	e4:SetTarget(s.discardtg)
	e4:SetOperation(s.discardop)
	c:RegisterEffect(e4)
	--FIRE: Once per turn, during your End Phase: Take 1000 damage
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and s.PlayerControlsAttributeOrIsAffectedByClearWall(tp,ATTRIBUTE_FIRE) end)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
	--WIND: You cannot activate Spell Cards
	local e6a=Effect.CreateEffect(c)
	e6a:SetType(EFFECT_TYPE_FIELD)
	e6a:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6a:SetRange(LOCATION_FZONE)
	e6a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6a:SetTargetRange(1,0)
	e6a:SetCondition(function(e) return s.PlayerIsAffectedByClearWorld(e:GetHandlerPlayer(),ATTRIBUTE_WIND) end)
	e6a:SetValue(function(e,te,tp) return te:GetHandler():IsSpell() and te:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	c:RegisterEffect(e6a)
	local e6b=e6a:Clone()
	e6b:SetTargetRange(0,1)
	e6b:SetCondition(function(e) return s.PlayerIsAffectedByClearWorld(1-e:GetHandlerPlayer(),ATTRIBUTE_WIND) end)
	c:RegisterEffect(e6b)
end
function s.PlayerControlsAttributeOrIsAffectedByClearWall(player,attribute)
	return Duel.IsPlayerAffectedByEffect(1-player,EFFECT_CLEAR_WALL)
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,attribute),player,LOCATION_MZONE,0,1,nil)
end
function s.PlayerIsAffectedByClearWorld(player,attribute)
	return not Duel.IsPlayerAffectedByEffect(player,EFFECT_CLEAR_WORLD_IMMUNE)
		and s.PlayerControlsAttributeOrIsAffectedByClearWall(player,attribute)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not s.PlayerIsAffectedByClearWorld(tp,ATTRIBUTE_EARTH) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.discardtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.discardop(e,tp,eg,ep,ev,re,r,rp)
	if not s.PlayerIsAffectedByClearWorld(tp,ATTRIBUTE_WATER) then return end
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not s.PlayerIsAffectedByClearWorld(tp,ATTRIBUTE_FIRE) then return end
	Duel.Damage(tp,1000,REASON_EFFECT)
end

