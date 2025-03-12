{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE InstanceSigs #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use lambda-case" #-}

module Parser where


import Data.Aeson
    ( eitherDecode,
      (.:),
      withObject,
      withText,
      FromJSON(parseJSON),
      Value )
import Data.Aeson.Types (Parser)
import Prelude hiding (read, Left, Right)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.ByteString.Lazy as BL
import Data.Maybe (fromMaybe)
import System.IO (readFile)
import StateMachine (Action(..), Transition(..), StateMachine(..))
import Debug.Trace (trace, traceShow, traceM)
import qualified Data.Either as E
import Data.List ((\\), nub)
import qualified Data.Map as Map

instance FromJSON Action where
    parseJSON :: Value -> Parser Action
    parseJSON = withText "Action" $ \t -> case t of
        "LEFT"  -> return StateMachine.Left
        "RIGHT" -> return StateMachine.Right
        _       -> fail "Invalid Action"

instance FromJSON Transition where
    parseJSON :: Value -> Parser Transition
    parseJSON = withObject "Transition" $ \v -> do
        read <- v .: "read"
        toState <- v .: "to_state"
        write <- v .: "write"
        action <- v .: "action"
        return Transition { read = read, toState = toState, write = write, action = action }

instance FromJSON StateMachine where
    parseJSON :: Value -> Parser StateMachine
    parseJSON = withObject "StateMachine" $ \v -> do
        name <- v .: "name"
        alphabet <- v .: "alphabet"
        blank <- v .: "blank"
        states <- v .: "states"
        initial <- v .: "initial"
        finals <- v .: "finals"
        transitions <- v .: "transitions"

        let invalidStrings = filter (\s -> length s /= 1) alphabet
        if not (null invalidStrings)
            then fail $ "Invalid alphabet: " ++ show invalidStrings
        else if length blank /= 1
            then fail "Blank must be a single character"
        else if blank `notElem` alphabet
            then fail "Blank must be part of the alphabet"
        else if initial `notElem` states
            then fail "Initial state must be part of the states"
        else if any (`notElem` states) finals
            then fail "All final states must be part of the states"
        else if length (nub states) < 2
            then fail "There must be at least two different states"
        else if initial `elem` finals
            then fail "Initial state and final states must be different"
        else do
            let transitionGroups = Map.elems transitions
            let invalidGroups = filter (\ts -> length (nub (map toState ts)) < 2) transitionGroups
            let initialTransitions = Map.lookup initial transitions
            case initialTransitions of
                Nothing -> fail "Initial state must have at least one transition"
                Just ts -> if null ts
                    then fail "Initial state must have at least one transition"
                    else return ()
            if not (null invalidGroups)
                then fail "Each state must have at least two transitions with different to_state values"
            else if not (any (`elem` finals) (concatMap (\t -> [toState t]) (concatMap snd (Map.toList transitions))))
                then fail "There must be at least one to_state equal to at least one final state in all transitions"
            else do
                let allTransitions = concatMap snd (Map.toList transitions)
                let invalidReads = filter (\t -> length (read t) /= 1 || read t `notElem` alphabet) allTransitions
                let invalidToStates = filter (\t -> toState t `notElem` states) allTransitions
                let invalidWrites = filter (\t -> length (write t) /= 1 || write t `notElem` alphabet) allTransitions
                if not (null invalidReads)
                    then fail $ "Invalid read in transitions: " ++ show (map read invalidReads)
                else if not (null invalidToStates)
                    then fail $ "Invalid to_state in transitions: " ++ show (map toState invalidToStates)
                else if not (null invalidWrites)
                    then fail $ "Invalid write in transitions: " ++ show (map write invalidWrites)
                else return StateMachine { name = name, alphabet = alphabet, blank = blank, states = states, initial = initial, finals = finals, transitions = transitions }


parseFile :: FilePath -> String -> IO (Either String StateMachine)
parseFile path input = do
    content <- readFile path
    let jsonData = BL.fromStrict $ TE.encodeUtf8 $ T.pack content
    let decoded = eitherDecode jsonData :: Either String StateMachine
    case decoded of
        E.Left err -> do
            print err
            return (E.Left err)
        E.Right stateMachine -> do
            let alphabetSet = alphabet stateMachine
            let invalidChars = filter (`notElem` alphabetSet) (map (:[]) input)
            if null invalidChars && blank stateMachine `notElem` map (:[]) input
                then do
                    -- | print (E.Right stateMachine :: Either String StateMachine)
                    return (E.Right stateMachine)
                else do
                    let errMsg = "Invalid characters in input: " ++ show invalidChars
                    print errMsg
                    return (E.Left errMsg)
    return decoded
