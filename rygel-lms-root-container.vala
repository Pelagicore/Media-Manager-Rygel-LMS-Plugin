/*
 * Copyright (C) 2013 Intel Corporation.
 *
 * Author: Jussi Kukkonen <jussi.kukkonen@intel.com>
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

public class Rygel.LMS.RootContainer : Rygel.SimpleContainer {

    private LMS.Database lms_db = null;

    public RootContainer() {
        var config = MetaConfig.get_default ();

        var title = "GENIVI MediaManager";

        base.root(title);

        try {
            this.lms_db = new LMS.Database ();

            this.add_child_container (new Artists ("artists", this, _("Artists"), this.lms_db));
            this.add_child_container (new Genres (this, this.lms_db));
            this.add_child_container (new Albums (this, this.lms_db));
            this.add_child_container (new Playlists ("playlists", this, "Playlists"));
            this.add_child_container (new SortedTracks (this, this.lms_db));
            this.add_child_container (new FSBrowserContainer ("/", this, "/"));

        } catch (DatabaseError e) {
            warning ("%s\n", e.message);

            /* TODO if db does not exist we should
               wait for it to be created and then add folders.  Best to wait for the
               LMS notification API. */
        }
    }
}
