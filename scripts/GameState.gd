# res://scripts/GameState.gd
extends Node

# ---- Signals (kept for compatibility) ----
signal stats_changed
signal money_changed                         # (no args)
signal inventory_changed(category:String, name:String, new_count:int)

# ---- Money / Pet ----
var money: int = 2

var pet := {
	"name": "Ramonculus",
	"happiness": 0.95,  # 0..1
	"hunger":    0.69,
	"hygiene":   0.25,
}

# ---- Catalogue (controls slot order in each category) ----
const CATALOG := {
	"care":    ["Comb", "Shampoo", "Bath Soap", "Towel", "Toothbrush", "Toothpaste", "Face Wash", "Lotion"],
	"food":    ["Kibble", "Biscuits", "Milk", "Fish", "Chicken", "Veggies", "Fruit", "Cake"],
	"clothes": ["Hat", "Shirt", "Pants", "Shoes", "Scarf", "Gloves", "Jacket", "Socks"],
	"toys":    ["Ball", "Bone", "Rope", "Duck", "Squeaker", "Puzzle", "Mouse", "Laser"]
}

# ---- Inventory (what you actually own) ----
# (Counts for items you already have; others will default to 0 when queried.)
var inventory := {
	"care":    {"Comb":2, "Shampoo":1, "Bath Soap":1, "Towel":1},
	"food":    {"Kibble":3, "Biscuits":1},
	"clothes": {"Hat":1},
	"toys":    {"Ball":1, "Bone":2}
}

# --- Per-item icon paths (change paths to match your files) ---
const ICONS := {
	"care": {
		"Comb":       "res://assets/icons/inventory/comb.png",
		"Shampoo":    "res://assets/icons/inventory/shampoo.png",
		"Bath Soap":  "res://assets/icons/inventory/soap.png",
		"Towel":      "res://assets/icons/inventory/towel.png",
		"Toothbrush": "res://assets/icons/inventory/toothbrush.png",
		"Toothpaste": "res://assets/icons/inventory/toothpaste.png",
		"Face Wash":  "res://assets/icons/inventory/face_wash.png",
		"Lotion":     "res://assets/icons/inventory/lotion.png"
	},
	"food": {
		"Kibble":   "res://assets/icons/inventory/kibble.png",
		"Biscuits": "res://assets/icons/inventory/biscuits.png",
		"Milk":     "res://assets/icons/inventory/milk.png",
		"Fish":     "res://assets/icons/inventory/fish.png",
		"Chicken":  "res://assets/icons/inventory/chicken.png",
		"Veggies":  "res://assets/icons/inventory/veggies.png",
		"Fruit":    "res://assets/icons/inventory/fruit.png",
		"Cake":     "res://assets/icons/inventory/cake.png"
	},
	"clothes": {
		"Hat": "res://assets/icons/inventory/hat.png",
		"Shirt": "res://assets/icons/inventory/shirt.png",
		"Pants": "res://assets/icons/inventory/pants.png",
		"Shoes": "res://assets/icons/inventory/shoes.png",
		"Scarf": "res://assets/icons/inventory/scarf.png",
		"Gloves": "res://assets/icons/inventory/gloves.png",
		"Jacket": "res://assets/icons/inventory/jacket.png",
		"Socks": "res://assets/icons/inventory/socks.png"
	},
	"toys": {
		"Ball": "res://assets/icons/inventory/ball.png",
		"Bone": "res://assets/icons/inventory/bone.png",
		"Rope": "res://assets/icons/inventory/rope.png",
		"Duck": "res://assets/icons/inventory/duck.png",
		"Squeaker": "res://assets/icons/inventory/squeaker.png",
		"Puzzle": "res://assets/icons/inventory/puzzle.png",
		"Mouse": "res://assets/icons/inventory/mouse.png",
		"Laser": "res://assets/icons/inventory/laser.png"
	}
}
var _icon_cache: Dictionary = {}

func get_icon(category:String, name:String) -> Texture2D:
	var path: String = ICONS.get(category, {}).get(name, "")
	if path == "":
		return null
	if _icon_cache.has(path):
		return _icon_cache[path]
	var tex := load(path) as Texture2D
	if tex:
		_icon_cache[path] = tex
	return tex

