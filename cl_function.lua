lib.locale()
local saved_components = {}
local pedHandles = {}
local yes = locale('yes')

function tankAlert(value)
    if value % 100 == 0 then --75%, 50%, 25%
        return true
    end
    if value == 40 then --10%
        return true
    end
    if value <= 20 and value % 4 == 0 then --5%
        return true
    end
    return false
end

function isWearingScuba(playerPed, pedModel, fins)
    local isMale = Config.pedsMale[pedModel] or false
    local isFemale = Config.pedsFemale[pedModel] or false
    local WearingScuba = (isMale and GetPedDrawableVariation(playerPed, 8) == Config.maleScubaVariation) or (isFemale and GetPedDrawableVariation(playerPed, 8) == Config.femaleScubaVariation) or false
    local WearingSwimFins = (isMale and GetPedDrawableVariation(playerPed, 6) == Config.maleSwimFins) or (isFemale and GetPedDrawableVariation(playerPed, 6) == Config.femaleSwimFins) or false
    if fins then
        return WearingSwimFins
    end
    return WearingScuba
end

function applyScuba(name, playerPed, pedModel)
    local self = {}
    local isMale = Config.pedsMale[pedModel] or false
    local isFemale = Config.pedsFemale[pedModel] or false
    local anim = {
		[Config.scubaItemName] = {
			dict = 'clothingtie',
			clip = 'try_tie_negative_a',
			flags = 51,
		},
        [Config.finsItemName] = {
			dict = 'random@domestic',
			clip = 'pickup_low',
			flags = 51,
		}
    }
    if name == Config.scubaItemName then
        function self.playAnim()
            ESX.Streaming.RequestAnimDict(anim[name].dict)
            TaskPlayAnim(playerPed, anim[name].dict, anim[name].clip, 3.0, 3.0, 1200, anim[name].flags, 0.0, false, false, false)
            RemoveAnimDict(anim[name].dict)
            Wait(1200)
        end
        function self.getScuba()
            return isWearingScuba(playerPed, pedModel)
        end
        function self.setScuba()
            saved_components[name] = {
                GetPedDrawableVariation(playerPed, 8),
                GetPedTextureVariation(playerPed, 8),
                GetPedPropIndex(playerPed, 1),
                GetPedPropTextureIndex(playerPed, 1)
            }
            self.playAnim(playerPed)
            SetPedComponentVariation(playerPed, 8, isMale and Config.maleScubaVariation or isFemale and Config.femaleScubaVariation or 0, 0, 0)
            SetPedPropIndex(playerPed, 1, isMale and Config.maleScubaMaskVariation or isFemale and Config.femaleScubaMaskVariation or 0, 0, 0)
        end
        function self.resetScuba(hard)
            if saved_components[name] then
                if not hard then
                    self.playAnim(playerPed)
                end
                SetPedComponentVariation(playerPed, 8, saved_components[name][1], saved_components[name][2], 0)
                SetPedPropIndex(playerPed, 1, saved_components[name][3], saved_components[name][4], 0)
            end
        end
    end
    if name == Config.finsItemName then
        function self.playAnim()
            ESX.Streaming.RequestAnimDict(anim[name].dict)
            TaskPlayAnim(playerPed, anim[name].dict, anim[name].clip, 3.0, 3.0, 1200, anim[name].flags, 0.0, false, false, false)
            RemoveAnimDict(anim[name].dict)
            Wait(1200)
        end
        function self.getScuba()
            return isWearingScuba(playerPed, pedModel, true)
        end
        function self.setScuba()
            saved_components[name] = {
                GetPedDrawableVariation(playerPed, 6),
                GetPedTextureVariation(playerPed, 6)
            }
            self.playAnim(playerPed)
            SetPedComponentVariation(playerPed, 6, isMale and Config.maleSwimFins or isFemale and Config.femaleSwimFins or 0, 0, 0)
        end
        function self.resetScuba(hard)
            if saved_components[name] then
                if not hard then
                    self.playAnim(playerPed)
                end
                SetPedComponentVariation(playerPed, 6, saved_components[name][1], saved_components[name][2], 0)
            end
        end
    end
    return self
