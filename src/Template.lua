require("tags/Tag")
require("tags/ForTag")
require("tags/IfTag")
require("filters/TrimFilter")
require("parser/Expression")


---@enum
local BooleanEnum = {
    ["true"] = true,
    ["false"] = false,
    ["nil"] = false,
}

function string:trim()
  return self:gsub("^%s*(.-)%s*$", "%1")
end

function string:toBool()
    if BooleanEnum[self] ~= nil then
      return BooleanEnum[self]
    end
    return self:len() > 0
end

---@enum
Tags = {
  ["for"] = ForTag,
  ["if"] = IfTag,
}
 
---@enum
Filters = {
  ["trim"] = TrimFilter,
}


---@class Template
---@field tmpl string
local Template = {}
Template.__index = Template


---@param tmpl string
---@return Template
function Template.new(tmpl)
    local self = setmetatable({}, Template)

    self.tmpl = tmpl

    return self
end

---@param vars table
---@return string
function Template:render(vars)
  return Tag.new():render(self.tmpl, vars)
end

setmetatable(Template, {
  __call = function (cls, ...)
    return Template.render(cls, select(1, ...))
  end,
})


return Template.new
