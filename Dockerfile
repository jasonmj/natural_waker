FROM elixir:1.13.1

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && apt-get install -y avahi-daemon avahi-discover avahi-utils libnss-mdns iputils-ping dnsutils build-essential automake autoconf bc cpio git inotify-tools squashfs-tools ssh-askpass pkg-config curl wget rsync inotify-tools nodejs yarn
RUN wget https://github.com/fhunleth/fwup/releases/download/v1.9.0/fwup_1.9.0_amd64.deb
RUN dpkg -i ./fwup_1.9.0_amd64.deb
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force hex nerves_bootstrap
COPY ./avahi-daemon.conf /etc/avahi/avahi-daemon.conf
# RUN useradd -ms /bin/bash nerves && usermod -aG sudo nerves
# RUN chown -R nerves /opt/
# USER nerves
WORKDIR /root/app