end

function getScubaItemCount(name)
    if Config.OxInventory then
        return exports.ox_inventory:Search('count', name)
    end
    return ESX.SearchInventory(name, true)
end

function CreateBlips()
    for k, v in ipairs(Config.Locations) do
        local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)

        SetBlipSprite(blip, 597)
        SetBlipScale(blip, 0.5)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.BlipsName)
        EndTextCommandSetBlipName(blip)
    end
end



function CreatePedAtLocation(location)
    RequestModel(GetHashKey(location.model))
    while not HasModelLoaded(GetHashKey(location.model)) do
        Wait(1)
    end
    local pedHandle = CreatePed(4, GetHashKey(location.model), location.pos.x, location.pos.y, location.pos.z, location.heading, false, true)
    SetEntityAsMissionEntity(pedHandle, true, true)
    SetBlockingOfNonTemporaryEvents(pedHandle, true)
    SetEntityInvincible(pedHandle, true)
    FreezeEntityPosition(pedHandle, true)
    exports.ox_target:addLocalEntity(pedHandle, {
        {
            name = 'ox_target:openMenu',
            label = locale('name_menu'),
            icon = 'fa-solid fa-bars',
            onSelect = function()
                lib.showContext('seapanda_menu') -- Fonction pour ouvrir le menu
            end,
        },
    })
    return pedHandle
end

for _, location in ipairs(Config.Locations) do
    local pedHandle = CreatePedAtLocation(location)
    table.insert(pedHandles, pedHandle)
end

lib.registerContext({
    id = 'seapanda_menu',
    title = locale('name_menu'),
    options = {
        {
            title = locale('diving_gear'),
            description = locale('diving_gear_desc'),
            onSelect = function()
                local prixTenuedeplongee = Config.prixTenuedeplongee
                local confirm = lib.inputDialog(locale('confirmation'), {
                    {type = 'input', label = 'Prix : ' ..prixTenuedeplongee.. "$ " ..locale('yesorno'), required = true},
                })
                if confirm and confirm[1] and (confirm[1]:lower() == string.lower(locale('yes'))) then
                    TriggerServerEvent('ed_scuba:prixtenuesplongee')
                else
                    ESX.ShowNotification(locale('purchase_cancel'))
                    lib.showContext('seapanda_menu')
                end             
            end
        },
        {
            title = locale('diving_fins'),
            description = locale('diving_fins_desc'),
            onSelect = function()
                local prixpalmesplongee = Config.prixpalmesplongee
                local confirm = lib.inputDialog(locale('confirmation'), {
                    {type = 'input', label = 'Prix : ' ..prixpalmesplongee.. "$ " ..locale('yesorno'), required = true},
                })
                if confirm and confirm[1] and (confirm[1]:lower() == string.lower(locale('yes'))) then
                    TriggerServerEvent('ed_scuba:prixpalmesplongee')
                else
                    ESX.ShowNotification(locale('purchase_cancel'))
                    lib.showContext('seapanda_menu')
                end             
            end
            
        },
        {
            title = locale('oxygen_tank'),
            description = locale('oxygen_tank_desc'),
            onSelect = function()
                local prixOxygene = Config.refillPrice
                local confirm = lib.inputDialog(locale('confirmation'), {
                    {type = 'input', label = 'Prix : ' ..prixOxygene.. "$ " ..locale('yesorno'), required = true},
                })
                if confirm and confirm[1] and (confirm[1]:lower() == string.lower(locale('yes'))) then
                    TriggerEvent('ed_scuba:oxygenHandle', 'pay')
                else
                    ESX.ShowNotification(locale('purchase_cancel'))
                    lib.showContext('seapanda_menu')
                end             
            end
        }
    }
})
    
