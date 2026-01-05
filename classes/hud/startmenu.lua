--[[
    Classe Start - Menu Inicial do Jogo
    Responsável por exibir o menu principal com botões interativos
    para iniciar o jogo, ver ranking, ajuda e sair
]]--

Start = Classe:extend()

-- Altura padrão de cada botão do menu
ALTURA_BOTAO = 50

--[[
    Função auxiliar para criar um novo botão
    @param text: Texto exibido no botão
    @param fn: Função callback executada ao clicar
    @return: Tabela com propriedades do botão
]]--
local function newButton(text, fn)
    return{
        text = text,                                -- Texto do botão
        fn = fn,                                    -- Função a executar ao clicar

        now = false,                                -- Estado atual do clique
        last = false                                -- Estado anterior (para detectar clique único)
    }
end

-- Array que armazena todos os botões do menu
local botoes = {}

--[[
    Construtor da classe Start
    Inicializa o fundo animado e cria os botões do menu
]]--
function Start:new()
    -- Carrega e configura o fundo animado
    self.img_fundo = love.graphics.newImage("materials/background/fundo_menu.png")
    self.larg_img = self.img_fundo:getWidth()
    self.alt_img = self.img_fundo:getHeight()
    self.larg_frame = self.larg_img/3               -- Divide em 3 frames de animação
    self.alt_frame = self.alt_img
    local grid = anim.newGrid(self.larg_frame, self.alt_frame, self.larg_img, self.alt_img)
    self.animation = anim.newAnimation(grid('1-3', 1), 0.1)

    -- Configura a fonte padrão do menu
    font = love.graphics.setNewFont("materials/fonts/Melted-Monster.ttf", 40)
    botoes = {}

    -- Cria botão "Jogar" - Inicia o jogo
    table.insert(botoes, newButton(
        "Jogar",
        function()
            cena_atual = "jogo"
            jogo:new()
        end
    ))

    -- Cria botão "Ranking" - Exibe placar de tempos
    table.insert(botoes, newButton(
        "Ranking",
        function()
            cena_atual = "ranking"
        end
    ))

    -- Cria botão "Ajuda" - Mostra instruções do jogo
    table.insert(botoes, newButton(
        "Ajuda",
        function()
            cena_atual = "ajuda1"
        end
    ))

    -- Cria botão "Sair" - Fecha o jogo
    table.insert(botoes, newButton(
        "Sair",
        function()
            love.event.quit(0)
        end
    ))

end

--[[
    Atualiza a animação do fundo
    @param dt: Delta time
]]--
function Start:update(dt)
    self.animation:update(dt)
end

--[[
    Renderiza o menu inicial na tela
]]--
function Start:draw()
    -- Desenha o fundo animado
    self.animation:draw(self.img_fundo, 0, 0)

    -- Desenha o título do jogo com efeito de sombra
    font = love.graphics.setNewFont("materials/fonts/Dead-Kansas.ttf", 50)
    love.graphics.setColor(0, 0, 0)                 -- Sombra preta
    love.graphics.printf("THE ALCKMIN DEADI", 0, 40, 800, "center")
    love.graphics.setColor(1, 1, 1, 0.2)            -- Texto semi-transparente
    love.graphics.printf("THE ALCKMIN DEADI", 0, 40, 800, "center")
    font = love.graphics.setNewFont("materials/fonts/Melted-Monster.ttf", 40)

    -- Configurações de layout dos botões
    local larg_botao = 250
    local margem = 20

    local total_altura = (ALTURA_BOTAO + margem) * #botoes
    local cursor_y = 0

    -- Renderiza cada botão
    for _, botao in ipairs(botoes) do
        botao.last = botao.now

        -- Calcula posição do botão (centralizado)
        local bx = (LARGURA_TELA * 0.5) - (larg_botao * 0.5)
        local by = (ALTURA_TELA * 0.5) - (total_altura * 0.5) + cursor_y

        -- Cor padrão do botão (roxo)
        local color = {0.3, 0, 0.5, 1}
        local mx, my = love.mouse.getPosition()

        -- Detecta se o mouse está sobre o botão (hover)
        local hot = mx > bx and mx < bx + larg_botao and
                    my > by and my < by + ALTURA_BOTAO

        -- Muda cor quando mouse está sobre o botão (verde)
        if hot then
            color = {0, 0.4, 0, 1}
        end

        botao.now = love.mouse.isDown(1)

        -- Executa função do botão ao clicar
        if botao.now and mouse_delay <= 0 and not botao.last and hot then
            botao.fn()
        end

        -- Desenha o botão preenchido
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle(
            "fill",
            bx,
            by,
            larg_botao,
            ALTURA_BOTAO,
            20, 20)                                 -- Bordas arredondadas

        -- Desenha a borda do botão
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            "line",
            bx,
            by,
            larg_botao,
            ALTURA_BOTAO,
            20, 20)

        -- Desenha o texto do botão centralizado
        local textLarg = font:getWidth(botao.text)
        local textAlt = font:getHeight(botao.text)

        love.graphics.print(
            botao.text,
            font,
            (LARGURA_TELA * 0.5) - textLarg * 0.5,
            by + textAlt * 0.25
        )

        cursor_y = cursor_y + (ALTURA_BOTAO + margem)
    end
end
