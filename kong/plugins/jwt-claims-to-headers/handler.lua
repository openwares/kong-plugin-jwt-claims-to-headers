local BasePlugin = require "kong.plugins.base_plugin"
local jwtParser = require "kong.plugins.jwt.jwt_parser"
local JwtClaimsToHeadersHandler = BasePlugin:extend()

-- ensure the priority is lower than the Jwt plugin, which has a priority of 1005
JwtClaimsToHeadersHandler.PRIORITY = 10

local JwtParamName = "jwt"

local function extract_jwt(config)
  local jwt
  local err
  local authHeader = kong.request.get_header("authorization")

  if not authHeader == nil then
    local bearer_pattern = "[Bb][Ee][Aa][Rr][Ee][Rr]"
    jwt = authHeader.gsub(bearer_pattern, "")
  end

  if jwt == nil then
    -- TODO: if there is a parameter that defines this name, then extract the jwt param name from the config, or default to 'jwt'
    -- kong.log.inspect(config)
    local jwt_param_name = JwtParamName
    jwt = kong.request.get_query_arg(jwt_param_name)
  end

  -- TODO: error handling if no jwt is found - this may not necessary, since the 'jwt' plugin will return unauthorized before this is called
  -- TODO: error handling if there is a jwt in the Bearer token and in a query parameter and they aren't the same:
  -- TODO: return jwt, err. In the calling method, call: return kong.response.exit(400, "Bad Request: request should have a Bearer token or a jwt on a query parameter, not both")
  -- TODO: see https://docs.konghq.com/0.14.x/pdk/kong.response/

  return jwt, err
end

local function header_from_key(key_name, config)
  -- TODO: check the config: first look for a mapping for the keys. If there is a mapping config, but none for this key, return nil
  -- TODO: if there is no mapping, look for a prefix. If there is no prefix, use the default prefix

  local prefix = "X-Jwt-Claim-"
  return prefix .. key_name
end

function JwtClaimsToHeadersHandler:new()
  JwtClaimsToHeadersHandler.super.new(self, "jwt-claims-to-headers")
end


function JwtClaimsToHeadersHandler:access(config)
  JwtClaimsToHeadersHandler.super.access(self)

  local jwt, err = extract_jwt(config)
  -- TODO: handle a jwt that's nil
  if (jwt == nil or jwt == '' or not (type(jwt) == "string")) then
    kong.log.debug("Invalid jwt: type is ", type(jwt), ", jwt is ", jwt)
  else
    kong.log.debug("Jwt is : " .. jwt)

    local jwt_table, err = jwtParser:new(jwt)
    if err ~= nil then
      -- TODO: handle an error
      kong.log.error("Error parsing the jwt: ", err)
    end

    local claims = jwt_table["claims"]
    kong.log.debug("Jwt claims:")
    kong.log.inspect(claims)

    if claims ~= nil then
      for key, value in pairs(claims) do
        -- TODO: create headers
        kong.log.debug("@@@@@@ claim key is ", key, " key type is ", type(key), " value is ", value)
        local header = header_from_key(key, config)
        kong.log.debug("Set header: ", header, " value: ", value)
        if header ~= nil then
          kong.service.request.set_header(header, value)
        end
      end
    end

  end

  ngx.header["X-Jwt-ClaimX"] = "ClaimX value"
  ngx.req.set_header("X-Jwt-ClaimX", "ClaimX value")
  ngx.header["X-Jwt-ClaimY"] = "ClaimY value"
  ngx.req.set_header("X-Jwt-ClaimY", "ClaimY value")

  end



return JwtClaimsToHeadersHandler