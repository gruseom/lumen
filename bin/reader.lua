local delimiters = {["("] = true, ["\n"] = true, [")"] = true, [";"] = true}
local whitespace = {["\n"] = true, ["\t"] = true, [" "] = true}
local function stream(str, more)
  return({len = _35(str), string = str, more = more, pos = 0})
end
local function peek_char(s)
  local _id = s
  local string = _id.string
  local len = _id.len
  local pos = _id.pos
  if pos < len then
    return(char(string, pos))
  end
end
local function read_char(s)
  local c = peek_char(s)
  if c then
    s.pos = s.pos + 1
    return(c)
  end
end
local function skip_non_code(s)
  while true do
    local c = peek_char(s)
    if nil63(c) then
      break
    else
      if whitespace[c] then
        read_char(s)
      else
        if c == ";" then
          while c and not( c == "\n") do
            c = read_char(s)
          end
          skip_non_code(s)
        else
          break
        end
      end
    end
  end
end
local read_table = {}
local eof = {}
local function read(s)
  skip_non_code(s)
  local c = peek_char(s)
  if is63(c) then
    return((read_table[c] or read_table[""])(s))
  else
    return(eof)
  end
end
local function read_all(s)
  local l = {}
  while true do
    local form = read(s)
    if form == eof then
      break
    end
    add(l, form)
  end
  return(l)
end
function read_string(str, more)
  local x = read(stream(str, more))
  if not( x == eof) then
    return(x)
  end
end
local function key63(atom)
  return(string63(atom) and _35(atom) > 1 and char(atom, edge(atom)) == ":")
end
local function flag63(atom)
  return(string63(atom) and _35(atom) > 1 and char(atom, 0) == ":")
end
local function expected(s, c)
  local _id1 = s
  local more = _id1.more
  local pos = _id1.pos
  local _id2 = more
  local _e
  if _id2 then
    _e = _id2
  else
    error("Expected " .. c .. " at " .. pos)
    _e = nil
  end
  return(_e)
end
local function wrap(s, x)
  local y = read(s)
  if y == s.more then
    return(y)
  else
    return({x, y})
  end
end
local function maybe_number(str)
  if number_code63(code(str, edge(str))) then
    return(number(str))
  end
end
local function real63(x)
  return(number63(x) and not nan63(x) and not inf63(x))
end
local function valid_access63(str)
  return(_35(str) > 2 and not( "." == char(str, 0)) and not( "." == char(str, edge(str))) and not search(str, ".."))
end
local function parse_access(str)
  return(reduce(function (a, b)
    local n = number(a)
    if is63(n) then
      return({"at", b, n})
    else
      return({"get", b, {"quote", a}})
    end
  end, reverse(split(str, "."))))
end
read_table[""] = function (s)
  local str = ""
  local dot63 = false
  while true do
    local c = peek_char(s)
    if c and (not whitespace[c] and not delimiters[c]) then
      if c == "." then
        dot63 = true
      end
      str = str .. read_char(s)
    else
      break
    end
  end
  if str == "true" then
    return(true)
  else
    if str == "false" then
      return(false)
    else
      if str == "nan" then
        return(nan)
      else
        if str == "-nan" then
          return(nan)
        else
          if str == "inf" then
            return(inf)
          else
            if str == "-inf" then
              return(-inf)
            else
              local n = maybe_number(str)
              if real63(n) then
                return(n)
              else
                if dot63 and valid_access63(str) then
                  return(parse_access(str))
                else
                  return(str)
                end
              end
            end
          end
        end
      end
    end
  end
end
read_table["("] = function (s)
  read_char(s)
  local r = nil
  local l = {}
  while nil63(r) do
    skip_non_code(s)
    local c = peek_char(s)
    if c == ")" then
      read_char(s)
      r = l
    else
      if nil63(c) then
        r = expected(s, ")")
      else
        local x = read(s)
        if key63(x) then
          local k = clip(x, 0, edge(x))
          local v = read(s)
          l[k] = v
        else
          if flag63(x) then
            l[clip(x, 1)] = true
          else
            add(l, x)
          end
        end
      end
    end
  end
  return(r)
end
read_table[")"] = function (s)
  error("Unexpected ) at " .. s.pos)
end
read_table["\""] = function (s)
  read_char(s)
  local r = nil
  local str = "\""
  while nil63(r) do
    local c = peek_char(s)
    if c == "\"" then
      r = str .. read_char(s)
    else
      if nil63(c) then
        r = expected(s, "\"")
      else
        if c == "\\" then
          str = str .. read_char(s)
        end
        str = str .. read_char(s)
      end
    end
  end
  return(r)
end
read_table["|"] = function (s)
  read_char(s)
  local r = nil
  local str = "|"
  while nil63(r) do
    local c = peek_char(s)
    if c == "|" then
      r = str .. read_char(s)
    else
      if nil63(c) then
        r = expected(s, "|")
      else
        str = str .. read_char(s)
      end
    end
  end
  return(r)
end
read_table["'"] = function (s)
  read_char(s)
  return(wrap(s, "quote"))
end
read_table["`"] = function (s)
  read_char(s)
  return(wrap(s, "quasiquote"))
end
read_table[","] = function (s)
  read_char(s)
  if peek_char(s) == "@" then
    read_char(s)
    return(wrap(s, "unquote-splicing"))
  else
    return(wrap(s, "unquote"))
  end
end
return({["read-all"] = read_all, ["read-string"] = read_string, stream = stream, ["read-table"] = read_table, read = read})
