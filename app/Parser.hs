{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}

module Parser where

import Data.Aeson
import Data.Aeson.Types (Parser)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.ByteString.Lazy as BL
import Data.Maybe (fromMaybe)
import System.IO (readFile)
import StateMachine (Action(..), Transition(..), StateMachine(..))
import Control.Monad.IO.Class (liftIO)

instance FromJSON Action where
    parseJSON = withText "Action" $ \t -> case t of
        "Left"  -> return StateMachine.Left
        "Right" -> return StateMachine.Right
        _       -> fail "Invalid Action"

instance FromJSON Transition where
    parseJSON = withObject "Transition" $ \v -> Transition
        <$> v .: "read"
        <*> v .: "toState"
        <*> v .: "write"
        <*> v .: "action"

instance FromJSON StateMachine where
    parseJSON = withObject "StateMachine" $ \v -> do
        name <- v .: "name"
        alphabet <- v .: "alphabet"
        blank <- v .: "blank"
        states <- v .: "states"
        initial <- v .: "initial"
        finals <- v .: "finals"
        transitions <- v .: "transitions"
        
        let invalidChars = filter (not . isChar) alphabet
        if null invalidChars
            then return StateMachine
                { name = name
                , alphabet = alphabet
                , blank = blank
                , states = states
                , initial = initial
                , finals = finals
                , transitions = transitions
                }
            else fail $ "Invalid characters in alphabet: " ++ show invalidChars

-- Helper function to check if a value is a character
isChar :: Char -> Bool
isChar c = c >= ' ' && c <= '~'

parseFile :: FilePath -> IO (Maybe StateMachine)
parseFile path = do
    content <- readFile path
    let jsonData = BL.fromStrict $ TE.encodeUtf8 $ T.pack content
    return $ decode jsonData
