ConRO.DeathKnight = {};
ConRO.DeathKnight.CheckTalents = function()
end
ConRO.DeathKnight.CheckPvPTalents = function()
end
local ConRO_DeathKnight, ids = ...;

function ConRO:EnableRotationModule(mode)
	mode = mode or 0;
	self.ModuleOnEnable = ConRO.DeathKnight.CheckTalents;
	self.ModuleOnEnable = ConRO.DeathKnight.CheckPvPTalents;
	if mode == 0 then
		self.Description = "Death Knight [No Specialization Under 10]";
		self.NextSpell = ConRO.DeathKnight.Disabled;
		self.ToggleHealer();
		ConROWindow:SetAlpha(0);
		ConRODefenseWindow:SetAlpha(0);
	end;
	if mode == 1 then
		self.Description = 'Death Knight [Blood - Tank]';
		if ConRO.db.profile._Spec_1_Enabled then
			self.NextSpell = ConRO.DeathKnight.Blood;
			self.ToggleDamage();
			self.BlockAoE();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.DeathKnight.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	if mode == 2 then
		self.Description = 'Death Knight [Frost - Melee]';
		if ConRO.db.profile._Spec_2_Enabled then
			self.NextSpell = ConRO.DeathKnight.Frost;
			self.ToggleDamage();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.DeathKnight.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	if mode == 3 then
		self.Description = 'Death Knight [Unholy - Melee]';
		if ConRO.db.profile._Spec_3_Enabled then
			self.NextSpell = ConRO.DeathKnight.Unholy;
			self.ToggleDamage();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.DeathKnight.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED');
	self.lastSpellId = 0;
end

function ConRO:EnableDefenseModule(mode)
	mode = mode or 0;
	if mode == 0 then
		self.NextDef = ConRO.DeathKnight.Disabled;
	end;
	if mode == 1 then
		if ConRO.db.profile._Spec_1_Enabled then
			self.NextDef = ConRO.DeathKnight.BloodDef;
		else
			self.NextDef = ConRO.DeathKnight.Disabled;
		end
	end;
	if mode == 2 then
		if ConRO.db.profile._Spec_2_Enabled then
			self.NextDef = ConRO.DeathKnight.FrostDef;
		else
			self.NextDef = ConRO.DeathKnight.Disabled;
		end
	end;
	if mode == 3 then
		if ConRO.db.profile._Spec_3_Enabled then
			self.NextDef = ConRO.DeathKnight.UnholyDef;
		else
			self.NextDef = ConRO.DeathKnight.Disabled;
		end
	end;
end

function ConRO:UNIT_SPELLCAST_SUCCEEDED(event, unitID, lineID, spellID)
	if unitID == 'player' then
		self.lastSpellId = spellID;
	end
end

