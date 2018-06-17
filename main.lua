function love.load()
    
    love.window.setTitle('Projeto Final')
    
    love.graphics.setBackgroundColor(0,0,0)
    
    asteroide = love.graphics.newImage('asteroide.png')
    
    rot = 0
end

function desenha_asteroide()
    local tx,ty = asteroide:getDimensions()
    
    
    love.graphics.setColor(255,255,255)
    love.graphics.draw(asteroide,w/2,3/4*h,rot,2/3,2/3,tx/2,ty/2)
    
    
    love.graphics.circle('line',w/2,3/4*h,ty/3)
end


function love.update(dt)
    
    rot = rot + dt*math.pi/5
end


function love.draw()
    w,h = love.graphics.getDimensions()
    
    desenha_asteroide()

end
