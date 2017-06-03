local termW, termH = term.getSize()
---------- Check if on advanced computer
if (not term.isColor()) and termW ~= 51 and termH ~= 19 then
  error("Advanced computer required")
end

term.setTextColor(colors.cyan)

local tasks = {
    "Launching application",
    "Importing Theme",
    "Applying Theme",
    "Loading TML",
    "Registering callbacks for navigation",
    "Checking if any config files is available",
    "Starting peripheral updater",
    "Starting application"
}
local currentTask = 1
function nextTask()
    print(tasks[currentTask])
    currentTask = currentTask + 1
end

---------- Set up GUI framework
nextTask()
local application = Application(1,1,termW,termH):set{
    terminatable = true,
    backgroundColour = colours.white,
    colour = colours.grey,
}
function stopApplication(text)
    local h = fs.open("shipControllerStartup.cfg","w")
    h.write(textutils.serialize({
        pageID = app.pages.selectedPage.id
    }))
    h.close()
    application:stop()
    term.clear()
    print("Stopping application...")
    if(text) then
        -- print(text)
    end
end

---------- Initialize some variables
local peripherals = {}
local filteredPeripherals = {}
local editMovementEnabled
local editDimensionEnabled
local selectedForceField

---------- Function that gets run alongside the program, and handles peripherals and updating GUI when peripherals get changed
function updatePeripherals()
    ---------- Function for wrapping new peripherals
    local function addPeripheral(side)
        local type = peripheral.getType(side)
        if not (peripherals[type]) then
            peripherals[type] = {}
        end
        peripherals[type][side]=peripheral.wrap(side)
    end
    ---------- Function for removing peipherals from table
    local function removePeripheral(side)
        for k,v in pairs(peripherals) do
            if v[side] then
                v[side] = nil
                if next(v) == nil then
                    peripherals[k] = nil
                    break
                end
            end
        end
    end

    peripherals = {}
    ---------- Add initial peripherals
    for k,side in pairs(peripheral.getNames()) do
        addPeripheral(side)
    end
    ---------- Filter initial peripherals
    filterPeripherals()
    ---------- Continously check for peripherals placed or removed

    while true do
        local event, side = os.pullEvent()
        if event == "peripheral" then
            addPeripheral(side)
            filterPeripherals()
        elseif event == "peripheral_detach" then
            removePeripheral(side)
            filterPeripherals()
        end
    end
end
---------- Gets run by updatePeripherals, and changes the filteredPeripherals table to include only relevant peripherals
function filterPeripherals()
    filteredPeripherals = {}
    ---------- Ship Controller peripheral
    if(peripherals.warpdriveShipController) then
        for k,v in pairs(peripherals.warpdriveShipController) do
            filteredPeripherals.shipController = v
        end
    else
        filteredPeripherals.shipController = false
    end

    ---------- Forcefield projector peripheral, not implemented

    filteredPeripherals.forceFieldProjector = {}
    if(peripherals.warpdriveForceFieldProjector) then
        for k,v in pairs(peripherals.warpdriveForceFieldProjector) do
            filteredPeripherals.forceFieldProjector[k] = v
            -- error(k)
        end
    else
        filteredPeripherals.forceFieldProjector = false
    end

    ---------- Cloaking Core peripheral
    if(peripherals.warpdriveCloakingCore) then
        for k,v in pairs(peripherals.warpdriveCloakingCore) do
            filteredPeripherals.cloakingCore = v
        end
    else
        filteredPeripherals.cloakingCore = false
    end
    ---------- Updates display once
    updateDisplay()
