--[[
    Classe Tiro - Projéteis do jogo
    Representa os tiros disparados pelo herói e pelo boss
    Gerencia trajetória, colisão e efeitos sonoros
]]--

Tiro = Classe:extend()

--[[
    Construtor da classe Tiro
    @param x: Posição inicial X
    @param y: Posição inicial Y
    @param direcao: Direção do tiro ('esquerda' ou 'direita')
    @param raio: Raio de colisão do projétil
    @param tipo_tiro: Tipo do atirador ('heroi' ou 'boss')
    @param dano: Quantidade de dano causado
    @param vel_tiro: Velocidade do projétil
]]--
function Tiro:new(x, y, direcao, raio, tipo_tiro, dano, vel_tiro)
    self.posicao_inicial = Vector(x + 20, y - 18)
    self.posicao = Vector(x + 20, y - 18)       -- Ajuste de -18 para alinhar com sprite
    self.posicao_boss = Vector(x, y)            -- Posição do boss (para tiros do boss)
    self.posicao_heroi = heroi.posicao          -- Posição do herói (para mira do boss)
    self.raio = raio                            -- Raio de colisão
    self.direcao = direcao                      -- Direção do movimento
    self.dano = dano                            -- Dano causado ao acertar
    self.tipo_tiro = tipo_tiro                  -- 'heroi' ou 'boss'
    self.vel_y_tiro = math.abs(heroi.posicao.y - y)  -- Velocidade vertical (para tiros do boss)
    self.vel_x_tiro = vel_tiro                  -- Velocidade horizontal
    self.distancia_tiro = 0                     -- Distância percorrida

    -- Sprite da pedra (tiros do boss)
    self.img_pedra = love.graphics.newImage("materials/misc/pedra.png")
    self.img_pedraLarg = self.img_pedra:getWidth()
    self.img_pedraAlt = self.img_pedra:getHeight()

    -- Sons de tiro
    self.som_tiro = love.audio.newSource("materials/audio/shotgun-firing-3-14483.mp3", "static")
    self.som_tiro:setVolume(0.05)

    self.som_pedra = love.audio.newSource("materials/audio/whoosh-6316.mp3", "static")
    self.som_pedra:setVolume(0.5)

    self.delay = 0.3                            -- Delay para evitar reprodução múltipla do som
end

--[[
    Atualiza a posição do projétil
    @param dt: Delta time
]]--
function Tiro:update(dt)
    self.delay = self.delay - dt

    -- TIROS DO HERÓI - Movimento horizontal simples
    if self.direcao == 'esquerda' and self.tipo_tiro == 'heroi' then
        self.posicao = self.posicao - Vector(self.vel_x_tiro, 0) * dt
        self.som_tiro:play()
    elseif self.direcao == 'direita' and self.tipo_tiro == 'heroi' then
        self.posicao = self.posicao + Vector(self.vel_x_tiro, 0) * dt
        self.som_tiro:play()

    -- TIROS DO BOSS - Movimento diagonal em direção ao herói
    elseif self.direcao == 'esquerda' and self.tipo_tiro == 'boss' then
        if self.posicao_heroi.y >= self.posicao_boss.y then -- Tiro baixo esquerda
            self.posicao = self.posicao - Vector(self.vel_x_tiro, -self.vel_y_tiro) * dt
        elseif self.posicao_heroi.y < self.posicao_boss.y then -- Tiro cima esquerda
            self.posicao = self.posicao - Vector(self.vel_x_tiro, self.vel_y_tiro) * dt
        end
        if self.delay > 0 then
            self.som_pedra:play()
        end
    elseif self.direcao == 'direita' and self.tipo_tiro == 'boss' then
        if self.posicao_heroi.y >= self.posicao_boss.y then -- Tiro baixo direita
            self.posicao = self.posicao + Vector(self.vel_x_tiro, self.vel_y_tiro) * dt
        elseif self.posicao_heroi.y < self.posicao_boss.y then -- Tiro cima direita
            self.posicao = self.posicao + Vector(self.vel_x_tiro, -self.vel_y_tiro) * dt
        end
        if self.delay > 0 then
            self.som_pedra:play()
        end
    end

    self.distancia_tiro = self.posicao.dist(self.posicao_inicial, self.posicao)
end

function Tiro:draw()
    if self.tipo_tiro == 'heroi' then
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", self.posicao.x, self.posicao.y, self.raio)
        love.graphics.setColor(1, 1, 1)
    elseif self.tipo_tiro == 'boss' then
        love.graphics.draw(self.img_pedra, self.posicao.x - (self.img_pedraLarg/2), self.posicao.y - (self.img_pedraAlt/2))
    end
end
