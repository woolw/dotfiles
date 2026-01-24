import { Astal, Gtk, Gdk } from "ags/gtk4";
import app from "ags/gtk4/app";
import Apps from "gi://AstalApps";
import Gio from "gi://Gio";

const appsService = new Apps.Apps();

type ResultItem = { type: "app"; app: Apps.Application } | { type: "web"; query: string };

let currentResults: ResultItem[] = [];
let selectedIndex = 0;
let buttons: Gtk.Button[] = [];

function updateSelection() {
  buttons.forEach((btn, i) => {
    if (i === selectedIndex) {
      btn.add_css_class("selected");
    } else {
      btn.remove_css_class("selected");
    }
  });
}

function createResultButton(item: ResultItem, index: number): Gtk.Button {
  const button = new Gtk.Button();
  button.add_css_class("app-item");
  if (index === 0) button.add_css_class("selected");

  const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL });

  if (item.type === "app") {
    const icon = new Gtk.Image({
      iconName: item.app.iconName || "application-x-executable",
    });
    icon.add_css_class("app-icon");

    const labelBox = new Gtk.Box({
      orientation: Gtk.Orientation.VERTICAL,
      valign: Gtk.Align.CENTER,
    });

    const nameLabel = new Gtk.Label({
      label: item.app.name,
      halign: Gtk.Align.START,
      ellipsize: 3,
    });
    nameLabel.add_css_class("app-name");

    labelBox.append(nameLabel);
    box.append(icon);
    box.append(labelBox);

    button.connect("clicked", () => {
      item.app.launch();
      app.toggle_window("launcher");
    });
  } else {
    const icon = new Gtk.Image({ iconName: "web-browser-symbolic" });
    icon.add_css_class("app-icon");

    const labelBox = new Gtk.Box({
      orientation: Gtk.Orientation.VERTICAL,
      valign: Gtk.Align.CENTER,
    });

    const nameLabel = new Gtk.Label({
      label: `Search: ${item.query}`,
      halign: Gtk.Align.START,
      ellipsize: 3,
    });
    nameLabel.add_css_class("app-name");

    labelBox.append(nameLabel);
    box.append(icon);
    box.append(labelBox);

    button.connect("clicked", () => {
      Gio.AppInfo.launch_default_for_uri(`https://search.brave.com/search?q=${encodeURIComponent(item.query)}`, null);
      app.toggle_window("launcher");
    });
  }

  button.set_child(box);
  return button;
}

export default function Launcher() {
  const resultsBox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    visible: false,
  });
  resultsBox.add_css_class("results");

  const container = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
  });
  container.add_css_class("launcher-container");

  let winRef: Astal.Window | null = null;

  const updateResults = (text: string) => {
    // Clear existing children
    let child = resultsBox.get_first_child();
    while (child) {
      const next = child.get_next_sibling();
      resultsBox.remove(child);
      child = next;
    }
    buttons = [];
    currentResults = [];
    selectedIndex = 0;

    if (text.length === 0) {
      resultsBox.visible = false;
      return;
    }

    // Web search mode
    if (text.startsWith("?")) {
      const query = text.slice(1).trim();
      if (query.length === 0) {
        resultsBox.visible = false;
        return;
      }
      currentResults = [{ type: "web", query }];
      const btn = createResultButton(currentResults[0], 0);
      buttons.push(btn);
      resultsBox.append(btn);
      resultsBox.visible = true;
      return;
    }

    // App search mode
    const results = appsService.fuzzy_query(text).slice(0, 8);
    if (results.length === 0) {
      resultsBox.visible = false;
      return;
    }

    currentResults = results.map(a => ({ type: "app" as const, app: a }));
    currentResults.forEach((item, index) => {
      const btn = createResultButton(item, index);
      buttons.push(btn);
      resultsBox.append(btn);
    });
    resultsBox.visible = true;
  };

  const launchSelected = () => {
    if (currentResults.length > 0 && selectedIndex < currentResults.length) {
      const item = currentResults[selectedIndex];
      if (item.type === "app") {
        item.app.launch();
      } else {
        Gio.AppInfo.launch_default_for_uri(`https://search.brave.com/search?q=${encodeURIComponent(item.query)}`, null);
      }
      app.toggle_window("launcher");
    }
  };

  const entry = (
    <entry
      cssClasses={["search-entry"]}
      placeholderText="Search..."
      hexpand
      onChanged={(self) => updateResults(self.text)}
      onActivate={() => launchSelected()}
    />
  ) as Gtk.Entry;

  const searchBox = new Gtk.Box();
  searchBox.add_css_class("search-box");

  const searchIcon = new Gtk.Image({ iconName: "system-search-symbolic" });
  searchIcon.add_css_class("search-icon");

  searchBox.append(searchIcon);
  searchBox.append(entry);

  container.append(searchBox);
  container.append(resultsBox);

  const win = (
    <window
      name="launcher"
      cssClasses={["Launcher"]}
      application={app}
      visible={false}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={Astal.WindowAnchor.TOP}
    >
      {container}
    </window>
  ) as Astal.Window;

  winRef = win;

  // Focus entry and clear when shown
  app.connect("window-toggled", (_, w) => {
    if (w.name === "launcher" && w.visible) {
      entry.text = "";
      updateResults("");
      entry.grab_focus();
    }
  });

  // Key handling - attach to entry so it captures keys while typing
  const keyController = new Gtk.EventControllerKey();
  keyController.connect(
    "key-pressed",
    (_: Gtk.EventControllerKey, keyval: number) => {
      if (keyval === Gdk.KEY_Escape) {
        app.toggle_window("launcher");
        return true;
      }
      if (keyval === Gdk.KEY_Down || keyval === Gdk.KEY_Tab) {
        if (currentResults.length > 0) {
          selectedIndex = (selectedIndex + 1) % currentResults.length;
          updateSelection();
        }
        return true;
      }
      if (keyval === Gdk.KEY_Up) {
        if (currentResults.length > 0) {
          selectedIndex = (selectedIndex - 1 + currentResults.length) % currentResults.length;
          updateSelection();
        }
        return true;
      }
      return false;
    },
  );
  entry.add_controller(keyController);

  return win;
}
