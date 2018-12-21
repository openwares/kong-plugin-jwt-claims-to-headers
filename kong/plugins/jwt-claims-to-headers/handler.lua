local BasePlugin = require "kong.plugins.base_plugin"
local jwtParser = require "kong.plugins.jwt.jwt_parser"
local JwtClaimsToHeadersHandler = BasePlugin:extend()

-- ensure the priority is lower than the Jwt plugin, which has a priority of 1005
JwtClaimsToHeadersHandler.PRIORITY = 10

local JwtParamName = "jwt"

-- local functions ------------------------------
local function extract_jwt(config)
    local jwt
    local err
    local authHeader = kong.request.get_header("authorization")
    kong.log.debug("authHeader: ", authHeader)

    if authHeader ~= nil then
        local bearer_pattern = "[Bb][Ee][Aa][Rr][Ee][Rr] "
        jwt = string.gsub(authHeader, bearer_pattern, "")
        kong.log.debug("jwt from auth header: ", jwt)
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

local function claims(config)

    local jwt, err = extract_jwt(config)
    if err ~= nil or jwt == nil then
        -- TODO: handle an error
        kong.log.err("Error extracting the jwt: ", err, " jwt: ", jwt)
        return nil, err
    end
    kong.log.debug("Jwt is : ", jwt)

    local jwt_table, err2 = jwtParser:new(jwt)
    if err2 ~= nil then
        -- TODO: handle an error
        kong.log.err("Error parsing the jwt: ", err2, " jwt: ", jwt)
        return nil, err2
    end

    local claims_table = jwt_table["claims"]
    kong.log.debug("Jwt claims:")
    kong.log.inspect(claims_table)

    return claims_table, err
end

function JwtClaimsToHeadersHandler:new()
    JwtClaimsToHeadersHandler.super.new(self, "jwt-claims-to-headers")
end

-- Plugin functions ------------------------------
function JwtClaimsToHeadersHandler:access(config)
    JwtClaimsToHeadersHandler.super.access(self)

    local claims_table, err = claims(config)
    if err ~= nil then
        -- TODO: handle an error
        kong.log.err("Error parsing the jwt: ", err, " jwt: ", jwt)
        return nil, err
    end

    if claims_table ~= nil then
        for key, value in pairs(claims_table) do
            local header = header_from_key(key, config)
            kong.log.debug("Set header: ", header, " value: ", value)
            if header ~= nil then
                kong.service.request.set_header(header, value)
            end
        end
    end

    -- TODO: delete test claims
    ngx.header["X-Jwt-ClaimX"] = "ClaimX value"
    ngx.req.set_header("X-Jwt-ClaimX", "ClaimX value")
    ngx.header["X-Jwt-ClaimY"] = "ClaimY value"
    ngx.req.set_header("X-Jwt-ClaimY", "ClaimY value")

end

--[[
function JwtClaimsToHeadersHandler:header_filter(config)
    -- kong.response.set_header(name, value)
end
]]


return JwtClaimsToHeadersHandler