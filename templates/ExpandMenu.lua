---@class Addon
local Addon = select(2, ...)

local LQT = Addon.LQT
local Script = LQT.Script
local Style = LQT.Style
local Frame = LQT.Frame
local Button = LQT.Button
local Texture = LQT.Texture
local FontString = LQT.FontString
local EditBox = LQT.EditBox
local ScrollFrame = LQT.ScrollFrame
local PARENT = LQT.PARENT

-- local Event = Addon.Event
local BubbleScript = Addon.BubbleScript
local CubicInOut = Addon.CubicInOut

-- local SidebarEnter = Event()
-- local SidebarLeave = Event()

local BubbleHover = Style { BubbleScript.OnEnter, BubbleScript.OnLeave }


Addon.ExpandDownButton = Button
    :RegisterForClicks('LeftButtonUp', 'LeftButtonDown')
    :Height(16)
{
    function(self, parent)
        -- table.insert(parent.buttons, self)
        self.menu = parent
        self.menu:MenuAddButton(self)
    end,
    SetText = function(self, ...)
        self.Text:SetText(...)
    end,
    SetClick = function(self, fn)
        self.Click = fn
    end,

    [Script.OnEnter] = function(self)
        self.hoverBg:Show()
    end,
    [Script.OnLeave] = function(self)
        self.hoverBg:Hide()
    end,

    [Script.OnClick] = function(self, button, down)
        if down then
            self.menu.ClickTracker:SetFocus()
        else
            self.menu:MenuClose()
            if self.Click then
                self.Click(self.menu:GetParent())
            end
        end
    end,

    Text = FontString
        :SetFont('Fonts/ARIALN.ttf', 12)
        .LEFT:LEFT(12, 0)
        :JustifyH 'LEFT',
    hoverBg = Texture
        -- :ColorTexture(0.3, 0.3, 0.3)
        :Texture 'Interface/BUTTONS/UI-Listbox-Highlight2'
        :BlendMode 'ADD'
        :VertexColor(1,1,1,0.2)
        :Hide()
        :AllPoints(PARENT),
}


Addon.ExpandDownMenu = ScrollFrame
    .TOPLEFT:BOTTOMLEFT()
    .TOPRIGHT:BOTTOMRIGHT()
    :Height(1)
{
    buttons = {},

    function(self, parent)
        self:SetScrollChild(self.Container)
    end,

    MenuAddButton = function(self, button)
        button:SetParent(self.Container)
        table.insert(self.buttons, button)
    end,

    MenuOpen = function(self)
        self.ClickTracker:SetFocus()
        -- SidebarEnter('dropdown')
        local previous = nil
        local width = 1
        local height = 0
        for _, btn in pairs(self.buttons) do
            btn:SetPoint('RIGHT', self, 'RIGHT')
            if previous then
                btn:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT')
            else
                btn:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, -1)
            end
            height = height + btn:GetHeight()
            previous = btn
        end
        -- self:SetSize(width+24, height+12)
        self.targetHeight = height + 1
        self.animTarget = 1
    end,

    MenuClose = function(self)
        -- SidebarLeave('dropdown')
        self.animTarget = 0
    end,

    MenuToggle = function(self)
        if self.animTarget == 1 then
            self:MenuClose()
        else
            self:MenuOpen()
        end
    end,

    [Script.OnHide] = function(self)
        self.anim = 0
        self:SetHeight(1)
    end,

    Container = Frame
        :AllPoints(PARENT),

    ClickTracker = EditBox
        :AutoFocus(false)
        :Alpha(0)
        .BOTTOM:TOP(UIParent)
        :PropagateKeyboardInput(true)
    {
        [Script.OnEditFocusLost] = function(self)
            self:GetParent():MenuClose()
        end,
        [Script.OnEditFocusGained] = function(self)
            self:GetParent():MenuOpen()
        end
    },

    background = Texture
        .TOPLEFT:TOPLEFT(0, -1)
        .BOTTOMRIGHT:BOTTOMRIGHT()
        :ColorTexture(0, 0, 0, 0.5),

    anim = 0,
    animTarget = 0,
    [Script.OnUpdate] = function(self, dt)
        if self.anim ~= self.animTarget then
            local sign = self.anim >= self.animTarget and -1 or 1
            local new = math.max(sign > 0 and 0 or self.animTarget,
                                 math.min(sign > 0 and self.animTarget or 1,
                                          self.anim + sign * dt*5))
            self.anim = new
            self:SetHeight(1 + self.targetHeight * CubicInOut(self.anim))
        end
    end,

}
