local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")

-- Define feedback form elements
local feedbackForm
local feedbackTextField
local submitButton

local function onBackBtnRelease()
    composer.gotoScene("feedback", "fade", 500)
    return true -- indicates successful touch
end

local function onSubmitButtonRelease()
    local feedbackText = feedbackTextField.text
    -- Handle the submission of feedbackText, e.g., send it to a server or save it locally
    print("Feedback submitted: " .. feedbackText)
    return true -- indicates successful touch
end

function scene:create(event)
    local sceneGroup = self.view
    physics.start()
    physics.pause()
    
    local background = display.newRect(display.screenOriginX, display.screenOriginY, display.actualContentWidth, display.actualContentHeight)
    background.anchorX, background.anchorY = 0, 0
    local gradient = {
        type = "gradient",
        color1 = {0.2, 0.4, 0.8},
        color2 = {0.1, 0.2, 0.4},
        direction = "down"
    }
    background:setFillColor(gradient)
    
    local crate = display.newImageRect("crate.png", 90, 90)
    crate.x, crate.y, crate.rotation = 160, -100, 15
    physics.addBody(crate, {density = 1.0, friction = 0.3, bounce = 0.3})
    
    local grass = display.newRect(display.screenOriginX, display.actualContentHeight - 20, display.actualContentWidth, 20)
    grass.anchorX, grass.anchorY = 0, 1
    grass:setFillColor(0.2, 0.7, 0.2)
    
    -- Create a feedback form with a text field and a submit button
    feedbackForm = display.newGroup()
    
    feedbackTextField = native.newTextField(display.contentCenterX, display.contentCenterY - 50, 240, 40)
    feedbackTextField.placeholder = "Enter your feedback"
    
    submitButton = display.newRect(display.contentCenterX, display.contentCenterY + 50, 120, 40)
    submitButton:setFillColor(0.1, 0.6, 0.3)
    submitButton:addEventListener("tap", onSubmitButtonRelease)
    
    local submitButtonText = display.newText({
        text = "Submit",
        x = submitButton.x,
        y = submitButton.y,
        font = native.systemFont,
        fontSize = 18,
    })
    
    feedbackForm:insert(feedbackTextField)
    feedbackForm:insert(submitButton)
    feedbackForm:insert(submitButtonText)
    
    sceneGroup:insert(background)
    sceneGroup:insert(grass)
    sceneGroup:insert(crate)
    sceneGroup:insert(feedbackForm)
end

scene:addEventListener("create", scene)

return scene
