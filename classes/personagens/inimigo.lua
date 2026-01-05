--[[
    Classe Inimigo - Zumbis inimigos do jogo
    Representa os inimigos comuns que perseguem o herói
    Possui IA básica de perseguição e ataque
]]--

Inimigo = Classe:extend()

--[[
    Construtor da classe Inimigo
    @param nome_inimigo: Nome do arquivo de sprite
    @param tipos_inimigos: Tabela com atributos do inimigo (vida, dano, velocidade, etc)
    @param posicao: Vetor com posição inicial
]]--
function Inimigo:new(nome_inimigo, tipos_inimigos, posicao)
    -- SPRITE E ANIMAÇÕES
    self.nome = 'zumbi'
    self.img = love.graphics.newImage("/materials/chars/" .. nome_inimigo .. ".png")
    self.largura_animacao = self.img:getWidth()
    self.altura_animacao = self.img:getHeight()
    self.largura = 100
    self.altura = 100

    -- EFEITOS SONOROS
    self.som_grunhido = love.audio.newSource("/materials/audio/zombie-growl-3-6863.mp3", "static")
    self.som_grunhido:setVolume(0.03)
    self.som_ataque = love.audio.newSource("/materials/audio/zombie-6851.mp3", "static")
    self.som_ataque:setVolume(0.03)

    local g_inimigos = anim.newGrid(self.largura, self.altura, self.largura_animacao, self.altura_animacao)
    self.anim_inimigos = anim.newAnimation(g_inimigos('1-4', tipos_inimigos.op), 0.15)
    self.anim_inimigos_parado = anim.newAnimation(g_inimigos('1-1', tipos_inimigos.op), 0.15)

    -- ATRIBUTOS DE COMBATE E MOVIMENTO
    self.posicao = posicao                      -- Posição atual no mapa
    self.velocidade = tipos_inimigos.vel        -- Velocidade atual
    self.dano = tipos_inimigos.dano             -- Dano causado ao herói
    self.vel_max = tipos_inimigos.vel_max       -- Velocidade máxima
    self.raio_deteccao = tipos_inimigos.raio    -- Distância de detecção do herói
    self.vida = tipos_inimigos.vida             -- Pontos de vida atuais
    self.temp_vida = tipos_inimigos.vida        -- Vida máxima (para barra de vida)
    self.barra_vida = 56                        -- Largura da barra de vida
    self.raio = 35                              -- Raio de colisão

    self.esta_atacando = false                  -- Flag de ataque em progresso

    -- SISTEMA DE MOVIMENTO (Steering Behavior)
    self.objetivo = Vector(0, 0)                -- Posição alvo
    self.vel_desejada = Vector(0, 0)            -- Vetor velocidade desejada
    self.aceleracao = Vector(1, 1)              -- Vetor aceleração
    self.direcao_max = 10                       -- Força máxima de direção
    self.direcao_des = Vector(0,0)              -- Direção desejada
    self.massa = 5                              -- Massa (para cálculo de força)

    -- ESTADOS E CONTROLES
    self.heroi_visivel = false                  -- Se o herói foi detectado
    self.estado = "parado"                      -- Estado atual (parado, olhando_dir, olhando_esq)

    self.delay_dano = 0                         -- Cooldown entre ataques
    self.colidindo = false                      -- Flag de colisão com herói

    -- Collider físico
    self.collider = world:newBSGRectangleCollider(self.posicao.x, self.posicao.y, self.largura-60, self.altura-80, 0)
    self.collider:setFixedRotation(true)
end

--[[
    Atualiza o estado e comportamento do inimigo
    Implementa IA de perseguição e ataque
    @param dt: Delta time
]]--
function Inimigo:update(dt)
    self.anim_inimigos:update(dt)
    self.anim_inimigos_parado:update(dt)

    -- Gerencia cooldown de dano
    if self.delay_dano >= 0.80 then
        self.delay_dano = 0
        self.colidindo = false
    end

    -- Incrementa timer de cooldown
    if self.colidindo then
        self.delay_dano = self.delay_dano + dt
    end

    self.objetivo = heroi.posicao

    -- SISTEMA DE ORIENTAÇÃO - Define direção que o inimigo está olhando
    if self.heroi_visivel and self.objetivo.x >= self.posicao.x then
        self.estado = "olhando_dir"
    elseif self.heroi_visivel and self.objetivo.x < self.posicao.x then
        self.estado = "olhando_esq"
    end

    -- SISTEMA DE DETECÇÃO - Herói detectado visualmente ou por som de tiro
    local viu_heroi = verifica_colisao(heroi.posicao, heroi.raio, self.posicao, self.raio_deteccao)
    local escutou_tiro = (heroi.atirando and verifica_colisao(heroi.posicao, heroi.raio_tiro, self.posicao, self.raio_deteccao))
    if (viu_heroi or escutou_tiro) and not self.esta_atacando then
        self.heroi_visivel = true
        self.som_grunhido:play()
    end

    local vx, vy = 0, 0
    -- Coloca o zumbi para seguir se tem heroi visivel
    if self.heroi_visivel then
        self.vel_desejada = self.objetivo - self.posicao
        self.direcao_des = self.objetivo - (self.posicao + self.velocidade)
        self.direcao_des = self.direcao_des:limit(self.direcao_max / self.massa)

        self.velocidade = self.velocidade + self.direcao_des
        self.velocidade = self.velocidade:limit(self.vel_max)

        vx = self.velocidade.x
        vy = self.velocidade.y
    end

    self.collider:setLinearVelocity(vx, vy)
end

function Inimigo:draw()
    if self.estado == 'parado' then
        self.anim_inimigos_parado:draw(self.img, self.posicao.x - self.largura/2, self.posicao.y - self.altura/2, 0, 1, 1)
    elseif self.estado == "olhando_esq" then
        self.anim_inimigos:draw(self.img, self.posicao.x + self.largura/2, self.posicao.y - self.altura/2, 0, -1, 1)
    else
        self.anim_inimigos:draw(self.img, self.posicao.x - self.largura/2, self.posicao.y - self.altura/2, 0, 1, 1)
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.posicao.x - 80 + self.largura/2, self.posicao.y - self.altura/2, 60, 10)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.posicao.x - 78 + self.largura/2, self.posicao.y - self.altura/2, self.barra_vida, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", self.posicao.x, self.posicao.y, self.raio_deteccao)
    love.graphics.circle("line", self.posicao.x, self.posicao.y, self.raio)
end
