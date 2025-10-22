Config = {}

-- General Settings
Config.Locale = 'en'

-- Money Wash Settings
Config.DirtyMoneyItem = 'black_money' -- Item name for dirty money
Config.LaundryCardItem = 'laundry_card' -- Item required to wash money
Config.RequireLaundryCard = true -- Set to false if you don't want to require the card

-- Tax Settings
Config.EnableTax = true -- Set to true to enable tax reduction
Config.TaxPercentage = 15 -- Percentage of money lost during washing (0-100)

-- Access Control
-- Options: 'none' (public access), 'lscustoms' (job locked)
Config.AccessType = 'none'
Config.JobName = 'lscustoms' -- Job name if using job lock
Config.MinimumGrade = 3 -- Minimum job grade required

-- Blip Settings
Config.EnableBlips = true
Config.BlipSprite = 500
Config.BlipColor = 2
Config.BlipScale = 0.8
Config.BlipName = 'Money Wash'

-- Wash Locations
Config.WashLocations = {
    {
        coords = vector3(1122.5, -3193.5, -40.4),
        label = 'Money Wash #1',
        blip = true -- Individual blip control
    },
    {
        coords = vector3(-1160.9, -1568.9, 4.4),
        label = 'Money Wash #2',
        blip = true
    },
    {
        coords = vector3(714.9, -966.0, 30.4),
        label = 'Money Wash #3',
        blip = false -- This location won't show a blip
    }
}

-- Interaction Settings
Config.DrawDistance = 10.0 -- Distance to draw markers
Config.MarkerType = 1
Config.MarkerSize = {x = 1.5, y = 1.5, z = 1.0}
Config.MarkerColor = {r = 0, g = 255, b = 0}
Config.MarkerOpacity = 100

-- Washing Settings
Config.WashTime = 10000 -- Time in milliseconds (10 seconds)
Config.MinWashAmount = 500 -- Minimum amount to wash
Config.MaxWashAmount = 50000 -- Maximum amount to wash per transaction

-- Notification Settings
Config.UseOkokNotify = false -- Set to true if using okokNotify
Config.Use3DText = false -- Set to true to use 3D text instead of markers
