msgr = require('mqttLoveLibrary')
high = require('highscore')


function love.load()
    meuusuario = '1810981' -- Sua matricula


    teste = false -- Modo de teste

    --Textos
    titulo = love.graphics.newFont('BLADRMF_.TTF',75)
    menuf = love.graphics.newFont('BLADRMF_.TTF',30)
    menuT = love.graphics.newText(titulo,'')
    menu = love.graphics.newText(menuf,'')
    pontuacaotxt = love.graphics.newText(menuf,'pontos:')
    pontuacao = love.graphics.newText(menuf,pont)
    --Tela
    love.window.setTitle('Projeto Final')
    love.window.setMode(800,1000)
    love.graphics.setBackgroundColor(0,0,0)
    w,h = love.graphics.getDimensions() -- Dimensões(global)
    -------------------------------//-------------------------------
    --Movimentação
    msgr.start(meuusuario,'asteroide',coord_mov) -- Ao receber mensagem executa a função coord_mov
    vmov= 5 -- Velocidade da movimentação
    nfaixas = 3 -- Número de faixas na movimentação
    mov = 0 --Estado inicial da movimentação
    dist = 0 -- Variavel auxiliar "distância", para a movimentação
    nfaixas = nfaixas+1 -- Ajusta para o número real de faixas
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
    nbomba = 0 -- Quantidade de bombas seguidas
    -------------------------------//-------------------------------
    --Defaults
    estado = 'menu' --Jogo começa no menu
    starttime = 0 --Inicializa a variavel inicio do jogo
    delta = 0 -- Espaço entre updates
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

        if el.t>=0.1 then -- Incrementa sprite com 0.1s de delay
            el.t = 0
            el.s = el.s+1
        end

        if el.s>8 then -- Deleta explosão após a ultima sprite

            exp[key] = nil

        end
    end
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
        if teste==true then
            meuusuario = 'robo'
        end
        highscore.append(meuusuario,pont) -- Adiciona e ordena seu nome às scores
        highscore.order()

        love.load()
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
    menu:set('jogar = "enter"')
    mx,my = menu:getDimensions()

    love.graphics.setColor(255,255,0)
    love.graphics.draw(menu,w/2-mx/2,h/2-my*2)

    menu:set('records = "r"')
    mx,my = menu:getDimensions()

    love.graphics.draw(menu,w/2-mx/2,h/2+my*5)
end


function desenha_asteroide()
    local ax,ay = asteroide:getDimensions()


    love.graphics.setColor(255,255,255)
    love.graphics.draw(asteroide,asx,4/5*h,rot,1,1,ax/2,ay/2)

end


function cria_trilha(dt) -- Trilha do asteroide
    local ax,ay = asteroide:getDimensions()


    local fila = {} -- Filas possíveis

    for i=1,6 do
        fila[i] = ay*(i)/6
    end

    for i=1,ntri do
        if trilha[i].y>=h+20 then -- Reseta a trilha ao sair da tela

            esc = math.floor(math.random(2,12)/2) -- Escolhe um numero que será a fila
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


function coord_mov(msg) -- Coordena a movimentação
    estado='game'


    local _,_,inst=string.find(msg,'(%w+)')
    print(inst)
    print('mensagem recebida')

    if inst=='esq' then
        mov = -1
    end

    if inst=='dir' then
        mov = 1
    end
end


function exec_mov(dt) -- Executa movimento

    if math.abs(asx - (nfaixas-1)*w/nfaixas) <= 30 and mov==1 then -- Impede que saia da tela pela direita
        mov = 0
        dist = 0
    end

    if math.abs(asx-w/nfaixas) <= 30 and mov==-1 then -- Impede que saia da tela pela esquerda
        mov = 0
        dist = 0
    end


    dist = dist + (1/nfaixas*w)*dt*vmov*math.abs(mov) -- Essa fórmula garante velocidade fixa independente da velocidade do computador

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

        if el.y>h then -- Deleta os elementos que saem da tela
            elementos[key]=nil
        end

        if el.y > asy - el.dy then -- Conserva recursos só chamando a colisão quando o objeto esta proximo
            collision(el,key)
        end
    end
    eltimer = eltimer+dt
    local dtempo = eltimer - ultimoel -- Tempo deste o ultimo elemento (s)

    local dificuldade = fator/(eltimer+fator/3); -- Equação que determina a dificuldade de acordo com o tempo

    if ultimoel==-1 or dtempo>dificuldade then -- Mais elementos conforme o tempo passa
        local tipoel = math.floor(math.random(1,6))

        if nbomba>=2 then
            tipoel=2
        end

        if tipoel>1 then
            dx,dy=93,96
            tipoel = 1
            nbomba = 0
        else

            dx,dy = bomb:getDimensions()
            tipoel = 2
            nbomba = nbomba + 1
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


    local dcol = math.sqrt( (asx-(el.x))^2 + (asy-(el.y))^2 )
    if dcol <= ad-20 then
        elementos[key] = nil

        expx,expy,extipo = el.x,el.y,el.tipo
    end


