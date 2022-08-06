FROM centos:7
ENV container docker

WORKDIR /tmp
RUN pwd

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;


RUN yum -y update
RUN yum -y install deltarpm
RUN yum -y install wget

#Install htop
RUN wget https://armv7.dev.centos.org/repodir/epel-pass-1/htop/2.2.0-3.el7/armv7hl/htop-2.2.0-3.el7.armv7hl.rpm 
RUN yum -y install htop-2.2.0-3.el7.armv7hl.rpm

RUN yum -y install man-pages man-db man gcc gcc-c++ httpd git openssh-server openssh-clients bzip2 ncurses-devel make sudo passwd
RUN yum -y install vim-common vim-X11 


#Install Berryconda3
RUN wget https://github.com/jjhelmus/berryconda/releases/download/v2.0.0/Berryconda3-2.0.0-Linux-armv7l.sh
RUN chmod +x Berryconda3-2.0.0-Linux-armv7l.sh
RUN ./Berryconda3-2.0.0-Linux-armv7l.sh -b -p /usr/bin/berryconda


#Download zsh
RUN wget http://www.zsh.org/pub/zsh-5.8.tar.xz
RUN tar -xvf zsh-5.8.tar.xz
WORKDIR /tmp/zsh-5.8


##Compile ZSH
RUN ./configure --prefix=/usr --bindir=/bin --sysconfdir=/etc/zsh --enable-etcdir=/etc/zsh --without-tcsetpgrp
RUN make
RUN make install
WORKDIR /tmp


RUN echo "export PATH=/usr/bin/berryconda/bin/:$PATH" >> /etc/profile.d/path.sh
RUN chmod +x /etc/profile.d/path.sh


RUN systemctl enable httpd.service
RUN systemctl enable sshd.service
EXPOSE 80/tcp
EXPOSE 22/tcp

RUN yum -y install which file

RUN useradd -ms /bin/bash fred
RUN usermod -aG wheel fred
RUN echo password | passwd --stdin -f fred
RUN sed -i 's/%wheel\s*\ALL=(ALL)\s*\ALL/#%wheel  ALL=(ALL)       ALL/g' /etc/sudoers

#https://stackoverflow.com/questions/10420713/regex-pattern-to-edit-etc-sudoers-file
RUN sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers

RUN echo /usr/bin/zsh >> /etc/shells

USER fred
WORKDIR /home/fred

RUN wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
RUN chmod +x install.sh
RUN ./install.sh --unattended

#https://github.com/zsh-users/zsh-autosuggestions
#https://www.dev-diaries.com/blog/terminal-history-auto-suggestions-as-you-type/
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
RUN echo "source /home/fred/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /home/fred/.zshrc
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="kiwi"/g' /home/fred/.zshrc


USER root
WORKDIR /tmp

CMD ["/usr/sbin/init"]
#ENTRYPOINT ["/bin/bash"]
