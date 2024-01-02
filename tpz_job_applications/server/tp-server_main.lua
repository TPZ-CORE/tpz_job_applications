

local TPZ    = {}
local TPZInv = exports.tpz_inventory:getInventoryAPI()

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

JobApplications = {}

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

-- We clear job applications list (table) when resource stops for avoiding data to be kept from the system.
AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
      return
  end

  JobApplications = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

  exports["ghmattimysql"]:execute("SELECT * FROM job_application_requests", {}, function(result)

    for index, res in pairs (result) do

      JobApplications[res.id] = {}
      JobApplications[res.id] = res

    end
  
  end)

end)

-- The following event is called and used only to receive the job applications.
RegisterServerEvent('tpz_job_applications:requestJobApplications')
AddEventHandler('tpz_job_applications:requestJobApplications', function()
  local _source = source

  TriggerClientEvent("tpz_job_applications:updateJobApplications", _source, JobApplications)
end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_job_applications:showApplicationDocumentOnTarget')
AddEventHandler('tpz_job_applications:showApplicationDocumentOnTarget', function(targetId, applicationId)
  TriggerClientEvent('tpz_job_applications:displayApplicationDocument', targetId, applicationId)
end)

-- The following event is called and used to send the trading credentials in the right time.
RegisterServerEvent('tpz_job_applications:submitApplication')
AddEventHandler('tpz_job_applications:submitApplication', function(job, description)
	local _source         = source
  local xPlayer         = TPZ.GetPlayer(_source)

	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()

  local username        = xPlayer.getFirstName() .. " " .. xPlayer.getLastName()
  local steamName       = GetPlayerName(_source)
  
  local currentDate         = os.date('%d').. '/' ..os.date('%m').. '/' .. Config.Year .. " " .. os.date('%H') .. ":" .. os.date('%M')
  local randomApplicationId = charidentifier .. '-' .. os.date('%H') .. os.date('%M') .. math.random(1,9) .. math.random(1,9) .. math.random(1,9) .. math.random(1,9) .. math.random(1,9)
  
  -- Inserting to the list the player's char identifier.
  JobApplications[randomApplicationId]                = {}
  JobApplications[randomApplicationId].id             = randomApplicationId

  JobApplications[randomApplicationId].charidentifier = charidentifier
  JobApplications[randomApplicationId].identifier     = identifier
  JobApplications[randomApplicationId].username       = username
  JobApplications[randomApplicationId].job            = job
  JobApplications[randomApplicationId].description    = description
  JobApplications[randomApplicationId].date           = currentDate
  JobApplications[randomApplicationId].approved       = 0
  JobApplications[randomApplicationId].received       = 0
  Wait(250)

  TriggerClientEvent("tpz_job_applications:updateJobApplicationByIndex", -1, 'INSERT', randomApplicationId, JobApplications[randomApplicationId])

  -- Inserting to the sql the player's job application request data.
  local Parameters = { 
    ['id']             = randomApplicationId,
    ['charidentifier'] = charidentifier,
    ['identifier']     = identifier,
    ['username']       = username,
    ['job']            = job,
    ['description']    = description,
    ['date']           = currentDate,
  }

  exports.ghmattimysql:execute("INSERT INTO job_application_requests ( `id`, `identifier`,`charidentifier`, `username`, `job`, `description`, `date`) VALUES ( @id, @identifier, @charidentifier, @username, @job, @description, @date)", Parameters)
  
  -- Sending a notification using TPZ Notify.
  local NotifyData = Locales['SUBMIT_JOB_APPLICATION']
  TriggerClientEvent("tpz_notify:sendNotification", _source, NotifyData.title, NotifyData.message, NotifyData.icon, "success", NotifyData.duration)

  -- If webhooking is enabled, we send a webhook with all the player's job application request data.
  local webhookData = Config.Webhooking

  if webhookData.Enabled then
    local title   = "📝` The following player submitted a job application request.`"
    local message = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. identifier .. " (Char: " .. charidentifier .. ")`**\nJob Name: **`" .. job .. "**\nDescription: \n\n`" .. description .. "`"

    TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
  end

end)

-- The following event is called from NUI when a player approves an application.
RegisterServerEvent('tpz_job_applications:approveApplication')
AddEventHandler('tpz_job_applications:approveApplication', function(applicationId)
	local _source         = source
  local xPlayer         = TPZ.GetPlayer(_source)
	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()

  local steamName       = GetPlayerName(_source)

  local applicationData = JobApplications[applicationId]

  -- Sending a notification using TPZ Notify.
  local NotifyData = Locales['APPROVED_JOB_APPLICATION']
  TriggerClientEvent("tpz_notify:sendNotification", _source, NotifyData.title, string.format(NotifyData.message, applicationData.username), NotifyData.icon, "info", NotifyData.duration)

  -- Changing status of the application from the sql after approving the application.
  exports.ghmattimysql:execute("UPDATE job_application_requests SET approved = @approved WHERE id = @id", { ['id'] = applicationId, ['approved'] = 1})

  -- If webhooking is enabled, we send a webhook with all the player's job application request data.
  local webhookData = Config.Webhooking

  if webhookData.Enabled then
    local title   = "📝` The following player approved a job application request.`"
    local message = "**(Manager's) Steam name: **`" .. steamName .. "`**\n (Manager's) Identifier: **`" .. identifier .. " (Char: " .. charidentifier .. ")`**\nJob Name: **`" .. applicationData.job .. "**\nDescription: \n\n`" .. applicationData.description .. "`"

    TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
  end

  JobApplications[applicationId].approved = 1
  TriggerClientEvent("tpz_job_applications:updateJobApplicationByIndex", -1, 'UPDATE', applicationId, { approved = 1, received = 0  })
end)

-- The following event is called from NUI when a player rejects an application.
RegisterServerEvent('tpz_job_applications:rejectApplication')
AddEventHandler('tpz_job_applications:rejectApplication', function(applicationId)
	local _source         = source
  local xPlayer         = TPZ.GetPlayer(_source)
	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()

  local steamName       = GetPlayerName(_source)

  local applicationData = JobApplications[applicationId]

  -- Sending a notification using TPZ Notify.
  local NotifyData = Locales['REJECTED_JOB_APPLICATION']
  TriggerClientEvent("tpz_notify:sendNotification", _source, NotifyData.title, string.format(NotifyData.message, applicationData.username), NotifyData.icon, "info", NotifyData.duration)

  -- Changing status of the application from the sql after approving the application.
  exports.ghmattimysql:execute("UPDATE job_application_requests SET approved = @approved WHERE id = @id", { ['id'] = applicationId, ['approved'] = 2})


  -- If webhooking is enabled, we send a webhook with all the player's job application request data.
  local webhookData = Config.Webhooking

  if webhookData.Enabled then
    local title   = "📝` The following player rejected a job application request.`"
    local message = "**(Manager's) Steam name: **`" .. steamName .. "`**\n (Manager's) Identifier: **`" .. identifier .. " (Char: " .. charidentifier .. ")`**\nJob Name: **`" .. applicationData.job .. "**\nDescription: \n\n`" .. applicationData.description .. "`"

    TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
  end

  JobApplications[applicationId].approved = 2
  TriggerClientEvent("tpz_job_applications:updateJobApplicationByIndex", -1, 'UPDATE', applicationId, { approved = 2, received = 0 })

end)

-- The following event is called from NUI when an application sets as received.
-- By calling it, we give the application as an item and that item will be able to be readable by everyone.
RegisterServerEvent('tpz_job_applications:setApplicationAsReceivedById')
AddEventHandler('tpz_job_applications:setApplicationAsReceivedById', function(applicationId)
  local _source = source

  local canCarryItem = TPZInv.canCarryItem(_source, Config.DocumentItem, 1)

  if not canCarryItem then
    -- Sending a notification using TPZ Notify.
    local wNotifyData = Locales['NOT_ENOUGH_INVENTORY_WEIGHT']
    TriggerClientEvent("tpz_notify:sendNotification", _source, wNotifyData.title, wNotifyData.message, wNotifyData.icon, "error", wNotifyData.duration)
    return
  end

  local metadata = { applicationId = applicationId, description = JobApplications[applicationId].username, durability = -1 }
  TPZInv.addItem(_source, Config.DocumentItem, 1, metadata)

  -- Sending a notification using TPZ Notify.
  local notifyData = Locales['RECEIVED_APPLICATION_DOCUMENT']
  TriggerClientEvent("tpz_notify:sendNotification", _source, notifyData.title, notifyData.message, notifyData.icon, "success", notifyData.duration)

  -- Changing status of the application from the sql after receiving the application.
  exports.ghmattimysql:execute("UPDATE job_application_requests SET received = @received WHERE id = @id", { ['id'] = applicationId, ['received'] = 1})

  JobApplications[applicationId].received = 1

  local approvedStatus = JobApplications[applicationId].approved
  TriggerClientEvent("tpz_job_applications:updateJobApplicationByIndex", -1, 'UPDATE', applicationId, {approved = approvedStatus, received = 1})
end)

-- The following event is called only on rejected applications.
RegisterServerEvent('tpz_job_applications:deleteApplicationById')
AddEventHandler('tpz_job_applications:deleteApplicationById', function(applicationId)

  -- Deleting the application request from the sql after rejecting the application.
  exports.ghmattimysql:execute( "DELETE FROM job_application_requests WHERE id = @id", {["@id"] = applicationId})

  JobApplications[applicationId] = nil
  TriggerClientEvent("tpz_job_applications:updateJobApplicationByIndex", -1, 'DELETE', applicationId)
end)