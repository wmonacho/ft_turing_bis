module Main where

import System.Environment (getArgs)
import Parser (parseFile)

main :: IO ()
main = do
    args <- getArgs
    case args of
        [filePath] -> do
            parsedData <- parseFile filePath
            return ()
        _ -> putStrLn "Usage: program <file-path>"