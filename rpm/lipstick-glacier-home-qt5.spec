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
Requires:   qt5-qtfeedback
Requires:   qt5-qtdeclarative-import-window2
Requires:   qt5-qtdeclarative-import-sensors
Requires:   qt5-qtquickcontrols >= 5.3.1
Requires:   qt5-qtquickcontrols-nemo >= 5.1.1
Requires:   nemo-qml-plugin-contextkit-qt5
Requires:   connman-qt5
Requires:   libqofono-qt5-declarative
Requires:   nemo-theme-glacier
Requires:   google-opensans-fonts
Requires:   mpris-qt5-qml-plugin
Requires:   glacier-settings
Requires:   glacier-gallery-qmlplugin

#provide services for startup user session
Requires:   systemd-config-mer
Requires:   nemo-mobile-session-common

#provide keyboard
Requires:   maliit-plugins

BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(lipstick-qt5) >= 0.12.0
BuildRequires:  pkgconfig(Qt5Compositor)
BuildRequires:  pkgconfig(nemodevicelock)

Provides: lipstick-colorful-home-qt5

Conflicts:   lipstick-example-home

%description
A homescreen for Nemo Mobile

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5

make %{?_smp_mflags}

%install
rm -rf %{buildroot}

%qmake5_install

mkdir -p %{buildroot}%{_libdir}/systemd/user/user-session.target.wants/
ln -s ../lipstick.service %{buildroot}%{_libdir}/systemd/user/user-session.target.wants/lipstick.service

%files
%defattr(-,root,root,-)
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
