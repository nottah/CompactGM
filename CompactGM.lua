local ADDON, CGM = ...

CGM.version = "0.5.0"
CGM.targetName = nil
CGM.lookupItemIDs = {}

local function SayCommand(command)
  if not command or command == "" then return end
  command = string.gsub(command, "^%s+", "")
  command = string.gsub(command, "%s+$", "")
  if command == "" then return end
  if string.sub(command, 1, 1) ~= "." then
    command = "." .. command
  end
  SendChatMessage(command, "SAY")
end

local function CommandItem(text, command)
  return {
    text = text,
    notCheckable = 1,
    func = function() SayCommand(command) end,
  }
end

local function TargetCommandItem(text, command)
  return {
    text = text,
    notCheckable = 1,
    disabled = not CGM.targetName,
    func = function()
      if CGM.targetName then
        SayCommand(command .. " " .. CGM.targetName)
      end
    end,
  }
end

local function Submenu(text, menuList)
  return { text = text, hasArrow = 1, menuList = menuList, notCheckable = 1 }
end

local function PromptCommand(defaultText)
  CGM.promptText = defaultText or "."
  StaticPopup_Show("COMPACTGM_COMMAND")
end

local function PromptItem(text, defaultText)
  return {
    text = text or "Enter command…",
    notCheckable = 1,
    func = function() PromptCommand(defaultText) end,
  }
end

local function PromptLookup(category)
  CGM.lookupCategory = category
  StaticPopup_Show("COMPACTGM_LOOKUP")
end

local function LookupItem(text, category)
  return {
    text = text,
    notCheckable = 1,
    func = function() PromptLookup(category) end,
  }
end

local function TargetPromptItem(text, commandPrefix)
  return {
    text = text,
    notCheckable = 1,
    disabled = not CGM.targetName,
    func = function()
      if CGM.targetName then
        PromptCommand(commandPrefix .. " " .. CGM.targetName .. " ")
      end
    end,
  }
end

local function Trim(text)
  return (string.gsub(string.gsub(text or "", "^%s+", ""), "%s+$", ""))
end

local function InstallLookupItemClick()
  local previousSetItemRef = SetItemRef
  SetItemRef = function(link, text, button, chatFrame)
    local itemID = tonumber(string.match(link or "", "^item:(%d+)"))
    if itemID and CGM.lookupItemIDs[itemID] and IsControlKeyDown() then
      SayCommand(".additem " .. itemID .. " 1")
      return
    end
    if previousSetItemRef then
      return previousSetItemRef(link, text, button, chatFrame)
    end
  end

  local capture = CreateFrame("Frame")
  capture:RegisterEvent("CHAT_MSG_SYSTEM")
  capture:SetScript("OnEvent", function(_, _, message)
    if type(message) ~= "string" then return end
    local listedID, linkID = string.match(message, "^(%d+)%s*%-.-|Hitem:(%d+)")
    listedID, linkID = tonumber(listedID), tonumber(linkID)
    if listedID and listedID == linkID then
      CGM.lookupItemIDs[linkID] = true
    end
  end)
end

local function GetSavedTeleportNames()
  CompactGMDB = CompactGMDB or {}
  CompactGMDB.teleports = CompactGMDB.teleports or {}
  local names = {}
  for _, name in ipairs(CompactGMDB.teleports) do
    if type(name) == "string" and name ~= "" then
      table.insert(names, name)
    end
  end
  table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)
  return names
end

local function RememberTeleport(name)
  name = Trim(name)
  if name == "" then return false end
  CompactGMDB = CompactGMDB or {}
  CompactGMDB.teleports = CompactGMDB.teleports or {}
  for _, existing in ipairs(CompactGMDB.teleports) do
    if string.lower(existing) == string.lower(name) then return false end
  end
  table.insert(CompactGMDB.teleports, name)
  return true
end

local function ForgetTeleport(name)
  if not CompactGMDB or not CompactGMDB.teleports then return end
  for index = #CompactGMDB.teleports, 1, -1 do
    if string.lower(CompactGMDB.teleports[index]) == string.lower(name) then
      table.remove(CompactGMDB.teleports, index)
    end
  end
end

local function PromptTeleportName(mode)
  CGM.teleportPromptMode = mode
  StaticPopup_Show("COMPACTGM_TELEPORT_NAME")
end

local function TeleportNameItem(text, mode)
  return {
    text = text,
    notCheckable = 1,
    func = function() PromptTeleportName(mode) end,
  }
end

local function SavedTeleportMenu()
  local names = GetSavedTeleportNames()
  local entries = {}
  if #names == 0 then
    return { { text = "No saved spots yet", disabled = 1, notCheckable = 1 } }
  end
  for _, name in ipairs(names) do
    local teleportName = name
    table.insert(entries, CommandItem(teleportName, ".teleport " .. teleportName))
  end
  return entries
end

local function RemoveSavedTeleportMenu()
  local names = GetSavedTeleportNames()
  local entries = {}
  if #names == 0 then
    return { { text = "No saved spots to remove", disabled = 1, notCheckable = 1 } }
  end
  for _, name in ipairs(names) do
    local teleportName = name
    table.insert(entries, {
      text = teleportName,
      notCheckable = 1,
      func = function()
        ForgetTeleport(teleportName)
        print("|cff66ccffCompactGM|r Removed " .. teleportName .. " from this addon's list.")
      end,
    })
  end
  return entries
