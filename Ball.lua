Ball = Class{}

function Ball:init(x, y, width, height, servingPlayer)
    self.x = x
    self.y = y 
    self.width = width
    self.height = height

    -- Start x-velocity
    if servingPlayer == 1 then 
        self.dx = 100
    else 
        self.dx = -100
    end
    
    self.dy = love.math.random(-50, 50)
end

function Ball:collides(box)
    -- Check for X position
    if self.x > box.x + box.width or self.x + self.width < box.x then 
        return false 
    end

    -- Check for Y position
    if self.y > box.y + box.height or self.y + self.height < box.y then 
        return false 
    end

    return true 

end

function Ball:reset(dx)
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2

    self.dx = dx
    self.dy = love.math.random(-50, 50)
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end