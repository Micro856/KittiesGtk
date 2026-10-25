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
    private unowned Gtk.Button getting;
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
    [GtkChild]
    private unowned Adw.ToastOverlay file_action;
    [GtkChild]
    private unowned Adw.Toast file_saved;
    [GtkChild]
    private unowned Adw.Toast file_error;
    [GtkChild]
    private unowned Adw.Toast file_cancelled;

    private int64 cat_id;
    private string cat_url;
    private GLib.Bytes image_data;
    private Gtk.StringObject selection;
    private GLib.File file;

    private Cancellable cancellable;

    public Window (Gtk.Application app) {
        Object (application: app);

        cat_id_button.notify["value"].connect (() => {
            set_spinner ();
        });

        cat_selector.notify["selected-item"].connect (() => {
            image_render_random ();
        });

        dice.clicked.connect (() => {
            image_render_random ();
        });

        getting.clicked.connect (() => {
            saving ();
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
            getting.set_sensitive (true);
            info_id.show ();
            info_url.show ();
        } catch {
            data_issue.set_revealed (true);
            getting.set_sensitive (false);
            info_id.hide ();
            info_url.hide ();
            image_data = new GLib.Bytes(null);
        }
    }

    private async void image_render () {
        try {
            var to_display = Gdk.Texture.from_bytes (image_data);
            picture.set_paintable (to_display);
        } catch {
            picture.set_paintable (null);
        }
    }

    private async void saving () {
        var dialog = new Gtk.FileDialog ();
        var cat_name = selection.string;
        if (cat_name == "Rory") {
            var initial_url = GLib.Path.get_basename (cat_url);
            var final_url = @"$cat_name$cat_id - $initial_url";
            dialog.set_initial_name (final_url);
        } else {
            var final_url = GLib.Path.get_basename (cat_url);
            dialog.set_initial_name (final_url);
        }
        try {
            file = yield dialog.save (this, cancellable);
            stdout.printf ("%s\n", (string) file.get_path ());
            try {
                var file_stream = file.replace (null, false, FileCreateFlags.NONE);
                if (file.query_exists ()) {
                    file_action.add_toast (file_saved);
                }
                var data_stream = new DataOutputStream (file_stream);
                data_stream.write_bytes (image_data);
            } catch {
                file_action.add_toast (file_error);
            }
        } catch {
            file_action.add_toast (file_cancelled);
        }
    }
}