end
---------- updateDisplay changes GUI after peripheral has been removed or added, and should only be run once after changed peripherals
function updateDisplay()
    ---------- Enable or disable radio buttons in page selector if the required peripheral is placed
    for k,v in pairs(filteredPeripherals) do
        if not v then
            application:query("#"..k.."Button").result[1]:setEnabled(false)
            application:query("#"..k.."Label").result[1]:setEnabled(false)
            application:query("#"..k).result[1]:setEnabled(false)
        else
            application:query("#"..k.."Button").result[1]:setEnabled(true)
            application:query("#"..k.."Label").result[1]:setEnabled(true)
            application:query("#"..k).result[1]:setEnabled(true)
        end
    end


    local shipController = filteredPeripherals.shipController
    local cloakingCore = filteredPeripherals.cloakingCore
    local forceFieldProjector = filteredPeripherals.forceFieldProjector

    if shipController then
        if shipController.isAttached() then
            -- application:on("shipCoreCooldownDone",function() end)

            local function rotateShip(dir)
                if(not tonumber(dir)) then
                    return
                end
                if(shipController.rotationSteps() + dir > 3) then
                    shipController.rotationSteps(0)
                elseif(shipController.rotationSteps() + dir < 0) then
                    shipController.rotationSteps(3)
                else
                    shipController.rotationSteps(shipController.rotationSteps()+dir)
                end
            end
            shipController.mode(1)
            shipController.rotationSteps(0)
            local editDimensionButton = application:query("#editDimensionButton").result[1]

            local positiveDimensionLabelContainer = application:query("#positiveDimensionLabelContainer").result[1]
            local positiveDimensionInputContainer = application:query("#positiveDimensionInputContainer").result[1]
            local negativeDimensionLabelContainer = application:query("#negativeDimensionLabelContainer").result[1]
            local negativeDimensionInputContainer = application:query("#negativeDimensionInputContainer").result[1]

            local frontDimLabel = application:query("#frontDimLabel").result[1]
            local rightDimLabel = application:query("#rightDimLabel").result[1]
            local upDimLabel = application:query("#upDimLabel").result[1]
            local backDimLabel = application:query("#backDimLabel").result[1]
            local leftDimLabel = application:query("#leftDimLabel").result[1]
            local downDimLabel = application:query("#downDimLabel").result[1]

            local frontDimInput = application:query("#frontDimInput").result[1]
            local rightDimInput = application:query("#rightDimInput").result[1]
            local upDimInput = application:query("#upDimInput").result[1]
            local backDimInput = application:query("#backDimInput").result[1]
            local leftDimInput = application:query("#leftDimInput").result[1]
            local downDimInput = application:query("#downDimInput").result[1]

            local editMovementButton = application:query("#editMovementButton").result[1]

            local movementLabelContainer = application:query("#movementLabelContainer").result[1]
            local movementInputContainer = application:query("#movementInputContainer").result[1]

            local frontMovementLabel = application:query("#frontMovementLabel").result[1]
            local upMovementLabel = application:query("#upMovementLabel").result[1]
            local rightMovementLabel = application:query("#rightMovementLabel").result[1]

            local frontMovementInput = application:query("#frontMovementInput").result[1]
            local upMovementInput = application:query("#upMovementInput").result[1]
            local rightMovementInput = application:query("#rightMovementInput").result[1]

            local rotateButtonContainer = application:query("#rotateButtonContainer").result[1]

            local rotateLeftButton = application:query("#rotateLeftButton").result[1]
            local rotateRightButton =  application:query("#rotateRightButton").result[1]

            local enableHyperspaceCheckbox = application:query("#enableHyperspaceCheckbox").result[1]
            local enableHyperspaceLabel = application:query("#enableHyperspaceLabel").result[1]
            local jumpButton = application:query("#jumpButton").result[1]


            editDimensionEnabled = false
            function toggleDimensionEdit()
                local curFrontDim, curRightDim, curUpDim = shipController.dim_positive()
                local curBackDim, curLeftDim, curDownDim = shipController.dim_negative()
                if not editDimensionEnabled then
                    frontDimInput.value = ""--tostring(curFrontDim)
                    rightDimInput.value = ""--tostring(curRightDim)
                    upDimInput.value = ""--tostring(curUpDim)
                    backDimInput.value = ""--tostring(curBackDim)
                    leftDimInput.value = ""--tostring(curLeftDim)
                    downDimInput.value = ""--tostring(curDownDim)

                    editDimensionButton:setClass("informationButton", true)
                    editDimensionButton:setClass("warningButton", false)
                    editDimensionButton:setText("Save")
                    positiveDimensionLabelContainer:setVisible(false)
                    positiveDimensionInputContainer:setVisible(true)
                    positiveDimensionInputContainer:setEnabled(true)
                    negativeDimensionLabelContainer:setVisible(false)
                    negativeDimensionInputContainer:setVisible(true)
                    negativeDimensionInputContainer:setEnabled(true)
                    frontDimInput:focus()
                else
                    shipController.dim_positive(
                        frontDimInput.value and tonumber(frontDimInput.value) or curFrontDim,
                        rightDimInput.value and tonumber(rightDimInput.value) or curRightDim,
                        upDimInput.value and tonumber(upDimInput.value) or curUpDim
                    )
                    shipController.dim_negative(
                        backDimInput.value and tonumber(backDimInput.value) or curBackDim,
                        leftDimInput.value and tonumber(leftDimInput.value) or curLeftDim,
                        downDimInput.value and tonumber(downDimInput.value) or curDownDim
                    )
                    editDimensionButton:setClass("informationButton", false)
                    editDimensionButton:setClass("warningButton", true)
                    editDimensionButton:setText("Edit")
                    positiveDimensionLabelContainer:setVisible(true)
                    positiveDimensionInputContainer:setVisible(false)
                    positiveDimensionInputContainer:setEnabled(false)
                    negativeDimensionLabelContainer:setVisible(true)
                    negativeDimensionInputContainer:setVisible(false)
                    negativeDimensionInputContainer:setEnabled(false)
                    refreshDisplay()
                end
                editDimensionEnabled = not editDimensionEnabled
            end
            editMovementEnabled = false
            function toggleMovementEdit()
                local curFrontMovement, curUpMovement, curRightMovement = shipController.movement()
                if not editMovementEnabled then
                    frontMovementInput.value = ""--tostring(curFrontMovement)
                    upMovementInput.value = ""--tostring(curUpMovement)
                    rightMovementInput.value = ""--tostring(curRightMovement)

                    editMovementButton:setClass("informationButton", true)
                    editMovementButton:setClass("warningButton", false)
                    editMovementButton:setText("Save")
                    movementLabelContainer:setVisible(false)
                    movementInputContainer:setVisible(true)
                    movementInputContainer:setEnabled(true)
                    -- rotateButtonContainer:setVisible(true)
                    -- rotateButtonContainer:setEnabled(true)
                    frontMovementInput:focus()
                else
                    shipController.movement(
                        frontMovementInput.value and tonumber(frontMovementInput.value) or curFrontMovement,
                        upMovementInput.value and tonumber(upMovementInput.value) or curUpMovement,
                        rightMovementInput.value and tonumber(rightMovementInput.value) or curRightMovement
                    )
                    editMovementButton:setClass("informationButton", false)
                    editMovementButton:setClass("warningButton", true)
                    editMovementButton:setText("Edit")
                    movementLabelContainer:setVisible(true)
                    movementInputContainer:setVisible(false)
                    movementInputContainer:setEnabled(false)
                    -- rotateButtonContainer:setVisible(false)
                    -- rotateButtonContainer:setEnabled(false)

                    refreshDisplay()
                end
                editMovementEnabled = not editMovementEnabled
            end

            editDimensionButton:off("trigger")
            editDimensionButton:on("trigger", toggleDimensionEdit)

            frontDimInput:off("trigger")
            frontDimInput:on("trigger", function(input)
                input:unfocus()
                rightDimInput:focus()
            end)
            rightDimInput:off("trigger")
            rightDimInput:on("trigger", function(input)
                input:unfocus()
                upDimInput:focus()
            end)
            upDimInput:off("trigger")
            upDimInput:on("trigger", function(input)
                input:unfocus()
                backDimInput:focus()
            end)
            backDimInput:off("trigger")
            backDimInput:on("trigger", function(input)
                input:unfocus()
                leftDimInput:focus()
            end)
            leftDimInput:off("trigger")
            leftDimInput:on("trigger", function(input)
                input:unfocus()
                downDimInput:focus()
            end)
            downDimInput:off("trigger")
            downDimInput:on("trigger", function(input)
                input:unfocus()
                toggleDimensionEdit()
            end)

            editMovementButton:off("trigger")
            editMovementButton:on("trigger", toggleMovementEdit)

            frontMovementInput:off("trigger")
            frontMovementInput:on("trigger",function(input)
                input:unfocus()
                upMovementInput:focus()
            end)
            upMovementInput:off("trigger")
            upMovementInput:on("trigger",function(input)
                input:unfocus()
                rightMovementInput:focus()
            end)
            rightMovementInput:off("trigger")
            rightMovementInput:on("trigger",function(input)
                input:unfocus()
                toggleMovementEdit()
            end)
            rotateLeftButton:off("trigger")
            rotateLeftButton:on("trigger", function() rotateShip(-1) refreshDisplay() end)

            rotateRightButton:off("trigger")
            rotateRightButton:on("trigger", function() rotateShip(1) refreshDisplay() end)

            if(shipController.isInSpace()) then
                enableHyperspaceLabel:setText("Warp to hyperspace?")
            elseif(shipController.isInHyperspace()) then
                enableHyperspaceLabel:setText("Warp to space?")
            else
                enableHyperspaceCheckbox:setEnabled(false)
                enableHyperspaceCheckbox:setVisible(false)
            end
            enableHyperspaceCheckbox:on("toggle",function(checkbox)
                if(checkbox.toggled) then
                    shipController.mode(5)
                else
                    shipController.mode(1)
                end
                refreshDisplay()
            end)
            jumpButton:off("trigger")
            jumpButton:on("trigger",function()
                shipController.jump()

                local h = fs.open("shipControllerStartup.cfg","w")
                h.write(textutils.serialize({
                    pageID = app.pages.selectedPage.id
                }))
                h.close()
            end)

        end
    end
    if forceFieldProjector then
        local forceFieldList = application:query("#forceFieldList").result[1]
        activateForceFieldButton = application:query("#activateForceFieldButton").result[1]

        forceFieldList:clearNodes()

        local mainPageRadioButton = RadioButton(1,1,"forceFieldSelector")
        mainPageRadioButton.value = "all"
        mainPageRadioButton.id = "mainPageRadioButton"
        mainPageRadioButton:setClass("forceFieldRadioButton", true)
        forceFieldList:addNode(mainPageRadioButton)
        local mainPageLabel = Label("All Forcefields",4,1)
        mainPageLabel.labelFor = "mainPageRadioButton"
        forceFieldList:addNode(mainPageLabel)

        local i=3
        for k,v in pairs(forceFieldProjector) do
            local radioButton = RadioButton(1,i,"forceFieldSelector")
            radioButton.value = k
            radioButton.id = k
            radioButton:setClass("forceFieldRadioButton", true)
            forceFieldList:addNode(radioButton)
            local label = Label(k,3,i)
            label.labelFor = k
            forceFieldList:addNode(label)

            i = i+2
        end
        application:query(".forceFieldRadioButton"):off("select")
        application:query(".forceFieldRadioButton"):on("select",function(radioButton)
            selectedForceField = radioButton.value
            if(not (selectedForceField=="all")) then
                currentForceField = forceFieldProjector[selectedForceField]

                activateForceFieldButton:off("trigger")
                activateForceFieldButton:on("trigger",function()
                    currentForceField.enable(not currentForceField.enable())
                    refreshDisplay()
                end)
            end
            refreshDisplay()
        end)

        mainPageRadioButton:select()
        selectedForceField = "all"
    end
    if cloakingCore then
        local activateCloakingButton = application:query("#activateCloakingButton").result[1]

        local tierRadioButton = application:query(".tierRadioButton")
        local currentTier = cloakingCore.tier()

        activateCloakingButton:setClass((cloakingCore.enable()) and "warningButton" or "affirmativeButton" ,true)
        activateCloakingButton:setClass((not cloakingCore.enable()) and "warningButton" or "affirmativeButton" ,false)

        function toggleCloakingEnabled()
            cloakingCore.enable(not cloakingCore.enable())
            refreshDisplay()
        end
        application:query("#tier"..currentTier.."Button").result[1]:select()

        tierRadioButton:off("select")
        tierRadioButton:on("select",function(radioButton)
            cloakingCore.tier(radioButton.value)
        end)
        activateCloakingButton:off("trigger")
        activateCloakingButton:on("trigger", toggleCloakingEnabled)
    end
