return function()
    local passo = 1 / 120
    local Placar = require 'classes/placar'
    local Colisao = require 'classes/colisao'
    local teclas, atirando = {}, false

    love.keyboard.isDown = function(tecla) return teclas[tecla] or false end
    love.mouse.isDown = function(botao) return botao == 1 and atirando end
    love.mouse.getPosition = function() return 0, 0 end

    local function perto(a, b, erro)
        assert(math.abs(a - b) <= erro, string.format('Esperado %f ± %f, obtido %f', b, erro, a))
    end

    local function avancar(n)
        for _ = 1, n do love.update(passo) end
    end

    local function iniciar()
        teclas, atirando = {}, false
        jogo:iniciar()
        assert(jogo.fase.estado == 'introducao')
        love.draw()
        love.keypressed('space')
        avancar(1)
        assert(jogo.fase.estado == 'jogando' and jogo.tempo == 0)
    end

    local function mover_para(x, y)
        local heroi = jogo.fase.heroi
        heroi.collider:setPosition(x, y)
        heroi:sincronizar()
        heroi.posicao_anterior = heroi.posicao
    end

    local function posicao_apos(fps)
        iniciar()
        local antes = jogo.fase.heroi.posicao
        teclas.d, teclas.s = true, true
        local quadros = math.floor(fps * 0.25)
        for _ = 1, quadros do love.update(1 / fps) end
        love.update(0.25 - quadros / fps)
        perto(jogo.tempo, 0.25, 1e-8)
        return jogo.fase.heroi.posicao - antes
    end

    local diagonal = posicao_apos(60)
    perto(diagonal:getmag(), 230 * 0.25, 0.01)
    for _, fps in ipairs({30, 120}) do
        perto((diagonal - posicao_apos(fps)):getmag(), 0, 0.01)
    end
    iniciar()
    teclas.d, teclas.s = true, true
    local antes = jogo.fase.heroi.posicao
    love.update(0.15)
    perto((jogo.fase.heroi.posicao - antes):getmag(), 230 * 0.15, 0.01)
    print('OK: movimento a 30, 60 e 120 FPS e frame de 150 ms')

    iniciar()
    mover_para(480, 500)
    atirando = true
    avancar(1)
    assert(#jogo.fase.tiros == 1 and jogo.fase.tiros[1].passo.x > 0)
    perto(jogo.fase.tiros[1].posicao.x, 480 + 20 + 1000 * passo, 0.01)
    teclas.a = true
    avancar(60)
    assert(#jogo.fase.tiros <= 1)
    teclas.a = false
    avancar(1)
    local esquerda = jogo.fase.tiros[#jogo.fase.tiros]
    assert(esquerda and esquerda.passo.x < 0)
    perto(esquerda.posicao.x, jogo.fase.heroi.posicao.x - 20 - 1000 * passo, 0.02)
    love.draw()

    local fase = jogo.fase
    local caixa = fase.caixas[1]
    local alvo, impacto = fase:primeiroImpacto(Vector(200, 370), Vector(500, 370), 2, false)
    assert(alvo == caixa and impacto > 0 and impacto < 1)
    local _, parede = fase:primeiroImpacto(Vector(100, 200), Vector(60, 200), 2, false)
    assert(parede)
    local intersecao = Colisao.circulo(Vector(20, 0), Vector(170, 0), Vector(100, 0), 37)
    perto(intersecao, 43 / 150, 1e-8)
    assert(Colisao.circulo(Vector(20, 20), Vector(170, 20), Vector(100, 0), 5) == nil)
    local cruzou = Colisao.alvo(Vector(20, 0), Vector(170, 0), {
        posicao_anterior = Vector(100, -50), posicao = Vector(100, 50), raio = 3
    }, 2)
    assert(cruzou)

    local tiros = {Tiro(Vector(200, 370), Vector(1, 0), 1000, 600, 2, 30)}
    fase:atualizarProjeteis(tiros, 0.15, false)
    assert(#tiros == 0 and caixa.vida == 45)
    fase:atualizarProjeteis(tiros, 0.15, false)
    assert(caixa.vida == 45)
    for _ = 1, 2 do
        tiros[1] = Tiro(Vector(200, 370), Vector(1, 0), 1000, 600, 2, 30)
        fase:atualizarProjeteis(tiros, 0.15, false)
    end
    assert(caixa.vida == 0 and #fase.caixas == 2)
    local pedra = Tiro(Vector(2300, 530), Vector(1, 0), 350, 40, 40, 16, true)
    local pedras = {pedra}
    fase:atualizarProjeteis(pedras, 1, true)
    assert(#pedras == 0)
    perto(pedra.posicao.x, 2340, 1e-8)
    assert(fase:primeiroImpacto(Vector(2000, 350), Vector(2400, 350), 2, false) == nil)
    print('OK: tiro clássico, alvos móveis, obstáculo, impacto único e alcance')

    local function posicao_chefe(fps)
        iniciar()
        mover_para(1900, 480)
        avancar(1)
        assert(jogo.fase.arena)
        local chefe = jogo.fase.chefe
        for _ = 1, fps * 2 do love.update(1 / fps) end
        assert(chefe.posicao.y > 350)
        return chefe.posicao, #jogo.fase.pedras, jogo.tempo
    end

    local chefe_60, pedras_60, tempo_60 = posicao_chefe(60)
    for _, fps in ipairs({30, 120}) do
        local posicao, pedras, tempo = posicao_chefe(fps)
        perto((posicao - chefe_60):getmag(), 0, 0.001)
        assert(pedras == pedras_60)
        perto(tempo, tempo_60, 1e-8)
    end

    iniciar()
    mover_para(1615, 499)
    avancar(1)
    assert(not jogo.fase.arena)
    teclas.d = true
    avancar(4)
    assert(jogo.fase.arena)
    teclas.d = false
    teclas.a = true
    avancar(240)
    assert(jogo.fase.heroi.posicao.x >= 1619, jogo.fase.heroi.posicao.x)
    assert(jogo.fase.cam.x == 2000)
    local zumbi = jogo.fase.inimigos[1]
    zumbi.collider:setPosition(1580, 490)
    zumbi:sincronizar()
    zumbi:detectarHeroi()
    mover_para(1750, 490)
    teclas.a = false
    avancar(120)
    assert(zumbi.posicao.x > 1605, zumbi.posicao.x)
    print('OK: ataques independentes do FPS e entrada unilateral da arena')

    local tempo = jogo.tempo
    local vida = jogo.fase.heroi.vida
    local chefe = jogo.fase.chefe.posicao
    love.keypressed('escape')
    avancar(180)
    assert(jogo.tempo == tempo and jogo.fase.heroi.vida == vida and jogo.fase.chefe.posicao == chefe)
    love.draw()
    love.keypressed('escape')
    local heroi = jogo.fase.heroi
    heroi.vida, heroi.invulneravel = 100, 0
    assert(heroi:receberDano(99))
    assert(not heroi:receberDano(1))
    for _ = 1, 56 do heroi:update(passo, Vector()) end
    assert(heroi:receberDano(100))
    jogo.fase.estado = 'morrendo'
    avancar(24)
    local transicao = jogo.fase.tempo_transicao
    love.keypressed('escape')
    avancar(180)
    assert(jogo.fase.tempo_transicao == transicao and jogo.tempo == tempo)
    love.keypressed('escape')
    avancar(145)
    assert(cena_atual == 'game_over' and jogo.resultado == 'derrota')
    assert(#tabela_ranking == 0)
    love.draw()
    print('OK: pausa durante combate e morte, invulnerabilidade e derrota')

    iniciar()
    mover_para(1850, 477)
    avancar(1)
    fase = jogo.fase
    fase.heroi.vida = 1
    fase.chefe.vida = 30
    fase.pedras[1] = Tiro(fase.heroi.posicao:clone(), Vector(1, 0), 350, 1000, 40, 16, true)
    fase.tiros[1] = Tiro(fase.chefe.posicao:clone(), Vector(1, 0), 1000, 600, 2, 30)
    avancar(1)
    assert(fase.chefe.vida == 0 and fase.heroi.vida == 0 and fase.estado == 'morrendo')

    iniciar()
    for nivel, quantidade in ipairs({9, 13, 14}) do
        fase = jogo.fase
        assert(jogo.nivel == nivel and fase.heroi.vida == 100 and #fase.inimigos == quantidade)
        mover_para(1850, 477)
        avancar(1)
        assert(fase.arena)
        fase.heroi.vida = 1
        fase.chefe.vida = 30
        fase.tiros[1] = Tiro(fase.chefe.posicao + Vector(-100, 0), Vector(1, 0), 1000, 600, 2, 30)
        avancar(125)
        if nivel < 3 then
            assert(jogo.fase.estado == 'introducao')
            love.keypressed('space')
            avancar(1)
        end
    end
    assert(cena_atual == 'game_over' and jogo.resultado == 'vitoria')
    assert(#tabela_ranking == 1)
    local registros = Placar.carregar()
    assert(#registros == 1 and registros[1].milissegundos == tabela_ranking[1].milissegundos)
    love.draw()
    jogo:voltar()
    for _, cena in ipairs({'menu_inicial', 'ajuda1', 'ajuda2', 'ranking'}) do
        cena_atual = cena
        love.draw()
    end
    for i = 11, 1, -1 do Placar.registrar(registros, i / 10) end
    assert(love.filesystem.append('ranking-v1.tsv', 'inválido\n-1\t40\n'))
    registros = Placar.carregar()
    assert(#registros == 10 and registros[10].milissegundos == 900)
    print('OK: três fases, recuperação de vida, telas e ranking persistente')
end
