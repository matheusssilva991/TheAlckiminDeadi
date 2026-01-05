--[[
    Arquivo de configuração do LÖVE2D
    Define as propriedades da janela do jogo e configurações gerais
]]--

function love.conf(t)
    -- Configurações da janela do jogo
    t.window.title = "The Alckmin Deadi"        -- Título exibido na barra da janela
    t.window.width = 800                        -- Largura da janela em pixels
    t.window.height = 600                       -- Altura da janela em pixels

    -- Desabilita o console (útil para release do jogo)
    t.console = false
end
