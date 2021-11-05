#ffmpeg from source(s)

sudo apt-get install --yes libtheora-dev libzvbi-dev ocl-icd-opencl-dev libnuma-dev

mkdir -p ~/ffmpeg_sources/bin
sudo mkdir -p /usr/bin/ffmpeg_bins/lib
echo "export PATH=/usr/bin/ffmpeg_bins:\$PATH" >> ~/.bashrc
sudo sh -c 'echo "export PATH=/usr/bin/ffmpeg_bins:\$PATH" >> /root/.bashrc'
sudo sh -c 'echo "/usr/bin/ffmpeg_bins/lib" >> /etc/ld.so.conf.d/ffmpeg_libs.conf'
sudo ldconfig
source ~/.bashrc

sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libunistring-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  meson \
  ninja-build \
  pkg-config \
  python3-pip
  texinfo \
  wget \
  yasm \
  zlib1g-dev

pip3 install --user meson

# NASM
cd ~/ffmpeg_sources
wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2
tar xjvf nasm-2.15.05.tar.bz2
cd nasm-2.15.05
./autogen.sh
PATH="/usr/bin/ffmpeg_bins:$PATH" ./configure --prefix="/usr/bin/ffmpeg_bins" --bindir="/usr/bin/ffmpeg_bins"
make -j 4
sudo make install

#libX264-dev
cd ~/ffmpeg_sources
git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
PATH="/usr/bin/ffmpeg_bins:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="/usr/bin/ffmpeg_bins" --bindir="/usr/bin/ffmpeg_bins" --enable-static --enable-pic
PATH="/usr/bin/ffmpeg_bins:$PATH" make -j 4
sudo make install

#libX265-dev
cd ~/ffmpeg_sources
wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2
tar xjvf x265.tar.bz2
cd multicoreware*/build/linux
PATH="/usr/bin/ffmpeg_bins:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/usr/bin/ffmpeg_bins" -DENABLE_SHARED=off ../../source
PATH="/usr/bin/ffmpeg_bins:$PATH" make -j 4
sudo make install

#libVPX
cd ~/ffmpeg_sources
git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
PATH="/usr/bin/ffmpeg_bins:$PATH" ./configure --prefix="/usr/bin/ffmpeg_bins" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
PATH="/usr/bin/ffmpeg_bins:$PATH" make -j 4
sudo make install

#libfdk-aac
cd ~/ffmpeg_sources
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="/usr/bin/ffmpeg_bins" --libdir="/usr/bin/ffmpeg_bins/lib" --disable-shared
make -j 4
sudo make install
sudo ldconfig

#libOPUS
cd ~/ffmpeg_sources
git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git
cd opus
./autogen.sh
./configure --prefix="/usr/bin/ffmpeg_bins" --libdir="/usr/bin/ffmpeg_bins/lib" --disable-shared
make -j 4
sudo make install
sudo ldconfig

#libaom
cd ~/ffmpeg_sources
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom
mkdir -p aom_build
cd aom_build
PATH="/usr/bin/ffmpeg_bins:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/usr/bin/ffmpeg_bins" -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom
PATH="/usr/bin/ffmpeg_bins:$PATH" make -j 4
sudo make install

#libDAV1D
cd ~/ffmpeg_sources
git -C dav1d pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/dav1d.git
mkdir -p dav1d/build
cd dav1d/build
meson setup -Denable_tools=false -Denable_tests=false --default-library=static .. --prefix "/usr/bin/ffmpeg_bins" --libdir="/usr/bin/ffmpeg_bins/lib"
ninja
sudo ninja install
sudo ldconfig

#libvmaf
cd ~/ffmpeg_sources
wget https://github.com/Netflix/vmaf/archive/v2.1.1.tar.gz
tar xvf v2.1.1.tar.gz
mkdir -p vmaf-2.1.1/libvmaf/build
cd vmaf-2.1.1/libvmaf/build
meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "/usr/bin/ffmpeg_bins" --bindir="/usr/bin/ffmpeg_bins/bin" --libdir="/usr/bin/ffmpeg_bins/lib"
ninja
sudo ninja install

sudo ldconfig