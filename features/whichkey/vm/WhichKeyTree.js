function keyTokenLabel(token) {
    if (token === "<enter>") {
        return "keyboard_return";
    }

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
//   { key, label, description, icon, hasChildren }
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
        const dispatcher = typeof entry.dispatcher === "string" ? entry.dispatcher : "";
        const isSubmap = dispatcher === "submap";

        // Parse <icon> prefix from description
        let displayDesc = description;
        let displayIcon = icon;
        const iconMatch = displayDesc.match(/^<([^>]+)>(.*)/);
        if (iconMatch) {
            displayIcon = iconMatch[1];
            displayDesc = iconMatch[2].trim();
        }

        result.push({
            key: tokens[0],
            label: keyTokenLabel(tokens[0]),
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