end

local function ShowMenu(menu, frame)
  frame = frame or CGM.DropDown
  UIDropDownMenu_Initialize(frame, function(self, level, menuList)
    local entries = menuList or menu
    if type(entries) == "function" then entries = entries() end
    for _, entry in ipairs(entries) do
      UIDropDownMenu_AddButton(entry, level)
    end
  end, "MENU")
  ToggleDropDownMenu(1, nil, frame, "cursor", 0, 0)
end

local playerMenu = {
  Submenu("Travel", {
    TargetCommandItem("Appear at this character", ".appear"),
    TargetCommandItem("Summon this character", ".summon"),
    TargetCommandItem("Recall this character", ".recall"),
  }),
  Submenu("Character", {
    TargetCommandItem("Revive", ".revive"),
    TargetCommandItem("Player info", ".pinfo"),
    TargetCommandItem("GPS", ".gps"),
  }),
  Submenu("Moderation", {
    TargetCommandItem("Freeze", ".freeze"),
    TargetCommandItem("Unfreeze", ".unfreeze"),
    TargetPromptItem("Mute…", ".mute"),
    TargetCommandItem("Unmute", ".unmute"),
  }),
  { text = "Enter command…", notCheckable = 1, func = PromptCommand },
}

local globalMenu = {
  Submenu("Lookup", {
    LookupItem("Item…", "item"),
    LookupItem("Item set…", "item set"),
    LookupItem("Quest…", "quest"),
    LookupItem("Creature / NPC…", "creature"),
    LookupItem("Game object…", "gobject"),
    LookupItem("Spell…", "spell"),
    LookupItem("Skill…", "skill"),
    LookupItem("Area…", "area"),
    LookupItem("Map…", "map"),
    LookupItem("Faction…", "faction"),
    LookupItem("Event…", "event"),
  }),
  Submenu("GM mode", {
    CommandItem("Enable GM", ".gm on"),
    CommandItem("Disable GM", ".gm off"),
    CommandItem("Toggle flight", ".gm fly"),
    CommandItem("Toggle visibility", ".gm visible"),
  }),
  Submenu("Playerbots", {
    CommandItem("Start selfbot fishing", ".sbfish start"),
    CommandItem("Fishing: status", ".sbfish status"),
    CommandItem("Fishing: stop", ".sbfish stop"),
  }),
  Submenu("Dungeon Clear", {
    CommandItem("Status", ".dc status"),
    CommandItem("Enable", ".dc on"),
    CommandItem("Pause", ".dc pause"),
    CommandItem("Skip current step", ".dc skip"),
    CommandItem("Disable", ".dc off"),
    CommandItem("List bosses", ".dc bosses"),
  }),
  Submenu("World & server", {
    Submenu("Teleport", {
      CommandItem("Return before last teleport", ".recall"),
      TeleportNameItem("Save current spot on server…", "create"),
      Submenu("Saved spots", SavedTeleportMenu),
      TeleportNameItem("Add existing server spot to list…", "remember"),
      Submenu("Remove from addon's list", RemoveSavedTeleportMenu),
      TeleportNameItem("Search server teleport names…", "search"),
    }),
    CommandItem("Server info", ".server info"),
    CommandItem("List commands", ".commands"),
    PromptItem("Teleport / other command…"),
  }),
  { text = "Custom command…", notCheckable = 1, func = PromptCommand },
}

local function GetPopupTarget()
  local menu = UIDROPDOWNMENU_INIT_MENU
  if not menu then return nil end
  if menu.unit and UnitExists(menu.unit) then
    local name = UnitName(menu.unit)
    if name and name ~= "" then return name end
  end
  if menu.name and menu.name ~= "" then
    return string.match(menu.name, "^[^-]+") or menu.name
  end
  return nil
end

local function OpenPlayerMenu()
  CGM.targetName = GetPopupTarget()
  ShowMenu(playerMenu, CGM.PlayerDropDown)
end

local function InstallUnitPopupEntry()
  if not UnitPopupMenus or not UnitPopupButtons then return end
  UnitPopupButtons.COMPACTGM_ROOT = { text = "Compact GM Tools", dist = 0 }

  local menus = { "PLAYER", "PARTY", "RAID_PLAYER", "CHAT_ROSTER" }
  for _, menuName in ipairs(menus) do
    local menu = UnitPopupMenus[menuName]
    if menu then
      local found = false
      for _, value in ipairs(menu) do
        if value == "COMPACTGM_ROOT" then found = true break end
      end
      if not found then table.insert(menu, "COMPACTGM_ROOT") end
    end
  end

  if UnitPopup_OnClick and hooksecurefunc then
    hooksecurefunc("UnitPopup_OnClick", function(button)
      if button and button.value == "COMPACTGM_ROOT" then
        OpenPlayerMenu()
      end
    end)
  end
end

