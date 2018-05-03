module Main where

import Data.Monoid
import NixRepl
import Reflex.Dom

main :: IO ()
main = mainWidgetWithHead headWidget nixRepl

headWidget :: MonadWidget t m => m ()
headWidget =
  elAttr "link" ("rel" =: "stylesheet" <> "type" =: "text/css" <> "href" =: "css/site.css") blank
