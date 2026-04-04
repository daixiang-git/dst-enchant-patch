local Widget = require("widgets/widget")
local Templates = require("widgets/redux/templates")
local ImageButton = require("widgets/imagebutton")
local hh_utils = require("utils/hh_utils")
local HH_ITEMS = require("enums/hh_items")

local SCRAPBOOK_XML = "images/scrapbook.xml"
local MAIN_XML, MAIN_TEX = "images/global.xml", "square.tex"
local BUTTON_SCALE = 0x40

local function RebuildGemTemplates(self)
    if self.hh_main == nil or self.hh_main.hh_gem_ui == nil then
        return
    end

    hh_utils:HHKillChild(self.hh_main.hh_gem_ui, "gem_templates")
    self.hh_main.hh_gem_ui.gem_templates = self.hh_main.hh_gem_ui:AddChild(self:CreateTemplates())
    self.hh_main.hh_gem_ui.gem_templates:SetPosition(0x0, -0x14, 0x1)
    self:UpdateTemplates()
end

AddClassPostConstruct("widgets/hh_ui/hh_equip_ui", function(self)
    function self:CreateGemActionSureUi(gem_name, gem_index)
        local size_x, size_y = 0xdc, 0x78
        local btn_size_x, btn_size_y = 0x32, 0x1e
        local padding = 0xa
        local desc = "选" .. "择" .. "操" .. "作" .. "\n" .. tostring(gem_name)

        hh_utils:HHKillChild(self.hh_main, "hh_sure_ui")
        self.hh_main.hh_sure_ui = hh_utils:HHCreateImageUi(self.hh_main, SCRAPBOOK_XML, "scrap_wide.tex", Vector3(0x32, 0x0, 0x1), size_x, size_y)
        local sure_ui = self.hh_main.hh_sure_ui

        sure_ui.hh_desc = hh_utils:HHCreateTextUi(sure_ui, Vector3(0x0, 0x0, 0x1), desc, nil, 0x18)
        local _, desc_size_y = sure_ui.hh_desc:GetRegionSize()
        sure_ui.hh_desc:SetPosition(0x0, size_y / 0x2 - padding - desc_size_y / 0x2, 0x1)

        sure_ui.hh_tip = hh_utils:HHCreateTextUi(sure_ui, Vector3(0x0, 0x0, 0x1), "转" .. "换" .. "：" .. "50%消失 50%变成其他宝石", nil, 0x10, true)
        local _, tip_size_y = sure_ui.hh_tip:GetRegionSize()
        sure_ui.hh_tip:SetPosition(0x0, sure_ui.hh_desc:GetPosition().y - desc_size_y / 0x2 - tip_size_y / 0x2, 0x1)

        local embed_pos_y = -size_y / 0x2 + btn_size_y / 0x2 + padding

        sure_ui.hh_embed = hh_utils:HHCreateImageButton(sure_ui, MAIN_XML, MAIN_TEX, Vector3(-size_x / 0x2 + padding + btn_size_x / 0x2, embed_pos_y, 0x1), btn_size_x / BUTTON_SCALE, btn_size_y / BUTTON_SCALE, { 0x0, 0x0, 0x0, 0.5 })
        sure_ui.hh_embed.hh_text = hh_utils:HHCreateTextUi(sure_ui.hh_embed, Vector3(0x0, 0x0, 0x1), "镶" .. "嵌", nil, 0xf)
        sure_ui.hh_embed:SetOnClick(function()
            SendModRPCToServer(MOD_RPC.hh_rpc.hh_handle_equip, "EquipGems", gem_index)
            hh_utils:HHKillChild(self.hh_main, "hh_sure_ui")
        end)

        sure_ui.hh_convert = hh_utils:HHCreateImageButton(sure_ui, MAIN_XML, MAIN_TEX, Vector3(0x0, embed_pos_y, 0x1), btn_size_x / BUTTON_SCALE, btn_size_y / BUTTON_SCALE, { 0x0, 0x0, 0x0, 0.5 })
        sure_ui.hh_convert.hh_text = hh_utils:HHCreateTextUi(sure_ui.hh_convert, Vector3(0x0, 0x0, 0x1), "转" .. "换", nil, 0xf)
        sure_ui.hh_convert:SetOnClick(function()
            SendModRPCToServer(MOD_RPC.hh_rpc.hh_handle_equip, "EquipGems", "convert:" .. gem_index)
            hh_utils:HHKillChild(self.hh_main, "hh_sure_ui")
        end)

        sure_ui.hh_close = hh_utils:HHCreateImageButton(sure_ui, MAIN_XML, MAIN_TEX, Vector3(size_x / 0x2 - padding - btn_size_x / 0x2, embed_pos_y, 0x1), btn_size_x / BUTTON_SCALE, btn_size_y / BUTTON_SCALE, { 0x0, 0x0, 0x0, 0.5 })
        sure_ui.hh_close.hh_text = hh_utils:HHCreateTextUi(sure_ui.hh_close, Vector3(0x0, 0x0, 0x1), "取" .. "消", nil, 0xf)
        sure_ui.hh_close:SetOnClick(function()
            hh_utils:HHKillChild(self.hh_main, "hh_sure_ui")
        end)
    end

    function self:CreateTemplates()
        local child_size_x, child_size_y = 0x5f, 0x20

        local function ScrollWidgetsCtor(context, index)
            local widget = Widget("widget-" .. index)
            widget:SetOnGainFocus(function()
                if self.hh_main and self.hh_main.hh_gem_ui and self.hh_main.hh_gem_ui.gem_templates then
                    self.hh_main.hh_gem_ui.gem_templates:OnWidgetFocus(widget)
                end
            end)

            widget.hh_background = hh_utils:HHCreateImageUi(widget, MAIN_XML, MAIN_TEX, Vector3(0x0, 0x0, 0x1), 0xa, 0xa, { 0x0, 0x0, 0x0, 0x0 })
            widget.hh_background.hh_btn = widget.hh_background:AddChild(ImageButton(MAIN_XML, MAIN_TEX))
            widget.hh_background.hh_btn.image:SetTint(0x0, 0x0, 0x0, 0.5)
            widget.hh_background.hh_btn:SetNormalScale(child_size_x / BUTTON_SCALE, child_size_y / BUTTON_SCALE, 0x1)
            widget.hh_background.hh_btn:SetPosition(0x0, 0x0, 0x1)
            widget.hh_background.hh_btn.focus_scale = { child_size_x / BUTTON_SCALE, child_size_y / BUTTON_SCALE, 0x1 }
            widget.hh_background.hh_btn.gem_name = hh_utils:HHCreateTextUi(widget.hh_background.hh_btn, Vector3(0x0, 0x0, 0x1), "宝" .. "石", nil, 0x14)
            widget.hh_background.hh_btn.gem_name.gem_num = hh_utils:HHCreateTextUi(widget.hh_background.hh_btn.gem_name, Vector3(0x0, 0x0, 0x1), "宝" .. "石", nil, 0x14)
            return widget
        end

        local function ApplyDataToWidget(context, widget, data, index)
            widget.data = data
            widget.hh_background:Hide()
            if not data then
                return
            end
            widget.hh_background:Show()

            local gem_id = widget.data.id
            if gem_id == nil or HH_ITEMS[gem_id] == nil then
                return
            end

            local gem_name = HH_ITEMS[gem_id].name or "空"
            local gem_num = widget.data.num or "0"
            widget.hh_background.hh_btn.gem_name:SetString(gem_name .. ":")
            local gem_name_size_x = select(1, widget.hh_background.hh_btn.gem_name:GetRegionSize())
            widget.hh_background.hh_btn.gem_name:SetPosition(-child_size_x / 0x2 + 0xa + gem_name_size_x / 0x2, 0x0, 0x1)
            widget.hh_background.hh_btn.gem_name.gem_num:SetString(gem_num)
            local gem_num_size_x = select(1, widget.hh_background.hh_btn.gem_name.gem_num:GetRegionSize())
            widget.hh_background.hh_btn.gem_name.gem_num:SetPosition(gem_name_size_x / 0x2 + gem_num_size_x / 0x2, 0x0, 0x1)

            widget.hh_background.hh_btn:SetOnClick(function()
                local ui_desc = "是" .. "否" .. "镶" .. "嵌"
                local is_special_item = HH_ITEMS[gem_id].is_item

                if gem_id == "a_punchStone" then
                    ui_desc = "是" .. "否" .. "给" .. "装" .. "备" .. "打" .. "孔"
                elseif gem_id == "a_stoneDecoder" then
                    ui_desc = "是" .. "否" .. "随" .. "机" .. "销" .. "毁" .. "一" .. "个" .. "宝" .. "石"
                elseif is_special_item then
                    ui_desc = "使" .. "用" .. gem_name
                else
                    ui_desc = ui_desc .. "\n" .. gem_name
                end

                if gem_id == "a_refreshStone" or gem_id == "z_clean_stone" then
                    return
                end

                if gem_id ~= "a_punchStone" and gem_id ~= "a_stoneDecoder" and not is_special_item then
                    self:CreateGemActionSureUi(gem_name, gem_id)
                    return
                end

                self:CreateSureUi("EquipGems", ui_desc, gem_id, true)
            end)
        end

        local grid = Templates.ScrollingGrid(self.hh_server_items, {
            context = {},
            widget_width = child_size_x,
            widget_height = child_size_y,
            num_visible_rows = 0x4,
            num_columns = 0x3,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn = ApplyDataToWidget,
            scrollbar_offset = 0x5,
            scrollbar_height_offset = 0x0,
            peek_percent = 0x0,
            allow_bottom_empty_row = true,
        })
        grid:SetPosition(0x32, 0x0, 0x1)
        grid.up_button:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
        grid.up_button:SetScale(0.2)
        grid.down_button:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
        grid.down_button:SetScale(-0.2)
        grid.scroll_bar_line:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
        grid.scroll_bar_line:SetScale(0.3)
        grid.position_marker:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
        grid.position_marker.image:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
        grid.position_marker:SetScale(0.3)
        return grid
    end

    RebuildGemTemplates(self)
end)
