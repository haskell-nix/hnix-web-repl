module History where

------------------------------------------------------------------------------
import           Data.Map (Map)
import qualified Data.Map as M
import           Data.Monoid
------------------------------------------------------------------------------


data History a = History
  { historyItems :: Map Int a
  , historyCount :: Int
  } deriving (Eq,Ord,Show,Read)

-- | @empty@ is an empty history
empty :: History a
empty = History mempty 0

toList :: History a -> [a]
toList = M.elems . historyItems

addToHistory :: a -> History a -> History a
addToHistory a (History m c) = History (M.insert (c+1) a m) (c+1)
