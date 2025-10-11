ConRO.DeathKnight = {};
ConRO.DeathKnight.CheckTalents = function()
end
ConRO.DeathKnight.CheckPvPTalents = function()
end
local ConRO_DeathKnight, ids = ...;
local Ability, Buff, Debuff, PvPTalent, Pet_Ability = _, _, _, _, _;

function ConRO:EnableRotationModule(mode)
	mode = mode or 0;
	self.ModuleOnEnable = ConRO.DeathKnight.CheckTalents;
	self.ModuleOnEnable = ConRO.DeathKnight.CheckPvPTalents;
	if mode == 0 then
		self.Description = "Death Knight [No Specialization Under 10]";
		self.NextSpell = ConRO.DeathKnight.Disabled;
		self.NextDef = ConRO.DeathKnight.Disabled;
		self.ToggleHealer();
		ConROWindow:SetAlpha(0);
		ConRODefenseWindow:SetAlpha(0);
	end;
	if mode == 1 then
		self.Description = 'Death Knight [Blood - Tank]';
		if ConRO.db.profile._Spec_1_Enabled then
			Ability, Buff, Debuff, PvPTalent = ids.blood.ability, ids.blood.buff, ids.blood.debuff, ids.blood.pvptalent;
			self.NextSpell = ConRO.DeathKnight.Blood;
			self.NextDef = ConRO.DeathKnight.BloodDef;
			self.ToggleDamage();
			self.BlockAoE();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.DeathKnight.Disabled;
			self.NextDef = ConRO.DeathKnight.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	if mode == 2 then
		self.Description = 'Death Knight [Frost - Melee]';
		if ConRO.db.profile._Spec_2_Enabled then
			Ability, Buff, Debuff, PvPTalent = ids.frost.ability, ids.frost.buff, ids.frost.debuff, ids.frost.pvptalent;
			self.NextSpell = ConRO.DeathKnight.Frost;
			self.NextDef = ConRO.DeathKnight.FrostDef;
			self.ToggleDamage();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.DeathKnight.Disabled;
			self.NextDef = ConRO.DeathKnight.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	if mode == 3 then
		self.Description = 'Death Knight [Unholy - Melee]';
		if ConRO.db.profile._Spec_3_Enabled then
			Ability, Buff, Debuff, PvPTalent, Pet_Ability = ids.unholy.ability, ids.unholy.buff, ids.unholy.debuff, ids.unholy.pvptalent, ids.unholy.pet_ability;
			self.NextSpell = ConRO.DeathKnight.Unholy;
			self.NextDef = ConRO.DeathKnight.UnholyDef;
			self.ToggleDamage();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.DeathKnight.Disabled;
			self.NextDef = ConRO.DeathKnight.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED');
	self.lastSpellId = 0;
end

function ConRO:EnableDefenseModule(mode)

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
local _Queue = 0;
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

local HeroSpec, Racial, Runeforge = ids.hero_spec, ids.racial, ids.runeforge;

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

	_Queue = 0;
	_is_moving = ConRO:PlayerSpeed();
	_enemies_in_melee, _target_in_melee = ConRO:Targets("Melee");
	_enemies_in_10yrds, _target_in_10yrds = ConRO:Targets("10");
	_enemies_in_25yrds, _target_in_25yrds = ConRO:Targets("25");
	_enemies_in_40yrds, _target_in_40yrds = ConRO:Targets("40");
	_can_Execute = _Target_Percent_Health < 35;

	_Pet_summoned = ConRO:CallPet();

	_AncestralCall, _AncestralCall_RDY = ConRO:AbilityReady(Racial.AncestralCall, timeShift);
	_ArcanePulse, _ArcanePulse_RDY = ConRO:AbilityReady(Racial.ArcanePulse, timeShift);
	_Berserking, _Berserking_RDY = ConRO:AbilityReady(Racial.Berserking, timeShift);
	_ArcaneTorrent, _ArcaneTorrent_RDY = ConRO:AbilityReady(Racial.ArcaneTorrent, timeShift);
end

