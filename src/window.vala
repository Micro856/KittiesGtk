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
    private unowned Gtk.Button clipboard;
    [GtkChild]
    private unowned Adw.ComboRow cat_selector;
    [GtkChild]
    private unowned Adw.Banner data_issue;
    [GtkChild]
    private unowned Adw.Banner image_issue;
    [GtkChild]
    private unowned Adw.SpinRow cat_id_button;
    [GtkChild]
    private unowned Gtk.SpinButton cat_id_button_window;
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
    [GtkChild]
    private unowned Adw.Toast file_copied;
    [GtkChild]
    private unowned Gtk.MenuButton cat_popover;
    [GtkChild]
    private unowned Gtk.MenuButton info_bttn;
    [GtkChild]
    private unowned Adw.Dialog cat_selector_window;
    [GtkChild]
    private unowned Gtk.ProgressBar progress;

    private int64 cat_id;
    private string cat_url;
    private GLib.Bytes image_data;
    private Gtk.StringObject selection;
    private uint selection_id;
    private GLib.File file;
    private Gdk.Texture to_display;

    private Kittiesgtk.Backend backend = new Kittiesgtk.Backend ();

    private Cancellable cancellable;

    construct {
        ActionEntry[] action_entries = {
            { "switch_to_garfield", switch_to_garfield },
            { "switch_to_gary", switch_to_gary },
            { "switch_to_goober", switch_to_goober },
            { "switch_to_gully", switch_to_gully },
            { "switch_to_rory", switch_to_rory },
            { "randomize", random_action },
            { "save", saving_action },
            { "copy", copying_action },
            { "img_number", img_number_window }
        };
        this.add_action_entries (action_entries, this);
    }

    public Window (Gtk.Application app) {
        Object (application: app);

        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            add_css_class ("devel");
        }

        cat_id_button.notify["value"].connect (() => {
            set_spinner ();
        });

        cat_selector.notify["selected-item"].connect (() => {
            set_popover_title ();
            set_cat_dconf ();
            image_render_random_erase ();
        });

        dice.clicked.connect (() => {
            image_render_random ();
        });

        getting.clicked.connect (() => {
            saving ();
        });

        clipboard.clicked.connect (() => {
            copying ();
        });

        data_issue.button_clicked.connect (() => {
            image_render_random ();
        });

        data_issue.notify["revealed"].connect (() => {
            if ( data_issue.get_revealed () == true ) {
                getting.set_sensitive (false);
                clipboard.set_sensitive (false);
                dice.set_sensitive (true);
            } else {
                getting.set_sensitive (true);
                clipboard.set_sensitive (true);
            }
        });

        image_issue.button_clicked.connect (() => {
            image_render ();
        });

        image_issue.notify["revealed"].connect (() => {
            if ( image_issue.get_revealed () == true ) {
                getting.set_sensitive (false);
                clipboard.set_sensitive (false);
                dice.set_sensitive (true);
            } else {
                getting.set_sensitive (true);
                clipboard.set_sensitive (false);
            }
        });

        get_cat_dconf ();
        set_popover_title ();
        if ( selection_id == 0 ) {
            image_render_random ();
        }
}

    private void set_popover_title () {
        selection = cat_selector.get_selected_item () as Gtk.StringObject;
        selection_id = cat_selector.get_selected ();
        cat_popover.set_label(selection.string);
    }

    private async void set_spinner () {
        cat_id = (int64) cat_id_button.get_value ();
        info_cat.set_subtitle (selection.string);
        info_id.set_subtitle (cat_id.to_string ());
        if (selection.string == "Rory") {
            info_copying.show ();
            info_copying.set_subtitle ("<a href='https://rory.cat/license/'>CC BY 4.0</a>");
            info_api.set_subtitle ("<a href='https://rory.cat/'>rory.cat</a>");
        } else {
            info_copying.hide ();
            info_api.set_subtitle ("<a href='https://api.garythe.cat/'>api.garythe.cat</a>");
        }
        yield image_get ();
        info_url.set_subtitle (@"<a href='$cat_url'>$cat_url</a>");
    }

    private async void image_get () {
        getting.set_sensitive (false);
        clipboard.set_sensitive (false);
        yield image_get_url();
        yield image_get_data ();
        image_render ();
    }

    private async void image_render_random () {
        dice.set_sensitive (false);
        data_issue.set_revealed (false);
        image_issue.set_revealed (false);
        getting.set_sensitive (false);
        clipboard.set_sensitive (false);
        info_bttn.set_sensitive (false);

        cat_id = yield backend.image_get_id (selection, data_issue);

        cat_id_button.set_value((double) cat_id);
    }

    private async void image_render_random_erase () {
        picture.set_paintable (null);
        yield image_render_random ();
    }

    private async void image_get_url () {
        selection = cat_selector.get_selected_item () as Gtk.StringObject;
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf("GET URL: Read selection: %s\n", selection.string);
        }
        cat_url = yield backend.refresh_url (cat_id, selection.string);
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf ("GET URL: Read URL: %s\n", cat_url);
        }
    }

    private async void image_get_data () {
        var session = new Soup.Session ();
        var image = new Soup.Message ("GET", @cat_url);
        try {
            progress.set_visible (true);
            double downloaded = 0;
            double to_download = 0;
            data_issue.set_revealed (false);
            image.got_headers.connect (() => {
                to_download = image.response_headers.get_content_length ();
            });
            image.got_body_data.connect ((read) => {
                downloaded += read;
                var downloaded_prcnt = ( downloaded / to_download );
                progress.set_fraction (downloaded_prcnt);
            });
            image_data = yield session.send_and_read_async (image, GLib.Priority.DEFAULT, null);
            progress.set_fraction (0);
        } catch {
            data_issue.set_revealed (true);
            progress.set_visible (false);
            info_bttn.set_sensitive (false);
            image_data = new GLib.Bytes(null);
        }
    }

    private void image_render () {
        try {
            image_issue.set_revealed (false);
            var renderer = new Kittiesgtk.GlycinRender ();
            to_display = renderer.render (image_data);
            picture.set_paintable (to_display);
            progress.set_visible (false);
            getting.set_sensitive (true);
            clipboard.set_sensitive (true);
            info_bttn.set_sensitive (true);
            dice.set_sensitive (true);
        } catch {
            if (data_issue.get_revealed () == false) {
                image_issue.set_revealed (true);
            }
            progress.set_visible (false);
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
            if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
                stdout.printf ("SAVING: Read path: %s\n", (string) file.get_path ());
            }
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

    private void copying () {
        var display = Gdk.Display.get_default ();
        var saver = display.get_clipboard ();
        saver.set_texture(to_display);
        file_action.add_toast (file_copied);
    }

    private void get_cat_dconf () {
        var dconf = new Settings ("io.github.Micro856.KittiesGtk");
        var cat = dconf.get_string ("selected-cat");

        if ( cat  == "Gary" ) {
            switch_to_gary ();
        } else if ( cat  == "Garfield" ) {
            switch_to_garfield ();
        } else if ( cat  == "Goober" ) {
            switch_to_goober ();
        } else if ( cat  == "Gully" ) {
            switch_to_gully ();
        } else if ( cat  == "Rory" ) {
            switch_to_rory ();
        } else {
            switch_to_gary ();
        }
    }

    private void set_cat_dconf () {
        var dconf = new Settings ("io.github.Micro856.KittiesGtk");

        dconf.set_string ("selected-cat", selection.string);
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf("Saved value: %s\n", dconf.get_string ("selected-cat"));
        }
    }

    private void random_action () {
        var disabled = dice.get_sensitive ();
        if ( disabled ) {
            image_render_random.begin();
        }
    }

    private void saving_action () {
        var disabled = getting.get_sensitive ();
        if ( disabled ) {
            saving.begin();
        }
    }

    private void copying_action () {
        var disabled = clipboard.get_sensitive ();
        if ( disabled ) {
            copying();
        }
    }

    private void switch_to_garfield () {
        cat_selector.set_selected (0);
    }

    private void switch_to_gary () {
        cat_selector.set_selected (1);
    }

    private void switch_to_goober () {
        cat_selector.set_selected (2);
    }

    private void switch_to_gully () {
        cat_selector.set_selected (3);
    }

    private void switch_to_rory () {
        cat_selector.set_selected (4);
    }

    private void img_number_window () {
        var current_value = cat_id_button.get_value ();
        cat_id_button_window.set_value (current_value);
        cat_selector_window.present (this);
    }
}
