pkgname=ffmpeg-git
pkgver=4.4.r101737.g896395bbcf
pkgrel=1
pkgdesc='Complete solution to record, convert and stream audio and video (git version)'
arch=('armv6h' 'armv7h' 'aarch64')
url='https://www.ffmpeg.org/'
license=('GPL3')
depends=(
  alsa-lib
  aom
  bzip2
  fontconfig
  fribidi
  gmp
  gnutls
  gsm
  jack
  lame
  libass.so
  libavc1394
  libbluray.so
  libdav1d.so
  libdrm
  libfreetype.so
  libiec61883
  libmfx
  libmodplug
  libpulse
  librav1e.so
  libraw1394
  libsoxr
  libssh
  libtheora
  libva.so
  libva-drm.so
  libva-x11.so
  libvdpau
  libvidstab.so
  libvorbisenc.so
  libvorbis.so
  libvpx.so
  libwebp
  libx11
  libx264.so
  libx265.so
  libxcb
  libxext
  libxml2
  libxv
  libxvidcore.so
  libzimg.so
  opencore-amr
  openjpeg2
  opus
  sdl2
  speex
  srt
  v4l-utils
  vmaf
  xz
  zlib
)
makedepends=(
  amf-headers
  avisynthplus
  clang
  ffnvcodec-headers
  git
  ladspa
  nasm
)
optdepends=('avisynthplus: for reading AviSynth scripts as input'
            'intel-media-sdk: for Intel Quick Sync Video'
            'ladspa: for LADSPA filters'
            'nvidia-utils: Nvidia NVDEC/NVENC support')
provides=('libavcodec.so' 'libavdevice.so' 'libavfilter.so' 'libavformat.so'
          'libavutil.so' 'libpostproc.so' 'libswresample.so' 'libswscale.so'
          'ffmpeg')
conflicts=('ffmpeg')
source=('git+https://git.ffmpeg.org/ffmpeg.git'
        '010-ffmpeg-fix-vmaf-model-path.patch')
sha256sums=('SKIP'
            '52778c70d9fe6e3a10941b99b96ac7749cec325dc1b9ee11ab75332b5ff68e50')

prepare() {
    patch -d ffmpeg -Np1 -i "${srcdir}/010-ffmpeg-fix-vmaf-model-path.patch"
}

pkgver() {
    printf '%s.r%s.g%s' "$(git -C ffmpeg describe --tags --long | awk -F'-' '{ sub(/^n/, "", $1); print $1 }')" \
                        "$(git -C ffmpeg describe --tags --match 'N' | awk -F'-' '{ print $2 }')" \
                        "$(git -C ffmpeg rev-parse --short HEAD)"
}

build() {
    cd ffmpeg
    
    printf '%s\n' '  -> Running ffmpeg configure script...'
    
    ./configure \
        --prefix='/usr' \
        --disable-debug \
        --disable-opencl \
        --disable-stripping \
        --enable-amf \
        --enable-avisynth \
        --enable-cuda-llvm \
        --enable-lto \
        --enable-fontconfig \
        --enable-gmp \
        --enable-gnutls \
        --enable-gpl \
        --enable-ladspa \
        --enable-libaom \
        --enable-libass \
        --enable-libbluray \
        --enable-libcdio \
        --enable-libdav1d \
        --enable-libdrm \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libfribidi \
        --enable-libgsm \
        --enable-libiec61883 \
        --enable-libjack \
        --enable-libmfx \
        --enable-libmodplug \
        --enable-libmp3lame \
        --enable-libopencore_amrnb \
        --enable-libopencore_amrwb \
        --enable-libopenjpeg \
        --enable-libopus \
        --enable-libpulse \
        --enable-librav1e \
        --enable-libsoxr \
        --enable-libspeex \
        --enable-libsrt \
        --enable-libssh \
        --enable-libtheora \
        --enable-libv4l2 \
        --enable-libvidstab \
        --enable-libvmaf \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libwebp \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libxcb \
        --enable-libxml2 \
        --enable-libxvid \
        --enable-libzimg \
        --enable-mmal \
        --enable-nonfree \
        --enable-nvdec \
        --enable-nvenc \
        --enable-omx \
        --enable-omx-rpi \
        --enable-shared \
        --enable-static \
        --enable-version3
    make
    make tools/qt-faststart
}

package() {
    make -C ffmpeg DESTDIR="$pkgdir" install
    install -D -m755 ffmpeg/tools/qt-faststart -t "${pkgdir}/usr/bin"
}
