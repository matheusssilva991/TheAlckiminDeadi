Personagem = Classe:extend()

function Personagem:new(mundo, x, y)
    self.img = Recursos.imagem('materials/chars/personagem.png')
    local grade = anim.newGrid(100, 100, self.img:getWidth(), self.img:getHeight())
    self.animacoes = {
        andando = anim.newAnimation(grade('1-8', 3, '1-6', 4), 0.1),
        parado = anim.newAnimation(grade(7, 4), 0.1),
        morrendo = anim.newAnimation(grade('7-8', 4, '1-8', 5), 0.1, 'pauseAtEnd'),
        atirando = anim.newAnimation(grade('1-5', 2), 0.1, 'pauseAtEnd')
    }
    self.estado = 'parado'
    self.direcao = 1
    self.vida = 100
    self.velocidade = 230
    self.raio = 20
    self.raio_tiro = 450
    self.dano = 30
    self.delay_tiro = 0
    self.invulneravel = 0
    self.tempo_recuo = 0
    self.collider = mundo:newBSGRectangleCollider(x - 20, y - 10, 40, 20, 6,
        {collision_class = 'Heroi'})
    self.collider:setFixedRotation(true)
    self.collider:setBullet(true)
    self:sincronizar()
end

function Personagem:sincronizar()
    local x, y = self.collider:getPosition()
    self.posicao_anterior = self.posicao
    self.posicao = Vector(x, y - 100 / 3)
    self.chao = y
end

function Personagem:update(dt, entrada)
    self.delay_tiro = math.max(0, self.delay_tiro - dt)
    self.invulneravel = math.max(0, self.invulneravel - dt)

    local vx, vy = 0, 0
    local estado = 'parado'
    if self.tempo_recuo > 0 then
        self.tempo_recuo = math.max(0, self.tempo_recuo - dt)
        vx, vy = self.recuo.x, self.recuo.y
        estado = 'andando'
    elseif entrada.x ~= 0 or entrada.y ~= 0 then
        vx, vy = entrada.x * self.velocidade, entrada.y * self.velocidade
        if vx ~= 0 then self.direcao = vx > 0 and 1 or -1 end
        estado = 'andando'
    elseif self.delay_tiro > 0 then
        estado = 'atirando'
    end
    self.collider:setLinearVelocity(vx, vy)
    self.estado = estado

    if estado == 'parado' and entrada.atirando then
        self.delay_tiro = 0.45
        self.estado = 'atirando'
        self.animacoes.atirando:gotoFrame(1)
        self.animacoes.atirando:resume()
        local origem = self.posicao + Vector(20 * self.direcao, -18)
        return Tiro(origem, Vector(self.direcao, 0), 1000, 600, 2, self.dano)
    end
    self.animacoes[self.estado]:update(dt)
end

function Personagem:receberDano(dano, origem_recuo)
    if self.invulneravel > 0 or self.vida <= 0 then return false end
    self.vida = math.max(0, self.vida - dano)
    self.invulneravel = 0.45
    if self.vida == 0 then
        self.collider:setLinearVelocity(0, 0)
        self.estado = 'morrendo'
    elseif origem_recuo then
        local direcao = self.posicao - origem_recuo
        if direcao:magSq() == 0 then direcao = Vector(-self.direcao, 0) end
        self.recuo = direcao:norm() * 280
        self.tempo_recuo = 0.30
    end
    return true
end

function Personagem:draw()
    local x = self.posicao.x - 50 * self.direcao
    if self.vida > 0 and self.invulneravel > 0 and math.floor(self.invulneravel * 16) % 2 == 1 then
        love.graphics.setColor(1, 1, 1, 0.55)
    end
    self.animacoes[self.estado]:draw(self.img, x, self.posicao.y - 50, 0, self.direcao, 1)
    love.graphics.setColor(1, 1, 1)
end
