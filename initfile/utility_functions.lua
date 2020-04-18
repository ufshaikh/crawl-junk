-- UTILITY FUNCTIONS

function magic(command)
  crawl.process_keys(command .. string.char(27) .. string.char(27) ..
                     string.char(27))
end

function dprint(str)
   if debugp then
      crawl.mpr(str)
   end
end

function in_list_p(val, list)
    for i, j in ipairs(list) do
        if j == val then
        return true
        end
    end
    return false
end

function hp_percent() a,b=you.hp() return 100*a/b end

function mp_percent() a,b=you.mp() return 100*a/b end
