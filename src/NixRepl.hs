{-# LANGUAGE RecursiveDo #-}

module NixRepl where

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

dummyData :: Seq DisplayedSnippet
dummyData = S.fromList
      [ OutputSnippet "# Welcome to the Nix interactive repl"
      , OutputSnippet "# Enter nix expressions here"
      ]

nixRepl :: MonadWidget t m => m ()
nixRepl = replWidget never

data DisplayedSnippet
  = InputSnippet Text
  | OutputSnippet Text
  deriving (Eq,Ord,Show,Read)

snippetWidget :: MonadWidget t m => DisplayedSnippet -> m ()
snippetWidget (InputSnippet t) = el "pre" $ text t
snippetWidget (OutputSnippet t) = el "pre" $ text t

replWidget
    :: MonadWidget t m
    => Event t Text
    -> m ()
replWidget newCode = do
    let runInput input snippets =
          snippets <> S.singleton (InputSnippet input)

    elAttr "div" ("id" =: "code") $ mdo
      let start = (Left "init", mempty)
      replState <- holdDyn start $ leftmost
        [ evalResult
        , start <$ newCode
        ]
      snippets <- holdUniqDyn =<< foldDyn ($) dummyData (leftmost
        [ runInput <$> newInput
        , (\r ss -> ss <> S.singleton (OutputSnippet (showResult $ fst r))) <$> evalResult
        , const dummyData <$ newCode
        ])
      _ <- dyn $ mapM_ snippetWidget <$> snippets
      (ti, goEvent) <- divClass "repl-input-controls" $ mdo
        ti <- textArea $ def
          & attributes .~ constDyn mempty -- ("class" =: "repl-input")
          & setValue .~ (mempty <$ buttonClicked)
        (b,_) <- el' "button" $ text "Evaluate"
        let buttonClicked = domEvent Click b
        return (ti, buttonClicked)
      let newInput = tag (current $ value ti) goEvent
      evalResult <- performEvent $ leftmost
        [ attachWith runExpr (current replState) newInput
        , attachPromptlyDynWith runExpr replState newCode
        ]
      return ()

runExpr s etext = liftIO $
  case parseNixText etext of
    Failure err -> return (Left $ show err, snd s)
    Success e -> do
      (a,s2) <- (`runStateT` snd s)
        $ (`runReaderT` newContext defaultOptions)
        $ runLazy (normalForm =<< nixEvalExpr Nothing e)
      return (Right a, s2)

showResult :: Show a => Either String a -> Text
showResult (Right v) = T.pack $ show v
showResult (Left e) = "Error: " <> T.pack e

