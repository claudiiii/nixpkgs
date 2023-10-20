{ lib
, stdenv
, fetchFromGitHub
, cmake
, perl
, python3
, tbb
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bowtie2";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "BenLangmead";
    repo = "bowtie2";
    rev = "refs/tags/v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-rWeopeYuCk9ZhJX2SFCcxZWcjXjjTiVRiwkzLQcIgd0=";
  };

  # because of this flag, gcc on aarch64 cannot find the Threads
  # Could NOT find Threads (missing: Threads_FOUND)
  # TODO: check with other distros and report upstream
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "-m64" ""
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ tbb zlib python3 perl ];

  cmakeFlags = lib.optional (!stdenv.hostPlatform.isx86) ["-DCMAKE_CXX_FLAGS=-I${finalAttrs.src}/third_party"];

  meta = with lib; {
    description = "An ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences";
    license = licenses.gpl3Plus;
    homepage = "http://bowtie-bio.sf.net/bowtie2";
    changelog = "https://github.com/BenLangmead/bowtie2/releases/tag/${finalAttrs.src.rev}";
    maintainers = with maintainers; [ rybern ];
    platforms = platforms.all;
    mainProgram = "bowtie2";
  };
})
