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
            return ()
        _ -> putStrLn "Usage: ft_turing [-h] jsonfile input"
  where
    usage = "positional arguments:\n  jsonfile    json description of the machine\n  input       input of the machine\noptional arguments:\n  -h, --help  show this help message and exit"