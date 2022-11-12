local ADDON, Addon = ...


local TypeInfo = {
    { 'Silver UI' },
    { 'Object' },
    { 'FrameScriptObject' },
    { 'ScriptRegion' },
    { 'ScriptRegionResizing' },
    { 'AnimatableObject' },
    { 'Region' },
    { 'TextureBase' },
    { 'Texture' },
    { 'MaskTexture' },
    { 'Line' },
    { 'Font' },
    { 'FontString' },
    { 'AnimationGroup' },
    { 'Animation' },
    { 'Alpha' },
    { 'Rotation' },
    { 'Scale' },
    { 'LineScale' },
    { 'Translation' },
    { 'LineTranslation' },
    { 'TextureCoordTranslation' },
    { 'FlipBook' },
    { 'Path' },
    { 'ControlPoint' },
    { 'Frame' },
    { 'Button' },
    { 'CheckButton' },
    { 'Model' },
    { 'PlayerModel' },
    { 'CinematicModel' },
    { 'DressUpModel' },
    { 'TabardModel' },
    { 'ColorSelect' },
    { 'Cooldown' },
    { 'EditBox' },
    { 'GameTooltip' },
    { 'MessageFrame' },
    { 'Minimap' },
    { 'MovieFrame' },
    { 'ScrollFrame' },
    { 'SimpleHTML' },
    { 'Slider' },
    { 'StatusBar' },
    { 'Browser' },
    { 'ItemButton' },
    { 'Checkout' },
    { 'FogOfWarFrame' },
    { 'ModelScene' },
    { 'ModelSceneActor' },
    { 'OffScreenFrame' },
    { 'POIFrame' },
    { 'ArchaeologyDigSiteFrame' },
    { 'QuestPOIFrame' },
    { 'ScenarioPOIFrame' },
    { 'ScrollingMessageFrame' },
    { 'UnitPositionFrame' },
    { 'WorldFrame' },
}


local function FillTypeInfo()

    if TypeInfo[1][2] then return end

    TypeInfo[1][2] = LQT.FrameExtensions
    
    LoadAddOn('Blizzard_APIDocumentationGenerated')

    for _, typeinfo in pairs(TypeInfo) do
        for _, system in pairs(APIDocumentation.systems) do
            if system.Type == 'ScriptObject' and system.Name == 'Simple' .. typeinfo[1] .. 'API' then
                local functions = {}
                for _, fn in pairs(system.Functions) do
                    functions[fn.Name] = true
                end
                typeinfo[2] = functions
            end
        end
    end
end

Addon.TypeInfo = TypeInfo
Addon.FillTypeInfo = FillTypeInfo
