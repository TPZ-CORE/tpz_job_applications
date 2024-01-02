Config = {}

Config.DevMode = false
Config.Debug   = false

Config.PromptKey = { key = 0x760A9C6F, label = 'Create / View Job Application', manage_label = 'Manage Job Applications'}

-----------------------------------------------------------
--[[ General ]]--
-----------------------------------------------------------

Config.Year = 1890

-- The following jobs will be able to view, accept or reject the job application requests.
Config.Jobs = { {name = 'mayor', grade = 0 } }

-- The following jobs will be displayed on the board for the players to create job application requests.
Config.ApplicationJobs = {
    
    ['medic']   = { label = "Medical Department" },
    ['police']  = { label = "Police Department"  },
}

Config.DocumentItem = 'job_application_document'

-----------------------------------------------------------
--[[ Discord Webhooking  ]]--
-----------------------------------------------------------

-- Submit, Accept, Reject Webhooking Actions.
Config.Webhooking = {

    Enabled = false,
    Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", -- The discord webhook url.
    Color = 10038562,
}

-----------------------------------------------------------
--[[ Locations ]]--
-----------------------------------------------------------

-- Types: 
-- `APPLICATION_BOARD_CREATE` : The location where the players create a job application.
-- `APPLICATION_BOARD_MANAGEMENT` : The location where allowed jobs are able to manage the job applications.
Config.Locations = {

    [1] = {

        Type   = "APPLICATION_BOARD_CREATE",

        Coords = {x = 1367.435, y = -6988.28, z = 56.420, h = 232.3072052002 },

        ActionDistance  = 2.0,

        BlipData = {
            Allowed = true,
            Title   = "Job Applications",
            Sprite  = 1475879922,
        },

        -- If this is enabled, a circular marker will be displayed when close to the warehouse actions.
        Marker = {
            Enabled = true,
            RGBA    = {r = 240, g = 230, b = 140, a = 50},
            DisplayDistance = 10.0,
        },


    },

    [2] = {

        Type   = "APPLICATION_BOARD_MANAGEMENT",
        
        Coords = {x = 1364.828, y = -6999.88, z = 54.838, h = 86.037315368652 },
        
        ActionDistance  = 2.0,

        -- If this is enabled, a circular marker will be displayed when close to the warehouse actions.
        Marker = {
            Enabled = true,
            RGBA    = {r = 240, g = 230, b = 140, a = 50},
            DisplayDistance = 10.0,
        },

    },


}
