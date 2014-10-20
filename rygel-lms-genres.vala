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

public class Rygel.LMS.Genres : Rygel.LMS.CategoryContainer {
    private static const string SQL_ALL =
        "SELECT audio_genres.id as id, audio_genres.name as genre " +
        "FROM audio_genres " +
        "%s LIMIT ? OFFSET ?;";

    private static const string SQL_COUNT =
        "SELECT COUNT(audio_genres.id) " +
        "FROM audio_genres;";

    private static const string SQL_FIND_OBJECT =
        "SELECT audio_genres.id, audio_genres.name " +
        "FROM audio_genres " +
        "WHERE audio_genres.id = ?;";

    protected override MediaObject? object_from_statement (Statement statement) {
        var db_id = "%d".printf (statement.column_int (0));
        var title = statement.column_text (1);

        var genre = new LMS.Genre (db_id, this, title, this.lms_db, title);
        this.children.add (genre);

        return genre;
    }

    private MediaObjects children = new MediaObjects();

    public async override MediaObject? find_object (string id, 
                                                    Cancellable? cancellable)
                                        throws Error {
        MediaObject? object = null;

        if (!id.has_prefix (this.child_prefix)) {
            /* can't match anything in this container */
            return null;
        }

        foreach (var child in this.children) {
            if (child.id == id) {
                return child;
            } if (id.has_prefix (child.id)) {
                object = yield (child as LMS.Genre).find_object(id, cancellable);
            }
        }

    return object;
    }

    public Genres ( MediaContainer parent,
                   LMS.Database   lms_db) {
        base ("genres",
              parent,
              "Genres",
              lms_db,
              Genres.SQL_ALL,
              Genres.SQL_FIND_OBJECT,
              Genres.SQL_COUNT,
              null,
              null,
              {"id", "genre"});
    }
}
