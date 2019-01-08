#!/usr/bin/env luajit

-- Le dictionnaire doit être trié pour que les anagrammes le soient
-- aussi.

local function build_freqs(s)
   local t = {}
   for i = 0, #s do
      local c = s:sub(i, i)
      if not t[c] then
         t[c] = 1
      else
         t[c] = t[c] + 1
      end
   end
   return t
end

local function is_anagram(freqs, s)
   local is_subtbl = function(t1, t2)
      for k, v in pairs(t1) do
         if t2[k] ~= v then
            return false
         end
      end
      return true
   end
   local freqs_s = build_freqs(s)
   return is_subtbl(freqs, freqs_s) and is_subtbl(freqs_s, freqs)
end

local function main()
   local dict = assert(io.open(arg[1], "r"))
   local freqs, anagrams = {}, {}
   for i = 0, #arg - 2 do
      freqs[i] = build_freqs(arg[i + 2])
      anagrams[i] = {}
   end
   for line in dict:lines() do
      for i, freq in ipairs(freqs) do
         if is_anagram(freq, line) then
            table.insert(anagrams[i], line)
         end
      end
   end
   dict:close()
   for i, words in ipairs(anagrams) do
      io.write(arg[i + 2]); io.write(":\n")
      for _, word in ipairs(words) do
         io.write(word); io.write("\n")
      end
   end
end

main()
