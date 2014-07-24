# Copyright (C) 2014, Jaguar Land Rover
#
# Author: Jonatan Palsson <jonatan.palsson@pelagicore.com>
#
# This file is part of the GENIVI Media Manager Proof-of-Concept
# For further information, see http://genivi.org/
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

CMAKE_MINIMUM_REQUIRED (VERSION 2.6)
PROJECT (LIBRYGEL_LMS)

FIND_PACKAGE (PkgConfig)
pkg_check_modules (PC_GLIB           REQUIRED glib-2.0)
pkg_check_modules (PC_RYGEL_SERVER   REQUIRED rygel-server-2.4)
pkg_check_modules (PC_RYGEL_CORE     REQUIRED rygel-core-2.4)
pkg_check_modules (PC_SQLITE3        REQUIRED sqlite3)

SET (VALA_PACKAGES
     --pkg rygel-server-2.4
     --pkg rygel-core-2.4
     --pkg sqlite3)

SET (VALA_FLAGS
     -C)

SET (VALAC valac)

SET (VAPIDIR /home/jonatan/rygel_install_new/share/vala/vapi)

SET (CONFIG_H
     -DGETTEXT_PACKAGE="rygel")

SET (VALA_DEFINES
    -D rygel_lms_utf8_collate_str)

SET (VALA_INPUT
     rygel-lms-albums.vala
     rygel-lms-album.vala
     rygel-lms-all-images.vala
     rygel-lms-all-music.vala
     rygel-lms-all-videos.vala
     rygel-lms-artists.vala
     rygel-lms-artist.vala
     rygel-lms-category-container.vala
     rygel-lms-database.vala
     rygel-lms-genres.vala
     rygel-lms-genre.vala
     rygel-lms-image-root.vala
     rygel-lms-image-years.vala
     rygel-lms-image-year.vala
     rygel-lms-music-root.vala
     rygel-lms-playlists.vala
     rygel-lms-plugin-factory.vala
     rygel-lms-plugin.vala
     rygel-lms-root-container.vala
     rygel-lms-sql-function.vala
     rygel-lms-sql-operator.vala
     rygel-lms-tracks.vala)

SET (ADDITIONAL_SOURCES
     ${CMAKE_CURRENT_SOURCE_DIR}/rygel-lms-collate.c)

set(C_SOURCES "")
set(VALA_SOURCES "")
foreach(src ${VALA_INPUT})
    list(APPEND VALA_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
    string(REPLACE ".vala" ".c" src ${src})
    string(REPLACE ".gs" ".c" src ${src})
    list(APPEND C_SOURCES "${src}")
endforeach(src ${VALA_SOURCES})

ADD_CUSTOM_COMMAND (OUTPUT ${C_SOURCES}
                    COMMAND ${VALAC}
                            ${VALA_FLAGS}
                            ${VALA_PACKAGES}
                            --vapidir=${VAPIDIR}
                            ${VALA_DEFINES}
                            ${VALA_SOURCES})

INCLUDE_DIRECTORIES (${PC_GLIB_INCLUDE_DIRS}
                     ${PC_RYGEL_SERVER_INCLUDE_DIRS}
                     ${PC_SQLITE3}
                     ${PC_RYGEL_CORE_INCLUDE_DIRS})

LINK_DIRECTORIES (${PC_RYGEL_SERVER_LIBRARY_DIRS}
                  ${PC_RYGEL_CORE_LIBRARY_DIRS})

ADD_DEFINITIONS (${CONFIG_H})

ADD_LIBRARY (rygel-lms SHARED ${C_SOURCES} ${ADDITIONAL_SOURCES})

TARGET_LINK_LIBRARIES (rygel-lms ${PC_GLIB_LIBRARIES}
                                    ${PC_RYGEL_SERVER_LIBRARIES}
                                    ${PC_SQLITE3}
                                    ${PC_RYGEL_CORE_LIBRARIES})
