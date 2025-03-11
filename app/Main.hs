module Main where

import System.Environment (getArgs)
import Parser (parseFile)

main :: IO ()
main = do
    args <- getArgs
    case args of
        ["-h"] -> putStrLn usage
        ["--help"] -> putStrLn usage
        [jsonFilePath, input] -> do
            parsedData <- parseFile jsonFilePath input
            -- | Appeler la machine de Turing ici. avec pasedData (StateMachine) et input (String)
            return ()
        _ -> putStrLn usage
  where
    usage = "Usage: ft_turing [-h] jsonfile input\n\n" ++
            "positional arguments:\n  jsonfile    json description of the machine\n  input       input of the machine\n" ++
            "optional arguments:\n  -h, --help  show this help message and exit"