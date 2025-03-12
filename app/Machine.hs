module Machine where

import qualified Data.Map as Map
import Prelude hiding (read, Left, Right)
import Data.List (intercalate)
import Parser
import StateMachine

returnStr :: String -> IO String
returnStr str = do
    putStrLn str
    return str

multiplyByTwo :: Int -> Int
multiplyByTwo value = do
    value * 2

evenOrOdd :: Int -> String
evenOrOdd value
    | mod value 2 == 1 = "Odd"
    | otherwise = "Even"

printList :: Show a => [a] -> IO ()
printList [] = return ()
printList (x:xs) = do
    print x
    printList xs

printListReverse :: [Char] -> IO ()
printListReverse [] = return ()
printListReverse (x:xs) = do
    printListReverse xs
    print x

addEllListEnd :: [Char] -> Char -> [Char]
addEllListEnd [] v = [v]
addEllListEnd (x:xs) v = x : addEllListEnd xs v

addEllListBeg :: [Char] -> Char -> [Char]
addEllListBeg xs v = [v] ++ xs

addEllListPos :: [Char] -> Char -> Int -> [Char]
addEllListPos [] v _ = [v]
addEllListPos (x:xs) v p
    | p == 0 = [v] ++ [x] ++ xs
    | otherwise = x : addEllListPos xs v (p-1)

remEllListBeg :: [Char] -> [Char]
remEllListBeg [] = []
remEllListBeg (_:xs) = xs

remEllListEnd :: [Char] -> [Char]
remEllListEnd [] = []
remEllListEnd [_] = []
remEllListEnd (x:xs) = x:remEllListEnd xs

remEllListPos :: [Char] -> Int -> [Char]
remEllListPos [] _ = []
remEllListPos (x:xs) p
    | p == 0 = xs
    | otherwise = x : remEllListPos xs (p-1)

replaceEllListPos :: [Char] -> Char -> Int -> [Char]
replaceEllListPos [] _ _ = []
replaceEllListPos (x:xs) v p
    | p == 0 = [v] ++ xs
    | otherwise = x : replaceEllListPos xs v (p-1)

getEllListPos :: [Char] -> Int -> Char
getEllListPos [] _ = '0'
getEllListPos (x:xs) p
    | p == 0 = x
    | otherwise = getEllListPos xs (p-1)

getTransisionFromName :: String -> StateMachine -> Maybe [Transition]
getTransisionFromName tr_name state = Map.lookup tr_name (transitions state)

getSingleTransitionFromAlphabet :: [Transition] -> Char -> Transition
getSingleTransitionFromAlphabet [] _ = error ("No Transition found")
getSingleTransitionFromAlphabet (x:xs) ch
    | ch == (head (read x)) = x
    | otherwise = getSingleTransitionFromAlphabet xs ch

printTransitionList :: [Transition] -> IO ()
printTransitionList [] = return ()
printTransitionList (x:xs) = do
    putStrLn "===="
    print (read x)
    print (toState x)
    print (write x)
    let ac = (action x)
    if ac == Right then putStrLn "Right"
    else putStrLn "Left"
    printTransitionList xs

convertToChars :: [String] -> [Char]
convertToChars = concatMap id

printWithIndex :: [Char] -> [Char] -> Int -> Int -> IO ()
printWithIndex lst back_lst idx max_ell = do
    if idx < 0 then do
        let small_lst = 
                if (-idx) > 8
                then take (-idx + 2) back_lst
                else take 9 back_lst
        let before = take (-idx-1) small_lst
        let charAtIdx = small_lst !! (-idx - 1)
        let after = drop (-idx + 1) small_lst
        let result = before ++ ">" ++ [charAtIdx] ++ "<" ++ after
        let reverse_lst = "[" ++ reverse result ++ "]"
        putStr reverse_lst
        let toPrint2 = "[" ++ take (max_ell + 10) lst ++ "] "
        putStr toPrint2
    else do
        let small_lst = 
                if (idx) > (max_ell + 7)
                then take (idx + 4) lst
                else take (max_ell + 8) lst
        let before = take idx small_lst
        let charAtIdx = small_lst !! idx
        let after = drop (idx + 1) small_lst
        let result = "[" ++ before ++ "<" ++ [charAtIdx] ++ ">" ++ after ++ "] "
        let toPrint = "[" ++ reverse (take 10 back_lst) ++ "]"
        putStr toPrint
        putStr result

