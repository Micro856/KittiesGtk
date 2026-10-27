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
    public async int64 refresh_id (string cat_name, Adw.Banner data_issue) {
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

    public async string refresh_url (int64 cat_id, string cat_name) {
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

