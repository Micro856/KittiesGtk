/* glycin-render.vala
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

public class Kittiesgtk.GlycinRender {
    public Gdk.Texture render (GLib.Bytes image_data) {
        var loader = new Gly.Loader.for_bytes (image_data);
        Gdk.Texture to_display;
        try {
            var img = loader.load ();
            var frame = img.next_frame ();
            to_display = GlyGtk4.frame_get_texture (frame);
        } catch {
            to_display = null;
        }
        return to_display;
    }
}

