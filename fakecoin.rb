class Fakecoin < Formula
  homepage "https://fakco.in/"
  url "https://github.com/Fake-Coin/FakeCoin-Qt.git"

  option "with-qt", "Build `fakecoin-qt` binary"

  #head do
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  #end

  depends_on "pkg-config" => :build
  depends_on "berkeley-db@4"
  depends_on "boost"
  depends_on "libevent"
  depends_on "miniupnpc"
  depends_on "openssl"
  depends_on "zeromq"

  depends_on "qt5" => :optional
  if build.with? "qt"
    depends_on "qt5"
    depends_on "protobuf"
    depends_on "qrencode"
    depends_on "gettext" => :optional
  end

  needs :cxx11

  def install
    if MacOS.version == :el_capitan && MacOS::Xcode.installed? &&
       MacOS::Xcode.version >= "8.0"
       ENV.delete("SDKROOT")
    end

    args = %w[
      --disable-dependency-tracking
      --disable-silent-rules
    ]

    args << "--with-boost-libdir=#{Formula["boost"].opt_lib}"
    args << "--prefix=#{prefix}"

    if build.with? "qt"
      args << "--with-gui=auto"
      ENV.append "CXXFLAGS", "-std=c++11 -stdlib=libc++"
      ENV.append "OBJCXXFLAGS", "-std=c++11 -stdlib=libc++"
    end

    system "./autogen.sh" # if build.head?
    system "./configure", *args
    system "make", "install"

    pkgshare.install "share/rpcuser"
  end

  plist_options :manual => "fakecoind"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/fakecoind</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/test_fakecoin"
  end
end
