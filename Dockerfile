# xfce4-tigervnc

FROM takaomag/base:2015.12.06.13.39

ENV \
    X_DOCKER_REPO_NAME=xfce4.tigervnc

# ADD files /
ADD files/etc /etc
ADD files/root /root
ADD files/usr/lib/systemd/system /usr/lib/systemd/system

RUN \
    echo "2015-12-04-0" > /dev/null && \
    export TERM=dumb && \
    export LANG='en_US.UTF-8' && \
    source /opt/local/bin/x-set-shell-fonts-env.sh && \
    chown -R root:root /etc/supervisor.d && \
    chmod 755 /etc/supervisor.d && \
    chmod 755 /etc/supervisor.d/vncserver && \
    chmod 600 /etc/supervisor.d/vncserver/* && \
    cd /etc/supervisor.d && \
    ln -sf vncserver/vncserver.ini . && \
    ln -sf sshd/sshd.ini . && \
    chown -R root:root /root/.config && \
    (chmod 700 /root/.config || true) && \
    chmod 755 /root/.config/xfce4 && \
    chmod 664 /root/.config/xfce4/xinitrc && \
    chown -R root:root /root/.vnc && \
    chmod 700 /root/.vnc && \
    chmod 755 /root/.vnc/xstartup && \
    chmod 644 /usr/lib/systemd/system/x-vncserver@.service && \
    echo -e "${FONT_INFO}[INFO] Updating package database${FONT_DEFAULT}" && \
    reflector --latest 100 --verbose --sort score --save /etc/pacman.d/mirrorlist && \
    sudo -u nobody yaourt -Syy && \
    echo -e "${FONT_SUCCESS}[SUCCESS] Updated package database${FONT_DEFAULT}" && \
    REQUIRED_PACKAGES=("supervisor" "vim" "xorg-server" "xorg-server-utils" "xorg-xinit" "xfce4" "xfce4-goodies" "fcitx" "fcitx-gtk3" "fcitx-configtool" "fcitx-kkc" "firefox" "firefox-i18n-ja" "arch-firefox-search" "tigervnc" "ttf-dejavu" "otf-ipafont" "infinality-bundle" "fontforge" "terminator" "wireshark-gtk" "pycharm-professional") && \
    echo -e "${FONT_INFO}[INFO] Installing required packages [${REQUIRED_PACKAGES[@]}]${FONT_DEFAULT}" && \
    cd /tmp && \
    echo -e "# ${X_DOCKER_ID}/${X_DOCKER_REPO_NAME} >>>\n[infinality-bundle]\nServer = http://bohoomil.com/repo/\$arch\n# ${X_DOCKER_ID}/${X_DOCKER_REPO_NAME} <<<\n" >> /etc/pacman.conf && \
    pacman-key -r 962DDE58 && \
    pacman-key --lsign-key 962DDE58 && \
    sudo -u nobody yaourt -Syy && \
    sudo -u nobody yaourt -S --needed --noconfirm --noprogressbar "${REQUIRED_PACKAGES[@]}" && \
    cd /usr/lib/systemd/system/multi-user.target.wants && \
    ln -s ../x-vncserver@.service x-vncserver@:1.service && \
    cd /tmp && \
    echo -e "${FONT_SUCCESS}[SUCCESS] Installed required packages [${REQUIRED_PACKAGES[@]}]${FONT_DEFAULT}" && \
    echo -e "${FONT_INFO}[INFO] Installing fonts${FONT_DEFAULT}" && \
#    (sudo -u nobody yaourt -G --noconfirm ttf-ms-win8 || true) && \
#    cd /tmp/ttf-ms-win8 && \
#    curl --fail --silent --location --remote-name https://s3-ap-northeast-1.amazonaws.com/mago-ap-northeast-1/archlinux/win8/Fonts.zip && \
#    unzip -q Fonts.zip && \
#    mv Fonts/* . && \
#    rm -rf Fonts && \
#    rm Fonts.zip && \
#    curl --fail --silent --location --remote-name https://s3-ap-northeast-1.amazonaws.com/mago-ap-northeast-1/archlinux/win8/license.rtf && \
#    sed --in-place -e 's/^PKGEXT=/#PKGEXT=/g' PKGBUILD && \
    (sudo -u nobody yaourt -G --noconfirm ttf-ms-win10 || true) && \
    cd /tmp/ttf-ms-win10 && \
    curl --fail --silent --location https://s3-ap-northeast-1.amazonaws.com/mago-ap-northeast-1/archlinux/win10/win10-fonts.tgz | tar xz && \
#    sudo -u nobody makepkg PKGBUILD && \
#    sudo -u nobody yaourt -U --noconfirm --noprogressbar *.pkg.tar.* && \
#    sudo -u nobody yaourt -U --noconfirm --noprogressbar $(ls *.pkg.tar.*)
#    sudo -u nobody yaourt -U --noconfirm $(find ./ -mindepth 1 -maxdepth 1 -type f -name '*\.pkg\.*' -print0 | sed -e 's/\x0/ /g') && \
    sudo -u nobody makepkg --install --noconfirm --noprogressbar && \
    cd /tmp && \
#    rm -rf ttf-ms-win8 && \
    rm -rf ttf-ms-win10 && \
    expect -c "$(echo -e 'set send_slow {1 0.3}\nset timeout -1\nspawn fc-presets set\nexpect {\n  -exact "Enter your choice... " { sleep 0.3; send -- "3\\r"; exp_continue }\n  eof { exit 0 }\n}')" && \
    sudo -u nobody yaourt -Rsn  --noconfirm --noprogressbar fontforge && \
    echo -e "${FONT_SUCCESS}[SUCCESS] Installed fonts${FONT_DEFAULT}" && \
    echo -e "${FONT_INFO}[INFO] Configuring xfce4/vnc${FONT_DEFAULT}" && \
    _bashrc="\n# ${X_DOCKER_ID}/${X_DOCKER_REPO_NAME} >>>\nalias vi >/dev/null 2>&1 || alias vi='vim'\n# ${X_DOCKER_ID}/${X_DOCKER_REPO_NAME} <<<\n" && \
    echo -e ${_bashrc}  >> /etc/skel/.bashrc && \
    echo -e ${_bashrc} >> /root/.bashrc && \
    echo -e "\n# ${X_DOCKER_ID}/${X_DOCKER_REPO_NAME} >>>\nexec startxfce4\n# ${X_DOCKER_ID}/${X_DOCKER_REPO_NAME} <<<\n" >> /etc/skel/.xinitrc && \
    cp -apr /etc/skel/.xinitrc /root/. && \
#    cp -apr /etc/skel/.xsession /root/. && \
#    sed --in-place -e "s/^\(\$desktopLog =.\+\)/# ${X_DOCKER_ID}\/${X_DOCKER_REPO_NAME} #\1\n\$desktopLog = \"\/dev\/stdout\";/g" /usr/bin/vncserver && \
    sed --in-place -e "s/^\(\$desktopLog =.\+\)/# ${X_DOCKER_ID}\/${X_DOCKER_REPO_NAME} #\1\n\$desktopLog = \"\/dev\/console\";/g" /usr/bin/vncserver && \
    sed --in-place -e "s/^unlink(\$desktopLog);/# ${X_DOCKER_ID}\/${X_DOCKER_REPO_NAME} #unlink(\$desktopLog);/g" /usr/bin/vncserver && \
    echo -e "${FONT_INFO}[INFO] Changing vnc password [password=${X_DOCKER_ID}/${X_DOCKER_REPO_NAME}]${FONT_DEFAULT}" && \
#    _expect_cmd=$(echo -e 'set send_slow {1 0.3}\nset timeout -1\nspawn vncpasswd\nexpect {\n -exact "Password:" { sleep 0.3; send -- "'${X_DOCKER_ID}'/'${X_DOCKER_REPO_NAME}'\\r"; exp_continue }\n -exact "Verify:" { sleep 0.3; send -- "'${X_DOCKER_ID}'/'${X_DOCKER_REPO_NAME}'\\r"; exp_continue }\n -exact "Would you like to enter a view-only password (y/n)? " { sleep 0.3; send -- "n\r"; exp_continue }\n eof { exit 0 }\n}') && \
    _expect_cmd=$(echo -e 'set send_slow {1 0.3}\nset timeout -1\nspawn vncpasswd\nexpect {\n -exact "Password:" { sleep 0.3; send -- "'${X_DOCKER_ID}'\\r"; exp_continue }\n -exact "Verify:" { sleep 0.3; send -- "'${X_DOCKER_ID}'\\r"; exp_continue }\n -exact "Would you like to enter a view-only password (y/n)? " { sleep 0.3; send -- "n\r"; exp_continue }\n eof { exit 0 }\n}') && \
    expect -c "${_expect_cmd}" && \
#    echo -e "${FONT_INFO}[INFO] Changed vnc password [password=${X_DOCKER_ID}/${X_DOCKER_REPO_NAME}]${FONT_DEFAULT}" && \
    echo -e "${FONT_INFO}[INFO] Changed vnc password [password=${X_DOCKER_ID}]${FONT_DEFAULT}" && \
    echo -e "${FONT_INFO}[INFO] Configured xfce4/vnc${FONT_DEFAULT}" && \
    /opt/local/bin/x-archlinux-remove-unnecessary-files.sh && \
    pacman-optimize && \
    rm -f /etc/machine-id

EXPOSE \
    22 \
    5901 \
    9001

#ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration=/etc/supervisord.conf"]
ENTRYPOINT ["/usr/lib/systemd/systemd"]

# By systemd
# docker run --name=xxx -d -P --cap-add SYS_ADMIN --env container=docker --env container_uuid=xxxx --env LANG=ja_JP.UTF-8 --volume /sys/fs/cgroup:/sys/fs/cgroup:ro takaomag/xfce4-tigervnc

# By supervisord
# docker run --name=xxx -d -P --env container=docker --env container_uuid=xxxx --env LANG=ja_JP.UTF-8 --entrypoint /usr/bin/supervisord takaomag/xfce4.tigervnc --nodaemon --configuration=/etc/supervisord.conf

# docker exec xxx /bin/bash -c 'export HOME=/root && vncserver -kill :1'
#    vncserver :1 -autokill &&
#    (vncserver -kill :1 || true) &&
