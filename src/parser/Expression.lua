---@class Expression
---@field __value string
---@field __type string
Expression = {}
Expression.__index = Expression

local concat = table.concat

---@param str string
---@param vars table
---@return string
local function buildValue(str, vars)
    local r, _, v, o1, f1, o2, f2, o3, f3, o4, f4 = str:find("([^%|%+%-/%*]+)([%|%+%-/%*]?)([^%|%+%-/%*]*)([%|%+%-/%*]?)([^%|%+%-/%*]*)([%|%+%-/%*]?)([^%|%+%-/%*]*)([%|%+%-/%*]?)([^%|%+%-/%*]*)")
    if r == nil then
        return str
    end
    local vvars = vars
    for p in str:gmatch("([^%.]+)") do
        if type(vvars) ~= "table" or vvars[p] == nil then
            return str
        end
        if type(vvars[p]) == "function" then
            local e, nvars = pcall(vvars[p])
            if not e or nvars == nil then
                return str
            end
            vvars = nvars
        else
            vvars = vvars[p]
        end
    end
    ---@type any
    local value = vvars
    local type = type(value)
    while type == "function" or type == "table" do
        if type == "table" then
            return str
        elseif type == "function" then
            local e, nv = pcall(vvars)
            if not e or nv == nil then
                return str
            end
            value = nv
        end
        type = type(value)
    end

    local operators = { o1, o2, o3, o4 } --- TODO find maybe a way to get that directly from find
    local operants = { f1, f2, f3, f4 } --- TODO find maybe a way to get that directly from find

    for i = 1, #operants do
        if operants[i] ~= nil and operators[i] ~= nil then
            local operant = operants[i]:trim()
            if operant:len() > 0 then
                if operators[i] ~= "|" then
                    local a = tonumber(value) or 0
                    local b = tonumber(Expression.new(operant):evalString(vars)) or 0
                    if operators[i] == "+" then
                        value = a + b
                    elseif operators[i] == "-" then
                        value = a + b
                    elseif operators[i] == "*" then
                        value = a * b
                    elseif operators[i] == "/" then
                        if b == 0 then
                            error(('"%s / %s" : Cannot devide by 0'):format(value, operant))
                        end
                        value = a / b
                    end
                else
                    local arguments = "" --- TODO parse filter arguments
                    if Filters[operant] == nil then
                        error(('"%s" filter does not exist'):format(operant))
                    else
                        value = Filters[operant](arguments):execute(value)
                    end
                end
            end
        end
    end

    return tostring(value)
end

local function extractParenthese(chars, i)
    local endCount = 0
    local startCount = 0
    local expression = {}
    local index = i + 1
    for j = i + 1, #chars do
        if chars[j] == ')' then
            endCount = endCount + 1
        elseif chars[j] == '(' then
            startCount = startCount + 1
        else
            expression[#expression + 1] = chars[j]
        end
        if endCount > startCount then
            break
        end
        index = j
    end
    if endCount <= startCount then
        error(('"%s" has a non-closed parenthezis'):format(concat(chars)))
    end
    return concat(expression), index + 1
end

local function evaluateExpression(expression, vars)
    local count = #expression
    if count == 0 then
        error("Parsing error: empty expression")
    end

    local negate = false
    local offset = 0
    if expression[1] == '!' then
        offset = 1
        negate = true
    end

    count = count - offset
    if count == 1 then
        local e = expression[1 + offset]
        local result = (type(e) == "string" and e:toBool()) or e:eval(vars, true)
        if negate then
            return not result
        else
            return result
        end
    elseif count == 3 then
        local e = expression[1 + offset]
        local e1 = (type(e) == "string" and e) or e:eval(vars)
        local operator = expression[2 + offset]
        e = expression[3 + offset]
        local e2 = (type(e) == "string" and e) or e:eval(vars)
        if operator == ">" then
            return e1 > e2
        elseif operator == ">=" then
            return e1 >= e2
        elseif operator == "<" then
            return e1 < e2
        elseif operator == "<=" then
            return e1 <= e2
        elseif operator == "==" then
            return tostring(e1) == tostring(e2)
        elseif operator == "!=" then
            return tostring(e1) ~= tostring(e2)
        else
            error("Parsing error: comparison operator not recognized")
        end
    else
        error("Parsing error: expression can only have 1 element or 3")
    end
end

---@param value string
---@param type? string
---@return Expression
function Expression.new(value, type)
    local self = setmetatable({}, Expression)

    self.__value = value or ""
    self.__type = type or "litteral"

    return self
end

function Expression:eval(vars, forceBoolean)
    if self.__type == "boolean" then
        return self:evalBoolean(vars)
    elseif forceBoolean then
        return self:evalString(vars):toBool()
    else
        return self:evalString(vars)
    end
end

function Expression:evalBoolean(vars)
    local chars = {}
    for i in string.gmatch(self.__value, "(.)") do
        chars[#chars + 1] = i
    end
    local elements = {}
    local expressions = {}
    local currentOperator = 'and'
    local i = 1
    local count = #chars
    while i <= count do
        if chars[i] ~= ' ' then
            if chars[i] == '"' or chars[i] == "'" then
                local s, e, element = self.__value:find('([^' .. chars[i] .. '\\]+)' .. chars[i], i)
                if s == nil then
                    error(('"%s" has a non-closed litteral string'):format(self.__value))
                end
                i = e + 1
                elements[#elements + 1] = element
            elseif chars[i] == '(' then
                local expression, j = extractParenthese(chars, i)
                elements[#elements + 1] = Expression.new(expression, "boolean")
                i = j
            elseif chars[i] == '<' or chars[i] == '>' or chars[i] == '=' or chars[i] == '!' then
                local operator = chars[i]
                if chars[i + 1] == '=' then
                    i = i + 1
                    operator = operator .. chars[i]
                elseif chars[i] == '!' and #elements > 0 then
                    error(('"%s" negate operator can only be at start of the expression'):format(self.__value))
                elseif chars[i] == '=' then
                    error(('"%s" equal expression is missing an ='):format(self.__value))
                end
                elements[#elements + 1] = operator
            else
                local s, e, operator = self.__value:find("(and|or)%s", i)
                if s ~= nil then
                    if currentOperator == 'and' then
                        expressions[#expressions + 1] = { elements }
                    else
                        expressions[#expressions][#expressions[#expressions] + 1] = elements
                    end
                    currentOperator = operator
                    i = e + 1
                else
                    local ss, ee, variable = self.__value:find("([^%(%s]+)", i)
                    if ss == nil then
                        error(('Something wrong happens while parsing the expression "%s"(%s)'):format(self.__value, i))
                    end
                    i = ee + 1
                    if chars[i] == '(' then
                        local expression, j = extractParenthese(chars, i)
                        variable = variable .. '(' .. expression .. ')'
                        i = j
                    end
                    elements[#elements + 1] = Expression.new(variable)
                end
            end
        end
        i = i + 1
    end
    if #elements > 0 then
        if currentOperator == 'and' then
            expressions[#expressions + 1] = { elements }
        else
            expressions[#expressions][#expressions[#expressions] + 1] = elements
        end
        elements = {}
    end

    for i = 1, #expressions do
        local result = false
        for j = 1, #expressions[i] do
            result = evaluateExpression(expressions[i][j], vars)
            if result then
                break
            end
        end
        if not result then
            return false
        end
    end
    return true
end

function Expression:evalString(vars)
    return buildValue(self.__value, vars)
end
