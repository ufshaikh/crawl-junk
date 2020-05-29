function custom_rest()
    if not you.feel_safe() then
        crawl.mpr("But you're not safe!")
        return
    end
    if hp_percent() == 100 and mp_percent() == 100 or
    mp_percent() == 100 and you.race() == "Deep Dwarf" then
        if crawl.yesnoquit("Wait 100 turns?", true, 'n') == 1 then
        crawl.sendkeys("5")
        end
    else crawl.sendkeys("5")
    end
end

function swap_for_autoexplore()
    local w = items.equipped_at("Weapon")
    if w and string.find(w.inscription, "autoexplore") then
        return nil
    else
        for i, j in ipairs(items.inventory()) do
        if string.find(j.inscription, "autoexplore") then
            return items.index_to_letter(j.slot)
        end
        end
        return nil
    end
end

function custom_autoexplore()
    if not you.feel_safe() then
        crawl.mpr("But you're not safe!")
        return
    end
    local action = ""
    local swap = swap_for_autoexplore()
    if swap then action = "w" .. swap end
    local dummy, mmp = you.mp()
    local mp_threshold = math.max(3, math.ceil(mmp / 2))
    crawl.sendkeys(action .. "o")
end

function custom_autofight()
    a = {}
    if you.status("icy armour") or you.status("icy armour (expiring)") then
        a[1] = "CMD_AUTOFIGHT_NOMOVE"
    else
        a[1] = "CMD_AUTOFIGHT"
    end
    crawl.do_commands(a)
end

safe_move_toggle = true
crawl.setopt("mon_glyph += player : green")

safe = you.feel_safe()

function update_safe()
   local old_safe = safe
   safe = you.feel_safe()
   if safe_move_toggle and not safe and old_safe then
      crawl.mpr("Danger!", 6)
      crawl.more()
   end
end

function toggle_safe_move()
    if safe_move_toggle then
        safe_move_toggle = false
        crawl.message("<cyan>safe move off</cyan>", 0)
        crawl.setopt("mon_glyph += player : red")
    else
        safe_move_toggle = true
        crawl.message("<cyan>safe move on</cyan>", 0)
        crawl.setopt("mon_glyph += player : green")
    end
end