function ConRO.DeathKnight.Disabled(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	return nil;
end

--Info
local _Player_Level = UnitLevel("player");
local _Player_Percent_Health = ConRO:PercentHealth('player');
local _is_PvP = ConRO:IsPvP();
local _in_combat = UnitAffectingCombat('player');
local _party_size = GetNumGroupMembers();
local _is_PC = UnitPlayerControlled("target");
local _is_Enemy = ConRO:TarHostile();
local _Target_Health = UnitHealth('target');
local _Target_Percent_Health = ConRO:PercentHealth('target');

--Resources
local _Runes = _;
local _RunicPower, _RunicPower_Max = ConRO:PlayerPower('RunicPower');

--Conditions
local _is_moving = ConRO:PlayerSpeed();
local _enemies_in_melee, _target_in_melee = ConRO:Targets("Melee");
local _enemies_in_10yrds, _target_in_10yrds = ConRO:Targets("10");
local _enemies_in_25yrds, _target_in_25yrds = ConRO:Targets("25");
local _enemies_in_40yrds, _target_in_40yrds = ConRO:Targets("40");
local _can_Execute = _Target_Percent_Health < 35;

local _Pet_summoned = ConRO:CallPet();

--Racials
local _AncestralCall, _AncestralCall_RDY = _, _;
local _ArcanePulse, _ArcanePulse_RDY = _, _;
local _Berserking, _Berserking_RDY = _, _;
local _ArcaneTorrent, _ArcaneTorrent_RDY = _, _;

function ConRO:Stats()
	_Player_Level = UnitLevel("player");
	_Player_Percent_Health = ConRO:PercentHealth('player');
	_is_PvP = ConRO:IsPvP();
	_in_combat = UnitAffectingCombat('player');
	_party_size = GetNumGroupMembers();
	_is_PC = UnitPlayerControlled("target");
	_is_Enemy = ConRO:TarHostile();
	_Target_Health = UnitHealth('target');
	_Target_Percent_Health = ConRO:PercentHealth('target');

	_Runes = ConRO:DKrunes();
	_RunicPower, _RunicPower_Max = ConRO:PlayerPower('RunicPower');

	_is_moving = ConRO:PlayerSpeed();
	_enemies_in_melee, _target_in_melee = ConRO:Targets("Melee");
	_enemies_in_10yrds, _target_in_10yrds = ConRO:Targets("10");
	_enemies_in_25yrds, _target_in_25yrds = ConRO:Targets("25");
	_enemies_in_40yrds, _target_in_40yrds = ConRO:Targets("40");
	_can_Execute = _Target_Percent_Health < 35;

	_Pet_summoned = ConRO:CallPet();

	_AncestralCall, _AncestralCall_RDY = ConRO:AbilityReady(ids.Racial.AncestralCall, timeShift);
	_ArcanePulse, _ArcanePulse_RDY = ConRO:AbilityReady(ids.Racial.ArcanePulse, timeShift);
	_Berserking, _Berserking_RDY = ConRO:AbilityReady(ids.Racial.Berserking, timeShift);
	_ArcaneTorrent, _ArcaneTorrent_RDY = ConRO:AbilityReady(ids.Racial.ArcaneTorrent, timeShift);
end

function ConRO.DeathKnight.Blood(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Blood_Ability, ids.Blood_Form, ids.Blood_Buff, ids.Blood_Debuff, ids.Blood_PetAbility, ids.Blood_PvPTalent;

--Abilities
	local _AbominationLimb, _AbominationLimb_RDY = ConRO:AbilityReady(Ability.AbominationLimb, timeShift);
	local _Asphyxiate, _Asphyxiate_RDY = ConRO:AbilityReady(Ability.Asphyxiate, timeShift);
	local _BloodBoil, _BloodBoil_RDY = ConRO:AbilityReady(Ability.BloodBoil, timeShift);
		local _BloodBoil_CHARGES, _BloodBoil_MCHARGES = ConRO:SpellCharges(_BloodBoil);
		local _BloodPlague_DEBUFF = ConRO:TargetAura(Debuff.BloodPlague, timeShift);
		local _CrimsonScourge_BUFF = ConRO:Aura(Buff.CrimsonScourge, timeShift);
		local _Hemostasis_BUFF, _Hemostasis_COUNT = ConRO:Aura(Buff.Hemostasis, timeShift);
	local _DancingRuneWeapon, _DancingRuneWeapon_RDY = ConRO:AbilityReady(Ability.DancingRuneWeapon, timeShift);
		local _DancingRuneWeapon_BUFF, _, _DancingRuneWeapon_DUR = ConRO:Aura(Buff.DancingRuneWeapon, timeShift);
	local _DarkCommand, _DarkCommand_RDY = ConRO:AbilityReady(Ability.DarkCommand, timeShift);
	local _DeathandDecay, _DeathandDecay_RDY = ConRO:AbilityReady(Ability.DeathandDecay, timeShift);
		local _DeathandDecay_BUFF, _, _DeathandDecay_DUR = ConRO:Aura(Buff.DeathandDecay, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _BloodShield_BUFF = ConRO:Aura(Buff.BloodShield, timeShift + 2);
		local _IcyTalons_BUFF, _, _IcyTalons_DUR = ConRO:Aura(Buff.IcyTalons, timeShift);
	local _DeathsAdvance, _DeathsAdvance_RDY = ConRO:AbilityReady(Ability.DeathsAdvance, timeShift);
	local _DeathsCaress, _DeathsCaress_RDY = ConRO:AbilityReady(Ability.DeathsCaress, timeShift);
	local _HeartStrike, _HeartStrike_RDY = ConRO:AbilityReady(Ability.HeartStrike, timeShift);
	local _MindFreeze, _MindFreeze_RDY = ConRO:AbilityReady(Ability.MindFreeze, timeShift);
	local _Marrowrend, _Marrowrend_RDY = ConRO:AbilityReady(Ability.Marrowrend, timeShift);
		local _BoneShield_BUFF, _BoneShield_COUNT = ConRO:Aura(Buff.BoneShield, timeShift + 3);
	local _RaiseDead, _RaiseDead_RDY = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _SoulReaper, _SoulReaper_RDY = ConRO:AbilityReady(Ability.SoulReaper, timeShift);
	local _BloodTap, _BloodTap_RDY = ConRO:AbilityReady(Ability.BloodTap, timeShift);
		local _BloodTap_CHARGES, _BloodTap_MAX_CHARGES = ConRO:SpellCharges(_BloodTap);
	local _Blooddrinker, _Blooddrinker_RDY = ConRO:AbilityReady(Ability.Blooddrinker, timeShift);
	local _Bonestorm, _Bonestorm_RDY = ConRO:AbilityReady(Ability.Bonestorm, timeShift);
	local _Consumption, _Consumption_RDY = ConRO:AbilityReady(Ability.Consumption, timeShift);
	local _MarkofBlood, _MarkofBlood_RDY = ConRO:AbilityReady(Ability.MarkofBlood, timeShift);
	local _Tombstone, _Tombstone_RDY = ConRO:AbilityReady(Ability.Tombstone, timeShift);
	local _WraithWalk, _WraithWalk_RDY = ConRO:AbilityReady(Ability.WraithWalk, timeShift);

--Conditions

--Indicators
	ConRO:AbilityInterrupt(_MindFreeze, _MindFreeze_RDY and ConRO:Interrupt());
	ConRO:AbilityInterrupt(_Asphyxiate, _Asphyxiate_RDY and (ConRO:Interrupt() and not _MindFreeze_RDY and _is_PC and _is_Enemy));
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());
	ConRO:AbilityTaunt(_DarkCommand, _DarkCommand_RDY and (not ConRO:InRaid() or (ConRO:InRaid() and ConRO:TarYou())));
	ConRO:AbilityMovement(_DeathsAdvance, _DeathsAdvance_RDY and not _target_in_melee);
	ConRO:AbilityMovement(_WraithWalk, _WraithWalk_RDY and not _target_in_melee);

	ConRO:AbilityBurst(_AbominationLimb, _AbominationLimb_RDY and _in_combat and ConRO:BurstMode(_AbominationLimb, 120));
	ConRO:AbilityBurst(_Bonestorm, _Bonestorm_RDY and _RunicPower >= 10 and _enemies_in_melee >= 3 and ConRO:BurstMode(_Bonestorm, 60));
	ConRO:AbilityBurst(_RaiseDead, _RaiseDead_RDY and not _Pet_summoned  and ConRO:BurstMode(_RaiseDead, 120));

--Rotations
	for i = 1, 2, 1 do
		if currentSpell == _Blooddrinker then
			tinsert(ConRO.SuggestedSpells, _Blooddrinker);
		end

		if not _in_combat then
			if _AbominationLimb_RDY and ConRO:FullMode(_AbominationLimb, 120) then
				tinsert(ConRO.SuggestedSpells, _AbominationLimb);
				_AbominationLimb_RDY = false;
			end

			if _DeathsCaress_RDY and not _BloodPlague_DEBUFF and not _target_in_melee then
				tinsert(ConRO.SuggestedSpells, _DeathsCaress);
				_DeathsCaress_RDY = false;
			end
		end

		if _DancingRuneWeapon_BUFF then
			if _Marrowrend_RDY and _Runes >= 2 and _DancingRuneWeapon_DUR <= 4.5 then
				tinsert(ConRO.SuggestedSpells, _Marrowrend);
				_Runes = _Runes - 2;
				_BoneShield_COUNT = _BoneShield_COUNT + 6;
			end

			if _DeathandDecay_RDY and not _DeathandDecay_BUFF then
				tinsert(ConRO.SuggestedSpells, _DeathandDecay);
				_DeathandDecay_BUFF = true;
			end

			if _SoulReaper_RDY and _Runes >= 1 and _Target_Percent_Health <= 35 then
				tinsert(ConRO.SuggestedSpells, _SoulReaper);
				_SoulReaper_RDY = false;
				_Runes = _Runes - 1;
			end

			if _Marrowrend_RDY and _Runes >= 2 and _BoneShield_COUNT <= 0 then
				tinsert(ConRO.SuggestedSpells, _Marrowrend);
				_Runes = _Runes - 2;
				_BoneShield_COUNT = _BoneShield_COUNT + 6;
			end

			if _Tombstone_RDY and _BoneShield_COUNT >= 6 and _DeathandDecay_BUFF then
				tinsert(ConRO.SuggestedSpells, _Tombstone);
				_BoneShield_COUNT = _BoneShield_COUNT - 5;
			end

			if _DeathStrike_RDY and (_RunicPower >= 75 or (tChosen[Ability.IcyTalons.talentID] and (not _IcyTalons_BUFF or (_IcyTalons_BUFF and _IcyTalons_DUR <= 1.5)))) then
				tinsert(ConRO.SuggestedSpells, _DeathStrike);
				_RunicPower = _RunicPower - 40;
				if tChosen[Ability.IcyTalons.talentID] then
					_IcyTalons_BUFF = true;
					_IcyTalons_DUR = 6;
				end
			end

			if _BloodBoil_RDY and _BloodBoil_CHARGES == _BloodBoil_MCHARGES then
				tinsert(ConRO.SuggestedSpells, _BloodBoil);
				_BloodBoil_CHARGES = _BloodBoil_CHARGES - 1;
			end

			if _HeartStrike_RDY and _Runes > 3 then
				tinsert(ConRO.SuggestedSpells, _HeartStrike);
				_Runes = _Runes - 1;
			end
		else
			if _AbominationLimb_RDY and ConRO:FullMode(_AbominationLimb) then
				tinsert(ConRO.SuggestedSpells, _AbominationLimb);
				_AbominationLimb_RDY = false;
			end

			if _RaiseDead_RDY and ConRO:FullMode(_RaiseDead) then
				tinsert(ConRO.SuggestedSpells, _RaiseDead);
				_RaiseDead_RDY = false;
			end

			if _Bonestorm_RDY and _RunicPower >= 100 and _enemies_in_melee >= 3 and ConRO:FullMode(_Bonestorm) then
				tinsert(ConRO.SuggestedSpells, _Bonestorm);
				_Bonestorm_RDY = false;
			end

			if _Blooddrinker_RDY and not _DancingRuneWeapon_BUFF then
				tinsert(ConRO.SuggestedSpells, _Blooddrinker);
				_Blooddrinker_RDY = false;
			end

			if _BloodTap_RDY and (_Runes < 3 or _BloodTap_CHARGES == _BloodTap_MAX_CHARGES) then
				tinsert(ConRO.SuggestedSpells, _BloodTap);
				_BloodTap_RDY = false;
			end

			if _DeathsCaress_RDY and not _BoneShield_BUFF then
				tinsert(ConRO.SuggestedSpells, _DeathsCaress);
				_DeathsCaress_RDY = false;
			end

			if _DeathandDecay_RDY and not _DeathandDecay_BUFF then
				tinsert(ConRO.SuggestedSpells, _DeathandDecay);
				_DeathandDecay_RDY = false;
			end

			if _SoulReaper_RDY and _Runes >= 1 and _Target_Percent_Health <= 35 then
				tinsert(ConRO.SuggestedSpells, _SoulReaper);
				_SoulReaper_RDY = false;
				_Runes = _Runes - 1;
			end

			if _Marrowrend_RDY and _Runes >= 2 and _BoneShield_COUNT <= 4 then
				tinsert(ConRO.SuggestedSpells, _Marrowrend);
				_Runes = _Runes - 2;
				_BoneShield_COUNT = _BoneShield_COUNT + 3;
			end

			if _DancingRuneWeapon_RDY then
				tinsert(ConRO.SuggestedSpells, _DancingRuneWeapon);
				_DancingRuneWeapon_RDY = false;
			end

			if _Tombstone_RDY and _BoneShield_COUNT >= 6 and _DeathandDecay_BUFF then
				tinsert(ConRO.SuggestedSpells, _Tombstone);
				_BoneShield_COUNT = _BoneShield_COUNT - 5;
			end

			if _DeathStrike_RDY and (_RunicPower >= 75 or (tChosen[Ability.IcyTalons.talentID] and (not _IcyTalons_BUFF or (_IcyTalons_BUFF and _IcyTalons_DUR <= 1.5)))) then
				tinsert(ConRO.SuggestedSpells, _DeathStrike);
				_RunicPower = _RunicPower - 40;
				if tChosen[Ability.IcyTalons.talentID] then
					_IcyTalons_BUFF = true;
					_IcyTalons_DUR = 6;
				end
			end

			if _BloodBoil_RDY and _BloodBoil_CHARGES == _BloodBoil_MCHARGES then
				tinsert(ConRO.SuggestedSpells, _BloodBoil);
				_BloodBoil_CHARGES = _BloodBoil_CHARGES - 1;
			end

			if _HeartStrike_RDY and _Runes > 3 then
				tinsert(ConRO.SuggestedSpells, _HeartStrike);
				_Runes = _Runes - 1;
			end

			if _Consumption_RDY then
				tinsert(ConRO.SuggestedSpells, _Consumption);
				_Consumption_RDY = false;
			end

			if _BloodBoil_RDY and _BloodBoil_CHARGES >= 1 then
				tinsert(ConRO.SuggestedSpells, _BloodBoil);

			end
		end
	end
	return nil;
end

function ConRO.DeathKnight.BloodDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Blood_Ability, ids.Blood_Form, ids.Blood_Buff, ids.Blood_Debuff, ids.Blood_PetAbility, ids.Blood_PvPTalent;

--Abilities
	local _DancingRuneWeapon, _DancingRuneWeapon_RDY = ConRO:AbilityReady(Ability.DancingRuneWeapon, timeShift);
	local _DeathCoil, _DeathCoil_RDY = ConRO:AbilityReady(Ability.DeathCoil, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
	local _IceboundFortitude, _IceboundFortitude_RDY = ConRO:AbilityReady(Ability.IceboundFortitude, timeShift);
	local _Lichborne, _Lichborne_RDY = ConRO:AbilityReady(Ability.Lichborne, timeShift);
		local _Lichborne_BUFF = ConRO:Aura(Buff.Lichborne, timeShift);
	local _RaiseDead, _RaiseDead_RDY, _RaiseDead_CD = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _RuneTap, _RuneTap_RDY = ConRO:AbilityReady(Ability.RuneTap, timeShift);
		local _RuneTap_BUFF	= ConRO:Aura(Buff.RuneTap, timeShift);
	local _SacrificialPact, _SacrificialPact_RDY = ConRO:AbilityReady(Ability.SacrificialPact, timeShift);
	local _VampiricBlood, _VampiricBlood_RDY = ConRO:AbilityReady(Ability.VampiricBlood, timeShift);

	local _Blooddrinker, _Blooddrinker_RDY = ConRO:AbilityReady(Ability.Blooddrinker, timeShift);
	local _DeathPact, _DeathPact_RDY = ConRO:AbilityReady(Ability.DeathPact, timeShift);

--Conditions

--Rotations
		if _SacrificialPact_RDY and _Player_Percent_Health <= 20 and _RaiseDead_CD > 60 then
			tinsert(ConRO.SuggestedDefSpells, _SacrificialPact);
		end

		if _DeathPact_RDY and _Player_Percent_Health <= 50 then
			tinsert(ConRO.SuggestedDefSpells, _DeathPact);
		end

		if _DeathCoil_RDY and _Lichborne_BUFF and _Player_Percent_Health <= 80 then
			tinsert(ConRO.SuggestedDefSpells, _DeathCoil);
		end

		if _Blooddrinker_RDY and _Player_Percent_Health <= 75 then
			tinsert(ConRO.SuggestedDefSpells, _Blooddrinker);
		end

		if _VampiricBlood_RDY and _Player_Percent_Health <= 50 then
			tinsert(ConRO.SuggestedDefSpells, _VampiricBlood);
		end

		if _Lichborne_RDY and _Player_Percent_Health <= 40 then
			tinsert(ConRO.SuggestedDefSpells, _Lichborne);
		end

		if _RaiseDead_RDY and _Player_Percent_Health <= 30 then
			tinsert(ConRO.SuggestedDefSpells, _RaiseDead);
		end

		if _DeathStrike_RDY and _Player_Percent_Health <= 30 then
			tinsert(ConRO.SuggestedDefSpells, _DeathStrike);
		end

		if _DancingRuneWeapon_RDY then
			tinsert(ConRO.SuggestedDefSpells, _DancingRuneWeapon);
		end

		if _RuneTap_RDY and not _RuneTap_BUFF then
			tinsert(ConRO.SuggestedDefSpells, _RuneTap);
		end

		if _IceboundFortitude_RDY then
			tinsert(ConRO.SuggestedDefSpells, _IceboundFortitude);
		end
	return nil;
end

function ConRO.DeathKnight.Frost(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Frost_Ability, ids.Frost_Form, ids.Frost_Buff, ids.Frost_Debuff, ids.Frost_PetAbility, ids.Frost_PvPTalent;

--Abilities
	local _AbominationLimb, _AbominationLimb_RDY = ConRO:AbilityReady(Ability.AbominationLimb, timeShift);
	local _Asphyxiate, _Asphyxiate_RDY = ConRO:AbilityReady(Ability.Asphyxiate, timeShift);
	local _BreathofSindragosa, _BreathofSindragosa_RDY, _BreathofSindragosa_CD = ConRO:AbilityReady(Ability.BreathofSindragosa, timeShift);
		local _BreathofSindragosa_FORM = ConRO:Form(Form.BreathofSindragosa);
	local _ChainsofIce, _ChainsofIce_RDY = ConRO:AbilityReady(Ability.ChainsofIce, timeShift);
		local _ColdHeart_BUFF, _ColdHeart_COUNT = ConRO:Form(Buff.ColdHeart);
	local _ChillStreak, _ChillStreak_RDY = ConRO:AbilityReady(Ability.ChillStreak, timeShift);
	local _DeathandDecay, _DeathandDecay_RDY = ConRO:AbilityReady(Ability.DeathandDecay, timeShift);
		local _CleavingStrikes_BUFF = ConRO:Aura(Buff.CleavingStrikes, timeShift);
		local _DeathandDecay_BUFF = ConRO:Aura(Buff.DeathandDecay, timeShift);
		local _DeathandDecay_CHARGES, _DeathandDecay_MAX_CHARGES = ConRO:SpellCharges(_DeathandDecay);
	local _DeathGrip, _DeathGrip_RDY = ConRO:AbilityReady(Ability.DeathGrip, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _DarkSuccor_BUFF = ConRO:Aura(Buff.DarkSuccor, timeShift);
	local _DeathsAdvance, _DeathsAdvance_RDY = ConRO:AbilityReady(Ability.DeathsAdvance, timeShift);
	local _EmpowerRuneWeapon, _EmpowerRuneWeapon_RDY = ConRO:AbilityReady(Ability.EmpowerRuneWeapon, timeShift);
		local _EmpowerRuneWeapon_BUFF = ConRO:Aura(Buff.EmpowerRuneWeapon, timeShift);
		local _UnholyStrength_BUFF, _, _UnholyStrength_DUR = ConRO:Aura(Buff.UnholyStrength, timeShift);
		local _RazorIce_DEBUFF, _RazorIce_COUNT	= ConRO:TargetAura(Debuff.RazorIce, timeShift);
	local _Frostscythe, _Frostscythe_RDY = ConRO:AbilityReady(Ability.Frostscythe, timeShift);
	local _FrostStrike, _FrostStrike_RDY = ConRO:AbilityReady(Ability.FrostStrike, timeShift);
		local _FrostStrike_COST = 30;
		local _IcyTalons_BUFF, _, _IcyTalons_DUR = ConRO:Aura(Buff.IcyTalons, timeShift);
		local _UnleashedFrenzy_BUFF, _, _UnleashedFrenzy_DUR = ConRO:Aura(Buff.UnleashedFrenzy, timeShift);
	local _FrostwyrmsFury, _FrostwyrmsFury_RDY = ConRO:AbilityReady(Ability.FrostwyrmsFury, timeShift);
	local _GlacialAdvance, _GlacialAdvance_RDY = ConRO:AbilityReady(Ability.GlacialAdvance, timeShift);
	local _HornofWinter, _HornofWinter_RDY = ConRO:AbilityReady(Ability.HornofWinter, timeShift);
	local _HowlingBlast, _HowlingBlast_RDY = ConRO:AbilityReady(Ability.HowlingBlast, timeShift);
		local _FrostFever_DEBUFF = ConRO:TargetAura(Debuff.FrostFever, timeShift);
		local _Rime_BUFF = ConRO:Aura(Buff.Rime, timeShift);
	local _MindFreeze, _MindFreeze_RDY = ConRO:AbilityReady(Ability.MindFreeze, timeShift);
	local _Obliterate, _Obliterate_RDY = ConRO:AbilityReady(Ability.Obliterate, timeShift);
		local _Obliterate_COST = 2;
		local _KillingMachine_BUFF, _KillingMachine_COUNT = ConRO:Aura(Buff.KillingMachine, timeShift);
	local _PillarofFrost, _PillarofFrost_RDY, _PillarofFrost_CD = ConRO:AbilityReady(Ability.PillarofFrost, timeShift);
		local _PillarofFrost_BUFF, _, _PillarofFrost_DUR = ConRO:Aura(Buff.PillarofFrost, timeShift);
		local _PillarofFrost_THRESHOLD = 45;
	local _RaiseDead, _RaiseDead_RDY = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _ReapersMark, _ReapersMark_RDY = ConRO:AbilityReady(Ability.ReapersMark, timeShift);
		local _ReapersMark_COST = 2;
	local _RemorselessWinter, _RemorselessWinter_RDY, _RemorselessWinter_CD = ConRO:AbilityReady(Ability.RemorselessWinter, timeShift);
		local _RemorselessWinter_COST = 1;
	local _WraithWalk, _WraithWalk_RDY = ConRO:AbilityReady(Ability.WraithWalk, timeShift);

		local _AFeastofSouls_BUFF = ConRO:Aura(Buff.AFeastofSouls, timeShift);

--Conditions
	if tChosen[Ability.SwiftEnd.talentID] then
		_ReapersMark_COST = _ReapersMark_COST - 1;
	end

	if tChosen[Ability.Icecap.talentID] then
		_PillarofFrost_THRESHOLD = 30;
	end

--Indicators
	ConRO:AbilityInterrupt(_Asphyxiate, _Asphyxiate_RDY and (ConRO:Interrupt() and not _MindFreeze_RDY and _is_PC and _is_Enemy));
	ConRO:AbilityInterrupt(_MindFreeze, _MindFreeze_RDY and ConRO:Interrupt());

	ConRO:AbilityMovement(_DeathGrip, _DeathGrip_RDY and _is_Enemy and ConRO:IsSpellInRange(Ability.DeathGrip) and not _target_in_melee);
	ConRO:AbilityMovement(_DeathsAdvance, _DeathsAdvance_RDY and not _target_in_melee);
	ConRO:AbilityMovement(_WraithWalk, _WraithWalk_RDY and not _target_in_melee);

	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());

	ConRO:AbilityBurst(_AbominationLimb, _AbominationLimb_RDY and _FrostFever_DEBUFF and ConRO:BurstMode(_AbominationLimb));
	ConRO:AbilityBurst(_BreathofSindragosa, _BreathofSindragosa_RDY and _RunicPower >= 60 and _PillarofFrost_RDY and ConRO:BurstMode(_BreathofSindragosa));
	ConRO:AbilityBurst(_EmpowerRuneWeapon, _EmpowerRuneWeapon_RDY and _PillarofFrost_RDY and _Runes < 6 and not tChosen[Ability.BreathofSindragosa.talentID] and ConRO:BurstMode(_EmpowerRuneWeapon));
	ConRO:AbilityBurst(_FrostwyrmsFury, _FrostwyrmsFury_RDY and (_PillarofFrost_BUFF and _UnholyStrength_BUFF) or _PillarofFrost_DUR <= 5);
	ConRO:AbilityBurst(_PillarofFrost, _PillarofFrost_RDY and (not tChosen[Ability.BreathofSindragosa.talentID] or (tChosen[Ability.BreathofSindragosa.talentID] and ((_BreathofSindragosa_CD >= _PillarofFrost_THRESHOLD) or _BreathofSindragosa_FORM))) and ConRO:BurstMode(_PillarofFrost));
	ConRO:AbilityBurst(_RaiseDead, _RaiseDead_RDY and not _Pet_summoned and _PillarofFrost_BUFF);

--Rotations
--Start building similar to SimC structure for future updates
	for i = 1, 2, 1 do
		if not _in_combat then
			if _AbominationLimb_RDY and ConRO:FullMode(_AbominationLimb) then
				tinsert(ConRO.SuggestedSpells, _AbominationLimb);
				_AbominationLimb_RDY = false;
			end

			if _RemorselessWinter_RDY and _Runes >= _RemorselessWinter_COST then
				tinsert(ConRO.SuggestedSpells, _RemorselessWinter);
				_RemorselessWinter_RDY = false;
				_Runes = _Runes - _RemorselessWinter_COST;
			end

			if _ChillStreak_RDY and _Runes >= 1 then
				tinsert(ConRO.SuggestedSpells, _ChillStreak);
				_ChillStreak_RDY = false;
				_Runes = _Runes - 1;
			end
		end

		if tChosen[Ability.ColdHeart.talentID] and _ChainsofIce_RDY and _ColdHeart_COUNT >= 20 and _KillingMachine_BUFF and _RazorIce_COUNT >= 5 then
			tinsert(ConRO.SuggestedSpells, _ChainsofIce);
			_ChillStreak_RDY = false;
		end

		if _PillarofFrost_RDY and (not tChosen[Ability.BreathofSindragosa.talentID] or (tChosen[Ability.BreathofSindragosa.talentID] and ((_BreathofSindragosa_CD >= _PillarofFrost_THRESHOLD) or _BreathofSindragosa_FORM))) and ConRO:FullMode(_PillarofFrost) then
			tinsert(ConRO.SuggestedSpells, _PillarofFrost);
			_PillarofFrost_RDY = false;
		end

		if _BreathofSindragosa_RDY and _RunicPower >= 60 and ConRO:FullMode(_BreathofSindragosa) then
			tinsert(ConRO.SuggestedSpells, _BreathofSindragosa);
			_BreathofSindragosa_RDY = false;
			_BreathofSindragosa_FORM = true;
			_Runes = _Runes + 2;
		end

		if tChosen[Ability.BreathofSindragosa.talentID] and _BreathofSindragosa_FORM then
			if _EmpowerRuneWeapon_RDY and _Runes <= 3 and _RunicPower <= 70 and ConRO:FullMode(_EmpowerRuneWeapon) then
				tinsert(ConRO.SuggestedSpells, _EmpowerRuneWeapon);
				_EmpowerRuneWeapon_RDY = false;
			end

			if _RemorselessWinter_RDY and _Runes >= _RemorselessWinter_COST then
				tinsert(ConRO.SuggestedSpells, _RemorselessWinter);
				_RemorselessWinter_RDY = false;
				_Runes = _Runes - _RemorselessWinter_COST;
			end

			if _ChillStreak_RDY and _Runes >= 1 then
				tinsert(ConRO.SuggestedSpells, _ChillStreak);
				_ChillStreak_RDY = false;
				_Runes = _Runes - 1;
			end

			if _ReapersMark_RDY and _Runes >= _ReapersMark_COST then
				tinsert(ConRO.SuggestedSpells, _ReapersMark);
				_ReapersMark_RDY = false;
				_Runes = _Runes - _ReapersMark_COST;
			end

			if _DeathandDecay_RDY and not _DeathandDecay_BUFF and _Runes >= 1 and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _DeathandDecay);
				_DeathandDecay_RDY = false;
				_Runes = _Runes - 1;
			end

			if _Obliterate_RDY and _Runes >= _Obliterate_COST and _KillingMachine_COUNT <= 2 and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee <= 1) or ConRO_SingleButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _Obliterate);
				_KillingMachine_COUNT = _KillingMachine_COUNT - 1;
				_Runes = _Runes - _Obliterate_COST;
			end

			if _SoulReaper_RDY and _Runes >= 1 and _Target_Percent_Health <= 36 and _RunicPower >= 50 and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee <= 1) or ConRO_SingleButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _SoulReaper);
				_SoulReaper_RDY = false;
				_Runes = _Runes - 1;
			end

			if _HowlingBlast_RDY and _Rime_BUFF and _RunicPower >= 60 then
				tinsert(ConRO.SuggestedSpells, _HowlingBlast);
				_Rime_BUFF = false;
			end

			if _Frostscythe_RDY and _Runes >= 2 and not _KillingMachine_BUFF then
				tinsert(ConRO.SuggestedSpells, _Frostscythe);
				_Frostscythe_RDY = false;
				_Runes = _Runes - 2;
			end

			if _Obliterate_RDY and _Runes >= _Obliterate_COST and ((_KillingMachine_COUNT >= 1) or (_RunicPower <= _RunicPower_Max - 25)) then
				tinsert(ConRO.SuggestedSpells, _Obliterate);
				_KillingMachine_COUNT = _KillingMachine_COUNT - 1;
				_Runes = _Runes - _Obliterate_COST;
			end

			if _HornofWinter_RDY and _RunicPower <= _RunicPower_Max - 25 and ConRO:FullMode(_HornofWinter) then
				tinsert(ConRO.SuggestedSpells, _HornofWinter);
				_HornofWinter_RDY = false;
				_RunicPower = _RunicPower + 25;
				_Runes = _Runes + 2;
			end

			if _DeathandDecay_RDY and not _DeathandDecay_BUFF and _Runes >= 1 then
				tinsert(ConRO.SuggestedSpells, _DeathandDecay);
				_DeathandDecay_RDY = false;
				_Runes = _Runes - 1;
			end

			if _ArcaneTorrent_RDY and _RunicPower <= 60 then
				tinsert(ConRO.SuggestedSpells, _ArcaneTorrent);
				_ArcaneTorrent_RDY = false;
				_RunicPower = _RunicPower + 20;
			end

			if _AbominationLimb_RDY and ConRO:FullMode(_AbominationLimb) then
				tinsert(ConRO.SuggestedSpells, _AbominationLimb);
				_AbominationLimb_RDY = false;
			end

		elseif tChosen[Ability.Obliteration.talentID] and _PillarofFrost_BUFF then
			if _RunicPower >= _FrostStrike_COST and (tChosen[Ability.IcyTalons.talentID] and _IcyTalons_DUR <= 1) or (tChosen[Ability.UnleashedFrenzy.talentID] and _UnleashedFrenzy_DUR <= 1) then
				if tChosen[Ability.GlacialAdvance.talentID] and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) then
					if _GlacialAdvance_RDY then
						tinsert(ConRO.SuggestedSpells, _GlacialAdvance);
						_GlacialAdvance_RDY = false;
						_RunicPower = _RunicPower - _GlacialAdvance_COST;
					end
				else
					if _FrostStrike_RDY then
						tinsert(ConRO.SuggestedSpells, _FrostStrike);
						_FrostStrike_RDY = false;
						_RunicPower = _RunicPower - _FrostStrike_COST;
					end
				end
			end

			if _ReapersMark_RDY and _Runes >= _ReapersMark_COST then
				tinsert(ConRO.SuggestedSpells, _ReapersMark);
				_ReapersMark_RDY = false;
				_Runes = _Runes - _ReapersMark_COST;
			end

			if _EmpowerRuneWeapon_RDY and not tChosen[Ability.BreathofSindragosa.talentID] and _Runes <= 3 and _RunicPower <= 70 and ConRO:FullMode(_EmpowerRuneWeapon) then
				tinsert(ConRO.SuggestedSpells, _EmpowerRuneWeapon);
				_EmpowerRuneWeapon_RDY = false;
			end

			if _DeathandDecay_RDY and not _DeathandDecay_BUFF and not _CleavingStrikes_BUFF and _Runes >= 1 and _KillingMachine_BUFF and _PillarofFrost_DUR >= 5 and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 2) or ConRO_AoEButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _DeathandDecay);
				_DeathandDecay_RDY = false;
				_Runes = _Runes - 1;
			end

			if _Obliterate_RDY and _Runes >= _Obliterate_COST and _KillingMachine_COUNT <= 1 then
				tinsert(ConRO.SuggestedSpells, _Obliterate);
				_KillingMachine_COUNT = _KillingMachine_COUNT - 1;
				_Runes = _Runes - _Obliterate_COST;
			end

			if _SoulReaper_RDY and _Runes >= 3 and _Target_Percent_Health <= 36 and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee <= 1) or ConRO_SingleButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _SoulReaper);
				_SoulReaper_RDY = false;
				_Runes = _Runes - 1;
			end

			if _HowlingBlast_RDY and not _FrostFever_DEBUFF then
				tinsert(ConRO.SuggestedSpells, _HowlingBlast);
				_Rime_BUFF = false;
			end

			if _GlacialAdvance_RDY and _RunicPower >= _FrostStrike_COST and _RazorIce_COUNT < 5 then
				tinsert(ConRO.SuggestedSpells, _GlacialAdvance);
				_GlacialAdvance_RDY = false;
				_RunicPower = _RunicPower - _FrostStrike_COST;
			end

			if _FrostStrike_RDY and _RunicPower >= _FrostStrike_COST and tChosen[Ability.ShatteringBlade.talentID] and _RazorIce_COUNT >= 5 then
				tinsert(ConRO.SuggestedSpells, _FrostStrike);
				_RunicPower = _RunicPower - _FrostStrike_COST;
				_RazorIce_COUNT = _RazorIce_COUNT - 5;
			end

			if _RunicPower >= _FrostStrike_COST and _Runes < 2 then
				if tChosen[Ability.GlacialAdvance.talentID] and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) then
					if _GlacialAdvance_RDY then
						tinsert(ConRO.SuggestedSpells, _GlacialAdvance);
						_GlacialAdvance_RDY = false;
						_RunicPower = _RunicPower - _GlacialAdvance_COST;
					end
				else
					if _FrostStrike_RDY then
						tinsert(ConRO.SuggestedSpells, _FrostStrike);
						_FrostStrike_RDY = false;
						_RunicPower = _RunicPower - _FrostStrike_COST;
					end
				end
			end

			if _HowlingBlast_RDY and _Rime_BUFF then --Without Icebreaker talent
				tinsert(ConRO.SuggestedSpells, _HowlingBlast);
				_Rime_BUFF = false;
				_Runes = _Runes - 1;
			end

			if _FrostStrike_RDY and _RunicPower >= _FrostStrike_COST then
				tinsert(ConRO.SuggestedSpells, _FrostStrike);
				_RunicPower = _RunicPower - _FrostStrike_COST;
			end

			if _HornofWinter_RDY and (not tChosen[Ability.BreathofSindragosa.talentID] or (tChosen[Ability.BreathofSindragosa.talentID] and _BreathofSindragosa_CD >= 30)) and ConRO:FullMode(_HornofWinter) then
				tinsert(ConRO.SuggestedSpells, _HornofWinter);
				_HornofWinter_RDY = false;
				_RunicPower = _RunicPower + 25;
				_Runes = _Runes + 2;
			end
		end
