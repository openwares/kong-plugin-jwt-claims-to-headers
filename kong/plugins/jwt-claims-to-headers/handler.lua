local BasePlugin = require "kong.plugins.base_plugin"
local JwtClaimsToHeadersHandler = BasePlugin:extend()


function JwtClaimsToHeadersHandler:new()
  JwtClaimsToHeadersHandler.super.new(self, "jwt-claims-to-headers")
end


function JwtClaimsToHeadersHandler:access(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  JwtClaimsToHeadersHandler.super.access(self)

  -- Implement any custom logic here
  kong.log.inspect(config.key_names)   
end


return JwtClaimsToHeadersHandler