StaticPopupDialogs.COMPACTGM_COMMAND = {
  text = "Enter an AzerothCore GM command (with or without the leading dot):",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 240,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  preferredIndex = 3,
  OnShow = function(self)
    local editBox = self.editBox
    editBox:SetText(CGM.promptText or ".")
    editBox:SetFocus()
    editBox:HighlightText()
  end,
  OnAccept = function(self)
    SayCommand(self.editBox:GetText())
  end,
  EditBoxOnEnterPressed = function(self)
    local parent = self:GetParent()
    SayCommand(self:GetText())
    parent:Hide()
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide()
  end,
}

StaticPopupDialogs.COMPACTGM_LOOKUP = {
  text = "Search AzerothCore lookup results:",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 100,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  preferredIndex = 5,
  OnShow = function(self)
    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnAccept = function(self)
    local term = Trim(self.editBox:GetText())
    if term ~= "" then
      SayCommand(".lookup " .. CGM.lookupCategory .. " " .. term)
    end
  end,
  EditBoxOnEnterPressed = function(self)
    local parent = self:GetParent()
    StaticPopupDialogs.COMPACTGM_LOOKUP.OnAccept(parent)
    parent:Hide()
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide()
  end,
}

StaticPopupDialogs.COMPACTGM_TELEPORT_NAME = {
  text = "Enter a teleport name:",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 100,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  preferredIndex = 4,
  OnShow = function(self)
    local mode = CGM.teleportPromptMode
    if mode == "create" then
      self.text:SetText("Name this spot, then CompactGM will save it on the server and add it to your list:")
    elseif mode == "search" then
      self.text:SetText("Enter part of a teleport name to search the server:")
    else
      self.text:SetText("Enter the exact name of an existing server teleport to add it to your list:")
    end
    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnAccept = function(self)
    local name = Trim(self.editBox:GetText())
    if name == "" then return end
    if string.len(name) > 100 or string.find(name, "[^%w%s_%-']") then
      print("|cffff5555CompactGM:|r Use up to 100 letters, numbers, spaces, apostrophes, hyphens, or underscores.")
      return
    end
    RememberTeleport(name)
    if CGM.teleportPromptMode == "create" then
      SayCommand(".teleport add " .. name)
    elseif CGM.teleportPromptMode == "search" then
      SayCommand(".lookup teleport " .. name)
    else
      SayCommand(".lookup teleport " .. name)
    end
  end,
  EditBoxOnEnterPressed = function(self)
    local parent = self:GetParent()
    StaticPopupDialogs.COMPACTGM_TELEPORT_NAME.OnAccept(parent)
    parent:Hide()
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide()
  end,
}

local function CreateMinimapButton()
  if not Minimap then return end
  CompactGMDB = CompactGMDB or {}
  CompactGMDB.angle = CompactGMDB.angle or 220

  local button = CreateFrame("Button", "CompactGMMinimapButton", Minimap)
  button:SetWidth(31)
  button:SetHeight(31)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(8)
  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  button:SetMovable(true)
  button:EnableMouse(true)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button:RegisterForDrag("LeftButton")

  local icon = button:CreateTexture(nil, "BACKGROUND")
  icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
  icon:SetWidth(19)
  icon:SetHeight(19)
  icon:SetPoint("CENTER", button, "CENTER", 0, 1)

  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetWidth(54)
  border:SetHeight(54)
  border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

  local function Reposition()
    local angle = math.rad(CompactGMDB.angle or 220)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * 80, math.sin(angle) * 80)
  end

  button:SetScript("OnClick", function()
    ShowMenu(globalMenu, CGM.GlobalDropDown)
  end)
  button:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", function()
    local scale = Minimap:GetEffectiveScale()
    local cx, cy = Minimap:GetCenter()
    local x, y = GetCursorPosition()
    x, y = x / scale - cx, y / scale - cy
    CompactGMDB.angle = math.deg(math.atan2(y, x))
    Reposition()
  end) end)
  button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Compact GM Tools")
    GameTooltip:AddLine("Click for GM, Playerbots, and Dungeon Clear", 1, 1, 1)
    GameTooltip:AddLine("Drag to move", 0.7, 0.7, 0.7)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  Reposition()
  CGM.MinimapButton = button
end

local function Setup()
  CGM.DropDown = CreateFrame("Frame", "CompactGMDropDown", UIParent, "UIDropDownMenuTemplate")
  CGM.PlayerDropDown = CreateFrame("Frame", "CompactGMPlayerDropDown", UIParent, "UIDropDownMenuTemplate")
  CGM.GlobalDropDown = CreateFrame("Frame", "CompactGMGlobalDropDown", UIParent, "UIDropDownMenuTemplate")
  InstallUnitPopupEntry()
  CreateMinimapButton()
  InstallLookupItemClick()

  SLASH_COMPACTGM1 = "/cgm"
  SLASH_COMPACTGM2 = "/compactgm"
  SlashCmdList.COMPACTGM = function()
    ShowMenu(globalMenu, CGM.GlobalDropDown)
  end
  DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffCompactGM|r loaded. Use /cgm or the minimap button. Ctrl-click lookup item results to add one.")
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", Setup)
