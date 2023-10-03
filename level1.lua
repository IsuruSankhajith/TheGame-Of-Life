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
----------------------------------------------------------------------------------------------------------

-- Define a local function named onfbackBtnRelease()
local function onfbackBtnRelease()
    
    -- go to level1.lua scene
    composer.gotoScene( "feedback", "fade", 500 )
    
    return true -- indicates successful touch
end


---------------------------------------------------------------------------------------------------------------

local function createGrid()
    -- Initialize two empty tables, grid and nextGrid, which will hold the grid data
    for i = 1, gridSize do
        grid[i], nextGrid[i] = {}, {}
        for j = 1, gridSize do
            -- Fill the grid with random boolean values (true or false)
            grid[i][j] = math.random(2) == 1
        end
    end
end


------------------------------------------------------------------------------------------------------

local function onStartGameBtnRelease()
    -- Start the game logic here
    if not isGameStarted then
        isGameStarted = true
        createGrid()  -- Generate the game grid
        displayPoints()  -- Display game points (not shown in the provided code)
        Runtime:addEventListener("enterFrame", onEnterFrame)
        setupMouseListeners() --- Set up mouse listeners (not shown in the provided code)
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
----This function is responsible for generating a random initial state for the grid.
---- It appears to fill the grid table with random boolean values, 
---- which may represent the initial state of cells in a grid.

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
-- Define a local function named 'onRandomSeedButtonRelease'

local function onRandomSeedButtonRelease()
    createRandomInitialState() -- Call a function to generate a random initial state
    displayPoints() -- Update the display to reflect the new initial state
end

-- Add a touch event listener to the scene to handle user input
scene:addEventListener("touch", onUserInput)

-------------------------------------------------------------------------------------------------------------
-- Define a function named 'countNeighbors' that takes two parameters: 'x' and 'y'
local function countNeighbors(x, y)
    local count, dx, dy = 0, {-1, 0, 1, -1, 1, -1, 0, 1}, {-1, -1, -1, 0, 0, 1, 1, 1}

     -- Loop through the eight possible neighbor positions
    for i = 1, 8 do
        local newX, newY = x + dx[i], y + dy[i]
        if newX >= 1 and newX <= gridSize and newY >= 1 and newY <= gridSize and grid[newX][newY] then
            count = count + 1
        end
    end
    -- Return the final count of neighboring cells
    return count
end
------------------------------------------------------------------------------------------------------------
-- Define a function named 'calculateNextGeneration'
local function calculateNextGeneration()
    for i = 1, gridSize do
        for j = 1, gridSize do
            -- Calculate the number of neighbors for the cell at (i, j)
            local neighbors = countNeighbors(i, j)

             -- Apply the rules of Conway's Game of Life to update the cell's state
            nextGrid[i][j] = grid[i][j] and (neighbors == 2 or neighbors == 3) or (not grid[i][j] and neighbors == 3)
        end
    end
    -- Swap the 'grid' and 'nextGrid' references to update the main grid with the new generation
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

-- Define a function named 'onEnterFrame' that takes an 'event' parameter
local function onEnterFrame(event)
    -- Check if the simulation is running (controlled by the 'isRunning' variable)
    if isRunning then
        -- Use pcall to catch and handle errors during execution
        local success, errorInfo = pcall(function()
            -- Calculate the next generation of the grid
            calculateNextGeneration()

            -- Iterate over the 'circles' table to update their fill colors
            for i, circle in ipairs(circles) do
                local x, y = circle.x, circle.y

                -- Calculate the corresponding grid coordinates for the circle's position
                local gridX, gridY = math.floor((x - startX) / pointRadius) + 1, math.floor((y - startY) / pointRadius) + 1

                -- Set the fill color of the circle based on the state of the corresponding grid cell
                circle:setFillColor(grid[gridX][gridY] and unpack(aliveColor) or unpack(deadColor))
            end
        end)

        -- Check for and handle any errors that occurred during execution
        if not success then
            print("Error in onEnterFrame:", errorInfo)
        end
    end
end

--------------------------------------------------------------------------------------------------------------

