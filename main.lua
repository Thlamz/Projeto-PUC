msgr = require('mqttLoveLibrary')


function love.load()
    minhamat = '1810981' -- Sua matricula


    --Textos
    titulo = love.graphics.newFont('BLADRMF_.TTF',60)
    menuf = love.graphics.newFont('BLADRMF_.TTF',30)
    menuT = love.graphics.newText(titulo,'')
    menu = love.graphics.newText(menuf,'')
    --Tela
    love.window.setTitle('Projeto Final')
    love.window.setMode(800,950)
    love.graphics.setBackgroundColor(0,0,0)
    w,h = love.graphics.getDimensions() -- Dimensões(global)
    -------------------------------//-------------------------------
    --Movimentação
    msgr.start(minhamat,minhamat,coord_mov) -- Ao receber mensagem executa a função coord_mov
    vmov= 5 -- Velocidade da movimentação
    nfaixas = 3 -- Número de faixas na movimentação
    mov = '' --Estado inicial da movimentação
    dist = 0 -- Variavel auxiliar "distância", para a movimentação
    nfaixas = nfaixas+1 --Não alterar(ajusta para o número real de faixas)
    -------------------------------//------------------------------
    --Sprites
    asteroide = love.graphics.newImage('asteroide.png')
    background = love.graphics.newImage("BKG.png")
    backgroundmenu = love.graphics.newImage("BKGM.png")
    bomb = love.graphics.newImage('bomb.png')
    
    hp = love.graphics.newImage("HP.png")
    local vx,vy = hp:getDimensions()
    fullhp = love.graphics.newQuad(2,0,54,55,vx,vy)
    halfhp = love.graphics.newQuad(61,0,54,55,vx,vy)
    nohp = love.graphics.newQuad(119,0,54,55,vx,vy)
    
    ships = love.graphics.newImage("Ships.png")
    local nx,ny = ships:getDimensions()
    ship = love.graphics.newQuad(191,0,93,96,nx,ny)
    
    -------------------------------//-------------------------------
    --Trilha
    ntri = 6 -- Numero de trilhas de asteroide
    trilha = {}
    for i=1,ntri do 
        trilha[i] = {x=w/2,y=h} -- Inicializa "ntri" trilhas com valores default
    end
    -------------------------------//-------------------------------
    --Elementos
    eltimer = 0
    ultimoel = -1 -- Segundos desde o ultimo elemento
    elementos = {} -- Elementos existentes
    -------------------------------//-------------------------------
    --Defaults
    estado = 'menu' --Jogo começa no menu
    vida = 3 -- Vida inicial
    starttime = 0 --Inicializa a variavel inicio do jogo
    runtime = 0 -- Tempo desde o inicio do jogo
    velocidade = 0 -- Velocidade inicial dos elementos
    rot = 0 -- Rotação original
    asx = w*(math.floor(nfaixas/2))/(nfaixas) -- X inicial do asteroide
    asy = 4/5*h -- Y do asteroide
    k = 300 -- Constante de movimentação
    math.randomseed(os.time())
    -------------------------------//------------------------------
end


function tempo_de_jogo()
    tempo = os.time()
    runtime = tempo - starttime
end


function faz_background()
    local X,Y = background:getDimensions()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(background,0,0)
end

function desenha_hp()
    love.graphics.setColor(255,255,255)
    if vida==3 then
      love.graphics.draw(hp,fullhp,30,h-80)
    
    elseif vida==2 then
      love.graphics.draw(hp,halfhp,30,h-80)
      
    else
      love.graphics.draw(hp,nohp,30,h-80)
    end
end

function faz_backgroundmenu()
    local X,Y = backgroundmenu:getDimensions()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(backgroundmenu,0,-100)
end

function desenha_titulo()
  menuT:set('asteroide')
  Mx,My = menuT:getDimensions()
  
  love.graphics.setColor(255,255,0)
  love.graphics.draw(menuT,w/2-Mx/2,200-My/2)
end

function desenha_menu()
    menu:set('Para jogar aperte "enter"')
    mx,my = menu:getDimensions()

    love.graphics.setColor(255,255,0)
    love.graphics.draw(menu,w/2-mx/2,h/2-my/2)
end


function desenha_asteroide()
    local ax,ay = asteroide:getDimensions()


    love.graphics.setColor(255,255,255)
    love.graphics.draw(asteroide,asx,4/5*h,rot,1,1,ax/2,ay/2)


    love.graphics.circle('line',asx,asy,ay/2)
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
    estado='game'


    local _,_,inst,mat=string.find(msg,'(%a+)(%d+)')
    print('mensagem recebida')
    if mat==minhamat then

        if inst=='esq' then
            mov = 'esq'
        end

        if inst=='dir' then
            mov = 'dir'
        end
    end
