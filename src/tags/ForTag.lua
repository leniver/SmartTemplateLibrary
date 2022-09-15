---@class ForTag
---@field name string
---@field arguments? string
---@field __blocks function[]
ForTag = {}
ForTag.__index = ForTag

---@param name string
---@param arguments? string
---@return ForTag
function ForTag.new(name, arguments)
    local self = setmetatable(Tag.new(name, arguments), ForTag)

    ---@diagnostic disable-next-line: return-type-mismatch
    return self
end

---@param tmpl string
---@param vars table
---@return string
function ForTag:render(tmpl, vars)
    return "FOR BLOCK"
end