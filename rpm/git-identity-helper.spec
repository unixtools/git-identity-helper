
Summary: git-identity-helper Scripts
Name: git-identity-helper
Version: 1.1.0
Release: 1%{?dist}
License: Distributable
Group: System Environment/Base
BuildArch: noarch

Packager: Nathan Neulinger <nneul@neulinger.org>

Source: git-identity-helper-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
This contains the profile script for improved shared-userid git behavior.

%prep
%setup -c -q -n git-identity-helper

%build
cd git-identity-helper-%{version}
make DESTDIR=$RPM_BUILD_ROOT

%install

cd git-identity-helper-%{version}
make DESTDIR=$RPM_BUILD_ROOT install

mkdir -p $RPM_BUILD_ROOT/etc/profile.d
cp -pr git-identity-helper.sh $RPM_BUILD_ROOT/etc/profile.d/

%clean
%{__rm} -rf %{buildroot}

%files

%attr(0644, root, root) /etc/profile.d/git-identity-helper.sh

%changelog