function ConRO.DeathKnight.Blood(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();

--Abilities
	local _Asphyxiate, _Asphyxiate_RDY = ConRO:AbilityReady(Ability.Asphyxiate, timeShift);
	local _BloodBoil, _BloodBoil_RDY = ConRO:AbilityReady(Ability.BloodBoil, timeShift);
		local _BloodBoil_CHARGES = ConRO:SpellCharges(_BloodBoil);
	local _BloodTap, _BloodTap_RDY = ConRO:AbilityReady(Ability.BloodTap, timeShift);
		local _BloodTap_CHARGES, _BloodTap_MAX_CHARGES = ConRO:SpellCharges(_BloodTap);
	local _Blooddrinker, _Blooddrinker_RDY = ConRO:AbilityReady(Ability.Blooddrinker, timeShift);
	local _Bonestorm, _Bonestorm_RDY = ConRO:AbilityReady(Ability.Bonestorm, timeShift);
	local _Consumption, _Consumption_RDY = ConRO:AbilityReady(Ability.Consumption, timeShift);
	local _DancingRuneWeapon, _DancingRuneWeapon_RDY, _DancingRuneWeapon_CD = ConRO:AbilityReady(Ability.DancingRuneWeapon, timeShift);
		local _DancingRuneWeapon_BUFF = ConRO:Aura(Buff.DancingRuneWeapon, timeShift);
	local _DarkCommand, _DarkCommand_RDY = ConRO:AbilityReady(Ability.DarkCommand, timeShift);
	local _DeathandDecay, _DeathandDecay_RDY = ConRO:AbilityReady(Ability.DeathandDecay, timeShift);
		local _DeathandDecay_BUFF = ConRO:Aura(Buff.DeathandDecay, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _, _, _Coagulopathy_DUR = ConRO:Aura(Buff.Coagulopathy, timeShift);
	local _DeathsAdvance, _DeathsAdvance_RDY = ConRO:AbilityReady(Ability.DeathsAdvance, timeShift);
	local _DeathsCaress, _DeathsCaress_RDY = ConRO:AbilityReady(Ability.DeathsCaress, timeShift);
	local _HeartStrike, _HeartStrike_RDY = ConRO:AbilityReady(Ability.HeartStrike, timeShift);
	local _MarkofBlood, _MarkofBlood_RDY = ConRO:AbilityReady(Ability.MarkofBlood, timeShift);
	local _MindFreeze, _MindFreeze_RDY = ConRO:AbilityReady(Ability.MindFreeze, timeShift);
	local _Marrowrend, _Marrowrend_RDY = ConRO:AbilityReady(Ability.Marrowrend, timeShift);
		local _, _BoneShield_COUNT, _BoneShield_DUR = ConRO:Aura(Buff.BoneShield, timeShift);
	local _RaiseDead, _RaiseDead_RDY = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _ReapersMark, _ReapersMark_RDY, _ReapersMark_CD = ConRO:AbilityReady(Ability.ReapersMark, timeShift);
	local _SoulReaper, _SoulReaper_RDY = ConRO:AbilityReady(Ability.SoulReaper, timeShift);
	local _Tombstone, _Tombstone_RDY = ConRO:AbilityReady(Ability.Tombstone, timeShift);
	local _WraithWalk, _WraithWalk_RDY = ConRO:AbilityReady(Ability.WraithWalk, timeShift);

--Aura
	local _, exterminate_COUNT = ConRO:Aura(Buff.exterminate, timeShift)
	local infliction_of_sorrow_BUFF = ConRO:Aura(Buff.infliction_of_sorrow, timeShift)
	local _ReaperofSouls_BUFF = ConRO:Aura(Buff.reaper_of_souls, timeShift)

	local _BloodPlague_DEBUFF = ConRO:TargetAura(Debuff.BloodPlague, timeShift)
	local blood_plague_SPREAD = ConRO:EveryTargetAura(Debuff.BloodPlague)
	local _ReapersMark_DEBUFF = ConRO:TargetAura(Debuff.ReapersMark, timeShift)

--Conditions
	local death_strike_COST = 45
	if tChosen[Ability.ImprovedDeathStrike.talentID] then
		death_strike_COST = death_strike_COST - 5
	end

	if tChosen[Ability.Ossuary.talentID] and _BoneShield_COUNT >= 5 then
		death_strike_COST = death_strike_COST - 5
	end

	if ConRO:IsOverride(_HeartStrike) == Ability.VampiricStrike.spellID then
		_HeartStrike, _HeartStrike_RDY = ConRO:AbilityReady(Ability.VampiricStrike, timeShift)
	end

--Indicators
	ConRO:AbilityInterrupt(_MindFreeze, _MindFreeze_RDY and ConRO:Interrupt());
	ConRO:AbilityInterrupt(_Asphyxiate, _Asphyxiate_RDY and (ConRO:Interrupt() and not _MindFreeze_RDY and _is_PC and _is_Enemy));
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());
	ConRO:AbilityTaunt(_DarkCommand, _DarkCommand_RDY and (not ConRO:InRaid() or (ConRO:InRaid() and ConRO:TarYou())));
	ConRO:AbilityMovement(_DeathsAdvance, _DeathsAdvance_RDY and not _target_in_melee);
	ConRO:AbilityMovement(_WraithWalk, _WraithWalk_RDY and not _target_in_melee);

	ConRO:AbilityBurst(_Bonestorm, _Bonestorm_RDY and _RunicPower >= 10 and _enemies_in_melee >= 3 and ConRO:BurstMode(_Bonestorm, 60));
	ConRO:AbilityBurst(_RaiseDead, _RaiseDead_RDY and not _Pet_summoned  and ConRO:BurstMode(_RaiseDead, 120));

--Rotations
	repeat
		while(true) do
			if select(8, UnitChannelInfo("player")) == _Blooddrinker then
				tinsert(ConRO.SuggestedSpells, _Blooddrinker);
				_Queue = _Queue + 1;
				break;
			end

			if not _in_combat then
				if _DeathsCaress_RDY and _Runes >= 1 and not _BloodPlague_DEBUFF and not _target_in_melee then
					tinsert(ConRO.SuggestedSpells, _DeathsCaress);
					_DeathsCaress_RDY = false;
					_BloodPlague_DEBUFF = true;
					_BoneShield_COUNT = _BoneShield_COUNT + 2
					_BoneShield_DUR = 30
					_Runes = _Runes - 1;
					_Queue = _Queue + 1;
					break;
				end

				if _DeathandDecay_RDY and _Runes >= 1 and not _DeathandDecay_BUFF and ConRO.lastSpellId ~= _DeathandDecay then
					tinsert(ConRO.SuggestedSpells, _DeathandDecay);
					_DeathandDecay_BUFF = true;
					_Runes = _Runes - 1;
					_Queue = _Queue + 1;
					break;
				end

				if _ReapersMark_RDY and ConRO:HeroSpec(HeroSpec.Deathbringer) then
					tinsert(ConRO.SuggestedSpells, _ReapersMark);
					_ReapersMark_RDY = false;
					_Queue = _Queue + 1;
					break;
				end
			end

			if _Marrowrend_RDY and _Runes >= 2 and (_BoneShield_COUNT < 5 or _BoneShield_DUR < 1.5) and _target_in_melee then
				tinsert(ConRO.SuggestedSpells, _Marrowrend)
				_BoneShield_COUNT = _BoneShield_COUNT + 3
				_BoneShield_DUR = 30
				_Runes = _Runes - 2
				_RunicPower = _RunicPower + 20
				_Queue = _Queue + 1
				break
			end

			if _DeathsCaress_RDY and _Runes >= 1 and (_BoneShield_COUNT < 5 or _BoneShield_DUR < 1.5) and not _target_in_melee then
				tinsert(ConRO.SuggestedSpells, _DeathsCaress)
				_DeathsCaress_RDY = false
				_BloodPlague_DEBUFF = true
				_BoneShield_COUNT = _BoneShield_COUNT + 2
				_BoneShield_DUR = 30
				_Runes = _Runes - 1
				_RunicPower = _RunicPower + 10
				_Queue = _Queue + 1
				break
			end

			if _Blooddrinker_RDY and not _DancingRuneWeapon_BUFF then
				tinsert(ConRO.SuggestedSpells, _Blooddrinker)
				_Blooddrinker_RDY = false
				_Queue = _Queue + 1
				break
			end

			if _DeathandDecay_RDY and _Runes >= 1 and not _DeathandDecay_BUFF and ConRO.lastSpellId ~= _DeathandDecay then
				tinsert(ConRO.SuggestedSpells, _DeathandDecay)
				_DeathandDecay_RDY = false
				_DeathandDecay_BUFF = true
				_Runes = _Runes - 1
				_RunicPower = _RunicPower + 10
				_Queue = _Queue + 1
				break
			end

			if _DancingRuneWeapon_BUFF then
				if _Bonestorm_RDY and _BoneShield_COUNT > 5 and _DeathandDecay_BUFF and ConRO:FullMode(_Bonestorm) then
					tinsert(ConRO.SuggestedSpells, _Bonestorm)
					_Bonestorm_RDY = false
					_BoneShield_COUNT = _BoneShield_COUNT - 5
					_Queue = _Queue + 1
					break
				end

				if _BloodBoil_RDY and _enemies_in_10yrds >= 1 and _BloodBoil_CHARGES >= 1 and not blood_plague_SPREAD then
					tinsert(ConRO.SuggestedSpells, _BloodBoil)
					blood_plague_SPREAD = true
					_BloodBoil_CHARGES = _BloodBoil_CHARGES - 1
					_Queue = _Queue + 1
					break
				end

				if _HeartStrike_RDY and _Runes >= 1 then
					tinsert(ConRO.SuggestedSpells, _HeartStrike)
					_Runes = _Runes - 1
					_RunicPower = _RunicPower + 10
					_Queue = _Queue + 1
					break
				end

				if _DeathStrike_RDY and _RunicPower >= 75 or _Coagulopathy_DUR <= 1.5 then
					tinsert(ConRO.SuggestedSpells, _DeathStrike)
					_RunicPower = _RunicPower - death_strike_COST
					_Coagulopathy_DUR = 8
					_Queue = _Queue + 1
					break
				end

				if _Consumption_RDY then
					tinsert(ConRO.SuggestedSpells, _Consumption)
					_Consumption_RDY = false
					_Runes = _Runes + 2
					_RunicPower = _RunicPower + 20
					_Queue = _Queue + 1
					break
				end

				if _BloodBoil_RDY and _enemies_in_10yrds >= 1 and _BloodBoil_CHARGES >= 1 then
					tinsert(ConRO.SuggestedSpells, _BloodBoil)
					blood_plague_SPREAD = true
					_BloodBoil_CHARGES = _BloodBoil_CHARGES - 1
					_Queue = _Queue + 1
					break
				end
			else
				if _Marrowrend_RDY and _Runes >= 1 and exterminate_COUNT >= 1 and _ReapersMark_CD < 15 then
					tinsert(ConRO.SuggestedSpells, _Marrowrend)
					exterminate_COUNT = exterminate_COUNT - 1
					_Runes = _Runes - 1
					_BoneShield_COUNT = _BoneShield_COUNT + 3
					_BoneShield_DUR = 30
					_Queue = _Queue + 1
					break
				end

				if _ReapersMark_RDY and not _ReapersMark_DEBUFF and ConRO:HeroSpec(HeroSpec.Deathbringer) then
					tinsert(ConRO.SuggestedSpells, _ReapersMark);
					_ReapersMark_RDY = false;
					_ReapersMark_BUFF = true;
					_Queue = _Queue + 1;
					break;
				end

				if _SoulReaper_RDY and ((_Runes >= 1 and _Target_Percent_Health <= 35) or _ReaperofSouls_BUFF) then
					tinsert(ConRO.SuggestedSpells, _SoulReaper)
					_SoulReaper_RDY = false
					if _ReaperofSouls_BUFF then
						_ReaperofSouls_BUFF = false
					else
						_Runes = _Runes - 1
						_RunicPower = _RunicPower + 10
					end
					_Queue = _Queue + 1
					break
				end

				if _DancingRuneWeapon_RDY and ConRO:HeroSpec(HeroSpec.Sanlayn) then
					tinsert(ConRO.SuggestedSpells, _DancingRuneWeapon)
					_DancingRuneWeapon_RDY = false
					_Queue = _Queue + 1
					break
				end

				if _Tombstone_RDY and _BoneShield_COUNT > 5 and _DancingRuneWeapon_CD > 25 and _DeathandDecay_BUFF and ConRO:FullMode(_Tombstone) then
					tinsert(ConRO.SuggestedSpells, _Tombstone)
					_Tombstone_RDY = false
					_BoneShield_COUNT = _BoneShield_COUNT - 5
					_RunicPower = _RunicPower + 30
					_Queue = _Queue + 1
					break
				end

				if _Bonestorm_RDY and _BoneShield_COUNT > 5 and _DancingRuneWeapon_CD > 15 and _DeathandDecay_BUFF and ConRO:FullMode(_Bonestorm) then
					tinsert(ConRO.SuggestedSpells, _Bonestorm)
					_Bonestorm_RDY = false
					_BoneShield_COUNT = _BoneShield_COUNT - 5
					_Queue = _Queue + 1
					break
				end

				if _DeathStrike_RDY and _RunicPower >= 75 or _Coagulopathy_DUR <= 1.5 then
					tinsert(ConRO.SuggestedSpells, _DeathStrike)
					_RunicPower = _RunicPower - death_strike_COST
					_Coagulopathy_DUR = 8
					_Queue = _Queue + 1
					break
				end

				if _HeartStrike_RDY and _Runes >= 1 and (infliction_of_sorrow_BUFF or ConRO:IsOverride(_HeartStrike) == Ability.VampiricStrike.spellID) then
					tinsert(ConRO.SuggestedSpells, _HeartStrike)
					infliction_of_sorrow_BUFF = false
					_Runes = _Runes - 1
					_RunicPower = _RunicPower + 10
					_Queue = _Queue + 1
					break
				end

				if _Consumption_RDY and _Runes <= 4 then
					tinsert(ConRO.SuggestedSpells, _Consumption)
					_Consumption_RDY = false
					_Runes = _Runes + 2
					_RunicPower = _RunicPower + 20
					_Queue = _Queue + 1
					break
				end

				if _BloodBoil_RDY and _enemies_in_10yrds >= 1 and (_BloodBoil_CHARGES >= 2 or (_BloodBoil_CHARGES >= 1 and not blood_plague_SPREAD)) then
					tinsert(ConRO.SuggestedSpells, _BloodBoil)
					blood_plague_SPREAD = true
					_BloodBoil_CHARGES = _BloodBoil_CHARGES - 1
					_Queue = _Queue + 1
					break
				end

				if _HeartStrike_RDY and _Runes > 3 then
					tinsert(ConRO.SuggestedSpells, _HeartStrike)
					_Runes = _Runes - 1
					_RunicPower = _RunicPower + 10
					_Queue = _Queue + 1
					break
				end
			end

			tinsert(ConRO.SuggestedSpells, 6603) --Waiting Spell Icon
			_Queue = _Queue + 3
			break
		end
	until _Queue >= 3
	return nil
end

function ConRO.DeathKnight.BloodDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells)
	ConRO:Stats()

