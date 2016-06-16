--
-- Created by IntelliJ IDEA.
-- User: Geramy92
-- Date: 16.06.2016
-- Time: 15:48
-- To change this template use File | Settings | File Templates.
--

local teleportMarkers = {}
function getTeleportMarkers()
    return teleportMarkers;
end

function loadTeleportMarkers()
    local markersFromDatabase = MySql.helper.getSync("objects_teleport_markers", "*");

    local marker;
    for theKey, theMarkerData in ipairs(markersFromDatabase) do
        marker = createMarker(theMarkerData.x, theMarkerData.y, theMarkerData.z, theMarkerData.markerType, theMarkerData.markerSize);
        setElementInterior(marker, theMarkerData.interior);
        setElementDimension(marker, theMarkerData.dimension);

        vioSetElementData(marker, "additionalData", theMarkerData);

        teleportMarkers[theMarkerData.ID] = marker;
        addEventHandler("onMarkerHit", marker, onTeleportMarkerHit);
    end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), loadTeleportMarkers)

function onTeleportMarkerHit(hitElement, matchingDimension)

    if matchingDimension then
        if (getElementType(hitElement) == "player") then
            local markerData = vioGetElementData(source, "additionalData");

            -- don't teleport if stop is set
            if (vioGetElementData(hitElement, "stopTeleportMarkersForTeleport")) then
                showError(hitElement, "teleport disabled");
                return;
            end

            -- Special cases
            if (markerData.specialKey) then
                if (markerData.specialKey == "onlypolice") then
                    if (not isBeamter(hitElement)) then
                        showError(hitElement, "Du bist kein Beamter!");
                        return;
                    end
                elseif (marker.specialKey == "ammonation") then
                    if (vioGetElementData(hitElement, "waffenLic") ~= 1) then
                        showError(hitElement, "Aufseher: Sie besitzen keinen Waffenschein, daher sind sie hier unerwünscht! Bitte verpissen Sie sich!");
                        return;
                    end
                elseif (marker.specialKey == "casino") then
                    outputChatBox("Der Innenraum und sämtliche Spiele sind überwacht, Diebstahl und Bugusing lohnt sich nicht!", hitElement, 255, 0, 0);
                end
            end

            if (markerData.toInt) then
                setElementInterior(hitElement, markerData.toInt);
            end

            if (markerData.toDim) then
                setElementDimension(hitElement, markerData.toDim);
            end

            if (markerData.toMarker) then
                -- Teleport to Marker
                local toX, toY, toZ = getElementPosition(teleportMarkers[markerData.toMarker]);
                vioSetElementData(hitElement, "stopTeleportMarkersForTeleport", true);
                setTimer(enableTeleportMarkersForPlayerAgain, 2000, 1, hitElement);
                setElementPosition(hitElement, toX, toY, toZ);
            else
                -- Teleport to Position
                setElementPosition(hitElement, markerData.toPosX, markerData.toPosY, markerData.toPosZ);
            end

            if (markerData.rzAfterTeleport) then
                setElementRotation ( hitElement, 0, 0, markerData.rzAfterTeleport);
            end

            -- For Ammonation run Script after teleport
            if (markerData.specialKey) then
                if (markerData.specialKey == "ammonation") then
                    respawnAmmoBot_Server();
                end
            end
        end
    end
end

function enableTeleportMarkersForPlayerAgain(thePlayer)
    vioSetElementData(thePlayer, "stopTeleportMarkersForTeleport", false);
end