--Standard Rotation
		if _RunicPower >= _FrostStrike_COST and (tChosen[Ability.IcyTalons.talentID] and _IcyTalons_DUR <= 1) or (tChosen[Ability.UnleashedFrenzy.talentID] and _UnleashedFrenzy_DUR <= 1) then
			if tChosen[Ability.GlacialAdvance.talentID] and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) then
				if _GlacialAdvance_RDY then
					tinsert(ConRO.SuggestedSpells, _GlacialAdvance);
					_GlacialAdvance_RDY = false;
					_RunicPower = _RunicPower - _FrostStrike_COST;
				end
			else
				if _FrostStrike_RDY then
					tinsert(ConRO.SuggestedSpells, _FrostStrike);
					_FrostStrike_RDY = false;
					_RunicPower = _RunicPower - _FrostStrike_COST;
				end
			end
		end

		if _AbominationLimb_RDY and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) and ConRO:FullMode(_AbominationLimb) then
			tinsert(ConRO.SuggestedSpells, _AbominationLimb);
			_AbominationLimb_RDY = false;
		end

		if _RemorselessWinter_RDY and _Runes >= _RemorselessWinter_COST then
			tinsert(ConRO.SuggestedSpells, _RemorselessWinter);
			_RemorselessWinter_RDY = false;
			_Runes = _Runes - _RemorselessWinter_COST;
		end

		if _ChillStreak_RDY and _Runes >= 1 then
			tinsert(ConRO.SuggestedSpells, _ChillStreak);
			_ChillStreak_RDY = false;
			_Runes = _Runes - 1;
		end

		if _ReapersMark_RDY and _Runes >= _ReapersMark_COST then
			tinsert(ConRO.SuggestedSpells, _ReapersMark);
			_ReapersMark_RDY = false;
			_Runes = _Runes - _ReapersMark_COST;
		end

		if _SoulReaper_RDY and _Runes >= 1 and _Target_Percent_Health <= 36 and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee <= 1) or ConRO_SingleButton:IsVisible()) then
			tinsert(ConRO.SuggestedSpells, _SoulReaper);
			_SoulReaper_RDY = false;
			_Runes = _Runes - 1;
		end

		if _Frostscythe_RDY and _Runes >= 2 and not _KillingMachine_BUFF then
			tinsert(ConRO.SuggestedSpells, _Frostscythe);
			_Frostscythe_RDY = false;
			_Runes = _Runes - 2;
		end

		if _DeathandDecay_RDY and not _DeathandDecay_BUFF and not _CleavingStrikes_BUFF and _Runes >= 1 and (_DeathandDecay_CHARGES >= 2 or _PillarofFrost_CD >= 30) and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 2) or ConRO_AoEButton:IsVisible()) then
			tinsert(ConRO.SuggestedSpells, _DeathandDecay);
			_DeathandDecay_RDY = false;
			_Runes = _Runes - 1;
		end

		if _Obliterate_RDY and _Runes >= _Obliterate_COST and (_KillingMachine_COUNT <= 2 or (_KillingMachine_BUFF and _CleavingStrikes_BUFF)) then
			tinsert(ConRO.SuggestedSpells, _Obliterate);
			_KillingMachine_COUNT = _KillingMachine_COUNT - 1;
			_Runes = _Runes - _Obliterate_COST;
		end

		if (tChosen[Ability.ShatteredFrost.talentID] and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 2) or ConRO_AoEButton:IsVisible())) or (((ConRO_AutoButton:IsVisible() and _enemies_in_melee <= 1) or ConRO_SingleButton:IsVisible()) and (not tChosen[Ability.AFeastofSouls.talentID] or (tChosen[Ability.AFeastofSouls.talentID] and _AFeastofSouls_BUFF))) then
			if _FrostStrike_RDY and _RunicPower >= _FrostStrike_COST and tChosen[Ability.ShatteringBlade.talentID] and _RazorIce_COUNT >= 5 then
				tinsert(ConRO.SuggestedSpells, _FrostStrike);
				_RunicPower = _RunicPower - _FrostStrike_COST;
				_RazorIce_COUNT = _RazorIce_COUNT - 5;
			end
		end

		if _FrostStrike_RDY and _RunicPower >= _FrostStrike_COST and _KillingMachine_BUFF and _Runes < 2 and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee <= 1) or ConRO_SingleButton:IsVisible()) then
			tinsert(ConRO.SuggestedSpells, _FrostStrike);
			_RunicPower = _RunicPower - _FrostStrike_COST;
		end

		if _HowlingBlast_RDY and _Runes >= 1 and _Rime_BUFF and (tChosen[Ability.Icebreaker.talentID] or ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible())) then
			tinsert(ConRO.SuggestedSpells, _HowlingBlast);
			_Rime_BUFF = false;
			_Runes = _Runes - 1;
		end

		if _Obliterate_RDY and _Runes >= _Obliterate_COST and _KillingMachine_COUNT <= 1 then
			tinsert(ConRO.SuggestedSpells, _Obliterate);
			_KillingMachine_COUNT = _KillingMachine_COUNT - 1;
			_Runes = _Runes - _Obliterate_COST;
		end

		if _FrostStrike_RDY and _RunicPower >= _RunicPower_Max - 10 and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee <= 1) or ConRO_SingleButton:IsVisible()) then
			tinsert(ConRO.SuggestedSpells, _FrostStrike);
			_RunicPower = _RunicPower - _FrostStrike_COST;
		end

		if _HowlingBlast_RDY and _Runes >= 1 and _Rime_BUFF then --Without Icebreaker talent
			tinsert(ConRO.SuggestedSpells, _HowlingBlast);
			_Rime_BUFF = false;
			_Runes = _Runes - 1;
		end

		if _RunicPower >= _FrostStrike_COST then
			if tChosen[Ability.GlacialAdvance.talentID] and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) then
				if _GlacialAdvance_RDY then
					tinsert(ConRO.SuggestedSpells, _GlacialAdvance);
					_GlacialAdvance_RDY = false;
					_RunicPower = _RunicPower - _FrostStrike_COST;
				end
			else
				if _FrostStrike_RDY then
					tinsert(ConRO.SuggestedSpells, _FrostStrike);
					_RunicPower = _RunicPower - _FrostStrike_COST;
				end
			end
		end

		if _Obliterate_RDY and _Runes >= _Obliterate_COST then
			tinsert(ConRO.SuggestedSpells, _Obliterate);
			_KillingMachine_COUNT = _KillingMachine_COUNT - 1;
			_Runes = _Runes - _Obliterate_COST;
		end

		if _HornofWinter_RDY and _RunicPower <= _RunicPower_Max - 25 and (not tChosen[Ability.BreathofSindragosa.talentID] or (tChosen[Ability.BreathofSindragosa.talentID] and _BreathofSindragosa_CD >= 30)) and ConRO:FullMode(_HornofWinter) then
			tinsert(ConRO.SuggestedSpells, _HornofWinter);
			_HornofWinter_RDY = false;
			_RunicPower = _RunicPower + 25;
			_Runes = _Runes + 2;
		end

		if _AbominationLimb_RDY and ConRO:FullMode(_AbominationLimb) then
			tinsert(ConRO.SuggestedSpells, _AbominationLimb);
			_AbominationLimb_RDY = false;
		end
	end
	return nil;