-- Define a function named 'onUserInput' that takes an 'event' parameter
local function onUserInput(event)
    -- Check if the input event is in the "began" or "moved" phase (e.g., touch or mouse interaction)
    if event.phase == "began" or event.phase == "moved" then
        -- Extract the x and y coordinates of the input event
        local x, y = event.x, event.y

        -- Calculate the corresponding grid coordinates for the input position
        local gridX = math.floor((x - startX) / pointRadius) + 1
        local gridY = math.floor((y - startY) / pointRadius) + 1

        -- Check if the calculated grid coordinates are within the valid grid boundaries
        if gridX >= 1 and gridX <= gridSize and gridY >= 1 and gridY <= gridSize then
            -- Toggle the state of the cell at the grid coordinates (alive to dead, or vice versa)
            grid[gridX][gridY] = not grid[gridX][gridY]

            -- Update the display to reflect the new cell state
            local circle = display.newCircle(x, y, pointRadius)
            circle:setFillColor(grid[gridX][gridY] and unpack(aliveColor) or unpack(deadColor))

            -- Add the newly created circle to the 'circles' table (assuming 'circles' is defined elsewhere)
            circles[#circles + 1] = circle
        end
    end
end

--------------------------------------------------------------------------------------------------------------
-- Define a function named 'onPauseResumeBtnRelease'
local function onPauseResumeBtnRelease()
    print("Pause/Resume button pressed")  -- Debugging output

    -- Check if the simulation is currently running
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
-----------Animations----------------------------------------------------------------------------------------------------

local function displayPointsWithAnimation()
    local function fadeIn(circle, delay)
        transition.to(circle, {
            time = 1000,  -- Adjust the duration as needed
            alpha = 1,
            delay = delay,
            transition = easing.outQuad
        })
    end

display.setDefault("background", unpack(backgroundColor))
    for i = 1, gridSize do
        for j = 1, gridSize do
            local x, y = startX + (i - 1) * pointRadius, startY + (j - 1) * pointRadius
            local circle = display.newCircle(x, y, pointRadius)
            circle:setFillColor(grid[i][j] and unpack(aliveColor) or unpack(deadColor))
            circle.alpha = 0  -- Make the circle invisible initially
            circles[#circles + 1] = circle
            fadeIn(circle, (i + j) * 10)  -- Delay the fade-in animation based on position
        end
    end
end
---------------------------------------------------------------------------------------------------------------
-- Define a function named 'buttonPressEffect' that takes an 'event' parameter
local function buttonPressEffect(event)
    local button = event.target  -- Get the button that triggered the event

    -- Check the phase of the touch event (began, ended, or cancelled)
    if event.phase == "began" then
        -- Scale the button down to 95% of its size when the touch begins
        transition.to(button, { xScale = 0.95, yScale = 0.95, time = 100 })  -- Transition animation
    elseif event.phase == "ended" or event.phase == "cancelled" then
        -- Return the button to its original size when the touch is released or canceled
        transition.to(button, { xScale = 1, yScale = 1, time = 100 })  -- Transition animation
    end

    return true  -- Return 'true' to indicate that the touch event has been handled
end

---------------------------------------------------------------------------------------------------------------

local function main()
    createGrid()
    displayPoints()
    displayPointsWithAnimation()
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
    randomStartButton.y = display.contentHeight - randomStartButton.contentHeight / 2 - 180

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
    userInputButton.y = display.contentHeight - userInputButton.contentHeight / 2 - 180
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
    playBtn.y = display.contentHeight - playBtn.contentHeight / 2 - 180 


    playBtn:addEventListener("touch", buttonPressEffect)

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
    randomSeedButton.y = display.contentHeight - randomSeedButton.contentHeight / 2 - 130

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
    pauseResumeBtn.y = display.contentHeight - pauseResumeBtn.contentHeight / 2 - 130

 

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
    restartBtn.y = display.contentHeight - restartBtn.contentHeight / 2 - 130

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
    stopBtn.y = display.contentHeight - stopBtn.contentHeight / 2 - 80

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
    saveButton.y = display.contentHeight - saveButton.contentHeight / 2 - 80
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
    restoreButton.y = display.contentHeight - restoreButton.contentHeight / 2 - 80
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
--------------------------------------------------------------------------------------------------------------
    fbackBtn = widget.newButton{
        label = "feedback",
        labelColor = { default={ 1.0 }, over={ 0.5 } },
        shape = "roundedRect",
        cornerRadius = 10,
        fillColor = { default={0.5, 0.5, 0, 1}, over={0.5, 0.5, 0, 0.5} },  -- Yellow and black mix
        width = 200, height = 25,
        onRelease = onfbackBtnRelease  -- event listener function
    }

    fbackBtn.x = display.contentCenterX
    fbackBtn.y = display.contentHeight - fbackBtn.contentHeight / 2 - 45


    fbackBtn:addEventListener("touch", buttonPressEffect)

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
    sceneGroup:insert(fbackBtn)

    

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
