LARGURA_TELA, ALTURA_TELA = love.graphics.getDimensions()

function love.load()
    Classe = require 'classes/classic'
    Vector = require 'classes/vector'
    camera = require 'classes/camera'
    anim = require 'classes/anim8'
    wf = require 'classes.windfield'
    Recursos = require 'classes/recursos'

    require 'classes/hud/background'
    require 'classes/hud/startmenu'
    require 'classes/hud/ingamehud'
    require 'classes/hud/fimdejogo'
    require 'classes/hud/ajuda'
    require 'classes/hud/ajuda2'
    require 'classes/hud/ranking'
    require 'classes/hud/pause'
    require 'classes/objetos/tiro'
    require 'classes/objetos/caixa'
    require 'classes/personagens/personagem'
    require 'classes/personagens/inimigo'
    require 'classes/personagens/boss'
    require 'cenas/fase'
    require 'cenas/jogo'

    start_menu = Start()
    game_over = GameOver()
    ajuda = Ajuda()
    ajuda2 = Ajuda2()
    ranking = Ranking()
    pause = Pause()
    jogo = Jogo()

    cenas = {
        menu_inicial = start_menu,
        jogo = jogo,
        game_over = game_over,
        ajuda1 = ajuda,
        ajuda2 = ajuda2,
        ranking = ranking
    }
    cena_atual = 'menu_inicial'
    tabela_ranking = require('classes/placar').carregar()
    mouse_delay = 0
end

function love.update(dt)
    mouse_delay = math.max(0, mouse_delay - dt)
    cenas[cena_atual]:update(dt)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    Recursos.usarFonte('materials/fonts/Melted-Monster.ttf', 40)
    cenas[cena_atual]:draw()
end

function love.keypressed(tecla, _, repeticao)
    if cena_atual ~= 'jogo' or repeticao then return end
    if tecla == 'escape' then
        jogo:alternarPausa()
    elseif tecla == 'space' and not jogo.pausado and jogo.fase.estado == 'introducao' then
        jogo.pular = true
    end
end
