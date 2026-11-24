Boss = Classe:extend()

local ESQUERDA, DIREITA = 1675, 2325
local MIN_Y, MAX_Y = 300, 450

function Boss:new(tipo)
    self.img = Recursos.imagem('materials/chars/inimigos.png')
    local grade = anim.newGrid(100, 100, self.img:getWidth(), self.img:getHeight())
    self.andando = anim.newAnimation(grade('1-4', 2), 0.15)
    self.parado = anim.newAnimation(grade(1, 2), 0.15)
    self.posicao = Vector(DIREITA, 350)
    self.chao = self.posicao.y + 56
    self.raio = 70
    self.vida = tipo.vida
    self.vida_max = tipo.vida
    self.dano = tipo.dano
    self.vel = tipo.vel
    self.vel_tiro = tipo.vel_tiro
    self.intervalo_tiro = tipo.intervalo_tiro
    self.aviso = tipo.aviso
    self.estado = 'normal'
    self.lado_avanco = -1
    self.direcao = -1
    self.ciclo = 2.25
    self.tempo_ate_avanco = 12
    self.tempo_ate_tiro = 0
end

function Boss:update(dt, heroi)
    self.posicao_anterior = self.posicao
    self.andando:update(dt)
    if self.estado == 'avanco' then
        local restante = self.destino - self.posicao
        local passo = self.vel * dt
        if restante:magSq() <= passo * passo then
            self.posicao = self.destino
            self.estado = 'normal'
            self.lado_avanco = -self.lado_avanco
            self.tempo_ate_avanco = 12
            self.ciclo = 0
        else
            self.posicao = self.posicao + restante:norm() * passo
        end
    elseif self.estado == 'aviso' then
        self.tempo_aviso = self.tempo_aviso - dt
        if self.tempo_aviso <= 0 then self.estado = 'avanco' end
    else
        self.direcao = heroi.posicao.x >= self.posicao.x and 1 or -1
        self.ciclo = (self.ciclo + dt) % 5
        self.tempo_ate_avanco = self.tempo_ate_avanco - dt
        self.tempo_ate_tiro = math.max(0, self.tempo_ate_tiro - dt)

        if self.tempo_ate_avanco <= 0 then
            self.estado = 'aviso'
            self.tempo_aviso = self.aviso
            self.direcao = self.lado_avanco
            self.origem_avanco = self.posicao
            self.destino = Vector(self.lado_avanco < 0 and ESQUERDA or DIREITA,
                math.max(MIN_Y, math.min(MAX_Y, heroi.posicao.y)))
        elseif self.ciclo >= 3 and self.tempo_ate_avanco > 2 then
            local alvo_y = math.max(MIN_Y, math.min(MAX_Y, heroi.posicao.y))
            local dy = math.max(-48 * dt, math.min(48 * dt, alvo_y - self.posicao.y))
            self.posicao = self.posicao + Vector(0, dy)
            self.chao = self.posicao.y + 56
            if self.tempo_ate_tiro == 0 then
                self.tempo_ate_tiro = self.intervalo_tiro
                local direcao = heroi.posicao - self.posicao
                if direcao:magSq() == 0 then direcao = Vector(self.direcao, 0) end
                return Tiro(self.posicao, direcao:norm(), self.vel_tiro, 1000, 40, self.dano, true)
            end
        end
    end
    self.chao = self.posicao.y + 56
end

function Boss:receberDano(dano)
    self.vida = math.max(0, self.vida - dano)
end

function Boss:draw()
    local quadro = self.estado == 'aviso' and self.parado or self.andando
    quadro:draw(self.img, self.posicao.x - 75 * self.direcao, self.posicao.y - 75,
        0, 1.5 * self.direcao, 1.5)
end

function Boss:drawAviso()
    if self.estado == 'aviso' or self.estado == 'avanco' then
        love.graphics.setColor(1, 0, 0, 0.25)
        love.graphics.setLineWidth(2 * self.raio)
        love.graphics.line(self.origem_avanco.x, self.origem_avanco.y, self.destino.x, self.destino.y)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1)
    end
end
