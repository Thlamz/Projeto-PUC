local msgr = require "mqttNodeMCULibrary"

local led1 = 6
local led2 = 3
local sw1 = 2
local sw2 = 1

local minhamat = "1810981"


local tdif = 500000


function mesq()
    msgr.sendMessage("esq",'asteroide')  
    
    gpio.trig(sw1)
    gpio.trig(sw2)
    
    gpio.write(led1,gpio.HIGH)
    tmr.delay(tdif)  
    gpio.write(led1,gpio.LOW)
    
    gpio.trig(sw1, "down", mesq)
    gpio.trig(sw2, "down", mdir)

end

function mdir()
    msgr.sendMessage("dir",'asteroide')
    
    gpio.trig(sw1)
    gpio.trig(sw2)

    gpio.write(led2,gpio.HIGH)
    tmr.delay(tdif)  
    gpio.write(led2,gpio.LOW)
    
    gpio.trig(sw1, "down", mesq)
    gpio.trig(sw2, "down", mdir)
    
end




gpio.mode(sw1, gpio.INPUT, gpio.PULLUP)
gpio.mode(sw2, gpio.INPUT, gpio.PULLUP)
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)



gpio.trig(sw1, "down", mesq)
gpio.trig(sw2, "down", mdir)

function mensagemrecebida()
end

msgr.start('node', minhamat ,mensagemrecebida) -- use unique id
