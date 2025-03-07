module StateMachine where

import qualified Data.Map as Map
import Prelude hiding (read, Left, Right)
import GHC.Generics
import Control.Exception

data Action = Left | Right deriving (Show, Eq)

data Transition = Transition {
    read :: String,
    toState :: String,
    write :: String,
    action :: Action
} deriving (Show, Eq)

data StateMachine = StateMachine {
    name :: String,
    alphabet :: [String],
    blank :: String,
    states :: [String],
    initial :: String,
    finals :: [String],
    transitions :: Map.Map String [Transition]
} deriving (Show, Eq)

machine :: StateMachine
machine = StateMachine {
    name = "unary_sub",
    alphabet = ["1", ".", "-", "="],
    blank = ".",
    states = ["scanright", "eraseone", "subone", "skip", "HALT"],
    initial = "scanright",
    finals = ["HALT"],
    transitions = Map.fromList [
        ("scanright", [
            Transition { read = ".", toState = "scanright", write = ".", action = Right },
            Transition { read = "1", toState = "scanright", write = "1", action = Right },
            Transition { read = "-", toState = "scanright", write = "-", action = Right },
            Transition { read = "=", toState = "eraseone", write = ".", action = Left }
        ]),
        ("eraseone", [
            Transition { read = "1", toState = "subone", write = "=", action = Left },
            Transition { read = "-", toState = "HALT", write = ".", action = Left }
        ]),
        ("subone", [
            Transition { read = "1", toState = "subone", write = "1", action = Left },
            Transition { read = "-", toState = "skip", write = "-", action = Left }
        ]),
        ("skip", [
            Transition { read = ".", toState = "skip", write = ".", action = Left },
            Transition { read = "1", toState = "scanright", write = ".", action = Right }
        ])
    ]
}
