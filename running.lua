
-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local timer = require "timer"
local audio = require "audio"
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

local HELI_FLY = 1
local HELI_UP = 2
local HELI_STOP = 3
local HELI_EXPLOSION = 4
local HELI_STATUS

local backWall

-- helicopter sprite group
local heliGroup = display.newGroup()
local heli_fly
local heli_stop
local heli_up

local ground
local groundMoveSpeed = 4

local scoreBox
local score = 0

local reStartTimerId
local stoneTimerId

-- local explosionSound
local helicopterSound
local bg1Sound

local helicopterChannel = 0


function loadGroundLayer( sceneGroup, imageName )
    -- Create a group
    local parallaxGroup = display.newGroup()
    
    -- Load the background image twice and add them to the group
    local groundImage = display.newImage( imageName )
    parallaxGroup:insert( groundImage )
    groundImage.anchorX, groundImage.anchorY = 0, 0
    groundImage.width = display.contentWidth
    groundImage.x = 0
    -- groundImage.y = 100
    
    groundImage = display.newImage( imageName )
    parallaxGroup:insert( groundImage )
    groundImage.anchorX, groundImage.anchorY = 0, 0
    groundImage.width = display.contentWidth
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
	stone.y = math.random(30, display.contentHeight - 30 - stone.height)
	amount = math.random(7, 17)

	stone.myName = "stone"

	-- calcurate radius
	-- print ( "stone.width : " .. stone.width )
	local stoneRadius = (stone.width * 0.5) - 3
	if ( stoneRadius <= 0 ) then
		stoneRadius = 1
	end
	-- print ( "stoneRadius : " .. stoneRadius )
	physics.addBody(stone, "static", { radius=stoneRadius, isSensor=true })
end

function scrollStone()
	stone.x = stone.x - amount
	if (stone.x < (0 - stone.width)) then
		stone:removeSelf ()
		createNewStone()
	end
end



function changeHellicopter( status )
	
	HELI_STATUS = status

	if ( status ~= HELI_EXPLOSION) then
		if ( status == HELI_FLY ) then
			heli_stop.isVisible = false
			heli_up.isVisible = false
			heli_fly.isVisible = true
			heli_explosion.isVisible = false
			
			if(helicopterChannel == 0) then
				helicopterChannel = audio.play(helicopterSound, {loops = -1})
				print ( "FLY PLAY... " .. helicopterChannel)
			end
			
			groundMoveSpeed = 4
		elseif ( status == HELI_UP) then
			heli_stop.isVisible = false
			heli_fly.isVisible = false
			heli_up.isVisible = true
			heli_explosion.isVisible = false

			if(helicopterChannel == 0) then
				helicopterChannel = audio.play(helicopterSound, {loops = -1})
				print ( "UP PLAY... " .. helicopterChannel)
			end
			
			groundMoveSpeed = 4
		elseif ( status == HELI_STOP) then
			heli_stop.isVisible = true
			heli_fly.isVisible = false
			heli_up.isVisible = false
			heli_explosion.isVisible = false

			if(helicopterChannel ~= 0) then
				audio.stop(helicopterChannel)
				helicopterChannel = 0
				print ( "AUDIO STOP... " .. helicopterChannel)
			end
			
			groundMoveSpeed = 0
		end
	else

		media.playEventSound ( "resources/sounds/explosion1.mp3" )

		-- audio.play ( explosionSound )
		heli_stop.isVisible = false
		heli_fly.isVisible = false
		heli_up.isVisible = false
		heli_explosion.isVisible = true

		if(helicopterChannel ~= 0) then
			audio.stop(helicopterChannel)
			helicopterChannel = 0
			print ( "AUDIO STOP... " .. helicopterChannel)
		end

		groundMoveSpeed = 0
	end
end

function movePlayer( event )

	if (event.phase == "began") then
		up = true
		changeHellicopter( HELI_UP )
	elseif (event.phase == "ended") then
		up = false
		impulse = -60
		changeHellicopter( HELI_FLY )
	end

end


local function updateParallax()

	ground.x = ground.x - groundMoveSpeed

	-- change score
	if ( HELI_STATUS ~= HELI_EXPLOSION ) then
		if ( groundMoveSpeed > 0 ) then
			score = score + 3
		elseif ( score > 0) then
			score = score - 1
		end
	end
	scoreBox.text = score

	-- print ( "score : " .. score )

	-- print("ground.x  : " .. ground.x .. ", ground[1].width : " .. ground[1].width .. ", ground[2].width : " .. ground[2].width)

	if(ground.x <= ground[1].width * -1) then
		-- print("IF==============================================================")
		ground.x = 0
	end

end


