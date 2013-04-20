
for _, script in ipairs {
	"gui/help";
	"gui/inventory";
	"gui/item_pickup";
	"gui/transient_message";
} do
	nxrequire(script)
end

