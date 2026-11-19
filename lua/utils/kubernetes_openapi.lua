--- Converts a cluster's OpenAPI v3 documents into strict, standalone JSON schemas,
--- one per kind, for yaml-language-server

local M = {}

local REF_PREFIX = "#/components/schemas/"
local QUANTITY = "io.k8s.apimachinery.pkg.api.resource.Quantity"

--- resource.Quantity's grammar: a signed decimal with an optional binary SI,
--- decimal SI, or exponent suffix
M.quantity_pattern = [[^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)([KMGTPE]i|[numkMGTPE]|[eE][+-]?[0-9]+)?$]]

--- Directory holding the schemas synced from one kubectl context
---
---@param context string
---@return string
function M.schema_dir(context)
  return vim.fs.joinpath(vim.fn.stdpath("data"), "kubernetes-schemas", (context:gsub("[^%w%._-]", "_")))
end

---@param dir string
---@param group string "" for the core group
---@param version string
---@param kind string
---@return string
function M.schema_path(dir, group, version, kind)
  return vim.fs.joinpath(dir, group == "" and "core" or group, kind:lower() .. "_" .. version .. ".json")
end

local transform

---@param list table|nil
local function transform_each(list)
  for _, schema in ipairs(list or {}) do
    transform(schema)
  end
end

--- Rewrite refs to the standalone layout, reject unknown keys where the API does,
--- and allow null wherever a typed property is set, as the API server does
---
---@param schema table
transform = function(schema)
  if type(schema) ~= "table" then
    return
  end

  if schema["$ref"] then
    schema["$ref"] = "#/definitions/" .. schema["$ref"]:sub(#REF_PREFIX + 1)
  end

  if schema.properties then
    if schema.additionalProperties == nil and not schema["x-kubernetes-preserve-unknown-fields"] then
      schema.additionalProperties = false
    end

    for _, property in pairs(schema.properties) do
      if type(property) == "table" and type(property.type) == "string" then
        property.type = { property.type, "null" }
      end

      transform(property)
    end
  end

  transform(schema.items)
  transform(schema["not"])
  transform_each(schema.allOf)
  transform_each(schema.anyOf)
  transform_each(schema.oneOf)

  if type(schema.additionalProperties) == "table" then
    transform(schema.additionalProperties)
  end
end

---@param defs table<string, table>
---@param root table
---@return table<string, table>
local function reachable(defs, root)
  local found = {}
  local pending = { root }

  while #pending > 0 do
    local node = table.remove(pending)

    for key, value in pairs(node) do
      if key == "$ref" and type(value) == "string" then
        local name = value:match("^#/definitions/(.+)$")

        if name and defs[name] and not found[name] then
          found[name] = defs[name]
          table.insert(pending, defs[name])
        end
      elseif type(value) == "table" then
        table.insert(pending, value)
      end
    end
  end

  return found
end

---@class KubernetesSchema
---@field group string
---@field version string
---@field kind string
---@field schema table

--- Standalone schemas for every kind an OpenAPI v3 group-version document serves.
--- Mutates `doc`.
---
---@param doc table decoded /openapi/v3/<group-version> response
---@param group string "" for the core group
---@param version string
---@return KubernetesSchema[]
function M.convert(doc, group, version)
  local defs = vim.tbl_get(doc, "components", "schemas") or {}
  local api_version = group == "" and version or (group .. "/" .. version)
  local results = {}

  if defs[QUANTITY] then
    defs[QUANTITY] = {
      description = defs[QUANTITY].description,
      oneOf = {
        {
          type = "string",
          pattern = M.quantity_pattern,
          patternErrorMessage = "Invalid quantity, e.g. 500m, 0.5, 2Gi, 1e9",
        },
        { type = "number" },
      },
    }
  end

  for _, schema in pairs(defs) do
    transform(schema)
  end

  for name, schema in pairs(defs) do
    -- apimachinery types such as DeleteOptions claim a kind in every group
    if not name:match("^io%.k8s%.apimachinery%.") then
      for _, gvk in ipairs(schema["x-kubernetes-group-version-kind"] or {}) do
        if gvk.group == group and gvk.version == version and not gvk.kind:match("List$") then
          local root = vim.tbl_extend("force", {}, schema)

          root.properties = vim.tbl_extend("force", {}, schema.properties or {}, {
            apiVersion = { type = "string", enum = { api_version } },
            kind = { type = "string", enum = { gvk.kind } },
          })
          root.definitions = reachable(defs, schema)

          if vim.tbl_isempty(root.definitions) then
            root.definitions = vim.empty_dict()
          end

          table.insert(results, { group = group, version = version, kind = gvk.kind, schema = root })
        end
      end
    end
  end

  return results
end

--- Group and version of an /openapi/v3 path, or nil for paths that serve no kinds
---
---@param path string e.g. "api/v1" or "apis/apps/v1"
---@return string|nil group
---@return string|nil version
function M.parse_path(path)
  if path == "api/v1" then
    return "", "v1"
  end

  return path:match("^apis/([^/]+)/([^/]+)$")
end

--- apiVersion/kind pairs of every document in a buffer
---
---@param lines string[]
---@return { group: string, version: string, kind: string }[]
function M.resources(lines)
  local resources = {}
  local current = {}

  for _, line in ipairs(lines) do
    if line:match("^%-%-%-") then
      current = {}
    end

    local api_version = line:match([[^apiVersion:%s*["']?([^%s"']+)]])
    local kind = line:match([[^kind:%s*["']?([^%s"']+)]])

    if api_version then
      local group, version = api_version:match("^(.+)/(.+)$")

      current.group = group or ""
      current.version = version or api_version
    end

    current.kind = kind or current.kind

    if current.version and current.kind then
      table.insert(resources, current)
      current = {}
    end
  end

  return resources
end

return M
