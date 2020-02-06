local helpers = require "spec.helpers"
local jwtParser = require "kong.plugins.jwt.jwt_parser"

-- local jwt_for_test = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ0ZXN0X2tleSJ9.Uj1YcRCeGAElh8zl6wm_RjjLzJ86GRoD5htP7HOx9yg"

local algo = 'HS256'
local test_key = 'test_key'
local test_secret = 'test_secret'
local test_claim1_value = 'test_claim1_value'
local test_claim2_value = 'test_claim2_value'
local test_claim3_value = { 'test_claim3_value_1', 'test_claim3_value_2' }
local expected_claim3_value = 'test_claim3_value_1,test_claim3_value_2'
local iss_custom_header = "issCustomHeader"
local claim1_custom_header = "claim1CustomHeader"
local jwt_for_test = jwtParser.encode({
  iss = test_key,
  claim1 = test_claim1_value,
  claim2 = test_claim2_value,
  claim3 = test_claim3_value
}, test_secret, algo)
local test_prefix = "X-MyPrefix-"
local jwt_param_name = "custom_jwt"


-- The source code to setup and teardown Kong was borrowed from the Kong project
-- spec/fixture contains fixtures directly borrowed from the Kong project

local function create_route(host_name, jwt_config, jwt_claims_to_header_config, bp)
  local routeWithDefaults = bp.routes:insert({
    hosts = { host_name },
  })

  bp.plugins:insert {
    name = "jwt",
    route = {id = routeWithDefaults.id},
    config = jwt_config,
  }

  bp.plugins:insert {
    name = "jwt-claims-to-headers",
    route = {id = routeWithDefaults.id},
    config = jwt_claims_to_header_config,
  }

end


