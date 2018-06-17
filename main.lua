msgr = require('mqttLoveLibrary')


function love.load()
    minhamat = '1810981'
    
    msgr.start('love',minhamat,coord_mov) -- Ao receber mensagem executa a função coord_mov
    mov = '' --Estado inicial da movimentação
    timer = 0
    

    love.window.setTitle('Projeto Final')
    love.graphics.setBackgroundColor(0,0,0)
    w,h = love.graphics.getDimensions() -- Dimensões(global)
    
    
    asteroide = love.graphics.newImage('asteroide.png')
    
    
    math.randomseed(os.time())
    
    
    rot = 0 -- Rotação original
    asx = w/2 -- X inicial do asteroide
    k = 300 -- Constante de movimentação
    ntri = 5 -- Numero de trilhas de asteroide
    trilha = {}
    for i=1,ntri do 
        trilha[i] = {x=w/2,y=h} -- Inicializa "ntri" trilhas com valores default
    end
    
end


function desenha_asteroide()
    local ax,ay = asteroide:getDimensions()
    
    
    love.graphics.setColor(255,255,255)
    love.graphics.draw(asteroide,asx,3/4*h,rot,1,1,ax/2,ay/2)
    
    
    love.graphics.circle('line',asx,3/4*h,ay/2)
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


function coord_mov(msg) -- coordena a movimentação
    print('mensagem recebida')
    if msg=='esq' then
        mov = 'esq'
    end
    
    if msg=='dir' then
        mov = 'dir'
    end
end

function exec_mov(dt) -- Executa movimento
    
    if asx>w/2+(30*k*dt*2) and mov=='dir' then --Impede que saia da tela pela direita
        mov = ''
    end
    
    if asx<w/2-(30*k*dt*2) and mov=='esq' then --Impede que saia da tela pela esquerda
        mov = ''
    end
    
    if math.abs(asx - w/2)<30 and timer==0 then --Centraliza o asteroide para compensar pequenos erros
        asx = w/2
    end
    
    
    
    if mov=='esq' then
        timer = timer + 1
        
        asx = asx - k*dt*2
    
    elseif mov=='dir' then
        timer = timer + 1
        
        asx = asx + k*dt*2
    
    else
        timer = 0
    end
    
    
    if timer >= 30 then
        mov = ''
    end
    
end

function love.update(dt)
    
    rot = rot + dt*math.pi/5 -- Rotaciona o asteroide a cada update
    
    msgr.checkMessages()
    cria_trilha(dt)
    exec_mov(dt)
end


function love.draw()
    
    desenha_trilha()    
    desenha_asteroide()
  
end
