{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}

module Parser where


import Data.Aeson
import Data.Aeson.Types (Parser)
import Prelude hiding (read, Left, Right)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.ByteString.Lazy as BL
import Data.Maybe (fromMaybe)
import System.IO (readFile)
import StateMachine (Action(..), Transition(..), StateMachine(..))
import Debug.Trace (trace, traceShow, traceM)

instance FromJSON Action where
    parseJSON = withText "Action" $ \t -> trace ("Parsing Action: " ++ T.unpack t) $ case t of
        "LEFT"  -> return StateMachine.Left
        "RIGHT" -> return StateMachine.Right
        _       -> fail "Invalid Action"

instance FromJSON Transition where
    parseJSON = withObject "Transition" $ \v -> do
        read <- v .: "read"
        toState <- v .: "to_state"
        write <- v .: "write"
        action <- v .: "action"
        return Transition { read = read, toState = toState, write = write, action = action }

instance FromJSON StateMachine where
    parseJSON = withObject "StateMachine" $ \v -> do
        name <- v .: "name"
        alphabet <- v .: "alphabet"
        blank <- v .: "blank"
        states <- v .: "states"
        initial <- v .: "initial"
        finals <- v .: "finals"
        transitions <- v .: "transitions"
        return StateMachine { name = name, alphabet = alphabet, blank = blank, states = states, initial = initial, finals = finals, transitions = transitions }

parseFile :: FilePath -> IO (Either String StateMachine)
parseFile path = do
    content <- readFile path
    let jsonData = BL.fromStrict $ TE.encodeUtf8 $ T.pack content
    let decoded = eitherDecode jsonData :: Either String StateMachine
    return decoded
