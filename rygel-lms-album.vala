public class Rygel.LMS.Album : Rygel.LMS.Tracks {
    public Album (string id,
                  MediaContainer parent,
                  string         title,
                  string         artist_,
                  LMS.Database   lms_db) {
        base (id,
              parent,
              title,
              lms_db,
              " AND audios.album_id = %s ".printf(id));

        upnp_class = MediaContainer.MUSIC_ALBUM;
        artist = artist_;
    }

}
