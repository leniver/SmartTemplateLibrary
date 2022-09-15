---@class IfTag
---@field name string
---@field arguments? string
---@field __blocks function[]
IfTag = {}
IfTag.__index = IfTag

---@param name string
---@param arguments? string
---@return IfTag
function IfTag.new(name, arguments)
    local self = setmetatable(Tag.new(name, arguments), IfTag)

    ---@diagnostic disable-next-line: return-type-mismatch
    return self
end


function IfTag:render(tmpl, vars)
    local result = Expression.new(self.arguments):evalBoolean(vars)

    return "TODO: parse the block. Eval " .. self.arguments .. " with " .. tostring(vars['name'])  .. " " .. tostring(result)
end