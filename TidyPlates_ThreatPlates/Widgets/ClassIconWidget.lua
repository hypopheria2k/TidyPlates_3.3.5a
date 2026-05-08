-----------------------
-- Class Icon Widget --
-----------------------
local path = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\ClassIconWidget\\"

local function UpdateClassIconWidget(frame, unit)
    local db = TidyPlatesThreat.db.profile
    
    -- Grund-Einstellungen
    frame:SetSize(db.classWidget.scale or 42, db.classWidget.scale or 42) 
    frame:SetAlpha(1)

    -- 1. Check: Ist das Widget überhaupt an?
    if not db.classWidget.ON then
        frame:Hide()
        return
    end

    -- 2. Check: Ist es ein Spieler? (NPCs kriegen hier kein Icon mehr)
    if unit.type ~= "PLAYER" then
        frame:Hide()
        return
    end

    -- 3. Check: Reaktion filtern
    -- Feindliche Spieler nur, wenn Option an
    if unit.reaction ~= "FRIENDLY" and not db.showEnemyClassIcon then
        frame:Hide()
        return
    -- Freundliche Spieler nur, wenn Option an
    elseif unit.reaction == "FRIENDLY" and not db.friendlyClassIcon then
        frame:Hide()
        return
    end

    -- Klassenerkennung (Unit-Daten -> Cache -> GUID-Abfrage)
    local class = unit.class
    if not class or class == "UNKNOWN" then
        class = db.cache[unit.name]
    end

    if (not class or class == "UNKNOWN") and unit.guid then
        local engClass = select(2, GetPlayerInfoByGUID(unit.guid))
        if engClass then
            class = engClass
            if db.cacheClass then db.cache[unit.name] = class end
        end
    end

    -- Wenn wir eine Klasse haben, zeigen wir das Icon unkaputtbar an
    if class and class ~= "UNKNOWN" then
        frame.Icon:SetTexture(path .. db.classWidget.theme .. "\\" .. class)
        
        -- Positionierung an der Blizzard-Plate (bleibt bei Hide Names sichtbar)
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", frame:GetParent(), "CENTER", db.classWidget.x or 0, (db.classWidget.y or 0) + 35)
        
        frame:Show()
    else
        frame:Hide()
    end
end

local function CreateClassIconWidget(parent)
    local db = TidyPlatesThreat.db.profile.classWidget
    
    -- Anker an die originale Blizzard-Plate
    local blizzardPlate = parent:GetParent() or parent
    local frame = CreateFrame("Frame", nil, blizzardPlate)
    
    frame:SetSize(42, 42)
    frame.Icon = frame:CreateTexture(nil, "OVERLAY", nil, 7)
    frame.Icon:SetAllPoints(frame)
    
    frame:SetFrameLevel(1)
    frame:EnableMouse(false)
    
    frame.Update = UpdateClassIconWidget
    return frame
end

ThreatPlatesWidgets.CreateClassIconWidget = CreateClassIconWidget