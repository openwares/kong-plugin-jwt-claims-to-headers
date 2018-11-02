local BasePlugin = require "kong.plugins.base_plugin"
local JwtClaimsToHeadersHandler = BasePlugin:extend()


function JwtClaimsToHeadersHandler:new()
  JwtClaimsToHeadersHandler.super.new(self, "jwt-claims-to-headers")
end


function JwtClaimsToHeadersHandler:access(config)

  JwtClaimsToHeadersHandler.super.access(self)

  ngx.log(ngx.ERR, "@@@@ Adding headers")
  ngx.header["X-Jwt-ClaimX"] = "ClaimX value"

  
  kong.log.inspect(config.key_names)   
end


return JwtClaimsToHeadersHandler