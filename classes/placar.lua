local Placar = {}
local arquivo = 'ranking-v1.tsv'

local function ordenar(lista)
    table.sort(lista, function(a, b)
        if a.milissegundos == b.milissegundos then return a.id < b.id end
        return a.milissegundos < b.milissegundos
    end)
    for i = #lista, 11, -1 do lista[i] = nil end
end

function Placar.carregar()
    local lista, ids = {}, {}
    local dados = love.filesystem.read(arquivo) or ''
    for linha in dados:gmatch('[^\r\n]+') do
        local id, milissegundos = linha:match('^(%d+)\t(%d+)$')
        id, milissegundos = tonumber(id), tonumber(milissegundos)
        if id and id > 0 and id < 1e12 and milissegundos and milissegundos > 0
            and milissegundos < 1e12 and not ids[id] then
            lista[#lista + 1] = {id = id, milissegundos = milissegundos}
            ids[id] = true
        end
    end
    ordenar(lista)
    return lista
end

function Placar.registrar(lista, segundos)
    local id = 1
    for _, registro in ipairs(lista) do id = math.max(id, registro.id + 1) end
    lista[#lista + 1] = {id = id, milissegundos = math.floor(segundos * 1000 + 0.5)}
    ordenar(lista)
    local linhas = {}
    for _, registro in ipairs(lista) do
        linhas[#linhas + 1] = string.format('%d\t%d\n', registro.id, registro.milissegundos)
    end
    local ok, erro = love.filesystem.write(arquivo, table.concat(linhas))
    if not ok then print('Falha ao salvar ranking: ' .. tostring(erro)) end
end

return Placar
