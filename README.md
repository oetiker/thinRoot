<img src="buildroot-external/patches/psplash/thinroot/logo.png" width="250px" align="center">

See https://github.com/jens-maus/thinRoot for the original. This is simply a
fork with changes to make things work for OETIIKER+PARTNER

Some notes on how to use this thing

## changing the kernel config

```
make linux-menuconfig
make linux-savedefault
```

## changing the buildroot config

```
make menuconfig
make savedefault
```

## creating a boot image

```
make dist
cp build-intel_nuc/images/bzImage $dest
```

## build the ipxe bootloader

```
git clone git@github.com:ipxe/ipxe.git
cd ipxe/src
make ipxe.kpxe
```

or if you want the undi driver

```
make undionly.kpxe
```

if you want customize the behavior, have a look at `src/config/general.h`
and `src/config/console.h`


## configure isc dhcp

the following goes into your `/etc/dhcp/dhcpd.conf` 

```
option space ipxe;
option ipxe-encap-opts code 175 = encapsulate ipxe;
option ipxe.priority code 1 = signed integer 8;
option ipxe.keep-san code 8 = unsigned integer 8;
option ipxe.skip-san-boot code 9 = unsigned integer 8;
option ipxe.syslogs code 85 = string;
option ipxe.cert code 91 = string;
option ipxe.privkey code 92 = string;
option ipxe.crosscert code 93 = string;
option ipxe.no-pxedhcp code 176 = unsigned integer 8;
option ipxe.bus-id code 177 = string;
option ipxe.san-filename code 188 = string;
option ipxe.bios-drive code 189 = unsigned integer 8;
option ipxe.username code 190 = string;
option ipxe.password code 191 = string;
option ipxe.reverse-username code 192 = string;
option ipxe.reverse-password code 193 = string;
option ipxe.version code 235 = string;
option iscsi-initiator-iqn code 203 = string;
# Feature indicators
option ipxe.pxeext code 16 = unsigned integer 8;
option ipxe.iscsi code 17 = unsigned integer 8;
option ipxe.aoe code 18 = unsigned integer 8;
option ipxe.http code 19 = unsigned integer 8;
option ipxe.https code 20 = unsigned integer 8;
option ipxe.tftp code 21 = unsigned integer 8;
option ipxe.ftp code 22 = unsigned integer 8;
option ipxe.dns code 23 = unsigned integer 8;
option ipxe.bzimage code 24 = unsigned integer 8;
option ipxe.multiboot code 25 = unsigned integer 8;
option ipxe.slam code 26 = unsigned integer 8;
option ipxe.srp code 27 = unsigned integer 8;
option ipxe.nbi code 32 = unsigned integer 8;
option ipxe.pxe code 33 = unsigned integer 8;
option ipxe.elf code 34 = unsigned integer 8;
option ipxe.comboot code 35 = unsigned integer 8;
option ipxe.efi code 36 = unsigned integer 8;
option ipxe.fcoe code 37 = unsigned integer 8;
option ipxe.vlan code 38 = unsigned integer 8;
option ipxe.menu code 39 = unsigned integer 8;
option ipxe.sdi code 40 = unsigned integer 8;
option ipxe.nfs code 41 = unsigned integer 8;


# obviously for your setup different you will have different IPS
subnet 10.23.107.0 netmask 255.255.255.0 {
    authoritative;
    option broadcast-address   10.23.107.255;
    option routers             10.23.107.1;
    option domain-name-servers 10.46.101.1;
    option ntp-servers         ntp.metas.ch;
    range                    10.23.107.10 10.23.107.250;
    next-server 10.23.107.1; # the tftp server where ipxe.kpxe is to be found
    option ipxe.no-pxedhcp 1;
    # show the hw address in the log
    log (debug, binary-to-ascii (16, 8, ":", hardware)); 
    # once we have ipxe loaded we provide it a pointer to the config
    if exists user-class and option user-class = "iPXE" {
      log (debug, "Detected iPXE Loader");
      filename "http://boot-server:3833/ipxe.cfg";
    # we want to only serve ipxe to certain machines
    } elsif binary-to-ascii (16, 8, ":", hardware) = "1:fc:aa:14:da:4:d0" # tc1
        or  binary-to-ascii (16, 8, ":", hardware) = "1:fc:aa:14:da:8:1b" # tc2
        or  binary-to-ascii (16, 8, ":", hardware) = "1:f8:f:41:4a:72:2e" # tc3
        or  binary-to-ascii (16, 8, ":", hardware) = "1:94:c6:91:a4:73:5" # tc4
    {
      filename "ipxe.kpxe";
      # filename "undionly.kpxe";
    } else {
      filename "pxelinux.0";
    }
  }
}

```

### setup the boot server

for ease of use, I created a little 'boot-server' which provides all the
files required by thinRoot by using the http protocol it is way faster than
downloads via tftp.

```
cd boot-server
./bootstrap
./configure --prefix=/opt/thinroot-bootserver
make install
```

configure the location for your configuration files in
`/opt/thinroot-bootserver/etc/boot-server.cfg` there is a `.dist` file for
inspiration.

In the `boot-server/sample-data` you find some settigs to get you started.
Notably the `./etc/X11/xorg.conf.d/00-keyboard.conf` file where you can set
the keyboard configuration.

the `home` folder gets copied into the `truser` acccount and contains the
default `thinlinc` configuration. The special `trick` of this setup is that
any changes you make to your thinlinc config will be copied back to the
boot-server when you exit the thinlinc client which allows easy runtime
configuration. Each mac address gets a separate config store ... note that
there is a security issue with this as the boot server just accepts what
ever mac address the thinclient claims to have ... so best is to NOT run
this server in an untrusted settig ... in that case it would make sense to
use ip addresses or even a use supplied login/password to get going.


---

tobi oetiker <tobi@oetiekr.ch>