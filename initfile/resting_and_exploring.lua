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

function custom_move_dl()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_SAFE_MOVE_DOWN_LEFT"
    else
        a[1] = "CMD_MOVE_DOWN_LEFT"
    end
    crawl.do_commands(a)
end

function custom_move_l()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_SAFE_MOVE_LEFT"
    else
        a[1] = "CMD_MOVE_LEFT"
    end
    crawl.do_commands(a)
end

function custom_move_d()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_SAFE_MOVE_DOWN"
    else
        a[1] = "CMD_MOVE_DOWN"
    end
    crawl.do_commands(a)
end

function custom_move_r()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_SAFE_MOVE_RIGHT"
    else
        a[1] = "CMD_MOVE_RIGHT"
    end
    crawl.do_commands(a)
end

function custom_move_dr()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_SAFE_MOVE_DOWN_RIGHT"
    else
        a[1] = "CMD_MOVE_DOWN_RIGHT"
    end
    crawl.do_commands(a)
end

function custom_move_u()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_SAFE_MOVE_UP"
    else
        a[1] = "CMD_MOVE_UP"
    end
    crawl.do_commands(a)
end

function custom_move_ur()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_SAFE_MOVE_UP_RIGHT"
    else
        a[1] = "CMD_MOVE_UP_RIGHT"
    end
    crawl.do_commands(a)
end

function custom_move_ul()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_SAFE_MOVE_UP_LEFT"
    else
        a[1] = "CMD_MOVE_UP_LEFT"
    end
    crawl.do_commands(a)
end

function custom_autofight()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_NO_CMD_DEFAULT"
    elseif you.status("icy armour") or you.status("icy armour (expiring)") then
        a[1] = "CMD_AUTOFIGHT_NOMOVE"
    else
        a[1] = "CMD_AUTOFIGHT"
    end
    crawl.do_commands(a)
end

function custom_autofight_nomove()
    a = {}
    if safe_move_toggle then
        a[1] = "CMD_NO_CMD_DEFAULT"
    else
        a[1] = "CMD_AUTOFIGHT_NOMOVE"
    end
    crawl.do_commands(a)
end

safe_move_toggle = true
crawl.setopt("mon_glyph += player : green")

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