printCharListRaw :: [String] -> IO ()
printCharListRaw lst = do
    -- putStrLn $ "[" ++ intercalate ", " (map (:[]) lst) ++ "]"
    putStrLn $ "[ ]"

printStringListRaw :: [String] -> IO ()
printStringListRaw lst = do
    putStrLn $ "[" ++ intercalate ", " (map (show) lst) ++ "]"

printTransition :: Transition -> String -> IO ()
printTransition tr tr_name = do
    let ac = (action tr)
    putStr $ "(" ++ tr_name ++ ", " ++ show (read tr) ++ ")" ++ " -> (" ++ show (toState tr) ++ ", " ++ show (write tr) ++ ", "
    if ac == Right then putStrLn "RIGHT)"
    else putStrLn "LEFT)"

displayMachineData :: StateMachine -> IO ()
displayMachineData machine = do
    putStrLn "********************************************************************************"
    putStrLn (name machine)
    putStrLn "********************************************************************************"
    putStr "Alphabet: "
    printStringListRaw (alphabet machine)
    putStr "State: "
    printStringListRaw (states machine)
    putStr "Initial: "
    print (initial machine)
    putStr "Finals: "
    printStringListRaw (finals machine)
    putStrLn "********************************************************************************"


checkEndState :: [String] -> String -> Bool
checkEndState final_lst curent_final = elem curent_final final_lst

--  Detect infinite loop
runTuringMachine :: [Char] -> [Char] -> StateMachine -> [Transition] -> Int -> String -> Int -> String -> IO ()
runTuringMachine [] [] _ _ _ _ _ _ = return ()
runTuringMachine ts back_ts turing_machine turing_state index current_state max_ell previous_char = do
    let current_char = 
            if index >= 0 
            then getEllListPos ts index
            else getEllListPos back_ts (-index - 1)
    let current_transition = getSingleTransitionFromAlphabet turing_state current_char
    let next_state = getTransisionFromName (toState current_transition) turing_machine
    printWithIndex ts back_ts index max_ell
    printTransition current_transition current_state
    case next_state of
        Nothing -> do
            return ()
        Just transitions -> do
            if (checkEndState (finals turing_machine) current_state) then return ()
            else if (index < 0 || index > max_ell) && previous_char == (blank turing_machine) && previous_char == (read current_transition) then do
                print previous_char
                print (read current_transition)
                error ("Error Machine probable infinite loop")
            else if (read current_transition) /= (write current_transition) then do
                if index < 0 then do
                    let updated_input = replaceEllListPos back_ts (head (write current_transition)) (-index - 1)
                    if (action current_transition) == Right then do
                        runTuringMachine ts updated_input turing_machine transitions (index + 1) (toState current_transition) max_ell (read current_transition)
                    else do
                        runTuringMachine ts updated_input turing_machine transitions (index - 1) (toState current_transition) max_ell (read current_transition)
                else do
                    let updated_input = replaceEllListPos ts (head (write current_transition)) index
                    if (action current_transition) == Right then do
                        runTuringMachine updated_input back_ts turing_machine transitions (index + 1) (toState current_transition) max_ell (read current_transition)
                    else do
                        runTuringMachine updated_input back_ts turing_machine transitions (index - 1) (toState current_transition) max_ell (read current_transition)
            else do
                if (action current_transition) == Right then do
                    runTuringMachine ts back_ts turing_machine transitions (index + 1) (toState current_transition) max_ell (read current_transition)
                else do
                    runTuringMachine ts back_ts turing_machine transitions (index - 1) (toState current_transition) max_ell (read current_transition)

-- ..0011..