# TPZ-CORE Job Applications

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
3. TPZ-Inventory: https://github.com/TPZ-CORE/tpz_inventory
4. TPZ-Notify: https://github.com/TPZ-CORE/tpz_notify

# Installation

1. When opening the zip file, open `tpz_job_applications-main` directory folder and inside there will be another directory folder which is called as `tpz_job_applications`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_job_applications` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.

> Exports

```lua

-- The following export is opening and displaying all the players submitted job applications.
exports.tpz_job_applications:OpenJobApplicationsManagement()

-- The following export is opening the board for creatig / submitting a new job application request.
exports.tpz_job_applications:OpenJobApplicationsRequestBoard()
```
