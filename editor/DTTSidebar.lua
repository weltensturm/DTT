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
local RenameBox = Addon.RenameBox
local FrameInspector = Addon.FrameInspector
local PixelAnchor = Addon.Templates.PixelAnchor
local PixelSizex2 = Addon.Templates.PixelSizex2
local Event = Addon.Event
local BubbleScript = Addon.BubbleScript
local StyledButton = Addon.StyledButton
local ExpandDownMenu = Addon.ExpandDownMenu
local ExpandDownButton = Addon.ExpandDownButton

local TraceReceived = Addon.TraceReceived
local SidebarEnter = Event()
local SidebarLeave = Event()
local SidebarAnim = Event()
local OnPage = Event()
Addon.OnPage = OnPage


local CubicInOut = function(x)
    return x < 0.5
        and 4 * x^3
         or 1 - (-2 * x + 2)^3 / 2;
end


local BubbleHover = Style { BubbleScript.OnEnter, BubbleScript.OnLeave }


local SidebarButton = StyledButton { BubbleHover } {

    Selected = Texture
        .LEFT:LEFT(3.5, 0)
        :Size(14, 14)
        :Texture 'Interface/AddOns/DTT/art/icons/circle'
        :Hide(),

    [SidebarAnim] = function(self, state)
        self.Text:SetAlpha(state)
    end,

    ['.Text'] = Style
        :JustifyH 'LEFT'
        :ClearAllPoints()
        :Font('Fonts/ARIALN.TTF', 12, '')
        .TOPLEFT:TOPLEFT(21, 0)
        .BOTTOMLEFT:BOTTOMLEFT(21, 0),
}



local ScriptEntry = Frame { BubbleHover } {
    Update = function(self)
        if self.settings.enabled then
            self.ContextMenu.Toggle:SetText('Disable')
            self.Disabled:Hide()
            self.Enabled:Show()
        else
            self.ContextMenu.Toggle:SetText('Run automatically')
            self.Disabled:Show()
            self.Enabled:Hide()
        end
    end,
    SetData = function(self, name, script, settings)
        self.Button:SetText(script.name)
        self.Button.Name:SetText(script.name)
        self.Button.Name:SetCursorPosition(0)
        self.name = name
        self.script = script
        self.settings = settings or { enabled=false }
        self:Update()
    end,
    Reset = function(self)
        self.script.code = self.script.code_original
        self:Update()
    end,
    Edit = function(self)
        DTT:EditScript(self.script)
    end,
    SetName = function(self, name)
        self.script.name = name
    end,
    Rename = function(self)
        self.Button.Name:Edit()
    end,

    [SidebarAnim] = function(self, state)
        self.Button.Name:SetAlpha(state)
        self.ContextMenu:SetAlpha(state)
        self.ActiveBg:SetAlpha(state*0.2)
    end,

    [OnPage] = function(self, page, script)
        local show = page == 'script' and self.script == script
        self.Selected:SetShown(show)
        self.ActiveBg:SetShown(show)
    end,

    Button = StyledButton { BubbleHover }
        :AllPoints()
        :RegisterForClicks('AnyUp')
    {
        ['.Text'] = Style:Alpha(0),

        Name = RenameBox { BubbleHover }
            .TOPLEFT:TOPLEFT(10, 0)
            .BOTTOMRIGHT:BOTTOMRIGHT()
            :EnableMouse(false)
        {
            [SELF.Edit] = function(self)
                SidebarEnter('keyboard')
            end,
            [SELF.Save] = function(self)
                self:GetParent():GetParent():SetName(self:GetText())
                self:GetParent():GetParent():Edit()
                SidebarLeave('keyboard')
            end,
            [SELF.Cancel] = function(self)
                SidebarLeave('keyboard')
            end,
        },

        [Script.OnClick] = function(self, button)
            if button == 'LeftButton' then
                -- editorWindow.CodeEditor.Content.Editor:SetText(self.script.code)
                -- editorWindow.CodeEditor.Content.Editor:SetCursorPosition(0)
                self:GetParent():Edit()
            elseif button == 'RightButton' then
                self:GetParent().ContextMenu:MenuToggle()
            end
        end,
    },

    ActiveBg = Texture
        -- :ColorTexture(0.3, 0.3, 0.3)
        :Texture 'Interface/BUTTONS/UI-Listbox-Highlight2'
        :BlendMode 'ADD'
        :VertexColor(1,1,1,0.2)
        :Hide()
        :AllPoints(PARENT),

    Enabled = Texture
        .LEFT:LEFT(3.5, 0)
        :Size(14, 14)
        :Texture 'Interface/AddOns/DTT/art/icons/dot'
        :VertexColor(1, 1, 1, 0.5)
        :Hide(),

    Disabled = Texture
        .LEFT:LEFT(3.5, 0)
        :Size(14, 14)
        :Texture 'Interface/AddOns/DTT/art/icons/dot-split'
        :VertexColor(1, 1, 1, 0.5)
        :Hide(),

    Selected = Texture
        .LEFT:LEFT(3.5, 0)
        :Size(14, 14)
        :Texture 'Interface/AddOns/DTT/art/icons/circle'
        :Hide(),

    ContextMenu = ExpandDownMenu { BubbleHover } {
        [Hook.MenuOpen] = function(self)
            SidebarEnter('dropdown')
        end,
        [Hook.MenuClose] = function(self)
            SidebarLeave('dropdown')
        end,

        ['.Content'] = BubbleHover,

        Run = ExpandDownButton { BubbleHover }
            :Text 'Run'
            :Click(function(parent)
                Scripts.ExecuteScript(parent.script)
            end),
        Rename = ExpandDownButton { BubbleHover }
            :Text 'Rename'
            :Click(function(parent)
                parent.Button.Name:Edit()
            end),
        Copy = ExpandDownButton { BubbleHover }
            :Text 'Copy'
            :Click(function(parent)
                local name, script = Scripts.CopyScript(parent.script)
                parent:GetParent():Update()
                DTT:EditScript(script)
            end),
        Toggle = ExpandDownButton { BubbleHover }
            :Text 'Disable'
            :Click(function(parent)
                parent.settings.enabled = not parent.settings.enabled
                parent:Update()
            end),
        Delete = ExpandDownButton { BubbleHover }
            :Text 'Delete'
            :Click(function(parent)
                Scripts.DeleteScript(parent.script)
                parent:GetParent():Update()
            end),
    }
}


