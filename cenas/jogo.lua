local Placar = require 'classes/placar'
local fases = {
    require('cenas/fase1'),
    require('cenas/fase2'),
    (require('cenas/fase3'))
}

Jogo = Classe:extend()

local PASSO = 1 / 120
local MAX_TEMPO_FRAME = 0.25

function Jogo:new()
    self.musica = love.audio.newSource('materials/audio/terror-ambience-7003.mp3', 'stream')
    self.musica:setVolume(0.02)
    self.musica:setLooping(true)
end

function Jogo:iniciar()
    self:encerrarFase()
    self.nivel = 1
    self.tempo = 0
    self.acumulado = 0
    self.pular = false
    self.pausado = false
    self.resultado = nil
    self.fase = Fase(fases[self.nivel])
    self.musica:play()
    cena_atual = 'jogo'
end

function Jogo:encerrarFase()
    if self.fase then self.fase:destroy() end
    self.fase = nil
end

function Jogo:voltar()
    self:encerrarFase()
    self.musica:stop()
    cena_atual = 'menu_inicial'
end

function Jogo:alternarPausa()
    self.pausado = not self.pausado
    if self.pausado then
        self.musica:pause()
        self.pular = false
        pause:ativar()
    else
        self.musica:play()
    end
end

function Jogo:finalizar(resultado)
    self.resultado = resultado
    if resultado == 'vitoria' then Placar.registrar(tabela_ranking, self.tempo) end
    self:encerrarFase()
    self.musica:stop()
    game_over:ativar()
    cena_atual = 'game_over'
end

function Jogo:update(dt)
    if self.pausado then return end

    local teclado = love.keyboard.isDown
    local x = (teclado('d') and 1 or 0) - (teclado('a') and 1 or 0)
    local y = (teclado('s') and 1 or 0) - (teclado('w') and 1 or 0)
    local entrada = Vector(x, y):norm()
    entrada.atirando = love.mouse.isDown(1) and mouse_delay <= 0
    entrada.pular = self.pular

    self.acumulado = self.acumulado + math.min(dt, MAX_TEMPO_FRAME)
    while self.acumulado + 1e-10 >= PASSO do
        self.acumulado = math.max(0, self.acumulado - PASSO)
        self.tempo = self.tempo + self.fase:update(PASSO, entrada)
        self.pular = false
        entrada.pular = false

        if self.fase.tempo_transicao >= 1.2 and self.fase.estado == 'morrendo' then
            self:finalizar('derrota')
            return
        elseif self.fase.tempo_transicao >= 1 and self.fase.estado == 'vencendo' then
            if self.nivel == #fases then
                self:finalizar('vitoria')
                return
            end
            self:encerrarFase()
            self.nivel = self.nivel + 1
            self.fase = Fase(fases[self.nivel])
        end
    end
end

function Jogo:draw()
    self.fase:draw()
    Recursos.usarFonte('materials/fonts/Melted-Monster.ttf', 40)
    if self.fase.estado ~= 'introducao' then
        local texto = string.format('Tempo %.2f', self.tempo)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(texto, 20, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(texto, 22, 12)
    end
    if self.pausado then pause:draw() end
end