# ---- Descriptions (category + item specifics) ----
const CATEGORY_BASE_DESC := {
	"care":    "Care item used to groom or clean your pet.",
	"food":    "Food item that restores hunger.",
	"clothes": "Cosmetic item to dress up your pet.",
	"toys":    "Toy that increases pet happiness."
}

const DESCRIPTIONS := {
	"care": {
		"Comb": "Gently tidies fur. Small happiness boost.",
		"Shampoo": "Deep clean for a shiny coat. Big hygiene gain.",
		"Bath Soap": "Quick wash; modest hygiene boost.",
		"Towel": "Dries your pet after bathing; tiny hygiene top-up.",
		"Toothbrush": "Freshens teeth; small hygiene bump.",
		"Toothpaste": "Use with toothbrush for best effect.",
		"Face Wash": "Refreshes the face; light hygiene bump.",
		"Lotion": "Soothes skin; tiny happiness increase."
	},
	"food": {
		"Kibble": "Everyday meal. Medium hunger restore.",
		"Biscuits": "Crunchy snack. Small hunger boost.",
		"Milk": "Comfort drink. Small hunger + tiny happiness.",
		"Fish": "Protein feast. Large hunger restore.",
		"Chicken": "Hearty meal. Large hunger restore.",
		"Veggies": "Healthy mix. Medium hunger restore.",
		"Fruit": "Fresh snack. Small hunger + tiny happiness.",
		"Cake": "Treat food. Medium hunger + happiness."
	},
	"clothes": {
		"Hat": "Fashion item. Cosmetic only.",
		"Shirt": "Casual top. Cosmetic only.",
		"Pants": "Comfy bottoms. Cosmetic only.",
		"Shoes": "Stylish kicks. Cosmetic only.",
		"Scarf": "Cozy accessory. Cosmetic only.",
		"Gloves": "Warm paws! Cosmetic only.",
		"Jacket": "Snug outerwear. Cosmetic only.",
		"Socks": "Soft and cute. Cosmetic only."
	},
	"toys": {
		"Ball": "Classic fetch toy. Happiness boost.",
		"Bone": "Chew toy pets love. Happiness boost.",
		"Rope": "Tug-of-war fun. Happiness boost.",
		"Duck": "Squeaky pal. Happiness boost.",
		"Squeaker": "Noisy fun. Happiness boost.",
		"Puzzle": "Brain teaser. Big happiness over time.",
		"Mouse": "Chase toy. Happiness boost.",
		"Laser": "Zoom zoom! High-energy play."
	}
}

func get_description(category:String, name:String) -> String:
	# Only return item-specific description
	return DESCRIPTIONS.get(category, {}).get(name, "No description available.")


# ---------- PET STATS ----------
func set_stat(key: String, value: float) -> void:
	if key in pet:
		pet[key] = clamp(value, 0.0, 1.0)
		stats_changed.emit()

# ---------- MONEY ----------
func add_money(delta: int) -> void:
	money = max(0, money + delta)
	money_changed.emit()   # keep legacy signature

func spend_money(amount:int) -> bool:
	if amount <= 0:
		return true
	if money < amount:
		return false
	money -= amount
	money_changed.emit()
	return true

# ---------- INVENTORY HELPERS ----------
func get_count(category:String, name:String) -> int:
	# Always return a valid count; auto-init missing items to 0.
	var cat: Dictionary = inventory.get(category, {})
	if not cat.has(name):
		cat[name] = 0
		inventory[category] = cat
	return int(cat[name])

func set_count(category:String, name:String, count:int) -> void:
	count = max(0, count)
	if not inventory.has(category):
		inventory[category] = {}
	inventory[category][name] = count
	inventory_changed.emit(category, name, count)

func add_item(category:String, name:String, delta:int=1) -> void:
	set_count(category, name, get_count(category, name) + delta)

func use_item(category:String, name:String) -> bool:
	var n := get_count(category, name)
	if n <= 0:
		return false
	set_count(category, name, n - 1)
	return true
