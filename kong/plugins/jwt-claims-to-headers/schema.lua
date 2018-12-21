return {
  no_consumer = true, -- this plugin will only be applied to Services or Routes,
  fields = {
    -- jwt_query_param_name: {type = "string", default = "jwt"}
    -- TODO: optional parameter that has a map of each jwt claim to include as a header, and what to name the header.
    -- TODO: optional parameter that has the prefix to use for defaulting the claim headers: if not map is given, use this prefix to map every claim.
    -- TODO:  if neither a map nor a prefix is given, use a default prefix for all claims (X-Jwt-Claim-n)
    -- TODO: parameter to specify the name of the 'jwt' parameter that the JWT plugin is configured with, for example 'jwt'. Is this necessary? Maybe it's confusing
  }
  -- ,
  -- self_check = function(schema, plugin_t, dao, is_updating)
  --   -- perform any custom verification
  --   return true
  -- end
}