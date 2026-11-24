local Colisao = {}

function Colisao.circulo(origem, destino, centro, raio)
    local inicio = origem - centro
    local c = inicio:magSq() - raio * raio
    if c <= 0 then return 0 end

    local passo = destino - origem
    local a = passo:magSq()
    local b = inicio.x * passo.x + inicio.y * passo.y
    local discriminante = b * b - a * c
    if a == 0 or b >= 0 or discriminante < 0 then return nil end

    local t = (-b - math.sqrt(discriminante)) / a
    if t <= 1 then return t end
end

-- Trajetória relativa entre dois corpos que se movem no mesmo passo.
function Colisao.alvo(origem, destino, alvo, raio)
    local centro = alvo.posicao
    if alvo.posicao_anterior then
        origem = origem + (centro - alvo.posicao_anterior)
    end
    return Colisao.circulo(origem, destino, centro, raio + alvo.raio)
end

local function caixa(origem, destino, x1, y1, x2, y2)
    local entrada, saida = 0, 1
    local function eixo(inicio, fim, minimo, maximo)
        local passo = fim - inicio
        if passo == 0 then return inicio >= minimo and inicio <= maximo end
        local t1, t2 = (minimo - inicio) / passo, (maximo - inicio) / passo
        entrada = math.max(entrada, math.min(t1, t2))
        saida = math.min(saida, math.max(t1, t2))
        return entrada <= saida
    end
    if eixo(origem.x, destino.x, x1, x2) and eixo(origem.y, destino.y, y1, y2) then
        return entrada
    end
end

-- O raio alarga as laterais do obstáculo e arredonda seus cantos.
function Colisao.retangulo(origem, destino, retangulo, raio)
    local x1, y1, largura, altura = unpack(retangulo)
    local x2, y2 = x1 + largura, y1 + altura
    local primeiro = math.min(
        caixa(origem, destino, x1 - raio, y1, x2 + raio, y2) or math.huge,
        caixa(origem, destino, x1, y1 - raio, x2, y2 + raio) or math.huge
    )
    for _, x in ipairs({x1, x2}) do
        for _, y in ipairs({y1, y2}) do
            primeiro = math.min(primeiro, Colisao.circulo(origem, destino, Vector(x, y), raio) or math.huge)
        end
    end
    if primeiro <= 1 then return primeiro end
end

return Colisao
