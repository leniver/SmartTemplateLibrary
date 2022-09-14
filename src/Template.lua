--[[
  Wolfe Labs Smart Template Library (STL)
  A simple, Twig-like templating language for Lua
  Syntax:
    {{ variable }} prints the contents of "variable"
    {% some_lua_code %} executes the Lua code, useful for creating blocks like {% if %} and {% else %}, make sure you add {% end %} too :)
  (C) 2022 - Wolfe Labs
]]

--- Helper function that generates a clean print statement of a certain string
---@param str string The string we need to show
---@return string
local function mkPrint(str)
  return 'print(\'' .. str:gsub('\'', '\\\''):gsub('\n', '\\n') .. '\')'
end

--- Helper function that merges tables
---@vararg table
---@return table
local function tMerge(...)
  local tables = {...}
  local result = {}
  for _, t in pairs(tables) do
    for k, v in pairs(t) do
      result[k] = v
    end
  end
  return result
end

---@class Template
local Template = {
  --- Globals available for every template by default
  globals = {
    math = math,
    table = table,
    string = string,
  }
}

-- Makes our template directly callable
function Template.__call(self, ...)
  return Template.render(self, ({...})[1])
end

--- Renders our template
---@param vars table The variables to be used when rendering the template
---@return string
function Template:render(vars)
  --- This is our return buffer
  local _ = {}

  -- Creates our environment
  local env = tMerge(Template.globals, self.globals or {}, vars or {}, {
    print = function (str) table.insert(_, tostring(str or '')) end,
  })

  -- Invokes our template
  load(self.code, nil, 't', env)()

  -- General trimming
  local result = table.concat(_, ''):gsub('%s+', ' ')

  -- Trims result
  result = result:sub(result:find('[^%s]') or 1):gsub('%s*$', '')

  -- Done
  return result
end

--- Creates a new template
---@param source string The code for your template
---@param globals table Global variables to be used on on the template
---@return Template
function Template.new(source, globals)
  -- Creates our instance
  local self = {
    source = source,
    globals = globals,
  }

  -- Parses direct printing of variables, we'll convert a {{var}} into {% print(var) %}
  source = source:gsub('{{(.-)}}', '{%% print(%1) %%}')

  -- Ensures {% if %} ... {% else %} ... {% end %} stays on same line
  source = source:gsub('\n%s*{%%', '{%%')
  source = source:gsub('%%}\n', '%%}')

  --- This variable stores all our Lua "pieces"
  local tPieces = {}

  -- Parses actual Lua inside {% lua %} tags
  while #source > 0 do
    --- The start index of Lua tag
    local iLuaStart = source:find('{%%')

    --- The end index of Lua tag
    local iLuaEnd = source:find('%%}')

    -- Checks if we have a match
    if iLuaStart then
      -- Errors when not closing a tag
      if not iLuaEnd then
        error('Template error, missing Lua closing tag near: ' .. source:sub(0, 16))
      end

      --- The current text before Lua tag
      local currentText = source:sub(1, iLuaStart - 1)
      if #currentText then
        table.insert(tPieces, mkPrint(currentText))
      end

      --- Our Lua tag content
      local luaTagContent = source:sub(iLuaStart, iLuaEnd + 1):match('{%%(.-)%%}') or ''
      table.insert(tPieces, luaTagContent)

      -- Removes parsed content
      source = source:sub(iLuaEnd + 2)
    else
      -- Adds remaining Lua as a single print statement
      table.insert(tPieces, mkPrint(source))

      -- Marks content as parsed
      source = ''
    end
  end

  -- Builds the Lua function
  self.code = table.concat(tPieces, '\n')

  -- Initializes our instance
  return setmetatable(self, Template)
end

-- By default, returns the constructor of our class
return Template.new