---@class Addon
local Addon = select(2, ...)

local LQT = Addon.LQT
local query = LQT.query
local Hook = LQT.Hook
local Script = LQT.Script
local Style = LQT.Style
local Frame = LQT.Frame
local Button = LQT.Button
local Texture = LQT.Texture
local FontString = LQT.FontString
local EditBox = LQT.EditBox
local ScrollFrame = LQT.ScrollFrame
local SELF = LQT.SELF
local PARENT = LQT.PARENT
local ApplyFrameProxy = LQT.ApplyFrameProxy
local FrameProxyMt = LQT.FrameProxyMt

local Scripts = Addon.Scripts

local TypeInfo = Addon.TypeInfo
local FillTypeInfo = Addon.FillTypeInfo

local FrameSmoothScroll = Addon.FrameSmoothScroll
local CodeEditor = Addon.CodeEditor
local BoxShadow = Addon.BoxShadow
local FrameTraceWindow = Addon.FrameTraceWindow
local FrameInspector = Addon.FrameInspector
local PixelAnchor = Addon.Templates.PixelAnchor
local PixelSizex2 = Addon.Templates.PixelSizex2
local BubbleScript = Addon.BubbleScript
local StyledButton = Addon.StyledButton
local OnPage = Addon.OnPage



local editorWindow = nil


local function GetUIParentChildren()
    local found = {}

    local object = EnumerateFrames()
    while object do
        if not object:IsForbidden() and not found[object] and object:GetParent() == UIParent then
            found[object] = true
        end
        object = EnumerateFrames(object)
    end

    return found
end


local BubbleHover = Style { BubbleScript.OnEnter, BubbleScript.OnLeave }


local SortedChildren = nil



