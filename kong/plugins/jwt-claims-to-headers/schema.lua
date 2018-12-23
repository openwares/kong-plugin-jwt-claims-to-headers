return {
  no_consumer = true, -- this plugin will only be applied to Services or Routes,
  fields = {
    -- jwt_query_param_name: {type = "string", default = "jwt"}
    -- TODO: optional parameter that has a map of each jwt claim to include as a header, and what to name the header.
    -- TODO: optional parameter that has the prefix to use for defaulting the claim headers: if no map is given, use this prefix to map every claim. The default value is 'X-Jwt-Claim-'
    -- TODO: Two parameters that specify where to find the jwt: uri_param_names and cookie_names. See the parameters in the Jwt plugin: https://docs.konghq.com/hub/kong-inc/jwt/
    -- TODO: it would be best to query the configuration of the Jwt plugin to get its parameters and reuse those.
    -- TODO: see 'Accessing the datastore': https://docs.konghq.com/1.0.x/plugin-development/access-the-datastore/.
    -- TODO: the Jwt plugin would need to be configured on the same service|route|consumer as this plugin
  }
  -- ,
  -- self_check = function(schema, plugin_t, dao, is_updating)
  --   -- perform any custom verification
  --   return true
  -- end
}