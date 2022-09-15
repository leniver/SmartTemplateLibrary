---@class Tag
---@field name string
---@field arguments? string
Tag = {}
Tag.__index = Tag

local concat = table.concat

function string:trim()
    return self:gsub("^%s*(.-)%s*$", "%1")
end

---@param name? string
---@param arguments? string
---@return Tag
function Tag.new(name, arguments)
    local self = setmetatable({}, Tag)

    self.name = name or ""
    self.arguments = (arguments or ""):trim()

    return self
end

---@param tmpl string
local function compile_blocks(tmpl, vars)
    repeat
        local s, e, b, n, a = tmpl:find("({%%%s+(%w+)%s+([^{}]*)%%})")
        if s ~= nil then
            if Tags[n] == nil then
                error(('"%s" block is not defined'):format(n))
            end
            local startPattern = "({%%%s+" .. n .. ".+%%})"
            local endPattern = "({%%%s+end" .. n .. "%s+%%})"
            local startStart = e
            local endStart = e
            local endEnd = 0
            local startCount = 1
            local endCount = 0
            repeat
                local ss, ee = tmpl:find(endPattern, endStart)
                if ss == nil then
                    error([["]] .. b .. [[" is not closed]])
                end
                endCount = endCount + 1
                endStart = ss
                endEnd = ee
                local sss, eee = tmpl:find(startPattern, startStart)
                if sss ~= nil and sss < ss then
                    startCount = startCount + 1
                    startStart = eee
                    endStart = endEnd
                end
            until startCount == endCount
            tmpl = concat {
                tmpl:sub(1, s - 1),
                Tags[n].new(n, a):render(tmpl:sub(e, endStart), vars),
                tmpl:sub(endEnd + 1)
            }
        end
    until s == nil
    return tmpl
end

---@param tmpl string
---@param vars table
---@return string
local function compile_vars(tmpl, vars)
    ---@param match string
    ---@return string
    local substitute = function(match)
        return Expression.new(match):evalString(vars)
    end
    tmpl =  tmpl:gsub("{{%s*(.-)%s*}}", substitute)
    return tmpl
end

---@param tmpl string
---@param vars table
---@return string
function Tag:compile(tmpl, vars)
    return compile_vars(compile_blocks(tmpl, vars), vars)
end

function Tag:render(tmpl, vars)
    return self:compile(tmpl, vars)
end
