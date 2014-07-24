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
using Gee;
using GUPnP;

public class Rygel.LMS.Playlists : Rygel.WritableContainer,
                                   Rygel.SimpleContainer {
    public ArrayList<string> create_classes { get; set; }

    public override async MediaObject? find_object (string       id,
                                               Cancellable? cancellable)
                                               throws Error {
        foreach (var c in this.children) {
            if (c.id == id)
                return c;
        }

        return null;
    }

    public async override MediaObjects? get_children (uint         offset,
                                                      uint         max_count,
                                                      string       sort_criteria,
                                                      Cancellable? cancellable)
                                                      throws Error {
        return this.children;
    }

    public async string add_reference (MediaObject    object,
                                       Cancellable? cancellable)
                                       throws Error {
        this.add_child_item(object as MusicItem);
        return object.id;
    }

    public async void add_container (MediaContainer container,
                                        Cancellable?   cancellable)
                                        throws Error {
        var ct = new Playlists(container.id, this, container.title);

        this.add_child_container (ct as MediaContainer);
        this.container_updated (this, ct, ObjectEventType.ADDED, false);
    }

    public async void add_item (MediaItem    item,
                                Cancellable? cancellable) throws Error {
        debug ("Add item requested");
        throw new WritableContainerError.NOT_IMPLEMENTED
                                        ("Can't add items. Create a reference instead.");
    }

    public async void remove_container (string       id,
                                        Cancellable? cancellable)
                                        throws Error {
        throw new WritableContainerError.NOT_IMPLEMENTED
                                        ("Can't remove containers. Remove a reference instead.");
    }

    public async void remove_item (string       id,
                                   Cancellable? cancellable)
                                   throws Error {
        throw new WritableContainerError.NOT_IMPLEMENTED
                                        ("Can't remove items. Remove a reference instead.");
    }

    public override OCMFlags ocm_flags {
        get {
            var flags = OCMFlags.UPLOAD |
                        OCMFlags.UPLOAD_DESTROYABLE |
                        OCMFlags.CREATE_CONTAINER;
            return flags;
        }
    }

    public Playlists (string id, MediaContainer parent, string name) {
        base (id, parent, name);

        this.create_classes = new ArrayList<string>();
        this.create_classes.add (Rygel.MusicItem.UPNP_CLASS);
        this.create_classes.add (Rygel.MediaContainer.UPNP_CLASS);

        this.add_uri ("rygel-writable://playlist");

        var item = new MusicItem ("item", this, "Item", Rygel.MusicItem.UPNP_CLASS);
        item.add_uri ("file:///");
        item.mime_type = "audio/mpeg";

        this.add_child_item(item as MediaItem);
    }
}
