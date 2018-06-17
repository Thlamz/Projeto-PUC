function love.load()
    
    love.window.setTitle('Projeto Final')
    
    w,h = love.graphics.getDimensions() -- Dimensões(global)
    love.graphics.setBackgroundColor(0,0,0)
    
    asteroide = love.graphics.newImage('asteroide.png')
    
    math.randomseed(os.time())
    
    rot = 0
    asx = w/2 -- X inicial do asteroide
    k = 300
    
    ntri = 5 -- Numero de trilhas do asteroide
    trilha = {}
    for i=1,ntri do 
        trilha[i] = {x=w/2,y=h} -- 3 trilhas com valores default
    end
    
end


function desenha_asteroide()
    local ax,ay = asteroide:getDimensions()
    
    
    love.graphics.setColor(255,255,255)
    love.graphics.draw(asteroide,asx,3/4*h,rot,1,1,ax/2,ay/2)
    
    
    love.graphics.circle('line',w/2,3/4*h,ay/2)
end


function cria_trilha(dt) -- Trilha do asteroide
    local ax,ay = asteroide:getDimensions()
    
    
    local fila = {} -- Filas possíveis
    
    for i=1,6 do
        fila[i] = ay*(i)/6
    end
    
    for i=1,ntri do
        if trilha[i].y>=h+20 then -- Reseta a trilha ao sair da tela
            
            esc = math.floor(math.random(2,12)/2) -- Escolhe um numero que sera a fila
            trilha[i].x = (asx-ay/2)+fila[esc]            
            trilha[i].y = 3/4*h+ay/4
            
        end
        

        trilha[i].y = trilha[i].y + dt*k + (i)
    end
end
    

function desenha_trilha()
    for i=1,ntri do
        love.graphics.setColor(255,255,255)
        love.graphics.rectangle('fill',trilha[i].x,trilha[i].y,1,50) 
    end
end

function love.update(dt)
    
    rot = rot + dt*math.pi/5 -- Rotaciona o asteroide a cada update
    
    cria_trilha(dt)
end


function love.draw()
    
    desenha_trilha()    
    desenha_asteroide()
  
end
