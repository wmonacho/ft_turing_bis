module Main where

import System.Environment (getArgs)
import Parser (parseFile)
import StateMachine (StateMachine, blank)

main :: IO ()
main = do
    args <- getArgs
    case args of
        ["-h"] -> putStrLn usage
        ["--help"] -> putStrLn usage
        [jsonFilePath, input] -> do
            result <- parseFile jsonFilePath input
            case result of
                Left err -> putStrLn $ "Error: " ++ err
                Right stateMachine -> do
                    -- Appeler la machine de Turing ici avec stateMachine (StateMachine) et input (String)
                    print (blank stateMachine)
                    putStrLn "StateMachine parsed successfully"
                    -- Ajoutez ici le code pour utiliser stateMachine et input
                    return ()
        _ -> putStrLn usage
  where
    usage = "Usage: ft_turing [-h] jsonfile input\n\n" ++
            "positional arguments:\n  jsonfile    json description of the machine\n  input       input of the machine\n" ++
            "optional arguments:\n  -h, --help  show this help message and exit"