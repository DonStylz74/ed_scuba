Config  = {}

Config.scubaItemName = 'scuba_set'
Config.finsItemName = 'scuba_fins'
Config.OxInventory = true -- enable ox_inventory support

Config.pedsMale = {
    [`mp_m_freemode_01`] = true, -- hash
    --
}

Config.pedsFemale = {
    [`mp_f_freemode_01`] = true, -- hash
    --
}

Config.EnableBlip = true -- enable blips for oxygen refill station

Config.BlipsName = 'SeaPanda' -- blips name if enabled

Config.Locations = {
    {pos = vector3(-1263.727, -1435.815, 4.351-1), heading = 125.733, model = "a_m_y_jetski_01"},
    {pos = vector3(-216.583, 6552.067, 11.002-1), heading =  267.085, model = "cs_josef"},
    
}

Config.Currency = '$'
Config.refillPrice = 250

Config.prixTenuedeplongee = 0
Config.prixpalmesplongee = 0

-- ped component variations configuration
-- below is default ped assets, only added streamed scuba asset files
-- some may different if server have other replaced ped assets
Config.maleScubaVariation = 124 -- the scuba component number of the included stream file
Config.femaleScubaVariation = 154 -- the scuba component number of the included stream file
Config.maleScubaMaskVariation = 26
Config.femaleScubaMaskVariation = 28
Config.maleSwimFins = 67
Config.femaleSwimFins = 70

Config.fulltank = 400 -- full oxygen tank capacity, measure duration in seconds

Config.scubalightKeybind = 'H' -- default keybind to switch scuba flashlight on/off
Config.refillCommand = 'oxyrefill' -- command to manually refill oxygen tank capacity
Config.checkCommand = 'oxycheck' -- command to check oxygen tank capacity

Config.drop_to_reset = false -- need to drop scuba or fins to put off from ped

-- can be replaced with other notification function
if IsDuplicityVersion() then -- server notification
    sendnotification = function(xPlayer, text)
        if not xPlayer then
            return
        end
        xPlayer.showNotification(text)
    end
else -- client notification
    sendnotification = function(text)
        ESX.ShowNotification(text)
    end
end