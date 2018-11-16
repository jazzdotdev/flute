require "content_functions.content_base"

function content.split_header (document_text)
    local yaml_text, body = document_text:match("(.-)\n%.%.%.*\n?(.*)")
    local header = yaml.to_table(yaml_text)
    return header, body
end

