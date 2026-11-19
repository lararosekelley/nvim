--- Tests for the kubernetes OpenAPI conversion and manifest helpers

local kubernetes = require("utils.kubernetes")
local openapi = require("utils.kubernetes_openapi")

--- A trimmed OpenAPI v3 group-version document shaped like the API server's
---
--- @return table
local function apps_doc()
  return vim.json.decode([[
{
  "components": {
    "schemas": {
      "io.k8s.api.apps.v1.Deployment": {
        "type": "object",
        "x-kubernetes-group-version-kind": [{ "group": "apps", "version": "v1", "kind": "Deployment" }],
        "properties": {
          "apiVersion": { "type": "string" },
          "kind": { "type": "string" },
          "spec": { "allOf": [{ "$ref": "#/components/schemas/io.k8s.api.apps.v1.DeploymentSpec" }] }
        }
      },
      "io.k8s.api.apps.v1.DeploymentList": {
        "type": "object",
        "x-kubernetes-group-version-kind": [{ "group": "apps", "version": "v1", "kind": "DeploymentList" }],
        "properties": { "items": { "type": "array" } }
      },
      "io.k8s.api.apps.v1.DeploymentSpec": {
        "type": "object",
        "properties": {
          "replicas": { "type": "integer" },
          "limits": { "additionalProperties": { "$ref": "#/components/schemas/io.k8s.apimachinery.pkg.api.resource.Quantity" } },
          "extra": { "type": "object", "x-kubernetes-preserve-unknown-fields": true, "properties": { "a": {} } }
        }
      },
      "io.k8s.api.apps.v1.Unused": { "type": "object", "properties": {} },
      "io.k8s.apimachinery.pkg.api.resource.Quantity": { "oneOf": [{ "type": "string" }, { "type": "number" }] },
      "io.k8s.apimachinery.pkg.apis.meta.v1.DeleteOptions": {
        "type": "object",
        "x-kubernetes-group-version-kind": [{ "group": "apps", "version": "v1", "kind": "DeleteOptions" }]
      }
    }
  }
}
]])
end

describe("kubernetes_openapi.convert", function()
  local results = openapi.convert(apps_doc(), "apps", "v1")
  local deployment = results[1] and results[1].schema

  it("emits one schema per kind, skipping lists and apimachinery types", function()
    assert.equals(1, #results)
    assert.equals("Deployment", results[1].kind)
  end)

  it("pins apiVersion and kind", function()
    assert.same({ "apps/v1" }, deployment.properties.apiVersion.enum)
    assert.same({ "Deployment" }, deployment.properties.kind.enum)
  end)

  it("rejects unknown keys unless the API preserves them", function()
    local spec = deployment.definitions["io.k8s.api.apps.v1.DeploymentSpec"]

    assert.is_false(deployment.additionalProperties)
    assert.is_false(spec.additionalProperties)
    assert.is_nil(spec.properties.extra.additionalProperties)
  end)

  it("allows null on typed properties", function()
    local spec = deployment.definitions["io.k8s.api.apps.v1.DeploymentSpec"]

    assert.same({ "integer", "null" }, spec.properties.replicas.type)
  end)

  it("rewrites refs and keeps only reachable definitions", function()
    local spec_ref = deployment.properties.spec.allOf[1]["$ref"]

    assert.equals("#/definitions/io.k8s.api.apps.v1.DeploymentSpec", spec_ref)
    assert.is_not_nil(deployment.definitions["io.k8s.apimachinery.pkg.api.resource.Quantity"])
    assert.is_nil(deployment.definitions["io.k8s.api.apps.v1.Unused"])
  end)

  it("encodes empty schemas as objects", function()
    assert.matches('"a":{}', vim.json.encode(deployment))
  end)
end)

describe("kubernetes_openapi.quantity_pattern", function()
  -- Lua patterns cannot express the alternation, so check it with Vim's regex
  local function matches(value)
    return vim.fn.match(value, "\\v\\C" .. openapi.quantity_pattern) == 0
  end

  it("accepts valid quantities", function()
    for _, value in ipairs({ "500m", "1", "0.5", ".5", "2Gi", "128Mi", "1e9", "+1k", "100n" }) do
      assert.is_true(matches(value), value)
    end
  end)

  it("rejects invalid quantities", function()
    for _, value in ipairs({ "banana", "1GB", "2gi", "", "1.2.3", "Mi" }) do
      assert.is_false(matches(value), value)
    end
  end)
end)

describe("kubernetes_openapi.parse_path", function()
  it("maps core and named groups", function()
    assert.same({ "", "v1" }, { openapi.parse_path("api/v1") })
    assert.same({ "apps", "v1" }, { openapi.parse_path("apis/apps/v1") })
    assert.same({ "cert-manager.io", "v1" }, { openapi.parse_path("apis/cert-manager.io/v1") })
  end)

  it("ignores paths that serve no kinds", function()
    assert.is_nil(openapi.parse_path("api"))
    assert.is_nil(openapi.parse_path("apis/apps"))
    assert.is_nil(openapi.parse_path(".well-known/openid-configuration"))
  end)
end)

describe("kubernetes_openapi.resources", function()
  it("reads every document's apiVersion and kind", function()
    local resources = openapi.resources({
      "apiVersion: v1",
      "kind: Service",
      "---",
      "kind: Deployment",
      'apiVersion: "apps/v1"',
    })

    assert.same({
      { group = "", version = "v1", kind = "Service" },
      { group = "apps", version = "v1", kind = "Deployment" },
    }, resources)
  end)
end)

describe("kubernetes.object_row", function()
  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "apiVersion: v1",
      "kind: Service",
      "metadata:",
      "  name: web",
      "---",
      "apiVersion: apps/v1",
      "kind: Deployment",
      "metadata:",
      "  labels: {}",
      "  name: 'web'",
    })
  end)

  after_each(function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("finds the kind line of the named object", function()
    assert.equals(7, kubernetes.object_row(bufnr, "Deployment", "web"))
    assert.equals(2, kubernetes.object_row(bufnr, "Service", "web"))
  end)

  it("falls back to the first object of that kind, then the top", function()
    assert.equals(7, kubernetes.object_row(bufnr, "Deployment", "{{ .Chart.Name }}"))
    assert.equals(1, kubernetes.object_row(bufnr, "Ingress", "web"))
  end)
end)
