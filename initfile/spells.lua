-- SPELLS & MISCASTS

-- take spell name or displayed fail rate and output max possible "damage" from
-- a miscast. Note that "damage" might not be literal damage (it could be turns
-- of slow, e.g.)
function max_miscast_dam(x) -- string -> int
   fail = fail_to_raw_fail(spells.fail(x))
   level = spells.level(x)
   return math.ceil(fail * level * level / 10)
end

-- we call mpr only once each time we print info for a bunch of spells
-- to avoid crawl putting semicolons in everywhere
function _print_max_miscast_dam_array(xs, str) -- table, string -> None (IO)
   for i,x in pairs(xs) do
      str = str .. "\n" .. x .. ": " .. max_miscast_dam(x)
   end
   crawl.mpr(str)
end

function spells_max_miscast_dams() -- None -> None (IO)
   s = "Spells: maximum miscast damages"
   _print_max_miscast_dam_array(you.spells(), s)
end

function library_max_miscast_dams() -- None -> None (IO)
   s = "Library: maximum miscast damages"
   _print_max_miscast_dam_array(you.mem_spells(), s)
end

-- get number of triples of non-negative numbers with sum < n
-- corresponds to _tetrahedral_number in spl-cast.cc
function tet_num(x) -- int -> int
   return x * (x+1) * (x+2) / 6
end

-- takes raw fail and transforms it into a probability to fail
-- (what the player sees in the I screen)
-- corresponds to _get_true_fail_rate in spl-cast.cc
function raw_fail_to_fail(x) -- int -> double
   outcomes = 101 * 101 * 100
   target = x * 3
   if target <= 100 then
      return tet_num(target) / outcomes
   end
   if target <= 200 then
      return ((tet_num(target) - 2 * tet_num(target - 101) - tet_num(target - 100)) / outcomes)
   end
   return (outcomes - tet_num(300 - target)) / outcomes
end

_lookup_table = {}

function populate_lookup_table()
   for i=0,100,1 do
      if i <= 0 then
         _lookup_table[0] = i
      end
      if i >= 100 then
         _lookup_table[100] = i
      end
      displayed_rate = math.max(1, math.floor(100 * raw_fail_to_fail(i)))
      _lookup_table[displayed_rate] = i
   end
end

populate_lookup_table()

-- take displayed fail and get raw fail
-- displayed fail is truncated when cast from double to int, so multiple raw
-- fails might be displayed the same way. for a given displayed fail we return
-- the highest raw fail displayed that way
function fail_to_raw_fail(x) -- int -> int
   return _lookup_table[x]
end

-- what are the chances the roll to cast will hit a specific number
function chance_of_fail_level(target)
   return raw_fail_to_fail(target + 1) - raw_fail_to_fail(target)
end

-- implemented more or less like fail_severity in spl-cast.cc
function chance_for_x_or_more_dam(spl, d) -- string, int -> double
   fail = fail_to_raw_fail(spells.fail(spl))
   lvl = spells.level(spl)
   lvl2 = lvl * lvl
   -- First let's just bail if it's impossible to do damage
   if fail * lvl2 <= 100 then
      return 0
   end

   chance = 0
   for i=0,fail,1 do
      miss_amt = fail - i
      -- damage is miss_amt * lvl2 / 10
      if miss_amt * lvl2 > 100 and miss_amt * lvl2 >= d * 10 then
         chance = chance + chance_of_fail_level(i)
      end
   end
   return chance * 100
end

-- TODO: consolidate with other functions printing info for all spells
function _print_chances_to_suffer_x_dam_array(xs, str, d) -- table, string, int -> None (IO)
   for i,x in pairs(xs) do
      str = str .. "\n" .. x .. ": " .. chance_for_x_or_more_dam(x, d)
   end
   crawl.mpr(str)
end

function spells_chances_to_suffer_x_dams(d) -- Int -> None (IO)
   s = "Spells: chances to suffer " .. tostring(d) .. " damage: "
   _print_chances_to_suffer_x_dam_array(you.spells(), s, d)
end

function library_chances_to_suffer_x_dams(d) -- Int -> None (IO)
   s = "Library: maximum suffer " .. tostring(d) .. "damage: "
   _print_chances_to_suffer_x_dam_array(you.mem_spells(), s, d)
end

