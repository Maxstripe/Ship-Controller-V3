local termW, termH = term.getSize();
---------- Check if on advanced computer
if (not term.isColor()) and termW ~= 51 and termH ~= 19 then
  error("Advanced computer required")
end

---------- Initialize GUI framework
-- dofile "shipcontroller/titanium.lua"

---------- Set up GUI framework
local application = Application(1,1,termW,termH):set{
    terminatable = true,
    backgroundColour = colours.white,
    colour = colours.grey,
}
----------
function stopApplication()
    application:stop()
    term.clear()
    print("Stopping application...")
end

---------- Initialize some variables
local peripherals = {}
local filteredPeripherals = {}
local editMovementEnabled
local editDimensionEnabled

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

    -- if(peripherals.warpdriveforceFieldProjector) then
    --     for k,v in pairs(peripherals.warpdriveforceFieldProjector) do
    --         filteredPeripherals.forceFieldController = v
    --     end
    -- else
        filteredPeripherals.forceFieldController = false
    -- end

    ---------- Cloaking Core peripheral
    if(peripherals.warpdriveCloakingCore) then
        for k,v in pairs(peripherals.warpdriveCloakingCore) do
            filteredPeripherals.cloakingController = v
        end
    else
        filteredPeripherals.cloakingController = false
    end
    ---------- Updates display once
    updateDisplay()
end
---------- updateDisplay changes GUI after peripheral has been removed or added, and should only be run once after changed peripherals
function updateDisplay()
    ---------- Enable or disable radio buttons in page selector if the required peripheral is placed
    for k,v in pairs(filteredPeripherals) do
        if not v then
            application:query("#"..k.."Button").result[1].enabled = false
            application:query("#"..k.."Label").result[1].enabled = false
        else
            application:query("#"..k.."Button").result[1].enabled = true
            application:query("#"..k.."Label").result[1].enabled = true
        end
    end


    local shipController = filteredPeripherals.shipController
    local cloakingController = filteredPeripherals.cloakingController
    local forceFieldController = filteredPeripherals.forceFieldController

    if shipController then
        if shipController.isAttached() then
            shipController.mode(1)
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
    if cloakingController then

    end
    if forceFieldController then

    end
end

function refreshDisplay()
    local shipController = filteredPeripherals.shipController
    local cloakingController = filteredPeripherals.cloakingController
    local forceFieldController = filteredPeripherals.forceFieldController
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

            local distanceLabel = application:query("#distanceLabel").result[1]
            local energyRequiredLabel = application:query("#energyRequiredLabel").result[1]

            local energyProgressBar = application:query("#energyProgressBar").result[1]

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

            energyProgressBar:set("maxValue",maxEnergy)
            energyProgressBar:set("value", curEnergy)
            energyProgressBar:setText(math.ceil((curEnergy/maxEnergy*100)).."%")

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

            frontDimInput:queueAreaReset()
            rightDimInput:queueAreaReset()
            upDimInput:queueAreaReset()
            backDimInput:queueAreaReset()
            leftDimInput:queueAreaReset()
            downDimInput:queueAreaReset()
        end
    end
    if cloakingController then

    end
    if forceFieldController then

    end
end


---------- Set up markup, theme and app variables
app = {}
app.masterTheme = Theme.fromFile("masterTheme","shipcontroller/ui/master.theme")

application:addTheme(app.masterTheme)
application:importFromTML("shipcontroller/ui/master.tml")

app.pages = application:query("PageContainer").result[1]
app.pageSelectorPane = application:query("Container#pageSelectorPane").result[1]

---------- Set animation and function for side pane
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
if(fs.exists("shipControllerStartup.cfg")) then
    local h = fs.open("shipControllerStartup.cfg","r")
    local cfg = textutils.unserialize(h.readAll())
    if cfg.pageID then
        application:query("#"..cfg.pageID.."Button"):executeOnNodes("select")
        paneToggle()
    end
    h.close()
    fs.delete("shipControllerStartup.cfg")
else
    application:query("#mainButton"):executeOnNodes("select")
end

---------- Add threads, can be set with a timeout to reduce lag
-- application:schedule(function()
    application:addThread(Thread(updatePeripherals, false))
    application:addThread(Thread(function()
        while true do
            refreshDisplay()
            sleep(2)
        end
    end, false))
-- end, 1,false)

---------- Start Titanium GUI
application:start()