end

---------- Refreshes everything on the screen that needs to be updated regularily
local prevShipControllerEnergy = 0
local prevCloakingCoreEnergy = 0
local prevForceFieldProjectorEnergy = 0
function refreshDisplay()
    local shipController = filteredPeripherals.shipController
    local cloakingCore = filteredPeripherals.cloakingCore
    local forceFieldProjector = filteredPeripherals.forceFieldProjector
    if shipController then
        if shipController.isAttached() then

            local xPosLabel = application:query("#xPosLabel").result[1]
            local yPosLabel = application:query("#yPosLabel").result[1]
            local zPosLabel = application:query("#zPosLabel").result[1]

            local frontDimLabel = application:query("#frontDimLabel").result[1]
            local rightDimLabel = application:query("#rightDimLabel").result[1]
            local upDimLabel = application:query("#upDimLabel").result[1]
            local backDimLabel = application:query("#backDimLabel").result[1]
            local leftDimLabel = application:query("#leftDimLabel").result[1]
            local downDimLabel = application:query("#downDimLabel").result[1]

            local frontDimInput = application:query("#frontDimInput").result[1]
            local rightDimInput = application:query("#rightDimInput").result[1]
            local upDimInput = application:query("#upDimInput").result[1]
            local backDimInput = application:query("#backDimInput").result[1]
            local leftDimInput = application:query("#leftDimInput").result[1]
            local downDimInput = application:query("#downDimInput").result[1]

            local shipSizeLabel = application:query("#shipSizeLabel").result[1]

            local frontMovementLabel = application:query("#frontMovementLabel").result[1]
            local upMovementLabel = application:query("#upMovementLabel").result[1]
            local rightMovementLabel = application:query("#rightMovementLabel").result[1]

            local shipRotationLabel = application:query("#shipRotationLabel").result[1]

            -- local rotateButtonContainer = application:query("#rotateButtonContainer").result[1]
            --     local rotateLeftButton = application:query("#rotateLeftButton").result[1]
            --     local rotateRightButton =  application:query("#rotateRightButton").result[1]

            local distanceLabel = application:query("#distanceLabel").result[1]
            local energyRequiredLabel = application:query("#energyRequiredLabel").result[1]

            local shipEnergyProgressBar = application:query("#shipEnergyProgressBar").result[1]

            local xPos,yPos,zPos = shipController.position()
            local frontDim, rightDim, upDim = shipController.dim_positive()
            local backDim, leftDim, downDim = shipController.dim_negative()

            local shipSize = shipController.getShipSize()

            local frontMovement, upMovement, rightMovement = shipController.movement()
            local shipRotation = shipController.rotationSteps()
            local shipRotationText = (shipRotation==0 and "None") or (shipRotation==1 and "Right") or (shipRotation==2 and "Back") or "Left"

            local dX,dY,dZ = shipController.getOrientation()
            local actualDistance = math.ceil(math.sqrt(
            math.pow(dX*frontMovement-dZ*rightMovement,2) +
            math.pow(upMovement,2) +
            math.pow(dZ*frontMovement+dX*rightMovement,2)))

            local energyRequired = shipController.getEnergyRequired(actualDistance)

            local curEnergy,maxEnergy,energyOut = shipController.energy()

            -- local summonAllButton = application:query("#summonAllButton")



            xPosLabel:setText(tostring(xPos))
            yPosLabel:setText(tostring(yPos))
            zPosLabel:setText(tostring(zPos))

            frontDimLabel:setText(tostring(frontDim))
            rightDimLabel:setText(tostring(rightDim))
            upDimLabel:setText(tostring(upDim))
            backDimLabel:setText(tostring(backDim))
            leftDimLabel:setText(tostring(leftDim))
            downDimLabel:setText(tostring(downDim))

            shipSizeLabel:setText(shipSize.." blocks")

            frontMovementLabel:setText(tostring(frontMovement))
            upMovementLabel:setText(tostring(upMovement))
            rightMovementLabel:setText(tostring(rightMovement))

            shipRotationLabel:setText(shipRotationText)

            distanceLabel:setText(actualDistance.." blocks")
            energyRequiredLabel:setText(energyRequired.." EU")

            shipEnergyProgressBar:set("maxValue",maxEnergy)
            shipEnergyProgressBar:set("value", curEnergy)
            shipEnergyProgressBar:setText(math.ceil((curEnergy/maxEnergy*100)).."%".." : ".. (((curEnergy-prevShipControllerEnergy)>=0) and "+" or "") ..(curEnergy-prevShipControllerEnergy) .."EU")
            prevShipControllerEnergy = curEnergy

            frontDimInput:queueAreaReset()
            rightDimInput:queueAreaReset()
            upDimInput:queueAreaReset()
            backDimInput:queueAreaReset()
            leftDimInput:queueAreaReset()
            downDimInput:queueAreaReset()
        end
    end
    if forceFieldProjector then
        local activateForceFieldButton = application:query("#activateForceFieldButton").result[1]
        local forceFieldProjectorEnergyProgressBar = application:query("#forceFieldProjectorEnergyProgressBar").result[1]
        if(selectedForceField == "all") then
            activateForceFieldButton:setEnabled(false)
            activateForceFieldButton:setText("Activate")
        else
            local currentForceField = forceFieldProjector[selectedForceField]
            activateForceFieldButton:setEnabled(true)
            local isEnabled = currentForceField.enable()
            local curEnergy, maxEnergy = currentForceField.energy()

            activateForceFieldButton:setText(isEnabled and "Disable " or "Activate ")
            activateForceFieldButton:setClass((currentForceField.enable()) and "warningButton" or "affirmativeButton" ,true)
            activateForceFieldButton:setClass((not currentForceField.enable()) and "warningButton" or "affirmativeButton" ,false)

            forceFieldProjectorEnergyProgressBar:set("maxValue",maxEnergy)
            forceFieldProjectorEnergyProgressBar:set("value",curEnergy)
            forceFieldProjectorEnergyProgressBar:setText(math.ceil((curEnergy/maxEnergy*100)).."%".." : ".. (((curEnergy-prevForceFieldProjectorEnergy)>=0) and "+" or "") ..(curEnergy-prevForceFieldProjectorEnergy) .."EU")

            prevForceFieldProjectorEnergy = curEnergy
        end
    end
    if cloakingCore then
        local isAssemblyValidLabel = application:query("#isAssemblyValidLabel").result[1]
        local activateCloakingButton = application:query("#activateCloakingButton").result[1]
        local cloakingCoreEnergyProgressBar = application:query("#cloakingCoreEnergyProgressBar").result[1]

        local isEnabled = cloakingCore.enable()
        local curEnergy,maxEnergy = cloakingCore.energy()

        activateCloakingButton:setText(isEnabled and "Disable " or "Activate ")
        activateCloakingButton:setClass((cloakingCore.enable()) and "warningButton" or "affirmativeButton" ,true)
        activateCloakingButton:setClass((not cloakingCore.enable()) and "warningButton" or "affirmativeButton" ,false)

        cloakingCoreEnergyProgressBar:set("maxValue",maxEnergy)
        cloakingCoreEnergyProgressBar:set("value", curEnergy)
        -- cloakingCoreEnergyProgressBar:setText(math.ceil((curEnergy/maxEnergy*100)).."%")
        cloakingCoreEnergyProgressBar:setText(math.ceil((curEnergy/maxEnergy*100)).."%".." : ".. (((curEnergy-prevCloakingCoreEnergy)>=0) and "+" or "") ..(curEnergy-prevCloakingCoreEnergy) .."EU")
        prevCloakingCoreEnergy = curEnergy

        if(cloakingCore.isAssemblyValid()) then
            isAssemblyValidLabel:setVisible(false)
            activateCloakingButton:setEnabled(true)
        else
            isAssemblyValidLabel:setVisible(true)
            activateCloakingButton:setEnabled(false)
        end
    end
