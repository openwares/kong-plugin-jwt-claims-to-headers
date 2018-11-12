local BasePlugin = require "kong.plugins.base_plugin"
local JwtClaimsToHeadersHandler = BasePlugin:extend()


function JwtClaimsToHeadersHandler:new()
  JwtClaimsToHeadersHandler.super.new(self, "jwt-claims-to-headers")
end


function JwtClaimsToHeadersHandler:access(config)
  JwtClaimsToHeadersHandler.super.access(self)

  ngx.log(ngx.ERR, "@@@@ Adding headers")
  ngx.header["X-Jwt-ClaimX"] = "ClaimX value"
  ngx.req.set_header("X-Jwt-ClaimX", "ClaimX value")
  ngx.header["X-Jwt-ClaimYt"] = "ClaimY value"
  ngx.req.set_header("X-Jwt-ClaimY", "ClaimY value")

  
  kong.log.inspect(config.key_names)   
end


return JwtClaimsToHeadersHandler