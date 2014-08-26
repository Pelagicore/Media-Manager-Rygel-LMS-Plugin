public class Rygel.LMS.Album : Rygel.LMS.Tracks {
    public Album (string id,
                  MediaContainer parent,
                  string         title,
                  string         artist_,
                  string         album_art_uri_,
                  LMS.Database   lms_db) {
        base (id,
              parent,
              title,
              lms_db,
              " AND audios.album_id = %s ".printf(id));

        upnp_class = MediaContainer.MUSIC_ALBUM;
        artist = artist_;
        this.set_album_art_uri(album_art_uri_);
    }

}
