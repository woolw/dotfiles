import { Gtk } from "ags/gtk4"
import Tray from "gi://AstalTray"

const tray = Tray.get_default()

export default function SystemTray() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("tray")

    const items = new Map<string, Gtk.Widget>()

    const addItem = (item: Tray.TrayItem) => {
        const menuBtn = new Gtk.MenuButton()
        menuBtn.add_css_class("tray-item")

        const icon = new Gtk.Image()
        icon.add_css_class("tray-icon")

        if (item.gicon) {
            icon.set_from_gicon(item.gicon)
        } else if (item.iconName) {
            icon.iconName = item.iconName
        }

        menuBtn.set_child(icon)

        const popover = Gtk.PopoverMenu.new_from_model(item.menuModel)
        menuBtn.set_popover(popover)

        if (item.actionGroup) {
            popover.insert_action_group("dbusmenu", item.actionGroup)
        }

        item.connect("notify::menu-model", () => {
            popover.set_menu_model(item.menuModel)
        })
        item.connect("notify::action-group", () => {
            if (item.actionGroup) {
                popover.insert_action_group("dbusmenu", item.actionGroup)
            }
        })

        items.set(item.itemId, menuBtn)
        box.append(menuBtn)

        item.connect("notify::gicon", () => {
            if (item.gicon) {
                icon.set_from_gicon(item.gicon)
            }
        })
        item.connect("notify::icon-name", () => {
            if (item.iconName) {
                icon.iconName = item.iconName
            }
        })
    }

    const removeItem = (itemId: string) => {
        const widget = items.get(itemId)
        if (widget) {
            box.remove(widget)
            items.delete(itemId)
        }
    }

    tray.get_items().forEach(addItem)

    tray.connect("item-added", (_tray, itemId: string) => {
        const item = tray.get_item(itemId)
        if (item) addItem(item)
    })
    tray.connect("item-removed", (_tray, itemId: string) => {
        removeItem(itemId)
    })

    return box
}