end

function ConRO.DeathKnight.FrostDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Frost_Ability, ids.Frost_Form, ids.Frost_Buff, ids.Frost_Debuff, ids.Frost_PetAbility, ids.Frost_PvPTalent;

--Abilities
	local _DeathCoil, _DeathCoil_RDY = ConRO:AbilityReady(Ability.DeathCoil, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _DarkSuccor_BUFF = ConRO:Aura(Buff.DarkSuccor, timeShift);
	local _IceboundFortitude, _IceboundFortitude_RDY = ConRO:AbilityReady(Ability.IceboundFortitude, timeShift);
	local _Lichborne, _Lichborne_RDY = ConRO:AbilityReady(Ability.Lichborne, timeShift);
		local _Lichborne_BUFF = ConRO:Aura(Buff.Lichborne, timeShift);
	local _RaiseDead, _RaiseDead_RDY, _RaiseDead_CD = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _SacrificialPact, _SacrificialPact_RDY = ConRO:AbilityReady(Ability.SacrificialPact, timeShift);

	local _DeathPact, _DeathPact_RDY = ConRO:AbilityReady(Ability.DeathPact, timeShift);

--Conditions

--Rotations
		if _SacrificialPact_RDY and _Player_Percent_Health <= 20 and _RaiseDead_CD > 60 then
			tinsert(ConRO.SuggestedDefSpells, _SacrificialPact);
		end

		if _DeathPact_RDY and _Player_Percent_Health <= 50 then
			tinsert(ConRO.SuggestedDefSpells, _DeathPact);
		end

		if _DeathCoil_RDY and _Lichborne_BUFF and _Player_Percent_Health <= 80 then
			tinsert(ConRO.SuggestedDefSpells, _DeathCoil);
		end

		if _Lichborne_RDY and _Player_Percent_Health <= 40 then
			tinsert(ConRO.SuggestedDefSpells, _Lichborne);
		end

		if _DeathStrike_RDY and ((_DarkSuccor_BUFF and _Player_Percent_Health <= 80) or _Player_Percent_Health <= 30) then
			tinsert(ConRO.SuggestedDefSpells, _DeathStrike);
		end

		if _IceboundFortitude_RDY then
			tinsert(ConRO.SuggestedDefSpells, _IceboundFortitude);
		end
	return nil;
end

function ConRO.DeathKnight.Unholy(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Unholy_Ability, ids.Unholy_Form, ids.Unholy_Buff, ids.Unholy_Debuff, ids.Unholy_PetAbility, ids.Unholy_PvPTalent;

--Abilities
	local _Apocalypse, _Apocalypse_RDY, _Apocalypse_CD, _Apocalypse_MaxCD = ConRO:AbilityReady(Ability.Apocalypse, timeShift);
	local _ArmyoftheDead, _ArmyoftheDead_RDY = ConRO:AbilityReady(Ability.ArmyoftheDead, timeShift);
	local _DarkTransformation, _DarkTransformation_RDY, _DarkTransformation_CD = ConRO:AbilityReady(Ability.DarkTransformation, timeShift);
		local _DarkTransformation_BUFF = ConRO:UnitAura(Buff.DarkTransformation, timeShift, "pet");
	local _DeathandDecay, _DeathandDecay_RDY = ConRO:AbilityReady(Ability.DeathandDecay, timeShift);
		local _DeathandDecay_BUFF = ConRO:Aura(Buff.DeathandDecay, timeShift);
	local _DeathCoil, _DeathCoil_RDY = ConRO:AbilityReady(Ability.DeathCoil, timeShift);
		local _SuddenDoom_BUFF = ConRO:Aura(Buff.SuddenDoom, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _DarkSuccor_BUFF = ConRO:Aura(Buff.DarkSuccor, timeShift);
	local _DeathsAdvance, _DeathsAdvance_RDY = ConRO:AbilityReady(Ability.DeathsAdvance, timeShift);
	local _Epidemic, _Epidemic_RDY = ConRO:AbilityReady(Ability.Epidemic, timeShift);
	local _FesteringStrike, _FesteringStrike_RDY = ConRO:AbilityReady(Ability.FesteringStrike, timeShift);
		local _FesteringWound_DEBUFF, _FesteringWound_COUNT = ConRO:TargetAura(Debuff.FesteringWound, timeShift);
	local _MindFreeze, _MindFreeze_RDY = ConRO:AbilityReady(Ability.MindFreeze, timeShift);
	local _Outbreak, _Outbreak_RDY = ConRO:AbilityReady(Ability.Outbreak, timeShift);
		local _VirulentPlague_DEBUFF = ConRO:TargetAura(Debuff.VirulentPlague, timeShift);
	local _RaiseDead, _RaiseDead_RDY = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _RaiseDeadUnholy, _RaiseDeadUnholy_RDY = ConRO:AbilityReady(Ability.RaiseDeadUnholy, timeShift);
	local _ScourgeStrike, _ScourgeStrike_RDY = ConRO:AbilityReady(Ability.ScourgeStrike, timeShift);
		local _Plaguebringer_BUFF = ConRO:Aura(Buff.Plaguebringer, timeShift);

	local _Asphyxiate, _Asphyxiate_RDY = ConRO:AbilityReady(Ability.Asphyxiate, timeShift);
	local _ClawingShadows, _ClawingShadows_RDY = ConRO:AbilityReady(Ability.ClawingShadows, timeShift);
	local _Defile, _Defile_RDY = ConRO:AbilityReady(Ability.Defile, timeShift);
	local _SoulReaper, _SoulReaper_RDY = ConRO:AbilityReady(Ability.SoulReaper, timeShift);
	local _SummonGargoyle, _SummonGargoyle_RDY, _SummonGargoyle_CD = ConRO:AbilityReady(Ability.SummonGargoyle, timeShift);
	local _UnholyAssault, _UnholyAssault_RDY = ConRO:AbilityReady(Ability.UnholyAssault, timeShift);
		local _UnholyBlight_DEBUFF = ConRO:TargetAura(Debuff.UnholyBlight, timeShift);
	local _WraithWalk, _WraithWalk_RDY = ConRO:AbilityReady(Ability.WraithWalk, timeShift);

	local _AbominationLimb, _AbominationLimb_RDY = ConRO:AbilityReady(Ability.AbominationLimb, timeShift);

--Conditions
	local _Ghoul_out = IsSpellKnown(PetAbility.Claw, true);

	if tChosen[Ability.Defile.talentID] then
		_DeathandDecay, _DeathandDecay_RDY = _Defile, _Defile_RDY;
	end

	if tChosen[Ability.RaiseDeadUnholy.talentID] then
		_RaiseDead, _RaiseDead_RDY = _RaiseDeadUnholy, _RaiseDeadUnholy_RDY;
	end

--Indicators
	ConRO:AbilityInterrupt(_MindFreeze, _MindFreeze_RDY and ConRO:Interrupt());
	ConRO:AbilityInterrupt(_Asphyxiate, _Asphyxiate_RDY and (ConRO:Interrupt() and not _MindFreeze_RDY and _is_PC and _is_Enemy));
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());
	ConRO:AbilityMovement(_DeathsAdvance, _DeathsAdvance_RDY and not _target_in_melee);
	ConRO:AbilityMovement(_WraithWalk, _WraithWalk_RDY and not _target_in_melee);

	ConRO:AbilityBurst(_ArmyoftheDead, _ArmyoftheDead_RDY);
	ConRO:AbilityBurst(_DarkTransformation, _in_combat and _DarkTransformation_RDY and _Ghoul_out and ConRO:BurstMode(_DarkTransformation));
	ConRO:AbilityBurst(_Apocalypse, _in_combat and _Apocalypse_RDY and _FesteringWound_COUNT >= 4 and ConRO:BurstMode(_Apocalypse));
	ConRO:AbilityBurst(_UnholyAssault, _in_combat and _UnholyAssault_RDY and _FesteringWound_COUNT < 3 and ConRO:BurstMode(_UnholyAssault));
	ConRO:AbilityBurst(_SummonGargoyle, _SummonGargoyle_RDY and _RunicPower >= 90 and _SuddenDoom_BUFF and ConRO:BurstMode(_SummonGargoyle));

	ConRO:AbilityBurst(_AbominationLimb, _AbominationLimb_RDY and ConRO:BurstMode(_AbominationLimb));

--Warnings
	ConRO:Warnings("Call your ghoul!", _RaiseDead_RDY and not _Pet_summoned);

--Rotations
	for i = 1, 2, 1 do
		if not _in_combat then
			if _Outbreak_RDY and not _VirulentPlague_DEBUFF then
				tinsert(ConRO.SuggestedSpells, _Outbreak);
				_Outbreak_RDY = false;
				_Runes = _Runes - 1;
			end

			if _FesteringStrike_RDY and _Runes >= 2 and (_FesteringWound_COUNT <= 0 or (_FesteringWound_COUNT <= 4 and (_Apocalypse_RDY or _Apocalypse_CD <= 10))) then
				tinsert(ConRO.SuggestedSpells, _FesteringStrike);
				_Runes = _Runes - 2;
			end
		end

		if _SummonGargoyle_RDY and _RunicPower >= _RunicPower_Max - 50 and ConRO:FullMode(_SummonGargoyle) then
			tinsert(ConRO.SuggestedSpells, _SummonGargoyle);
			_SummonGargoyle_RDY = false;
		end

		if _DeathCoil_RDY and (_RunicPower >= 30 or _SuddenDoom_BUFF) and (_SummonGargoyle_CD >= 155 and tChosen[Ability.SummonGargoyle.talentID]) then
			tinsert(ConRO.SuggestedSpells, _DeathCoil);
			_RunicPower = _RunicPower - 30;
		end

		if _SoulReaper_RDY and _Runes >= 1 and _can_Execute then
			tinsert(ConRO.SuggestedSpells, _SoulReaper);
			_SoulReaper_RDY = false;
			_Runes = _Runes - 1;
		end

		if _Outbreak_RDY and not _VirulentPlague_DEBUFF then
			tinsert(ConRO.SuggestedSpells, _Outbreak);
			_Runes = _Runes - 1;
		end

		if _DarkTransformation_RDY and _Ghoul_out and ConRO:FullMode(_DarkTransformation) then
			tinsert(ConRO.SuggestedSpells, _DarkTransformation);
			_DarkTransformation_RDY = false;
		end

		if _Apocalypse_RDY and _FesteringWound_COUNT >= 4 and ConRO:FullMode(_Apocalypse) then
			tinsert(ConRO.SuggestedSpells, _Apocalypse);
			_Apocalypse_RDY = false;
		end

		if _UnholyAssault_RDY and _FesteringWound_COUNT < 3 and _Apocalypse_CD <= _Apocalypse_MaxCD - 3 and _Apocalypse_CD >= _Apocalypse_MaxCD - 15 and ConRO:FullMode(_UnholyAssault) then
			tinsert(ConRO.SuggestedSpells, _UnholyAssault);
			_UnholyAssault_RDY = false;
		end

		if _AbominationLimb_RDY and ConRO:FullMode(_AbominationLimb) then
			tinsert(ConRO.SuggestedSpells, _AbominationLimb);
			_AbominationLimb_RDY = false;
		end

		if _DeathandDecay_RDY and not _DeathandDecay_BUFF and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 2) or ConRO_AoEButton:IsVisible()) then
			tinsert(ConRO.SuggestedSpells, _DeathandDecay);
			_DeathandDecay_BUFF = true;
		end

		if ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) and _Runes >= 1 and _DeathandDecay_BUFF then
			if _ClawingShadows_RDY and tChosen[Ability.ClawingShadows.talentID] and ((_FesteringWound_COUNT >= 1 and (not _Apocalypse_RDY or _Apocalypse_CD > 5)) or (_FesteringWound_COUNT >= 5 and _Apocalypse_RDY)) then
				tinsert(ConRO.SuggestedSpells, _ClawingShadows);
				_Runes = _Runes - 1;
			elseif _ScourgeStrike_RDY and not tChosen[Ability.ClawingShadows.talentID] and ((_FesteringWound_COUNT >= 1 and (not _Apocalypse_RDY or _Apocalypse_CD > 5)) or (_FesteringWound_COUNT >= 5 and _Apocalypse_RDY)) then
				tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
				_Runes = _Runes - 1;
			end
		end

		if _Epidemic_RDY and ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 4) or ConRO_AoEButton:IsVisible()) then
			tinsert(ConRO.SuggestedSpells, _Epidemic);
			_RunicPower = _RunicPower - 30;
		end

		if _ScourgeStrike_RDY and tChosen[Ability.Plaguebringer.talentID] and not _Plaguebringer_BUFF then
			tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
			_Runes = _Runes - 1;
		end

		if _DeathCoil_RDY and (_SuddenDoom_BUFF or (not tChosen[Ability.RunicMastery.talentID] and _RunicPower >= 100) or _RunicPower >= 80) then
			tinsert(ConRO.SuggestedSpells, _DeathCoil);
			_RunicPower = _RunicPower - 30;
		end

		if _FesteringStrike_RDY and _Runes >= 2 and (_FesteringWound_COUNT <= 2 or (_FesteringWound_COUNT <= 4 and (_Apocalypse_RDY or _Apocalypse_CD <= 10))) then
			tinsert(ConRO.SuggestedSpells, _FesteringStrike);
		end

		if ((_FesteringWound_COUNT >= 3 and (not _Apocalypse_RDY or _Apocalypse_CD > 5)) or (_FesteringWound_COUNT >= 5 and _Apocalypse_RDY)) then
			if tChosen[Ability.ClawingShadows.talentID] then
				if _ClawingShadows_RDY then
					tinsert(ConRO.SuggestedSpells, _ClawingShadows);
					_Runes = _Runes - 1;
				end
			else
				if _ScourgeStrike_RDY then
					tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
					_Runes = _Runes - 1;
				end
			end
		end

		if _DeathStrike_RDY and _DarkSuccor_BUFF then
			tinsert(ConRO.SuggestedSpells, _DeathStrike);
		end

		if _DeathCoil_RDY then
			tinsert(ConRO.SuggestedSpells, _DeathCoil);
			_RunicPower = _RunicPower - 30;
		end
	end
	return nil;
