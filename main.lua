--[[
    Arquivo principal do jogo The Alckmin Deadi
    Responsável por inicializar o jogo, gerenciar o loop principal
    e controlar as transições entre diferentes cenas/estados do jogo
]]--

-- Obtém as dimensões da tela do jogo
LARGURA_TELA, ALTURA_TELA = love.graphics.getDimensions()

--[[
    Função love.load()
    Executada uma única vez ao iniciar o jogo
    Responsável por carregar todas as bibliotecas, classes e recursos necessários
]]--
function love.load()
    -- Carrega bibliotecas essenciais
    Classe = require "classes/classic"          -- Sistema de orientação a objetos
    Vector = require "classes/vector"           -- Vetores matemáticos para posição e movimento
    camera = require "classes/camera"           -- Sistema de câmera que segue o jogador
    anim = require "classes/anim8"              -- Sistema de animações de sprites
    wf = require "classes/windfield"            -- Biblioteca de física 2D

    -- Carrega classes de interface do usuário (HUD)
    require "classes/hud/background"            -- Fundo animado
    require "classes/hud/startmenu"             -- Menu inicial
    require "classes/hud/ingamehud"             -- Interface durante o jogo
    require "classes/hud/fimdejogo"             -- Tela de fim de jogo
    require "classes/hud/ajuda"                 -- Primeira tela de ajuda
    require "classes/hud/ajuda2"                -- Segunda tela de ajuda
    require "classes/hud/ranking"               -- Tela de ranking/placar
    require "classes/hud/pause"                 -- Menu de pausa

    -- Carrega classes de objetos do jogo
    require "classes/objetos/tiro"              -- Projéteis disparados pelo jogador
    require "classes/objetos/caixa"             -- Obstáculos e caixas

    -- Carrega classes de personagens
    require "classes/personagens/personagem"    -- Classe do herói/jogador
    require "classes/personagens/inimigo"       -- Classe dos inimigos comuns
    require "classes/personagens/boss"          -- Classe dos chefes de fase

    -- Carrega o gerenciador de cenas do jogo
    require "cenas/jogo"

    -- Inicializa as diferentes telas/estados do jogo
    start_menu = Start()                        -- Menu inicial
    game_over = GameOver()                      -- Tela de game over
    ajuda = Ajuda()                             -- Tela de ajuda 1
    ajuda2 = Ajuda2()                           -- Tela de ajuda 2
    ranking = Ranking()                         -- Tela de ranking
    pause = Pause()                             -- Menu de pausa

    -- Inicializa o jogo e define a cena inicial
    jogo = Jogo()
    cena_atual = "menu_inicial"                 -- Define menu inicial como primeira cena

    -- Sistema de ranking
    tabela_ranking = {}                         -- Armazena pontuações dos jogadores
    id_jogador = 1                              -- Contador de jogadores

    -- Controle de input do mouse
    mouse_delay = 0                             -- Delay para evitar cliques múltiplos

    -- Carrega a fonte customizada do jogo
    font = love.graphics.setNewFont("materials/fonts/Melted-Monster.ttf", 40)
end

--[[
    Função love.update(dt)
    Executada continuamente a cada frame
    @param dt: Delta time - tempo decorrido desde o último frame
]]--
function love.update(dt)
    mouse_delay = mouse_delay - dt

    -- Atualiza a cena atual baseada no estado do jogo
    if cena_atual == "menu_inicial" then
        start_menu:update(dt)
    elseif cena_atual == "jogo" then
        jogo:update(dt)
    elseif cena_atual == "game_over" then
        game_over:update(dt)
    elseif cena_atual == "ajuda1" then
        ajuda:update(dt)
    elseif cena_atual == "ajuda2" then
        ajuda2:update(dt)
    elseif cena_atual == "ranking" then
        ranking:update(dt)
    end
end

--[[
    Função love.draw()
    Executada continuamente para renderizar elementos na tela
]]--
function love.draw()
    -- Renderiza a cena atual
    if cena_atual == "menu_inicial" then
        start_menu:draw()
    elseif cena_atual == "jogo" then
        jogo:draw()
    elseif cena_atual == "game_over" then
        game_over:draw()
    elseif cena_atual == "ajuda1" then
        ajuda:draw()
    elseif cena_atual == "ajuda2" then
        ajuda2:draw()
    elseif cena_atual == "ranking" then
        ranking:draw()
    end

    -- Descomente para debug: mostra FPS na tela
    --love.graphics.print("FPS: ".. love.timer.getFPS(), 10, 10)
end
