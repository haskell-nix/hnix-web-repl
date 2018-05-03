{ rpRef ? "ea3c9a1536a987916502701fb6d319a880fdec96" }:

let rp = builtins.fetchTarball "https://github.com/mightybyte/reflex-platform/archive/${rpRef}.tar.gz";

in
  (import rp {}).project ({ pkgs, ... }: {
    name = "hnix-web-repl";
    overrides = self: super: {
      # lens = pkgs.haskell.lib.dontCheck super.lens;
    };
    packages = {
      frontend = ./.;
      hnix = ../hnix;

      hashing = pkgs.fetchFromGitHub {
        owner = "wangbj";
        repo = "hashing";
        rev = "656dd2ffdbcf6d87b397b2c7c49034bd37cb9fb4";
        sha256 = "0zsdzh0a0ply4xswlva5wf880q9cjcdf2d6l0xz06q2dzy8dqrjh";
      };
      megaparsec = pkgs.fetchFromGitHub {
        owner = "mrkkrp";
        repo = "megaparsec";
        rev = "a2175ea6db9d9bdfbbd96a84123175d59652eeca";
        sha256 = "1503yc16jnyyg9zfxvlxxcgcws5719sxb75hqg1awzxxpmjhjdr7";
      };
      optparse-applicative = pkgs.fetchFromGitHub {
        owner = "pcapriotti";
        repo = "optparse-applicative";
        rev = "72ae4b69875e1702de36f083b32b106f6da6926e";
        sha256 = "1b19wjgsnlr5399qp0qhk2w1bqyzvabkkxr2iw3jkfx4f6zb2lp0";
      };
      parser-combinators = pkgs.fetchFromGitHub {
        owner = "mrkkrp";
        repo = "parser-combinators";
        rev = "7cf535720938c91294bd40add51df2feec1af2af";
        sha256 = "1ydplsby33hlbipqj86gb2r0hggm3bk4g2c4zjm1x28y3lwywhsb";
      };
    };
    
    shells = {
      ghc = [ "hnix" "frontend" ];
      ghcjs = [ "hnix" "frontend" ];
    };
  
  })
