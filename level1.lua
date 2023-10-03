local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")
local widget = require "widget"
local json = require("json")
local startGameBtn
local isGameStarted = false

-- Define the scene-specific variables
local pauseResumeBtn = nil
local isRunning = true
local randomSeedButton
local pauseResumeBtn
local randomStartButton
local userInputButton
local isRandomStart = true
local gridSize, pointRadius, circles, grid, nextGrid = 100, 2, {}, {}, {}
local aliveColor = {0, 255, 0}
local deadColor = {255, 0, 0}
local backgroundColor = {0, 0, 0}
local startX = (display.contentWidth - gridSize * pointRadius) / 2
local startY = (display.contentHeight - gridSize * pointRadius) / 6

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
    -- Remove the displayed circles
    for i, circle in ipairs(circles) do
        circle:removeSelf()
    end
    circles = {}

    -- Go to the "menu" scene
    composer.gotoScene("menu", "fade", 500)

    return true -- indicates successful touch
end



---------------------------------------------------------------------------------------------------------------
local function createGrid()
    for i = 1, gridSize do
        grid[i], nextGrid[i] = {}, {}
        for j = 1, gridSize do
            grid[i][j] = math.random(2) == 1
        end
    end
end


------------------------------------------------------------------------------------------------------

local function onStartGameBtnRelease()
    -- Start the game logic here
    if not isGameStarted then
        isGameStarted = true
        createGrid()
        displayPoints()
        Runtime:addEventListener("enterFrame", onEnterFrame)
        setupMouseListeners()
        startGameBtn.isVisible = false  -- Hide the button after starting the game
    end
end
--------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
local function onToggleStartState(event)
        isRandomStart = not isRandomStart  -- Toggle the start state
        if isRandomStart then
            -- Set the grid to a random start state
            createGrid()
        else
            -- Implement user-input start state logic here
            -- You can prompt the user for input and update the grid accordingly
            -- Example: Implement a touch event listener on the grid to allow the user to draw their own start state
        end
    end

