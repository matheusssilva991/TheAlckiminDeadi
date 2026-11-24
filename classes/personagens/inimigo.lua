Inimigo = Classe:extend()

function Inimigo:new(mundo, tipo, x, y)
    self.img = Recursos.imagem('materials/chars/inimigos.png')
    local grade = anim.newGrid(100, 100, self.img:getWidth(), self.img:getHeight())
    self.andando = anim.newAnimation(grade('1-4', tipo.op), 0.15)
    self.parado = anim.newAnimation(grade(1, tipo.op), 0.15)
    self.dano = tipo.dano
    self.vel_max = tipo.vel_max
    self.raio_deteccao = tipo.raio
    self.vida = tipo.vida
    self.vida_max = tipo.vida
    self.raio = 35
    self.visivel = false
    self.direcao = 1
    self.velocidade = Vector()
    self.delay_dano = 0
    self.collider = mundo:newRectangleCollider(x - 20, y - 10, 40, 20)
    self.collider:setFixedRotation(true)
    self:sincronizar()
end

function Inimigo:sincronizar()
    local x, y = self.collider:getPosition()
    self.posicao_anterior = self.posicao
    self.posicao = Vector(x, y - 40)
    self.chao = y
end

function Inimigo:detectarHeroi()
    if not self.visivel then
        self.visivel = true
        Recursos.tocar('materials/audio/zombie-growl-3-6863.mp3', 0.03)
    end
end

function Inimigo:update(dt, heroi, disparou)
    self.delay_dano = math.max(0, self.delay_dano - dt)
    local deslocamento = heroi.posicao - self.posicao
    local alcance = self.raio_deteccao + (disparou and heroi.raio_tiro or heroi.raio)
    if deslocamento:magSq() <= alcance * alcance then
        self:detectarHeroi()
    end
    if self.visivel then
        if deslocamento.x ~= 0 then self.direcao = deslocamento.x > 0 and 1 or -1 end
        local desejada = deslocamento:norm() * self.vel_max
        self.velocidade = self.velocidade + (desejada - self.velocidade):limit(120 * dt)
        self.andando:update(dt)
    end
    self.collider:setLinearVelocity(self.velocidade.x, self.velocidade.y)
end

function Inimigo:tentarAtacar(heroi)
    local raio_contato = self.raio + heroi.raio
    if self.delay_dano == 0 and (self.posicao - heroi.posicao):magSq() <= raio_contato * raio_contato
        and heroi:receberDano(self.dano) then
        self.delay_dano = 0.80
        Recursos.tocar('materials/audio/zombie-6851.mp3', 0.03)
    end
end

function Inimigo:receberDano(dano)
    self.vida = math.max(0, self.vida - dano)
    if self.vida > 0 then self:detectarHeroi() end
end

function Inimigo:draw()
    local quadro = self.visivel and self.andando or self.parado
    quadro:draw(self.img, self.posicao.x - 50 * self.direcao, self.posicao.y - 50, 0, self.direcao, 1)

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', self.posicao.x - 30, self.posicao.y - 50, 60, 10)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', self.posicao.x - 28, self.posicao.y - 48, 56 * self.vida / self.vida_max, 6)
    love.graphics.setColor(1, 1, 1)
end