--Abilities
	local _DeathPact, _DeathPact_RDY = ConRO:AbilityReady(Ability.DeathPact, timeShift)
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift)
	local _IceboundFortitude, _IceboundFortitude_RDY = ConRO:AbilityReady(Ability.IceboundFortitude, timeShift)
	local _Lichborne, _Lichborne_RDY = ConRO:AbilityReady(Ability.Lichborne, timeShift)
	local _RuneTap, _RuneTap_RDY = ConRO:AbilityReady(Ability.RuneTap, timeShift)
		local _RuneTap_BUFF	= ConRO:Aura(Buff.RuneTap, timeShift)
	local _SacrificialPact, _SacrificialPact_RDY = ConRO:AbilityReady(Ability.SacrificialPact, timeShift)
	local _VampiricBlood, _VampiricBlood_RDY = ConRO:AbilityReady(Ability.VampiricBlood, timeShift)

--Conditions

--Rotations
	if _DeathStrike_RDY and _Player_Percent_Health <= 40 then
		tinsert(ConRO.SuggestedDefSpells, _DeathStrike)
	end

	if _Lichborne_RDY and _Player_Percent_Health <= 40 then
		tinsert(ConRO.SuggestedDefSpells, _Lichborne)
	end

	if _DeathPact_RDY and _Player_Percent_Health <= 50 then
		tinsert(ConRO.SuggestedDefSpells, _DeathPact)
	end

	if _VampiricBlood_RDY and _Player_Percent_Health <= 50 then
		tinsert(ConRO.SuggestedDefSpells, _VampiricBlood)
	end

	if _SacrificialPact_RDY and _Player_Percent_Health <= 70 then
		tinsert(ConRO.SuggestedDefSpells, _SacrificialPact)
	end

	if _RuneTap_RDY and not _RuneTap_BUFF then
		tinsert(ConRO.SuggestedDefSpells, _RuneTap)
	end

	if _IceboundFortitude_RDY then
		tinsert(ConRO.SuggestedDefSpells, _IceboundFortitude)
	end

	return nil
end

