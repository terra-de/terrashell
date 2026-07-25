const KEY_ICONS = {
    "return": "keyboard_return",
    "enter": "keyboard_return",
    "space": "space_bar",
    "tab": "keyboard_tab",
    "backspace": "backspace",
    "delete": "delete",
    "del": "delete",
    "up": "keyboard_arrow_up",
    "down": "keyboard_arrow_down",
    "left": "keyboard_arrow_left",
    "right": "keyboard_arrow_right",
    "home": "keyboard_home",
    "end": "keyboard_end",
    "page_up": "keyboard_page_up",
    "page_down": "keyboard_page_down",
    "menu": "menu",
    "caps_lock": "keyboard_capslock",
    "insert": "keyboard",
    "ins": "keyboard",
};

function keyTokenIcon(token) {
    return KEY_ICONS[token] || "";
}

function keyTokenLabel(token) {
    return typeof token === "string" ? token.toUpperCase() : "";
}

function parseKeySequence(value) {
    if (typeof value !== "string") {
        return [];
    }

    const normalized = value.trim().toLowerCase();
    if (!normalized) {
        return [];
    }

    // Return the entire key name as a single token.
    // hyprctl binds -j reports resolved key names like "escape", "backspace", "y", "r".
    // The old character-by-character splitting was designed for the
    // pre-submap binding system and broke multi-character keysym names.
    return [normalized];
}

// Takes raw bind entries from hyprctl binds -j (filtered to current submap).
// Returns a flat array of entry objects suitable for display:
//   { key, label, keyIcon, description, icon, hasChildren }
// Automatically excludes escape/backspace (shown in footer instead).
// Marks entries as hasChildren=true when dispatcher is "submap".
function normalizeBinds(rawBinds) {
    const source = Array.isArray(rawBinds) ? rawBinds : [];
    const seen = ({});
    const result = [];

    for (const entry of source) {
        if (!entry || typeof entry !== "object") {
            continue;
        }

        const key = typeof entry.key === "string" ? entry.key.trim().toLowerCase() : "";
        if (!key) {
            continue;
        }

        // Skip special keys shown in footer
        if (key === "escape" || key === "backspace") {
            continue;
        }

        if (seen[key]) {
            continue;
        }
        seen[key] = true;

        const tokens = parseKeySequence(key);
        if (tokens.length === 0) {
            continue;
        }

        const description = typeof entry.description === "string" ? entry.description.trim() : "";
        const icon = typeof entry.icon === "string" ? entry.icon.trim() : "";

        // Detect submaps via @submap@ prefix in description.
        // hyprctl binds -j reports all Lua dispatchers as "__lua", so the
        // old dispatcher === "submap" check never matches.
        const isSubmap = description.startsWith("@submap@");
        const rawDesc = isSubmap ? description.slice(8).trim() : description;

        // Parse <icon> prefix from description
        let displayDesc = rawDesc;
        let displayIcon = icon;
        const iconMatch = displayDesc.match(/^<([^>]+)>(.*)/);
        if (iconMatch) {
            displayIcon = iconMatch[1];
            displayDesc = iconMatch[2].trim();
        }

        const token = tokens[0];

        result.push({
            key: token,
            label: keyTokenLabel(token),
            keyIcon: keyTokenIcon(token),
            description: displayDesc || (isSubmap ? "Group" : "Action"),
            icon: displayIcon || (isSubmap ? "folder" : "bolt"),
            hasChildren: isSubmap,
        });
    }

    // Sort: groups first, then alphabetically
    result.sort((a, b) => {
        if (a.hasChildren !== b.hasChildren) {
            return a.hasChildren ? -1 : 1;
        }
        return a.key.localeCompare(b.key);
    });

    return result;
}