local PageCodeEditor = FrameSmoothScroll {

    bg = Texture
        :AllPoints()
        :ColorTexture(0.2, 0.2, 0.2, 0.5),

    shadow = BoxShadow
        :EdgeSize(4)
        :Alpha(0.5),

    ['.Content'] = Style {

        [Script.OnMouseDown] = function(self)
            local editor = self.CodeEditor.Editor
            editor:SetFocus()
            editor:SetCursorPosition(#editor:OrigGetText())
        end,

        EditorHead = Frame
            .TOPLEFT:TOPLEFT()
            .RIGHT:RIGHT()
            :Height(20)
        {
            bg = Texture
                .BOTTOMLEFT:BOTTOMLEFT()
                .BOTTOMRIGHT:BOTTOMRIGHT()
                :Height(2)
                :ColorTexture(0.3, 0.3, 0.3, 0.5),

            label = FontString
                :Font('Fonts/ARIALN.ttf', 12, '')
                :Height(20-2)
                .BOTTOMLEFT:BOTTOMLEFT(25, 0)
                :TextColor(0.7, 0.7, 0.7),

            [OnPage] = function(self, page, script)
                if page == 'script' then
                    self.label:SetText(script.name)
                elseif page == 'scratchpad' then
                    self.label:SetText('Scratchpad')
                elseif page == 'raw' then
                    self.label:SetText(script)
                end
            end,
        },

        CodeEditor = CodeEditor
            .TOPLEFT:BOTTOMLEFT(PARENT.EditorHead)
            .RIGHT:RIGHT()
        {
            [SELF.CtrlEnter] = function(self, code)
                local func = assert(loadstring('return function(inspect, trace, this, Addon) ' .. code .. '\n end', "silver editor"))
                local ok, error = pcall(
                    func(),
                    function(frame) DTT.FrameInspector:SetFrameStack(frame) end,
                    function(...) DTT.Tracer:StartTrace(...) end,
                    DTT.FrameInspector.selected,
                    Addon
                )
                if not ok then
                    self:OnError(error)
                end
            end,

            [SELF.OnError] = function(self, error)
                local e = self:GetParent():GetParent().Error
                if error then
                    e.Text:SetText(error)
                    e.Text:Show()
                    e.Background:Show()
                else
                    e.Text:Hide()
                    e.Background:Hide()
                end
            end,

            ['.Editor'] = Style
                :AutoFocus(false),
            paddingBottom = Frame
                .TOP:BOTTOM(PARENT.Editor)
                :Size(1, 50)
        },

    },

    Error = Frame
        :AllPoints()
    {
        Text = FontString
            :Font('Interface/AddOns/DTT/Fonts/iosevka-regular.ttf', 11, '')
            :JustifyH 'LEFT'
            :Hide()
            .BOTTOMLEFT:BOTTOMLEFT(2, 2)
            .BOTTOMRIGHT:BOTTOMRIGHT(-2, 2),

        Background = Texture
            :ColorTexture(0.2, 0.07, 0.07, 0.9)
            .TOPLEFT:TOPLEFT(PARENT.Text, -2, 2)
            .BOTTOMRIGHT:BOTTOMRIGHT(PARENT.Text, 2, -2),
    },

}



local PageSettings = FrameSmoothScroll {

    function(self, parent)
        self.Content.editor = parent
    end,

    ['.Content'] = Style {

        backButton = StyledButton
            .TOPLEFT:TOPLEFT(10, -3)
            :Text '< Back'
            :ToTextSize()
            :Font('Fonts/FRIZQT__.ttf', 12, '')
        {
            [Script.OnClick] = function(self)
                self:GetParent().editor:ShowMain()
            end,
            ['.Text'] = Style
                :TextColor(0.7, 0.7, 0.7)
        },
        label = FontString
            .TOPLEFT:BOTTOMLEFT(PARENT.backButton)
            :Font('Fonts/FRIZQT__.ttf', 16, '')
            :Text 'Settings',

    }

}


local FrameDTT = Frame { PixelAnchor, PixelSizex2 }
    :Width(1000)
    :Height(600)
    .TOPLEFT:TOPLEFT(300, -200)
    :EnableMouse(true)
    :Toplevel(true)
{
    function(self)
        self.editor = self.PageCodeEditor.Content.CodeEditor.Editor
        self.scripts = self.SideBar.Content.Scripts
    end,
    buttons = {},
    scriptEditing = nil,
    ShowMain = function(self)
        self:HideAll()
        self.PageCodeEditor:Show()
        self.FrameInspector:Show()
    end,
    EditScript = function(self, script)
        self:ShowMain()
        self.scriptEditing = script
        -- self.CodeEditor:Show()
        self.editor.Save = function(code)
            if code ~= script.code then
                script.code = code
                self.scripts:Update()
            end
        end
        self.editor:ClearHistory()
        self.editor:SetText(script.code)
        self.editor:SetCursorPosition(0)
        self.editor:SetFocus()
        self.PageCodeEditor:SetVerticalScroll(0)
        OnPage('script', script)
    end,
    RenameScript = function(self, name)
    end,
    NewScript = function(self)
        self.scripts['DTT']:NewScript()
    end,
    EditScratchpad = function(self)
        self:ShowMain()
        self.scriptEditing = 'scratchpad'
        self.editor.Save = function(code)
            DTTSavedVariablesAccount.playground = code
        end
        self.editor:ClearHistory()
        self.editor:SetText(DTTSavedVariablesAccount.playground or '\n\n')
        self.editor:SetCursorPosition(0)
        self.editor:SetFocus()
        self.PageCodeEditor:SetVerticalScroll(0)
        OnPage('scratchpad')
    end,
    EditRawValue = function(self, value, name)
        self:ShowMain()
        self.scriptEditing = 'raw'
        -- self.CodeEditor:Show()
        self.editor.Save = function(code) end
        self.editor:ClearHistory()
        self.editor:SetText(value)
        self.editor:SetCursorPosition(0)
        self.editor:SetFocus()
        self.PageCodeEditor:SetVerticalScroll(0)
        OnPage('raw', name)
    end,
    EnterTrace = function(self)
        self:HideAll()
        self.Tracer:Show()
        OnPage('tracer')
    end,
    HideAll = function(self)
        self.scriptEditing = nil
        self.Tracer:Hide()
        self.PageCodeEditor:Hide()
        self.PageSettings:Hide()
    end,
    EnterSettings = function(self)
        self:HideAll()
        self.FrameInspector:Hide()
        self.PageSettings:Show()
    end,
    NextPage = function(self)
        local scriptButtons = self.scripts['DTT'].scriptButtons
        if self.Tracer:IsShown() then
            self:EditScratchpad()
        elseif self.scriptEditing == 'scratchpad' then
            if #scriptButtons > 0 then
                self:EditScript(scriptButtons[1].script)
            end
        else
            local nextScript
            for i=1, #scriptButtons do
                local b = scriptButtons[i]
                if b.script == self.scriptEditing then
                    nextScript = i+1
                    break
                end
            end
            if nextScript and nextScript <= #scriptButtons and scriptButtons[nextScript]:IsShown() then
                self:EditScript(scriptButtons[nextScript].script)
            end
        end
    end,
    PreviousPage = function(self)
        if self.scriptEditing == 'scratchpad' then
            self:EnterTrace()
        elseif not self.Tracer:IsShown() then
            local previousScript
            for i=1, #self.scripts['DTT'].scriptButtons do
                local b = self.scripts['DTT'].scriptButtons[i]
                if b.script == self.scriptEditing then
                    previousScript = i-1
                    break
                end
            end
            if previousScript then
                if previousScript == 0 then
                    self:EditScratchpad()
                else
                    self:EditScript(self.scripts['DTT'].scriptButtons[previousScript].script)
                end
            end
        end
    end,

    [Script.OnKeyDown] = function(self, key)
        if key == 'ESCAPE' then
            self:SetPropagateKeyboardInput(false)
            self:Hide()
        elseif key == 'TAB' then
            if IsControlKeyDown() then
                self:SetPropagateKeyboardInput(false)
                if IsShiftKeyDown() then
                    self:PreviousPage()
                else
                    self:NextPage()
                end
            end
        else
            self:SetPropagateKeyboardInput(true)
        end
    end,

    Shadow = BoxShadow,

    Title = FontString
        .TOPLEFT:TOPLEFT(8, -4)
        :Height(19)
        :Font('Interface/AddOns/DTT/Fonts/iosevka-regular.ttf', 14, '')
        :Text 'dtt',

    TitleMoveHandler = Frame
        :Height(25)
        -- :FrameLevel(5)
        .TOPLEFT:TOPLEFT()
        .TOPRIGHT:TOPRIGHT()
    {
        [Script.OnMouseDown] = function(self, button)
            if button == 'LeftButton' then
                local x, y = GetCursorPosition()
                local _, _, _, px, py = self:GetParent():GetPoint()
                local scale = self:GetEffectiveScale()
                self.dragOffset = { x/scale - px, y/scale - py }
                self:SetScript('OnUpdate', self.OnUpdate)
            end
        end,
        [Script.OnMouseUp] = function(self, button)
            if button == 'LeftButton' then
                self:SetScript('OnUpdate', nil)
            end
        end,
        OnUpdate = function(self, dt)
            local x, y = GetCursorPosition()
            local from, frame, to, _, _ = self:GetParent():GetPoint()
            local scale = self:GetEffectiveScale()
            self:GetParent():SetPoint(from, frame, to, x/scale - self.dragOffset[1], y/scale - self.dragOffset[2])
        end
    },

    CornerResizer = Frame
        .BOTTOMRIGHT:BOTTOMRIGHT()
        :Size(16, 16)
        :FrameLevel(20)
    {
        [Script.OnMouseDown] = function(self, button)
            if button == 'LeftButton' then
                local x, y = GetCursorPosition()
                self.mouseStart = { x, y }
                local parent = self:GetParent()
                self.startSize = { parent:GetWidth(), parent:GetHeight() }
                self:SetScript('OnUpdate', self.OnUpdate)
            end
        end,
        [Script.OnMouseUp] = function(self, button)
            if button == 'LeftButton' then
                self:SetScript('OnUpdate', nil)
            end
        end,
        OnUpdate = function(self)
            local x, y = GetCursorPosition()
            local scale = self:GetEffectiveScale()
            self:GetParent():SetSize(
                math.max(self.startSize[1] + (x - self.mouseStart[1])/scale, 510),
                math.max(self.startSize[2] + (self.mouseStart[2] - y)/scale, 210)
            )
            -- PixelUtil.SetSize(
            --     self:GetParent(),
            --     self.startSize[1] + (x - self.mouseStart[1])/scale,
            --     self.startSize[2] + (self.mouseStart[2] - y)/scale
            -- )
        end,
        [Script.OnEnter] = function(self)
            SetCursor('Interface/CURSOR/UI-Cursor-SizeRight')
        end,
        [Script.OnLeave] = function(self)
            SetCursor(nil)
        end,
        Texture = Texture
            :AllPoints(PARENT)
            :Texture 'Interface/AddOns/DTT/art/icons/resize'
    },

    Bg = Texture
        :ColorTexture(0.05,0.05,0.05,0.8)
        :AllPoints(PARENT)
        :DrawLayer('BACKGROUND', -7),

    ButtonClose = StyledButton
        :FrameLevel(10)
        .TOPRIGHT:TOPRIGHT(-3, -5)
        :Size(20, 20)
        :Alpha(0.75)
        :NormalTexture 'Interface/AddOns/DTT/art/icons/cross'
    {
        [Script.OnClick] = PARENT.Hide
    },

    ButtonReload = StyledButton
        :Size(20, 20)
        :NormalTexture 'Interface/AddOns/DTT/art/icons/reload'
        :FrameLevel(10)
        -- .RIGHT:LEFT(PARENT.settingsBtn)
        .RIGHT:LEFT(PARENT.ButtonClose)
    {
        [Script.OnClick] = ReloadUI
    },

    ButtonPickFrame = StyledButton
        :NormalTexture 'Interface/AddOns/DTT/art/icons/framepicker'
        :FrameLevel(10)
        :Size(20, 20)
        .RIGHT:LEFT(PARENT.ButtonReload)
    {
        -- [Script.OnClick] = PARENT.FrameInspector.PickFrame -- TODO: fix
        [Script.OnClick] = function(self)
            self:GetParent().FrameInspector:PickFrame()
        end
    },

    SideBar = Addon.DTTSidebar
        .TOPLEFT:TOPLEFT(0, -25)
        .BOTTOMLEFT:BOTTOMLEFT()
        :Width(20),

    PageCodeEditor = PageCodeEditor
        -- .TOPLEFT:TOPLEFT(0, -25)
        .TOPLEFT:TOPRIGHT(PARENT.SideBar)
        .BOTTOMRIGHT:BOTTOMRIGHT(-330, 0),

    PageSettings = PageSettings
        .TOPLEFT:TOPLEFT(0, -30)
        .BOTTOMRIGHT:BOTTOMRIGHT(-30, 0)
        :Hide(),

    Tracer = FrameTraceWindow
        .TOPLEFT:TOPRIGHT(PARENT.SideBar)
        .BOTTOMRIGHT:BOTTOMRIGHT(-330, 0)
        :Hide(),

    FrameInspector = FrameInspector
        .TOPLEFT:TOPRIGHT(PARENT.PageCodeEditor)
        .BOTTOMRIGHT:BOTTOMRIGHT(-10, 0)
    {
        [Hook.ClickEntry] = function(self, table, key)
            if type(table[key]) == 'function' then
                self:GetParent().Tracer:StartTrace(table, key)
            elseif type(table[key]) == 'string' then
                self:GetParent():EditRawValue(table[key], key)
            end
        end,
    }

}


local function spawn()

    FillTypeInfo()

    editorWindow = FrameDTT.new(nil, 'DTT')
    editorWindow:EditScratchpad()
    editorWindow:Show()

end




SLASH_DTT1 = '/dtt'

SlashCmdList['DTT'] = function(msg, editbox)

    if editorWindow then
        if editorWindow:IsShown() then
            editorWindow:Hide()
        else
            editorWindow:Show()
        end
    else
        spawn()
    end

end



