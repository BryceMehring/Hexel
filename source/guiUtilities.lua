local flower = flower
local widget = widget

function buildUI(gameMode, view, parentObj)
    local buttonSize = {flower.viewWidth/6, 39}
    local xPosition = flower.viewWidth - flower.viewWidth/6
    
     saveButton = widget.Button {
        pos = {xPosition, 39},
        size = buttonSize,
        text = "Save State",
        parent = view,
        onClick = function()
            if gameMode == "MapEditor" then
                parentObj.serializeGrid(saveFile) 
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
                if parentObj.paused() then
                    parentObj.paused(false)
                    pauseButton:setText("Pause Wave")
                else
                    parentObj.paused(true)
                    pauseButton:setText("Start Wave")
                end
            end,
            enabled = true,
        }
    end
    
     statusUI = widget.TextBox {
         pos = {xPosition,  pauseButton and pauseButton:getBottom() or loadButton:getBottom()},
         size = {buttonSize[1], 70},
         text =  parentObj.generateStatus(),
         textSize = 10,
         parent = view,
    }

     yellowTower = widget.SheetButton {
         pos = {xPosition,  statusUI:getBottom()},
         size = buttonSize,
         normalTexture = "yellow_tower.png",
         onClick = function()
              parentObj.currentColor = 1
              statusUI:setText( parentObj.generateStatus()) 
         end,
         parent = view,
    }
    
     redTower = widget.SheetButton {
         pos = { yellowTower:getRight(),  yellowTower:getTop()},
         size = buttonSize,
         normalTexture = "red_tower.png",
         onClick = function()
              parentObj.currentColor = 2
              statusUI:setText( parentObj.generateStatus())
         end,
         parent = view,
    }
    
     greenTower = widget.SheetButton {
         pos = { redTower:getRight(),  redTower:getTop()},
         size = buttonSize,
         normalTexture = "green_tower.png",
         onClick = function()
              parentObj.currentColor = 3
              statusUI:setText( parentObj.generateStatus())
         end,
         parent = view,
    }
    
     blueTower = widget.SheetButton {
         pos = { greenTower:getRight(),  greenTower:getTop()},
         size = buttonSize,
         normalTexture = "blue_tower.png",
         onClick = function()
              parentObj.currentColor = 4
              statusUI:setText(parentObj.generateStatus())
         end,
         parent = view,
    }
    
    if gameMode == "MapEditor" then
       blackSpace = widget.SheetButton {
         pos = {yellowTower:getLeft(), yellowTower:getBottom()},
         size = buttonSize,
         normalTexture = "black_space.png",
         onClick = function()
             parentObj.currentColor = 5
             statusUI:setText(parentObj.generateStatus())
         end,
         parent = view,
    }
    
    brownSpace = widget.SheetButton {
         pos = {blackSpace:getRight(), blackSpace:getTop()},
         size = buttonSize,
         normalTexture = "brown_space.png",
         onClick = function()
             parentObj.currentColor = 6
             statusUI:setText(parentObj.generateStatus())
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
            
            statusUI:setText(parentObj.generateStatus())
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

function _updateStatus(status)
    retString = ""
    isFirstRow = true
    --for i, item in ipairs(status) do
    for key,value in pairs(status) do
        if not isFirstRow then
           retString = retString .. "\n"
        else
            isFirstRow = false
        end
     retString = retString .. key .. ": " .. status[key]
    end
    
   return retString
end


