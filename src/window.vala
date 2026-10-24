/* window.vala
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

[GtkTemplate (ui = "/io/github/Micro856/KittiesGtk/window.ui")]
public class Kittiesgtk.Window : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Gtk.Picture picture;
    [GtkChild]
    private unowned Gtk.Button dice;
    [GtkChild]
    private unowned Gtk.DropDown cat_selector;
    [GtkChild]
    private unowned Adw.Banner data_issue;

    public Window (Gtk.Application app) {
        Object (application: app);

        cat_selector.notify["selected-item"].connect (() => {
            image_render_random ();
        });

        dice.clicked.connect (() => {
            image_render_random ();
        });

        data_issue.button_clicked.connect (() => {
            image_render_random ();
        });

        image_render_random ();
        }

    private async void image_render_random () {
        var selection = cat_selector.get_selected_item() as Gtk.StringObject;

        stdout.printf("%s\n", selection.string);

        var backend = new Kittiesgtk.Backend ();

        var cat_id = yield backend.refresh_id (selection.string);
        stdout.printf ("ID: %" + int64.FORMAT + "\n", cat_id);

        var url = yield backend.refresh_url (cat_id, selection.string);
        stdout.printf ("%s\n", url);

        var session = new Soup.Session ();
        var image = new Soup.Message ("GET", @url);
        try {
            data_issue.set_revealed (false);
            GLib.Bytes image_data = yield session.send_and_read_async (image, GLib.Priority.DEFAULT, null);
            var to_display = Gdk.Texture.from_bytes (image_data);
            picture.set_paintable (to_display);
        } catch {
            data_issue.set_revealed (true);
        }
    }
}
