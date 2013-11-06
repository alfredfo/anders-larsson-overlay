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
	EGIT_BOOTSTRAP="eautoreconf"
	KEYWORDS="~amd64 ~x86"
else
	SRC_URI="https://github.com/MaartenBaert/${PKGNAME}/archive/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

SLOT="0"
IUSE="debug mp3 pulseaudio theora vorbis vpx x264"

RDEPEND="
	dev-qt/qtgui
	virtual/ffmpeg
	virtual/glu
	abi_x86_32? ( || ( virtual/glu[abi_x86_32] app-emulation/emul-linux-x86-opengl ) )
	mp3? ( virtual/ffmpeg[mp3] )
	pulseaudio? ( media-sound/pulseaudio )
	theora? ( virtual/ffmpeg[theora] )
	vorbis? ( || ( media-video/ffmpeg[vorbis] media-video/libav[vorbis] ) )
	vpx? ( || ( media-video/ffmpeg[vpx] media-video/libav[vpx] ) )
	x264? ( virtual/ffmpeg[x264] )
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
}

multilib_src_configure() {
	ECONF_SOURCE=${S}
	if $(is_final_abi ${abi}); then
		econf \
			$(use_enable debug assert) \
			$(use_enable pulseaudio) \
			--enable-dependency-tracking
	else
		econf \
			--enable-dependency-tracking \
			--disable-ssrprogram
	fi
}

multilib_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}