function ConRO.DeathKnight.Frost(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();

--Abilities
	local _Asphyxiate, _Asphyxiate_RDY = ConRO:AbilityReady(Ability.Asphyxiate, timeShift);
	local _BreathofSindragosa, _BreathofSindragosa_RDY, _BreathofSindragosa_CD = ConRO:AbilityReady(Ability.BreathofSindragosa, timeShift);
		local _BreathofSindragosa_FORM = ConRO:Form(Buff.BreathofSindragosa);
	local _ChainsofIce, _ChainsofIce_RDY = ConRO:AbilityReady(Ability.ChainsofIce, timeShift);
		local _, _ColdHeart_COUNT = ConRO:Form(Buff.ColdHeart);
	local _DeathandDecay, _DeathandDecay_RDY = ConRO:AbilityReady(Ability.DeathandDecay, timeShift);
		local _DeathandDecay_BUFF = ConRO:Aura(Buff.DeathandDecay, timeShift);
		local _DeathandDecay_CHARGES = ConRO:SpellCharges(_DeathandDecay);
	local _DeathGrip, _DeathGrip_RDY = ConRO:AbilityReady(Ability.DeathGrip, timeShift);
	local _DeathsAdvance, _DeathsAdvance_RDY = ConRO:AbilityReady(Ability.DeathsAdvance, timeShift);
	local _EmpowerRuneWeapon, _EmpowerRuneWeapon_RDY = ConRO:AbilityReady(Ability.EmpowerRuneWeapon, timeShift);
		local empower_rune_weapon_CHARGES, _, empower_rune_weapon_CCD = ConRO:SpellCharges(_EmpowerRuneWeapon);
	local _Frostscythe, _Frostscythe_RDY = ConRO:AbilityReady(Ability.Frostscythe, timeShift);
	local _FrostStrike, _FrostStrike_RDY = ConRO:AbilityReady(Ability.FrostStrike, timeShift);
	local frost_strike_SB, frost_strike_SB_RDY = ConRO:AbilityReady(Ability.FrostStrike, timeShift);
		local _, _, _IcyTalons_DUR = ConRO:Aura(Buff.IcyTalons, timeShift);
	local _FrostwyrmsFury, _FrostwyrmsFury_RDY, _FrostwyrmsFury_CD = ConRO:AbilityReady(Ability.FrostwyrmsFury, timeShift);
	local glacial_advance, glacial_advance_RDY = ConRO:AbilityReady(Ability.glacial_advance, timeShift);
	local _HowlingBlast, _HowlingBlast_RDY = ConRO:AbilityReady(Ability.HowlingBlast, timeShift);
		local _FrostFever_DEBUFF = ConRO:TargetAura(Debuff.FrostFever, timeShift);
		local _Rime_BUFF = ConRO:Aura(Buff.Rime, timeShift);
	local _MindFreeze, _MindFreeze_RDY = ConRO:AbilityReady(Ability.MindFreeze, timeShift);
	local _Obliterate, _Obliterate_RDY = ConRO:AbilityReady(Ability.Obliterate, timeShift);
		local obliterate_COST = 2;
		local _KillingMachine_BUFF, _KillingMachine_COUNT = ConRO:Aura(Buff.KillingMachine, timeShift);
	local _PillarofFrost, _PillarofFrost_RDY, _PillarofFrost_CD = ConRO:AbilityReady(Ability.PillarofFrost, timeShift);
		local _PillarofFrost_BUFF, _, _PillarofFrost_DUR = ConRO:Aura(Buff.PillarofFrost, timeShift);
		local _PillarofFrost_THRESHOLD = 45;
	local _RaiseDead, _RaiseDead_RDY = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _ReapersMark, _ReapersMark_RDY, _ReapersMark_CD = ConRO:AbilityReady(Ability.ReapersMark, timeShift);
	local _RemorselessWinter, _RemorselessWinter_RDY = ConRO:AbilityReady(Ability.RemorselessWinter, timeShift);
	local _WraithWalk, _WraithWalk_RDY = ConRO:AbilityReady(Ability.WraithWalk, timeShift);

--Auras
	local exterminate_BUFF = ConRO:Aura(Buff.exterminate, timeShift)
	local _, razor_ice_COUNT = ConRO:TargetAura(Debuff.razor_ice, timeShift)
	local reaper_of_souls_BUFF = ConRO:Aura(Buff.reaper_of_souls, timeShift)
	local _UnholyStrength_BUFF = ConRO:Aura(Buff.UnholyStrength, timeShift)

--Conditions
	local no_razor_ice = true

	if ConRO:HasEnchant(Runeforge.rune_of_razorice) or tChosen[Ability.Avalanche.talentID] or tChosen[Ability.ArcticAssault.talentID] then
		no_razor_ice = false
	end

	if exterminate_BUFF then
		obliterate_COST = 1;
	end

	if ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) then
		_Obliterate, _Obliterate_RDY = _Frostscythe, _Frostscythe_RDY
		_FrostStrike, _FrostStrike_RDY = glacial_advance, glacial_advance_RDY
	end

--Indicators
	ConRO:AbilityInterrupt(_Asphyxiate, _Asphyxiate_RDY and (ConRO:Interrupt() and not _MindFreeze_RDY and _is_PC and _is_Enemy));
	ConRO:AbilityInterrupt(_MindFreeze, _MindFreeze_RDY and ConRO:Interrupt());

	ConRO:AbilityMovement(_DeathGrip, _DeathGrip_RDY and _is_Enemy and ConRO:IsSpellInRange(Ability.DeathGrip) and not _target_in_melee);
	ConRO:AbilityMovement(_DeathsAdvance, _DeathsAdvance_RDY and not _target_in_melee);
	ConRO:AbilityMovement(_WraithWalk, _WraithWalk_RDY and not _target_in_melee);

	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());

	ConRO:AbilityBurst(_BreathofSindragosa, _BreathofSindragosa_RDY and _RunicPower >= 60 and _PillarofFrost_RDY and ConRO:BurstMode(_BreathofSindragosa))
	ConRO:AbilityBurst(_FrostwyrmsFury, _FrostwyrmsFury_RDY and ((ConRO:HeroSpec(HeroSpec.RideroftheApocalypse) and _PillarofFrost_BUFF) or (_PillarofFrost_BUFF and _UnholyStrength_BUFF) or _PillarofFrost_DUR <= 5) and ConRO:BurstMode(_FrostwyrmsFury))
	ConRO:AbilityBurst(_PillarofFrost, _PillarofFrost_RDY and (not tChosen[Ability.BreathofSindragosa.talentID] or (tChosen[Ability.BreathofSindragosa.talentID] and ((_BreathofSindragosa_CD >= _PillarofFrost_THRESHOLD) or _BreathofSindragosa_FORM))) and ConRO:BurstMode(_PillarofFrost))
	ConRO:AbilityBurst(_RaiseDead, _RaiseDead_RDY and not _Pet_summoned and _PillarofFrost_BUFF)

