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
    [GtkChild]
    private unowned Adw.SpinRow cat_id_button;
    [GtkChild]
    private unowned Adw.ActionRow info_cat;
    [GtkChild]
    private unowned Adw.ActionRow info_id;
    [GtkChild]
    private unowned Adw.ActionRow info_url;
    [GtkChild]
    private unowned Adw.ActionRow info_copying;
    [GtkChild]
    private unowned Adw.ActionRow info_api;

    private int64 cat_id;
    private string cat_url;
    private GLib.Bytes image_data;
    private Gtk.StringObject selection;

    public Window (Gtk.Application app) {
        Object (application: app);

        cat_id_button.notify["value"].connect (() => {
            set_spinner();
        });

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

    private async void set_spinner() {
        cat_id = (int64) cat_id_button.get_value();
        info_cat.set_subtitle (selection.string);
        info_id.set_subtitle (cat_id.to_string ());
        if (selection.string == "Rory") {
            info_copying.show ();
            info_copying.set_subtitle ("<a href='https://rory.cat/license/'>CC BY 4.0</a>");
        } else {
            info_copying.hide ();
        }
        if (selection.string == "Rory") {
            info_api.set_subtitle ("<a href='https://rory.cat/'>rory.cat</a>");
        } else {
            info_api.set_subtitle ("<a href='https://api.garythe.cat/'>api.garythe.cat</a>");
        }
        yield image_get ();
        info_url.set_subtitle (@"<a href='$cat_url'>$cat_url</a>");
    }

    private async void image_get () {
        yield image_get_url();
        yield image_get_data ();
        image_render ();
    }

    private async void image_render_random () {
        yield image_get_id();
    }

    private async void image_get_id () {
        selection = cat_selector.get_selected_item() as Gtk.StringObject;
        stdout.printf("%s\n", selection.string);
        var backend = new Kittiesgtk.Backend ();
        cat_id = yield backend.refresh_id (selection.string);
        stdout.printf ("ID: %" + int64.FORMAT + "\n", cat_id);
        cat_id_button.set_value((double) cat_id);
    }

    private async void image_get_url () {
        selection = cat_selector.get_selected_item() as Gtk.StringObject;
        stdout.printf("%s\n", selection.string);
        var backend = new Kittiesgtk.Backend ();
        cat_url = yield backend.refresh_url (cat_id, selection.string);
        stdout.printf ("%s\n", cat_url);
    }

    private async void image_get_data () {
        var session = new Soup.Session ();
        var image = new Soup.Message ("GET", @cat_url);
        try {
            data_issue.set_revealed (false);
            image_data = yield session.send_and_read_async (image, GLib.Priority.DEFAULT, null);
        } catch {
            data_issue.set_revealed (true);
        }
    }

    private async void image_render () {
        var to_display = Gdk.Texture.from_bytes (image_data);
        picture.set_paintable (to_display);
    }
}
