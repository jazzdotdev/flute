local underscore = require "third-party.underscore"

for _, name in ipairs(underscore.functions()) do
  _G[name] = underscore[name]
end
