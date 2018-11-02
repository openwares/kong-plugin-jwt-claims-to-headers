return {
  no_consumer = true, -- this plugin will only be applied to Services or Routes,
  fields = {
    -- jwt_query_param_name: {type = "string", default = "jwt"}
  }
  -- ,
  -- self_check = function(schema, plugin_t, dao, is_updating)
  --   -- perform any custom verification
  --   return true
  -- end
}