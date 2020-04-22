-- SPELLS & MISCASTS

-- constants:
miscast_divisor = 15
miscast_threshold = 150

-- take spell name or displayed fail rate and output max possible "damage" from
-- a miscast. Note that "damage" might not be literal damage (it could be turns
-- of slow, e.g.)
function max_miscast_dam(x) -- string -> int
   fail = fail_to_raw_fail(spells.fail(x))
   level = spells.level(x)
   nastiness = fail * level * level
   if nastiness <= miscast_threshold then
      return 0
   end
   return math.ceil(nastiness / miscast_divisor)
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
   -- Special cases first:
   if d <= 0 then
      return 100
   end
   -- Bail if it's impossible to do non-zero damage
   if fail * lvl2 <= miscast_threshold then
      return 0
   end

   chance = 0
   for i=0,fail,1 do
      miss_amt = fail - i
      -- damage is miss_amt * lvl2 / 10
      if miss_amt * lvl2 > miscast_threshold
      and miss_amt * lvl2 >= d * miscast_divisor then
         chance = chance + chance_of_fail_level(i)
      end
   end
   return chance * 100
end

-- table, string, number -> string
function get_spells_info(xs, s, threshold)
   s = s .. "max possible damage, chance to suffer " .. tostring(threshold)
      .. " or more damage:"
   -- the longest spell name is 24 chars (I think)
   -- a tie between mystic blast and revivificaton
   for i,x in pairs(xs) do
      spl_s = string.format("\n%-29s%4d%10.2f", x, max_miscast_dam(x),
                            chance_for_x_or_more_dam(x, threshold))
      s = s .. spl_s
   end
   return s
end

function get_dam_threshold() -- None (IO) -> Int or nil (IO)
   crawl.mpr("Damage over or above what number? ")
   num = tonumber(crawl.c_input_line())
   if not num then
      crawl.mpr("Error, invalid input.")
      return nil
   end
   return num
end

function spells_info() -- None -> None (IO)
   threshold = get_dam_threshold()
   if not threshold then
      return
   end
   info = get_spells_info(you.spells(), "Spells: ", threshold)
   crawl.mpr(info)
end

function spells_info_lib() -- None -> None (IO)
   threshold = get_dam_threshold()
   if not threshold then
      return
   end
   info = get_spells_info(you.mem_spells(), "Library: ", threshold)
   crawl.mpr(info)
end
