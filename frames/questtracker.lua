local _, ns = ...
local lqt = ns.lqt
local Style, Frame, Texture, FontString = lqt.Style, lqt.Frame, lqt.Texture, lqt.FontString


local addon = Frame.new()


ObjectiveTrackerFrame.IsUserPlaced = function() return true end

Style(ObjectiveTrackerFrame)
    -- :Points { TOPRIGHT = Minimap:BOTTOMRIGHT(-15, 0) }
    :Points { TOPRIGHT = MinimapCluster:BOTTOMRIGHT(35, -20) }
    :Height(600)
{
    -- Style'.BlocksFrame.QuestHeader' {
    --     Style'.Background':Texture '',
    --     Style'.Text':Alpha(0)
    -- },

}


local trackerHeaderAlpha = 0.1
local trackerHeaderAlphaTarget = 0


OBJECTIVE_TRACKER_TEXT_WIDTH = 350


local hooks = {
    OnEnter = function()
        trackerHeaderAlphaTarget = 1
    end,
    OnLeave = function()
        trackerHeaderAlphaTarget = 0
    end
}


local function update_size()
    Style(ObjectiveTrackerFrame)
        :Width(400)
        :Alpha(0.5)
    {
        -- Texture'.Bg'
        --     :ColorTexture(0, 0, 0, 0.3)
        --     :AllPoints(ObjectiveTrackerFrame),
        Style'.BlocksFrame'
            :Hook(hooks)
        {
            --Style'.Button':Hide(),
            -- Style'.Button' {
            --     function(self)
            --         local _, p, _, _, _ = self:GetPoint()
            --         self:Points {
            --             TOPLEFT = p:TOPRIGHT(5, 0)
            --         }
            --     end
            -- },
            Style'.Button':Hook(hooks),
            Style'.Frame'
                :SetWidth(350)
                :Hook(hooks)
            {
                Style'.HeaderButton':Hook(hooks),
                Style'.HeaderText':SetJustifyH('RIGHT'),
                Style'.Frame':Hook(hooks) {
                    Style'.Text':SetJustifyH('RIGHT'):SetWidth(OBJECTIVE_TRACKER_TEXT_WIDTH-10),
                    Style'.Dash':Hide(),
                    Style'.Check':Hide(),
                },
                Style:FitToChildren(),
            },
            Style:FitToChildren()
        }
    }
end


addon:EventHook {
    PLAYER_ENTERING_WORLD = update_size,
    QUEST_WATCH_LIST_CHANGED = update_size,
    QUEST_LOG_UPDATE = update_size,
    SUPER_TRACKING_CHANGED = update_size
}


Style(ObjectiveTrackerFrame.HeaderMenu) {
    Style'.Button':Hook(hooks),
    Frame'.HoverFrame'
        :FrameStrata('BACKGROUND', -1)
        :TOPLEFT(ObjectiveTrackerFrame:TOPLEFT())
        :TOPRIGHT(ObjectiveTrackerFrame:TOPRIGHT())
        :Height(42)
        :Hook(hooks)
        :Hook {
            OnMouseDown = function(self)
                self:GetParent().MinimizeButton:Click()
            end
        }
}


for frame in ObjectiveTrackerFrame.BlocksFrame'.Frame' do
    if frame.MinimizeButton and frame.Background then
        Style(frame) {
            Style'.MinimizeButton'
                :Hook(hooks)
                :Hook {
                    OnClick = update_size
                },
            Style'.Background':Hide(),
            Frame'.HoverFrame'
                -- :FrameStrata 'BACKGROUND'
                :Hook(hooks)
                :Hook {
                    OnMouseDown = function(self)
                        self:GetParent().MinimizeButton:Click()
                    end
                }
                .init(function(self, parent) self:SetAllPoints(parent) end)
        }
    end
end



local addon = CreateFrame('Frame')

addon:RegisterEvent('QUEST_WATCH_LIST_CHANGED')
addon:RegisterEvent('SUPER_TRACKING_CHANGED')


addon:Hook {
    OnEvent = function()
        for frame in ObjectiveTrackerFrame.BlocksFrame'.Frame' do
            if frame.MinimizeButton and frame.Background then
                frame.MinimizeButton:SetAlpha(math.sqrt(trackerHeaderAlpha))
            end
        end
    end,
    OnUpdate = function(self, dt)
        if trackerHeaderAlphaTarget ~= trackerHeaderAlpha then
            local sign = trackerHeaderAlpha >= trackerHeaderAlphaTarget and -1 or 1
            trackerHeaderAlpha = math.min(1, math.max(0, trackerHeaderAlpha + sign * dt*5))
            local anim = math.sqrt(trackerHeaderAlpha)

            
            ObjectiveTrackerFrame:SetAlpha(0.5 + trackerHeaderAlpha/2)
            -- ObjectiveTrackerFrame.Bg:SetAlpha(anim)
            ObjectiveTrackerFrame.HeaderMenu:SetAlpha(anim)
            for frame in ObjectiveTrackerFrame.BlocksFrame'.Frame' do
                if frame.MinimizeButton and frame.Background then
                    frame:SetAlpha(anim)
                    frame.MinimizeButton:SetAlpha(anim)
                end
            end
            for btn in ObjectiveTrackerFrame.BlocksFrame'.Button' do
                btn:SetAlpha(anim)
            end
        end
    end
}