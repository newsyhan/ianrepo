
-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------
local amount = 3
local stone;

local vertices = {0, 0,  20, -20,   0, -30,   -5, -27,  -10, -20,  -15, -15,  -20, -6,  -22, 0,  
					-20, 6,  -15, 15,  -10, 20,  -5, 27,  0, 30,  20, 20}
local bird;

function createNewStone() 
	stone = display.newCircle(0, 0, math.random(10, 40))
	stone.strokeWidth = 2
	stone:setFillColor( math.random(200, 255) / 256, math.random(200, 255) / 256, math.random(200, 255) / 256 )
	stone:setStrokeColor( math.random(0, 100) / 256, math.random(0, 100) / 256, math.random(0, 100) / 256 )
	stone.x = display.contentWidth
	stone.y = math.random(0, display.contentHeight)
	amount = math.random(3, 9)
end

function scrollStone()
	stone.x = stone.x - amount
	if (stone.x < (0 - stone.width)) then
		createNewStone()
	end
end


function scene:create( event )

	local mountain = display.newImage( "mountain.png", display.contentWidth, display.contentHeight)
	mountain.anchorX = 0
	mountain.anchorY = 0
	mountain.x = 0
	mountain.y = 0

	bird = display.newPolygon( 50, 160, vertices )
	bird:setFillColor( 1, 0, 0 )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		createNewStone()

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		timer.performWithDelay( 1, scrollStone, -1 )

	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene

