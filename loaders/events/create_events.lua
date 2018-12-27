function events_loader.create_events (event_count, events_strings)
  -- create events
  for i=1, event_count do
    local name = events_strings[i]
    local event = _G.events[name] -- if the event already exists from another package we are not overriding it
    if not event then
      event = luvent.newEvent()
      _G.events[name] = event
      _G.events_actions[name] = { } -- create table of actions for that event
    end
    event:addAction(function ()
    log.debug("[triggering] event"  .. ansicolors('%{underline}' .. name) )
    end)
  end
end
