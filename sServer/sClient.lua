-- sClient Information Retrival System
-- Copyright 2015 Shawn Anastasio
-- Licensed under the Gnu Public License version 3.0

-- Change to side of your modem
modemside = "top"

-- uID of server (set to "" if none)
-- Ex. server = 1
server = ""

rednet.open(modemside)

print("sClient v1.0 started")


if server == "" then
  io.write("Enter server UID: ")

  server = io.read()
  server = tonumber(server)
end

--Prompt
prompt = 1
first = 1
print("Connecting to server..")
print()
version = "1.1"
command = "index"

while prompt == 1 do
  if first == 1 then
    -- Send client version
    rednet.send(server, "--CLIENT HANDSHAKE--")
    rednet.send(server, version)
    rednet.send(server, "--END CLIENT HANDSHAKE--")
    -- Wait for response
    serverResponse, response = rednet.receive()
    if serverResponse == server then
      if response ~= "--SUCCESS--" then
        print("ERROR, your client version is likely unsupported.")
        print()
        exit()
      end
    end
  end

  if first ~= 1 then
    io.write("s>")
    command = io.read()
  end

  if command == "exit" then
    return 1
  end

  if command ~= "" then
    rednet.send(server, command)

    --Loop until --END-- for response
    go = 1

    while go == 1 do
      id, message = rednet.receive()
      if id == server then
        if message ~= "--END--" then
          print(message)
        end

        if message == "--END--" then
          go = 0
        end
      end
    end

  end
  first = 0
end
