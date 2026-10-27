/* rory_api.vala
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

public class Kittiesgtk.RoryApi {
    public async int64 get_rory_id (Adw.Banner data_issue) {
        var session = new Soup.Session ();
        var url = "https://rory.cat/purr";
        var json_get = new Soup.Message ("GET", @url);
        try {
            GLib.Bytes raw_json_response_data = yield session.send_and_read_async (json_get, GLib.Priority.DEFAULT, null);
            string json_response_data = (string) raw_json_response_data.get_data ();

            var parser = new Json.Parser ();
            parser.load_from_data (json_response_data);
            Json.Object json_root_object = parser.get_root ().get_object ();
	        int64 cat_id = json_root_object.get_int_member ("id");

            return cat_id;
        } catch {
            data_issue.set_revealed (true);
            warning ("Can't get the picture ID");
            return 0;
        }

    }

    public async string get_rory_url (int64 cat_id) {
        var session = new Soup.Session ();
        var url = "https://rory.cat/purr/" + cat_id.to_string ();
        var json_get = new Soup.Message ("GET", @url);
        try {
            GLib.Bytes raw_json_response_data = yield session.send_and_read_async (json_get, GLib.Priority.DEFAULT, null);
            string json_response_data = (string) raw_json_response_data.get_data ();

            var parser = new Json.Parser ();
            parser.load_from_data (json_response_data);
            Json.Object json_root_object = parser.get_root ().get_object ();
	        var final_url = json_root_object.get_string_member ("url");

            return final_url;
        } catch {
            warning ("Can't get the picture URL");
            return "https://example.org";
        }
    }
}
