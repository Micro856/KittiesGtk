/* backend.vala
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

public class Kittiesgtk.Backend {
    public string image_get_cat () {
        int number = Random.int_range (0, 5); // 2nd digit must be Max +1
        string cat = "Gary";

        if (number == 0) {
            cat = "Garfield";
        } else if (number == 1) {
            cat = "Gary";
        } else if (number == 2) {
            cat = "Goober";
        } else if (number == 3) {
            cat = "Gully";
        } else if (number == 4) {
            cat = "Rory";
        }

        return cat;
    }

    public async int64 image_get_id (string selection, Adw.Banner data_issue) {
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf("GET ID: Read selection: %s\n", selection);
        }
        var cat_id = yield refresh_id (selection, data_issue);
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf ("GET ID: ID: %" + int64.FORMAT + "\n", cat_id);
        }
        return cat_id;
    }

    public async string image_get_url (int64 cat_id, string selection) {
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf("GET URL: Read selection: %s\n", selection);
        }
        var cat_url = yield refresh_url (cat_id, selection);
        if (Config.APP_ID == "io.github.Micro856.KittiesGtkDevel") {
            stdout.printf ("GET URL: Read URL: %s\n", cat_url);
        }

        return cat_url;
    }

    public async GLib.Bytes image_get_data (string cat_url, Gtk.ProgressBar progress) {
        var session = new Soup.Session ();
        var image = new Soup.Message ("GET", @cat_url);
        var image_data = new GLib.Bytes(null);
        try {
            double downloaded = 0;
            double to_download = 0;
            image.got_headers.connect (() => {
                to_download = image.response_headers.get_content_length ();
            });
            progress.set_visible (true);
            image.got_body_data.connect ((read) => {
                downloaded += read;
                var downloaded_prcnt = ( downloaded / to_download );
                progress.set_fraction (downloaded_prcnt);
            });
            image_data = yield session.send_and_read_async (image, GLib.Priority.DEFAULT, null);
            progress.set_fraction (0);
        } catch {
            //data_issue.set_revealed (true);
            progress.set_visible (false);
            //info_bttn.set_sensitive (false);
        }
        return image_data;
    }

    public bool check_mark (string selection, int64 id, string url, GenericArray<string> array) {
        string current = @"$selection-$id-$url";
        bool result = false;
        if (array.find_with_equal_func (current, str_equal) == false) {
            result = false;
        } else {
            result = true;
        }
        return result;
    }

    private async int64 refresh_id (string cat_name, Adw.Banner data_issue) {
        var gary = new Kittiesgtk.GaryApi ();
        var rory = new Kittiesgtk.RoryApi ();
        int64 cat_id = 0;
        try {
            if (cat_name == "Rory") {
                cat_id = yield rory.get_rory_id (data_issue);
            } else {
                cat_id = yield gary.get_gary_id (cat_name, data_issue);
            }
            return cat_id;
        } catch {
            return 0;
        }
    }

    private async string refresh_url (int64 cat_id, string cat_name) {
        var gary = new Kittiesgtk.GaryApi ();
        var rory = new Kittiesgtk.RoryApi ();
        var url = "https://example.org";
        if (cat_name == "Rory") {
            url = yield rory.get_rory_url (cat_id);
        } else  {
            url = gary.get_gary_url (cat_id, cat_name);
        }
        return url;
    }
}

