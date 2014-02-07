# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit autotools multilib-minimal

if [[ ${PV} = 9999 ]]; then
	inherit git-2
fi

DESCRIPTION="A Simple Screen Recorder"
HOMEPAGE="http://www.maartenbaert.be/simplescreenrecorder"
LICENSE="GPL-3"
PKGNAME="ssr"
S=${WORKDIR}/${PKGNAME}-${PV}
if [[ ${PV} = 9999 ]]; then
	EGIT_REPO_URI="git://github.com/MaartenBaert/${PKGNAME}.git
		https://github.com/MaartenBaert/${PKGNAME}.git"
	EGIT_BOOTSTRAP=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/MaartenBaert/${PKGNAME}/archive/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

SLOT="0"
IUSE="debug jack mp3 pulseaudio theora vorbis vpx x264"

RDEPEND="
	dev-qt/qtcore
	dev-qt/qtgui
	virtual/glu[${MULTILIB_USEDEP}]
	media-libs/alsa-lib
	media-libs/mesa[${MULTILIB_USEDEP}]
	media-libs/soxr
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libXext
	x11-libs/libXfixes[${MULTILIB_USEDEP}]
	jack? ( media-sound/jack-audio-connection-kit )
	pulseaudio? ( media-sound/pulseaudio )
	|| (
		media-video/ffmpeg[vorbis?,vpx?,x264?,mp3?,theora?]
		media-video/libav[vorbis?,vpx?,x264?,mp3?,theora?]
	)
	"
DEPEND="${RDEPEND}"

pkg_setup() {
	if [[ ${PV} == "9999" ]]; then
		elog
		elog "This ebuild merges the latest revision available from upstream's"
		elog "git repository, and might fail to compile or work properly once"
		elog "merged."
		elog
	fi

	if [[ ${ABI} == amd64 ]]; then
		elog "You may want to add USE flag 'abi_x86_32' when running a 64bit system"
		elog "When added 32bit GLInject libraries are also included. This is"
		elog "required if you want to use OpenGL recording on 32bit applications."
		elog
	fi

	if ( has_version media-video/ffmpeg[x264] || has_version media-video/libav[x264] ) && has_version media-libs/x264[10bit]; then
		ewarn	
		ewarn "media-libs/x264 is currently built with 10bit useflag."
		ewarn "This is known to prevent simplescreenrecorder from recording x264 videos"
		ewarn "correctly. Please build media-libs/x264 without 10bit if you want to "
		ewarn "record videos with x264."
		ewarn
	fi

}

src_prepare() {
	local error='Failed to remove bundled soxr'

	# Remove bundled soxr. Use soxr provided by system instead
	rm -rf 3rdparty || die "${error}"
	sed -i -e 's/3rdparty//' Makefile.am || die "${error}"
	sed -i -e 's/3rdparty\/Makefile//' \
		-e '/\[3rdparty\/soxr\]/d' \
		-e 's/3rdparty\/soxr//' configure.ac || die "${error}"

	sed -i -e '/3rdparty/d' src/Makefile.am  || die "${error}"
	eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
		econf \
			$(multilib_is_native_abi && use_enable debug assert) \
			$(multilib_is_native_abi && use_enable pulseaudio) \
			$(multilib_is_native_abi && use_enable jack) \
			$(multilib_is_native_abi || echo "--disable-ssrprogram") \
			--enable-dependency-tracking
}
