\ olpc.fth

: force-date  ( -- )  \ set the clock to a specific date and time
   d# 0 d# 0 d# 10  d# 12 d# 11 d# 2015       ( s m h d m y )
   " set-time" clock-node @ $call-method   ( )
;
: get-year  ( -- year )  \ get the year only from the clock
   time&date 2nip 2nip nip
;
: ?fix-clock  ( -- )  \ set the clock if the year is obviously wrong
   get-year d# 2015 < if
      force-date
      visible ." warning: my clock was reset to 2015, check clock battery" cr
   then
;

visible
.( -- Tiny Core Linux boot script for Open Firmware    ) cr
.(    by quozl@laptop.org, 2014-08-07               -- ) cr cr

\ translate a bundle suffix string to an architecture tag string
: b>a  ( bundle$ -- architecture$ )
   drop c@ case
      [char] 0  of  " x86" exit  endof
      [char] 1  of  " x86" exit  endof
      [char] 2  of  " arm" exit  endof
      [char] 4  of  " arm" exit  endof
   endcase
;

\ translate a bundle suffix string to an serial terminal tag string
: b>s  ( bundle$ -- serialterm$ )
   drop c@ case
      [char] 0  of  " ttyS0" exit  endof
      [char] 1  of  " ttyS0" exit  endof
      [char] 2  of  " ttyS2" exit  endof
      [char] 4  of  " ttyS2" exit  endof
   endcase
;

[ifndef] bundle-suffix$
: bundle-suffix$
   " model" " /" find-package drop get-package-property 2drop c@
   case
      [char] C  of  " 0" exit  endof
      [char] D  of  " 1" exit  endof
      " 2" exit
   endcase
;
[then]

\ set macros
bundle-suffix$     " MACHINE"      $set-macro
bundle-suffix$ b>a " ARCHITECTURE" $set-macro
bundle-suffix$ b>s " SERIALTERM"   $set-macro

\ set kernel command line
" fbcon=font:SUN12x22 superuser quiet showapps multivt waitusb=5 nozswap console=${SERIALTERM},115200 console=tty0 xo-custom"   expand$ to boot-file

\ choose initramfs
" last:\boot\initrd.${ARCHITECTURE}"   expand$ to ramdisk

\ choose kernel
" last:\boot\vmlinuz.${MACHINE}"       expand$ to boot-device

?fix-clock
cr
boot
