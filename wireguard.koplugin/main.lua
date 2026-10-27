local WidgetContainer = require("ui/widget/container/widgetcontainer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local Notification = require("ui/widget/notification")
local Dispatcher = require("dispatcher")
local _ = require("gettext")

local WireGuard = WidgetContainer:extend{
    name = "wireguard",
    is_doc_only = false,
}

local CONTROL_SCRIPT = "./plugins/wireguard.koplugin/bin/wg-control.sh"

function WireGuard:init()
    self.ui.menu:registerToMainMenu(self)
    self:onDispatcherRegisterActions()

    if G_reader_settings:isTrue("wireguard_autoconnect") then
        UIManager:scheduleIn(3, function()
            self:connect(true)
        end)
    end
end

function WireGuard:execCmd(action)
    local cmd = string.format("/bin/sh %q %s", CONTROL_SCRIPT, action)
    local handle = io.popen(cmd)
    if not handle then return "" end
    local output = handle:read("*a") or ""
    handle:close()
    return output:gsub("^%s*(.-)%s*$", "%1")
end

function WireGuard:isConnected()
    local output = self:execCmd("status")
    return output:find("WG ON") ~= nil
end

function WireGuard:connect(silent)
    if not silent then
        UIManager:show(Notification:new{
            text = _("WireGuard: Iniciando túnel..."),
            timeout = 3,
        })
    end

    UIManager:scheduleIn(0.5, function()
        self:execCmd("up")
        local status = self:execCmd("status")
        
        if not silent then
            if status:find("WG ON") then
                UIManager:show(Notification:new{
                    text = _("WireGuard: Conectado con éxito"),
                    timeout = 3,
                })
            else
                UIManager:show(InfoMessage:new{
                    text = _("WireGuard: Error al conectar.\n\n") .. status,
                })
            end
        end
    end)
end

function WireGuard:disconnect()
    self:execCmd("down")
    UIManager:show(Notification:new{
        text = _("WireGuard: Desconectado"),
        timeout = 2,
    })
end

function WireGuard:showStatus()
    local status = self:execCmd("status")
    local last_log = self:execCmd("log")
    
    local msg = string.format(
        "Estado del Túnel:\n%s\n\nÚltimo Log:\n%s",
        status,
        last_log
    )
    UIManager:show(InfoMessage:new{
        text = msg,
    })
end

function WireGuard:onExit()
    if G_reader_settings:isTrue("wireguard_autodisconnect") and self:isConnected() then
        self:execCmd("down")
    end
end

function WireGuard:onDispatcherRegisterActions()
    Dispatcher:registerAction("toggle_wireguard_vpn", {
        category = "none",
        event = "ToggleWireGuardVPN",
        title = _("Toggle WireGuard VPN"),
        general = true,
    })
end

function WireGuard:addToMainMenu(menu_items)
    menu_items.wireguard = {
        text = _("WireGuard VPN"),
        sorting_hint = "network",
        sub_item_table = {
            {
                text = _("▶ Conectar VPN"),
                keep_menu_open = true,
                enabled_func = function()
                    return not self:isConnected()
                end,
                callback = function(touchmenu_instance)
                    self:connect(false)
                    if touchmenu_instance then touchmenu_instance:updateItems() end
                end,
            },
            {
                text = _("■ Desconectar VPN"),
                keep_menu_open = true,
                enabled_func = function()
                    return self:isConnected()
                end,
                callback = function(touchmenu_instance)
                    self:disconnect()
                    if touchmenu_instance then touchmenu_instance:updateItems() end
                end,
            },
            {
                text = _("ℹ Estado del Túnel"),
                keep_menu_open = true,
                callback = function()
                    self:showStatus()
                end,
            },
            {
                text = _("⚡ Conectar al iniciar KOReader"),
                keep_menu_open = true,
                checked_func = function()
                    return G_reader_settings:isTrue("wireguard_autoconnect")
                end,
                callback = function(touchmenu_instance)
                    local cur = G_reader_settings:isTrue("wireguard_autoconnect")
                    G_reader_settings:saveSetting("wireguard_autoconnect", not cur)
                    G_reader_settings:flush()
                    if touchmenu_instance then touchmenu_instance:updateItems() end
                end,
            },
            {
                text = _("⏹ Desconectar al salir de KOReader"),
                keep_menu_open = true,
                checked_func = function()
                    return G_reader_settings:isTrue("wireguard_autodisconnect")
                end,
                callback = function(touchmenu_instance)
                    local cur = G_reader_settings:isTrue("wireguard_autodisconnect")
                    G_reader_settings:saveSetting("wireguard_autodisconnect", not cur)
                    G_reader_settings:flush()
                    if touchmenu_instance then touchmenu_instance:updateItems() end
                end,
            },
        },
    }
end

return WireGuard