{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE EmptyCase #-}

module Parser where
import Data.Aeson
-- import Data.Aeson.WarningParser
import Data.Aeson.Types (Parser)
import qualified Data.Aeson.KeyMap as KM
import Data.Text (Text)
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
import Prelude as P hiding (read, Left, Right)

instance FromJSON Action where
    parseJSON = withText "Action" $ \t -> case t of
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

        let invalidStrings = filter (\s -> length s /= 1) alphabet
        let checks = [ (not (null invalidStrings), "Invalid alphabet: " ++ show invalidStrings)
                     , (length blank /= 1, "Blank must be a single character")
                     , (blank `notElem` alphabet, "Blank must be part of the alphabet")
                     , (initial `notElem` states, "Initial state must be part of the states")
                     , (any (`notElem` states) finals, "All final states must be part of the states")
                     , (length (nub states) < 2, "There must be at least two different states")
                     , (initial `elem` finals, "Initial state and final states must be different")
                     ]

        case filter fst checks of
            (True, errMsg):_ -> fail errMsg
            _ -> do
                let transitionGroups = Map.toList transitions
                let stateNames = map fst transitionGroups
                let duplicateStates = stateNames \\ nub stateNames
                let invalidGroups = filter (\(state, ts) -> all (\t -> toState t == state) ts) transitionGroups
                let initialTransitions = Map.lookup initial transitions
                case initialTransitions of
                    Nothing -> fail "Initial state must have at least one transition"
                    Just ts -> if null ts
                        then fail "Initial state must have at least one transition"
                        else return ()
                if not (null invalidGroups)
                    then fail "Each state must have at least one transition with a to_state different from the state's name"
                else if not (any (`elem` finals) (concatMap (\t -> [toState t]) (concatMap snd (Map.toList transitions))))
                    then fail "There must be at least one to_state equal to at least one final state in all transitions"
                else do
                    let allTransitions = concatMap snd (Map.toList transitions)
                    let invalidReads = filter (\t -> length (StateMachine.read t) /= 1 || StateMachine.read t `notElem` alphabet) allTransitions
                    let invalidToStates = filter (\t -> toState t `notElem` states) allTransitions
                    let invalidWrites = filter (\t -> length (write t) /= 1 || write t `notElem` alphabet) allTransitions
                    let invalidTransitionStates = filter (\(state, _) -> state `notElem` states) transitionGroups
                    let transitionChecks = [ (not (null invalidReads), "Invalid read in transitions: " ++ show (map StateMachine.read invalidReads))
                                        , (not (null invalidToStates), "Invalid to_state in transitions: " ++ show (map toState invalidToStates))
                                        , (not (null invalidWrites), "Invalid write in transitions: " ++ show (map write invalidWrites))
                                        , (not (null invalidTransitionStates), "Invalid state in transitions: " ++ show (map fst invalidTransitionStates))
                                        ]
                    let invalidStates = (states \\ map fst transitionGroups) \\ finals
                    if not (null invalidStates)
                        then fail $ "Invalid states in transitions: " ++ show invalidStates
                    else if any (\(state, _) -> state `elem` finals) transitionGroups
                        then fail "Transition groups must not have the same name as final states"
                    else
                        case filter fst transitionChecks of
                                    (True, errMsg):_ -> fail errMsg
                                    _ -> return StateMachine { name = name, alphabet = alphabet, blank = blank, states = states, initial = initial, finals = finals, transitions = transitions }

parseFile :: FilePath -> String -> IO (Either String StateMachine)
parseFile path input = do
    content <- readFile path
    let jsonData = BL.fromStrict $ TE.encodeUtf8 $ T.pack content
    let decoded = eitherDecode jsonData :: Either String StateMachine
    case decoded of
        E.Left err -> return (E.Left err)
        E.Right stateMachine -> do
            let alphabetSet = alphabet stateMachine
            let invalidChars = filter (`notElem` alphabetSet) (map (:[]) input)
            if null invalidChars && blank stateMachine `notElem` map (:[]) input
                then return (E.Right stateMachine)
            else return (E.Left $ "Invalid characters in input: " ++ show invalidChars)
