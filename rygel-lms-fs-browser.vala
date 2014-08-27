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

using GUPnP;

public class Rygel.LMS.FSBrowserContainer : Rygel.MediaContainer {
    MediaObjects children = new MediaObjects();

    public FSBrowserContainer (string id,
                               MediaContainer parent,
                               string title) {

        Object (id : id,
                parent : parent,
                title : title,
                child_count : 1);

        upnp_class = STORAGE_FOLDER;
    }

    public override async MediaObjects? get_children (
                                                 uint         offset,
                                                 uint         max_count,
                                                 string       sort_criteria,
                                                 Cancellable? cancellable)
                                                 throws Error {
        if (this.children.size > 0)
            return this.children;


        Dir dir;
        string name;

        try {
            dir = Dir.open(this.id, 0);
        } catch (FileError e) {
            return null;
        }

        while ((name = dir.read_name ()) != null) {
            string path = Path.build_filename (this.id, name);

            if (FileUtils.test (path, FileTest.IS_REGULAR)) {
                try_add_to_container (path, name, this);
            }

            if (FileUtils.test (path, FileTest.IS_DIR)) {
                FSBrowserContainer item = new FSBrowserContainer (path, this, name);
                children.add (item);
            }
        }

        return children;
    }

    public override async MediaObject? find_object (string       id,
                                                    Cancellable? cancellable)
                                                    throws Error {
        if (!id.has_prefix(this.id))
            return null;

        var children = yield this.get_children (0, 100, "", cancellable);

        foreach (var child in children) {
            if (child.id == id) {
                return child;
            } else if (child is MediaContainer) {
                var child2 = yield (child as MediaContainer).find_object (id, cancellable);
                if (child2 != null)
                    return child2;
            }
        }

        return null;
    }


    private void try_add_to_container(string path, string name, MediaContainer container) {
        if (path.down().has_suffix(".mp3")) {
            MediaObject item = new AudioItem (path, this, name);
            item.mime_type = "";
            File f = File.new_for_path (path);
            item.uris.add(f.get_uri());
            children.add (item);
        }
    }
}
