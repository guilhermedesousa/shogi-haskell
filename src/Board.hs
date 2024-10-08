module Board (createInitialBoard, isPromotionZone, printBoard, Cell, Board, GameState(..), ShogiGame) where

import Control.Monad.State
import Data.List (intercalate)
import Player
import Piece hiding (isPromoted)
import Utils

type Cell = Maybe Piece
type Board = [[Cell]]

data GameState = GameState {
    board          :: Board,
    capturedPieces :: ([Maybe Piece], [Maybe Piece]),
    currentPlayer  :: Player
}

type ShogiGame a = StateT GameState IO a

createCell :: Player -> PieceType -> Cell
createCell player pieceType = Just (Piece pieceType player False)

-- [lança, cavalo, general de prata, general de ouro, rei, general de ouro, general de prata, cavalo, lança]
createThirdRow :: Player -> [Cell]
createThirdRow player = [createCell player Lanca, createCell player Cavalo, createCell player General_Prata,
                         createCell player General_Ouro, createCell player Rei, createCell player General_Ouro,
                         createCell player General_Prata, createCell player Cavalo, createCell player Lanca]

-- [vazio, torre, vazio, vazio, vazio, vazio, vazio, bispo, vazio]
createSecondRowA :: Player -> [Cell]
createSecondRowA player = [Nothing, createCell player Torre, Nothing,
                          Nothing, Nothing, Nothing,
                          Nothing, createCell player Bispo, Nothing]

-- [vazio, bispo, vazio, vazio, vazio, vazio, vazio, torre, vazio]
createSecondRowB :: Player -> [Cell]
createSecondRowB player = [Nothing, createCell player Bispo, Nothing,
                          Nothing, Nothing, Nothing,
                          Nothing, createCell player Torre, Nothing]

-- [peão, peão, peão, peão, peão, peão, peão, peão, peão]
createFirstRow :: Player -> [Cell]
createFirstRow player = [createCell player Peao, createCell player Peao, createCell player Peao,
                         createCell player Peao, createCell player Peao, createCell player Peao,
                         createCell player Peao, createCell player Peao, createCell player Peao]

createEmptyRow :: [Cell]
createEmptyRow = [Nothing, Nothing, Nothing,
                  Nothing, Nothing, Nothing,
                  Nothing, Nothing, Nothing]

createInitialBoard :: Board
createInitialBoard = [
    createThirdRow A,
    createSecondRowA A,
    createFirstRow A,
    createEmptyRow,
    createEmptyRow,
    createEmptyRow,
    createFirstRow B,
    createSecondRowB B,
    createThirdRow B]

isPromotionZone :: Player -> Position -> Bool
isPromotionZone player (row, _) =
    case player of
        A -> row == 6 || row == 7 || row == 8
        B -> row == 2 || row == 1 || row == 0

-- *códigos das cores retirados do chatgpt
greenColor, yellowColor, blueColor, whiteColor, resetColor :: String
greenColor  = "\x1b[92m" -- Verde
yellowColor = "\x1b[33m" -- Amarelo
blueColor   = "\x1b[34m" -- Azul
whiteColor  = "\x1b[37m" -- Branco
resetColor  = "\x1b[0m"  -- Reseta para cor padrão

-- *código para colorir saída no terminal retirado do chatgpt
printPiece :: Piece -> String
printPiece (Piece pieceType player isPromoted) = case player of
    A -> case pieceType of
        Peao          -> pieceColor ++ (if isPromoted then "と" else "歩") ++ resetColor
        Lanca         -> pieceColor ++ (if isPromoted then "仝" else "香") ++ resetColor
        Cavalo        -> pieceColor ++ (if isPromoted then "今" else "桂") ++ resetColor
        General_Prata -> pieceColor ++ (if isPromoted then "全" else "銀") ++ resetColor
        General_Ouro  -> pieceColor ++ "金" ++ resetColor
        Bispo         -> pieceColor ++ (if isPromoted then "馬" else "角") ++ resetColor
        Torre         -> pieceColor ++ (if isPromoted then "龍" else "飛") ++ resetColor
        Rei           -> pieceColor ++ "王" ++ resetColor
    B -> case pieceType of
        Peao          -> pieceColor ++ (if isPromoted then "と" else "歩") ++ resetColor
        Lanca         -> pieceColor ++ (if isPromoted then "仝" else "香") ++ resetColor
        Cavalo        -> pieceColor ++ (if isPromoted then "今" else "桂") ++ resetColor
        General_Prata -> pieceColor ++ (if isPromoted then "全" else "銀") ++ resetColor
        General_Ouro  -> pieceColor ++ "金" ++ resetColor
        Bispo         -> pieceColor ++ (if isPromoted then "馬" else "角") ++ resetColor
        Torre         -> pieceColor ++ (if isPromoted then "龍" else "飛") ++ resetColor
        Rei           -> pieceColor ++ "玉" ++ resetColor
    where
        pieceColor = case player of
            A -> if isPromoted then greenColor else yellowColor
            B -> if isPromoted then whiteColor else blueColor

printCell :: Cell -> String
printCell Nothing      = "    "
printCell (Just piece) = " " ++ printPiece piece ++ " "

-- *código para printar as linhas numeradas retirado do chatgpt
printBoard :: ShogiGame ()
printBoard = do
    b <- gets board
    lift $ putStrLn " a  | b  | c  | d  | e  | f  | g  | h  |  i |" -- cabeçalho
    lift $ putStrLn "---------------------------------------------"
    lift $ putStrLn (unlines (zipWith showRow b [1..9]))
    where
        showRow :: [Cell] -> Int -> String
        showRow row n = intercalate "|" (map printCell row) ++ "| " ++ show n