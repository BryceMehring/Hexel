local flower = flower
local widget = widget

local TOWERS = require "assets/towers/towers"

local statusUI = nil
local itemInfoUI = nil

local fontSize = 12

function buildUI(gameMode, view, parentObj, saveGrid, loadGrid, setColor)
    local buttonSize = {flower.viewWidth/6, 39}
    local xPosition = flower.viewWidth - flower.viewWidth/6
    
    saveButton = widget.Button {
        pos = {xPosition, 39},
        size = buttonSize,
        text = "Save State",
        parent = view,
        onClick = function()
            if gameMode == "MapEditor" then
                saveGrid(saveFile)
            end
            -- TODO: implement
        end,
        enabled = gameMode == "MapEditor" and true or false,
    }
    
    loadButton = widget.Button {
        pos = {xPosition,  saveButton:getBottom()},
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
            pos = {xPosition,  loadButton:getBottom()},
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
        pos = {xPosition,  pauseButton and pauseButton:getBottom() or loadButton:getBottom()},
        size = {buttonSize[1], 50},
        text =  parentObj:generateStatus(),
        textSize = fontSize,
        parent = view,
    }
    
    if gameMode == "SinglePlayer" then
        
        -- TODO: create a method in the game that sets the current tower
        local function trySelect(parentObj, child)
            local towerSelected = parentObj:selectedTower()
            if towerSelected and towerSelected.id == child.id then
                parentObj:selectedTower(nil)
            else
                parentObj:selectedTower(child)
            end
        end
        
        local lastElem = nil
        local listX = xPosition
        for i, item in ipairs(TOWERS) do
            tower = widget.SheetButton{
                pos = {listX,  statusUI:getBottom()},
                size = buttonSize,
                normalTexture = item.texture,
                onClick = function() 
                    trySelect(parentObj, item)
                end,
                parent = view,
            }
            listX = tower:getRight()
            lastElem = tower:getBottom()
        end
        
        itemInfoUI = widget.TextBox {
            pos = {xPosition,  lastElem and lastElem or statusUI:getBottom()},
            size = {buttonSize[1], 70},
            text =  parentObj:generateItemInfo(),--"Info UI",--parentObj:generateStatus(),
            textSize = fontSize,
            parent = view,
        }
        
    end
    
    if gameMode == "MapEditor" then
        
        yellowTower = widget.SheetButton {
            pos = {xPosition,  statusUI:getBottom()},
            size = buttonSize,
            normalTexture = "yellow_tower.png",
            onClick = function()
                setColor(1)
                --parentObj.currentColor = 1 -- used in mapEditor
                statusUI:setText( parentObj:generateStatus()) 
            end,
            parent = view,
        }
        
        redTower = widget.SheetButton {
            pos = { yellowTower:getRight(),  yellowTower:getTop()},
            size = buttonSize,
            normalTexture = "red_tower.png",
            onClick = function()
                setColor(2)
                --parentObj.currentColor = 2
                statusUI:setText( parentObj:generateStatus())
            end,
            parent = view,
        }
        
        greenTower = widget.SheetButton {
            pos = { redTower:getRight(),  redTower:getTop()},
            size = buttonSize,
            normalTexture = "green_tower.png",
            onClick = function()
                setColor(3)
                --parentObj.currentColor = 3
                statusUI:setText( parentObj:generateStatus())
            end,
            parent = view,
        }
        
        blueTower = widget.SheetButton {
            pos = { greenTower:getRight(),  greenTower:getTop()},
            size = buttonSize,
            normalTexture = "blue_tower.png",
            onClick = function()
                setColor(4)
                --parentObj.currentColor = 4
                statusUI:setText(parentObj:generateStatus())
            end,
            parent = view,
        }
        
        blackSpace = widget.SheetButton {
            pos = {yellowTower:getLeft(), yellowTower:getBottom()},
            size = buttonSize,
            normalTexture = "black_space.png",
            onClick = function()
                setColor(5)
                --parentObj.currentColor = 5
                statusUI:setText(parentObj:generateStatus())
            end,
            parent = view,
        }
    
        brownSpace = widget.SheetButton {
            pos = {blackSpace:getRight(), blackSpace:getTop()},
            size = buttonSize,
            normalTexture = "brown_space.png",
            onClick = function()
                setColor(6)
                --parentObj.currentColor = 6
                statusUI:setText(parentObj:generateStatus())
            end,
            parent = view,
        }
        
        voidSpace = widget.SheetButton {
            pos = {blackSpace:getRight(), blackSpace:getTop()},
            size = buttonSize,
            normalTexture = "void_space.png",
            onClick = function()
                setColor(6)
                --parentObj.currentColor = 6
                statusUI:setText(parentObj:generateStatus())
            end,
            parent = view,
        }
    
        toggleModeButton = widget.Button {
            pos = {xPosition, brownSpace:getBottom()},
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
            pos = {xPosition, toggleModeButton:getBottom()},
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
        children = {{
            widget.Button {
                pos = {flower.viewWidth - flower.viewWidth/6, 0},
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
    local buttonSize = {flower.viewWidth/6, 39}
    local xPosition = flower.viewWidth - flower.viewWidth/6

    timesRepeated = 0
    
    prevY = -1
    prevItem = nil
   for i, item in ipairs(view.children) do
        if (item:getTop() == prevY) then--If it has the same Y as the prev elem
            timesRepeated = timesRepeated + 1
            item:setPos(xPosition+(item:getWidth()*timesRepeated), prevItem:getTop())
        else
            timesRepeated = 0
            item:setPos(xPosition, item:getTop())
            item:setSize(buttonSize[1], item:getHeight())
        end
          
        prevY = item:getTop()
        prevItem = item
    end 
end


