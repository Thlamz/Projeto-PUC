msgr = require('mqttLoveLibrary')
high = require('highscore')


function love.load()
    minhamat = '1810981' -- Sua matricula


    --Textos
    titulo = love.graphics.newFont('BLADRMF_.TTF',60)
    menuf = love.graphics.newFont('BLADRMF_.TTF',30)
    menuT = love.graphics.newText(titulo,'')
    menu = love.graphics.newText(menuf,'')
    pontuacaotxt = love.graphics.newText(menuf,'pontos:')
    pontuacao = love.graphics.newText(menuf,pont)
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
    mov = 0 --Estado inicial da movimentação
    dist = 0 -- Variavel auxiliar "distância", para a movimentação
    nfaixas = nfaixas+1 --Não alterar(ajusta para o número real de faixas)
    -------------------------------//------------------------------
    --Sprites
    asteroide = love.graphics.newImage('asteroide.png')
    background = love.graphics.newImage("BKG.png")
    backgroundmenu = love.graphics.newImage("BKGM.png")
    bomb = love.graphics.newImage('bomb.png')
    ships = love.graphics.newImage("Ships.png")
    local nx,ny = ships:getDimensions()
    ship = love.graphics.newQuad(191,0,93,96,nx,ny)
    -------------------------------//-------------------------------
    --Explosão
    exp = {} -- Explosões atuais

    spexp  = {} -- Sprites da explosão
    spexp[1] = love.graphics.newImage('exp1.png')
    spexp[2] = love.graphics.newImage('exp2.png')
    spexp[3] = love.graphics.newImage('exp3.png')
    spexp[4] = love.graphics.newImage('exp4.png')
    spexp[5] = love.graphics.newImage('exp5.png')
    spexp[6] = love.graphics.newImage('exp6.png')
    spexp[7] = love.graphics.newImage('exp7.png')
    spexp[8] = love.graphics.newImage('exp8.png')

    expx = nil -- Coordenadas da chamada da explosão
    expy = nil
    extipo = nil


    -------------------------------//-------------------------------
    --HP
    hp = love.graphics.newImage("HP.png")
    vida = 4 -- Vida inicial
    hpmax = vida -- HP maximo obtido
    local vx,vy = hp:getDimensions()
    fullhp = love.graphics.newQuad(2,0,54,55,vx,vy)
    halfhp = love.graphics.newQuad(61,0,54,55,vx,vy)
    nohp = love.graphics.newQuad(119,0,54,55,vx,vy)
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
    velocidade = 0 -- Velocidade inicial dos elementos
    fator = 15 -- Quanto menor mais difícil
    -------------------------------//-------------------------------
    --Defaults
    estado = 'menu' --Jogo começa no menu
    starttime = 0 --Inicializa a variavel inicio do jogo
    delta = 0 -- Espaço entre updates
    runtime = 0 -- Tempo desde o inicio do jogo
    rot = 0 -- Rotação original
    asx = w*(math.floor(nfaixas/2))/(nfaixas) -- X inicial do asteroide
    asy = 4/5*h -- Y do asteroide
    k = 300 -- Constante de movimentação
    pont = '0' -- Pontuação inicial
    math.randomseed(os.time())
    -------------------------------//------------------------------
end

function faz_explosao()
    if expx and expy then
        local x,y,modo = expx,expy,extipo
        expx,expy,extipo = nil,nil,nil
        
        if modo==1 then
            pont = pont+20

        elseif modo==2 then
            vida = vida-1
        end

        if #exp==0 then
            exp[1] = {x=x,y=y,s=1,t=0}
        end

        for i=1,#exp+1 do
            if not exp[i] then
                exp[i] = {x=x,y=y,s=1,t=0}

            end
        end
    end

    for key,el in pairs(exp) do

        el.t = el.t+delta


        local dx,dy = spexp[el.s]:getDimensions()

        love.graphics.draw(spexp[el.s],el.x-dx/2,el.y-dy/2)

        if el.t>=0.1 then
            el.t = 0
            el.s = el.s+1
        end

        if el.s>8 then

            exp[key] = nil

        end
    end
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
    local hprest = vida
    local hpcoord = 30

    if vida>hpmax then
        hpmax = vida
    end

    for i=1,math.ceil(hpmax/2) do

        if hprest>=2 then
            love.graphics.draw(hp,fullhp,hpcoord,h-80)

            hprest = hprest-2
            hpcoord = hpcoord + 55

        elseif hprest==1 then
            love.graphics.draw(hp,halfhp,hpcoord,h-80)

            hprest = hprest-1
            hpcoord = hpcoord + 55


        else
            love.graphics.draw(hp,nohp,hpcoord,h-80) -- Desenha corações vazios para representar a vida anterior perdida

            hpcoord = hpcoord + 55
        end

    end

    if vida<=0 then
        estado = 'end'

        highscore.append(minhamat,pont) -- Adiciona e ordena seu nome às scores
        highscore.order()
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
            mov = -1
        end

        if inst=='dir' then
            mov = 1
        end
    end
end

