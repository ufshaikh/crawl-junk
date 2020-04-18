-- PLACE SPECIFIC OPTIONS

branch = you.branch()
depth = you.depth()

function set_zig_options()
   crawl.setopt("flash_screen_message += You flicker back into view")
   crawl.setopt("flash_screen_message += Your transformation is almost over")
   crawl.setopt("flash_screen_message += You feel yourself come back to life")
   crawl.setopt("flash_screen_message += The darkness around you begins to abate")
   crawl.setopt("flash_screen_message += The ambient light returns to normal")
end

function unset_zig_options()
   crawl.setopt("flash_screen_message -= You flicker back into view")
   crawl.setopt("flash_screen_message -= Your transformation is almost over")
   crawl.setopt("flash_screen_message -= You feel yourself come back to life")
   crawl.setopt("flash_screen_message -= The darkness around you begins to abate")
   crawl.setopt("flash_screen_message -= The ambient light returns to normal")
end

function update_place_specific_options()
   old_br, old_depth = branch, depth
   branch, depth = you.branch(), you.depth()
   if not (old_br == branch) then
      if branch == "Zig" then
         set_zig_options()
      end
      if old_br == "Zig" then
         unset_zig_options()
      end
   end
end
