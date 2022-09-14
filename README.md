# Smart Template Library (STL)

A library that provides a simple smart template library, written in Lua. It uses a syntax similar to Twig:

`{{ variable }}` will print any variable existing on the current environment

`{% some_lua %}` will execute the lua in place of `some_lua`

You can use normal Lua inside `{% ... %}` blocks, so for example, this is a simple conditional check:

```
Greeting:
{% if name == 'Wolfe' then %}
  Hola, {{ name }}!
{% else %}
  Hello, {{ name }}!
{% end %}
```

When provided with the "Wolfe" name, the output will be "Hola, Wolfe!" while in any other case the output will be "Hello, Your Name Here!"

## Usage

The library is very simple and doesn't provide many functions, it's focused for usage in games (specially Dual Universe), where script space is often limited.

After using `require` to bring the library to your code, you can build a template by invoking it straight away. It will return an instance of that template, which can be executed by invoking that instance:

```lua
-- Imports our template library
STL = require('Template')

-- Compiles our template
hello = STL('Hello, {{name}}!')

-- Executes our template and prints its result for a few different names:
print(hello{ name = 'Matt' })
print(hello{ name = 'Wolfe' })
print(hello{ name = 'Example' })
```