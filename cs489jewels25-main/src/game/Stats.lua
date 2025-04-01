local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Tween = require "libs.tween"
local Sounds = require "src.game.SoundEffects"

local statFont = love.graphics.newFont(26)
local comboFont = love.graphics.newFont(30)

local Stats = Class{}
function Stats:init()
    self.y = 10 -- we will need it for tweening later
    self.level = 1 -- current level    
    self.totalScore = 0 -- total score so far
    self.targetScore = 1000
    self.maxSecs = 99 -- max seconds for the level
    self.elapsedSecs = 0 -- elapsed seconds
    self.timeOut = false -- when time is out
    self.tweenLevel = nil -- for later

    self.comboY = 150 -- y-value for tweening
    self.combo = 0 -- tracks the current combo (x2, x3, etc.)
    self.comboTweenLevel = nil -- tween for combo display animation
    self.comboBonusScore = 0 -- bonus score for combos
    self.comboOnDisplay = false

    Timer.every(1, function() self:clock() end) -- every 1 sec, call clock
end

function Stats:clock()
    self.elapsedSecs = self.elapsedSecs+1 -- 1 sec passed
    if self.elapsedSecs > self.maxSecs then -- max passed
        self.timeOut = true
    end
end

function Stats:draw()
    love.graphics.setColor(1,0,1)  -- Magenta
    love.graphics.printf("Level "..tostring(self.level),statFont,gameWidth/2-60,self.y,100,"center")
    love.graphics.printf("Time "..tostring(self.elapsedSecs).."/"..tostring(self.maxSecs), statFont,10,10,200)
    love.graphics.printf("Score "..tostring(self.totalScore), statFont,gameWidth-210,10,200,"right")

    if self.comboOnDisplay and self.combo > 1 then -- if a combo occurs, display it
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Nice! Combo x"..tostring(self.combo),comboFont,0,self.comboY,gameWidth,"center") -- displays current combo in the center of the screen
    end

    love.graphics.setColor(1,1,1)  -- White
end
    
function Stats:update(dt)
    Timer.update(dt)
    if self.tweenLevel then
        if self.tweenLevel:update(dt) then -- if tweenLevel is not nil
            self.tweenLevel = nil -- for later
        end
    end

    if self.comboTweenLevel then -- combo tween
        if self.comboTweenLevel:update(dt) then -- if comboTweenLevel is not nil
            self.comboTweenLevel = nil
            self.comboOnDisplay = false -- hide combo text after tween
        end
    end
end

function Stats:addScore(n, comboCount)
    self.totalScore = self.totalScore + n

    if comboCount > 0 then
        self.combo = comboCount
        self.comboBonusScore = self.combo * 25 -- each combo multiplier is worth 25 (25 x combo)
        self.totalScore = self.totalScore + self.comboBonusScore
        
        self.comboOnDisplay = true -- displaying combo on screen

        self.comboY = gameHeight-100
        self.comboTweenLevel = Tween.new(1.5, self, {comboY = gameHeight-40}, "outBounce") -- tween combo from lower half of screen to the bottom of it, just below board
    end

    if self.totalScore > self.targetScore then
        self:levelUp()
    end
end

function Stats:levelUp()
    Sounds['levelUp']:play() -- play level up sound
    self.level = self.level+1
    self.targetScore = self.targetScore+self.level*1000
    self.elapsedSecs = 0

    self.y = gameHeight / 2
    self.tweenLevel = Tween.new(2, self, {y = 10}, "outCubic") -- tween level up from middle of screen to the top
end
    
return Stats
    