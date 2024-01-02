local TPZ = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

-- The following callback returns if the player has already submitted a job application or not.
-- If submitted, it will return the job application data.
exports.tpz_core:rServerAPI().addNewCallBack("tpz_job_applications:hasSubmittedJobApplication", function(source, cb)
	local _source         = source
	local xPlayer         = TPZ.GetPlayer(_source)

	local charidentifier  = xPlayer.getCharacterIdentifier()
	local finished        = false
	local applicationId   = nil

	local applicationsLength = GetTableLength(JobApplications)

    if applicationsLength > 0 then

		for index, application in pairs (JobApplications) do
		
			if application.charidentifier == charidentifier and application.received == 0 then
				applicationId = application.id
				finished = true
			end

			if next(JobApplications, index) == nil then
				finished = true
			end
		end

	else
		finished = true
	end

	while not finished do
		Wait(100)
	end

	cb(applicationId)
end)


-- @GetTableLength returns the length of a table.
function GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end