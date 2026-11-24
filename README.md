# 🎮 The Alckmin Deadi

<div align="center">

![Love2D](https://img.shields.io/badge/LÖVE-2D-EA316E?style=for-the-badge&logo=lua&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Status](https://img.shields.io/badge/Status-Concluído-success?style=for-the-badge)

**Um jogo de ação e tiro no estilo side-scrolling desenvolvido com LÖVE2D**

[🎮 Como Jogar](#-como-jogar) • [🚀 Instalação](#-instalação) • [🎯 Características](#-características) • [👥 Equipe](#-equipe)

</div>

---

## 📖 Sobre o Projeto

**The Alckmin Deadi** é um jogo de ação e tiro desenvolvido como projeto final da disciplina **Tópicos Avançados de Ciências da Computação 1 (TAC 1)** com foco em desenvolvimento de jogos. O projeto incorpora os principais conceitos abordados na disciplina e recursos essenciais encontrados em jogos modernos.

### 🎯 Características

- 🏠 **Menu Inicial** completo e intuitivo
- 🎨 **Sprites e Animações** personalizadas
- 🎭 **Sistema de Personagens** com herói e inimigos
- 👾 **Boss Battles** desafiadoras
- 📊 **Sistema de HUD** com vida e tempo
- ⏸️ **Menu de Pausa** funcional
- 🌍 **3 Fases** com dificuldade progressiva
- 🏆 **Sistema de Ranking** com registro de tempos
- 🎵 **Trilha Sonora** e efeitos sonoros
- 💾 **Sistema de Física** com Windfield
- 📷 **Câmera** que acompanha o jogador

---

## 🎮 Como Jogar

### Controles

| Entrada | Ação |
|-------|------|
| `W` / `A` / `S` / `D` | Andar para cima, esquerda, baixo e direita |
| Clique esquerdo | Atirar na direção em que a personagem está olhando, enquanto estiver parada |
| `Espaço` | Pular a introdução da fase |
| `Esc` | Pausar ou retomar a partida |

Derrote o chefe para avançar de fase. A vida da personagem volta ao máximo entre fases.
O ranking local guarda os dez melhores tempos de campanhas concluídas e conta apenas o tempo jogável.

---

## 🚀 Instalação

### Jogar a partir dos pacotes

- **Linux x86_64** — Torne o AppImage executável e rode o arquivo.

  ```bash
  chmod +x TheAlckminDeadi-linux-x86_64.AppImage
  ./TheAlckminDeadi-linux-x86_64.AppImage
  ```

  Se o sistema estiver sem FUSE, execute `./TheAlckminDeadi-linux-x86_64.AppImage --appimage-extract-and-run`.

- **Windows x64** — Extraia todo o conteúdo de `TheAlckminDeadi-windows-x64.zip` e abra `TheAlckminDeadi.exe` na pasta que contém as DLLs.

- **Pacote portátil** — Com [LÖVE 11.5](https://github.com/love2d/love/releases/tag/11.5) instalado, execute `love TheAlckminDeadi.love`.

### Jogar a partir do código-fonte

Com o LÖVE 11.5 instalado, abra o terminal na raiz do checkout e execute `love .`.

### Gerar os pacotes

No Linux x86_64, com Bash, Python 3, curl e coreutils, execute a partir da raiz do checkout.

```bash
bash executavel/empacotar.sh
cd dist
sha256sum -c SHA256SUMS
```

O script usa o código e os recursos do checkout e verifica os downloads dos runtimes e ferramentas por SHA-256.
A pasta `dist/` recebe o AppImage, o ZIP do Windows, o `.love` e o arquivo `SHA256SUMS`.
Para reutilizar os arquivos oficiais que já estão baixados, aponte `ALCKMIN_BUILD_TOOLS` para a pasta que os contém.

O ranking é salvo em `ranking-v1.tsv` na pasta de dados do jogo.
No Linux, o caminho padrão é `~/.local/share/love/the-alckmin-deadi/` ao executar com `love .` ou com o arquivo `.love`.
No Windows, é `%APPDATA%\LOVE\the-alckmin-deadi\` nessas mesmas modalidades.
Nos executáveis empacotados, a pasta `the-alckmin-deadi` fica diretamente no diretório de dados do usuário.

### Executar os testes

Execute `bash tests/regressao.sh` com LÖVE 11.5 instalado. Em Linux sem sessão gráfica,
execute `SDL_VIDEODRIVER=offscreen ALSOFT_DRIVERS=null bash tests/regressao.sh`.
O teste usa uma pasta de dados temporária para o ranking.

---

## 📁 Estrutura do Projeto

```
projeto-final-tac1-jogos/
├── conf.lua                 # Configurações do LÖVE2D
├── main.lua                 # Arquivo principal do jogo
├── cenas/                   # Gerenciamento de cenas/fases
│   ├── jogo.lua            # Progressão, pausa e cronômetro
│   ├── fase.lua            # Simulação compartilhada das fases
│   ├── fase1.lua           # Primeira fase
│   ├── fase2.lua           # Segunda fase
│   └── fase3.lua           # Terceira fase
├── classes/                 # Classes do jogo
│   ├── hud/                # Interface do usuário
│   │   ├── startmenu.lua   # Menu inicial
│   │   ├── pause.lua       # Menu de pausa
│   │   ├── ranking.lua     # Tela de ranking
│   │   └── ...
│   ├── personagens/        # Personagens do jogo
│   │   ├── personagem.lua  # Classe do herói
│   │   ├── inimigo.lua     # Classe dos inimigos
│   │   └── boss.lua        # Classe dos chefes
│   ├── objetos/            # Objetos do jogo
│   └── windfield/          # Biblioteca de física
├── materials/              # Assets do jogo
│   ├── audio/             # Sons e música
│   ├── background/        # Imagens de fundo
│   ├── chars/             # Sprites de personagens
│   ├── fonts/             # Fontes customizadas
│   ├── hud/               # Elementos de interface
│   └── misc/              # Outros recursos
└── executavel/            # Script de empacotamento
```

---

## 🛠️ Tecnologias Utilizadas

- **[LÖVE2D](https://love2d.org/)** - Framework de desenvolvimento de jogos 2D
- **[Lua](https://www.lua.org/)** - Linguagem de programação
- **[Windfield](https://github.com/adnzzzzZ/windfield)** - Biblioteca de física 2D
- **[anim8](https://github.com/kikito/anim8)** - Biblioteca de animações
- **[classic](https://github.com/rxi/classic)** - Sistema de orientação a objetos

---

## 🎓 Conceitos Implementados

O projeto aborda os seguintes tópicos da disciplina:

- ✅ **Game Loop** e gerenciamento de estados
- ✅ **Sistema de Cenas** (Menu, Jogo, Game Over, Ranking)
- ✅ **Sprites e Animações** com sprite sheets
- ✅ **Detecção de Colisão** usando física 2D
- ✅ **Sistema de Input** (teclado e mouse)
- ✅ **Inteligência Artificial** para inimigos
- ✅ **Sistema de Câmera** que segue o jogador
- ✅ **Gerenciamento de Recursos** (imagens, sons, fontes)
- ✅ **Persistência de Dados** (ranking de jogadores)

---

## 👥 Equipe

Projeto desenvolvido por:

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/matheusssilva991">
        <img src="https://github.com/matheusssilva991.png" width="100px;" alt="Matheus Santos Silva"/><br>
        <sub><b>Matheus Santos Silva</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/phillxandre">
        <img src="https://github.com/phillxandre.png" width="100px;" alt="Philipe Alexandre Silva Lima"/><br>
        <sub><b>Philipe Alexandre Silva Lima</b></sub>
      </a>
    </td>
  </tr>
</table>

---

## 📝 Licença

Este projeto foi desenvolvido para fins acadêmicos como parte da disciplina TAC 1.

---

## 🎯 Agradecimentos

Agradecimento especial aos professores e colegas da disciplina TAC 1 que contribuíram com conhecimento e suporte durante o desenvolvimento deste projeto.

---

<div align="center">

**Desenvolvido com ❤️ usando LÖVE2D**

⭐ Se você gostou do projeto, considere dar uma estrela!

</div>
