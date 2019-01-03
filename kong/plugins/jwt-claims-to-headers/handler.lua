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

    -- TODO: since the jwt plugin supports sending a jwt in a cookie, this should support it as well.
    -- TODO: there is no default cookie name for the jwt: the cookie name is specified in the parameter cookie_names

    if jwt == nil then
        -- TODO: if there is a parameter that defines this name, then extract the jwt param name from the config, otherwise default to 'jwt'
        -- TODO: support the parameter name uri_param_names, used in the Jwt plugin, which is a list of query string parameters to inspect
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

local function header_for_claim(claim_name, config)

    -- if the config includes a table, claims_to_headers_table, that specifies a map of claims to headers, return the
    -- header for this claim name. If a table exists, but there is no mapping for this claim, return nil
    -- Otherwise, return a concatenation of the header_prefix and the key name. The header is specified in config.header_prefix.

    local header = nil
    local claims_to_headers_table = config.claims_to_headers_table
    local header_prefix = config.header_prefix or defaultHeaderPrefix

    if claims_to_headers_table ~= nil then
        if claims_to_headers_table[claim_name] ~= nil then
            header = claims_to_headers_table[claim_name]
        end
    else
        header = header_prefix .. claim_name
    end

    return header
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

    kong.log.debug("@@@@@@ config:")
    kong.log.inspect("@@@@@@ inspect config", config)
    kong.log.inspect("@@@@@@ inspect claims_to_headers_table", config.claims_to_headers_table)

    local claims_table, err = claims(config)
    if err ~= nil then
        -- TODO: handle an error
        kong.log.err("Error parsing the jwt: ", err, " jwt: ", jwt)
        return nil, err
    end

    if claims_table ~= nil then
        for key, value in pairs(claims_table) do
            local header = header_for_claim(key, config)
            if header ~= nil then
                kong.log.debug("Set header: '", header, "' to value: '", value, "'")
                kong.service.request.set_header(header, value)
            end
        end
    end

end

--[[
function JwtClaimsToHeadersHandler:header_filter(config)
    -- kong.response.set_header(name, value)
end
]]


return JwtClaimsToHeadersHandler