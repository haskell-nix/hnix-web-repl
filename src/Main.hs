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
import           Examples
import           NixRepl
------------------------------------------------------------------------------

main :: IO ()
main = mainWidgetWithHead headWidget nixRepl

headWidget :: MonadWidget t m => m ()
headWidget = do
  elAttr "link" ("rel" =: "stylesheet" <> "type" =: "text/css" <> "href" =: "css/semantic.min.css") blank
  elAttr "script" ("src" =: "js/jquery-3.1.1.min.js") blank
  elAttr "script" ("src" =: "js/semantic.min.js") blank

data ControlOut t = ControlOut
    { controlDropdown  :: Event t Text
    , controlLoadEvent :: Event t ()
    }

nixRepl :: MonadWidget t m => m ()
nixRepl = do
    ControlOut changeExample le <- controlBar
    divClass "ui two column grid container" $ do
      let getDemo = snd . (demos M.!)
      code <- divClass "column" $ divClass "ui segment" $ codeWidget hello changeExample
      divClass "column" $ divClass "ui segment" $ replWidget $ tag (current code) le

codeWidget :: MonadWidget t m => Text -> Event t Text -> m (Dynamic t Text)
codeWidget iv sv = do
    divClass "ui form" $ divClass "field" $ do
      ta <- textArea $ def
        & textAreaConfig_initialValue .~ iv
        & textAreaConfig_setValue .~ sv
        & textAreaConfig_attributes .~ constDyn ("class" =: "code-input")
      return $ value ta

demos :: Map Int (Text, Text)
demos = M.fromList $ zip [0..] exampleData

controlBar :: MonadWidget t m => m (ControlOut t)
controlBar = do
    elAttr "div" ("class" =: "ui menu") $ do
      elAttr "a" ("class" =: "header item") $ text "Nix REPL"
      d <- divClass "ui simple dropdown item" $ do
        text "Code Examples"
        elClass "i" "dropdown icon" blank
        divClass "dropdown menu" $ do
          (a,_) <- elAttr' "div" ("class" =: "item") $ text "Hello World"
          (b,_) <- elAttr' "div" ("class" =: "item") $ text "Factorial"
          return $ leftmost
            [ hello <$ domEvent Click a
            , fact <$ domEvent Click b
            ]
      (e,_) <- elAttr' "a" ("class" =: "item") $ text "Load"
      return $ ControlOut d (domEvent Click e)
