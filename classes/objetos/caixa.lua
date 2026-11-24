Caixa = Classe:extend()

function Caixa:new(mundo, x, y)
    self.img = Recursos.imagem('materials/misc/caixa.png')
    self.x, self.y = x, y
    self.chao = y + 74
    self.vida = 75
    self.area_tiro = {x + 18, y + 15, 65, 65}
    local grade = anim.newGrid(101, 96, self.img:getWidth(), self.img:getHeight())
    self.quadros = {
        grade(1, 1)[1],
        grade(4, 1)[1],
        grade(4, 2)[1]
    }
    self.collider = mundo:newRectangleCollider(x + 10, y + 60, 81, 26, {body_type = 'static'})
end

function Caixa:receberDano(dano)
    self.vida = math.max(0, self.vida - dano)
end

function Caixa:draw()
    local quadro = 1 + math.floor((75 - self.vida) / 30)
    love.graphics.draw(self.img, self.quadros[quadro], self.x, self.y)
end
