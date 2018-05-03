{-# LANGUAGE RecursiveDo #-}

module NixRepl where

------------------------------------------------------------------------------
import           Control.Monad.Trans
import           Data.Char
import           Data.Monoid
import           Data.Sequence (Seq)
import qualified Data.Sequence as S
import           Data.Text (Text)
import qualified Data.Text as T
import           Nix
import           Reflex.Dom
------------------------------------------------------------------------------
import           History
------------------------------------------------------------------------------

data DisplayedSnippet
  = InputSnippet Text
  | OutputSnippet Text
  deriving (Eq,Ord,Show,Read)

dummyData :: Seq DisplayedSnippet
dummyData = S.fromList
      [ OutputSnippet "# Welcome to the Nix interactive repl"
      , OutputSnippet "# Enter nix expressions here"
      ]

snippetWidget :: MonadWidget t m => DisplayedSnippet -> m ()
snippetWidget (InputSnippet t) = el "pre" $ text t
snippetWidget (OutputSnippet t) = el "pre" $ text t

nixRepl :: MonadWidget t m => m ()
nixRepl = do
    elAttr "div" ("class" =: "repl") $ mdo
      snippets <- holdUniqDyn =<< foldDyn ($) dummyData (leftmost
        [ flip (S.|>) . InputSnippet <$> newInput
        ])
      history <- foldDyn ($) emptyHistory $
        (addHistoryUnlessConsecutiveDupe <$> newInput)
      dyn $ mapM_ snippetWidget <$> snippets
      ti <- textInput $ def
        & attributes .~ constDyn ("class" =: "repl-input")
        & setValue .~ (mempty <$ enterPressed)
      let filterKey k = ffilter (==k) $ _textInput_keydown ti
      let enterPressed = filterKey 13
          newInput = tag (current $ value ti) enterPressed
          upPressed = ffilterKey 38
          downPressed = ffilterKey 40
      performEvent_ (liftIO . print <$> _textInput_keydown ti)
  where
    runInput input snippets =
      snippets <> S.singleton input <> runExpr input
    runExpr e = runLazyM defaultOptions (normalForm =<< nixEvalExpr Nothing e)
