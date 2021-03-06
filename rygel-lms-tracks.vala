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

public class Rygel.LMS.Tracks : Rygel.LMS.CategoryContainer {
    private static const string SQL_ADDED_TEMPLATE =
        "SELECT files.id, files.path, files.size, " +
               "audios.title as title, audios.trackno, audios.length, audios.channels, audios.sampling_rate, audios.bitrate, audios.dlna_profile, audios.dlna_mime, " +
               "audio_artists.name as artist, " +
               "audio_albums.name, " +
               "audio_genres.name, " +
               "audio_albums.album_art_url " +
        "FROM audios, files " +
        "LEFT JOIN audio_artists " +
        "ON audios.artist_id = audio_artists.id " +
        "LEFT JOIN audio_albums " +
        "ON audios.album_id = audio_albums.id " +
        "LEFT JOIN audio_genres " +
        "ON audios.genre_id = audio_genres.id " +
        "WHERE dtime = 0 AND audios.id = files.id " +
        "AND update_id > ? AND update_id <= ? " +
        " %s;";

    private static const string SQL_REMOVED_TEMPLATE =
        "SELECT files.id FROM files WHERE dtime <> 0 " +
        "AND update_id > ? AND update_id <= ?;";

    private static const string SQL_ALL_TEMPLATE =
        "SELECT files.id as id, files.path, files.size, " +
               "audios.title as title, audios.trackno, audios.length, audios.channels, audios.sampling_rate, audios.bitrate, audios.dlna_profile, audios.dlna_mime, " +
               "audio_artists.name as artist, " +
               "audio_albums.name as album, " +
               "audio_genres.name as genre, " +
               "audio_albums.album_art_url " +
        "FROM audios, files " +
        "LEFT JOIN audio_artists " +
        "ON audios.artist_id = audio_artists.id " +
        "LEFT JOIN audio_albums " +
        "ON audios.album_id = audio_albums.id " +
        "LEFT JOIN audio_genres " +
        "ON audios.genre_id = audio_genres.id " +
        "WHERE dtime = 0 AND audios.id = files.id" +
        " %s ";

    private static const string SQL_COUNT_TEMPLATE =
        "SELECT COUNT(audios.id) " +
        "FROM audios, files " +
        "LEFT JOIN audio_genres " +
        "ON audios.genre_id = audio_genres.id " +
        "WHERE dtime = 0 AND audios.id = files.id "+
        " %s " + ";";

    private static const string SQL_COUNT_WITH_FILTER_TEMPLATE =
        "SELECT COUNT(audios.id), audios.title as title, " +
               "audio_artists.name as artist, " +
               "audio_albums.name " +
        "FROM audios, files " +
        "LEFT JOIN audio_artists " +
        "ON audios.artist_id = audio_artists.id " +
        "LEFT JOIN audio_albums " +
        "ON audios.album_id = audio_albums.id " +
        "WHERE dtime = 0 AND audios.id = files.id;";

    private static const string SQL_FIND_OBJECT=
        "SELECT files.id, files.path, files.size, " +
               "audios.title, audios.trackno, audios.length, audios.channels, audios.sampling_rate, audios.bitrate, audios.dlna_profile, audios.dlna_mime, " + 
               "audio_artists.name, " +
               "audio_albums.name, " +
               "audio_genres.name, " +
               "audio_albums.album_art_url " +
        "FROM audios, files " +
        "LEFT JOIN audio_artists " +
        "ON audios.artist_id = audio_artists.id " +
        "LEFT JOIN audio_albums " +
        "ON audios.album_id = audio_albums.id " +
        "LEFT JOIN audio_genres " +
        "ON audios.genre_id = audio_genres.id " +
        "WHERE dtime = 0 AND files.id = ? AND audios.id = files.id;";

    private string guessDLNAMime (string path) {
        if (path.down().has_suffix ("ogg")) {
            return "audio/ogg";
        } else if (path.down().has_suffix ("mp3")) {
            return "audio/mpeg";
        }

        /* Just guess something */
        return "audio/mpeg";
    }

