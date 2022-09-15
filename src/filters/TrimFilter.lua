---@class TrimFilter
TrimFilter = {}
TrimFilter.__index = TrimFilter

---@return TrimFilter
function TrimFilter.new()
    local self = setmetatable({}, TrimFilter)
    return self
end

---@param value string
---@return string
function TrimFilter:execute(value)
    value = value:trim()
    return value
end
