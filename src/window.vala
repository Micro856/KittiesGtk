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
    [GtkChild]
    private unowned Adw.NavigationView navigation;
    [GtkChild]
    private unowned Gtk.ScrolledWindow star_list;
    [GtkChild]
    private unowned Gtk.Button mark;
    [GtkChild]
    private unowned Adw.StatusPage empty_starred;
    [GtkChild]
    private unowned Gtk.StringList names;

    private int64 cat_id;
    private string cat_url;
    private GLib.Bytes image_data;
    private Gtk.StringObject selection;
    private string actual_selection;
    private uint selection_id;
    private GLib.File file;
    private Gdk.Texture to_display;
    private bool checked;

    private string change_method = "manual";
    private GenericArray<string> bookmarks_array = new GenericArray<string> ();

    private Kittiesgtk.Backend backend = new Kittiesgtk.Backend ();
    private Kittiesgtk.Arrays arrays = new Kittiesgtk.Arrays ();

    private Cancellable cancellable;

    construct {
        ActionEntry[] action_entries = {
            { "switch_to_garfield", switch_to_garfield },
            { "switch_to_gary", switch_to_gary },
            { "switch_to_goober", switch_to_goober },
            { "switch_to_gully", switch_to_gully },
            { "switch_to_rory", switch_to_rory },
            { "switch_to_surprise", switch_to_surprise },
            { "randomize", random_action },
            { "save", saving_action },
            { "copy", copying_action },
            { "img_number", img_number_window },
            { "open_starred", open_starred },
            { "mark_starred", mark_starred },
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
            if (change_method == "manual") {
                image_render_random_erase ();
            }
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

        mark.clicked.connect (() => {
            mark_starred ();
        });

        data_issue.button_clicked.connect (() => {
            image_render_random ();
        });

        image_issue.button_clicked.connect (() => {
            image_render ();
        });

        names.append (_("Surprise"));
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
        if (selection.string == "Surprise") {
            cat_id_button.set_sensitive (false);
        } else {
            cat_id_button.set_sensitive (true);
        }
    }

    private async void set_spinner () {
        cat_id = (int64) cat_id_button.get_value ();
        info_cat.set_subtitle (actual_selection);
        info_id.set_subtitle (cat_id.to_string ());
        if (actual_selection == "Rory") {
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
        dice.set_sensitive (false);
        data_issue.set_revealed (false);
        image_issue.set_revealed (false);
        getting.set_sensitive (false);
        clipboard.set_sensitive (false);
        mark.set_sensitive (false);
        info_bttn.set_sensitive (false);

        cat_url = yield backend.image_get_url(cat_id, actual_selection);

        if (cat_url != "https://example.org") {
            image_data = yield backend.image_get_data (cat_url, progress);

            if (image_data == null) {
                data_issue.set_revealed (true);
            }

            image_render ();
        } else {
            data_issue.set_revealed (true);
        }
    }

    private async void image_render_random () {
        if (selection.string == "Surprise") {
            actual_selection = backend.image_get_cat ();
        } else {
            actual_selection = selection.string;
        }

        cat_id = yield backend.image_get_id (actual_selection, data_issue);

        cat_id_button.set_value((double) cat_id);
    }

    private async void image_render_random_erase () {
        picture.set_paintable (null);
        yield image_render_random ();
    }

    private void image_render () {
        image_issue.set_revealed (false);
        var renderer = new Kittiesgtk.GlycinRender ();
        to_display = renderer.render (image_data);
        if (to_display == null) {
            if (data_issue.get_revealed () == false) {
                image_issue.set_revealed (true);
            }
        } else {
            picture.set_paintable (to_display);
        }
        checked = backend.check_mark (actual_selection, cat_id, bookmarks_array);
        mark_appearance ();
        progress.set_visible (false);
        getting.set_sensitive (true);
        clipboard.set_sensitive (true);
        mark.set_sensitive (true);
        info_bttn.set_sensitive (true);
        dice.set_sensitive (true);
    }

    private async void saving () {
        var dialog = new Gtk.FileDialog ();
        var cat_name = actual_selection;
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
        } else if ( cat  == "Surprise" ) {
            switch_to_surprise ();
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

    private void switch_to_surprise () {
        cat_selector.set_selected (5);
    }

    private void img_number_window () {
        if (selection.string != "Surprise") {
            var current_value = cat_id_button.get_value ();
            cat_id_button_window.set_value (current_value);
            cat_selector_window.present (this);
        }
    }

    private void open_starred () {
        if (navigation.get_visible_page_tag () != "stars") {
            bookmarks_array = new GenericArray<string> ();
            arrays.starred_widget (bookmarks_array, star_list, empty_starred);
            navigation.push_by_tag ("stars");
            // if (change_method == "manual") {
            //     change_method = "via-bookmark";
            // } else if (change_method == "via-bookmark") {
            //     change_method = "manual";
            // }
        } else {
            navigation.pop_to_tag ("main");
        }
    }

    private void mark_appearance () {
        if (checked == false) {
            mark.set_icon_name ("non-starred-symbolic");
            mark.set_tooltip_text (C_("Button tooltip", "Mark as Starred"));
        } else {
            mark.set_icon_name ("starred-symbolic");
            mark.set_tooltip_text (C_("Button tooltip", "Unmark as Starred"));
        }
    }

    private void mark_starred () {
        string current = @"$actual_selection$cat_id";
        if (checked == false) {
            arrays.add_bookmark (current, bookmarks_array);
        } else {
            arrays.remove_bookmark (current, bookmarks_array);
        }
        checked = backend.check_mark (actual_selection, cat_id, bookmarks_array);
        mark_appearance ();
    }
}