local FrameAddonSection = Frame { BubbleHover }
    :Height(28)
{
    scriptButtons = {},
    Update = function(self)
        for _, button in pairs(self.scriptButtons) do
            button:Hide()
            button:SetPoint('TOP', self, 'TOP')
        end
        local height = 28
        local previous
        for i, script in pairs(DTTSavedVariablesAccount.scripts) do
            if not self.scriptButtons[i] then
                self.scriptButtons[i] = ScriptEntry
                    :Height(18)
                    .RIGHT:RIGHT()
                    .new(self)
            end
            local button = self.scriptButtons[i]
            if previous then
                button:SetPoint('TOPLEFT', previous.ContextMenu, 'BOTTOMLEFT', 0, -1)
            else
                button:SetPoint('TOPLEFT', self, 'TOPLEFT')
            end
            button:SetData(script.name, script, DTTSavedVariablesCharacter.scripts[script.name])
            button:Show()
            height = height + button:GetHeight()
            previous = button
        end
        self:SetHeight(height)
    end,
    NewScript = function(self)
        local script = Scripts.NewScript()
        self:Update()
        for _, button in pairs(self.scriptButtons) do
            if button.script.name == script then
                button:Rename()
                break
            end
        end
    end,
    Toggle = function(self)
        self.settings.enabled = not self.settings.enabled
    end,

    [Script.OnShow] = function(self)
        self:Update()
    end,

}