function spells_chances_to_suffer_x_dams_w_prompt() -- None -> None (IO)
   num = crawl.c_input_line()
   if not num then
      crawl.mpr("Error, invalid input.")
      return
   end
   spells_chances_to_suffer_x_dams(num)
   return
end

-- DEFLECT MISSILES

-- constants
dmsl_state = 0 -- normal, unequipping, casting, reequipping
arm_slot = nil
weap_slot = nil
dm = "deflect missiles"

function is_dmsl_safe()
   -- it's fine to force manual casting in sketchy situations---healthy
   -- buffers are better than cutting it as close as possible
   dam = max_miscast_dam(dm) -- max elec damage
   hp, mhp = you.hp()
   -- 20% hp buffer. % of mhp on the principle that how much hp is safe depends
   -- on where in the game you are
   toret = hp >= dam + math.ceil(mhp / 5)
   if not toret or hp < 50 then
      dprint("Error, not enough hp for fail rate.")
      dmsl_state = 0
      return toret
   end
   -- sanity check... a little paranoid but ok
   if spells.fail_severity(dm) >= 4 then
      dprint("Error, fail severity too severe but fail rate didn't catch it!")
      dmsl_state = 0
      return false
   end
   return true
end

function dmsl_dance_init()
   if can_dmsl_dance() then
      dprint("Dancing!")
      arm = items.equipped_at("armour")
      if arm then arm_slot = arm.slot end
      weap = items.equipped_at("weapon")
      if weap then weap_slot = weap.slot else weap_slot = (-1) end
      dmsl_state = 1
   else
      dprint("Can't dance.")
   end
end

function can_dmsl_dance()
   -- safety is checked prior to each cast not at the start since it is hard to
   -- predict what fail rate will be after taking off armour, putting on wiz
   -- equipment, etc
   if not spells.memorised(dm)
   or you.status(dm) then
      return false
   end
   return true
end

function dmsl_dance()
   if dmsl_state == 0 then
      return
   end

   if not you.feel_safe() then
      -- abort, let the player clean the situation up
      dmsl_state = 0
      return
   end

   if dmsl_state == 1 then
      dprint("Dealing with dmsl_state of 1.")
      cur_arm = items.equipped_at("armour")
      if cur_arm and cur_arm.encumbrance > 0 then
         magic("T" .. items.index_to_letter(cur_arm.slot))
         return
      end
      --swap to wiz staff/stat stick etc. TODO ring swapping
      cur_weap = items.equipped_at("weapon")
      if not cur_weap or not string.find(cur_weap.inscription, "dmsl") then
         for i, j in ipairs(items.inventory()) do
            if string.find(j.inscription, "dmsl") then
               magic("w" .. items.index_to_letter(j.slot))
               return
            end
         end
      end
      dmsl_state = 2
      crawl.sendkeys(" ")
      return
   end

   if dmsl_state == 2 then
      dprint("Dealing with dmsl_state of 2.")
      if not is_dmsl_safe() then
         dprint("Aborting dmsl dance, unsafe!")
         dmsl_state = 0
         return
      end
      if you.hunger() < 3 then
         dmsl_state = 0
         return
      end
--nb, documentation is incorrect, you.contaminated is a number representing
--contam level not a bool
      if you.mp() > 5 and you.contaminated() <= 2 then
         dm_slot = spells.letter(dm)
         -- I'm not sure how we could get into this state, but abort if we do
         if not dm_slot then
            dmsl_state = 0
            return
         end
         dprint("Casting dmsl.")
         magic("Z" .. dm_slot)
         if you.status(dm) then
            dmsl_state = 3
         end
      else
         dprint("Resting for mp or contamination.")
         magic(".")
      end
      return
   end

   if dmsl_state == 3 then
      dprint("Dealing with dmsl_state of 3.")
      if arm_slot then
         magic("W" .. items.index_to_letter(arm_slot))
         arm_slot = nil
         return
      end
      if weap_slot then
         if weap_slot == (-1) then
            let = "-"
         else
            let = items.index_to_letter(weap_slot)
         end
         -- needed in case easy_unequip option is set
         if not (weap_slot == items.equipped_at("weapon").slot) then
            magic("w" .. let)
         end
         weap_slot = nil
      end
      dmsl_state = 0
   end
end
