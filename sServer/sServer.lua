-- sServer Information Delivery System
-- Copyright 2015 Shawn Anastasio
-- Licensed under the Gnu Public License version 3.0

-- Change to side of your modem
modemside = "top"
connection = 0

rednet.open(modemside)

--os.pullEvent = os.pullEventRaw
print("sServer v1.1 started")
print("Listening for connections")

--BEGIN CONFIGURATION--

--Enables backdoor to shut down server
backdoorenabled = false
--Backdoor password (only if above is true)
backdoorpass = "backdoor"

--END CONFIGURATION--

version = "1.1"
function timeout2()
  sleep(2)
  rednet.send(client, "--TIMEOUT--")
end

function checkVer()
  -- Listen for version number
  client, filename = rednet.receive()
  if filename ~= version then
    rednet.send(client, "--ERROR--")
  end
end

function endHandshake()
  client, filename = rednet.receive()
  if filename ~= "--END CLIENT HANDSHAKE--" then
    rednet.send(client, "--ERROR--")
  else
    --print("DEBUG: Ended handshake successfully")
    rednet.send(client, "--SUCCESS--")
  end
end

function handshake()
  -- Client handshake has been started

  -- Listen for version number or timeout
  parallel.waitForAny(timeout2, checkVer)
  --checkVer()

  -- Listen for end handshake or timeout
  parallel.waitForAny(timeout2, endHandshake)
  --endHandshake()

end

--Send list of files to client
function sendList(client)
  local FileList = fs.list("/server")
  for _, file in ipairs(FileList) do
    --send line
    rednet.send(client, file)
  end
  rednet.send(client, "--END--")
end

--Check against file names in server
function validateFilename(client, filename)

  if backdoorenabled == true and filename == backdoorpass then
    print("Backdor activated.")
    exit()
  end

  if filename == "--CLIENT HANDSHAKE--" then
    --Validate handshake
    handshake()
    --Done w/ handshake, listen again
    return 2
  end

  if filename == "list" then
    --Send list of files
    sendList(client)
  end

  match = 0
  local FileList = fs.list("/server")

  --check for match
  for _, file in ipairs(FileList) do
    if file == filename then
      match = 1
    end
  end

  --if filename is valid, return 1
  if match == 1 then
    return 1
  else
    return 0
  end

end

--Listen for connection
function listenConnection()
  client, filename = rednet.receive()

  validResult = validateFilename(client, filename)

  if validResult == 1 then
    --rednet.send(client, "VALID REQUEST")
    --rednet.send(client, "--END--")

    --Return contents of requested file
    filepath = "/server/" .. filename

    local f = fs.open(filepath, "r")
    local text = f.readLine()

    while text ~= nil do
      rednet.send(client, text)
      text = f.readLine()
    end
    rednet.send(client, "--END--")
  end

  if validResult == 0 then
    rednet.send(client, "INVALID REQUEST")
    rednet.send(client, "--END--")
  end

end


--Start Program
while true do
  listenConnection()
end
