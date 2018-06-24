msgr = require('mqttLoveLibrary')


function love.load()
    minhamat = '1810981' -- Sua matricula


    --Textos
    menuf = love.graphics.newFont('arial.ttf',30)
    menu = love.graphics.newText(menuf,'')
    --Tela
    love.window.setTitle('Projeto Final')
    love.window.setMode(800,1000)
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
    bomb = love.graphics.newImage('bomb.png')
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
    starttime = 0 --Inicializa a variavel inicio do jogo
    runtime = 0 -- Tempo desde o inicio do jogo
    rot = 0 -- Rotação original
    asx = w*(math.floor(nfaixas/2))/(nfaixas) -- X inicial do asteroide
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


function desenha_menu()
    menu:set('Aperte "ENTER" ou use o Node para jogar')
    mx,my = menu:getDimensions()

    love.graphics.setColor(255,255,0)
    love.graphics.draw(menu,w/2-mx/2,h/2-my/2)
end


function desenha_asteroide()
    local ax,ay = asteroide:getDimensions()


    love.graphics.setColor(255,255,255)
    love.graphics.draw(asteroide,asx,4/5*h,rot,1,1,ax/2,ay/2)


    love.graphics.circle('line',asx,4/5*h,ay/2)
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

    for _,el in pairs(elementos) do -- Acessa os elementos existentes
        el.y = el.y + k*dt + eltimer/10 --Move os elementos existentes

        if el.y>h+10 then -- Deleta os elementos que saem da tela
            el=nil
        end
    end

    eltimer = eltimer+dt
    local dtempo = eltimer - ultimoel -- Tempo deste o ultimo elemento (s)

    local dificuldade = 5 - (eltimer/30)

    if dificuldade<0.1 then
        dificuldade=0.1
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
            nx,ny=nave:getDimensions()
            love.graphics.draw(nave,el.x-bx/2,el.y-by/2)
        end
            
        if el.tipo==2 then -- Tipo 2=bomba
            bx,by=bomb:getDimensions()
            love.graphics.draw(bomb,el.x-bx/2,el.y-by/2)
        end
    end

end


function love.keypressed(key)
    --print('pressionou '..key)

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
    end

end


function love.draw()
    faz_background()
    if estado=='menu' then
        desenha_menu()
    end

<<<<<<< HEAD

    if estado=='game' then

        desenha_trilha()    
        desenha_elementos()
        desenha_asteroide()
    end

end
=======
>>>>>>> dev
