/* application.vala
 *
 * Copyright 2026 Marcel Mrówka
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Kittiesgtk.Application : Adw.Application {
    public Application () {
        Object (
            application_id: "io.github.Micro856.KittiesGtk",
            flags: ApplicationFlags.DEFAULT_FLAGS,
            resource_base_path: "/io/github/Micro856/KittiesGtk"
        );
    }

    construct {
        ActionEntry[] action_entries = {
            { "about", this.on_about_action },
            { "quit", this.quit }
        };
        this.add_action_entries (action_entries, this);
        this.set_accels_for_action ("win.switch_to_garfield", {"<control>1"});
        this.set_accels_for_action ("win.switch_to_gary", {"<control>2"});
        this.set_accels_for_action ("win.switch_to_goober", {"<control>3"});
        this.set_accels_for_action ("win.switch_to_gully", {"<control>4"});
        this.set_accels_for_action ("win.switch_to_rory", {"<control>5"});
        this.set_accels_for_action ("win.randomize", {"<control>r"});
        this.set_accels_for_action ("win.img_number", {"<control><shift>r"});
        this.set_accels_for_action ("win.save", {"<control>s"});
        this.set_accels_for_action ("app.quit", {"<control>q"});
    }

    public override void activate () {
        base.activate ();
        var win = this.active_window ?? new Kittiesgtk.Window (this);
        win.present ();
    }

    private void on_about_action () {
        string[] developers = { "Marcel Mrówka https://micro856.github.io" };
        var about = new Adw.AboutDialog () {
            application_name = "Kitties",
            application_icon = "io.github.Micro856.KittiesGtk",
            developer_name = "Marcel Mrówka",
            translator_credits = _("translator-credits"),
            version = "0.1.0",
            developers = developers,
            copyright = _("""© 2026 Marcel Mrówka

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see https://www.gnu.org/licenses/."""),
        };

        about.present (this.active_window);
    }
}
