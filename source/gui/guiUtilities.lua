local flower = flower
local widget = widget

local TOWERS = require "assets/towers/towers"

local statusUI = nil
local chatLogTextbox = nil

local fontSize = 12

function buildUI(gameMode, view, parentObj, saveGrid, loadGrid, setColor)
    local buttonSize = {flower.viewWidth/6, 39}
    
    saveButton = widget.Button {
        size = buttonSize,
        text = "Save State",
        parent = view,
        onClick = function()
            if gameMode == "MapEditor" then
                saveGrid(saveFile)
            end
        end,
        enabled = gameMode == "MapEditor" and true or false,
    }
    
    loadButton = widget.Button {
        size = buttonSize,
        text = "Load State",
        parent = view,
        onClick = function()
            loadGrid()
            -- TODO: implement
        end,
        enabled = false,
    }
    
    if parentObj.paused then
        pauseButton = widget.Button {
            size = buttonSize,
            text = "Pause Wave",
            parent = view,
            onClick = function()
                if parentObj:paused() then
                    parentObj:paused(false)
                    pauseButton:setText("Pause Wave")
                else
                    parentObj:paused(true)
                    pauseButton:setText("Start Wave")
                end
            end,
            enabled = true,
        }
    end
    
    statusUI = widget.TextBox {
        size = {buttonSize[1], 50},
        text =  parentObj:generateStatus(),
        textSize = fontSize,
        parent = view,
    }
    
    if gameMode == "SinglePlayer" then
        local function trySelect(parentObj, child)
            local towerSelected = parentObj:getSelectedTower()
            if towerSelected and towerSelected.type.id == child.id then
                parentObj:selectTower(nil)
            else
                parentObj:selectTower(Tower(child))
            end
        end
        
        towerGroup = widget.UIGroup {
            layout = widget.BoxLayout {
                direction = "horizotal", --Yes, this has to be mispelled   
            },
            parent = view,
        }
        
        for i, item in ipairs(TOWERS) do
            tower = widget.SheetButton{
                size = buttonSize,
                normalTexture = item.texture,
                onClick = function() 
                    trySelect(parentObj, item)
                end,
                parent = towerGroup,
            }
        end
        
        itemInfoUI = widget.TextBox {
            size = {buttonSize[1], 70},
            text =  parentObj:generateItemInfo(),
            textSize = fontSize,
            parent = view,
        }
        
    end
    
    if gameMode == "MultiPlayer" then
        
        chatLogTextbox = widget.TextBox {
            size = {buttonSize[1], 210},
            text =  parentObj:generateItemInfo(),--"Info UI",--parentObj:generateStatus(),
            textSize = fontSize,
            parent = view,
        }
        
        textInput = widget.TextInput {chatLogTextbox:getBottom()},
            size = {buttonSize[1], 70},
            text =  "...",--"Info UI",--parentObj:generateStatus(),
            textSize = fontSize,
            parent = view,
        }
        submitButton = widget.Button {
            size = buttonSize,
            text = "Submit",
            parent = view,
            onClick = function()
                if gameMode == "MultiPlayer" then
                    local inputText = textInput:getText()
                    if #inputText > 0 then
                        parentObj:submitText(inputText)
                        textInput:setText("")
                    end
                end
                -- TODO: implement
            end,
            enabled = gameMode == "MultiPlayer" and true or false,
        }
        
    end
    
    if gameMode == "MapEditor" then
        
        towerGroup = widget.UIGroup {
            layout = widget.BoxLayout {
                direction = "horizotal", --Yes, this has to be mispelled   
            },
            parent = view,
        }
        
        for i, item in ipairs(TOWERS) do
            tower = widget.SheetButton{
                size = buttonSize,
                normalTexture = item.texture,
                onClick = function() 
                    setColor(i)
                    statusUI:setText( parentObj:generateStatus()) 
                end,
                parent = towerGroup,
            }
        end
        
        nonTowerGroup = widget.UIGroup {
            layout = widget.BoxLayout {
                direction = "horizotal",
            },
            parent = view,
        }
        
        blackSpace = widget.SheetButton {
            size = buttonSize,
            normalTexture = "black_space.png",
            onClick = function()
                setColor(5)
                statusUI:setText(parentObj:generateStatus())
            end,
            parent = nonTowerGroup,
        }
    
        brownSpace = widget.SheetButton {
            size = buttonSize,
            normalTexture = "brown_space.png",
            onClick = function()
                setColor(6)
                statusUI:setText(parentObj:generateStatus())
            end,
            parent = nonTowerGroup,
        }
        
        voidSpace = widget.SheetButton {
            size = buttonSize,
            normalTexture = "void_space.png",
            onClick = function()
                setColor(7)
                statusUI:setText(parentObj:generateStatus())
            end,
            parent = nonTowerGroup,
        }
    
        toggleModeButton = widget.Button {
            size = buttonSize,
            text = "Toggle Mode",
            parent = view,
            onClick = function()
                
                -- Loop over all algorithms
                parentObj.currentAlgorithm = (parentObj.currentAlgorithm + 1)
                
                if parentObj.currentAlgorithm > #parentObj.algorithms then
                    parentObj.currentAlgorithm = 1
                end
                
                statusUI:setText(parentObj:generateStatus())
            end,
        }
    
        clearButton = widget.Button {
            size = buttonSize,
            text = "Clear Grid",
            parent = view,
            onClick = function()
                parentObj.grid.grid:fill(5)
            end,
        }
    end

end

function updateStatusText(status)
    statusUI:setText(status)
end

function updateItemText(text)
    itemInfoUI:setText(text)
end

function updateChatText(text)
    chatLogTextbox:setText(text)
end

function updatePauseButton(paused)
    pauseButton:setText((paused and "Pause" or "Start") .. " Wave")
end

function generateMsgBox(position, size, msg, parentView)
    return widget.MsgBox {
        size = size,
        pos = position,
        text = msg,
        parent = parentView,
        priority = 100,
    }
end

function createChildView(animation, selectedData)
    return widget.UIView {
        scene = nil,
        layout = widget.BoxLayout {
            align = {"right", "top"},
        },
        children = {{
            widget.Button {
                --pos = {flower.viewWidth - flower.viewWidth/6, 0},
                size = {flower.viewWidth/6, 39},
                text = "Back",
                onClick = function()
                    flower.closeScene({animation = animation and animation or "fade"})
                    selectedData = nil
                end,
            },
        }},
    }
end

function _resizeComponents(view)
--    local buttonSize = {flower.viewWidth/6, 39}
--    local xPosition = flower.viewWidth - flower.viewWidth/6

--    timesRepeated = 0
    
--    prevY = -1
--    prevItem = nil
--   for i, item in ipairs(view.children) do
--        if (item:getTop() == prevY) then--If it has the same Y as the prev elem
--            timesRepeated = timesRepeated + 1
--            item:setPos(xPosition+(item:getWidth()*timesRepeated), prevItem:getTop())
--        else
--            timesRepeated = 0
--            item:setPos(xPosition, item:getTop())
--            item:setSize(buttonSize[1], item:getHeight())
--        end
          
--        prevY = item:getTop()
--        prevItem = item
--    end 
    view:updateViewport(0, 0, flower.viewWidth, flower.viewHeight)
end


