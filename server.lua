local baseUrl = GetConvar("web_baseUrl", "")
local resName = GetCurrentResourceName()


CreateThread(function()

    print("=============------------ PMMS-DUI ------------=============")

    if GetResourceState("pmms") == "started" then
        pmmsConfig = LoadResourceFile("pmms", "config.lua")
        if not pmmsConfig then
           print("PMMS-DUI requires the PMMS config file to be present in the pmms resource!")
            return
        end
    else
        print("PMMS-DUI requires the PMMS resource to be running!")
        return
    end

    if resName ~= "pmms-dui" then
        print("This resource MUST BE NAMED 'pmms-dui' to work correctly!")
        return
    end


    if baseUrl == "" then
        print("PMMS-DUI unable to find the CFX Nucleus URL for DRM Content. This may not work correctly!")
        local endpoint = GetCurrentServerEndpoint()
        url = "http://" .. endpoint
        print("Using default server endpoint: " .. url)
    else
        url = "https://"..baseUrl
    end


    local finalUrl = url .. "/pmms-dui/"

    local escapedUrl = finalUrl:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")

    if pmmsConfig then
        -- Check for both single and double quote patterns
        if not (pmmsConfig:find('Config%.dui%.urls%.https%s*=%s*"[^"]*' .. escapedUrl .. '"') or
                pmmsConfig:find("Config%.dui%.urls%.https%s*=%s*'[^']*" .. escapedUrl .. "'")) then
            print("PMMS-DUI has found the PMMS config file, but the URL is not set correctly.") 
            print("Type updateconfig in the server console to update the PMMS config file with the correct configuration and restart PMMS automatically.")
            print("---------OR----------")
            print("If you would like to manually update the config file, set Config.dui.urls.https in the pmms/config.lua to '" .. finalUrl .. "'")

            RegisterCommand("updateconfig", function(source)
                if source == 0 then
                    local updatedConfig = pmmsConfig
                        :gsub('Config%.dui%.urls%.https%s*=%s*".-"', 'Config.dui.urls.https = "' .. finalUrl .. '"')
                        :gsub("Config%.dui%.urls%.https%s*=%s*'.-'", "Config.dui.urls.https = '" .. finalUrl .. "'")

                    SaveResourceFile("pmms", "config.lua", updatedConfig, -1)
                    print("PMMS-DUI has updated the PMMS config file with the correct configuration. Attempting to restart PMMS...")
                    Wait(1000)
                    StopResource("pmms")
                    Wait(1000)
                    StartResource("pmms")
                    SetHttpHandler(createHttpHandler())        
                    print("PMMS-DUI has restarted PMMS. PMMS-DUI is now running.")
                else
                    print("You must be the server console to run this command.")
                end
            end, false)
        else
            print("PMMS-DUI has found the PMMS config file and the URL is set correctly. PMMS-DUI is now running.")
            SetHttpHandler(createHttpHandler())
        end
    end
end)