    protected override MediaObject? object_from_statement (Statement statement) {
        var id = statement.column_int (0);
        var path = statement.column_text (1);
        var mime_type = statement.column_text(10);
        var album_art_path = statement.column_text(14);

        if (mime_type == null || mime_type.length == 0) {
            var mime = guessDLNAMime (path);

            debug ("Guessing mime for music item %d (%s): %s",
                   id,
                   path,
                   mime);
            mime_type = mime;
        }

        var title = statement.column_text(3);
        var song_id = this.build_child_id (id);
        var song = new MusicItem (song_id, this, title);

        /* tell object to keep a reference to the parent --
         * otherwise parent is freed before object is serialized */
        song.parent_ref = song.parent;

        song.ref_id = this.build_reference_id (id);
        song.size = statement.column_int(2);
        song.track_number = statement.column_int(4);
        song.duration = statement.column_int(5);
        song.channels = statement.column_int(6);
        song.sample_freq = statement.column_int(7);
        song.bitrate = statement.column_int(8);
        song.dlna_profile = statement.column_text(9);
        song.mime_type = mime_type;
        song.artist = statement.column_text(11);
        song.album = statement.column_text(12);
        song.genre = statement.column_text(13);

        if (album_art_path != null) {
            File album_art = File.new_for_path (album_art_path);
            song.set_album_art_uri(album_art.get_uri());
        }

        File file = File.new_for_path (path);
        song.add_uri (file.get_uri ());

 //       debug ("Built track:");
 //       debug ("    id:         %d", id);
 //       debug ("    path:       %s", path);
 //       debug ("    mime:       %s", mime_type);
 //       debug ("    album art:  %s", album_art_path);
 //       debug ("    title:      %s", title);
 //       debug ("    song id:    %s", song_id);
 //       debug ("    ref id:     %s", song.ref_id);
 //       debug ("    size:       %" + int64.FORMAT, song.size);
 //       debug ("    track num:  %d", song.track_number);
 //       debug ("    duration:   %ld", song.duration);
 //       debug ("    channels    %d", song.channels);
 //       debug ("    sample frq: %d", song.sample_freq);
 //       debug ("    bitrate:    %d", song.bitrate);
 //       debug ("    dlna prof:  %s", song.dlna_profile);
 //       debug ("    artist:     %s", song.artist);
 //       debug ("    album:      %s", song.album);
 //       debug ("    genre:      %s", song.genre);
 //       debug ("    path:       %s", file.get_uri());

        return song;
    }

    private static string get_sql_added (string query_ext) {
        return (SQL_ADDED_TEMPLATE.printf (query_ext));
    }
    private static string get_sql_removed () {
        return (SQL_REMOVED_TEMPLATE);
    }

    private static string get_sql_all (string query_ext) {
        //debug ("QUERY: %s", SQL_ALL_TEMPLATE.printf (query_ext));
        return (SQL_ALL_TEMPLATE.printf (query_ext) +
        "%s LIMIT ? OFFSET ?;");
    }

    private static string get_sql_count (string query_ext = "") {
        //debug ("QUERY: %s", SQL_ALL_TEMPLATE.printf (query_ext));
        return (SQL_COUNT_TEMPLATE.printf (query_ext));
    }

    protected override string get_sql_all_with_filter (string filter) {
        if (filter.length == 0) {
            return this.sql_all;
        }
        var filter_str = " %s ".printf (filter);
        return (SQL_ALL_TEMPLATE.printf (filter_str));
    }

    protected override string get_sql_count_with_filter (string filter) {
        if (filter.length == 0) {
            return this.sql_count;
        }
        var filter_str = " %s ".printf (filter);
        return (SQL_COUNT_WITH_FILTER_TEMPLATE.printf (filter_str));
    }

    public Tracks (string id,
                   MediaContainer parent,
                   string         title,
                   LMS.Database   lms_db,
                   string?        query_ext = "") {
        base (id,
              parent,
              title,
              lms_db,
              get_sql_all (query_ext),
              SQL_FIND_OBJECT,
              get_sql_count (query_ext),
              get_sql_added (query_ext),
              get_sql_removed (),
              {"artist", "album", "genre", "title"});

    }
}
