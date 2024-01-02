JobApplications = {}

ClientData      = { HasMenuOpen = false, CurrentApplicationId = nil, Username = nil, Job = nil, JobGrade = 0, Loaded = false }
-----------------------------------------------------------
--[[ Base Events & Threads ]]--
-----------------------------------------------------------

-- We clear job applications list (table) when resource stops for avoiding data to be kept from the system.
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
  
    JobApplications = nil
end)


-- Gets the player job when devmode set to false and character is selected.
AddEventHandler("tpz_core:isPlayerReady", function()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_core:getPlayerData", function(data)
        ClientData.Job      = data.job
        ClientData.JobGrade = data.jobGrade

        ClientData.Username = data.firstname .. ' ' .. data.lastname
    end)

    TriggerServerEvent('tpz_job_applications:requestJobApplications')
    
end)

-- Gets the player job when devmode set to true.
if Config.DevMode then
    Citizen.CreateThread(function ()

        Wait(2000)

        TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_core:getPlayerData", function(data)
            ClientData.Job      = data.job
            ClientData.JobGrade = data.jobGrade

            ClientData.Username = data.firstname .. ' ' .. data.lastname
        end)

        TriggerServerEvent('tpz_job_applications:requestJobApplications')

    end)
end

-- Updates the player job and job grade in case if changes.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    ClientData.Job      = data.job
    ClientData.JobGrade = data.jobGrade
end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

-- The following event is called after requesting the job applications data.
RegisterNetEvent("tpz_job_applications:updateJobApplications")
AddEventHandler("tpz_job_applications:updateJobApplications", function(data)
    JobApplications = data

    ClientData.Loaded = true

    if Config.Debug then
        print("Loaded Job Applications & Personal Data")
    end
end)

-- The following event is called after updating an application index (Inserting / removing).
-- We avoid updating the whole table (JobApplications) for not causing any thread warnings and server delays
-- Because it is sent to all online players for performing this update.
RegisterNetEvent("tpz_job_applications:updateJobApplicationByIndex")
AddEventHandler("tpz_job_applications:updateJobApplicationByIndex", function(type, applicationId, data)

    if type == "INSERT" then
        
        -- Inserting to the list the player's char identifier.
        JobApplications[applicationId]                = {}
        JobApplications[applicationId].id             = data.id

        JobApplications[applicationId].charidentifier = data.charidentifier
        JobApplications[applicationId].identifier     = data.identifier
        JobApplications[applicationId].username       = data.username
        JobApplications[applicationId].job            = data.job
        JobApplications[applicationId].description    = data.description
        JobApplications[applicationId].date           = data.date
        JobApplications[applicationId].approved       = 0
        JobApplications[applicationId].received       = 0

    elseif type == 'DELETE' then

        -- Removing from the list the application id after being accepted or rejected.
        JobApplications[applicationId] = nil

    elseif type == 'UPDATE' then
        JobApplications[applicationId].approved = data.approved
        JobApplications[applicationId].received = data.received
    end

    Wait(250)
    LoadJobApplications()
end)

-- The following event is triggered when using the application document item
-- which also checks for nearby players to display the application when used.
RegisterNetEvent('tpz_job_applications:showApplicationDocument')
AddEventHandler('tpz_job_applications:showApplicationDocument', function(applicationId)
    Wait(500)

    local nearestPlayers = GetNearestPlayers(2.5)
    local playersLength  = GetTableLength(nearestPlayers)

    if playersLength > 0 then
        for _, player in pairs(nearestPlayers) do
            TriggerServerEvent('tpz_job_applications:showApplicationDocumentOnTarget', GetPlayerServerId(player), applicationId)
        end
    end

    OpenApplicationById(applicationId)
end)

-- The following event is triggered only on nearby players to display the application document.
RegisterNetEvent('tpz_job_applications:displayApplicationDocument')
AddEventHandler('tpz_job_applications:displayApplicationDocument', function(applicationId)
    OpenApplicationById(applicationId)
end)

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
    RegisterActionPrompt()

    while true do
        Citizen.Wait(0)
        local sleep  = true
        local player = PlayerPedId()
        local coords = GetEntityCoords(PlayerPedId())

        local isDead = IsEntityDead(player)

        if not isDead and not ClientData.HasMenuOpen and ClientData.Loaded then

            for index, locConfig in pairs(Config.Locations) do

                local coordsDist  = vector3(coords.x, coords.y, coords.z)
                local coordsStore = vector3(locConfig.Coords.x, locConfig.Coords.y, locConfig.Coords.z)
                local distance    = #(coordsDist - coordsStore)

                -- Creating marker on the location (If enabled).
                if locConfig.Marker.Enabled and distance <= locConfig.Marker.DisplayDistance then
                    sleep = false
                    local dr, dg, db, da = locConfig.Marker.RGBA.r, locConfig.Marker.RGBA.g, locConfig.Marker.RGBA.b, locConfig.Marker.RGBA.a
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, locConfig.Coords.x, locConfig.Coords.y, locConfig.Coords.z , 0, 0, 0, 0, 0, 0, 1.7, 1.7, 0.4, dr, dg, db, da, 0, 0, 2, 0, 0, 0, 0)
                end

                if distance <= locConfig.ActionDistance then
                    sleep = false

                    local label = CreateVarString(10, 'LITERAL_STRING', Config.PromptKey.label)

                    if locConfig.Type == 'APPLICATION_BOARD_MANAGEMENT' then
                        label = CreateVarString(10, 'LITERAL_STRING', Config.PromptKey.manage_label)
                    end

                    PromptSetActiveGroupThisFrame(Prompts, label)

                    if PromptHasHoldModeCompleted(PromptsList) then

                        if locConfig.Type == "APPLICATION_BOARD_CREATE" then
                            OpenJobApplicationsRequestBoard()

                        elseif locConfig.Type == "APPLICATION_BOARD_MANAGEMENT" then
                            OpenJobApplicationsManagement()
                        end

                        Wait(2000)
                    end
                end
            end

        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)