--Rotations
	repeat
		while(true) do
			if not _in_combat then
				if _RemorselessWinter_RDY and _Runes >= 1 and not tChosen[Ability.FrozenDominion.talentID] then
					tinsert(ConRO.SuggestedSpells, _RemorselessWinter)
					_RemorselessWinter_RDY = false
					_Runes = _Runes - 1
					_RunicPower = _RunicPower + 10
					_Queue = _Queue + 1
					break
				end

				if _Obliterate_RDY and _Runes >= obliterate_COST then
					tinsert(ConRO.SuggestedSpells, _Obliterate)
					_KillingMachine_COUNT = _KillingMachine_COUNT - 1
					_Runes = _Runes - obliterate_COST
					_RunicPower = _RunicPower + (10 * obliterate_COST)
					_Queue = _Queue + 1
					break
				end

				if _EmpowerRuneWeapon_RDY and _RunicPower <= 60 then
					tinsert(ConRO.SuggestedSpells, _EmpowerRuneWeapon)
					_EmpowerRuneWeapon_RDY = false
					empower_rune_weapon_CHARGES = empower_rune_weapon_CHARGES - 1
					_RunicPower = _RunicPower + 40
					_Queue = _Queue + 1
					break
				end
			end

			if _RemorselessWinter_RDY and _Runes >= 1 and not tChosen[Ability.FrozenDominion.talentID] and (tChosen[Ability.GatheringStorm.talentID] or ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible())) then
				tinsert(ConRO.SuggestedSpells, _RemorselessWinter)
				_RemorselessWinter_RDY = false
				_Runes = _Runes - 1
				_RunicPower = _RunicPower + 10
				_Queue = _Queue + 1
				break
			end

			if _EmpowerRuneWeapon_RDY and (empower_rune_weapon_CHARGES >= 2 or (empower_rune_weapon_CHARGES >= 1 and empower_rune_weapon_CCD < 5)) then
				tinsert(ConRO.SuggestedSpells, _EmpowerRuneWeapon)
				_EmpowerRuneWeapon_RDY = false
				empower_rune_weapon_CHARGES = empower_rune_weapon_CHARGES - 1
				_RunicPower = _RunicPower + 40
				_Queue = _Queue + 1
				break
			end

			if _PillarofFrost_RDY and ConRO:FullMode(_PillarofFrost) then
				tinsert(ConRO.SuggestedSpells, _PillarofFrost)
				_PillarofFrost_RDY = false
				_PillarofFrost_BUFF = true
				_Queue = _Queue + 1
				break
			end

			if _ReapersMark_RDY and _Runes >= 2 and _PillarofFrost_BUFF and ConRO:HeroSpec(HeroSpec.Deathbringer) then
				tinsert(ConRO.SuggestedSpells, _ReapersMark)
				_ReapersMark_RDY = false
				_Runes = _Runes - 2
				_RunicPower = _RunicPower + 20
				_Queue = _Queue + 1
				break
			end

			if _BreathofSindragosa_RDY and _RunicPower >= 60 and _PillarofFrost_BUFF and ConRO:FullMode(_BreathofSindragosa) then
				tinsert(ConRO.SuggestedSpells, _BreathofSindragosa)
				_BreathofSindragosa_RDY = false
				_KillingMachine_COUNT = _KillingMachine_COUNT - 1
				_Queue = _Queue + 1
				break
			end

			if _FrostwyrmsFury_RDY and ((ConRO:HeroSpec(HeroSpec.RideroftheApocalypse) and _PillarofFrost_BUFF) or (_PillarofFrost_BUFF and _UnholyStrength_BUFF) or (_PillarofFrost_BUFF and _PillarofFrost_DUR <= 3)) and ConRO:FullMode(_FrostwyrmsFury) then
				tinsert(ConRO.SuggestedSpells, _FrostwyrmsFury)
				_FrostwyrmsFury_RDY = false
				_Queue = _Queue + 1
				break
			end

			if _Obliterate_RDY and _Runes >= obliterate_COST and (_KillingMachine_COUNT >= 2 or (_KillingMachine_COUNT >= 1 and _Runes >= 3)) then
				tinsert(ConRO.SuggestedSpells, _Obliterate)
				_KillingMachine_COUNT = _KillingMachine_COUNT - 1
				_Runes = _Runes - obliterate_COST
				_RunicPower = _RunicPower + (10 * obliterate_COST)
				_Queue = _Queue + 1
				break
			end

			if _HowlingBlast_RDY and _Rime_BUFF then
				tinsert(ConRO.SuggestedSpells, _HowlingBlast)
				_FrostFever_DEBUFF = true
				_Rime_BUFF = false
				_Queue = _Queue + 1
				break
			end

			if frost_strike_SB_RDY and _RunicPower >= 35 and razor_ice_COUNT >= 5 and tChosen[Ability.ShatteringBlade.talentID] then
				tinsert(ConRO.SuggestedSpells, frost_strike_SB)
				_RunicPower = _RunicPower - 35
				_IcyTalons_DUR = 10
				razor_ice_COUNT = 0
				_Queue = _Queue + 1
				break
			end

			if _FrostStrike_RDY and _RunicPower >= 35 and not tChosen[Ability.ShatteringBlade.talentID] and tChosen[Ability.BreathofSindragosa.talentID] and _BreathofSindragosa_CD >= 3 then
				tinsert(ConRO.SuggestedSpells, _FrostStrike)
				_RunicPower = _RunicPower - 35
				_IcyTalons_DUR = 10
				razor_ice_COUNT = 0
				_Queue = _Queue + 1
				break
			end

			if _Obliterate_RDY and _Runes >= obliterate_COST and (_KillingMachine_COUNT >= 1 and (not _ReapersMark_RDY or _ReapersMark_CD >= 5) or (_KillingMachine_COUNT == 0 and not tChosen[Ability.Obliteration.talentID])) then
				tinsert(ConRO.SuggestedSpells, _Obliterate)
				_KillingMachine_COUNT = _KillingMachine_COUNT - 1
				_Runes = _Runes - obliterate_COST
				_RunicPower = _RunicPower + (10 * obliterate_COST)
				_Queue = _Queue + 1
				break
			end

			if _EmpowerRuneWeapon_RDY and empower_rune_weapon_CHARGES >= 1 and _RunicPower < 60 then
				tinsert(ConRO.SuggestedSpells, _EmpowerRuneWeapon)
				_EmpowerRuneWeapon_RDY = false
				empower_rune_weapon_CHARGES = empower_rune_weapon_CHARGES - 1
				_RunicPower = _RunicPower + 40
				_Queue = _Queue + 1
				break
			end

			if _Obliterate_RDY and _Runes >= obliterate_COST and tChosen[Ability.Obliteration.talentID] and _KillingMachine_COUNT == 0 and not _PillarofFrost_BUFF then
				tinsert(ConRO.SuggestedSpells, _Obliterate)
				_KillingMachine_COUNT = _KillingMachine_COUNT - 1
				_Runes = _Runes - obliterate_COST
				_RunicPower = _RunicPower + (10 * obliterate_COST)
				_Queue = _Queue + 1
				break
			end

			if _HowlingBlast_RDY and _Runes >= 1 and not _PillarofFrost_BUFF then
				tinsert(ConRO.SuggestedSpells, _HowlingBlast)
				_FrostFever_DEBUFF = true
				_Runes = _Runes - 1
				_Queue = _Queue + 1
				break
			end

			tinsert(ConRO.SuggestedSpells, 6603); --Waiting Spell Icon
			_Queue = _Queue + 3
			break;
		end
	until _Queue >= 3
	return nil
end

function ConRO.DeathKnight.FrostDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();

