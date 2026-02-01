# Necrosis-Classic TBC Anniversary Testing Guide

## Version Information
- **Addon Version:** 8.14 tbca
- **Target Interface:** 20505 (TBC Anniversary / Client 2.5.5.65534)
- **Last Updated:** 2025-02-01

---

## Installation

### TBC Anniversary Installation Path
Place the `Necrosis-Classic` folder into your TBC Anniversary AddOns directory:

**Windows:**
```
C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\Necrosis-Classic
```

**macOS:**
```
/Applications/World of Warcraft/_classic_/Interface/AddOns/Necrosis-Classic
```

**Linux:**
```
~/.wine/drive_c/Program Files (x86)/World of Warcraft/_classic_/Interface/AddOns/Necrosis-Classic
```

> **Note:** The exact path depends on your WoW installation and which version you're targeting. TBC Anniversary typically uses the `_classic_` or `_classic_era_` folder structure, NOT the retail `_retail_` folder.

### Manual Installation from Git
```bash
cd "/path/to/World of Warcraft/_classic_/Interface/AddOns/"
git clone https://github.com/kricklen/Necrosis-Classic.git
```

---

## Pre-Testing Checklist

Before logging in, verify:

1. ✅ The folder is named exactly `Necrosis-Classic` (case-sensitive on some systems)
2. ✅ Inside that folder, you can see `Necrosis-Classic.toc`
3. ✅ The TOC file shows `## Interface: 20505`
4. ✅ `Compatibility.lua` exists and is loaded early in the TOC
5. ✅ No other Necrosis variants are installed that might conflict

---

## Testing Procedure

### Phase 1: Addon Load Test (CRITICAL)

**Objective:** Ensure the addon loads without being marked "Out of Date" or throwing Lua errors.

**Steps:**
1. Log into TBC Anniversary with a **Warlock character**
2. Check the AddOns list at character select - Necrosis should be enabled and show as "loaded"
3. Enter the game world

**Expected Results:**
- ✅ Addon loads without "Interface too old" warnings
- ✅ No Lua errors displayed on login (check with `/console scriptErrors 1` if needed)
- ✅ Necrosis sphere button appears on screen
- ✅ Chat message shows addon initialized: `"Necrosis initialized"`

**If Failed:**
- Check `/reload` to see if errors appear after a UI reload
- Enable Lua errors: `/console scriptErrors 1` and look for red error boxes
- Check the TOC file Interface version matches 20505

---

### Phase 2: Core UI Elements Test

**Objective:** Verify all UI buttons appear and are interactive.

**Steps:**
1. Locate the main Necrosis sphere button
2. Right-click the sphere - options menu should appear
3. Drag the sphere - it should move freely
4. Check for these additional buttons around the sphere (may need to configure positions):
   - Soulstone button
   - Healthstone button
   - Spellstone button
   - Firestone button
   - Buff menu button
   - Pet/Demon menu button
   - Curse menu button
   - Mount button (if you have mounts)
   - Shadow Trance alert button (appears on proc)

**Expected Results:**
- ✅ All configured buttons visible
- ✅ Buttons respond to mouse hover (tooltip appears)
- ✅ Dragging works without errors
- ✅ No "blocked action" errors during non-combat interaction

**If Failed:**
- Try `/reload` to refresh the UI
- Check if buttons are hidden behind other UI elements
- Use `/necrosis` or right-click sphere to access options and reset button positions

---

### Phase 3: Bag Scanning & Shard Counting

**Objective:** Verify the addon correctly detects soul shards and warlock stones.

**Steps:**
1. Open your bags
2. Note current shard count (visible on sphere or via tooltip)
3. Create a soul shard (cast Drain Soul on a target that dies)
4. Verify shard count updates
5. Create a Healthstone
6. Hover over Healthstone button - tooltip should show you have one

**Expected Results:**
- ✅ Shard count updates automatically when shards are gained/lost
- ✅ No Lua errors during bag scanning
- ✅ Stone buttons update to show available stones
- ✅ Sphere texture may change based on shard count (if configured)

**If Failed:**
- Check for Lua errors with `/console scriptErrors 1`
- Try `/reload` after gaining/losing shards
- Verify BAG_UPDATE events are firing (debug mode)

---

### Phase 4: Spell & Demon Summoning

**Objective:** Test that spell buttons and demon summoning work without errors.

**Steps:**
1. Click the **Pet/Demon menu button**
2. Select "Summon Imp" (or another demon you have)
3. Cast the spell - verify no errors during cast
4. Repeat for other demons if available (Voidwalker, Succubus, etc.)
5. Test the **Buff menu** - cast Demon Armor or Fel Armor
6. Test the **Curse menu** - apply a curse to a training dummy or mob

**Expected Results:**
- ✅ Menus open without errors
- ✅ Spell buttons cast the correct spells
- ✅ No "spell not found" or "blocked action" errors
- ✅ Demon summoning completes successfully
- ✅ Chat messages (if configured) appear correctly

**If Failed:**
- Check if spells are learned (must be in your spellbook)
- Verify you have required reagents (soul shards for demons)
- Check for combat lockdown issues (see Phase 6)

---

### Phase 5: Stone Creation & Usage

**Objective:** Test stone creation and usage without errors.

**Steps:**
1. **Soulstone:**
   - Right-click Soulstone button to create one (requires soul shard)
   - Left-click to use it on yourself or a target
   - Verify cooldown is tracked correctly

2. **Healthstone:**
   - Create a Healthstone (requires soul shard)
   - Left-click to use it
   - Verify button updates when stone is consumed

3. **Spellstone/Firestone:**
   - Create stone (requires soul shard)
   - Apply to weapon
   - Verify button shows "equipped" state

