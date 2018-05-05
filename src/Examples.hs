{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Examples where

-- We use the string-qq package because file-embed doesn't build with GHCJS

import Data.String.QQ
import Data.Text

exampleData :: [(Text, Text)]
exampleData =
  [ ("Hello World", hello)
  ]

hello :: Text
hello = [s|
let hello = subject: "Hello " + subject + "!";
in hello "world"
|]

fact :: Text
fact = [s|
let fact = n: if n <= 1 then 1 else n * fact (n - 1);
in fact 5
|]
