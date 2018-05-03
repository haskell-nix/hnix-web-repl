BUILDROOT="dist-ghcjs"
OUTDIR=$BUILDROOT/build/x86_64-osx/ghcjs-0.2.1/frontend-0.1/c/frontend/build/frontend/frontend.jsexe
cabal --builddir=$BUILDROOT new-build frontend
cp $OUTDIR/* app
