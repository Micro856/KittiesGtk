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
    private unowned Gtk.Button back;
    [GtkChild]
    private unowned Gtk.Button next;
    [GtkChild]
    private unowned Adw.ComboRow cat_selector;
    [GtkChild]
    private unowned Adw.Banner data_issue;
    [GtkChild]
    private unowned Adw.Banner image_issue;
    [GtkChild]
    private unowned Adw.Banner data_404;
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
    [GtkChild]
    private unowned Adw.Dialog pref_window;
    [GtkChild]
    private unowned Adw.SpinRow history_spinner;
    [GtkChild]
    private unowned Adw.PreferencesGroup cat_fact;
    [GtkChild]
    private unowned Adw.ActionRow rudi_fact;
    [GtkChild]
    private unowned Adw.ActionRow miziany_fact;
    [GtkChild]
    private unowned Gtk.Image cat_fact_img;

    private int64 cat_id;
    private string cat_url;
    private GLib.Bytes image_data;
    private Gtk.StringObject selection;
    private string actual_selection;
    private uint selection_id; // 5 is Surprise
    private GLib.File file;
    private Gdk.Texture to_display;
    private bool checked;

    private string change_method = "manual";
    private string render_method = "render";
    private GenericArray<string> bookmarks_array = new GenericArray<string> ();

    private GenericArray<string> last_cats = new GenericArray<string> ();
    private GenericArray<GLib.Bytes> last_cats_data = new GenericArray<GLib.Bytes> ();
    private uint last_cat_indexer = 0;
    private uint last_cat_last_indexer = 0;
    private int max_last;

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
            { "go_back", go_back_action },
            { "go_next", go_next_action },
            { "add_one", add_one_action },
            { "rm_one", rm_one_action },
            { "preferences", pref_window_action },
        };
        this.add_action_entries (action_entries, this);
        getting = lookup_action ("save") as SimpleAction;
        clipboard = lookup_action ("copy") as SimpleAction;
    }

    private SimpleAction getting;
    private SimpleAction clipboard;

    public Window (Gtk.Application app) {
        Object (application: app);

        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            add_css_class ("devel");
        }

        history_spinner.notify["value"].connect (() => {
            max_last = (int)  history_spinner.get_value ();
            set_history_dconf ();
        });

        cat_id_button.notify["value"].connect (() => {
            if (change_method == "manual") {
                set_spinner_online ();
            }
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

        back.clicked.connect (() => {
            go_back_one ();
        });

        next.clicked.connect (() => {
            go_forward_one ();
        });

        mark.clicked.connect (() => {
            mark_starred ();
        });

        data_issue.button_clicked.connect (() => {
            image_render_random ();
        });

        data_issue.notify["revealed"].connect (() => {
            if ( data_issue.get_revealed () == true ) {
                dice.set_sensitive (true);
            }
        });

        data_404.button_clicked.connect (() => {
            image_render_random ();
        });

        data_404.notify["revealed"].connect (() => {
            if ( data_404.get_revealed () == true ) {
                dice.set_sensitive (true);
            }
        });

        image_issue.button_clicked.connect (() => {
            image_render ();
        });

        image_issue.notify["revealed"].connect (() => {
            if ( image_issue.get_revealed () == true ) {
                dice.set_sensitive (true);
            }
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
        if (selection_id == 5) {
            cat_id_button.set_sensitive (false);
        } else {
            cat_id_button.set_sensitive (true);
        }
    }

    private void set_spinner () {
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
    }

    private async void set_spinner_online () {
        cat_id = (int64) cat_id_button.get_value ();
        set_spinner ();
        yield image_get ();
        info_url.set_subtitle (@"<a href='$cat_url'>$cat_url</a>");
    }

    private async void image_get () {
        dice.set_sensitive (false);
        data_issue.set_revealed (false);
        data_404.set_revealed (false);
        image_issue.set_revealed (false);
        getting.set_enabled (false);
        clipboard.set_enabled (false);
        mark.set_sensitive (false);
        info_bttn.set_sensitive (false);

        render_method = "render";

        cat_url = yield backend.image_get_url(cat_id, actual_selection);

        if (cat_url == "this rory does not exist") {
            data_404.set_revealed (true);
            progress.set_visible (false);
        } else if (cat_url != "https://example.org" && cat_id != 0) {
            image_data = yield backend.image_get_data (cat_url, progress);

            if (image_data.length == 153) {
                data_404.set_revealed (true);
                progress.set_visible (false);
            } else if (image_data == null) {
                data_issue.set_revealed (true);
            } else {
                clean_last_override ();
                image_render ();
            }
        } else {
            data_issue.set_revealed (true);
        }
    }

    private async void image_render_random () {
        if (selection_id == 5) {
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

            if (render_method == "render") {
                var sel = selection.string;
                last_cats.add (@"$sel-$actual_selection-$cat_id-$cat_url");
                last_cats_data.add (image_data);
                clean_last_above();
            }

            control_navigation ();

            checked = backend.check_mark (actual_selection, cat_id, cat_url, bookmarks_array);
            mark_appearance ();
            getting.set_enabled (true);
            clipboard.set_enabled (true);
            mark.set_sensitive (true);
            info_bttn.set_sensitive (true);
            image_issue.set_revealed (false);
        }
        progress.set_visible (false);
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
        var history = dconf.get_int ("history");

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

        if ( history <= 0 || history > 50 ) {
            max_last = 15;
        } else {
            max_last = history;
        }

        history_spinner.set_value (max_last);
    }

    private void set_cat_dconf () {
        var dconf = new Settings ("io.github.Micro856.KittiesGtk");

        string value = "Surprise";

        if ( selection_id  == 1 ) {
            value = "Gary";
        } else if ( selection_id  == 0 ) {
            value = "Garfield";
        } else if ( selection_id  == 2 ) {
            value = "Gober";
        } else if ( selection_id  == 3 ) {
            value = "Gully";
        } else if ( selection_id  == 4 ) {
            value = "Rory";
        } else if ( selection_id  == 5 ) {
            value = "Surprise";
        }

        dconf.set_string ("selected-cat", value);
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf("Saved value: %s\n", dconf.get_string ("selected-cat"));
        }
    }

    private void set_history_dconf () {
        var dconf = new Settings ("io.github.Micro856.KittiesGtk");

        dconf.set_int ("history", max_last);
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf("Saved history value: %d\n", dconf.get_int ("history"));
        }
    }

    private void random_action () {
        var disabled = dice.get_sensitive ();
        if ( disabled ) {
            image_render_random.begin();
        }
    }

    private void saving_action () {
        var disabled = getting.get_enabled ();
        if ( disabled != false ) {
            saving.begin();
        }
    }

    private void copying_action () {
        var disabled = clipboard.get_enabled ();
        if ( disabled != false ) {
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
        if (selection_id != 5) {
            var current_value = cat_id_button.get_value ();
            cat_id_button_window.set_value (current_value);
            cat_selector_window.present (this);
        }
    }

    private void open_starred () {
        if (navigation.get_visible_page_tag () != "stars") {
            bookmarks_array = new GenericArray<string> ();
            arrays.starred_widget (bookmarks_array, star_list, empty_starred, this);
            navigation.push_by_tag ("stars");
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
        string current = @"$actual_selection-$cat_id-$cat_url";
        if (checked == false) {
            arrays.add_bookmark (current, bookmarks_array);
        } else {
            arrays.remove_bookmark (current, bookmarks_array);
        }
        checked = backend.check_mark (actual_selection, cat_id, cat_url, bookmarks_array);
        mark_appearance ();
    }

    public void show_cat (string cat, int64 id, string url) {
        change_method = "auto";
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
        set_popover_title ();
        actual_selection = cat;
        var looked = @"$cat-$cat-$id-$url";
        var looked2 = @"Surprise-$cat-$id-$url";
        var looked_result = last_cats.find_with_equal_func(looked, str_equal);
        var looked2_result = last_cats.find_with_equal_func(looked2, str_equal);

        if (looked_result == true || looked2_result == true) {
            bool found = false;
            for (int i = 0; i < last_cats.length; i++) {
                    if ((last_cats.get (i) == looked || last_cats.get (i) == looked2) && found == false) {
                        var history = arrays.regex (last_cats.get (i));
                        cat_url = url;
                        info_url.set_subtitle (@"<a href='$cat_url'>$cat_url</a>");
                        cat_id_button.set_value((double) id);
                        cat_id = (int64) cat_id_button.get_value ();
                        image_data = last_cats_data.get (i);
                        set_spinner ();
                        image_render ();
                        change_method = "manual";
                        found = true;
                    }
            }
        } else {
            change_method = "manual";
            cat_id_button.set_value((double) id);
        }
        if (navigation.get_visible_page_tag () == "stars") {
            navigation.pop_to_tag ("main");
        }
    }

    private void clean_last_above () {
        if (last_cats.length > max_last) {
            last_cats.remove_index (0);
            last_cats_data.remove_index (0);
        }
    }

    private void clean_last_override () {
        if (last_cat_indexer > 0) {
            var i = last_cats.length - 1 - last_cat_indexer;
            while (last_cats.length != i + 1) {
                last_cats.remove_index (i + 1);
                last_cats_data.remove_index (i + 1);
            }
            last_cat_indexer = 0;
            last_cat_last_indexer = 1;
        }
    }

    private void go_back_one () {
        last_cat_last_indexer = last_cat_indexer;
        last_cat_indexer++;
        var str = last_cats.get (last_cats.length - 1 - last_cat_indexer);
        var history = arrays.regex (str);
        var select = history[0];
        var act_select = history[1];
        var id_str = history[2];
        int64 id = int64.parse(id_str);
        var url = history[3];
        var img = last_cats_data.get (last_cats_data.length - 1 - last_cat_indexer);
        show_cat_history (select, act_select, id, url, img);
    }

    private void go_forward_one () {
        last_cat_last_indexer = last_cat_indexer;
        last_cat_indexer--;
        var str = last_cats.get (last_cats.length - 1 - last_cat_indexer);
        var history = arrays.regex (str);
        var select = history[0];
        var act_select = history[1];
        var id_str = history[2];
        int64 id = int64.parse(id_str);
        var url = history[3];
        var img = last_cats_data.get (last_cats_data.length - 1 - last_cat_indexer);
        show_cat_history (select, act_select, id, url, img);
    }

    private void show_cat_history (string select, string act_select, int64 id, string url, GLib.Bytes img) {
        change_method = "auto";
        if ( select  == "Gary" ) {
            switch_to_gary ();
        } else if ( select  == "Garfield" ) {
            switch_to_garfield ();
        } else if ( select  == "Goober" ) {
            switch_to_goober ();
        } else if ( select  == "Gully" ) {
            switch_to_gully ();
        } else if ( select  == "Rory" ) {
            switch_to_rory ();
        } else if ( select  == "Surprise" ) {
            switch_to_surprise ();
        } else {
            switch_to_gary ();
        }
        set_popover_title ();
        actual_selection = act_select;
        cat_url = url;
        info_url.set_subtitle (@"<a href='$url'>$url</a>");
        cat_id_button.set_value((double) id);
        cat_id = (int64) cat_id_button.get_value ();
        image_data = img;
        set_spinner ();
        render_method = "history";
        image_render ();
        change_method = "manual";
    }

    private void control_navigation () {
        back.set_sensitive (false);
        next.set_sensitive (false);
        if (last_cat_indexer < (last_cats.length - 1) && last_cats.length != 1) {
            back.set_sensitive (true);
        }
        if (last_cat_indexer != 0 && last_cat_indexer < last_cats.length) {
            next.set_sensitive (true);
        }
    }

    private void go_back_action () {
        var disabled = back.get_sensitive ();
        if ( disabled ) {
            go_back_one ();
        }
    }

    private void go_next_action () {
        var disabled = next.get_sensitive ();
        if ( disabled ) {
            go_forward_one ();
        }
    }

    private void add_one_action () {
        var disabled = dice.get_sensitive ();
        if ( disabled && selection_id != 5) {
            cat_id++;
            cat_id_button.set_value((double) cat_id);
        }
    }

    private void rm_one_action () {
        var disabled = dice.get_sensitive ();
        if ( disabled && selection_id != 5) {
            cat_id--;
            cat_id_button.set_value((double) cat_id);
        }
    }

    private void pref_window_action () {
        cat_fact_img.set_from_icon_name (Config.APP_ID);
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            miziany_fact.add_prefix (cat_fact_img);
            cat_fact.add (miziany_fact);
        } else {
            rudi_fact.add_prefix (cat_fact_img);
            cat_fact.add (rudi_fact);
        }
        pref_window.present (this);
    }
}
