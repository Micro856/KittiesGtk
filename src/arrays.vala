/* arrays.vala
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

public class Kittiesgtk.Arrays {
    public void read_array (GenericArray<string> array) {
        var dconf = new Settings ("io.github.Micro856.KittiesGtk");
        var stars = dconf.get_strv ("starred-cats");
        foreach (var i in stars) {
            array.add (i);
        }
    }

    public void write_array (GenericArray<string> array) {
        var dconf = new Settings ("io.github.Micro856.KittiesGtk");
        string[] stars = new string[array.length];
        for (int i = 0; i < array.length; i++) {
            stars[i] = array.get (i);
        }
        dconf.set_strv ("starred-cats", stars);
    }

    public void add_bookmark (string to_add, GenericArray<string> array) {
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
           stdout.printf ("%s\n", to_add);
        }
        array.add (to_add);
        write_array (array);
    }

    public void remove_bookmark (string to_remove, GenericArray<string> array) {
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
           stdout.printf ("%s\n", to_remove);
        }
            for (int i = 0; i < array.length; i++) {
                if (array.get (i) == to_remove) {
                    array.remove_index_fast (i);
                }
            }
        write_array (array);
    }

    public void starred_widget (GenericArray<string> array, Gtk.ScrolledWindow scrolled, Adw.StatusPage empty_starred) {
        read_array (array);

        if (array.length != 0) {
            var bookmarks_box = new Gtk.Box (VERTICAL, 16);
            scrolled.set_child (bookmarks_box);
            var bookmarks = new Adw.PreferencesGroup ();
            bookmarks_box.append (bookmarks);

            array.foreach ((str) => {
                var new_widget = new Adw.ActionRow();

                var no_num = new Regex ("\\d");
                string cat = no_num.replace_literal (str, -1, 0, "");

                var no_txt = new Regex ("[^0-9]");
                var id_str = no_txt.replace_literal (str, -1, 0, "");
                int64 id = id_str.to_int64 ();

                new_widget.set_title (cat);
                new_widget.set_subtitle (id.to_string ());
                bookmarks.add (new_widget);
            });
        } else {
            scrolled.set_child (empty_starred);
        }
    }
}