end


function desenha_hghscore()

    love.graphics.setColor(255,255,0)

    local user = highscore.user()

    menu:set(user)
    local dx,dy = menu:getDimensions() -- dx = 150, dy = 340

    love.graphics.draw(menu,w/2-200,300)

    local score = highscore.score()

    menu:set(score)

    love.graphics.draw(menu,w/2+100,300)
end


function desenha_tituloHS()

    menuT:set('top scores')
    tx,ty = menuT:getDimensions()

    love.graphics.setColor(255,255,0)
    love.graphics.draw(menuT,w/2-tx/2,100)
end


function aviso_menu()

    menu:set('para retornar ao menu aperte "enter"')
    tx,ty = menu:getDimensions()

    love.graphics.setColor(255,255,0)
    love.graphics.draw(menu,w/2-tx/2,h-ty*2)
end


function exibe_pontuacao()
    pontuacao:set(pont)

    ptx,pty = pontuacaotxt:getDimensions()
    px,py = pontuacao:getDimensions()

    love.graphics.setColor(255,255,0)
    love.graphics.draw(pontuacaotxt,w-ptx-110,h-pty-30)
    love.graphics.draw(pontuacao,w-px-10,h-py-30)
end


function robo()
    local _,ad = asteroide:getDimensions()

    local bombas = {}
    local perigo = false

    for _,el in pairs(elementos) do
        if el.tipo==2 and el.y<asy + ad/2 then
            bombas[#bombas+1] = el
        end
    end

    if #bombas>0 then
        table.sort(bombas,function(a,b) return a.y>b.y end) 
        for i=1,#bombas do
            local deltax = math.abs(bombas[i].x - asx)

            local deltay = asy - bombas[i].y

            if deltay<3/4*h then
                perigo=true
            end

            if deltax <= 10 and deltay <= ad+10+velocidade then


                if asx-(1/nfaixas)*w<=10 then
                    mov = 1

                elseif asx+(1/nfaixas)*w>=w  then
                    mov = -1

                else

                    local decisao=false
                    for a=1,#bombas do
                        if bombas[a].x>w/2 then
                            mov = -1

                            decisao=true
                            break

                        elseif bombas[a].x<w/2 then
                            mov = 1
                            print('direita')

                            decisao=true
                            break
                        end
                    end
                    if decisao==false then 

                        mov = -1
                    end
                end
            end


        end
    end

    if perigo==false then
        centraliza()
    end
end


function centraliza()
    if asx+(1/nfaixas)*w>=w then
        mov = -1
    elseif asx - (1/nfaixas)*w <= 0 then
        mov = 1
    end
end


function love.keypressed(key)

    if estado=='menu' then

        if key=='return' then
            estado='game' -- Inicia jogo
            starttime=os.time() -- Tempo de inicio do jogo
        end

        if key=='r' then
            estado='end'
        end
    end


    if estado=='game' then

        if key=='a' or key=='left' then
            mov=-1

        elseif key=='d' or key=='right' then
            mov=1
        end
    end

    if estado=='end' then
        if key == 'return' then
            love.load()
        end
    end
end


function love.update(dt)

    delta = dt
    msgr.checkMessages()

    if estado=='game' then
        rot = rot + dt*math.pi/5 -- Rotaciona o asteroide a cada update
        cria_trilha(dt)
        exec_mov(dt)
        posicao_elemento(dt)

        if teste==true and #elementos>0 then
            robo(el)
        end

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
        faz_explosao()
        desenha_trilha()    
        desenha_elementos()
        desenha_asteroide()
        exibe_pontuacao()
        desenha_hp()
    end

    if estado=='end' then
        faz_background()
        desenha_tituloHS()
        desenha_hghscore()
        aviso_menu()
    end

end