-- Imports
-- https://github.com/Ulydev/push
push = require 'push'
Class = require 'class'
require 'Ball'
require 'Paddle'

-- Constants
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 300

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    love.window.setTitle("Pong")

    -- Seed the random generator
    love.math.random(os.time())

    -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text 
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Load Fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)

    -- Load sounds
    sounds = {
        ['paddle'] = love.audio.newSource('paddle.wav', 'static'),
        ['wall'] = love.audio.newSource('wall.wav', 'static'),
        ['point'] = love.audio.newSource('point.wav', 'static'),
    }
    
    -- Player initialisation
    player1 = Paddle(5, 20, 5, 20, PADDLE_SPEED, false)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20, PADDLE_SPEED, true)

    player1Score = 0
    player2Score = 0
 
    servingPlayer = math.random(2) == 1 and 1 or 2 
    winningPlayer = 0

    -- Ball initialisation
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4, servingPlayer)

    -- Game state
    gameState = 'start'

    -- Use the push Class to zoom into the the screen
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end 

--[[
    Runs on each gameloop
]]
function love.update(dt)
    if gameState == 'play' then
        
        ball:update(dt)

        if ball.x <= 0 then 
            sounds['point']:play()
            player2Score = player2Score + 1
            servingPlayer = 1
            gameState = 'serve'
            ball:reset(200)
        end

        if ball.x >= VIRTUAL_WIDTH - ball.width then 
            sounds['point']:play()
            player1Score = player1Score + 1
            servingPlayer = 2
            gameState = 'serve'
            ball:reset(-200)
        end

        if ball:collides(player1) then 
            -- Deflect ball to the right
            ball.dx = -ball.dx
            sounds['paddle']:play()
        end
    
        if ball:collides(player2) then 
            -- Deflect ball to the left
            ball.dx = -ball.dx 
            sounds['paddle']:play()
        end

        -- Victory check
        if player2Score >= 2 then
            gameState = 'victory'
            winningPlayer = 2
        elseif player1Score >= 2 then
            gameState = 'victory'
            winningPlayer = 1
        end
    end
    

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
    
   
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end
    

    player1:update(dt)
    player2:update(dt)
end

--[[
    Keyboard handling, called by LÖVE each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end

--[[    
    Called after update by LÖVE, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()

    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    love.graphics.setFont(smallFont)
    if gameState == 'start' then 
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("press enter to play", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve'then
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("press enter to serve", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("press enter to restart", 0, 52, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- Ball
    ball:render()

    -- Paddles
    player1:render()
    player2:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 40, 20)
    love.graphics.print("Impact: "..tostring(player2.impactY), 80, 20)
    love.graphics.print("Paddle speed: "..tostring(player2.paddle_speed), 80, 40)
    love.graphics.print("dy: "..tostring(player2.dy), 80, 60)
    love.graphics.setColor(1, 1, 1, 1)
end

function love.resize(height, width)
    push:resize(height, width)
end
