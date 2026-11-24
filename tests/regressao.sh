#!/usr/bin/env bash
set -euo pipefail

raiz=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
trabalho=$(mktemp -d)
trap 'rm -rf -- "$trabalho"' EXIT
cp -r "$raiz"/{main.lua,conf.lua,cenas,classes,materials} "$trabalho/"
cp "$raiz/tests/regressao.lua" "$trabalho/"
cat >> "$trabalho/main.lua" <<'LUA'

local carregarJogo = love.load

function love.load(argumentos)
    local ok, erro = xpcall(function()
        carregarJogo()
        if argumentos[1] == '--verificar-ranking' then
            assert(#tabela_ranking == 10 and tabela_ranking[10].milissegundos == 900)
            print('OK: ranking recarregado em um novo processo')
        else
            require('regressao')()
        end
    end, debug.traceback)
    if not ok then io.stderr:write(erro, '\n') end
    love.event.quit(ok and 0 or 1)
end
LUA
export XDG_DATA_HOME="$trabalho/dados"
export APPDATA="$trabalho/dados"
"${1:-love}" "$trabalho"
"${1:-love}" "$trabalho" --verificar-ranking
