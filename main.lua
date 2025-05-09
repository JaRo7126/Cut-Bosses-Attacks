--If someone seing this PLEASE NOTE that my code isn't ideal
--So if you've found a better way to do smth in my code, write me about it

CutBossesAttacks = RegisterMod("Cut Bosses Attacks", 1)
local cba = CutBossesAttacks
local trw = TheRepentanceWitness --trw mod check

require("cba-scripts.cfg")
require("cba-scripts.utils")
require("cba-scripts.compats")

if not trw then --include witness module only without trw mod on
	require("cba-scripts.bosses.witness")
end

require("cba-scripts.bosses.visage")
require("cba-scripts.bosses.siren")
require("cba-scripts.bosses.reap_creep")
require("cba-scripts.bosses.mom")
require("cba-scripts.bosses.dogma")
require("cba-scripts.bosses.mega_satan2")
--!HEAVILY WIP!--
require("cba-scripts.skinless_womb")
require("cba-scripts.bosses.skinless_hush")
--.............--

if ModConfigMenu then
	require("cba-scripts.mcm")
end
require("cba-scripts.rgon_cfg")
