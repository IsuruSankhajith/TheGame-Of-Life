-----------------------------------------------------------------------------------------
--
-- instruction
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
    local sceneGroup = self.view

    -- display a background image
    local background = display.newImageRect( "game1.jpg", display.actualContentWidth, display.actualContentHeight )
    background.anchorX = 0
    background.anchorY = 0
    background.x = 0 + display.screenOriginX 
    background.y = 0 + display.screenOriginY
    
    -- create a widget button (which will load level1.lua on release)
    playBtn = widget.newButton{
        label = "Start",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.2, 0.7, 0.2, 1}, over={0.2, 0.7, 0.2, 0.5} },  -- Green color
        width = 100, height = 40,
        onRelease = onPlayBtnRelease  -- event listener function
    }

    -- Calculate the button's position to place it at the bottom
    playBtn.x = display.contentCenterX
    playBtn.y = display.contentHeight - playBtn.contentHeight / 2 - 20  -- Adjust the 20 as needed to add some spacing

    -- all display objects must be inserted into group
    sceneGroup:insert( background )
    sceneGroup:insert( playBtn )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
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
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
