--#textdomain wesnoth-Shadows_of_Deception

return {
	{ name = _ "General", text = _ [[
Many elements of this campaign differ from standard Wesnoth. If you aren’t sure if I’ve implemented something differently, look here; this should explain.

<big>Tips:</big>
• Read the objectives — there may be special win conditions.
• Don’t try to eradicate all enemies — they may be respawning.
• Explore — there may be hidden areas.

<b>NOTE:</b> A game screen resolution of 800x600 or greater is recommended. Additionally, some sequences make use of floating labels, halos, and standing unit animations, so you might want to make sure these options are enabled under Preferences → Display.]]
	};
	{ name = _ "Items", text = _ [[
During your playthrough, you may encounter certain items you can pick up and add to characters’ inventories. To access a unit’s inventory, right click on them and select the <b>Inventory</b> option. You will be presented with a list of items that unit is carrying. Each character’s weapons, such as swords or staves, will be also appear in their inventory.

When you pick up an item from the map, you can do three things:

• <b>Use:</b> Depending on the type of item you pick up, this button does different things: <small>
    • If the item is single-use, such as a potion, you can immediately use it. Its effect will be applied, and it <b>will not</b> be added to the character’s inventory.
    • If the item is equippable, such as an amulet, this button will say “Equip”. Its effect will be applied, and it <b>will</b> be added to the character’s inventory.
    • If the item is examinable, such as a book, this button will say “Examine”. Any appropriate messages will be shown, but the item <b>will not</b> be added added to the character’s inventory.</small>

• <b>Take:</b> Add the item to the relevant character’s inventory for later use. The effect will <b>not</b> be applied.

• <b>Leave:</b> Do nothing. The item will be left on the map to pick up at another time.

Equippable items will henceforth appear in your inventory, even if you equip them immediately. They can be equipped or unequipped from there. Single-use items will also appear in your inventory, provided you did not use them when you picked them up.]]
	};
	{ name = _ "Spellcasting", text = _ [[
Units with magical abilities (such as Elynia and Niryone) are able to cast spells. Each has a list of spells they have learned, accessible from the <b>Spells</b> right click menu.

<big>To cast a spell:</big>
• Right click on any unit who has learned spells and select the <b>Spells</b> option.
• Select a spell and click <b>Cast Spell</b>. This will create an overlay over any valid potential targets for that spell
• Right click on any of these highlighted hexes and select the <b>Cast Spell: (spell name)</b> option.

<b>NOTE:</b> Some spells may have limited usage or cooldown time, so be sure to use them wisely.]]
	};
}
