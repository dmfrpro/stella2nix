{
  stdenvNoCC,
  dockerTools,
  jq,
  gnutar,
  autoPatchelfHook,
  makeWrapper,
  gmp,
}:

let
  imageName = "fizruk/stella";
  imageDigest = "sha256:86d6123aff226787a02b1b8021c7d4f2cd3703586155f5a96d6f0a7c21d805c6";

  arches = {
    x86_64-linux = {
      arch = "amd64";
      sha256 = "sha256-Edh8zO9Gn5cZW49BWCA/YydLr5navT49jFTtsygQsBs=";
    };
    aarch64-linux = {
      arch = "arm64";
      sha256 = "sha256-VOgUL7LoP/+RT0vmKjH4kj7hL1KpROtR1T4kPSIGbaA=";
    };
  };
  inherit (arches.${stdenvNoCC.hostPlatform.system}) arch sha256;

  image = dockerTools.pullImage {
    inherit
      imageName
      imageDigest
      arch
      sha256
      ;
    finalImageTag = "pinned";
  };
in
stdenvNoCC.mkDerivation {
  pname = "stella";
  version = "0.1.0.0";

  src = image;
  dontUnpack = true;

  nativeBuildInputs = [
    jq
    gnutar
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ gmp ];

  installPhase = ''
    runHook preInstall

    mkdir -p image rootfs
    tar -xf $src -C image

    for layer in $(jq -r '.[0].Layers[]' image/manifest.json); do
      tar -xf "image/$layer" -C rootfs
      while IFS= read -r -d ''' whiteout; do
        target="$(dirname "$whiteout")/$(basename "$whiteout" | sed 's/^\.wh\.//')"
        if [ "$(basename "$whiteout")" = ".wh..wh..opq" ]; then
          find "$(dirname "$whiteout")" -mindepth 1 -delete
        else
          rm -rf "$target"
        fi
        rm -f "$whiteout"
      done < <(find rootfs -name '.wh.*' -print0)
    done

    mkdir -p $out/bin $out/share/stella
    cp rootfs/usr/local/bin/stella $out/bin/stella
    cp -a rootfs/usr/local/share/stella/. $out/share/stella/

    wrapProgram $out/bin/stella \
      --set stella_compiler_datadir $out/share/stella

    runHook postInstall
  '';

  meta = {
    description = "Stella compiler";
    homepage = "https://hub.docker.com/r/fizruk/stella";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "stella";
  };
}
