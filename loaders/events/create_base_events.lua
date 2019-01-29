function events_loader.create_base_events()
    events["lighttouch_loaded"] = luvent.newEvent()
    _G.events_actions["lighttouch_loaded"] = { }

    events["incoming_request_received"] = luvent.newEvent()
    _G.events_actions["incoming_request_received"] = { }

    events["outgoing_response_about_to_be_sent"] = luvent.newEvent()
    _G.events_actions["outgoing_response_about_to_be_sent"] = { }

    events["document_created"] = luvent.newEvent()
    _G.events_actions["document_created"] = { }

    events["incoming_response_received"] = luvent.newEvent()
    _G.events_actions["incoming_response_received"] = { }

    events["outgoing_request_about_to_be_sent"] = luvent.newEvent()
    _G.events_actions["outgoing_request_about_to_be_sent"] = { }
end
