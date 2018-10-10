local function split_yaml_header (document_text)
    local yaml_text, body = document_text:match("(.-)\n%.%.%.*\n(.*)")
    local yaml = yaml.load(yaml_text)
    return yaml, body
end

local function split_document(document_text, id)
    local yaml_text, body = document_text:match("(.-)\n%.%.%.*\n(.*)")
    local yaml = yaml.load(yaml_text)
    local processed_body = body:gsub("\n", "\n")
    local html_body = markdown_to_html(processed_body, {safe = true})
    
    print("yaml_text = " .. yaml_text)
    print("body = " .. body)
    print("processed_body = " .. processed_body)
    print("html_body = " .. html_body)

    local params = {
        uuid = id,
        type = yaml.type,
        title = yaml.title,
        body = body,
        created = yaml.created or "",
        updated = yaml.updated or "",
    }

    return params
end

return {
    split_yaml_header = split_yaml_header,
    split_document = split_document,
}
