local helpers = require "spec.helpers"

-- jwt created for key 'test_key', with secret 'test_secret' and algorightm HS256
local jwt_for_test = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ0ZXN0X2tleSJ9.Uj1YcRCeGAElh8zl6wm_RjjLzJ86GRoD5htP7HOx9yg"

-- The source code to setup and teardown Kong was borrowed from the Kong project
-- spec/fixture contains fixtures directly borrowed from the Kong project
for _, strategy in helpers.each_strategy() do
  describe("Jwt-Claims-to-Headers-Plugin: (access) [#" .. strategy .. "]", function()
    local client
    local bp = helpers.get_db_utils(strategy)
    local consumer_id
    local jwt_secret_id

    setup(function()

      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })

      bp.plugins:insert {
        name = "jwt",
        route_id = route1.id,
        config = {
          uri_param_names="jwt"
        },
      }

      bp.plugins:insert {
        name = "jwt-claims-to-headers",
        route_id = route1.id,
        config = {},
      }

      -- create consumer
      local consumer = bp.consumers:insert {
        username = "testUser1",
        custom_id = "testCustomId"
      }
      consumer_id = consumer.id
      print("Created consumer id " .. consumer.id .. ", at epoch time " .. consumer.created_at)

      --[[ debug info
      for k,v in pairs(consumer) do
        print("@@@@@@ consumer " .. k)
      end
      -- end debug info --]]

      -- create jwt_secret
      local jwt_secret = bp.jwt_secrets:insert {
        consumer_id = consumer.id,
        secret = "test_secret",
        key = "test_key"
      }
      jwt_secret_id = jwt_secret.id
      print("Created jwt_secret id " .. jwt_secret.id ..
              ", at epoch time " .. jwt_secret.created_at ..
              ", key " .. jwt_secret.key ..
              ", secret " .. jwt_secret.secret)

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- set the config item to make sure our plugin gets loaded
        plugins = "bundled,jwt,jwt-claims-to-headers",         -- since Kong CE 0.14
        custom_plugins = "jwt-claims-to-headers",          -- pre Kong CE 0.14
      }))
    end)

    teardown(function()
      -- TODO: delete the consumer with id consumer_id, and the jwt_secret with id jwt_secret_id
      -- bp.jwt_secrets:delete()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)



    describe("request", function()
      it("contains the X-Jwt-ClaimX header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test1.com"
          },
          query= {jwt = jwt_for_test}
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the headers
        local header_value_claim_x = assert.request(r).has.header("X-Jwt-ClaimX")
        local header_value_claim_y = assert.request(r).has.header("X-Jwt-ClaimY")
        -- validate the value of the headers
        assert.equal("ClaimX value", header_value_claim_x)
        assert.equal("ClaimY value", header_value_claim_y)
      end)
    end)



    describe("response", function()
      it("contains the X-Jwt-ClaimX header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test1.com",
          },
          query= {jwt = jwt_for_test}
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the response to have the header
        local header_value = assert.response(r).has.header("X-Jwt-ClaimX")
        -- validate the value of that header
        assert.equal("ClaimX value", header_value)
      end)
    end)

    describe("unauthorized", function()
      it("should return Unauthorized", function()
        -- send requests through Kong
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test1.com",
          }
        })

        assert.response(r).has.status(401)
      end)
    end)

    describe("/not-a-route", function()
      it("should return not found", function()
        -- send requests through Kong
        local res = client:get("/not-a-route", {
          headers = {
            ["Host"] = "test.com"
          }
        })

        assert.res_status(404, res)
      end)
    end)

  end)
end