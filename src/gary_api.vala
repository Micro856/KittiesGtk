/* gary_api.vala
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

public class Kittiesgtk.GaryApi {
    public async int64 get_gary_id (string cat_name) {
        var session = new Soup.Session ();
        var url = "https://api.garythe.cat/gary";

        if (cat_name == "Gary") {
            url = "https://api.garythe.cat/gary";
        } else if (cat_name == "Goober") {
            url = "https://api.garythe.cat/goober";
        } else if (cat_name == "Gully") {
            url = "https://api.garythe.cat/gully";
        } else if (cat_name == "Garfield") {
            url = "https://api.garythe.cat/garfield";
        }
        var json_get = new Soup.Message ("GET", @url);
        try {
            GLib.Bytes raw_json_response_data = yield session.send_and_read_async (json_get, GLib.Priority.DEFAULT, null);
            string json_response_data = (string) raw_json_response_data.get_data ();

            var parser = new Json.Parser ();
            parser.load_from_data (json_response_data);
            Json.Object json_root_object = parser.get_root ().get_object ();
	        int64 cat_id = json_root_object.get_int_member ("number");
	       return cat_id;
        } catch {
            warning ("Can't get the picture ID");
            return 0;
        }
    }

    public string get_gary_url (int64 cat_id, string cat_name) {
        var url = @"https://cdn.garythe.cat/$cat_name/$cat_name" + cat_id.to_string () + ".jpg";
        return url;
    }
}
