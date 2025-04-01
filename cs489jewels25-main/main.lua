-- Author: Ryland Mata
local Globals = require "src.Globals"
local Push = require "libs.push"
local Background = require "src.game.Background"
local Gem = require "src.game.Gem"
local Board = require "src.game.Board"
local Border = require "src.game.Border"
local Explosion = require "src.game.Explosion"
local Sounds = require "src.game.SoundEffects"
local Stats = require "src.game.Stats"

-- Load is executed only once; used to setup initial resource for your game
function love.load()
    love.window.setTitle("CS489 Jewels")
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
    math.randomseed(os.time()) -- RNG setup for later

    titleFont = love.graphics.newFont(40)
    textFont = love.graphics.newFont(16)

    bg1 = Background("graphics/bg/background1.png",30)
    bg2 = Background("graphics/bg/background2.png",60)

    gem1 = Gem(100,50,5)
    gem2 = Gem(166,110,6)
    gem3 = Gem(233,140,7)
    gem4 = Gem(300,160,8)
    gem5 = Gem(366,140,7)
    gem6 = Gem(433,110,4)
    gem7 = Gem(500,50,5)

    stats = Stats()
    board = Board(140,80,stats)
    border = Border(110,50,380,380)

    testexp = Explosion()
end

-- When the game window resizes
function love.resize(w,h)
    Push:resize(w,h) -- must called Push to maintain game resolution
end

-- Event for keyboard pressing
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "F2" or key == "tab" then
        debugFlag = not debugFlag
    elseif key == "return" and gameState=="start" then
        gameState = "play"
        Sounds["playStateMusic"]:play() -- play music when starting game
    elseif key == "return" and gameState=="over" then
        stats = Stats()
        board = Board(140,80,stats)
        border = Border(110,50,380,380)

        testexp = Explosion()
        gameState = "play"
        Sounds["playStateMusic"]:play() -- play music when restarting game
    end
end

-- Event to handle mouse pressed (there is another for mouse release)
function love.mousepressed(x, y, button, istouch)
    local gx, gy = Push:toGame(x,y)
    if button == 1 then -- regurlar mouse click
        board:mousepressed(gx,gy)
    elseif debugFlag then
        if button == 2 and love.keyboard.isDown("lctrl","rctrl") then
           testexp:trigger(gx,gy)
        elseif button == 2 then
            board:cheatGem(gx,gy)
        end
    end
end

-- Update is executed each frame, dt is delta time (a fraction of a sec)
function love.update(dt)
    bg1:update(dt)
    bg2:update(dt)
    testexp:update(dt)
    stats:update(dt)

    if stats.timeOut and gameState ~= "over" then
        gameState = "over"
        if Sounds["timeOut"]:isPlaying() then
            Sounds["timeOut"]:stop() -- stop playing game over music
        end
        Sounds["timeOut"]:play() 
        Sounds["playStateMusic"]:stop() -- stop music when game ends
        gem1.x,gem1.y = 100,160
        gem2.x,gem2.y = 166,100
        gem3.x,gem3.y = 233,70
        gem4.x,gem4.y = 300,50
        gem5.x,gem5.y = 366,70
        gem6.x,gem6.y = 433,100
        gem7.x,gem7.y = 500,160
    end

    if gameState == "start" then
        gem1:update(dt)
        gem2:update(dt)
        gem3:update(dt)
        gem4:update(dt)
        gem5:update(dt)
        gem6:update(dt)
        gem7:update(dt)
        
    elseif gameState == "play" then
        board:update(dt)

    elseif gameState == "over" then
        -- for later, if we needed
        gem1:update(dt)
        gem2:update(dt)
        gem3:update(dt)
        gem4:update(dt)
        gem5:update(dt)
        gem6:update(dt)
        gem7:update(dt)
    end
end

-- Draws the game after the update
function love.draw()
    Push:start()

    -- always draw between Push:start() and Push:finish()
    if gameState== "start" then
        drawStartState()
    elseif gameState == "play" then
        drawPlayState()    
    elseif gameState == "over" then
        drawGameOverState()    
    end

    if testexp:isActive() then
        testexp:draw()
    end
    if debugFlag then
        love.graphics.print("DEBUG ON",20,gameHeight-20)
    end

    Push:finish()
end

function drawStartState()
    bg1:draw()
    bg2:draw()

    love.graphics.setColor(0, 0, 1)
    love.graphics.printf("CS489 Jewels",titleFont,0,50,
        gameWidth,"center")
    love.graphics.printf("Press Enter to Play or Escape to exit",
        0,100, gameWidth,"center")
    love.graphics.setColor(1, 1, 1)

    gem1:draw()
    gem2:draw()
    gem3:draw()
    gem4:draw() 
    gem5:draw()
    gem6:draw()  
    gem7:draw() 
end

function drawPlayState()
    bg1:draw()
    bg2:draw()

    board:draw()

    border:draw()
    stats:draw()
end

function drawGameOverState()
    bg1:draw()
    bg2:draw()

    gem1:draw()
    gem2:draw()
    gem3:draw()
    gem4:draw() 
    gem5:draw()
    gem6:draw()  
    gem7:draw() 

    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("GameOver",titleFont,0,120,
        gameWidth,"center")
    love.graphics.printf("Press Enter to Play Again or Escape to exit",
        textFont,0,160, gameWidth,"center")

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Level Reached: "..tostring(stats.level),textFont,0,200,gameWidth,"center")
    love.graphics.printf("Final Score: "..tostring(stats.totalScore),textFont,0,220,gameWidth,"center")
end