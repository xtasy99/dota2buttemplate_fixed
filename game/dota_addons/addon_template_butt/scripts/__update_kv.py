import requests
import os

files = [
    ["npc\\_abilities.txt", "https://raw.githubusercontent.com/arcadia-redux/dota_vpk_updates/main/scripts/npc/npc_abilities.txt"],
    ["npc\\_heroes.txt", "https://raw.githubusercontent.com/arcadia-redux/dota_vpk_updates/main/scripts/npc/npc_heroes.txt"],
    ["npc\\_items.txt", "https://raw.githubusercontent.com/arcadia-redux/dota_vpk_updates/main/scripts/npc/items.txt"],
    ["npc\\_neutral_items.txt", "https://raw.githubusercontent.com/arcadia-redux/dota_vpk_updates/main/scripts/npc/neutral_items.txt"],
    ["npc\\_units.txt", "https://raw.githubusercontent.com/arcadia-redux/dota_vpk_updates/main/scripts/npc/npc_units.txt"],

    ["npc\\activelist.txt", "https://raw.githubusercontent.com/arcadia-redux/dota_vpk_updates/main/scripts/npc/activelist.txt"],
    ["npc\\npc_neutral_items_custom.txt", "https://raw.githubusercontent.com/arcadia-redux/dota_vpk_updates/main/scripts/npc/neutral_items.txt"],

    ["shops\\dota_fixed_shops.txt", "https://raw.githubusercontent.com/arcadia-redux/dota_vpk_updates/main/scripts/shops.txt"],
]

for filetype in files:
    r = requests.get(filetype[1], allow_redirects=True)
    open(os.path.realpath(__file__) + "\\..\\" + filetype[0], 'wb').write(r.content)

