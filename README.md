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
- 📊 **Sistema de HUD** com vida, pontuação e tempo
- ⏸️ **Menu de Pausa** funcional
- 🌍 **3 Fases** com dificuldade progressiva
- 🏆 **Sistema de Ranking** com registro de tempos
- 🎵 **Trilha Sonora** e efeitos sonoros
- 💾 **Sistema de Física** com Windfield
- 📷 **Câmera** que acompanha o jogador

---

## 🎮 Como Jogar

### Controles

| Tecla | Ação |
|-------|------|
| `W` / `↑` | Mover para cima |
| `S` / `↓` | Mover para baixo |
| `A` / `←` | Mover para esquerda |
| `D` / `→` | Mover para direita |
| `Mouse` | Mirar |
| `Clique Esquerdo` | Atirar |
| `ESC` | Pausar jogo |

### Objetivo

Avance através das 3 fases eliminando inimigos e derrotando os chefes. Complete o jogo no menor tempo possível para alcançar o topo do ranking!

---

## 🚀 Instalação

### Pré-requisitos

- [LÖVE2D](https://love2d.org/) (versão 11.x ou superior)
- Sistema Operacional: Windows, macOS ou Linux

### Executando o Jogo

#### Opção 1: Através do executável (Windows)

```bash
# Navegue até a pasta executavel
cd executavel
# Execute o arquivo jogo.love
```

#### Opção 2: Através do código fonte

```bash
# Clone o repositório
git clone https://github.com/matheusssilva991/projeto-final-tac1-jogos.git

# Navegue até a pasta do projeto
cd projeto-final-tac1-jogos

# Execute com LÖVE
love .
```

#### Opção 3: Gerando executável Windows

```bash
# Na pasta executavel, execute
gera exe.bat
```

---

## 📁 Estrutura do Projeto

```
projeto-final-tac1-jogos/
├── conf.lua                 # Configurações do LÖVE2D
├── main.lua                 # Arquivo principal do jogo
├── cenas/                   # Gerenciamento de cenas/fases
│   ├── jogo.lua            # Lógica principal do jogo
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
└── executavel/            # Executável do jogo
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
- ✅ **Sistema de Partículas** e efeitos visuais
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
