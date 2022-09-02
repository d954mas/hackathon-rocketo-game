--
-- lume
--
-- Copyright (c) 2018 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local lume = { _version = "2.3.0" }

local pairs, ipairs = pairs, ipairs
local type, assert, unpack = type, assert, unpack --or table.unpack
local tostring, tonumber = tostring, tonumber
local math_floor = math.floor
local math_ceil = math.ceil
local math_atan2 = math.atan2
local math_sqrt = math.sqrt
local math_abs = math.abs

local noop = function()
end

local identity = function(x)
    return x
end

local patternescape = function(str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

local absindex = function(len, i)
    return i < 0 and (len + i + 1) or i
end

local iscallable = function(x)
    if type(x) == "function" then return true end
    local mt = getmetatable(x)
    return mt and mt.__call ~= nil
end

local getiter = function(x)
    if lume.isarray(x) then
        return ipairs
    elseif type(x) == "table" then
        return pairs
    end
    error("expected table", 3)
end

local iteratee = function(x)
    if x == nil then return identity end
    if iscallable(x) then return x end
    if type(x) == "table" then
        return function(z)
            for k, v in pairs(x) do
                if z[k] ~= v then return false end
            end
            return true
        end
    end
    return function(z) return z[x] end
end

function lume.clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

function lume.round(x, increment)
    if increment then return lume.round(x / increment) * increment end
    return x >= 0 and math_floor(x + .5) or math_ceil(x - .5)
end

function lume.sign(x)
    return x < 0 and -1 or 1
end

function lume.lerp(a, b, amount)
    return a + (b - a) * lume.clamp(amount, 0, 1)
end

function lume.smooth(a, b, amount)
    local t = lume.clamp(amount, 0, 1)
    local m = t * t * (3 - 2 * t)
    return a + (b - a) * m
end

function lume.pingpong(x)
    return 1 - math_abs(1 - x % 2)
end

function lume.distance(x1, y1, x2, y2, squared)
    local dx = x1 - x2
    local dy = y1 - y2
    local s = dx * dx + dy * dy
    return squared and s or math_sqrt(s)
end

function lume.angle(x1, y1, x2, y2)
    return math_atan2(y2 - y1, x2 - x1)
end

function lume.angle_vector(x, y)
    return math_atan2(y, x)
end

function lume.normalize_angle_deg(deg)
    deg = deg % 360;
    if (deg < 0) then deg = deg + 360 end
    return deg
end

function lume.normalize_angle_rad(rad)
    return math.rad(lume.normalize_angle_deg(math.deg(rad)))
end

function lume.vector(angle, magnitude)
    return math.cos(angle) * magnitude, math.sin(angle) * magnitude
end

function lume.random(a, b)
    if not a then
        a, b = 0, 1
    end
    if not b then
        b = 0
    end
    return a + math.random() * (b - a)
end

function lume.randomchoice(t)
    return t[math.random(#t)]
end

function lume.weightedchoice(t)
    local sum = 0
    for _, v in pairs(t) do
        assert(v >= 0, "weight value less than zero")
        sum = sum + v
    end
    assert(sum ~= 0, "all weights are zero")
    local rnd = lume.random(sum)
    for k, v in pairs(t) do
        if rnd < v then
            return k
        end
        rnd = rnd - v
    end
end

function lume.isarray(x)
    return (type(x) == "table" and x[1] ~= nil) and true or false
end

function lume.push(t, ...)
    local n = select("#", ...)
    for i = 1, n do
        t[#t + 1] = select(i, ...)
    end
    return ...
end

function lume.remove(t, x)
    local iter = getiter(t)
    for i, v in iter(t) do
        if v == x then
            if lume.isarray(t) then
                table.remove(t, i)
                break
            else
                t[i] = nil
                break
            end
        end
    end
    return x
end

function lume.removei(t, value)
    local iter = ipairs
    for k, v in iter(t) do
        if v == value then
            return table.remove(t, k)
        end
    end
end

function lume.clear(t)
    local iter = getiter(t)
    for k in iter(t) do
        t[k] = nil
    end
    return t
end

function lume.clearp(t)
    for k, v in pairs(t) do
        t[k] = nil
    end
    return t
end
function lume.cleari(t)
    for k, v in ipairs(t) do
        t[k] = nil
    end
    return t
end

function lume.extend(t, ...)
    for i = 1, select("#", ...) do
        local x = select(i, ...)
        if x then
            for k, v in pairs(x) do
                t[k] = v
            end
        end
    end
    return t
end

function lume.shuffle(t)
    local rtn = {}
    for i = 1, #t do
        local r = math.random(i)
        if r ~= i then
            rtn[i] = rtn[r]
        end
        rtn[r] = t[i]
    end
    return rtn
end

function lume.sort(t, comp)
    local rtn = lume.clone(t)
    if comp then
        if type(comp) == "string" then
            table.sort(rtn, function(a, b) return a[comp] < b[comp]
            end)
        else
            table.sort(rtn, comp)
        end
    else
        table.sort(rtn)
    end
    return rtn
end

function lume.array(...)
    local t = {}
    for x in ... do
        t[#t + 1] = x
    end
    return t
end

function lume.each(t, fn, ...)
    local iter = getiter(t)
    if type(fn) == "string" then
        for _, v in iter(t) do
            v[fn](v, ...)
        end
    else
        for _, v in iter(t) do
            fn(v, ...)
        end
    end
    return t
end

function lume.map(t, fn)
    fn = iteratee(fn)
    local iter = getiter(t)
    local rtn = {}
    for k, v in iter(t) do rtn[k] = fn(v)
    end
    return rtn
end

function lume.all(t, fn)
    fn = iteratee(fn)
    local iter = getiter(t)
    for _, v in iter(t) do
        if not fn(v) then
            return false
        end
    end
    return true
end

function lume.any(t, fn)
    fn = iteratee(fn)
    local iter = getiter(t)
    for _, v in iter(t) do
        if fn(v) then
            return true
        end
    end
    return false
end

function lume.reduce(t, fn, first)
    local acc = first
    local started = first and true or false
    local iter = getiter(t)
    for _, v in iter(t) do
        if started then
            acc = fn(acc, v)
        else
            acc = v
            started = true
        end
    end
    assert(started, "reduce of an empty table with no first value")
    return acc
end

function lume.unique(t)
    local rtn = {}
    for k in pairs(lume.invert(t)) do
        rtn[#rtn + 1] = k
    end
    return rtn
end

function lume.iftern(bool, vtrue, vfalse)
    if bool then return vtrue else return vfalse end
end

function lume.filter(t, fn, retainkeys)
    fn = iteratee(fn)
    local iter = getiter(t)
    local rtn = {}
    if retainkeys then
        for k, v in iter(t) do
            if fn(v) then
                rtn[k] = v
            end
        end
    else
        for _, v in iter(t) do
            if fn(v) then
                rtn[#rtn + 1] = v
            end
        end
    end
    return rtn
end

function lume.reject(t, fn, retainkeys)
    fn = iteratee(fn)
    local iter = getiter(t)
    local rtn = {}
    if retainkeys then
        for k, v in iter(t) do
            if not fn(v) then rtn[k] = v
            end
        end
    else
        for _, v in iter(t) do
            if not fn(v) then
                rtn[#rtn + 1] = v
            end
        end
    end
    return rtn
end

function lume.merge(...)
    local rtn = {}
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        local iter = getiter(t)
        for k, v in iter(t) do
            rtn[k] = v
        end
    end
    return rtn
end

function lume.concat(...)
    local rtn = {}
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        if t ~= nil then
            local iter = getiter(t)
            for _, v in iter(t) do
                rtn[#rtn + 1] = v
            end
        end
    end
    return rtn
end

function lume.find(t, value)
    local iter = getiter(t)
    for k, v in iter(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function lume.findi(t, value)
    local iter = ipairs
    for k, v in iter(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function lume.match(t, fn)
    fn = iteratee(fn)
    local iter = getiter(t)
    for k, v in iter(t) do
        if fn(v) then
            return v, k
        end
    end
    return nil
end

function lume.countp(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

function lume.count(t, fn)
    local count = 0
    local iter = getiter(t)
    if fn then
        fn = iteratee(fn)
        for _, v in iter(t) do
            if fn(v) then
                count = count + 1
            end
        end
    else
        if lume.isarray(t) then
            return #t
        end
        for _ in iter(t) do
            count = count + 1
        end
    end
    return count
end

function lume.slice(t, i, j)
    i = i and absindex(#t, i) or 1
    j = j and absindex(#t, j) or #t
    local rtn = {}
    for x = i < 1 and 1 or i, j > #t and #t or j do
        rtn[#rtn + 1] = t[x]
    end
    return rtn
end

function lume.first(t, n)
    if not n then return t[1]
    end
    return lume.slice(t, 1, n)
end

function lume.last(t, n)
    if not n then
        return t[#t]
    end
    return lume.slice(t, -n, -1)
end

function lume.invert(t)
    local rtn = {}
    for k, v in pairs(t) do rtn[v] = k
    end
    return rtn
end

function lume.pick(t, ...)
    local rtn = {}
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        rtn[k] = t[k]
    end
    return rtn
end

function lume.keys(t)
    local rtn = {}
    local iter = getiter(t)
    for k in iter(t) do
        rtn[#rtn + 1] = k
    end
    return rtn
end

---@generic T
---@param t T
---@return T
function lume.clone_shallow(t)
    local rtn = {}
    for k, v in pairs(t) do rtn[k] = v
    end
    return rtn
end

---@generic T
---@param t T
---@return T
function lume.clone(t)
    return lume.clone_shallow(t)
end

function lume.clone_deep(t)
    local orig_type = type(t)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, t, nil do
            copy[lume.clone_deep(orig_key)] = lume.clone_deep(orig_value)
        end
    else
        -- number, string, boolean, etc
        copy = t
    end
    return copy
end

function lume.fn(fn, ...)
    assert(iscallable(fn), "expected a function as the first argument")
    local args = { ... }
    return function(...)
        local a = lume.concat(args, { ... })
        return fn(unpack(a))
    end
end

function lume.once(fn, ...)
    local f = lume.fn(fn, ...)
    local done = false
    return function(...)
        if done then
            return
        end
        done = true
        return f(...)
    end
end

local memoize_fnkey = {}
local memoize_nil = {}

function lume.memoize(fn)
    local cache = {}
    return function(...)
        local c = cache
        for i = 1, select("#", ...) do
            local a = select(i, ...) or memoize_nil
            c[a] = c[a] or {}
            c = c[a]
        end
        c[memoize_fnkey] = c[memoize_fnkey] or { fn(...) }
        return unpack(c[memoize_fnkey])
    end
end

function lume.combine(...)
    local n = select('#', ...)
    if n == 0 then
        return noop
    end
    if n == 1 then
        local fn = select(1, ...)
        if not fn then
            return noop
        end
        assert(iscallable(fn), "expected a function or nil")
        return fn
    end
    local funcs = {}
    for i = 1, n do
        local fn = select(i, ...)
        if fn ~= nil then
            assert(iscallable(fn), "expected a function or nil")
            funcs[#funcs + 1] = fn
        end
    end
    return function(...)
        for _, f in ipairs(funcs) do
            f(...) end
    end
end

function lume.call(fn, ...)
    if fn then
        return fn(...)
    end
end

function lume.time(fn, ...)
    local start = socket.gettime()
    local rtn = { fn(...) }
    return (socket.gettime() - start), unpack(rtn)
end

local lambda_cache = {}

function lume.lambda(str)
    if not lambda_cache[str] then
        local args, body = str:match([[^([%w,_ ]-)%->(.-)$]])
        assert(args and body, "bad string lambda")
        local s = "return function(" .. args .. ")\nreturn " .. body .. "\nend"
        lambda_cache[str] = lume.dostring(s)
    end
    return lambda_cache[str]
end

local serialize

local serialize_map = {
    ["boolean"] = tostring,
    ["nil"] = tostring,
    ["string"] = function(v) return string.format("%q", v)
    end,
    ["number"] = function(v)
        if v ~= v then
            return "0/0"      --  nan
        elseif v == 1 / 0 then
            return "1/0"      --  inf
        elseif v == -1 / 0 then
            return "-1/0"
        end -- -inf
        return tostring(v)
    end,
    ["table"] = function(t, stk)
        stk = stk or {}
        if stk[t] then
            error("circular reference") end
        local rtn = {}
        stk[t] = true
        for k, v in pairs(t) do
            if k ~= "__fields__" then
                rtn[#rtn + 1] = " [" .. serialize(k, stk) .. "]=" .. serialize(v, stk)
            end
        end
        stk[t] = nil
        return " {" .. table.concat(rtn, ", ") .. "}"
    end
}

setmetatable(serialize_map, {
    __index = function(_, k) error("unsupported serialize type: " .. k)
    end
})

serialize = function(x, stk)
    return serialize_map[type(x)](x, stk)
end

function lume.serialize(x)
    return serialize(x)
end

function lume.deserialize(str)
    return lume.dostring("return " .. str)
end

function lume.split(str, sep)
    if not sep then
        return lume.array(str:gmatch("([%S]+)"))
    else
        assert(sep ~= "", "empty separator")
        local psep = patternescape(sep)
        return lume.array((str .. sep):gmatch("(.-)(" .. psep .. ")"))
    end
end

function lume.trim(str, chars)
    if not chars then
        return str:match("^[%s]*(.-)[%s]*$")
    end
    chars = patternescape(chars)
    return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

function lume.wordwrap(str, limit)
    limit = limit or 72
    local check
    if type(limit) == "number" then
        check = function(s) return #s >= limit
        end
    else
        check = limit
    end
    local rtn = {}
    local line = ""
    for word, spaces in str:gmatch("(%S+)(%s*)") do
        local s = line .. word
        if check(s) then
            table.insert(rtn, line .. "\n")
            line = word
        else
            line = s
        end
        for c in spaces:gmatch(".") do
            if c == "\n" then
                table.insert(rtn, line .. "\n")
                line = ""
            else
                line = line .. c
            end
        end
    end
    table.insert(rtn, line)
    return table.concat(rtn)
end

function lume.format(str, vars)
    if not vars then
        return str
    end
    local f = function(x)
        return tostring(vars[x] or vars[tonumber(x)] or "{" .. x .. "}")
    end
    return (str:gsub("{(.-)}", f))
end

function lume.trace(...)
    local info = debug.getinfo(2, "Sl")
    local t = { info.short_src .. ":" .. info.currentline .. ":" }
    for i = 1, select("#", ...) do
        local x = select(i, ...)
        if type(x) == "number" then
            x = string.format("%g", lume.round(x, .01))
        end
        t[#t + 1] = tostring(x)
    end
    print(table.concat(t, " "))
end

function lume.dostring(str)
    return assert((loadstring or load)(str))()
end

function lume.uuid()
    local fn = function(x)
        local r = math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function lume.hotswap(modname)
    local oldglobal = lume.clone(_G)
    local updated = {}
    local function update(old, new)
        if updated[old] then
            return
        end
        updated[old] = true
        local oldmt, newmt = getmetatable(old), getmetatable(new)
        if oldmt and newmt then
            update(oldmt, newmt)
        end
        for k, v in pairs(new) do
            if type(v) == "table" then
                update(old[k], v)
            else
                old[k] = v
            end
        end
    end
    local err = nil
    local function onerror(e)
        for k in pairs(_G) do
            _G[k] = oldglobal[k]
        end
        err = lume.trim(e)
    end
    local ok, oldmod = pcall(require, modname)
    oldmod = ok and oldmod or nil
    xpcall(function()
        package.loaded[modname] = nil
        local newmod = require(modname)
        if type(oldmod) == "table" then
            update(oldmod, newmod)
        end
        for k, v in pairs(oldglobal) do
            if v ~= _G[k] and type(v) == "table" then
                update(v, _G[k])
                _G[k] = v
            end
        end
    end, onerror)
    package.loaded[modname] = oldmod
    if err then
        return nil, err
    end
    return oldmod
end

local ripairs_iter = function(t, i)
    i = i - 1
    local v = t[i]
    if v then
        return i, v
    end
end

function lume.ripairs(t)
    return ripairs_iter, t, (#t + 1)
end

function lume.color(str, mul)
    mul = mul or 1
    local r, g, b, a
    r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
    if r then
        r = tonumber(r, 16) / 0xff
        g = tonumber(g, 16) / 0xff
        b = tonumber(b, 16) / 0xff
        a = 1
    elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
        local f = str:gmatch("[%d.]+")
        r = (f() or 0) / 0xff
        g = (f() or 0) / 0xff
        b = (f() or 0) / 0xff
        a = f() or 1
    else
        error(("bad color string '%s'"):format(str))
    end
    return r * mul, g * mul, b * mul, a * mul
end

function lume.merge_table(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                lume.merge_table(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function lume.mix_table(t1, t2)
    local t = {}
    for _, v in ipairs(t1) do
        table.insert(t, v)
    end
    for _, v in ipairs(t2) do
        table.insert(t, v)
    end
    return t
end

function lume.rgba(color)
    local a = math_floor((color / 16777216) % 256)
    local r = math_floor((color / 65536) % 256)
    local g = math_floor((color / 256) % 256)
    local b = math_floor((color) % 256)
    return r, g, b, a
end

local chain_mt = {}
chain_mt.__index = lume.map(lume.filter(lume, iscallable, true),
        function(fn)
            return function(self, ...)
                self._value = fn(self._value, ...)
                return self
            end
        end)
chain_mt.__index.result = function(x) return x._value
end

function lume.chain(value)
    return setmetatable({ _value = value }, chain_mt)
end

setmetatable(lume, {
    __call = function(_, ...)
        return lume.chain(...)
    end
})

local function __genOrderedIndex(t)
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert(orderedIndex, key)
    end
    table.sort(orderedIndex)
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex(t)
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, #t.__orderedIndex do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function lume.ordered_pairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

function lume.weakref(t)
    local weak = setmetatable({ content = assert(t) }, { __mode = "v" })
    return function()
        return weak.content
    end
end

--DO NOT USE IT)) SOMETHING WRONG WHEN START TO CHANGE VALUES
function lume.meta_getter(f)
    assert(type(f) == "function")
    local result = setmetatable({}, { __index = function(_, key)
        local t = f()
        if not t then
            print("not t for meta_getter", "MetaGetter")
            return nil
        end
        return t[key]
    end, __newindex = function()
        assert("can't change value")
    end })
    return result
end

--region READ_ONLY
--local function len(self)
-- return #self.__VALUE
--end
--[[
--TODO CHECK PERFORMANCE OF OVERRIDE FN
--http://lua-users.org/wiki/GeneralizedPairsAndIpairs
local rawnext = next
function next(t,k)
    local m = getmetatable(t)
    local n = m and m.__next or rawnext
    return n(t,k)
end

function pairs(t) return next, t, nil end

local function _ipairs(t, var)
    var = var + 1
    local value = t[var]
    if value == nil then return end
    return var, value
end
function ipairs(t) return _ipairs, t, 0 end
--]]
-- remember mappings from original table to proxy table
--local proxies = setmetatable({}, { __mode = "k" })

--__VALUE use to work with debugger or pprint
---@generic T
---@param t T
---@return T
function lume.read_only(t)
    --[[if type(t) == "table" then
        -- check whether we already have a readonly proxy for this table
        local p = proxies[t]
        if not p then
            -- create new proxy table for t
            p = setmetatable( {__VALUE = t,__len = len}, {
                __next = function(_, k) return next(t, k) end,
                __index = function(_, k) return t[k] end,
                __newindex = function() error( "table is readonly", 2 ) end,
            } )
            proxies[t] = p
        end
        return p
    else--]]
    return t
    --end
end

---@generic T
---@param t T
---@return T
function lume.read_only_recursive(t)
    --[[if type(t) == "table" then
        -- check whether we already have a readonly proxy for this table
        local p = proxies[t]
        if not p then
            -- create new proxy table for t
            p = setmetatable( {__VALUE = t,__len = len}, {
                --errors in debugger if k is read_only_recursive
                __next = function(_, k)
                    local key,v = next(t, k)
                    return key, M.read_only_recursive(v)
                end,
                __index = function(_, k) return M.read_only_recursive( t[ k ] ) end,
                __newindex = function() error( "table is readonly", 2 ) end,
            } )
            proxies[t] = p
        end
        return p
    else--]]
    -- non-tables are returned as is
    return t
    --end
end
--endregion

function lume.string_split(s, delimiter)
    local result = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

function lume.string_replace_pattern(string, pattern, value)
    return string:gsub(pattern, value);
end

function lume.string_end_with(string, ending)
    return ending == "" or string:sub(-#ending) == ending
end

function lume.string_start_with(str,start)
    return string.sub(str,1,string.len(start))==start
end


function lume.color_parse_hex(hex)
    local r, g, b, a = hex:match("#(%x%x)(%x%x)(%x%x)(%x?%x?)")
    if a == "" then a = "ff" end
    if r and g and b and a then
        return vmath.vector4(tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255)
    end
    return nil
end

function lume.color_parse_hex2(hex)
    local a, r, g, b = hex:match("#(%x%x)(%x%x)(%x%x)(%x?%x?)")
    -- if a == "" then a = "ff" end
    if r and g and b and a then
        return vmath.vector4(tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255)
    end
    return nil
end

---@param url url
function lume.url_component_from_url(url, component)
    return msg.url(url.socket, url.path, component)
end

---@param url url
function lume.file_exist(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    else return false end
end

function lume.get_human_time(seconds)
	seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds / 3600));
		local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
		--local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
		if hours == '00' then
			return mins --.. ":" .. secs
		else
			return hours .. ":" .. mins --.. ":" .. secs
		end
	end
end

return lume
