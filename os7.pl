#!/usr/bin/perl
# 针对Centos 7系统优化

BEGIN { 
system("rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/epel/epel-release-latest-7.noarch.rpm");
system("yum install -y net-tools nload iftop sysstat wget vim ntpdate lrzsz chkconfig libaio* numa* jemalloc* perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-ExtUtils* perl-Switch perl-CPAN*");
}

use Switch;

#####1) 服务关闭#####

@server_name=split('\n',`systemctl list-unit-files | grep enabled | awk '{print \$1}'`);

print "默认打开crond,network,rsyslog,sshd服务,postfix和firewalld服务初始化会关闭.\n\n";

while (1==1){
print "你是否同意？同意请输入yes，否则输入no:\t";
$line = <STDIN>;
chomp($line);

if ($line eq "no" | $line eq "NO"){
	last;}
elsif ($line eq "yes" | $line eq "YES"){
foreach $sn (@server_name){
    switch($sn){
        case "postfix.service"     { `systemctl disable $sn`; }
        case "firewalld.service"   { `systemctl disable $sn`; }
    }}
print "-----------------\n";
last;
}
else {print "你输入一个错误的字符$line，请重新输入...\n"; next;}
}

##############################

#####2) selinux关闭#####

print "\nselinux关闭\n";
sleep(1);

@ARGV = "/etc/selinux/config";

local $^I='.bak';

while(<>){
   s/SELINUX\=.*/SELINUX\=disabled/;
   print;
}

##############################

#####3) ntpdate时间校对#####

print "ntpdate时间校对完毕\n";
sleep(1);
$status = 0;

open(NTP, "+>>/var/spool/cron/root") or die "/var/spool/cron/root 文件无法打开, $!";
seek NTP, 0, 0;

while($_ = <NTP>){
        if($_ =~ /asia/){
                $status = 1;
        }
}
if($status == 0){ 
	syswrite(NTP,"\n*/5 * * * * /usr/sbin/ntpdate 1.asia.pool.ntp.org > /dev/null 2 >&1\n");
}
close(NTP);

##############################

#####4) 系统优化#####

print "系统优化完毕\n";
sleep(1);
$status = 0;

open(NTP, "+>>/etc/rc.local") or die "/etc/rc.local 文件无法打开, $!";
seek NTP, 0, 0;

while($_ = <NTP>){
        if($_ =~ /scheduler/){
                $status = 1;
        }
}
if($status == 0){ 
        syswrite(NTP,"\necho deadline > /sys/block/sdb/queue/scheduler\n\n");
}
close(NTP);

###########################################

$status = 0;
open(LIMIT, "+>>/etc/security/limits.conf") or die "/etc/security/limits.conf 文件无法打开, $!";
seek LIMIT, 0, 0;

while($_ = <LIMIT>){
        if($_ =~ /65535/){
                $status = 1;
        }
}
if($status == 0){
        syswrite(LIMIT,"\n*                     soft     nofile             65535\n");
        syswrite(LIMIT,"\n*                     hard     nofile             65535\n");
        syswrite(LIMIT,"\n*                     soft     nproc              65535\n");
        syswrite(LIMIT,"\n*                     hard     nproc              65535\n");
}
close(LIMIT);

###########################################

$status = 0;

open(LIMITS1, "+>>/etc/security/limits.d/90-nproc.conf") or die "/etc/security/limits.d/90-nproc.conf 文件无法打开, $!";
seek LIMITS1, 0, 0;

while($_ = <LIMITS1>){
        if($_ =~ /65535/){
                $status = 1;
        }
        elsif($_ =~ /1024/){
               system("sed \-\i '\/1024\/d' \/etc\/security\/limits.d\/90\-nproc.conf");
        }
}
if($status == 0){
        syswrite(LIMITS1,"\n*                     soft     nproc              65535\n");
        syswrite(LIMITS1,"\n*                     hard     nproc              65535\n");
}
close(LIMITS1);

###########################################

@ARGV = "/etc/default/grub";

local $^I='.bak';

while(<>){
   s/quiet/quiet numa\=off/;
   print;
}

###########################################

@ARGV = "/etc/fstab";

local $^I='.bak';

while(<>){
   if ($_ =~ "\/data"){
   s/defaults/defaults\,noatime\,nobarrier/;
   }
print;
}

###########################################

open(SYSCTL, "+>>/etc/sysctl.conf") or die "/etc/sysctl.conf 文件无法打开, $!";
seek SYSCTL, 0, 0;

while($_ = <SYSCTL>){
        if($_ =~ /swappiness/){
                system("sed -i '/vm\.swappiness/d' \/etc\/sysctl\.conf");
        }
        elsif($_ =~ /file-max/){
                system("sed -i '/fs\.file\-max/d' \/etc\/sysctl\.conf");
        }
        elsif($_ =~ /ip\_local\_port\_range/){
                system("sed -i '/ip\_local\_port\_range/d' \/etc\/sysctl\.conf");
        }
        elsif($_ =~ /tcp\_tw\_reuse/){
                system("sed -i '/tcp\_tw\_reuse/d' \/etc\/sysctl\.conf");
        }
}
close(SYSCTL);

system("sed -i '\$avm\.swappiness \= 1' \/etc\/sysctl\.conf");
system("sed -i '\$afs\.file\-max \= 655350' \/etc\/sysctl\.conf");
system("sed -i '\$anet\.ipv4\.ip\_local\_port\_range \= 1025 65000' \/etc\/sysctl\.conf");
system("sed -i '\$anet\.ipv4\.tcp\_tw\_reuse \= 1' \/etc\/sysctl\.conf");
system("sysctl \-p");

###########################################

#####5) 重启服务器#####

END {
print "\n现在需要重启服务器生效.\n\n";

while (1==1){
print "你是否同意？同意请输入yes，否则输入no:\t";
$line = <STDIN>;
chomp($line);

if ($line eq "no" | $line eq "NO"){
        last;
}
elsif ($line eq "yes" | $line eq "YES"){
        system("sync\;reboot");
        last;
}
else {print "你输入一个错误的字符$line，请重新输入...\n"; next;}
}
}