end

---------- Set up markup, theme and app variables
app = {}
nextTask()
app.masterTheme = Theme.fromFile("masterTheme","shipcontroller/ui/master.theme")
nextTask()
application:addTheme(app.masterTheme)
nextTask()
application:importFromTML("shipcontroller/ui/master.tml")

app.pages = application:query("PageContainer").result[1]
app.pageSelectorPane = application:query("Container#pageSelectorPane").result[1]

---------- Set animation and function for side pane
nextTask()
local sidePane,paneStatus = app.pageSelectorPane
function paneToggle()
    paneStatus = not paneStatus
    sidePane:animate("sidePaneAnimation","X",paneStatus and sidePane.parent.width - 27 or sidePane.parent.width, panestatus and 0.15 or 0.2, paneStatus and "outSine" or "inQuad")
end

---------- Set page when button inside page selector is pressed
application:query(".pageSelector"):on("select",function(radioButton)
        app.pages:selectPage(radioButton.value)
        application:schedule(paneToggle,0.3)
end)
---------- Exit when pressing exit button
application:query("#exitButton"):on("trigger",stopApplication)
---------- Open side pane when pressed
application:query("#openPageSelectorButton"):on("trigger",paneToggle)

---------- Register quick terminate
application:registerHotkey("close","leftCtrl-leftShift-t",stopApplication)

---------- Select main page on startup, also opens the page selector which is a happy mistake.
nextTask()
if(fs.exists("shipControllerStartup.cfg")) then
    local h = fs.open("shipControllerStartup.cfg","r")
    local cfg = textutils.unserialize(h.readAll())
    if cfg.pageID then
        application:query("#"..cfg.pageID.."Button").result[1]:select()
        paneToggle()
    end
    h.close()
    fs.delete("shipControllerStartup.cfg")
else
    application:query("#mainButton"):executeOnNodes("select")
end

---------- Add threads, can be set with a timeout to reduce lag
-- application:schedule(function()
nextTask()
application:addThread(Thread(updatePeripherals, false))
application:addThread(Thread(function()
    while true do
        refreshDisplay()
        sleep(1.5)
    end
end, false))

-- end, 1,false)

---------- Start Titanium GUI
nextTask()

application:start()
