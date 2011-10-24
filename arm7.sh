export PATH=.:$PATH
./configure --enable-cross-compile --target-os=darwin --arch=c \
--cc='/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/gcc' \
--as='gas-preprocessor.pl --disable-neon --disable-pic --enable-postproc --disable-debug --disable-stripping /Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/gcc' \
--sysroot='/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk' \
--cpu=arm7 --extra-cflags='-arch armv7 -isysroot /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk' --extra-ldflags='-arch armv7 -isysroot /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk' \
--prefix=$(pwd)/O_ARM7 \
--disable-doc --disable-bzlib --disable-ffmpeg --disable-ffplay \
--disable-ffserver --disable-ffprobe --disable-avdevice --disable-avfilter --disable-filters \
--disable-bsfs --disable-protocol=udp --disable-muxers --disable-lpc
make -j8 install
