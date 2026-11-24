Tiro = Classe:extend()

function Tiro:new(origem, direcao, velocidade, alcance, raio, dano, eh_pedra)
    self.posicao = origem
    self.passo = direcao * velocidade
    self.velocidade = velocidade
    self.restante = alcance
    self.raio = raio
    self.dano = dano
    if eh_pedra then
        self.img = Recursos.imagem('materials/misc/pedra.png')
        Recursos.tocar('materials/audio/whoosh-6316.mp3', 0.5)
    else
        Recursos.tocar('materials/audio/shotgun-firing-3-14483.mp3', 0.05)
    end
end

function Tiro:update(dt)
    local distancia = math.min(self.restante, self.velocidade * dt)
    local origem = self.posicao
    local destino = origem + self.passo * (distancia / self.velocidade)
    self.posicao = destino
    self.restante = self.restante - distancia
    return origem, destino
end

function Tiro:draw()
    if self.img then
        love.graphics.draw(self.img, self.posicao.x, self.posicao.y, 0, 1, 1,
            self.img:getWidth() / 2, self.img:getHeight() / 2)
    else
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle('fill', self.posicao.x, self.posicao.y, self.raio)
        love.graphics.setColor(1, 1, 1)
    end
end
