function ready()
  if you.status("death's door (expiring)") then
    crawl.mpr("DDoor is almost expired!")
  end
  dmsl_dance()
  update_place_specific_options()
end
