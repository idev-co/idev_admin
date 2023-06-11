ESX = exports.es_extended:getSharedObject()

local function setupMenu(group)
	local function isNotBlacklist(id, group)
		if Config.functionsBlacklist[id] then
			return Config.functionsBlacklist[id][group]
		end

		return false
	end

	local function toKeyValues( tbl )

		local result = {}

		for k,v in pairs( tbl ) do
			table.insert( result, { key = k, val = v } )
		end

		return result

	end

	local function keyValuePairs( state )

		state.Index = state.Index + 1

		local keyValue = state.KeyValues[ state.Index ]
		if ( not keyValue ) then return end

		return keyValue.key, keyValue.val

	end

	local function sortedPairs( pTable, Desc )

		local sortedTbl = toKeyValues( pTable )

		if ( Desc ) then
			table.sort( sortedTbl, function( a, b ) return a.key > b.key end )
		else
			table.sort( sortedTbl, function( a, b ) return a.key < b.key end )
		end

		return keyValuePairs, { Index = 0, KeyValues = sortedTbl }

	end

	local target = true

	local function isTargetingPlayer(menuName)
		return menuName == Translations["sectionManagePlayers"] and target or false
	end

	local menu = RageUI.CreateMenu(Translations["menuTitle"], Translations["menuSubtitle"])
	local subMenus = {}

	local subMenuTargeted = false

	for _, subMenuType in ipairs(Sections) do
		if not subMenuType.disable then
			subMenus[#subMenus + 1] = { name = subMenuType.name, menu = RageUI.CreateSubMenu(menu, subMenuType.name, Translations["menuSubtitle"]), functions = subMenuType.functions, variables = {} }
		end
	end

	local justChangedMenu = false
	local onlinePlayers = {}

	function RageUI.PoolMenus:star_adminmenu()
		menu:IsVisible(function(items)
			for _, subMenu in ipairs(subMenus) do
				items:AddButton(subMenu.name, false, { IsDisabled = false }, function(onSelected)
					if onSelected then
						justChangedMenu = true

						if isTargetingPlayer(subMenu.name) then
							ESX.TriggerServerCallback("star_adminmenu:getAllPlayers", function(players)
								onlinePlayers = players
							end)
						end

			--			print("open subMenu with name= " .. subMenu.name)
						subMenuTargeted = false
						RageUI.Visible(menu, false)
						RageUI.Visible(subMenu.menu, true)

						-- Needed otherwise it will action the first button of the targeted menu
						Wait(50)
						justChangedMenu = false
					end
				end)
			end
		end, function() end)

		for _, subMenu in ipairs(subMenus) do
			subMenu.menu:IsVisible(function(items)
				if isTargetingPlayer(subMenu.name) and not subMenuTargeted then
					for k, player in sortedPairs(onlinePlayers) do
						items:AddButton(('%s [ID: %s]'):format(player.name, k), false, { IsDisabled = false }, function(onSelected)
							if onSelected and not justChangedMenu then
								--print("PLAYER SELECTED: " .. player.name)
								target = player

								subMenuTargeted = true
							end
						end)
					end
				else
					for _, action in ipairs(subMenu.functions) do
						if not isNotBlacklist(action.blacklistID, group) and not action.disable then
							local targetingPlayer = isTargetingPlayer(subMenu.name)

							if action.type == "checkbox" then
								items:CheckBox(action.name, false, subMenu.variables[action.name], { Style = 1 }, function(onSelected, isChecked)
									if onSelected and not justChangedMenu then
									--	print("CHECKBOX SELECTED: " .. action.name)
										subMenu.variables[action.name] = isChecked

										if not targetingPlayer then
											return ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
												action.trigger(PlayerPedId(), subMenu.variables[action.name], PlayerId())
											end, action.name, false, subMenu.variables[action.name])
										end

										ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
											action.trigger(PlayerPedId(), target, isChecked)
										end, action.name, target, isChecked)
									end
								end)
							elseif action.type == "slider" then
								--[[subMenu:AddSlider({ label = action.name, values = action.values, select = function(_, value)
									ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
										action.trigger(PlayerPedId(), value, PlayerId())
									end, action.name, false, value)
								end })]]
								if not subMenu.variables[action.name] then
									subMenu.variables[action.name] = 1
								end

								items:AddList(action.name, mapOnLabels(action.values), subMenu.variables[action.name], nil, { IsDisabled = false }, function(currentIndex, onSelected, onListChange)
									if onListChange and not justChangedMenu then
										subMenu.variables[action.name] = currentIndex
									end

									if onSelected then
										local value = getValueFromMap(action.values, subMenu.variables[action.name])

										if not targetingPlayer then
											return ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
												action.trigger(PlayerPedId(), value, PlayerId())
											end, action.name, false, value)
										end

										ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
											action.trigger(PlayerPedId(), target, value)
										end, action.name, target, value)
									end
								end)
							else
								items:AddButton(action.name, false, { IsDisabled = false }, function(onSelected)
									if onSelected and not justChangedMenu then
									--	print("BUTTON SELECTED: " .. action.name)

										if not targetingPlayer then
											return ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
												action.trigger(PlayerPedId(), PlayerId())
											end, action.name, false)
										end

										ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
											action.trigger(PlayerPedId(), target)
										end, action.name, target)
									end
								end)
							end
						end
					end
				end


			end, function() end)
		end
	end

	Keys.Register("F9", "F9", "Open admin menu", function()
		RageUI.Visible(menu, not RageUI.Visible(menu))
	end)

    --[[local menu = MenuV:CreateMenu(Translations["menuTitle"], Translations["menuSubtitle"], 'topleft', 255, 0, 0, 'size-125', 'default', 'menuv', 'star_adminmenu_main', 'native')
	local target

	for _, subMenuType in ipairs(Sections) do
        if subMenuType.disable then goto continue end

		local subMenu = MenuV:CreateMenu(subMenuType.name, "", "topleft", 255, 0, 0, 'size-125', 'default', 'menuv', 'stl_adminmenu_' .. subMenuType.name, 'native')

		menu:AddButton({ label = subMenuType.name, value = subMenu })

		if subMenuType.name == Translations["sectionManagePlayers"] then
			local targetMenu = MenuV:CreateMenu(Translations["menuActionsTitle"], Translations["menuActionsSubtitle"], "topleft", 255, 0, 0, 'size-125', 'default', 'menuv', 'star_adminmenu_target', 'native')

			for _, action in ipairs(subMenuType.functions) do
				if not isNotBlacklist(action.blacklistID, group) and not action.disable then
					if action.type == "checkbox" then
						targetMenu:AddCheckbox({ label = action.name, value = "n", change = function(item)
							ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
								action.trigger(PlayerPedId(), target, item.Value)
							end, action.name, target, item.Value)
						end })
					elseif action.type == "slider" then
						targetMenu:AddSlider({ label = action.name, values = action.values, select = function(_, value)
							ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
								action.trigger(PlayerPedId(), target, value)
							end, action.name, target, value)
						end })
					else
						targetMenu:AddButton({ label = action.name, select = function()
							ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
								action.trigger(PlayerPedId(), target)
							end, action.name, target)
						end })
					end
				end
			end

			subMenu:On("open", function (menu)
				ESX.TriggerServerCallback("star_adminmenu:getAllPlayers", function(players)
					menu:ClearItems()

					for k, player in pairs(players) do
						menu:AddButton({ label = ('%s [ID: %s]'):format(player.name, k), value = targetMenu, select = function()
							target = player
						end })
					end
				end)
			end)
		else
			for _, action in ipairs(subMenuType.functions) do
				if not isNotBlacklist(action.blacklistID, group) and not action.disable then
					if action.type == "checkbox" then
						subMenu:AddCheckbox({ label = action.name, value = "n", change = function(item)
							ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
								action.trigger(PlayerPedId(), item.Value, PlayerId())
							end, action.name, false, item.Value)
						end })
					elseif action.type == "slider" then
						subMenu:AddSlider({ label = action.name, values = action.values, select = function(_, value)
							ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
								action.trigger(PlayerPedId(), value, PlayerId())
							end, action.name, false, value)
						end })
					else
						subMenu:AddButton({ label = action.name, select = function()
							ESX.TriggerServerCallback("star_adminmenu:logDiscord", function()
								action.trigger(PlayerPedId(), PlayerId())
							end, action.name)
						end })
					end
				end
			end
		end

        ::continue::
	end

	menu:OpenWith('keyboard', Config.keyOpenMenu)]]


end

local hasBeenInitialized

local function initialize()
	if hasBeenInitialized then return end

	hasBeenInitialized = true

    CreateThread(function ()
        while not Config do
            Wait(0)
        end

        while not Sections do
            Wait(0)
        end

        ESX.TriggerServerCallback("star_adminmenu:hasMenuAccess", function(data)
            if not data.hasAccess then return end

            setupMenu(data.group)
        end)
    end)
end

RegisterNetEvent(Config.triggers["esxPlayerLoaded"])
AddEventHandler(Config.triggers["esxPlayerLoaded"], function()
    initialize()
end)

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    initialize()
end)