-----------------------------------------------------------------------------------------------------------------

    local function onUserInput(event)
        if event.phase == "began" or event.phase == "moved" then
            local x, y = event.x, event.y
            local gridX = math.floor((x - startX) / pointRadius) + 1
            local gridY = math.floor((y - startY) / pointRadius) + 1

            -- Check if the grid coordinates are valid
            if gridX >= 1 and gridX <= gridSize and gridY >= 1 and gridY <= gridSize then
                -- Toggle the state of the cell at the grid coordinates
                grid[gridX][gridY] = not grid[gridX][gridY]

                -- Update the display to reflect the new cell state
                local circle = display.newCircle(x, y, pointRadius)
                circle:setFillColor(grid[gridX][gridY] and unpack(aliveColor) or unpack(deadColor))
                circles[#circles + 1] = circle
            end
        end
    end

    scene:addEventListener("touch", onUserInput)

----------------------------------------------------------------------------------------------------------------
local function createRandomInitialState()
    -- Implement logic to generate a random initial state for your grid
    for i = 1, gridSize do
        for j = 1, gridSize do
            grid[i][j] = math.random(2) == 1
        end
    end
end

local function displayPoints()
    display.setDefault("background", unpack(backgroundColor))
    for i = 1, gridSize do
        for j = 1, gridSize do
            local x, y = startX + (i - 1) * pointRadius, startY + (j - 1) * pointRadius
            local circle = display.newCircle(x, y, pointRadius)
            circle:setFillColor(grid[i][j] and unpack(aliveColor) or unpack(deadColor))
            circles[#circles + 1] = circle
        end
    end
end
------------------------------------------------------------------------------------------------------------

local function onRandomSeedButtonRelease()
    createRandomInitialState() -- Call a function to generate a random initial state
    displayPoints() -- Update the display to reflect the new initial state
end

-- Add a touch event listener to the scene to handle user input
scene:addEventListener("touch", onUserInput)

-------------------------------------------------------------------------------------------------------------
local function countNeighbors(x, y)
    local count, dx, dy = 0, {-1, 0, 1, -1, 1, -1, 0, 1}, {-1, -1, -1, 0, 0, 1, 1, 1}
    for i = 1, 8 do
        local newX, newY = x + dx[i], y + dy[i]
        if newX >= 1 and newX <= gridSize and newY >= 1 and newY <= gridSize and grid[newX][newY] then
            count = count + 1
        end
    end
    return count
end
------------------------------------------------------------------------------------------------------------

local function calculateNextGeneration()
    for i = 1, gridSize do
        for j = 1, gridSize do
            local neighbors = countNeighbors(i, j)
            nextGrid[i][j] = grid[i][j] and (neighbors == 2 or neighbors == 3) or (not grid[i][j] and neighbors == 3)
        end
    end
    grid, nextGrid = nextGrid, grid
end
------------------------------------------------------------------------------------------------------------

local function displayPoints()
    display.setDefault("background", unpack(backgroundColor))
    for i = 1, gridSize do
        for j = 1, gridSize do
            local x, y = startX + (i - 1) * pointRadius, startY + (j - 1) * pointRadius
            local circle = display.newCircle(x, y, pointRadius)
            circle:setFillColor(grid[i][j] and unpack(aliveColor) or unpack(deadColor))
            circles[#circles + 1] = circle
        end
    end
end
-----------------------------------------------------------------------------------------------------------
local function onEnterFrame(event)
    if isRunning then  -- Only update the grid if the simulation is running
        local success, errorInfo = pcall(function()
            calculateNextGeneration()
            for i, circle in ipairs(circles) do
                local x, y = circle.x, circle.y
                local gridX, gridY = math.floor((x - startX) / pointRadius) + 1, math.floor((y - startY) / pointRadius) + 1
                circle:setFillColor(grid[gridX][gridY] and unpack(aliveColor) or unpack(deadColor))
            end
        end)

        if not success then
            print("Error in onEnterFrame:", errorInfo)
        end
    end
end
--------------------------------------------------------------------------------------------------------------

local function onUserInput(event)
    if event.phase == "began" or event.phase == "moved" then
        local x, y = event.x, event.y
        local gridX = math.floor((x - startX) / pointRadius) + 1
        local gridY = math.floor((y - startY) / pointRadius) + 1

        -- Check if the grid coordinates are valid
        if gridX >= 1 and gridX <= gridSize and gridY >= 1 and gridY <= gridSize then
            -- Toggle the state of the cell at the grid coordinates
            grid[gridX][gridY] = not grid[gridX][gridY]

            -- Update the display to reflect the new cell state
            local circle = display.newCircle(x, y, pointRadius)
            circle:setFillColor(grid[gridX][gridY] and unpack(aliveColor) or unpack(deadColor))
            circles[#circles + 1] = circle
        end
    end
end
--------------------------------------------------------------------------------------------------------------
local function onPauseResumeBtnRelease()
    print("Pause/Resume button pressed")  -- Debugging output
    if isRunning then
        -- Pause the simulation
        isRunning = false
        pauseResumeBtn:setLabel("Resume")  -- Change the button label
        print("Simulation paused")
    else
        -- Resume the simulation
        isRunning = true
        pauseResumeBtn:setLabel("Pause")  -- Change the button label
        print("Simulation resumed")
    end
end



   -- Create the restart button
local function onRestartBtnRelease()
        -- Reset the simulation to its initial state
    createGrid()  -- You may need to adjust this function to properly reset your simulation
    displayPoints()  -- Update the display
    isRunning = true  -- Ensure the simulation is running
    pauseResumeBtn:setLabel("Pause")  -- Reset the pause/resume button label
end

--------------------------------------------------------------------------------------------------------------
local function onStopBtnRelease()
    -- Reset the simulation to its initial state
    createGrid()
    displayPoints()
    isRunning = false -- Pause the simulation
    pauseResumeBtn:setLabel("Resume")  -- Change the "Pause/Resume" button label if needed
    print("Simulation stopped and reset")
end
-------------------------------------------------------------------------------------------------------------
local function restoreState()
    local path = system.pathForFile("gameState.json", system.DocumentsDirectory)
    local file = io.open(path, "r")
    if file then
        local jsonString = file:read("*a")
        io.close(file)
        local state = json.decode(jsonString)
        if state and state.grid and state.nextGrid then
            grid = state.grid
            nextGrid = state.nextGrid
            displayPoints()
        end
    end
end
local function saveState()
    local state = { grid = grid, nextGrid = nextGrid }
    local jsonString = json.encode(state)
    local path = system.pathForFile("gameState.json", system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        file:write(jsonString)
        io.close(file)
    end
end
local function onSaveBtnRelease()
    -- Save the current state
    saveState()
    -- Display a message or perform any other action you want after saving.
end

local function onRestoreBtnRelease()
    -- Restore the saved state
    restoreState()
    -- Display a message or perform any other action you want after restoring.
end
--------------------------------------------------------------------------------------------------------------
local function onSliderChange(event)
    local value = event.value
    local delay = 1000 / value  -- Calculate the delay based on the value (value is the iterations per second)
    -- Remove the previous timer, if any
    if gameTimer then
        timer.cancel(gameTimer)
    end
    -- Start a new timer with the updated delay
    gameTimer = timer.performWithDelay(delay, onEnterFrame, 0)
end

local function startGameLoop(delay)
    gameTimer = timer.performWithDelay(delay, onEnterFrame, 0)
end

local function increaseSpeed()
    local currentValue = slider:getValue()
    local newValue = currentValue + 1
    slider:setValue(newValue)
    onSliderChange({ value = newValue })  -- Call the slider change handler to update the game speed
end

local function decreaseSpeed()
    local currentValue = slider:getValue()
    if currentValue > 1 then
        local newValue = currentValue - 1
        slider:setValue(newValue)
        onSliderChange({ value = newValue })  -- Call the slider change handler to update the game speed
    end
end

---------------------------------------------------------------------------------------------------------------

local function main()
    createGrid()
    displayPoints()
    Runtime:addEventListener("enterFrame", onEnterFrame)
    physics.start()
    physics.pause()
    startGameLoop(1000)
    restoreState()
end

--------------------------------------------------------------------------------------------------------------

function scene:create(event)
    local sceneGroup = self.view
    physics.start()
    physics.pause()
    if gameTimer then
        timer.cancel(gameTimer)
    end
    local background = display.newRect(display.screenOriginX, display.screenOriginY, display.actualContentWidth, display.actualContentHeight)
    background.anchorX, background.anchorY = 0, 0
    local gradient = {
        type = "gradient",
        color1 = {0.2, 0.4, 0.8},
        color2 = {0.1, 0.2, 0.4},
        direction = "down"
    }

-------------------------------------------------------------------------------------------------------------
     -- Add the title text with a custom font and italics
    local titleText = display.newText({
        text = "Hi there! Let's have a blast!",
        x = 160,  -- Adjust this value to move it to the left
        y = 20,
        fontSize = 20,
        
        align = "center",  -- Center alignment
        width = 300,  -- Adjust the width if needed
    })

    titleText:setFillColor(1, 1, 1)  -- Set text color (white in this example)
    titleText.anchorX = 0.5  -- Center the text horizontally
-----------------------------------------------------------------------------------------------------------

    randomStartButton = widget.newButton{
        label = "Random Start",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix
        width = 110, height = 40,
        onRelease = onToggleStartState  -- Event listener function
    
    }

    randomStartButton.x = display.contentCenterX - 110  -- Adjust the position as needed
    randomStartButton.y = display.contentHeight - randomStartButton.contentHeight / 2 - 150

-------------------------------------------------------------------------------------------------------------

-- Add the user input button
    userInputButton = widget.newButton{
        label = "User Input",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix
        width = 100, height = 40,
            onRelease = function()
                -- Implement user input logic here
                -- You can prompt the user for input and update the grid accordingly
                -- For example, you can display a dialog box or allow the user to draw on the grid
            end
    }

    userInputButton.x = display.contentCenterX +4
    userInputButton.y = display.contentHeight - userInputButton.contentHeight / 2 - 150
--Back--------------------------------------------------------------------------------------------------------------
    playBtn = widget.newButton{
        label = "Back",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix
        width = 100, height = 40,
        onRelease = onPlayBtnRelease  -- event listener function
    }

    playBtn.x = display.contentCenterX + 110

    playBtn.y = display.contentHeight - playBtn.contentHeight / 2 - 150 

----------------------------------------------------------------------------------------------------------------
    randomSeedButton = widget.newButton{
        label = "Random Seed",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix


        width = 115, height = 40,
        onRelease = onRandomSeedButtonRelease
    }

    randomSeedButton.x = display.contentCenterX + 110
    randomSeedButton.y = display.contentHeight - randomSeedButton.contentHeight / 2 - 100

---------------------------------------------------------------------------------------------------------------
pauseResumeBtn = widget.newButton{
        label = "Pause",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix
        width = 100,
        height = 40,
        onRelease = onPauseResumeBtnRelease
    }

    pauseResumeBtn.x = display.contentCenterX - 114
    pauseResumeBtn.y = display.contentHeight - pauseResumeBtn.contentHeight / 2 - 100

 

    local restartBtn = widget.newButton{
        label = "Restart",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix


        width = 100,
        height = 40,
        onRelease = onRestartBtnRelease
    }

    restartBtn.x = display.contentCenterX - 5
    restartBtn.y = display.contentHeight - restartBtn.contentHeight / 2 - 100

---------------------------------------------------------------------------------------------------------------
    local stopBtn = widget.newButton{
        label = "Stop",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.7, 0.2, 0.2, 1}, over={0.7, 0.2, 0.2, 0.5} },  -- Red color
        width = 100, height = 40,
        onRelease = onStopBtnRelease
    }

    stopBtn.x = display.contentCenterX + 110
    stopBtn.y = display.contentHeight - stopBtn.contentHeight / 2 - 55

---------------------------------------------------------------------------------------------------------------
local saveButton = widget.newButton{
        label = "Save",
        labelColor = { default = { 1.0 }, over = { 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix
        width = 100, height = 40,
        onRelease = onSaveBtnRelease  -- Define the save button event handler
    }

    saveButton.x = display.contentCenterX - 110
    saveButton.y = display.contentHeight - saveButton.contentHeight / 2 - 55
-----------------------------------------------------------------------------------------------------------------

    local restoreButton = widget.newButton{
        label = "Restore",
        labelColor = { default = { 1.0 }, over = { 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix
        width = 100, height = 40,
        onRelease = onRestoreBtnRelease  -- Define the restore button event handler
    }

    restoreButton.x = display.contentCenterX -1
    restoreButton.y = display.contentHeight - restoreButton.contentHeight / 2 - 55
---------------------------------------------------------------------------------------------------------------

     -- Create the slider
    slider = widget.newSlider {
        left = 50,
        top = display.contentHeight - 50,
        width = 200,
        listener = onSliderChange,
        value = 1,  -- Initial value (1 iteration per second)
    }

    -- Define increaseSpeedButton and decreaseSpeedButton here
    local increaseSpeedButton = widget.newButton {
        label = "+",
        onRelease = increaseSpeed,
        shape = "circle",
        radius = 20,
        x = display.contentCenterX - 145,
        y = display.contentHeight - 30,
        fontSize = 24,
    }

    local decreaseSpeedButton = widget.newButton {
        label = "-",
        onRelease = decreaseSpeed,
        shape = "circle",
        radius = 20,
        x = display.contentCenterX + 115,
        y = display.contentHeight - 30,
        fontSize = 24,
    }

---------------------------------------------------------------------------------------------------------------
    
    background:setFillColor(gradient)
    local crate = display.newImageRect("crate.png", 90, 90)
    crate.x, crate.y, crate.rotation = 160, -100, 15
    physics.addBody(crate, {density = 1.0, friction = 0.3, bounce = 0.3})
    local grass = display.newRect(display.screenOriginX, display.actualContentHeight - 20, display.actualContentWidth, 20)
    grass.anchorX, grass.anchorY = 0, 1
    grass:setFillColor(0.2, 0.7, 0.2)
    sceneGroup:insert(background)
    sceneGroup:insert(grass)
    sceneGroup:insert(crate)
    sceneGroup:insert( playBtn )
    sceneGroup:insert(randomStartButton)
    sceneGroup:insert(userInputButton)
    sceneGroup:insert(randomSeedButton)
    sceneGroup:insert(pauseResumeBtn)
    sceneGroup:insert(restartBtn)
    sceneGroup:insert(stopBtn)
    sceneGroup:insert(saveButton)
    sceneGroup:insert(restoreButton)
    sceneGroup:insert(increaseSpeedButton)
    sceneGroup:insert(decreaseSpeedButton)
    sceneGroup:insert(slider)
    sceneGroup:insert(titleText)
    

    main()
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    physics.start()
    physics.pause()
    
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
        playBtn:removeSelf()    -- widgets must be manually removed
        playBtn = nil
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
