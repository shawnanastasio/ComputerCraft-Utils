-- sIM Program.
-- Copyright 2014 Shawn Anastasio


-- Change this to whatever side your modem is on
modemside = "top"
connected = 0

rednet.open(modemside)

print("Welcome to sIM.")
uid = os.getComputerID()
print("Your Unique IM ID is: " .. uid)
io.write("What's your buddy's UID?: ")
buddy = tonumber(io.read())

print()
print("Waiting for buddy to come online..")

function startIM()
  print("Connection Established!")

  function sendmsg()
    while true do
      io.write("Send Message> ")
      tosend = io.read()

      if tosend ~= "" then
        rednet.send(buddy, tosend)
      end
    end
  end

  function recvmsg()
    while true do
      id, message = rednet.receive()
      if id == buddy then
        if message ~= "IMPing" then
          print()
          print("Buddy> " .. message)
          io.write("Send Message> ")
        end
      end
    end
  end

  while true do
    parallel.waitForAny(sendmsg, recvmsg)
  end
end

function ping()
  while true do
    -- Ping the buddy until i get a response
    if connected == 0 then
      rednet.send(buddy, "IMPing")
    end
    sleep(1)
  end
end

function recvping()
  while true do
    -- Recieve pings and such
    id, message = rednet.receive()
    if id == buddy then
      if message == "IMPing" then
        connected = 1
        -- Send one final ping
        rednet.send(buddy, "IMPing")
        startIM()
      end

      if message ~= "IMPing" then
        print("ERROR: Malformed message recieved. Ask your buddy to restart client")
      end
    end
  sleep(1)
  end
end

while connected == 0 do
  parallel.waitForAny(ping, recvping)
end
