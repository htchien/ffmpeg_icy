#!/bin/bash
###
# configure settings is refered to http://abitno.me/compile-ffmpeg-android-ndk
#

NDK_HOME=$ANDROID_NDK_ROOT

#./toolchains/arm-eabi-4.4.0/prebuilt/linux-x86/arm-eabi/lib/ldscripts/armelf.x

if [ `uname` != 'Linux' ]; then
    HOST_OS=darwin-x86

else
    HOST_OS=linux-x86
fi

PLATFORM=$NDK_HOME/platforms/android-4/arch-arm
EX_INCLUDE=$PLATFORM/usr/include
LD_SCRIPT=$NDK_HOME/toolchains/arm-eabi-4.4.0/prebuilt/$HOST_OS/arm-eabi/lib/ldscripts/armelf.x
CRT_OBJ_1=$NDK_HOME/toolchains/arm-eabi-4.4.0/prebuilt/$HOST_OS/lib/gcc/arm-eabi/4.4.0/crtbegin.o
CRT_OBJ_2=$NDK_HOME/toolchains/arm-eabi-4.4.0/prebuilt/$HOST_OS/lib/gcc/arm-eabi/4.4.0/thumb/crtbegin.o
CRT_OBJ_2=
CRT_OBJ_1=
CRT_OBJ_3=$NDK_HOME/platforms/android-4/arch-arm/usr/lib/crtbegin_dynamic.o
MY_CC=$NDK_HOME/toolchains/arm-eabi-4.4.0/prebuilt/$HOST_OS/bin/arm-eabi-gcc
MY_NM=$NDK_HOME/toolchains/arm-eabi-4.4.0/prebuilt/$HOST_OS/bin/arm-eabi-nm
MY_CC_PREFIX=$NDK_HOME/toolchains/arm-eabi-4.4.0/prebuilt/$HOST_OS/bin/arm-eabi-
MY_LIB_GCC_A=$NDK_HOME/toolchains/arm-eabi-4.4.0/prebuilt/$HOST_OS/lib/gcc/arm-eabi/4.4.0/libgcc.a

function fileExists {
  # message, variable
  echo "test file >>$1<< exists"
  if [ -f $2 ]; then 
    echo "found $2" 
  else
    echo "file not found: $2"
    exit
  fi 
  echo
}

function dirExists {
  # message, variable
  echo "test dir >>$1<< exists"
  if [ -d $2 ]; then 
    echo "found $2" 
  else
    echo "dir not found: $2"
    exit
  fi 
  echo
}

echo
dirExists "ndk home" $NDK_HOME
dirExists "platform" $PLATFORM
dirExists "platform -> usr/lib" $PLATFORM/usr/lib
fileExists "arm ld script" $LD_SCRIPT
fileExists "crtbegin.o" $CRT_OBJ_1
fileExists "crtend.o" $CRT_OBJ_2
fileExists "arm nm" $MY_NM
echo


CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "
#PREFIX=./android/$CPU-vfp
PREFIX=./OUTPUT
ADDITIONAL_CONFIGURE_FLAG=


CPU=armv6
OPTIMIZE_CFLAGS="-DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU"
PREFIX=./android/${CPU}_vfp 
ADDITIONAL_CONFIGURE_FLAG=



./configure --target-os=linux \
    --prefix=$PREFIX \
    --enable-cross-compile \
    --extra-libs="-lgcc" \
    --arch=arm \
    --cc=$MY_CC \
    --cross-prefix=$MY_CC_PREFIX \
    --nm=$MY_NM \
    --sysroot=$PLATFORM \
    --extra-cflags=" -O3 -fpic -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums  -fno-strict-aliasing -finline-limit=300 $OPTIMIZE_CFLAGS " \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib  -nostdlib -lc -lm -ldl -llog" \
    --enable-parsers \
    --disable-encoders  \
    --enable-decoders \
    --disable-muxers \
    --enable-demuxers \
    --enable-swscale  \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-ffmpeg \
    --disable-avdevice \
    --disable-postproc \
    --disable-avfilter \
    --disable-filters \
    --enable-network \
    --enable-indevs \
    --disable-bsfs \
    --enable-protocols  \
    --disable-protocol=udp \
    --enable-asm \
    $ADDITIONAL_CONFIGURE_FLAG


#make clean
make  -j8 install

"$MY_CC_PREFIX"ar d libavcodec/libavcodec.a inverse.o
"$MY_CC_PREFIX"ld -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -soname libffmpeg.so \
    -shared -nostdlib  -z,noexecstack -Bsymbolic --whole-archive --no-undefined -o $PREFIX/libffmpeg.so \
    libavcodec/libavcodec.a libavformat/libavformat.a libavutil/libavutil.a libswscale/libswscale.a \
    -lc -lm -lz -ldl -llog --warn-once --dynamic-linker=/system/bin/linker \
    $MY_LIB_GCC_A