end

function exec_mov(dt) -- Executa movimento

    if asx>(nfaixas-1)*w/nfaixas and mov=='dir' then --Impede que saia da tela pela direita
        mov = ''
    end

    if asx<w/nfaixas and mov=='esq' then --Impede que saia da tela pela esquerda
        mov = ''
    end

    if math.abs(asx - w*(math.floor(nfaixas/2))/(nfaixas))<50 and dist==0 then --Centraliza o asteroide para compensar pequenos erros
        asx = w*(math.floor(nfaixas/2))/(nfaixas)
    end


    if mov=='esq' then
        dist = dist + (1/nfaixas*w)*dt*vmov -- Essa formulas garante velocidade fixa independente da velocidade do computador

        asx = asx - (1/nfaixas*w)*dt*vmov

    elseif mov=='dir' then
        dist = dist + (1/nfaixas*w)*dt*vmov
        asx = asx + (1/nfaixas*w)*dt*vmov

    else
        dist = 0
    end

    if dist >= 1/nfaixas*w then
        mov = ''
    end
end


function posicao_elemento(dt)
    for key,el in pairs(elementos) do -- Acessa os elementos existentes
        velocidade = k*dt + eltimer/10
        el.y = el.y + velocidade --Move os elementos existentes

        if el.y>h+10 then -- Deleta os elementos que saem da tela
            elementos[key]=nil
        end
    end

    eltimer = eltimer+dt
    local dtempo = eltimer - ultimoel -- Tempo deste o ultimo elemento (s)

    local dificuldade = ((-10*eltimer^2 + 3)*velocidade)
    print(dificuldade)

    if dificuldade<1/30*velocidade then
        dificuldade=1/30*velocidade
    end

    if dtempo>dificuldade or ultimoel==-1 then -- Mais elementos conforme o tempo passa
        local tipoel = math.floor(math.random(1,6))

        if tipoel>1 then
            tipoel = 1
        else
            tipoel = 2
        end



        local faixa = math.floor(math.random(1,nfaixas-1))
        local objx = w*(faixa/nfaixas)
        local objy = 0

        for el=1,#elementos+1 do
            if not elementos[el] then -- Coloca o elemento no primeiro espaço vazio da tabela
                elementos[el] = {x=objx,y=objy,tipo=tipoel}
            end
        end

        ultimoel = eltimer
    end

end

function desenha_elementos()

    for _,el in pairs(elementos) do

        if el.tipo==1 then
            nx,ny=ships:getDimensions()
            
            love.graphics.draw(ships,ship,el.x-(93/2),el.y-(96/2))
        end
            
        if el.tipo==2 then -- Tipo 2=bomba
            bx,by=bomb:getDimensions()
            love.graphics.draw(bomb,el.x-bx/2,el.y-by/2)
        end
    end

end

function collision()
    
    for key,el in pairs(elementos) do
        
        if el.tipo==1 then
            local nx,ny=93,96 --Tamanho da nave
            local _,ad = asteroide:getDimensions() -- Diametro da colisão do asteroide
            
            local dcol = math.sqrt( (asx-(el.x))^2 + (asy-(el.y))^2 )

            if dcol <= ad then
                elementos[key] = nil
            end
        end
        if el.tipo==2 then
            local bx,by=bomb:getDimensions() --Tamanho da nave
            local _,ad = asteroide:getDimensions() -- Diametro da colisão do asteroide
            
            local dcol = math.sqrt( (asx-(el.x))^2 + (asy-(el.y))^2 )

            if dcol <= ad then
                vida = vida-1
                if vida<=0 then
                  --love.load()
                end
                elementos[key] = nil
            end   
        end
    end
end


function love.keypressed(key)

    if key=='return' and estado=='menu' then
        estado='game' -- Inicia jogo
        starttime=os.time() -- Tempo de inicio do jogo
    end


    if estado=='game' then
        if mov=='' then
            if key=='a' or key=='left' then
                mov='esq'

            elseif key=='d' or key=='right' then
                mov='dir'
            end
        end
    end
end


function love.update(dt)
    rot = rot + dt*math.pi/5 -- Rotaciona o asteroide a cada update

    msgr.checkMessages()

    if estado=='game' then
        tempo_de_jogo()
        cria_trilha(dt)
        exec_mov(dt)
        posicao_elemento(dt)
        collision()
        
    end

end


function love.draw()
    if estado=='menu' then
        faz_backgroundmenu()
        desenha_titulo()
        desenha_menu()
    end



    if estado=='game' then
        faz_background()
        desenha_hp()
        desenha_trilha()    
        desenha_elementos()
        desenha_asteroide()
    end

end