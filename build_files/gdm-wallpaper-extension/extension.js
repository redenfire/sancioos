import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import Gio from 'gi://Gio';
import St from 'gi://St';

export default class GdmWallpaperExtension extends Extension {
    enable() {
        const monitorManager = global.backend.get_monitor_manager();
        const monitor = monitorManager.get_monitors()[0];
        const background = new St.Widget({
            style_class: 'gdm-wallpaper',
            style: `background-image: url('file:///usr/share/backgrounds/wallpaper.png'); background-size: cover;`,
            width: monitor.geometry.width,
            height: monitor.geometry.height,
        });
        global.stage.add_child(background);
        this._background = background;
    }

    disable() {
        if (this._background) {
            this._background.destroy();
            this._background = null;
        }
    }
}