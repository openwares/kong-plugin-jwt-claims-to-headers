defaultHeaderPrefix = "X-Jwt-Claim-"

return {
    no_consumer = true, -- this plugin will only be applied to Services or Routes,
    fields = {
        header_prefix = {type = "string", default = defaultHeaderPrefix}
    }
    --[[
    fields = {
        COMMENT_THIS_OUT
        { claims_to_headers_table = {
            type = "set",
            elements = {
                type = "table",
                schema = {
                    claim_name = { type = "string" },
                    header_name = { type = "string" }
                }
            }
        }, },
        END_COMMENT

        { claims_to_headers_table = { type = "table" }, },
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
        -- TODO: optional parameter that has a map of each jwt claim to include as a header, and what to name the header.
        -- TODO: Two parameters that specify where to find the jwt: uri_param_names and cookie_names. See the parameters in the Jwt plugin: https://docs.konghq.com/hub/kong-inc/jwt/
        -- TODO: it would be best to query the configuration of the Jwt plugin to get its parameters and reuse those.
        -- TODO: see 'Accessing the datastore': https://docs.konghq.com/1.0.x/plugin-development/access-the-datastore/.
        -- TODO: the Jwt plugin would need to be configured on the same service|route as this plugin
    }
--]]
    -- ,
    -- self_check = function(schema, plugin_t, dao, is_updating)
    --   -- perform any custom verification
    --   return true
    -- end

}