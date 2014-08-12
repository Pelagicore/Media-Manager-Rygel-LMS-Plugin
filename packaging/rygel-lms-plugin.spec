Name:       rygel-lms-plugin
Summary:    LMS plugin for Rygel
Version:    0.1
Release:    1
Group:      System/Libraries
License:    MPL-2.0
URL:        http://genivi.org
Source0:    %{name}-%{version}.tar.bz2

BuildRequires: pkgconfig(sqlite3)
BuildRequires: pkgconfig(glib-2.0)
BuildRequires: pkgconfig(rygel-server-2.0)
BuildRequires: pkgconfig(rygel-core-2.0)
BuildRequires: gupnp
BuildRequires: gupnp-av
BuildRequires: libdbus

BuildRequires: cmake
BuildRequires: vala

%description
LMS plugin for Rygel, which provides UPnP access to an LMS database, allowing
users to browse audio files.

%package devel
Summary:    Development files for %{name}
Group:      Development/Libraries
Requires:   %{name} = %{version}-%{release}

%description devel
Rygel LMS plugin, development files

%prep
%setup -q -n %{name}-%{version}

%build
mkdir build
cd build
%cmake ..

make %{?jobs:-j%jobs}

%install
cd build
%make_install

%files
/usr/lib/rygel-2.0/plugins/librygel-mm-lms.so
/usr/lib/rygel-2.0/plugins/mm-lms.plugin
