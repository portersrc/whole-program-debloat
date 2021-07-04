from static_analyzer.Gadget import Gadget

gadget = Gadget("0x0000000000002af4 : vzeroupper ; ret")
gadget2 = Gadget("0x0000000000000e3c : vzeroupper ; ret")
print(gadget == gadget2)

maps = {}
maps[gadget] = 1
maps[gadget2] = 1

print(maps)
