Paddle = Class{}

function Paddle:init(x, y, width, height, paddle_speed, ai)
    self.x = x 
    self.y = y 
    self.width = width
    self.height = height
    self.dy = 0
    self.ballX = VIRTUAL_WIDTH / 2 - 2
    self.ballY = VIRTUAL_HEIGHT / 2 - 2
    self.impactY = 0
    self.paddle_speed = paddle_speed
    self.is_ai = ai

    self.dtx = 0
    self.distanceX = 0
    self.seps = 0
    self.dty = 0
end

function Paddle:update(dt)
    self:impact_point()
    self:move()
    if self.dy < 0 then 
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - 20, self.y + self.dy * dt)
    end
end

function Paddle:impact_point()
    self.dtx = 1
    self.dtx = ball.x  - self.ballX
    self.distanceX = VIRTUAL_WIDTH - self.ballX
    self.steps = math.abs(self.distanceX / self.dtx)
    self.dty = ball.y - self.ballY
    self.ballX = ball.x 
    self.ballY = ball.y

    self.impactY = self.steps * self.dty + ball.y
end

function Paddle:move()
    if self.is_ai then
        if self.y > self.impactY then
            -- Move up
            self.dy = -self.paddle_speed
        elseif self.y + self.height < self.impactY and self.y < self.impactY then
            -- Move down
            self.dy = self.paddle_speed
        else 
            self.dy = 20
        end
    end
end

function Paddle:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
