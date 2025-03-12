module Main where

import Prelude --hiding (Left, Right)

import System.Environment (getArgs)
import Parser (parseFile)
import Machine
import StateMachine (StateMachine, Transition, blank, initial)
import Data.List (intercalate)
import qualified Data.Map as Map
-- import qualified Prelude as SM

main :: IO ()
main = do
    args <- getArgs
    case args of
        ["-h"] -> putStrLn usage
        ["--help"] -> putStrLn usage
        [jsonFilePath, input] -> do
            parseData <- parseFile jsonFilePath input
            -- | Appeler la machine de Turing ici. avec pasedData (StateMachine) et input (String)
            case parseData of
                Left err -> putStrLn ("Error: " ++ err)
                Right sm -> do
                    displayMachineData sm
                    let tr = getTransisionFromName (initial sm) sm
                    case tr of
                        Just transitions -> do
                            -- let basic_list_pos = [(blank sm), (blank sm)..]
                            let basic_list_pos = [(head (blank sm)), (head (blank sm))..]
                            let basic_list_neg = [(head (blank sm)), (head (blank sm))..]
                            let max_ellements = 7
                            -- let max_ellements = 4
                            let turing_sequence = ['1', '1', '1', '-', '1', '1', '='] ++ basic_list_pos
                            -- let turing_sequence = ["1", "1", "1", "1"] ++ basic_list_pos
                            runTuringMachine turing_sequence basic_list_neg sm transitions 0 (initial sm) max_ellements (blank sm)
                            putStrLn "End"
                        Nothing -> do
                            putStrLn $ "Initial transition not found."
        _ -> putStrLn usage
  where
    usage = "Usage: ft_turing [-h] jsonfile input\n\n" ++
            "positional arguments:\n  jsonfile    json description of the machine\n  input       input of the machine\n" ++
            "optional arguments:\n  -h, --help  show this help message and exit"