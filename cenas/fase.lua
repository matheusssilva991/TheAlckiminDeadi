local Colisao = require 'classes/colisao'

Fase = Classe:extend()

local ARENA_X = 1600
local MAPA_LARGURA = 2400
local CHAO_MIN, CHAO_MAX = 230, 520

function Fase:new(config)
    self.config = config
    self.mundo = wf.newWorld(0, 0)
    self.mundo:addCollisionClass('Heroi')
    self.mundo:addCollisionClass('LimiteArena', {ignores = {'Default'}})
    self.cam = camera(LARGURA_TELA / 2, ALTURA_TELA / 2)
    self.bg = Background(config.mapa)
    self.hud = InGameHud()
    self.estado = 'introducao'
    self.tempo_intro = 30
    self.tempo_transicao = 0
    self.alpha_entrada = 1

    -- Os limites do piso bloqueiam os pés. Os projéteis usam os limites da imagem.
    self.paredes = {
        {-10, 0, 10, 600}, {MAPA_LARGURA, 0, 10, 600},
        {0, -10, MAPA_LARGURA, 10}, {0, 600, MAPA_LARGURA, 10}
    }
    local paredes = {
        {-10, 0, 10, 600}, {MAPA_LARGURA, 0, 10, 600},
        {0, 0, MAPA_LARGURA, CHAO_MIN}, {0, CHAO_MAX, MAPA_LARGURA, 80}
    }
    for _, parede in ipairs(config.obstaculos or {}) do
        paredes[#paredes + 1] = parede
        self.paredes[#self.paredes + 1] = parede
    end
    for _, parede in ipairs(paredes) do
        self.mundo:newRectangleCollider(parede[1], parede[2], parede[3], parede[4], {body_type = 'static'})
    end

    self.heroi = Personagem(self.mundo, unpack(config.heroi))
    self.inimigos = {}
    for _, spawn in ipairs(config.inimigos) do
        local tipo, x, y = unpack(spawn)
        y = math.max(CHAO_MIN + 11, math.min(CHAO_MAX - 11, y))
        for _, parede in ipairs(config.obstaculos or {}) do
            if x + 20 > parede[1] and x - 20 < parede[1] + parede[3] then
                y = math.max(y, parede[2] + parede[4] + 11)
            end
        end
        self.inimigos[#self.inimigos + 1] = Inimigo(self.mundo, config.tipos[tipo], x, y)
    end

    self.chefe = Boss(config.chefe)
    self.arena = false
    self.caixas = {Caixa(self.mundo, 220, 330), Caixa(self.mundo, 275, 330), Caixa(self.mundo, 420, 330)}
    self.tiros, self.pedras = {}, {}
end

function Fase:abrirArena()
    self.arena = true
    self.mundo:newRectangleCollider(ARENA_X - 10, CHAO_MIN, 10, CHAO_MAX - CHAO_MIN,
        {body_type = 'static', collision_class = 'LimiteArena'})
end

function Fase:updateCamera(dt)
    if self.arena then
        self.cam.x = math.min(2000, self.cam.x + 350 * dt)
    else
        self.cam.x = math.max(LARGURA_TELA / 2, self.heroi.posicao.x + 200)
    end
end

function Fase:simular(dt, entrada)
    local heroi = self.heroi
    local disparo = heroi:update(dt, entrada)
    if disparo then self.tiros[#self.tiros + 1] = disparo end
    for _, inimigo in ipairs(self.inimigos) do
        inimigo:update(dt, heroi, disparo ~= nil)
    end
    self.mundo:update(dt)
    heroi:sincronizar()
    for _, inimigo in ipairs(self.inimigos) do
        inimigo:sincronizar()
    end

    if not self.arena and heroi.posicao.x >= ARENA_X + 20 then
        self:abrirArena()
    end
    if self.arena then
        local chefe = self.chefe
        local pedra = chefe:update(dt, heroi)
        if pedra then self.pedras[#self.pedras + 1] = pedra end
        local origem = (heroi.posicao_anterior or heroi.posicao) + (chefe.posicao - chefe.posicao_anterior)
        if Colisao.circulo(origem, heroi.posicao, chefe.posicao, chefe.raio + heroi.raio) then
            heroi:receberDano(chefe.dano, chefe.posicao)
        end
    end

    for _, inimigo in ipairs(self.inimigos) do
        inimigo:tentarAtacar(heroi)
    end
    self:atualizarProjeteis(self.pedras, dt, true)
    self:atualizarProjeteis(self.tiros, dt, false)
    self:updateCamera(dt)
    self.alpha_entrada = math.max(0, self.alpha_entrada - dt * 0.3)
end

function Fase:atualizarProjeteis(projeteis, dt, hostil)
    for i = #projeteis, 1, -1 do
        local tiro = projeteis[i]
        local origem, destino = tiro:update(dt)
        local alvo, distancia = self:primeiroImpacto(origem, destino, tiro.raio, hostil)
        if alvo then alvo:receberDano(tiro.dano) end
        if distancia or tiro.restante <= 0 then
            table.remove(projeteis, i)
        end
    end
    if not hostil then
        for _, lista in ipairs({self.caixas, self.inimigos}) do
            for i = #lista, 1, -1 do
                if lista[i].vida <= 0 then
                    lista[i].collider:destroy()
                    table.remove(lista, i)
                end
            end
        end
    end
end

function Fase:primeiroImpacto(origem, destino, raio, hostil)
    local alvo, menor
    local function testar(t, candidato)
        if t and (not menor or t < menor) then
            menor, alvo = t, candidato
        end
    end
    for _, parede in ipairs(self.paredes) do
        testar(Colisao.retangulo(origem, destino, parede, raio))
    end
    for _, caixa in ipairs(self.caixas) do
        if caixa.vida > 0 then
            testar(Colisao.retangulo(origem, destino, caixa.area_tiro, raio), not hostil and caixa or nil)
        end
    end
    if hostil then
        testar(Colisao.alvo(origem, destino, self.heroi, raio), self.heroi)
    else
        for _, inimigo in ipairs(self.inimigos) do
            if inimigo.vida > 0 then
                testar(Colisao.alvo(origem, destino, inimigo, raio), inimigo)
            end
        end
        if self.arena and self.chefe.vida > 0 then
            testar(Colisao.alvo(origem, destino, self.chefe, raio), self.chefe)
        end
    end
    return alvo, menor
end

function Fase:update(dt, entrada)
    if self.estado == 'introducao' then
        self.tempo_intro = entrada.pular and 0 or math.max(0, self.tempo_intro - dt)
        if self.tempo_intro == 0 then self.estado = 'jogando' end
    elseif self.estado == 'jogando' then
        self:simular(dt, entrada)
        if self.heroi.vida <= 0 then
            self.estado = 'morrendo'
        elseif self.chefe.vida <= 0 then
            self.estado = 'vencendo'
        end
        return dt
    elseif self.estado == 'morrendo' then
        self.tempo_transicao = self.tempo_transicao + dt
        self.heroi.animacoes.morrendo:update(dt)
    elseif self.estado == 'vencendo' then
        self.tempo_transicao = self.tempo_transicao + dt
    end
    return 0
end

function Fase:draw()
    if self.estado == 'introducao' then
        self:drawIntroducao()
        return
    end

    self.cam:attach()
    self.bg:draw()
    if self.arena and self.chefe.vida > 0 then self.chefe:drawAviso() end
    local objetos = {self.heroi}
    if self.chefe.vida > 0 then objetos[#objetos + 1] = self.chefe end
    for _, lista in ipairs({self.caixas, self.inimigos}) do
        for _, objeto in ipairs(lista) do
            objetos[#objetos + 1] = objeto
        end
    end
    -- Ordenação estável por profundidade. Objetos com o mesmo y mantêm a ordem de entrada.
    for i = 2, #objetos do
        local atual, j = objetos[i], i - 1
        while j >= 1 and objetos[j].chao > atual.chao do
            objetos[j + 1] = objetos[j]
            j = j - 1
        end
        objetos[j + 1] = atual
    end
    for _, objeto in ipairs(objetos) do objeto:draw() end
    for _, tiro in ipairs(self.tiros) do tiro:draw() end
    if self.chefe.vida > 0 then
        for _, pedra in ipairs(self.pedras) do pedra:draw() end
    end
    self.cam:detach()
    self.hud:draw(self.heroi, self.arena and self.chefe or nil)

    local alpha = self.estado == 'vencendo' and math.min(1, self.tempo_transicao) or self.alpha_entrada
    if alpha > 0 then
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle('fill', 0, 0, LARGURA_TELA, ALTURA_TELA)
        love.graphics.setColor(1, 1, 1)
    end
end

function Fase:drawIntroducao()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(1, 1, 1, math.min(1, self.tempo_intro))
    Recursos.usarFonte('materials/fonts/Melted-Monster.ttf', 40)
    love.graphics.printf(self.config.titulo, 0, 30, LARGURA_TELA, 'center')
    Recursos.usarFonte(30)
    love.graphics.printf(self.config.historia, 100, 100, 600, 'center')
    local pulso = 0.55 + math.sin((30 - self.tempo_intro) * math.rad(48)) * 0.2
    love.graphics.setColor(1, 1, 1, pulso)
    love.graphics.printf("Pressione ESPAÇO para pular", 100, 550, 600, 'center')
    love.graphics.setColor(1, 1, 1)
end

function Fase:destroy()
    self.mundo:destroy()
end