local function update( event )

	-- print ( "heliGroup.rotation : " .. heliGroup.rotation )

	if ( up ) then
		impulse = impulse - 20
		heliGroup:setLinearVelocity(0, impulse)
	end

	if (heliGroup.y >= 289 and HELI_STATUS == HELI_FLY) then
		changeHellicopter( HELI_STOP )
	end

	-- print ("heliGroup..." .. heliGroup.y)
	updateParallax()

end

function reStart ( event )
	print ( "reStart..............." )
	timer.cancel(reStartTimerId)

	score = 0;

	-- restart stone
	stone:removeSelf ()
	createNewStone()
	stoneTimerId = timer.performWithDelay( 1, scrollStone, -1 )

	-- restart helicopter
	changeHellicopter(HELI_FLY)
	heliGroup.x = 70
	heliGroup.y = 50
	heliGroup.rotation = 0

	backWall:addEventListener("touch", movePlayer)
end

function explosionHelicopter ( event )
	changeHellicopter ( HELI_EXPLOSION )
end


function onCollision( event )
	-- body
	if ( event.phase == "began" ) then
		if ( event.object1.myName == "heliGroup" and event.object2.myName == "stone" ) then
			if ( HELI_STATUS ~= HELI_EXPLOSION ) then
				print ("폭발...")
				changeHellicopter ( HELI_EXPLOSION )
				-- audio.play ( explosionSound, {onComplete=explosionHelicopter} )

				up = false
				heliGroup:setLinearVelocity(0, 100)
				backWall:removeEventListener("touch", movePlayer)
				reStartTimerId = timer.performWithDelay (4000, reStart)
				timer.cancel ( stoneTimerId )
			end
		end
		-- print ("collision began : " .. event.object1.myName .. " and " .. event.object2.myName)
	elseif ( event.phase == "ended" ) then
		-- print ("collision ended : " .. event.object1.myName .. " and " .. event.object2.myName)
	end

end

------------------------------------------------------------------------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view

	scoreBox = display.newText( score, 100, 5, native.systemFont, 16 )
	scoreBox:setTextColor(1, 0.1, 0.1)
	scoreBox.anchorX, scoreBox.anchorY = 0, 0

	heliGroup.anchorX, heliGroup.anchorY = 0, 0

	-- background setting
	backWall = display.newImage( "resources/images/mountain.png", display.contentWidth, display.contentHeight)
	backWall.anchorX, backWall.anchorY = 0, 0
	backWall.x, backWall.y = 0, 0
	backWall:addEventListener("touch", movePlayer)
	sceneGroup:insert( backWall )

	-- Ground
	ground = loadGroundLayer(sceneGroup, "resources/images/ground1.png")

	-- Hellicopter
	heliGroup = display.newGroup()
	heliGroup.myName = "heliGroup"
	heli_fly = display.newImageRect(heliGroup, "resources/images/helicopter_fly.png", 50, 29)
	heli_up = display.newImageRect(heliGroup, "resources/images/helicopter_up.png", 50, 31)
	heli_stop = display.newImageRect(heliGroup, "resources/images/helicopter_stop.png", 50, 30)
	heli_explosion = display.newImageRect(heliGroup, "resources/images/helicopter_explosion.png", 50, 31)
	heliGroup.x = 70
	heliGroup.y = 50
	changeHellicopter(HELI_FLY)

	physics.addBody(heliGroup, "dynamic", { density = 0, friction = 0, bounce = 0.1 })

	-- ground.anchorX, ground.anchorY = 0, 1
	-- ground.x = 0
	-- ground.y = display.contentHeight
	-- print("display.contentWidth : " .. display.contentWidth)
	-- print("display.contentHeight : " .. display.contentHeight)

	local halfWidth = display.contentWidth * 0.5
	print("ground : " ..ground.x .. ", " .. ground.y .. " - " .. ground.width .. ", " .. ground.height)
	local groundshape = { -halfWidth, 25, halfWidth * 3, 25, halfWidth * 3, 10, -halfWidth, 10}
	ground.myName = "ground"
	physics.addBody(ground, "static", { friction=0.3, shape=groundshape } )

	-- sky limit
	local skyWall = display.newRect ( 0, -20, display.contentWidth, 10)
	skyWall.anchorX, skyWall.anchorY = 0, 1
	physics.addBody(skyWall, "static")

	sceneGroup:insert( heliGroup )

	-- explosionSound = audio.loadSound("resources/sounds/explosion1.wav")
	helicopterSound = audio.loadSound("resources/sounds/helicopter1.wav")
	bg1Sound = audio.loadSound("resources/sounds/music2.wav")

end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		Runtime:addEventListener("enterFrame", update)

		createNewStone()

		changeHellicopter( HELI_FLY )

		audio.play(bg1Sound, {loops=-1})

		Runtime:addEventListener("collision", onCollision)

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		physics.start()

		stoneTimerId = timer.performWithDelay( 1, scrollStone, -1 )

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