for _, strategy in helpers.each_strategy() do
  describe("Jwt-Claims-to-Headers-Plugin: (access) [#" .. strategy .. "]", function()
    local client
    local bp = helpers.get_db_utils(strategy, nil, { "jwt-claims-to-headers" })

    setup(function()

      -- create a route to test each parameter

      create_route("test-defaults.com", {}, {}, bp)
      create_route("test-header-prefix.com", {}, { header_prefix = test_prefix }, bp)
      create_route("test-claims-to-headers-table.com",
              {},
              {
                claims_to_headers_table = {
                  iss = iss_custom_header,
                  claim1 = claim1_custom_header
                }
              },
              bp)
      create_route("test-uri-param-names.com",
              {
                uri_param_names= { jwt_param_name },
              },
              {
                uri_param_names = { jwt_param_name }
              },
              bp)

      -- create consumer
      local consumer = bp.consumers:insert {
        username = "testUser1",
        custom_id = "testCustomId"
      }

      print("Created consumer id " .. consumer.id ..
              ", at epoch time " .. consumer.created_at)

      -- create jwt_secret
      local jwt_secret = bp.jwt_secrets:insert {
        consumer = {id = consumer.id},
        secret = test_secret,
        key = test_key
      }

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
        plugins = "bundled,jwt,jwt-claims-to-headers",
      }))
    end)

    teardown(function()
      -- TODO: delete the consumer with id consumer_id, and the jwt_secret with id jwt_secret_id
      -- TODO: delete the hosts and routes
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
      it("with the 'jwt' query parameter, contains the X-claims header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test-defaults.com"
          },
          query= { jwt = jwt_for_test }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the headers
        local header_value_claim_iss = assert.request(r).has.header("X-Jwt-Claim-iss")
        local header_value_claim1 = assert.request(r).has.header("X-Jwt-Claim-claim1")
        local header_value_claim2 = assert.request(r).has.header("X-Jwt-Claim-claim2")
        local header_value_claim3 = assert.request(r).has.header("X-Jwt-Claim-claim3")

        -- validate the value of the headers
        assert.equal(test_key, header_value_claim_iss)
        assert.equal(test_claim1_value, header_value_claim1)
        assert.equal(test_claim2_value, header_value_claim2)
        assert.equal(expected_claim3_value, header_value_claim3)
      end)


      it("with a jwt as the Bearer token, contains the X-claims header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            authorization = "Bearer " .. jwt_for_test,
            host = "test-defaults.com"
          }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the headers
        local header_value_claim_iss = assert.request(r).has.header("X-Jwt-Claim-iss")
        local header_value_claim1 = assert.request(r).has.header("X-Jwt-Claim-claim1")
        local header_value_claim2 = assert.request(r).has.header("X-Jwt-Claim-claim2")
        local header_value_claim3 = assert.request(r).has.header("X-Jwt-Claim-claim3")
        -- validate the value of the headers
        assert.equal(test_key, header_value_claim_iss)
        assert.equal(test_claim1_value, header_value_claim1)
        assert.equal(test_claim2_value, header_value_claim2)
        assert.equal(expected_claim3_value, header_value_claim3)
      end)
    end)

    describe("request with config parameters", function()
      it("with the 'prefix' config parameter, uses the prefix in the header names", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test-header-prefix.com"
          },
          query= { jwt = jwt_for_test }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the headers
        local header_value_claim_iss = assert.request(r).has.header(test_prefix .. "iss")
        local header_value_claim1 = assert.request(r).has.header(test_prefix .. "claim1")
        local header_value_claim2 = assert.request(r).has.header(test_prefix .. "claim2")

        -- validate the value of the headers
        assert.equal(test_key, header_value_claim_iss)
        assert.equal(test_claim1_value, header_value_claim1)
        assert.equal(test_claim2_value, header_value_claim2)
      end)

      it("with the 'claims_to_headers_table' config parameter, uses the custom headers", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test-claims-to-headers-table.com"
          },
          query= { jwt = jwt_for_test }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the headers
        local header_value_claim_iss = assert.request(r).has.header(iss_custom_header)
        local header_value_claim1 = assert.request(r).has.header(claim1_custom_header)
        -- validate the value of the headers
        assert.equal(test_key, header_value_claim_iss)
        assert.equal(test_claim1_value, header_value_claim1)
      end)

      it("with uri_param_names specifying the location of the jwt, contains the X-claims header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test-uri-param-names.com"
          },
          query= { custom_jwt = jwt_for_test }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the headers
        local header_value_claim_iss = assert.request(r).has.header("X-Jwt-Claim-iss")
        local header_value_claim1 = assert.request(r).has.header("X-Jwt-Claim-claim1")
        local header_value_claim2 = assert.request(r).has.header("X-Jwt-Claim-claim2")
        local header_value_claim3 = assert.request(r).has.header("X-Jwt-Claim-claim3")

        -- validate the value of the headers
        assert.equal(test_key, header_value_claim_iss)
        assert.equal(test_claim1_value, header_value_claim1)
        assert.equal(test_claim2_value, header_value_claim2)
        assert.equal(expected_claim3_value, header_value_claim3)
      end)

    end)


    describe("response", function()
      it("with the 'jwt' query parameter, contains the X-claims header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test-defaults.com",
          },
          query= { jwt = jwt_for_test }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the response to have the headers
        local header_value_claim_iss = assert.request(r).has.header("X-Jwt-Claim-iss")
        local header_value_claim1 = assert.request(r).has.header("X-Jwt-Claim-claim1")
        local header_value_claim2 = assert.request(r).has.header("X-Jwt-Claim-claim2")
        local header_value_claim3 = assert.request(r).has.header("X-Jwt-Claim-claim3")
        -- validate the value of that headers
        assert.equal(test_key, header_value_claim_iss)
        assert.equal(test_claim1_value, header_value_claim1)
        assert.equal(test_claim2_value, header_value_claim2)
        assert.equal(expected_claim3_value, header_value_claim3)
      end)

      it("with a jwt as the Bearer token, contains the X-claims header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            authorization = "Bearer " .. jwt_for_test,
            host = "test-defaults.com",
          }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the response to have the headers
        local header_value_claim_iss = assert.request(r).has.header("X-Jwt-Claim-iss")
        local header_value_claim1 = assert.request(r).has.header("X-Jwt-Claim-claim1")
        local header_value_claim2 = assert.request(r).has.header("X-Jwt-Claim-claim2")
        local header_value_claim3 = assert.request(r).has.header("X-Jwt-Claim-claim3")
        -- validate the value of that headers
        assert.equal(test_key, header_value_claim_iss)
        assert.equal(test_claim1_value, header_value_claim1)
        assert.equal(test_claim2_value, header_value_claim2)
        assert.equal(expected_claim3_value, header_value_claim3)
      end)

    end)

    describe("unauthorized", function()
      it("should return Unauthorized", function()
        -- send requests through Kong
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test-defaults.com",
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