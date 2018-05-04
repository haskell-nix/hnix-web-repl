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
         # lens = pkgs.haskell.lib.dontCheck super.lens;
       };
    packages = {
      hnix-frontend = ./.;
      hnix = pkgs.fetchFromGitHub {
        owner = "haskell-nix";
        repo = "hnix";
        rev = "92c574a30739a45a52d3d026386f75fb8475d1cd";
        sha256 = "0p52p67isgxix88355chlqmh1g7pgrgbd3ikxmn4h5gpzmsx8rsg";
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
    };
    
    shells = {
      # ghc = [ "hnix-frontend" ];
      ghcjs = [ "hnix-frontend" ];
    };
  
  })