end

function ConRO.DeathKnight.UnholyDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Unholy_Ability, ids.Unholy_Form, ids.Unholy_Buff, ids.Unholy_Debuff, ids.Unholy_PetAbility, ids.Unholy_PvPTalent;

--Abilities
	local _DeathCoil, _DeathCoil_RDY = ConRO:AbilityReady(Ability.DeathCoil, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _DarkSuccor_BUFF = ConRO:Aura(Buff.DarkSuccor, timeShift);
	local _IceboundFortitude, _IceboundFortitude_RDY = ConRO:AbilityReady(Ability.IceboundFortitude, timeShift);
	local _Lichborne, _Lichborne_RDY = ConRO:AbilityReady(Ability.Lichborne, timeShift);
		local _Lichborne_BUFF = ConRO:Aura(Buff.Lichborne, timeShift);
	local _SacrificialPact, _SacrificialPact_RDY = ConRO:AbilityReady(Ability.SacrificialPact, timeShift);

	local _DeathPact, _DeathPact_RDY = ConRO:AbilityReady(Ability.DeathPact, timeShift);

--Conditions
	local _Pet_summoned = ConRO:CallPet();

--Rotations
		if _SacrificialPact_RDY and _Player_Percent_Health <= 20 and _Pet_summoned then
			tinsert(ConRO.SuggestedDefSpells, _SacrificialPact);
		end

		if _DeathPact_RDY and _Player_Percent_Health <= 50 then
			tinsert(ConRO.SuggestedDefSpells, _DeathPact);
		end

		if _DeathCoil_RDY and _Lichborne_BUFF and _Player_Percent_Health <= 80 then
			tinsert(ConRO.SuggestedDefSpells, _DeathCoil);
		end

		if _Lichborne_RDY and _Player_Percent_Health <= 40 then
			tinsert(ConRO.SuggestedDefSpells, _Lichborne);
		end

		if _DeathStrike_RDY and ((_DarkSuccor_BUFF and _Player_Percent_Health <= 80) or _Player_Percent_Health <= 30) then
			tinsert(ConRO.SuggestedDefSpells, _DeathStrike);
		end

		if _IceboundFortitude_RDY then
			tinsert(ConRO.SuggestedDefSpells, _IceboundFortitude);
		end
	return nil;
end

function ConRO:DKrunes()
	local _Runes = {
		rune1 = select(3, GetRuneCooldown(1));
		rune2 = select(3, GetRuneCooldown(2));
		rune3 = select(3, GetRuneCooldown(3));
		rune4 = select(3, GetRuneCooldown(4));
		rune5 = select(3, GetRuneCooldown(5));
		rune6 = select(3, GetRuneCooldown(6));
	}

	local totalrunes = 0;
		for k, v in pairs(_Runes) do
			if v then
				totalrunes = totalrunes + 1;
			end
		end
	return totalrunes;
end