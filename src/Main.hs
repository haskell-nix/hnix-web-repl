{-# LANGUAGE OverloadedStrings #-}
module Main where

------------------------------------------------------------------------------
import           Control.Monad.Trans
import           Control.Monad.Trans.Reader
import           Control.Monad.Trans.State.Strict
import           Data.HashMap.Lazy (HashMap)
import qualified Data.HashMap.Lazy as HM
import           Data.Map (Map)
import qualified Data.Map as M
import           Data.Monoid
import           Data.Sequence (Seq)
import qualified Data.Sequence as S
import           Data.Text (Text)
import qualified Data.Text as T
import           Nix hiding (value)
import           Nix.Atoms
import           Nix.Context
import           Reflex
import           Reflex.Dom
------------------------------------------------------------------------------
import           NixRepl
------------------------------------------------------------------------------

main :: IO ()
main = mainWidgetWithHead headWidget $ replWidget never

headWidget :: MonadWidget t m => m ()
headWidget =
  elAttr "link" ("rel" =: "stylesheet" <> "type" =: "text/css" <> "href" =: "css/site.css") blank

