#!/usr/bin/env bash
set -euo pipefail

raiz=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ $(uname -s) != Linux || $(uname -m) != x86_64 ]]; then
    printf '%s\n' 'Execute a geração dos pacotes em Linux x86_64.' >&2
    exit 1
fi

trabalho=$(mktemp -d)
trap 'rm -rf -- "$trabalho"' EXIT
mkdir -p "$trabalho/downloads" "$trabalho/saida" "$trabalho/linux"
origem=${ALCKMIN_BUILD_TOOLS:-"$trabalho/downloads"}
saida="$trabalho/saida"
jogo=TheAlckminDeadi

obter() {
    local url=$1 sha=$2 nome=${1##*/} arquivo
    arquivo="$trabalho/downloads/$nome"
    if [[ -f "$origem/$nome" ]]; then
        if [[ ! "$origem/$nome" -ef "$arquivo" ]]; then cp -- "$origem/$nome" "$arquivo"; fi
    else
        curl --fail --location --silent --show-error --retry 2 -o "$arquivo" "$url"
    fi
    printf '%s  %s\n' "$sha" "$arquivo" | sha256sum --check --status ||
        { printf 'SHA-256 inválido para %s\n' "$nome" >&2; return 1; }
}
love_release=https://github.com/love2d/love/releases/download/11.5
obter "$love_release/love-11.5-x86_64.AppImage" 65a673406431eff7167a15a032bf7a2e4ba50108e091eb7b176465831f9b5e00
obter "$love_release/love-11.5-win64.zip" ba6e56be2685e53c817749c4a5007f51137136fe5a3ab64920508babc2e74369
obter https://github.com/AppImage/appimagetool/releases/download/1.9.1/appimagetool-x86_64.AppImage ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0
obter https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-x86_64 2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d

python3 - "$raiz" "$saida/$jogo.love" "$trabalho/downloads/love-11.5-win64.zip" "$saida/$jogo-windows-x64.zip" "$jogo" <<'PY'
import sys
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

raiz, love, runtime, windows = map(Path, sys.argv[1:5])
nome = sys.argv[5]

def escrever(arquivo, caminho, dados, modo=0o644):
    entrada = ZipInfo(caminho, date_time=(1980, 1, 1, 0, 0, 0))
    entrada.create_system = 3
    entrada.external_attr = (0o100000 | modo) << 16
    arquivo.writestr(entrada, dados, compress_type=ZIP_DEFLATED)

arquivos = [raiz / 'main.lua', raiz / 'conf.lua']
for pasta in ('cenas', 'classes', 'materials'):
    arquivos.extend(item for item in (raiz / pasta).rglob('*') if item.is_file())
with ZipFile(love, 'w') as pacote:
    for arquivo in sorted(arquivos):
        nome_relativo = arquivo.relative_to(raiz)
        if any(parte.startswith('.') for parte in nome_relativo.parts):
            continue
        escrever(pacote, nome_relativo.as_posix(), arquivo.read_bytes())

with ZipFile(runtime) as origem, ZipFile(windows, 'w') as pacote:
    base = 'love-11.5-win64/'
    executavel = origem.read(base + 'love.exe') + love.read_bytes()
    escrever(pacote, nome + '/' + nome + '.exe', executavel, 0o755)
    for entrada in sorted(origem.namelist()):
        arquivo = Path(entrada).name
        if arquivo.endswith('.dll') or arquivo == 'license.txt':
            escrever(pacote, nome + '/' + arquivo, origem.read(entrada))
PY

runtime_linux="$trabalho/downloads/love-11.5-x86_64.AppImage"
appimagetool="$trabalho/downloads/appimagetool-x86_64.AppImage"
chmod u+x "$runtime_linux" "$appimagetool"
(
    cd "$trabalho/linux"
    "$runtime_linux" --appimage-extract >/dev/null
)
appdir="$trabalho/linux/squashfs-root"
cat "$appdir/bin/love" "$saida/$jogo.love" > "$appdir/bin/$jogo"
chmod 755 "$appdir/bin/$jogo"
rm -- "$appdir/bin/love" "$appdir/love.desktop"
sed '/^# uncomment and edit to add your own game/,$d' "$appdir/AppRun" > "$appdir/AppRun.novo"
printf 'exec "$APPDIR/bin/%s" "$@"\n' "$jogo" >> "$appdir/AppRun.novo"
mv -- "$appdir/AppRun.novo" "$appdir/AppRun"
chmod 755 "$appdir/AppRun"
cp -- "$raiz/materials/hud/cabeca_boss1.png" "$appdir/$jogo.png"
cat > "$appdir/$jogo.desktop" <<DESKTOP
[Desktop Entry]
Name=The Alckmin Deadi
Exec=$jogo
Icon=$jogo
Type=Application
Categories=Game;ActionGame;
Terminal=false
DESKTOP

ARCH=x86_64 SOURCE_DATE_EPOCH=315532800 "$appimagetool" --appimage-extract-and-run \
    --no-appstream --runtime-file "$trabalho/downloads/runtime-x86_64" \
    --mksquashfs-opt=-processors --mksquashfs-opt=2 \
    "$appdir" "$saida/$jogo-linux-x86_64.AppImage"

(
    cd "$saida"
    sha256sum "$jogo.love" "$jogo-linux-x86_64.AppImage" "$jogo-windows-x64.zip" > SHA256SUMS
)
mkdir -p "$raiz/dist"
mv -- "$saida/"* "$raiz/dist/"
printf 'Pacotes em %s/dist\n' "$raiz"
