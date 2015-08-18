-- Copyright 2015 Shawn Anastasio
-- Licensed under the Gnu Public License version 3.0

--os.pullEvent = os.pullEventRaw
print()
print("Started sDB Enterprise v1.2")

modemside = "top"
rednet.open(modemside)

--BEGIN CONFIGURATION--

--Enables querying of secondary server
recursive = false
--IP of secondary server (only if above is true)
hl = 0

--Enables client access list
restricted = false
--IPs of authorized clients (comma separated, only if above is true)
clientlist = {0}

--Enables backdoor to shut down server
backdoorenabled = false
--Backdoor password (only if above is true)
backdoorpass = "backdoor"

--END CONFIGURATION--

function inList(tbl, item)
  for key, value in pairs(tbl) do
    if value == item then return true end
  end
  return false
end

function validateQuery(query)
  local filepath = "/tokens"
  local f = fs.open(filepath, "r")

  local Qresult = 0

  text = f.readLine()
  while text ~= nil do
    if text == query then
      Qresult = 1
    end
    text = f.readLine()
  end

  if Qresult == 1 then
    return 1
  else
    if recursive == true then
      --Query Higher Access Level
      rednet.send(hl, query)
      id, result = rednet.receive()
      if id == hl then
        if result == "true" then
          return 1
        end
      end
    end

    return 0
  end
end


function listenConnection()
  client, query = rednet.receive()
  if (restricted == true and inList(clientlist, client)) or (restricted == false) then

    if backdoorenabled == true then
      if query == backdoorpass then
        print("Backdoor activated.")
        exit()
      end
    end

    result = validateQuery(query)

    if result == 1 then
      rednet.send(client, "true")
    else
      rednet.send(client, "false")
    end
  end
end

while true do
  listenConnection()
end