function exec_mov(dt) -- Executa movimento

    if math.abs(asx - (nfaixas-1)*w/nfaixas) <= 30 and mov==1 then --Impede que saia da tela pela direita
        mov = 0
        dist = 0
    end

    if math.abs(asx-w/nfaixas) <= 30 and mov==-1 then --Impede que saia da tela pela esquerda
        mov = 0
        dist = 0
    end


    dist = dist + (1/nfaixas*w)*dt*vmov*math.abs(mov) -- Essa formula garante velocidade fixa independente da velocidade do computador

    asx = asx + (1/nfaixas*w)*dt*vmov*mov


    for i=1,nfaixas-1 do
        if (mov ~= 0) and (math.abs(asx - i*w/nfaixas) <= 30) and (dist>=30) then -- Para o movimento do asteroide quando ele chega a uma faixa
            asx = i*w/nfaixas
            dist = 0
            mov = 0
        end
    end
end


function posicao_elemento(dt)
    for key,el in pairs(elementos) do -- Acessa os elementos existentes
        velocidade = k*dt + eltimer/10
        el.y = el.y + velocidade --Move os elementos existentes

        if el.y>h+10 then -- Deleta os elementos que saem da tela
            elementos[key]=nil
        end

        if el.y > asy - el.dy then -- Conserva recurss so chamando a colisao quando o objeto esta proximo
            collision(el,key)
        end
    end

    eltimer = eltimer+dt
    local dtempo = eltimer - ultimoel -- Tempo deste o ultimo elemento (s)

    local dificuldade = fator/(eltimer+fator/3); -- Equação que determina a dificuldade de acordo com o tempo

    if ultimoel==-1 or dtempo>dificuldade then -- Mais elementos conforme o tempo passa
        local tipoel = math.floor(math.random(1,6))

        if tipoel>1 then
            dx,dy=93,96
            tipoel = 1
        else
            dx,dy = bomb:getDimensions()
            tipoel = 2
        end



        local faixa = math.floor(math.random(1,nfaixas-1))
        local objx = w*(faixa/nfaixas)
        local objy = 0



        for el=1,#elementos+1 do
            if not elementos[el] then -- Coloca o elemento no primeiro espaço vazio da tabela
                elementos[el] = {x=objx,y=objy,tipo=tipoel,dx=dx,dy=dy}
            end
        end

        ultimoel = eltimer
    end

end

function desenha_elementos()

    for _,el in pairs(elementos) do

        if el.tipo==1 then
            love.graphics.draw(ships,ship,el.x-(el.dx/2),el.y-(el.dy/2))
        end

        if el.tipo==2 then -- Tipo 2=bomba
            love.graphics.draw(bomb,el.x-el.dx/2,el.y-el.dy/2)
        end
    end

end

function collision(el,key)
    local _,ad = asteroide:getDimensions() -- Diametro da colisão do asteroide

    if el.tipo==1 then

        local _,ad = asteroide:getDimensions() -- Diametro da colisão do asteroide

        local dcol = math.sqrt( (asx-(el.x))^2 + (asy-(el.y))^2 )

        if dcol <= ad-20 then
            elementos[key] = nil

            expx,expy,extipo = el.x,el.y,el.tipo
        end
    end

    if el.tipo==2 then

        local _,ad = asteroide:getDimensions() -- Diametro da colisão do asteroide

        local dcol = math.sqrt( (asx-(el.x))^2 + (asy-(el.y))^2 )

        if dcol <= ad-30 then
            elementos[key] = nil

            expx,expy,extipo = el.x,el.y,el.tipo

        end  
    end
end


function desenha_hghscore()

    local scores = highscore.string()

    love.graphics.setColor(255,255,0)
    menu:set(scores)

    local dx,dy = menu:getDimensions()

    love.graphics.draw(menu,w/2,h/8)

end




function love.keypressed(key)

    if key=='return' and estado=='menu' then
        estado='game' -- Inicia jogo
        starttime=os.time() -- Tempo de inicio do jogo
    end


    if estado=='game' then

        if key=='a' or key=='left' then
            mov=-1

        elseif key=='d' or key=='right' then
            mov=1
        end
    end

    if estado=='end' then
        love.load()
    end
end


function love.update(dt)

    delta = dt
    msgr.checkMessages()

    if estado=='game' then
        rot = rot + dt*math.pi/5 -- Rotaciona o asteroide a cada update
        tempo_de_jogo()
        cria_trilha(dt)
        exec_mov(dt)
        posicao_elemento(dt)

    end

end

function exibe_pontuacao()

    pontuacaotxt = love.graphics.newText(menuf,'pontos:')
    pontuacao = love.graphics.newText(menuf,pont)

    ptx,pty = pontuacaotxt:getDimensions()
    px,py = pontuacao:getDimensions()

    love.graphics.setColor(255,255,0)
    love.graphics.draw(pontuacaotxt,w-ptx-110,h-pty-30)
    love.graphics.draw(pontuacao,w-px-10,h-py-30)
end

function love.draw()

    if estado=='menu' then
        faz_backgroundmenu()
        desenha_titulo()
        desenha_menu()
    end

    if estado=='game' then
        faz_background()
        faz_explosao()
        exibe_pontuacao()
        desenha_hp()
        desenha_trilha()    
        desenha_elementos()
        desenha_asteroide()
        faz_explosao()
    end

    if estado=='end' then
        faz_backgroundmenu()
        desenha_hghscore()
    end

end