-- Loads our library
local STL = require('Template')

-- Hello World
local hello = STL('Hello, {{name}}!')
print('Hello:')
print(hello:render({ name = 'Gamers!' }))
print(hello:render({ name = 'World' }))
print('')

-- Just doing some quick maths
local adder = STL('The sum of A + B is {{ A + B }}')
print('Adder:')
print(adder:render({ A = 10, B = 15 }))
print(adder:render({ A = 5, B = 2 }))
print('')


-- Functions inside templates
local money = STL([[
  {% function money (value) return string.format('$%.2f', value) end %}
  We have {{ money(amount) }} in bank!
]])
--[[
print('Money:')
print(money:render({ amount = 200 }))
print(money:render({ amount = 49.95 }))
print('')
--]]

-- If-Else conditions
local ifelse = STL([[
  Greeting:
  {% if name == 'Wolfe' %}
    Salve, {{ name }}!
  {% else %}
    Hello, {{name}}!
  {% endif %}
]])
print('If-Else:')
print(ifelse:render({ name = 'Leniver' }))
print(ifelse:render({ name = 'Wolfe' }))
print('')

-- If-ElseIf-Else conditions
local ifelseifelse = STL([[
  Greeting:
  {% if name == 'Wolfe' %}
    Salve, {{ name }}!
  {% elseif name == 'Yoarii' %}
    Hey, {{ name }}
  {% else %}
    Hello, {{name}}!
  {% endif %}
]])
print('If-ElseIf-Else:')
print(ifelseifelse:render({ name = 'Leniver' }))
print(ifelseifelse:render({ name = 'Yoarii' }))
print(ifelseifelse:render({ name = 'Wolfe' }))
print('')

-- Custom (external) functions!
local function handleCustomFunction(value)
  return '[ Custom: ' .. value .. ' ]'
end
local custom = STL('You said: {{ custom(str) }}', {
  custom = handleCustomFunction,
})
--[[
print('External Function:')
print(custom:render({ str = 'Testing!' }))
print(custom:render({ str = 'Henlo :)' }))
print('')
--]]