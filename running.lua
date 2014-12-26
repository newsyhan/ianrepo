
-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local physics = require "physics"
physics.start()
physics.setGravity(0, 15)
physics.pause()

--------------------------------------------
local amount = 3
local stone;

local up = false
local impulse = -60


-- hellicopter sprite group
local helliGroup = display.newGroup()
local helli
local helli_up

local ground


function loadGroundLayer( sceneGroup, imageName )
    -- Create a group
    local parallaxGroup = display.newGroup()
    
    -- Load the background image twice and add them to the group
    local groundImage = display.newImage( imageName )
    parallaxGroup:insert( groundImage )
    groundImage.anchorX, groundImage.anchorY = 0, 0
    groundImage.x = 0
    -- groundImage.y = 100
    
    groundImage = display.newImage( imageName )
    parallaxGroup:insert( groundImage )
    groundImage.anchorX, groundImage.anchorY = 0, 0
    groundImage.x = groundImage.width
    -- image.y = 100
    
    -- Add the parallax group to the scene
    sceneGroup:insert( parallaxGroup )
    parallaxGroup.y = display.contentHeight - 24

    -- Return the group
    return parallaxGroup
end

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

	local sceneGroup = self.view

	-- background setting
	local mountain = display.newImage( "mountain.png", display.contentWidth, display.contentHeight)
	mountain.anchorX, mountain.anchorY = 0, 0
	mountain.x, mountain.y = 0, 0
	mountain:addEventListener("touch", movePlayer)
	sceneGroup:insert( mountain )

	-- Ground
	ground = loadGroundLayer(sceneGroup, "resources/images/ground1.png")

	-- Hellicopter
	helliGroup = display.newGroup()
	helli = display.newImageRect(helliGroup, "helicopter.png", 50, 31)
	helli_up = display.newImageRect(helliGroup, "helicopter_up.png", 50, 29)
	helliGroup.x = 70
	helliGroup.y = 50
	helli_up.isVisible = false

	physics.addBody(helliGroup, {density = 0, friction = 0, bounce = 0.1})

	-- ground.anchorX, ground.anchorY = 0, 1
	-- ground.x = 0
	-- ground.y = display.contentHeight
	-- print("display.contentWidth : " .. display.contentWidth)
	-- print("display.contentHeight : " .. display.contentHeight)

	local halfWidth = display.contentWidth * 0.5
	print("ground : " ..ground.x .. ", " .. ground.y .. " - " .. ground.width .. ", " .. ground.height)
	local groundshape = { -halfWidth, 25, halfWidth, 25, halfWidth, 10, -halfWidth, 10}
	physics.addBody(ground, "static", { friction=0.3, shape=groundshape } )

	sceneGroup:insert( helliGroup )

end

function movePlayer( event )
	if (event.phase == "began") then
		up = true;
		helli.isVisible = false
		helli_up.isVisible = true
	elseif (event.phase == "ended") then
		up = false;
		impulse = -60
		helli.isVisible = true
		helli_up.isVisible = false
	end

end


local function updateParallax()

	ground.x = ground.x - 4

	print("ground.x  : " .. ground.x  .. ", ground[1].width : " .. ground[1].width)

	if(ground.x <= ground[1].width * -1) then
		ground.x = 0
	end

end


local function update( event )

	if (up) then
		impulse = impulse - 27
		helliGroup:setLinearVelocity(0, impulse)
	end

	updateParallax()

end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		Runtime:addEventListener("enterFrame", update)
		createNewStone()

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		physics.start()

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

		physics.stop()
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

