-- [ Shmuel Zeigerman; Nov-Nov 2006 ]

module (..., package.seeall)

local fw = require "framework"

function testlib (libname)
  print ("[Library: " .. libname .. "]")
  local lib = require (libname)
  lib:flags()

  local N = fw.NT

  local set_f_gmatch = {
    -- gmatch (s, p, [cf], [ef])
    SetName = "Function gmatch",
    Test = "custom",
    Func = function (lib)
      local rep = 10
      local subj = string.rep ("abcd", rep)
      for a, b in lib.gmatch (subj, "(.)b.(d)") do
        if a == "a" and b == "d" then rep = rep - 1 end
      end
      if rep ~= 0 then return 1 end
      return 0
    end
  }

  local set_m_gmatch = {
    -- r:gmatch (s, [ef])
    SetName = "Method gmatch",
    Test = "custom",
    Func = function (lib)
      local rep = 10
      local subj = string.rep ("abcd", rep)
      local r = lib.new ("(.)b.(d)")
      for a, b in r:gmatch (subj) do
        if a == "a" and b == "d" then rep = rep - 1 end
      end
      if rep ~= 0 then return 1 end
      return 0
    end
  }

  local set_m_tgfind = {
    -- r:tgfind (s, f, [n], [ef])
    SetName = "Method tgfind",
    Test = "custom",
    Func = function (lib)
      local r = lib.new ("(.)b.(d)")
      local subj = string.rep ("abcd", 10)
      local rep, n
      -------- 1:  simple case
      rep = 10
      local decr = function (m, t)
        if m == "abcd" and fw.eq (t, {"a","d"}) then rep = rep - 1 end
      end
      r:tgfind (subj, decr)
      if rep ~= 0 then return 1 end
      -------- 2:  limiting number of matches in advance
      rep, n = 10, 4
      r:tgfind (subj, decr, n)
      if rep + n ~= 10 then return 1 end
      -------- 3:  break iterations from the callback
      rep = 10
      local f2 = function (m, t)
        decr (m, t)
        if rep == 3 then return true end
      end
      r:tgfind (subj, f2)
      if rep ~= 3 then return 1 end
      return 0
    end
  }

  local set_f_find = {
    SetName = "Function find",
    FMName = "find",
    Test = "function",
  --  { subj,  patt,  st, cf, ef }              { results }
    { {"abcd", ".+"},                           { 1,4 }   }, -- [none]
    { {"abcd", ".+",  2},                       { 2,4 }   }, -- positive st
    { {"abcd", ".+", -2},                       { 3,4 }   }, -- negative st
    { {"abcd", ".+",  5},                       { N,lib.NOMATCH }}, -- failing st
    { {"abcd", ".*"},                           { 1,4 }   }, -- [none]
    { {"abc", "aBC",  N, lib.ICASE},            { 1,3 }   }, -- cf
    { {"abc", "bc"},                            { 2,3 }   }, -- [none]
    { {"abc", "^abc"},                          { 1,3 }   }, -- anchor
    { {"abc", "^abc", N, N, lib.NOTBOL},        { N,lib.NOMATCH }}, -- anchor + ef
    { {"abcd", "(.)b.(d)"},                     { 1,4,"a","d" }},--[captures]
  }

  local set_m_find = {
    SetName = "Method find",
    FMName = "find",
    Test = "method",
  --  {patt,cf},            {subj,st,ef}             { results }
    { {".+"},               {"abcd"},                { 1,4 }   }, -- [none]
    { {".+"},               {"abcd",2},              { 2,4 }   }, -- positive st
    { {".+"},               {"abcd",-2},             { 3,4 }   }, -- negative st
    { {".+"},               {"abcd",5},              { N,lib.NOMATCH }}, -- failing st
    { {".*"},               {"abcd"},                { 1,4 }   }, -- [none]
    { {"aBC",lib.ICASE},    {"abc"},                 { 1,3 }   }, -- cf
    { {"bc"},               {"abc"},                 { 2,3 }   }, -- [none]
    { {"^abc"},             {"abc"},                 { 1,3 }   }, -- anchor
    { {"^abc"},             {"^abc",N,lib.NOTBOL},   { N,lib.NOMATCH }}, -- anchor + ef
    { { "(.)b.(d)"},        {"abcd"},                { 1,4,"a","d" }},--[captures]
  }

  local set_f_match = {
    SetName = "Function match",
    FMName = "match",
    Test = "function",
  --  { subj,  patt,  st, cf, ef }              { results }
    { {"abcd", ".+"},                           {"abcd"}  }, -- [none]
    { {"abcd", ".+",  2},                       { "bcd"}  }, -- positive st
    { {"abcd", ".+", -2},                       { "cd" }  }, -- negative st
    { {"abcd", ".+",  5},                       { N,lib.NOMATCH }}, -- failing st
    { {"abcd", ".*"},                           {"abcd"}  }, -- [none]
    { {"abc", "aBC",  N, lib.ICASE},            {"abc" }  }, -- cf
    { {"abc", "bc"},                            { "bc" }  }, -- [none]
    { {"abc", "^abc"},                          {"abc" }  }, -- anchor
    { {"abc", "^abc", N, N, lib.NOTBOL},        { N,lib.NOMATCH }}, -- anchor + ef
    { {"abcd", "(.)b.(d)"},                     { "a","d" }},--[captures]
  }

  local set_m_match = {
    SetName = "Method match",
    FMName = "match",
    Test = "method",
  --  {patt,cf},            {subj,st,ef}             { results }
    { {".+"},               {"abcd"},                {"abcd"}  }, -- [none]
    { {".+"},               {"abcd",2},              { "bcd"}  }, -- positive st
    { {".+"},               {"abcd",-2},             { "cd" }  }, -- negative st
    { {".+"},               {"abcd",5},              { N,lib.NOMATCH }}, -- failing st
    { {".*"},               {"abcd"},                {"abcd"}  }, -- [none]
    { {"aBC",lib.ICASE},    {"abc"},                 {"abc" }  }, -- cf
    { {"bc"},               {"abc"},                 { "bc" }  }, -- [none]
    { {"^abc"},             {"abc"},                 {"abc" }  }, -- anchor
    { {"^abc"},             {"^abc",N,lib.NOTBOL},   { N,lib.NOMATCH }}, -- anchor + ef
    { { "(.)b.(d)"},        {"abcd"},                { "a","d" }},--[captures]
  }

  local set_m_exec = {
    SetName = "Method exec",
    FMName = "exec",
    Test = "method",
  --  {patt,cf},            {subj,st,ef}             { results }
    { {".+"},               {"abcd"},                {1,4,{},0}  }, -- [none]
    { {".+"},               {"abcd",2},              {2,4,{},0}  }, -- positive st
    { {".+"},               {"abcd",-2},             {3,4,{},0}  }, -- negative st
    { {".+"},               {"abcd",5},              { N,lib.NOMATCH }}, -- failing st
    { {".*"},               {"abcd"},                {1,4,{},0}  }, -- [none]
    { {"aBC",lib.ICASE},    {"abc"},                 {1,3,{},0}  }, -- cf
    { {"bc"},               {"abc"},                 {2,3,{},0}  }, -- [none]
    { {"^abc"},             {"abc"},                 {1,3,{},0}  }, -- anchor
    { {"^abc"},             {"^abc",N,lib.NOTBOL},   { N,lib.NOMATCH }}, -- anchor + ef
    { { "(.)b.(d)"},        {"abcd"},                {1,4,{1,1,4,4},0}},--[captures]
  }

  local set_m_tfind = {
    SetName = "Method tfind",
    FMName = "tfind",
    Test = "method",
  --  {patt,cf},            {subj,st,ef}              { results }
    { {".+"},               {"abcd"},                 {1,4,{},0}  }, -- [none]
    { {".+"},               {"abcd",2},               {2,4,{},0}  }, -- positive st
    { {".+"},               {"abcd",-2},              {3,4,{},0}  }, -- negative st
    { {".+"},               {"abcd",5},               { N,lib.NOMATCH }}, -- failing st
    { {".*"},               {"abcd"},                 {1,4,{},0}  }, -- [none]
    { {"aBC",lib.ICASE},    {"abc"},                  {1,3,{},0}  }, -- cf
    { {"bc"},               {"abc"},                  {2,3,{},0}  }, -- [none]
    { {"^abc"},             {"abc"},                 {1,3,{},0}  }, -- anchor
    { {"^abc"},             {"^abc",N,lib.NOTBOL},   { N,lib.NOMATCH }}, -- anchor + ef
    { { "(.)b.(d)"},        {"abcd"},                 {1,4,{"a","d"},0}}, --[captures]
  }

  local set_f_plainfind = {
    SetName = "Function plainfind",
    FMName = "plainfind",
    Test = "function",
  --  { subj,  patt,  st, ci }    { results }
    { {"abcd", "bc"},             {2,3} }, -- [none]
    { {"abcd", "dc"},             {N}   }, -- [none]
    { {"abcd", "cd"},             {3,4} }, -- positive st
    { {"abcd", "cd", 3},          {3,4} }, -- positive st
    { {"abcd", "cd", 4},          {N}   }, -- failing st
    { {"abcd", "bc", 2},          {2,3} }, -- positive st
    { {"abcd", "bc", -4},         {2,3} }, -- negative st
    { {"abcd", "bc", 3},          {N}   }, -- failing st
    { {"abcd", "BC"},             {N}   }, -- case sensitive
    { {"abcd", "BC", N, true},    {2,3} }, -- case insensitive
    { {"ab\0cd", "b\0c"},         {2,4} }, -- contains nul
  }

  do
    local n = 0 -- number of failures
    n = n + fw.test2 (lib, set_f_match)
    n = n + fw.test2 (lib, set_f_find)
    n = n + fw.test2 (lib, set_f_plainfind)
    n = n + fw.test2 (lib, set_m_match)
    n = n + fw.test2 (lib, set_m_find)
    n = n + fw.test2 (lib, set_m_exec)
    n = n + fw.test2 (lib, set_m_tfind)
    n = n + fw.test2 (lib, set_f_gmatch)
    n = n + fw.test2 (lib, set_m_gmatch)
    n = n + fw.test2 (lib, set_m_tgfind)
    print ""
    return n
  end
end

