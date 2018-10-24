Name:       lipstick-glacier-home-qt5
Summary:    A nice homescreen for Glacier experience
Version:    0.27
Release:    2
Group:      System/GUI/Other
License:    BSD
URL:        https://github.com/locusf/glacier-home
Source0:    %{name}-%{version}.tar.bz2
Source1:    glacier.service

Requires:   lipstick-qt5 >= 0.17.0
Requires:   nemo-qml-plugin-configuration-qt5
Requires:   nemo-qml-plugin-time-qt5
Requires:   nemo-qml-plugin-dbus-qt5
Requires:   nemo-qml-plugin-statusnotifier
Requires:   qt5-qtdeclarative-import-window2
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

mkdir -p %{buildroot}%{_libdir}/systemd/user
cp %{SOURCE1} %{buildroot}%{_libdir}/systemd/user

mkdir -p %{buildroot}%{_libdir}/systemd/user/user-session.target.wants/
ln -s ../glacier.service %{buildroot}%{_libdir}/systemd/user/user-session.target.wants/glacier.service

%files
%defattr(-,root,root,-)
%{_bindir}/glacier-home
%{_libdir}/systemd/user/glacier.service
%{_libdir}/systemd/user/user-session.target.wants/glacier.service
%{_datadir}/lipstick-glacier-home-qt5/nemovars.conf
%{_datadir}/lipstick-glacier-home-qt5/qml
%{_datadir}/lipstick-glacier-home-qt5/translations
%{_datadir}/glacier-settings/

%post
systemctl-user --no-block restart glacier.service
