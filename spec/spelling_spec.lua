--- Tests for the ltex dictionary rewriting in utils.spelling.
---
--- These exercise the pure string transforms only. The commands that wrap them
--- write to the real lua/plugins/lsp/settings/ltex_plus.lua, so the specs stay
--- well clear of them.

local spelling = require("utils.spelling")

--- Wrap a dictionary body in enough surrounding settings to be realistic.
---
--- @param body string
--- @return string
local function settings(body)
  return table.concat({
    "return {",
    "  ltex = {",
    "    dictionary = {",
    '      ["en-US"] = ' .. body .. ",",
    "    },",
    "  },",
    "}",
  }, "\n")
end

describe("spelling.add_word", function()
  it("fills an empty inline block", function()
    local updated, count = spelling.add_word(settings("{}"), "nvim")

    assert.equals(1, count)
    assert.equals(settings('{ "nvim" }'), updated)
  end)

  it("appends to a populated inline block", function()
    local updated, count = spelling.add_word(settings('{ "lua" }'), "nvim")

    assert.equals(1, count)
    assert.equals(settings('{ "lua", "nvim" }'), updated)
  end)

  it("appends to a multiline block on its own line", function()
    local content = settings('{\n        "lua",\n      }')
    local updated, count = spelling.add_word(content, "nvim")

    assert.equals(1, count)
    assert.matches('"lua",\n        "nvim",', updated)
  end)

  it("reports no match when there is no en-US block", function()
    local _, count = spelling.add_word(settings("{}"):gsub("en%-US", "de%-DE"), "nvim")

    assert.equals(0, count)
  end)

  it("rewrites only the first block", function()
    local content = settings("{}") .. "\n" .. settings("{}")
    local updated = spelling.add_word(content, "nvim")

    local occurrences = select(2, updated:gsub('"nvim"', ""))
    assert.equals(1, occurrences)
  end)

  it("leaves the rest of the file untouched", function()
    local updated = spelling.add_word(settings("{}"), "nvim")

    assert.matches("^return {", updated)
    assert.matches("}$", updated)
  end)
end)

describe("spelling.remove_word", function()
  it("empties an inline block down to its last word", function()
    local updated, count = spelling.remove_word(settings('{ "nvim" }'), "nvim")

    assert.equals(1, count)
    assert.equals(settings("{ }"), updated)
  end)

  it("keeps the surviving words inline", function()
    local updated, count = spelling.remove_word(settings('{ "lua", "nvim" }'), "nvim")

    assert.equals(1, count)
    assert.equals(settings('{ "lua" }'), updated)
  end)

  it("keeps the surviving words multiline", function()
    local content = settings('{\n        "lua",\n        "nvim",\n      }')
    local updated, count = spelling.remove_word(content, "nvim")

    assert.equals(1, count)
    assert.matches('"lua",', updated)
    assert.is_nil(updated:find('"nvim"', 1, true))
  end)

  it("returns the content unchanged when the word is absent", function()
    local content = settings('{ "lua" }')
    local updated, count = spelling.remove_word(content, "nvim")

    -- A match on the block, but no edit: this is how the caller tells
    -- "word not in dictionary" apart from "no dictionary block".
    assert.equals(1, count)
    assert.equals(content, updated)
  end)

  it("reports no match when there is no en-US block", function()
    local _, count = spelling.remove_word(settings('{ "nvim" }'):gsub("en%-US", "de%-DE"), "nvim")

    assert.equals(0, count)
  end)

  it("removes an exact match only", function()
    local updated = spelling.remove_word(settings('{ "nvimrc", "nvim" }'), "nvim")

    assert.matches('"nvimrc"', updated)
    assert.equals(settings('{ "nvimrc" }'), updated)
  end)

  it("round-trips with add_word", function()
    local original = settings('{ "lua" }')
    local added = spelling.add_word(original, "nvim")

    assert.equals(original, spelling.remove_word(added, "nvim"))
  end)
end)
