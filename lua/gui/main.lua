
for _, script in ipairs {
	"gui/bug";
	"gui/help";
	"gui/inventory";
	"gui/item_pickup";
	"gui/spellcasting";
	"gui/transient_message";
} do
	nxrequire(script)
end