Addon.DTTSidebar = FrameSmoothScroll
    :EnableMouse(true)
{
    anim = 1,
    animTarget = 0,
    entered = {},

    Expand = function(self)
        self.animTarget = 1
    end,

    Contract = function(self)
        self.animTarget = 0
    end,

    [SidebarEnter] = function(self, obj)
        self.entered[obj] = true
        self:Expand()
    end,
    [Script.OnEnter] = function(self)
        SidebarEnter('mouse')
    end,

    [SidebarLeave] = function(self, obj)
        self.entered[obj] = nil
        if not next(self.entered) then
            self:Contract()
        end
    end,
    [Script.OnLeave] = function(self)
        SidebarLeave('mouse')
    end,

    [Script.OnUpdate] = function(self, dt)
        if self.anim ~= self.animTarget then
            local sign = self.anim >= self.animTarget and -1 or 1
            local new = math.max(sign > 0 and 0 or self.animTarget,
                                 math.min(sign > 0 and self.animTarget or 1,
                                          self.anim + sign * dt*5))
            self.anim = new
            self:SetWidth(20 + 130 * CubicInOut(self.anim))
            SidebarAnim(self.anim)
        end
    end,

    ['.Content'] = Style { BubbleHover } {

        EnterTrace = StyledButton { BubbleHover }
            .TOPLEFT:TOPLEFT(0, -6)
            .TOPRIGHT:TOPRIGHT(0, -6)
            :Height(20)
            :Text 'Tracers'
        {
            [Script.OnClick] = function(self)
                DTT:EnterTrace()
            end,

            [SidebarAnim] = function(self, state)
                self.Text:SetAlpha(state)
                self.ActiveBg:SetAlpha(state*0.2)
            end,

            [OnPage] = function(self, page)
                self.Selected:SetShown(page == 'tracer')
                self.ActiveBg:SetShown(page == 'tracer')
            end,

            ActiveBg = Texture
                :Texture 'Interface/BUTTONS/UI-Listbox-Highlight2'
                :BlendMode 'ADD'
                :VertexColor(1,1,1,0.2)
                :Hide()
                :AllPoints(PARENT),

            Crosshair = Texture
                .LEFT:LEFT(3.5, 0)
                :Size(14, 14)
                :Texture 'Interface/AddOns/DTT/art/icons/crosshair'
                :Alpha(0.5),

            HitMarker = Texture
                .LEFT:LEFT(3.5, 0)
                :Size(14, 14)
                :Texture 'Interface/AddOns/DTT/art/icons/hitmarker'
                :VertexColor(1, 1, 0)
                :Alpha(0)
            {
                [TraceReceived] = function(self)
                    self:SetAlpha(1)
                end
            },
            [Script.OnUpdate] = function(self, dt)
                local current = self.HitMarker:GetAlpha()
                if current > 0 then
                    self.HitMarker:SetAlpha(math.max(current - dt*2, 0))
                end
            end,

            Selected = Texture
                .LEFT:LEFT(3.5, 0)
                :Size(14, 14)
                :Texture 'Interface/AddOns/DTT/art/icons/circle'
                :Hide(),

            ['.Text'] = Style
                :JustifyH 'LEFT'
                :ClearAllPoints()
                :Font('Fonts/ARIALN.TTF', 12, '')
                .TOPLEFT:TOPLEFT(21, 0)
                .BOTTOMLEFT:BOTTOMLEFT(21, 0),
        },

        ScriptsLabel = FontString
            .TOPLEFT:BOTTOMLEFT(PARENT.EnterTrace, 10, 0)
            -- .RIGHT:RIGHT()
            :Height(25)
            :JustifyH 'LEFT'
            :Font('Fonts/FRIZQT__.ttf', 12)
            :Text 'Scripts'
            :TextColor(0.6, 0.6, 0.6),
        ScriptAdd = Button { BubbleHover }
            .LEFT:RIGHT(PARENT.ScriptsLabel, 2, 0)
            :Size(14, 14)
            :NormalTexture 'Interface/AddOns/DTT/art/icons/plus'
        {
            [Script.OnClick] = function(self)
                DTT:NewScript()
            end,
        },
        [SidebarAnim] = function(self, state)
            self.ScriptsLabel:SetAlpha(state)
            self.ScriptAdd:SetAlpha(state)
        end,

        Scratchpad = SidebarButton
            .TOPLEFT:BOTTOMLEFT(PARENT.ScriptsLabel, -10, 0)
            .RIGHT:RIGHT()
            :Text 'Scratchpad'
        {
            Smile = Texture
                .LEFT:LEFT(3.5, 0)
                :Size(14, 14)
                :Texture 'Interface/AddOns/DTT/art/icons/smile'
                :VertexColor(1, 1, 1, 0.5),
            ActiveBg = Texture
                :Texture 'Interface/BUTTONS/UI-Listbox-Highlight2'
                :BlendMode 'ADD'
                :VertexColor(1,1,1,0.2)
                :Hide()
                :AllPoints(PARENT),
            [Script.OnClick] = function(self)
                DTT:EditScratchpad()
            end,
            [OnPage] = function(self, page)
                self.Selected:SetShown(page == 'scratchpad')
                self.ActiveBg:SetShown(page == 'scratchpad')
            end,
            [SidebarAnim] = function(self, state)
                self.ActiveBg:SetAlpha(0.2*state)
            end
        },

        Scripts = Frame { BubbleHover }
            .TOPLEFT:BOTTOMLEFT(PARENT.Scratchpad)
            .RIGHT:RIGHT()
        {
            function(self, parent)
                Style {
                    DTT = FrameAddonSection
                        .TOPLEFT:TOPLEFT()
                        .RIGHT:RIGHT()
                        :Update()
                }(self)
                self:SetHeight(self.DTT:GetHeight())
            end,

            Update = function(self)
                for script in query(self, '.*') do
                    script:Update()
                end
            end
        },
    },

}
