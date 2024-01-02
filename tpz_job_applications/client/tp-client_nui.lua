local HasCooldown = false

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

OpenJobApplicationsManagement = function ()
    local isAllowed = false
    local finished  = false

    for index, job in pairs (Config.Jobs) do

        if job.name == ClientData.Job and job.grade == ClientData.JobGrade then
            isAllowed = true
        end

        if next(Config.Jobs, index) == nil then
            finished = true
        end
    end

    while not finished do
        Wait(250)
    end

    if not isAllowed then
        -- Sending a warning notification using TPZ Notify.
        local notifyData = Locales['MANAGEMENT_NOT_ALLOWED']
        TriggerEvent("tpz_notify:sendNotification", notifyData.title, notifyData.message, notifyData.icon, "error", notifyData.duration)
        return
    end

    SendNUIMessage({ action = 'clearJobApplications' })
    SendNUIMessage({ action = 'loadPersonalInformation', username = ClientData.Username })

    LoadJobApplications()
    ToggleUI(true, 'MANAGEMENT')
end

OpenJobApplicationsRequestBoard = function ()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_job_applications:hasSubmittedJobApplication", function(cb)

        if cb == nil then
            SendNUIMessage({ action = 'loadPersonalInformation', username = ClientData.Username})

            for index, application in pairs (Config.ApplicationJobs) do
                SendNUIMessage({ action = 'loadJobApplicationFromList', application = application.label })
            end
        
            ToggleUI(true, "REQUEST")
        else

            local data = JobApplications[cb]

            ClientData.CurrentApplicationId = data.id

            SendNUIMessage({ action = 'loadPersonalApplicationInformation', username = ClientData.Username, job = data.job, description = data.description, date = data.date, approved = data.approved, received = data.received})

            ToggleUI(true, "APPLICATION_OVERVIEW")

        end

    end)
end

OpenApplicationById = function(applicationId)
    local data = JobApplications[applicationId]

    if data == nil or ClientData.HasMenuOpen then
        return
    end

    SendNUIMessage({ action = 'loadPersonalApplicationInformation', username = data.username, job = data.job, description = data.description, date = data.date, approved = data.approved, received = 1})

    ToggleUI(true, "APPLICATION_OVERVIEW")
end


LoadJobApplications = function()
    
    local applicationsLength = GetTableLength(JobApplications)

    if applicationsLength > 0 then

        for index, application in pairs (JobApplications) do

            if application.approved == 0 then
                SendNUIMessage({ action = 'loadJobApplicationsRequest', application = application })
            end

        end

    end

end

ToggleUI = function(display, type)
    SetNuiFocus(display,display)

	ClientData.HasMenuOpen = display

    SendNUIMessage({ action = 'toggle', type = type, toggle = display })
end

CloseUI = function()
    SendNUIMessage({action = 'close'})
end


-----------------------------------------------------------
--[[ General NUI Callbacks ]]--
-----------------------------------------------------------

RegisterNUICallback('submit', function(data)

    if HasCooldown then
        return
    end

    HasCooldown = true

    CloseUI()

    TriggerServerEvent('tpz_job_applications:submitApplication', data.job, data.description)

    Wait(2000)
    HasCooldown = false

end)


RegisterNUICallback('close', function()
	ToggleUI(false)
end)

-----------------------------------------------------------
--[[ User NUI Callbacks ]]--
-----------------------------------------------------------

RegisterNUICallback('receive', function()

    if HasCooldown then
        return
    end

    HasCooldown = true

    
    CloseUI()

    TriggerServerEvent('tpz_job_applications:setApplicationAsReceivedById', ClientData.CurrentApplicationId)

    Wait(2000)
    HasCooldown = false

end)


RegisterNUICallback('delete', function()

    if HasCooldown then
        return
    end

    HasCooldown = true

    CloseUI()

    TriggerServerEvent('tpz_job_applications:deleteApplicationById', ClientData.CurrentApplicationId)

    Wait(2000)
    HasCooldown = false

end)

-----------------------------------------------------------
--[[ Management NUI Callbacks ]]--
-----------------------------------------------------------


RegisterNUICallback('openManagementList', function(cb)

    SendNUIMessage({ action = 'clearJobApplications' })
    SendNUIMessage({ action = 'loadPersonalInformation', username = ClientData.Username })

    LoadJobApplications()
    ToggleUI(true, "MANAGEMENT")
end)

RegisterNUICallback('manage', function(cb)

    local data = JobApplications[cb.applicationId]

    SendNUIMessage({ action = 'loadPersonalApplicationInformation', username = data.username, job = data.job, description = data.description, date = data.date, approved = -1, received = 0})
end)

RegisterNUICallback('approve', function(data)

    if HasCooldown then
        return
    end

    HasCooldown = true

    CloseUI()

    TriggerServerEvent('tpz_job_applications:approveApplication', data.applicationId)

    Wait(2000)
    HasCooldown = false

end)

RegisterNUICallback('reject', function(data)

    if HasCooldown then
        return
    end

    HasCooldown = true

    CloseUI()

    TriggerServerEvent('tpz_job_applications:rejectApplication', data.applicationId)

    Wait(2000)
    HasCooldown = false

end)

