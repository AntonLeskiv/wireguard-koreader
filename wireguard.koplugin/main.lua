local WidgetContainer = require("ui/widget/container/widgetcontainer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local Notification = require("ui/widget/notification")
local LuaSettings = require("luasettings")
local DataStorage = require("datastorage")
local _ = require("gettext")

local WireGuard = WidgetContainer:extend{
    name = "wireguard",
    is_doc_only = false,
}

local function getPluginDir()
    local src = debug.getinfo(1, "S").source:sub(2)
    return src:match("(.*/)") or "/mnt/us/koreader/plugins/wireguard.koplugin/"
end

function WireGuard:init()
    self.plugin_dir = getPluginDir()
    self.control_script = self.plugin_dir .. "bin/wg-control.sh"
    
    local settings_path = DataStorage:getSettingsDir() .. "/wireguard_settings.lua"
    self.settings = LuaSettings:open(settings_path)

    self.ui.menu:registerToMainMenu(self)

    if self.settings:isTrue("autoconnect") then
        UIManager:scheduleIn(3, function()
            self:connect(true)
        end)
    end
end

function WireGuard:execCmd(action)
    local cmd = string.format("/bin/sh %q %s", self.control_script, action)
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
    if self.settings:isTrue("autodisconnect") and self:isConnected() then
        self:execCmd("down")
    end
end

function WireGuard:addToMainMenu(menu_items)
    menu_items.wireguard = {
        text = _("WireGuard VPN"),
        sorting_hint = "network",
        sub_item_table = {
            {
                text = _("▶ Conectar VPN"),
                enabled_func = function()
                    return not self:isConnected()
                end,
                callback = function()
                    self:connect(false)
                end,
            },
            {
                text = _("■ Desconectar VPN"),
                enabled_func = function()
                    return self:isConnected()
                end,
                callback = function()
                    self:disconnect()
                end,
            },
            {
                text = _("ℹ Estado del Túnel"),
                callback = function()
                    self:showStatus()
                end,
            },
            {
                text = _("⚡ Conectar al iniciar KOReader"),
                checked_func = function()
                    return self.settings:isTrue("autoconnect")
                end,
                callback = function()
                    local cur = self.settings:isTrue("autoconnect")
                    self.settings:saveSetting("autoconnect", not cur)
                    self.settings:flush()
                end,
            },
            {
                text = _("⏹ Desconectar al salir de KOReader"),
                checked_func = function()
                    return self.settings:isTrue("autodisconnect")
                end,
                callback = function()
                    local cur = self.settings:isTrue("autodisconnect")
                    self.settings:saveSetting("autodisconnect", not cur)
                    self.settings:flush()
                end,
            },
        },
    }
end

return WireGuard