highscore = {} -- Modulo highscore


function highscore.read() -- Retorna uma tabela contendo cada linha do txt
    local arq = io.open('highscore.txt')
    
    local tabela = {}
    while true do
        linha = arq:read()
        if not linha then
            break
        end
        _,_,n,s = string.find(linha,'(.-)%s(%d+)')
        
        
        tabela[#tabela+1] = {n,tonumber(s)}
    end
    arq:close()
    
    return tabela
end


function highscore.order() -- Ordena o txt e o sobrescreve com sua versão ordenada
    tabela = highscore.read()

    
    table.sort(tabela,function(a,b) return a[2]>b[2] end)
    

    local arq = io.open('highscore.txt','w')
    
    string = ''
    
    for i=1,#tabela do
        string = string .. tabela[i][1] .. ' ' .. tabela[i][2] .. '\n'
    end
    
    arq:write(string)
    
    arq:close()
end

function highscore.append(n,s) -- n = nome, s = score ; Adicina score no final do txt
    arq = io.open('highscore.txt','a')
    
    string = n .. ' ' .. s .. '\n'
    
    arq:write(string)
    arq:close()
end

function highscore.string() -- Retorna uma string contendo todas as linhas do txt
    tabela = highscore.read()
    max = 10
    
    if max<#tabela then
        max = #tabela
    end
    
    string = ''
    for i=1,max do
        string = string..string.format('%-15s %10d',tabela[i][1],tabela[i][2])..'\n'
    end
    
    return string
end
print(highscore.string())

return highscore