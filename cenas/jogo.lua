--[[
    Classe Jogo - Gerenciador principal do jogo
    Responsável por gerenciar as fases, controlar o estado do jogo,
    e coordenar transições entre fases
]]--

Jogo = Classe:extend()

--[[
    Construtor da classe Jogo
    Inicializa as fases, variáveis de controle e áudio ambiente
]]--
function Jogo:new()
    -- Carrega as diferentes fases do jogo
    require "cenas/fase1"
    require "cenas/fase2"
    require "cenas/fase3"

    -- Controle de pausa do jogo
    estado_pause = "false"

    -- Controle de progressão das fases
    nivel_fase = 1                              -- Fase atual (1, 2 ou 3)
    trocou_fase = false                         -- Flag para controlar transição de fase
    tempo_jogo = 0                              -- Cronômetro do tempo total de jogo
    fase = Fase1()                              -- Inicia na primeira fase
    delay_morte = 0                             -- Tempo de animação de morte do personagem

    -- Carrega e reproduz música ambiente
    som_ambiente = love.audio.newSource("/materials/audio/terror-ambience-7003.mp3", "stream")
    som_ambiente:setVolume(0.02)                -- Volume baixo para ambiente
    som_ambiente:play()
end

--[[
    Atualiza o estado do jogo a cada frame
    @param dt: Delta time - tempo decorrido desde o último frame
]]--
function Jogo:update(dt)

    -- Se o jogo estiver pausado, apenas atualiza o menu de pausa
    if estado_pause == "true" then
        pause:update(dt)
    end

    -- Atualiza o jogo se não estiver pausado
    if estado_pause == "false" then
        -- Enquanto o personagem não está morrendo, jogo continua normalmente
        if delay_morte <= 0.6 then
            fase:update(dt)

            -- Conta o tempo quando o boss está presente e o timer da fase zerou
            if fase.tempo <= 0 and boss ~= nil then
                tempo_jogo = tempo_jogo + dt
            end

            -- Verifica se a fase foi concluída
            if fase.estado == 'finalizado' then
                if nivel_fase < 3 then
                    -- Avança para próxima fase
                    nivel_fase = nivel_fase + 1
                    trocou_fase = true
                elseif nivel_fase >= 3 then
                    -- Jogo concluído - adiciona ao ranking
                    table.insert(tabela_ranking, {
                        nome='Jogador ' .. id_jogador,
                        tempo_jogo=tonumber(string.format("%.2f", tempo_jogo))
                    })
                    id_jogador = id_jogador + 1
                    cena_atual = "game_over"
                end
            end

            -- Transição entre fases
            if nivel_fase == 2 and trocou_fase then
                trocou_fase = false
                fase = Fase2()
            elseif nivel_fase == 3 and trocou_fase then
                trocou_fase = false
                fase = Fase3()
            else
                fase.estado = 'nao finalizado'
            end
        -- Animação final de morte do personagem
        elseif delay_morte > 0.6 and delay_morte < 1.2 then
            if self.estado_anterior == 'morrendo_esq' then
                heroi.estado = 'morrendo_esq_final'
            elseif self.estado_anterior == 'morrendo_dir' then
                heroi.estado = 'morrendo_dir_final'
            end
        else
            -- Morte confirmada - fim de jogo
            cena_atual = "game_over"
            delay_morte = 0
        end
    end

    -- Inicia o delay de morte quando vida do herói chega a zero
    if heroi.vida <= 0 then
        delay_morte = delay_morte + dt
    end
end

--[[
    Renderiza os elementos do jogo na tela
]]--
function Jogo:draw()
    fase:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setColor(1, 1, 1)

    -- Exibe o cronômetro quando o tempo da fase acabou (durante a luta com o boss)
    if fase.tempo <= 0 then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("tempo: " .. tonumber(string.format("%.2f", tempo_jogo)), 20, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("tempo: " .. tonumber(string.format("%.2f", tempo_jogo)), 22, 12)
    end

    pause:draw()
end

--[[
    Callback para capturar teclas pressionadas
    @param key: Tecla pressionada
]]--
function love.keypressed(key)
    -- Tecla ESC alterna entre pausado e não pausado
    if key == "escape" and estado_pause == "false" then
        estado_pause = "true"
    elseif key == "escape" and estado_pause == "true" then
        estado_pause = "false"
    end
 end

--[[
    Verifica colisão circular entre dois objetos
    @param A: Primeiro objeto com posição
    @param raio_1: Raio de colisão do primeiro objeto
    @param B: Segundo objeto com posição
    @param raio_2: Raio de colisão do segundo objeto
    @return: true se houver colisão, false caso contrário
]]--
function verifica_colisao(A, raio_1, B, raio_2)
    if A.dist(A, B) <= raio_1 + raio_2 then
        return true
    end
    return false
end

--[[
    Troca posições de dois elementos na tabela se necessário
    Usado para ordenação de profundidade (renderização em layers)
    @param a: Índice do primeiro elemento
    @param b: Índice do segundo elemento
    @param table: Tabela contendo os elementos
    @return: true se houve troca, false caso contrário
]]--
function swap(a, b, table)
    if table[a] == nil or table[b] == nil then
        return false
    end

    -- Regras específicas de profundidade baseadas no tipo de objeto
    if table[a].nome == 'zumbi' and table[b].nome == 'caixa' then
        if table[a].posicao.y >= table[b].posicao.y then
            table[a], table[b] = table[b], table[a]
            return true
        end
    elseif table[a].nome == 'caixa' and table[b].nome == 'zumbi' then
        if table[a].posicao.y > table[b].posicao.y then
            table[a], table[b] = table[b], table[a]
            return true
        end
    elseif table[a].nome == 'heroi' and table[b].nome == 'caixa' then
        if table[a].posicao.y >= table[b].posicao.y then
            table[a], table[b] = table[b], table[a]
            return true
        end
    else
        -- Caso geral: ordena por posição Y
        if table[a].posicao.y > table[b].posicao.y then
            table[a], table[b] = table[b], table[a]
            return true
        end
    end

    return false
end

--[[
    Algoritmo Bubble Sort para ordenação de objetos por profundidade
    Ordena objetos na tela baseado em sua posição Y
    @param array: Array de objetos a ser ordenado
]]--
function bubblesort(array)
    for i=1,table.maxn(array) do
        local ci = i
        ::redo::
        if swap(ci, ci+1, array) then
            ci = ci - 1
            goto redo
        end
    end
end

--[[
    Ordena objetos pela posição X (horizontal)
    @param obj: Tabela de objetos a ser ordenada
]]--
function sort_posicao_x(obj)
    table.sort(obj, function(k1, k2) return k1.posicao.x < k2.posicao.x end)
end

--[[
    Ordena ranking de jogadores por tempo (menor tempo primeiro)
    @param obj: Tabela de ranking a ser ordenada
]]--
function sort_ranking(obj)
    table.sort(obj, function(k1, k2) return k1.tempo_jogo < k2.tempo_jogo end)
end
