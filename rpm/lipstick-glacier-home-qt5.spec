Name:       lipstick-glacier-home-qt5
Summary:    A nice homescreen for Glacier experience
Version:    0.27
Release:    2
Group:      System/GUI/Other
License:    BSD
URL:        https://github.com/nemomobile-ux/glacier-home
Source0:    %{name}-%{version}.tar.bz2

Requires:   lipstick-qt5 >= 0.17.0
Requires:   nemo-qml-plugin-configuration-qt5
Requires:   nemo-qml-plugin-time-qt5
Requires:   nemo-qml-plugin-dbus-qt5
Requires:   nemo-qml-plugin-statusnotifier
Requires:   nemo-qml-plugin-connectivity
Requires:   qt5-qtfeedback
%if 0%{?fedora}
Requires:   qt5-qtdeclarative
%else
Requires:   qt5-qtdeclarative-import-window2
Requires:   qt5-qtdeclarative-import-sensors
Requires:   qt5-qtdeclarative-plugin-layouts
%endif
Requires:   qt5-qtquickcontrols >= 5.3.1
Requires:   qt5-qtquickcontrols-nemo >= 5.1.1
Requires:   nemo-qml-plugin-systemsettings >= 0.2.30
Requires:   connman-qt5
Requires:   libqofono-qt5-declarative
Requires:   libqofonoext-declarative
Requires:   libngf-qt5-declarative
Requires:   nemo-theme-glacier
%if 0%{?fedora}
Requires:   open-sans-fonts
%else
Requires:   google-opensans-fonts
%endif
Requires:   mpris-qt5-qml-plugin
Requires:   glacier-settings
Requires:   glacier-gallery-qmlplugin
Requires:   libmce-qt5-declarative >= 1.3.0
Requires:   pulseaudio-modules-nemo-parameters
Requires:   libqofonoext-declarative
%if 0%{?fedora}
Requires:   qt5-qtmultimedia
%else
Requires:   qt5-qtmultimedia-plugin-mediaservice-gstmediaplayer
Requires:   qt5-qtmultimedia-plugin-mediaservice-gstmediaplayer
Requires:   qt5-qtmultimedia-plugin-audio-pulseaudio
%endif
Requires:   kf5bluezqt-declarative

BuildRequires:  cmake
BuildRequires:  extra-cmake-modules >= 5.68.0
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(lipstick-qt5) >= 0.12.0
BuildRequires:  pkgconfig(Qt5WaylandCompositor)
BuildRequires:  pkgconfig(Qt5WaylandClient)
BuildRequires:  pkgconfig(nemodevicelock)
BuildRequires:  kf5bluezqt-bluez5-devel >= 5.68.0
BuildRequires:  qt5-qttools-linguist >= 5.9

Provides: lipstick-colorful-home-qt5

Conflicts:   lipstick-example-home

%description
A homescreen for Nemo Mobile

%prep
%setup -q -n %{name}-%{version}

%build
mkdir build
cd build
%cmake -DCMAKE_VERBOSE_MAKEFILE=ON ..
cmake --build .

%install
cd build
rm -rf %{buildroot}
DESTDIR=%{buildroot} cmake --build . --target install

mkdir -p %{buildroot}%{_libdir}/systemd/user/user-session.target.wants/
ln -s ../lipstick.service %{buildroot}%{_libdir}/systemd/user/user-session.target.wants/lipstick.service

%files
%defattr(-,root,root,-)
%{_sysconfdir}/mce/90-glacier-*.conf
%{_bindir}/lipstick
%{_libdir}/systemd/user/lipstick.service
%{_libdir}/systemd/user/user-session.target.wants/lipstick.service
%{_datadir}/lipstick-glacier-home-qt5/nemovars.conf
%{_datadir}/lipstick-glacier-home-qt5/qml
%{_datadir}/lipstick-glacier-home-qt5/translations
%{_datadir}/glacier-settings/
%{_datadir}/mapplauncherd/privileges.d/glacier-home.privileges

%post
systemctl-user --no-block restart lipstick.service
