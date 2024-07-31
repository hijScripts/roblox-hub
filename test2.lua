local npc = ""
local line = "Black Bear"

for token in string.gmatch(line, "[^%s]+") do
   npc = npc .. token
end

print(npc)--