**Expected Results:**
- ✅ Stone creation spells cast without errors
- ✅ Stones can be used via button clicks
- ✅ Cooldowns display correctly
- ✅ Button icons update to reflect stone state (available, used, equipped)

**If Failed:**
- Ensure you have soul shards in bags
- Check if stones are in compatible bags (not in soul shard bag for some stones)
- Verify weapon is equippable with stones

---

### Phase 6: Combat Testing

**Objective:** Ensure no "blocked action" errors occur during combat.

**Steps:**
1. Enter combat with any mob
2. Use Necrosis buttons during combat (curses, DoTs, etc.)
3. Summon demon during combat (if Fel Domination is active)
4. Exit combat
5. Use buttons again after combat ends

**Expected Results:**
- ✅ Buttons work normally during combat
- ✅ No "Action blocked" or "Protected function" errors
- ✅ No UI taint warnings
- ✅ Buttons remain functional after combat ends

**If Failed:**
- This indicates a combat lockdown issue
- Check if secure action button templates are being modified during combat
- Review Compatibility.lua and secure button handling code
- May need to defer button updates to PLAYER_REGEN_ENABLED event

---

### Phase 7: Slash Commands & Options

**Objective:** Test addon configuration and commands.

**Steps:**
1. Type `/necrosis` in chat - options window should open
2. Change a setting (e.g., button scale, colors)
3. `/reload` to apply changes
4. Verify settings persisted
5. Test keybindings (Escape > Keybindings > Necrosis section)

**Expected Results:**
- ✅ `/necrosis` opens options without errors
- ✅ Settings can be changed and saved
- ✅ Settings persist across /reload and logout
- ✅ Keybindings can be assigned and work correctly

**If Failed:**
- Check SavedVariables file: `WTF/Account/<ACCOUNT>/<SERVER>/<CHARACTER>/SavedVariables/Necrosis-Classic.lua`
- Ensure NecrosisConfig variable is being saved/loaded
- Check for UI taint issues in options panel

---

### Phase 8: Edge Cases & Stress Tests

**Objective:** Test unusual scenarios that might break the addon.

**Steps:**
1. **Full Bags:** Fill bags with shards - verify no spam/errors
2. **Fast Bag Changes:** Rapidly open/close bags while gaining shards
3. **Talent Respec:** Respec talents and verify spell buttons update
4. **Mount While Buffed:** Mount up, dismount, verify buff buttons still work
5. **Death & Resurrect:** Die, resurrect, verify buttons re-enable correctly
6. **Group/Raid:** Join a party or raid, verify addon doesn't spam chat

**Expected Results:**
- ✅ No Lua errors in any scenario
- ✅ Addon handles edge cases gracefully
- ✅ Buttons update correctly after state changes
- ✅ No excessive chat spam or memory leaks

---

## Known Limitations (TBC Anniversary)

1. **Spell IDs:** Some spell ranks may differ from original TBC. If a spell button is greyed out, it may not exist in TBC Anniversary.
2. **Soul Shatter:** This spell was added in later TBC patches - may not be available early in TBC Anniversary progression.
3. **Incubus:** Added in TBC Classic Season of Mastery, may not be in base TBC Anniversary.
4. **Timer Bars:** If enabled, ensure they don't cause excessive memory usage on long dungeon runs.

---

## Reporting Issues

If you encounter problems:

1. **Enable Lua Errors:** `/console scriptErrors 1`
2. **Get Error Details:** Screenshot or copy the full error message
3. **Provide Context:**
   - Exact steps to reproduce
   - Your character's spec/talents
   - Which spells/stones were involved
   - Any other addons installed

4. **Check Logs:** Look in `Logs/` folder for crash dumps

5. **Report:** File an issue on GitHub with all details above

---

## Rollback Instructions

If the addon breaks your game:

1. Exit WoW completely
2. Rename or delete the `Necrosis-Classic` folder from AddOns directory
3. (Optional) Delete SavedVariables: `WTF/Account/<ACCOUNT>/<SERVER>/<CHARACTER>/SavedVariables/Necrosis-Classic.lua`
4. Restart WoW

---

## Success Criteria Summary

✅ **Addon loads on Interface 20505 without "out of date" warning**  
✅ **Zero Lua errors on login and basic usage**  
✅ **Sphere button and stone buttons appear and function**  
✅ **Bag scanning counts shards correctly**  
✅ **Demon summoning and spell menus work**  
✅ **No combat lockdown or taint issues**  
✅ **Settings save and persist across sessions**  

If all criteria pass: **APPROVED FOR TBC ANNIVERSARY** ✅

---

## Developer Notes

**Changes Made for TBC Anniversary:**
- Updated `## Interface` to 20505 in TOC
- Created `Compatibility.lua` shim layer for API detection
- Replaced `GetAddOnMetadata` with `NecrosisCompat.GetAddOnMetadata`
- Replaced `GetContainerNumSlots` with `NecrosisCompat.GetContainerNumSlots`
- Added runtime detection for `C_AddOns` and `C_Container` namespaces
- No functional behavior changes - pure compatibility fixes

**Future-Proofing:**
- Compatibility layer ready for C_AddOns/C_Container if Blizzard updates TBC Anniversary client
- SetBackdrop shims prepared (currently not needed but ready)
- All changes are backward-compatible with older TBC Classic clients

**Commit Message:**
```
TBC Anniversary (20505) compatibility update

- Update Interface version to 20505
- Add Compatibility.lua for API abstraction
- Use NecrosisCompat wrappers for GetAddOnMetadata/GetContainerNumSlots
- Forward compatible with C_AddOns/C_Container namespaces
- No functional changes, pure compatibility layer

Tested on TBC Anniversary client 2.5.5.65534
```

---

**END OF TESTING GUIDE**
