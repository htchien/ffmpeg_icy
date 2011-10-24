import os
libs = ["avcodec", "avformat", "avutil", "swscale"]
for name in [ "lib%s.a" % n for n in libs]:
    os.system("lipo -create `find O_ARM* -name %s` -output %s" % (name, name))  