--Abilities
	local _DeathPact, _DeathPact_RDY = ConRO:AbilityReady(Ability.DeathPact, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _DarkSuccor_BUFF = ConRO:Aura(Buff.DarkSuccor, timeShift);
	local _IceboundFortitude, _IceboundFortitude_RDY = ConRO:AbilityReady(Ability.IceboundFortitude, timeShift);
	local _Lichborne, _Lichborne_RDY = ConRO:AbilityReady(Ability.Lichborne, timeShift);
	local _RaiseDead, _RaiseDead_RDY, _RaiseDead_CD = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _SacrificialPact, _SacrificialPact_RDY = ConRO:AbilityReady(Ability.SacrificialPact, timeShift);

--Conditions

--Rotations
	if _DeathStrike_RDY and ((_DarkSuccor_BUFF and _Player_Percent_Health <= 80) or _Player_Percent_Health <= 30) then
		tinsert(ConRO.SuggestedDefSpells, _DeathStrike);
	end

	if _Lichborne_RDY and _Player_Percent_Health <= 40 then
		tinsert(ConRO.SuggestedDefSpells, _Lichborne);
	end

	if _DeathPact_RDY and _Player_Percent_Health <= 50 then
		tinsert(ConRO.SuggestedDefSpells, _DeathPact);
	end

	if _RaiseDead_RDY and _Player_Percent_Health <= 50 and tChosen[Ability.SacrificialPact.talentID] then
		tinsert(ConRO.SuggestedDefSpells, _RaiseDead);
	end

	if _SacrificialPact_RDY and _Player_Percent_Health <= 70 then
		tinsert(ConRO.SuggestedDefSpells, _SacrificialPact);
	end

	if _IceboundFortitude_RDY then
		tinsert(ConRO.SuggestedDefSpells, _IceboundFortitude);
	end

return nil;
end

function ConRO.DeathKnight.Unholy(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();

--Abilities
	local _Apocalypse, _Apocalypse_RDY, _Apocalypse_CD, _Apocalypse_MaxCD = ConRO:AbilityReady(Ability.Apocalypse, timeShift);
	local _ArmyoftheDead, _ArmyoftheDead_RDY, _ArmyoftheDead_CD = ConRO:AbilityReady(Ability.ArmyoftheDead, timeShift);
	local _Asphyxiate, _Asphyxiate_RDY = ConRO:AbilityReady(Ability.Asphyxiate, timeShift);
	local _ClawingShadows, _ClawingShadows_RDY = ConRO:AbilityReady(Ability.ClawingShadows, timeShift);
	local _DarkTransformation, _DarkTransformation_RDY, _DarkTransformation_CD = ConRO:AbilityReady(Ability.DarkTransformation, timeShift);
		local _GiftoftheSanlayn_BUFF = ConRO:Aura(Buff.GiftoftheSanlayn, timeShift);
		local _DarkTransformation_BUFF = ConRO:UnitAura(Buff.DarkTransformation, timeShift, "pet");
	local _DeathandDecay, _DeathandDecay_RDY = ConRO:AbilityReady(Ability.DeathandDecay, timeShift);
		local _DeathandDecay_BUFF = ConRO:Aura(Buff.DeathandDecay, timeShift);
	local _DeathCoil, _DeathCoil_RDY = ConRO:AbilityReady(Ability.DeathCoil, timeShift);
		local _, _, _DeathRot_DUR = ConRO:TargetAura(Debuff.DeathRot, timeShift);
		local _SuddenDoom_BUFF = ConRO:Aura(Buff.SuddenDoom, timeShift);
		local _RottenTouch_DEBUFF = ConRO:TargetAura(Debuff.RottenTouch, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _DarkSuccor_BUFF = ConRO:Aura(Buff.DarkSuccor, timeShift);
	local _DeathsAdvance, _DeathsAdvance_RDY = ConRO:AbilityReady(Ability.DeathsAdvance, timeShift);
	local _Defile, _Defile_RDY = ConRO:AbilityReady(Ability.Defile, timeShift);
	local _Epidemic, _Epidemic_RDY = ConRO:AbilityReady(Ability.Epidemic, timeShift);
	local _FesteringStrike, _FesteringStrike_RDY = ConRO:AbilityReady(Ability.FesteringStrike, timeShift);
		local _FesteringScythe, _FesteringScythe_RDY = ConRO:AbilityReady(Ability.FesteringScythe, timeShift);
		local _FesteringWound_DEBUFF, _FesteringWound_COUNT = ConRO:TargetAura(Debuff.FesteringWound, timeShift);
	local legion_of_souls, legion_of_souls_RDY = ConRO:AbilityReady(Ability.legion_of_souls, timeShift);
	local _MindFreeze, _MindFreeze_RDY = ConRO:AbilityReady(Ability.MindFreeze, timeShift);
	local _Outbreak, _Outbreak_RDY = ConRO:AbilityReady(Ability.Outbreak, timeShift);
		local _VirulentPlague_DEBUFF = ConRO:TargetAura(Debuff.VirulentPlague, timeShift);
	local _RaiseAbomination, _RaiseAbomination_RDY, _RaiseAbomination_CD = ConRO:AbilityReady(Ability.RaiseAbomination, timeShift);
	local _RaiseDead, _RaiseDead_RDY = ConRO:AbilityReady(Ability.RaiseDead, timeShift);
	local _RaiseDeadUnholy, _RaiseDeadUnholy_RDY = ConRO:AbilityReady(Ability.RaiseDeadUnholy, timeShift);
	local _ScourgeStrike, _ScourgeStrike_RDY = ConRO:AbilityReady(Ability.ScourgeStrike, timeShift);
		local _VampiricStrike, _VampiricStrike_RDY = ConRO:AbilityReady(Ability.VampiricStrike, timeShift);
		local _Plaguebringer_BUFF = ConRO:Aura(Buff.Plaguebringer, timeShift);
		local _InflictionofSorrow_BUFF = ConRO:Aura(Buff.InflictionofSorrow, timeShift);
		local _TrollbanesIcyFury_DEBUFF = ConRO:TargetAura(Debuff.TrollbanesIcyFury, timeShift);
	local _SoulReaper, _SoulReaper_RDY = ConRO:AbilityReady(Ability.SoulReaper, timeShift);
	local _SummonGargoyle, _SummonGargoyle_RDY, _SummonGargoyle_CD = ConRO:AbilityReady(Ability.SummonGargoyle, timeShift);
	local _UnholyAssault, _UnholyAssault_RDY = ConRO:AbilityReady(Ability.UnholyAssault, timeShift);
		local _UnholyBlight_DEBUFF = ConRO:TargetAura(Debuff.UnholyBlight, timeShift);
	local _VileContagion, _VileContagion_RDY = ConRO:AbilityReady(Ability.VileContagion, timeShift);
	local _WraithWalk, _WraithWalk_RDY = ConRO:AbilityReady(Ability.WraithWalk, timeShift);

--Conditions
	local _Ghoul_out = IsSpellKnown(Pet_Ability.Claw, true)

	if tChosen[Ability.Defile.talentID] then
		_DeathandDecay, _DeathandDecay_RDY = _Defile, _Defile_RDY
	end

	if tChosen[Ability.legion_of_souls.talentID] then
		_ArmyoftheDead, _ArmyoftheDead_RDY = legion_of_souls, legion_of_souls_RDY
	end

	if tChosen[Ability.RaiseDeadUnholy.talentID] then
		_RaiseDead, _RaiseDead_RDY = _RaiseDeadUnholy, _RaiseDeadUnholy_RDY
	end

--Indicators
	ConRO:AbilityInterrupt(_MindFreeze, _MindFreeze_RDY and ConRO:Interrupt());
	ConRO:AbilityInterrupt(_Asphyxiate, _Asphyxiate_RDY and (ConRO:Interrupt() and not _MindFreeze_RDY and _is_PC and _is_Enemy));
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());
	ConRO:AbilityMovement(_DeathsAdvance, _DeathsAdvance_RDY and not _target_in_melee);
	ConRO:AbilityMovement(_WraithWalk, _WraithWalk_RDY and not _target_in_melee);

	ConRO:AbilityBurst(_Apocalypse, _in_combat and _Apocalypse_RDY and _FesteringWound_COUNT >= 4 and ConRO:BurstMode(_Apocalypse));
	ConRO:AbilityBurst(_ArmyoftheDead, _ArmyoftheDead_RDY and not tChosen[Ability.RaiseAbomination.talentID] and ConRO:BurstMode(_ArmyoftheDead));
	ConRO:AbilityBurst(_DarkTransformation, _in_combat and _DarkTransformation_RDY and _Ghoul_out and not tChosen[Ability.Apocalypse.talentID] and ConRO:BurstMode(_DarkTransformation));
	ConRO:AbilityBurst(_SummonGargoyle, _SummonGargoyle_RDY and _RunicPower >= 90 and _SuddenDoom_BUFF and ConRO:BurstMode(_SummonGargoyle));
	ConRO:AbilityBurst(_UnholyAssault, _in_combat and _UnholyAssault_RDY and _FesteringWound_COUNT < 3 and ConRO:BurstMode(_UnholyAssault));


--Warnings
	ConRO:Warnings("Call your ghoul!", _RaiseDead_RDY and not _Pet_summoned);

--Rotations
	repeat
		while(true) do
			if not _in_combat then
				if _ArmyoftheDead_RDY and not tChosen[Ability.RaiseAbomination.talentID] and ConRO:FullMode(_ArmyoftheDead) then
					tinsert(ConRO.SuggestedSpells, _ArmyoftheDead);
					_ArmyoftheDead_RDY = false;
					_Runes = _Runes - 1;
					_Queue = _Queue + 1;
					break;
				end

				if _RaiseAbomination_RDY and tChosen[Ability.RaiseAbomination.talentID] and ConRO:FullMode(_RaiseAbomination) then
					tinsert(ConRO.SuggestedSpells, _RaiseAbomination);
					_RaiseAbomination_RDY = false;
					_Runes = _Runes - 1;
					_Queue = _Queue + 1;
					break;
				end

				if _FesteringStrike_RDY and _Runes >= 2 then
					tinsert(ConRO.SuggestedSpells, _FesteringStrike);
					_Runes = _Runes - 2;
					_FesteringWound_COUNT = _FesteringWound_COUNT + 2;
					_Queue = _Queue + 1;
					break;
				end
			end

			if ((ConRO_AutoButton:IsVisible() and _enemies_in_melee >= 3) or ConRO_AoEButton:IsVisible()) then
				if _GiftoftheSanlayn_BUFF then
					if _FesteringScythe_RDY and ConRO:IsOverride(_FesteringStrike) == _FesteringScythe and _Runes >= 2 then
						tinsert(ConRO.SuggestedSpells, _FesteringScythe);
						_Runes = _Runes - 2;
						_FesteringWound_COUNT = _FesteringWound_COUNT + 2;
						_Queue = _Queue + 1;
						break;
					end

					if _Epidemic_RDY and (_SuddenDoom_BUFF or (_RunicPower >= 30 and _Runes < 2)) then
						tinsert(ConRO.SuggestedSpells, _Epidemic);
						_SuddenDoom_BUFF = false;
						_Queue = _Queue + 1;
						break;
					end

					if _VampiricStrike_RDY and _Runes >= 1 then
						tinsert(ConRO.SuggestedSpells, _VampiricStrike);
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _Epidemic_RDY and _RunicPower >= 30 then
						tinsert(ConRO.SuggestedSpells, _Epidemic);
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end
				elseif _DeathandDecay_BUFF then
					if _DarkTransformation_RDY and _Ghoul_out and not tChosen[Ability.Apocalypse.talentID] and ConRO:HeroSpec(HeroSpec.Sanlayn) and ConRO:FullMode(_DarkTransformation) then
						tinsert(ConRO.SuggestedSpells, _DarkTransformation);
						_DarkTransformation_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if _ScourgeStrike_RDY and not tChosen[Ability.ClawingShadows.talentID] and _Runes >= 1 and _FesteringWound_COUNT >= 1 and not _Plaguebringer_BUFF then
						tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
						_Plaguebringer_BUFF = true;
						_Runes = _Runes - 1;
						_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _Outbreak_RDY and _Runes >= 1 and not _VirulentPlague_DEBUFF then
						tinsert(ConRO.SuggestedSpells, _Outbreak);
						_VirulentPlague_DEBUFF = true;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _FesteringScythe_RDY and ConRO:IsOverride(_FesteringStrike) == _FesteringScythe and _Runes >= 2 then
						tinsert(ConRO.SuggestedSpells, _FesteringScythe);
						_Runes = _Runes - 2;
						_FesteringWound_COUNT = _FesteringWound_COUNT + 2;
						_Queue = _Queue + 1;
						break;
					end

					if _Epidemic_RDY and _SuddenDoom_BUFF then
						tinsert(ConRO.SuggestedSpells, _Epidemic);
						_SuddenDoom_BUFF = false;
						_Queue = _Queue + 1;
						break;
					end

					if _Runes >= 1 and _FesteringWound_COUNT >= 1 then
						if tChosen[Ability.ClawingShadows.talentID] then
							if _ClawingShadows_RDY then
								tinsert(ConRO.SuggestedSpells, _ClawingShadows);
								_Runes = _Runes - 1;
								_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
								_Queue = _Queue + 1;
								break;
							end
						else
							if _ScourgeStrike_RDY then
								tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
								_Runes = _Runes - 1;
								_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
								_Queue = _Queue + 1;
								break;
							end
						end
					end

					if _Epidemic_RDY and _RunicPower >= 30 then
						tinsert(ConRO.SuggestedSpells, _Epidemic);
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end

					if _Runes >= 1 then
						if tChosen[Ability.ClawingShadows.talentID] then
							if _ClawingShadows_RDY then
								tinsert(ConRO.SuggestedSpells, _ClawingShadows);
								_Runes = _Runes - 1;
								_Queue = _Queue + 1;
								break;
							end
						else
							if _ScourgeStrike_RDY then
								tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
								_Runes = _Runes - 1;
								_Queue = _Queue + 1;
								break;
							end
						end
					end
				else
					if _ScourgeStrike_RDY and not tChosen[Ability.ClawingShadows.talentID] and _Runes >= 1 and (not _Plaguebringer_BUFF or _TrollbanesIcyFury_DEBUFF) then
						tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
						_Plaguebringer_BUFF = true;
						_Runes = _Runes - 1;
						_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _FesteringScythe_RDY and ConRO:IsOverride(_FesteringStrike) == _FesteringScythe and _Runes >= 2 then
						tinsert(ConRO.SuggestedSpells, _FesteringScythe);
						_Runes = _Runes - 2;
						_FesteringWound_COUNT = _FesteringWound_COUNT + 2;
						_Queue = _Queue + 1;
						break;
					end

					if _ArmyoftheDead_RDY and not tChosen[Ability.RaiseAbomination.talentID] and ConRO:FullMode(_ArmyoftheDead) then
						tinsert(ConRO.SuggestedSpells, _ArmyoftheDead);
						_ArmyoftheDead_RDY = false;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _RaiseAbomination_RDY and tChosen[Ability.RaiseAbomination.talentID] and ConRO:FullMode(_RaiseAbomination) then
						tinsert(ConRO.SuggestedSpells, _RaiseAbomination);
						_RaiseAbomination_RDY = false;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _Apocalypse_RDY and _FesteringWound_COUNT >= 4 and _Runes < 3 and ConRO:FullMode(_Apocalypse) then
						tinsert(ConRO.SuggestedSpells, _Apocalypse);
						_Apocalypse_RDY = false;
						_FesteringWound_COUNT = _FesteringWound_COUNT - 4;
						_Queue = _Queue + 1;
						break;
					end

					if _DarkTransformation_RDY and _Ghoul_out and not tChosen[Ability.Apocalypse.talentID] and ConRO:FullMode(_DarkTransformation) then
						tinsert(ConRO.SuggestedSpells, _DarkTransformation);
						_DarkTransformation_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if _SummonGargoyle_RDY and _RunicPower >= _RunicPower_Max - 50 and ConRO:FullMode(_SummonGargoyle) then
						tinsert(ConRO.SuggestedSpells, _SummonGargoyle);
						_SummonGargoyle_RDY = false;
						_RunicPower = _RunicPower + 50;
						_Queue = _Queue + 1;
						break;
					end

					if _Epidemic_RDY and _SuddenDoom_BUFF then
						tinsert(ConRO.SuggestedSpells, _Epidemic);
						_SuddenDoom_BUFF = false;
						_Queue = _Queue + 1;
						break;
					end

					if _FesteringStrike_RDY and _Runes >= 2 and _FesteringWound_COUNT <= 2 then
						tinsert(ConRO.SuggestedSpells, _FesteringStrike);
						_Runes = _Runes - 2;
						_FesteringWound_COUNT = _FesteringWound_COUNT + 2;
						_Queue = _Queue + 1;
						break;
					end

					if _UnholyAssault_RDY and _FesteringWound_COUNT <= 2 and ConRO:FullMode(_UnholyAssault) then
						tinsert(ConRO.SuggestedSpells, _UnholyAssault);
						_UnholyAssault_RDY = false;
						_FesteringWound_COUNT = _FesteringWound_COUNT + 4;
						_Queue = _Queue + 1;
						break;
					end

					if _VileContagion_RDY and _FesteringWound_COUNT >= 6 and ConRO:FullMode(_VileContagion) then
						tinsert(ConRO.SuggestedSpells, _VileContagion);
						_VileContagion_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if _Epidemic_RDY and _RunicPower >= 30 and _Runes < 2 then
						tinsert(ConRO.SuggestedSpells, _Epidemic);
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end

					if _DeathandDecay_RDY and not _DeathandDecay_BUFF and _Runes >= 1 then
						tinsert(ConRO.SuggestedSpells, _DeathandDecay);
						_DeathandDecay_BUFF = true;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _Epidemic_RDY and _RunicPower >= 30 then
						tinsert(ConRO.SuggestedSpells, _Epidemic);
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end
				end
			else
				if _GiftoftheSanlayn_BUFF then
					if _DeathCoil_RDY and ((_RunicPower > 30 and _Runes <= 2) or _SuddenDoom_BUFF) then
						tinsert(ConRO.SuggestedSpells, _DeathCoil);
						_SuddenDoom_BUFF = false;
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end

					if _VampiricStrike_RDY and _Runes >= 1 then
						tinsert(ConRO.SuggestedSpells, _VampiricStrike);
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _DeathCoil_RDY and _RunicPower > 30 then
						tinsert(ConRO.SuggestedSpells, _DeathCoil);
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end
				else
					if _ArmyoftheDead_RDY and not tChosen[Ability.RaiseAbomination.talentID] and ConRO:FullMode(_ArmyoftheDead) then
						tinsert(ConRO.SuggestedSpells, _ArmyoftheDead);
						_ArmyoftheDead_RDY = false;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _RaiseAbomination_RDY and tChosen[Ability.RaiseAbomination.talentID] and ConRO:FullMode(_RaiseAbomination) then
						tinsert(ConRO.SuggestedSpells, _RaiseAbomination);
						_RaiseAbomination_RDY = false;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _DeathandDecay_RDY and not _DeathandDecay_BUFF and _Runes >= 1 and ConRO:HeroSpec(HeroSpec.Sanlayn) then
						tinsert(ConRO.SuggestedSpells, _DeathandDecay);
						_DeathandDecay_BUFF = true;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if ConRO:HeroSpec(HeroSpec.Sanlayn) then
						if _FesteringStrike_RDY and _Runes >= 2 and _FesteringWound_COUNT <= 3 and (_Apocalypse_RDY or _Apocalypse_CD <= 3) then
							tinsert(ConRO.SuggestedSpells, _FesteringStrike);
							_Runes = _Runes - 2;
							_FesteringWound_COUNT = _FesteringWound_COUNT + 2;
							_Queue = _Queue + 1;
							break;
						end

						if _Apocalypse_RDY and _FesteringWound_COUNT >= 4 and ConRO:FullMode(_Apocalypse) then
							tinsert(ConRO.SuggestedSpells, _Apocalypse);
							_Apocalypse_RDY = false;
							_FesteringWound_COUNT = _FesteringWound_COUNT - 4;
							_Queue = _Queue + 1;
							break;
						end
					end

					if _DarkTransformation_RDY and _Ghoul_out and not tChosen[Ability.Apocalypse.talentID] and ConRO:FullMode(_DarkTransformation) then
						tinsert(ConRO.SuggestedSpells, _DarkTransformation);
						_DarkTransformation_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if _SummonGargoyle_RDY and _RunicPower >= _RunicPower_Max - 50 and ConRO:FullMode(_SummonGargoyle) then
						tinsert(ConRO.SuggestedSpells, _SummonGargoyle);
						_SummonGargoyle_RDY = false;
						_RunicPower = _RunicPower + 50;
						_Queue = _Queue + 1;
						break;
					end

					if _UnholyAssault_RDY and _FesteringWound_COUNT <= 3 and (_Apocalypse_RDY or _Apocalypse_CD >= 30) and ConRO:FullMode(_UnholyAssault) then
						tinsert(ConRO.SuggestedSpells, _UnholyAssault);
						_UnholyAssault_RDY = false;
						_FesteringWound_COUNT = _FesteringWound_COUNT + 4;
						_Queue = _Queue + 1;
						break;
					end

					if _FesteringStrike_RDY and _Runes >= 2 and _FesteringWound_COUNT <= 3 and (_Apocalypse_RDY or _Apocalypse_CD <= 3) then
						tinsert(ConRO.SuggestedSpells, _FesteringStrike);
						_Runes = _Runes - 2;
						_FesteringWound_COUNT = _FesteringWound_COUNT + 2;
						_Queue = _Queue + 1;
						break;
					end

					if _Apocalypse_RDY and _FesteringWound_COUNT >= 4 and ConRO:FullMode(_Apocalypse) then
						tinsert(ConRO.SuggestedSpells, _Apocalypse);
						_Apocalypse_RDY = false;
						_FesteringWound_COUNT = _FesteringWound_COUNT - 4;
						_Queue = _Queue + 1;
						break;
					end

					if _Runes >= 1 and _InflictionofSorrow_BUFF then
						if tChosen[Ability.ClawingShadows.talentID] then
							if _ClawingShadows_RDY then
								tinsert(ConRO.SuggestedSpells, _ClawingShadows);
								_Runes = _Runes - 1;
								_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
								_Queue = _Queue + 1;
								break;
							end
						else
							if _ScourgeStrike_RDY then
								tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
								_Runes = _Runes - 1;
								_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
								_Queue = _Queue + 1;
								break;
							end
						end
						_InflictionofSorrow_BUFF = false;
					end

					if _VampiricStrike_RDY and ConRO:IsOverride(_ScourgeStrike) == _VampiricStrike and _Runes >= 1 then
						tinsert(ConRO.SuggestedSpells, _VampiricStrike);
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _SoulReaper_RDY and _Runes >= 1 and _can_Execute then
						tinsert(ConRO.SuggestedSpells, _SoulReaper);
						_SoulReaper_RDY = false;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _DeathCoil_RDY and (_RunicPower > 80 or _SuddenDoom_BUFF) then
						tinsert(ConRO.SuggestedSpells, _DeathCoil);
						_SuddenDoom_BUFF = false;
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end

					if _Outbreak_RDY and _Runes >= 1 and not _VirulentPlague_DEBUFF then
						tinsert(ConRO.SuggestedSpells, _Outbreak);
						_VirulentPlague_DEBUFF = true;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _ClawingShadows_RDY and tChosen[Ability.ClawingShadows.talentID] and _Runes >= 1 and _FesteringWound_COUNT >= 1 and _RottenTouch_DEBUFF then
						tinsert(ConRO.SuggestedSpells, _ClawingShadows);
						_Runes = _Runes - 1;
						_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _FesteringStrike_RDY and _Runes >= 2 and _FesteringWound_COUNT <= 2 then
						tinsert(ConRO.SuggestedSpells, _FesteringStrike);
						_Runes = _Runes - 2;
						_FesteringWound_COUNT = _FesteringWound_COUNT + 2;
						_Queue = _Queue + 1;
						break;
					end

					if _ScourgeStrike_RDY and not tChosen[Ability.ClawingShadows.talentID] and _Runes >= 1 and _FesteringWound_COUNT >= 1 and not _Plaguebringer_BUFF then
						tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
						_Plaguebringer_BUFF = true;
						_Runes = _Runes - 1;
						_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _Defile_RDY and not _DeathandDecay_BUFF and _Runes >= 1 then
						tinsert(ConRO.SuggestedSpells, _Defile);
						_DeathandDecay_BUFF = true;
						_Runes = _Runes - 1;
						_Queue = _Queue + 1;
						break;
					end

					if _DeathCoil_RDY and (_RunicPower >= 30 or _SuddenDoom_BUFF) and _DeathRot_DUR < 1 then
						tinsert(ConRO.SuggestedSpells, _DeathCoil);
						_SuddenDoom_BUFF = false;
						_DeathRot_DUR = 10;
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end

					if _Runes >= 1 and _FesteringWound_COUNT >= 3 then
						if tChosen[Ability.ClawingShadows.talentID] then
							if _ClawingShadows_RDY then
								tinsert(ConRO.SuggestedSpells, _ClawingShadows);
								_Runes = _Runes - 1;
								_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
								_Queue = _Queue + 1;
								break;
							end
						else
							if _ScourgeStrike_RDY then
								tinsert(ConRO.SuggestedSpells, _ScourgeStrike);
								_Runes = _Runes - 1;
								_FesteringWound_COUNT = _FesteringWound_COUNT - 1;
								_Queue = _Queue + 1;
								break;
							end
						end
					end

					if _DeathCoil_RDY and _RunicPower >= 30 then
						tinsert(ConRO.SuggestedSpells, _DeathCoil);
						_SuddenDoom_BUFF = false;
						_RunicPower = _RunicPower - 30;
						_Queue = _Queue + 1;
						break;
					end
				end
			end

			tinsert(ConRO.SuggestedSpells, 6603); --Waiting Spell Icon
			_Queue = _Queue + 3;
			break;
		end
	until _Queue >= 3;
return nil;
end

function ConRO.DeathKnight.UnholyDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();

--Abilities
	local _DeathCoil, _DeathCoil_RDY = ConRO:AbilityReady(Ability.DeathCoil, timeShift);
	local _DeathPact, _DeathPact_RDY = ConRO:AbilityReady(Ability.DeathPact, timeShift);
	local _DeathStrike, _DeathStrike_RDY = ConRO:AbilityReady(Ability.DeathStrike, timeShift);
		local _DarkSuccor_BUFF = ConRO:Aura(Buff.DarkSuccor, timeShift);
	local _IceboundFortitude, _IceboundFortitude_RDY = ConRO:AbilityReady(Ability.IceboundFortitude, timeShift);
	local _Lichborne, _Lichborne_RDY = ConRO:AbilityReady(Ability.Lichborne, timeShift);
		local _Lichborne_BUFF = ConRO:Aura(Buff.Lichborne, timeShift);
	local _SacrificialPact, _SacrificialPact_RDY = ConRO:AbilityReady(Ability.SacrificialPact, timeShift);

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