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

public class Rygel.LMS.Genre : Rygel.SimpleContainer {
    public async override MediaObject? find_object (string id, 
                                                    Cancellable? cancellable)
                                        throws Error {
        MediaObject? object = null;

        debug("I am: %s, find_object called on %s".printf(this.id, id));
        if (!id.has_prefix (this.id)) {
            /* can't match anything in this container */
            return null;
        }

        debug ("I have %d children".printf(this.children.size));

        foreach (var child in this.children) {
            debug ("Looking at %s".printf(child.id));
            if (child.id == id) {
                return child;
            } if (id.has_prefix (child.id)) {
                object = yield (child as LMS.CategoryContainer).find_object(id, cancellable);
            }
        }

    return object;
    }

    public Genre (string         id,
                  MediaContainer parent,
                  string         title,
                  LMS.Database   lms_db,
                  string genreId) {
        base ("%s:%s".printf(parent.id, id), parent, title);

        debug ("Adding GenreArtist for %s", genreId);
        this.add_child_container (new GenreArtists ("artists", this, _("Artists"), lms_db, genreId));

        debug ("Adding GenreAlbums for %s", genreId);
        this.add_child_container (new GenreAlbums (this, lms_db, genreId));

        debug ("Adding GenreTracks for %s", genreId);
        this.add_child_container (new GenreTracks (this, lms_db, genreId));
    }
}

public class Rygel.LMS.GenreArtists : Rygel.LMS.Artists {
    protected string genreId = "";

    protected override MediaObject? object_from_statement (Statement statement) {
        var db_id = "%d".printf (statement.column_int (0));
        var title = statement.column_text (1);

        return new LMS.GenreArtist (db_id, this, title, this.lms_db, this.genreId);
    }

    public GenreArtists (string id,
                    MediaContainer parent,
                    string title,
                    LMS.Database   lms_db,
                    string genreId) {
        base (id,
              parent,
              title,
              lms_db);
        this.genreId = genreId;

    }
}

public class Rygel.LMS.GenreArtist : Rygel.LMS.Artist {
    protected string genreId = "";

    protected override MediaObject? object_from_statement (Statement statement) {
        var db_id = "%d".printf (statement.column_int (0));
        var title = statement.column_text (1);
        return new LMS.GenreAlbum (db_id, this, title, this.lms_db, this.genreId);
    }

    public GenreArtist (string         id,
                        MediaContainer parent,
                        string         title,
                        LMS.Database   lms_db,
                        string         genreId) {

        base (id,
              parent,
              title,
              lms_db);
        this.genreId = genreId;
    }
}

public class Rygel.GenreAlbums : Rygel.LMS.Albums {
    protected string genreId = "";

    protected override MediaObject? object_from_statement (Statement statement) {
        var id = "%d".printf (statement.column_int (0));
        var album = new LMS.GenreAlbum (id,
                                        this,
                                        statement.column_text (1),
                                        this.lms_db,
                                        this.genreId);
        var count = album.count();
        if (count > 0)
            return album;
        else
            return null;
    }

    public GenreAlbums (MediaContainer parent,
                        LMS.Database   lms_db,
                        string         genreId) {
        base (parent,
              lms_db);

        this.genreId = genreId;
    }
}

public class Rygel.LMS.GenreAlbum : Rygel.LMS.Tracks {
    public GenreAlbum (string id,
                       MediaContainer parent,
                       string         title,
                       LMS.Database   lms_db,
                       string         genre) {
        base (id,
              parent,
              title,
              lms_db,
              " AND audios.album_id = %s ".printf(id) +
              " AND audio_genres.name = '%s' ".printf(genre));
    }

}

public class Rygel.LMS.GenreTracks : Rygel.LMS.Tracks {
    public GenreTracks ( MediaContainer parent,
                       LMS.Database   lms_db,
                       string         genre) {
        base ("tracks",
              parent,
              "Tracks",
              lms_db,
              " AND audio_genres.name = '%s' ".printf(genre));

        upnp_class = MediaContainer.MUSIC_GENRE;
    }

}
