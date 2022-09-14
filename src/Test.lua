-- Loads our library
local STL = require('Template')

-- Hello World
local hello = STL('Hello, {{name}}!')
print('Hello:')
print(hello{ name = 'Gamers!' })
print(hello{ name = 'World' })
print('')

-- Just doing some quick maths
local adder = STL('The sum of A + B is {{ A + B }}')
print('Adder:')
print(adder{ A = 10, B = 15 })
print(adder{ A = 5, B = 2 })
print('')

-- Functions inside templates
local money = STL([[
  {% function money (value) return string.format('$%.2f', value) end %}
  We have {{ money(amount) }} in bank!
]])
print('Money:')
print(money{ amount = 200 })
print(money{ amount = 49.95 })
print('')

-- If-Else conditions
local ifelse = STL([[
  Greeting:
  {% if name == 'Wolfe' then %}
    Salve, {{ name }}!
  {% else %}
    Hello, {{name}}!
  {% end %}
]])
print('If-Else:')
print(ifelse{ name = 'Leniver' })
print(ifelse{ name = 'Wolfe' })
print('')

-- Custom (external) functions!
local function handleCustomFunction(value)
  return '[ Custom: ' .. value .. ' ]'
end
local custom = STL('You said: {{ custom(str) }}', {
  custom = handleCustomFunction,
})
print('External Function:')
print(custom{ str = 'Testing!' })
print(custom{ str = 'Henlo :)' })
print('')