/*
 * Copyright (C) 2013 Jaguar Land Rover
 *
 * Author: Jonatan Pålsson <jonatan.palsson@pelagicore.com>
 *
 * This file is part of Rygel.
 *
 * Rygel is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Rygel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

using Rygel;

using Sqlite;

public class Rygel.LMS.FSBrowser : Rygel.SimpleContainer {
    public FSBrowser (MediaContainer parent) {
        base ("fsbrowser",
              parent,
              "File system");

//       this.add_child_item (new FSBRowserItem ("/boot", this, "/boot"));
    }
}

//public class Rygel.LMS.FSBRowserItem : Rygel.MediaItem {
//    public FSBRowserItem (string id,
//                          MediaContainer parent,
//                          string title) {
//        base (id,
//              parent,
//              title,
//              "unknown");
//    }
//
//    public override bool streamable () { return false; }
//    public override DIDLLiteObject? serialize (Serializer serializer,
//                                               HTTPServer http_server)
//                                               throws Error {}
//}
