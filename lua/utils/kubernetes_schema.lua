--- schema-companion source for kubernetes manifests that holds several resources
---
--- yamlls validates every document in a file against every schema assigned to
--- it, so a Service and a Deployment in one file fail each other's schema. When
--- a file matches more than one resource, this assigns a single generated
--- schema that accepts any of them, letting each document match its own kind.

local matcher = require("schema-companion.sources.matchers.kubernetes")

local M = { name = matcher.name }

---@param config { version: string }
function M.setup(config)
  matcher.setup(config)

  return M
end

function M:match(ctx, bufnr)
  local schemas = {}
  local seen = {}

  for _, schema in ipairs(matcher:match(ctx, bufnr) or {}) do
    if not seen[schema.uri] then
      seen[schema.uri] = true
      table.insert(schemas, schema)
    end
  end

  if #schemas < 2 then
    return schemas
  end

  local uris = vim.tbl_map(function(schema)
    return schema.uri
  end, schemas)
  local names = vim.tbl_map(function(schema)
    return schema.name
  end, schemas)

  local dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "kubernetes-schemas")
  local path = vim.fs.joinpath(dir, vim.fn.sha256(table.concat(uris, "\n")):sub(1, 16) .. ".json")

  if not vim.uv.fs_stat(path) then
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile({
      vim.json.encode({
        anyOf = vim.tbl_map(function(uri)
          return { ["$ref"] = uri }
        end, uris),
      }),
    }, path)
  end

  return {
    {
      uri = vim.uri_from_fname(path),
      name = table.concat(names, " + "),
      source = M.name,
    },
  }
end

return M
