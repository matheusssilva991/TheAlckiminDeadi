return {
    mapa = "mapa_fase_1",
    titulo = "Capítulo 1: O despertar",
    historia = "A ex-policial Luiza Inarcia acorda de um coma no hospital após um grave acidente na metalúrgica em que trabalhava."..
        " Ao procurar ajuda dos profissionais do hospital, percebe que não há ninguém naquele andar... nem no resto edifício."..
        " Ao olhar pela janela percebe uma estranha movimentação na rua. Descendo para o térreo encontra um policial morto junto com um rifle.",
    heroi = {190, 246},
    tipos = {
        {dano = 5, vida = 100, op = 1, vel_max = 120, raio = 100},
        {dano = 10, vida = 100, op = 3, vel_max = 100, raio = 100},
        {dano = 15, vida = 100, op = 4, vel_max = 60, raio = 100},
    },
    inimigos = {
        {1, 420, 220},
        {2, 90, 460},
        {3, 720, 410},
        {2, 945, 236},
        {3, 1120, 177},
        {2, 1154, 462},
        {2, 1401, 456},
        {1, 1408, 214},
        {1, 1625, 167},
    },
    obstaculos = {
        {55, 160, 35, 90}, {281, 160, 35, 90},
        {1650, 160, 140, 80}, {1900, 160, 140, 80}
    },
    chefe = {vida = 720, dano = 16, vel = 700, vel_tiro = 350, intervalo_tiro = 0.55, aviso = 2.00}
}
