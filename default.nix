{ rpRef ? "ea3c9a1536a987916502701fb6d319a880fdec96" }:

let rp = builtins.fetchTarball "https://github.com/mightybyte/reflex-platform/archive/${rpRef}.tar.gz";

in
  (import rp {}).project ({ pkgs, ... }: {
    name = "hnix-web-repl";
    overrides = self: super:
      let guardGhcjs = p: if self.ghc.isGhcjs or false then null else p;
       in {
         cryptohash-md5 = guardGhcjs super.cryptohash-md5;
         cryptohash-sha1 = guardGhcjs super.cryptohash-sha1;
         cryptohash-sha256 = guardGhcjs super.cryptohash-sha256;
         cryptohash-sha512 = guardGhcjs super.cryptohash-sha512;
         hashing = super.hashing;
         haskeline = guardGhcjs super.haskeline;
         megaparsec = pkgs.haskell.lib.dontCheck super.megaparsec;
         serialise = pkgs.haskell.lib.doJailbreak super.serialise;

         Glob = guardGhcjs super.Glob;
         criterion = guardGhcjs super.criterion;
         interpolate = guardGhcjs super.interpolate;
         pretty-show = guardGhcjs super.pretty;
         repline = guardGhcjs super.repline;
         tasty = guardGhcjs super.tasty;
         tasty-hunit = guardGhcjs super.tasty;
         tasty-th = guardGhcjs super.tasty;
         unix = guardGhcjs super.unix;
       };
    packages = {
      hnix-frontend = builtins.filterSource
        (path: type: !(builtins.elem (baseNameOf path)
           ["result" "dist" "dist-ghcjs" ".git" "app"]))
        ./.;
      hnix = pkgs.fetchFromGitHub {
        owner = "haskell-nix";
        repo = "hnix";
        rev = "0d7176c2946c203adb49e2f19093892c917f513e";
        sha256 = "07x2vsx608bryd0il02bw7jky0p28yip73jhiwrh56adlvsp5xcq";
      };

      megaparsec = pkgs.fetchFromGitHub {
        owner = "mrkkrp";
        repo = "megaparsec";
        rev = "7b271a5edc1af59fa435a705349310cfdeaaa7e9";
        sha256 = "0415z18gl8dgms57rxzp870dpz7rcqvy008wrw5r22xw8qq0s13c";
      };
      parser-combinators = pkgs.fetchFromGitHub {
        owner = "mrkkrp";
        repo = "parser-combinators";
        rev = "dd6599224fe7eb224477ef8e9269602fb6b79fe0";
        sha256 = "11cpfzlb6vl0r5i7vbhp147cfxds248fm5xq8pwxk92d1f5g9pxm";
      };
      # Should be callHackage, but it gives an error "found zero or more than one cabal file"
      # unordered-containers = pkgs.haskellPackages.callHackage "unordered-containers" "0.2.9.0" {};
      unordered-containers = pkgs.fetchFromGitHub {
        owner = "tibbe";
        repo = "unordered-containers";
        rev = "0a6b84ec103e28b73458f385ef846a7e2d3ea42f";
        sha256 = "128q8k4py2wr1v0gmyvqvzikk6sksl9aqj0lxzf46763lis8x9my";
      };
    };
    
    shells = {
      # ghc = [ "hnix-frontend" ];
      ghcjs = [ "hnix-frontend" ];
    };
  
  })
