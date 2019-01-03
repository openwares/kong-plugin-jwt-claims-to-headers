defaultHeaderPrefix = "X-Jwt-Claim-"

return {
    no_consumer = true, -- this plugin will only be applied to Services or Routes,
    fields = {
        header_prefix = {type = "string", default = defaultHeaderPrefix},
        claims_to_headers_table = { type = "table", default = nil}
    }
    --[[
    fields = {
        { uri_param_names = {
            type = "set",
            elements = { type = "string" },
            default = { "jwt" },
        }, },
        { cookie_names = {
            type = "set",
            elements = { type = "string" },
            default = {}
        }, },
        -- jwt_query_param_name: {type = "string", default = "jwt"}
        -- TODO: Two parameters that specify where to find the jwt: uri_param_names and cookie_names. See the parameters in the Jwt plugin: https://docs.konghq.com/hub/kong-inc/jwt/
        -- TODO: This plugin would need to be configured the same way as the Jwt plugin.
        -- TODO: It would be best to query the configuration of the Jwt plugin to get its parameters and reuse those.
        -- TODO: However, a plugin can be configured many different ways (the jwt plugin can be global, on a service, on a route and on any combination of service and route), and kong has rules that govern the order of precedence,
        -- TODO: but there doesn't seem to be a way to get the config that was used on this request, in a plugin of higher precedence.
        -- TODO: see 'Accessing the datastore': https://docs.konghq.com/1.0.x/plugin-development/access-the-datastore/.
    }
--]]
    -- ,
    -- self_check = function(schema, plugin_t, dao, is_updating)
    --   -- perform any custom verification
    --   return true
    -- end

}