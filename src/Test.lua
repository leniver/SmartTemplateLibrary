local tmpl = require('Template')

local test1 = tmpl('Hello, {{name}}!')
print(test1{ name = 'Matt' })
print(test1{ name = 'Wolfe' })

local test2 = tmpl([[
  Welcome:
  {% if name == 'Wolfe' then %}
    Salve, {{ name }}!
  {% else %}
    Hello, {{ name }}!
  {% end %}
]])

print(test2{ name = 'Matt' })
print(test2{ name = 'JC' })
print(test2{ name = 'Wolfe' })

local test3 = tmpl([[
{% function add (a, b) return a + b end %}
{{ add(1, 2) }}
]])

print(test3())