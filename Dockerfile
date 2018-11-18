FROM centos:7

MAINTAINER thijs.schnitger@container-solutions.com

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ “/sys/fs/cgroup” ]

RUN echo "[epel]"  > /etc/yum.repos.d/epel.repo; \
echo "name=Epel rebuild for armhfp" >> /etc/yum.repos.d/epel.repo; \
echo "baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/" >> /etc/yum.repos.d/epel.repo; \
echo "enabled=1" >> /etc/yum.repos.d/epel.repo; \
echo "gpgcheck=0" >> /etc/yum.repos.d/epel.repo

RUN yum -y install cobbler cobbler-web dhcp bind syslinux pykickstart

RUN systemctl enable cobblerd httpd dhcpd

# enable tftp
RUN sed -i -e 's/\(^.*disable.*=\) yes/\1 no/' /etc/xinetd.d/tftp

# create rsync file
RUN touch /etc/xinetd.d/rsync

EXPOSE 69
EXPOSE 80
EXPOSE 443
EXPOSE 25151

CMD ["/sbin/init"]
