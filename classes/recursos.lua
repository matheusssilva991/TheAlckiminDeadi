local Recursos = {}
local imagens, fontes, sons = {}, {}, {}

function Recursos.imagem(caminho)
    if not imagens[caminho] then
        imagens[caminho] = love.graphics.newImage(caminho)
    end
    return imagens[caminho]
end

function Recursos.fonte(caminho, tamanho)
    local chave = tamanho and caminho .. ':' .. tamanho or caminho
    if not fontes[chave] then
        fontes[chave] = tamanho and love.graphics.newFont(caminho, tamanho) or love.graphics.newFont(caminho)
    end
    return fontes[chave]
end

function Recursos.usarFonte(caminho, tamanho)
    local fonte = Recursos.fonte(caminho, tamanho)
    love.graphics.setFont(fonte)
    return fonte
end

function Recursos.tocar(caminho, volume)
    if not sons[caminho] then
        sons[caminho] = {}
    end
    local canais = sons[caminho]
    for _, canal in ipairs(canais) do
        if not canal:isPlaying() then
            canal:setVolume(volume)
            canal:play()
            return
        end
    end
    local canal = canais[1] and canais[1]:clone() or love.audio.newSource(caminho, 'static')
    canais[#canais + 1] = canal
    canal:setVolume(volume)
    canal:play()
end

return Recursos
