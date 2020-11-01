module Game.Board exposing
    ( BoardState
    , Cellname(..)
    , ChosenPiece
    , Colour(..)
    , Gamestatus
    , Model
    , Pattern(..)
    , PlayedPieces
    , RemainingPieces
    , Shape(..)
    , Size(..)
    , Turn
    , Winner
    , initialModel
    , isWin
    , playedPieces
    , unPlayedPieces
    , updateBoard
    )

import Dict exposing (Dict)
import List.Extra as Liste
import Set



-- SHAPE


type Shape
    = Square
    | Circle


shapes : List Shape
shapes =
    [ Square, Circle ]


shapeToString : Shape -> String
shapeToString shape =
    case shape of
        Square ->
            "Square"

        Circle ->
            "Circle"



-- COLOUR


type Colour
    = Colour1
    | Colour2


colours : List Colour
colours =
    [ Colour1, Colour2 ]


colourToString : Colour -> String
colourToString colour =
    case colour of
        Colour1 ->
            "Colour1"

        Colour2 ->
            "Colour2"



-- PATTERN


type Pattern
    = Solid
    | Hollow


patterns : List Pattern
patterns =
    [ Solid, Hollow ]


patternToString : Pattern -> String
patternToString pattern =
    case pattern of
        Solid ->
            "Solid"

        Hollow ->
            "Hollow"



-- SIZE


type Size
    = Small
    | Large


sizes : List Size
sizes =
    [ Small, Large ]


sizeToString : Size -> String
sizeToString size =
    case size of
        Small ->
            "Small"

        Large ->
            "Large"



-- GAMEPIECE


type alias Gamepiece =
    { shape : Shape
    , colour : Colour
    , pattern : Pattern
    , size : Size
    }


gamepieceToList : Gamepiece -> List String
gamepieceToList { shape, colour, pattern, size } =
    [ shapeToString shape
    , colourToString colour
    , patternToString pattern
    , sizeToString size
    ]


type alias RemainingPieces =
    List Gamepiece


type alias PlayedPieces =
    Dict String Gamepiece



-- WINNING COMBINATION


type FourOf a
    = FourOf
        { first : a
        , second : a
        , third : a
        , fourth : a
        }


fourOf : a -> a -> a -> a -> FourOf a
fourOf a b c d =
    FourOf { first = a, second = b, third = c, fourth = d }


isMatchingFourOf : FourOf Gamepiece -> Bool
isMatchingFourOf (FourOf { first, second, third, fourth }) =
    let
        firstSet =
            (gamepieceToList >> Set.fromList) first
    in
    [ second, third, fourth ]
        |> List.map (gamepieceToList >> Set.fromList)
        |> List.foldl Set.intersect firstSet
        |> (not << Set.isEmpty)



-- CELLNAME


type Cellname
    = A1
    | B1
    | C1
    | D1
    | A2
    | B2
    | C2
    | D2
    | A3
    | B3
    | C3
    | D3
    | A4
    | B4
    | C4
    | D4


winningNames : List (FourOf Cellname)
winningNames =
    [ FourOf { first = A1, second = A2, third = A3, fourth = A4 }
    , FourOf { first = B1, second = B2, third = B3, fourth = B4 }
    , FourOf { first = C1, second = C2, third = C3, fourth = C4 }
    , FourOf { first = D1, second = D2, third = D3, fourth = D4 }
    , FourOf { first = A1, second = B1, third = C1, fourth = D1 }
    , FourOf { first = A2, second = B2, third = C2, fourth = D2 }
    , FourOf { first = A3, second = B3, third = C3, fourth = D3 }
    , FourOf { first = A4, second = B4, third = C4, fourth = D4 }
    , FourOf { first = A1, second = B2, third = C3, fourth = D4 }
    , FourOf { first = A4, second = B3, third = C2, fourth = D1 }
    ]


fourOfNameToString : FourOf Cellname -> FourOf String
fourOfNameToString (FourOf { first, second, third, fourth }) =
    FourOf
        { first = nameToString first
        , second = nameToString second
        , third = nameToString third
        , fourth = nameToString fourth
        }


nameToString : Cellname -> String
nameToString name =
    case name of
        A1 ->
            "A1"

        A2 ->
            "A2"

        A3 ->
            "A3"

        A4 ->
            "A4"

        B1 ->
            "B1"

        B2 ->
            "B2"

        B3 ->
            "B3"

        B4 ->
            "B4"

        C1 ->
            "C1"

        C2 ->
            "C2"

        C3 ->
            "C3"

        C4 ->
            "C4"

        D1 ->
            "D1"

        D2 ->
            "D2"

        D3 ->
            "D3"

        D4 ->
            "D4"



-- GAMECELL


type alias GameCell =
    ( Cellname, Gamepiece )


dictUpdate : GameCell -> PlayedPieces -> PlayedPieces
dictUpdate ( name, piece ) dict =
    Dict.insert (nameToString name) piece dict



-- PIECE STATUS


type PieceStatus
    = Unplayed
    | Played Cellname


tryPieceCellname : PieceStatus -> Maybe Cellname
tryPieceCellname status =
    case status of
        Unplayed ->
            Nothing

        Played name ->
            Just name



-- PIECE STATE


type alias PieceState =
    { status : PieceStatus
    , gamepiece : Gamepiece
    }


tryPieceStateToCell : PieceState -> Maybe GameCell
tryPieceStateToCell pstate =
    pstate.status
        |> tryPieceCellname
        |> Maybe.map (\name -> ( name, pstate.gamepiece ))



-- BOARDSTATE


type alias BoardState =
    List PieceState


playedPieces : BoardState -> PlayedPieces
playedPieces boardstate =
    boardstate
        |> List.filterMap tryPieceStateToCell
        |> List.foldl dictUpdate Dict.empty


unPlayedPieces : BoardState -> RemainingPieces
unPlayedPieces boardstate =
    boardstate
        |> List.filter (.status >> (==) Unplayed)
        |> List.map .gamepiece


playedPiecesToCombos : PlayedPieces -> FourOf Cellname -> Maybe (FourOf Gamepiece)
playedPiecesToCombos pieces winningCells =
    let
        get s =
            Dict.get s pieces
    in
    winningCells
        |> fourOfNameToString
        |> (\(FourOf s) -> Maybe.map4 fourOf (get s.first) (get s.second) (get s.third) (get s.fourth))


isWin : BoardState -> Bool
isWin board =
    board
        |> playedPieces
        |> (\pieces -> List.map (playedPiecesToCombos pieces) winningNames)
        |> List.filterMap identity
        |> List.filter isMatchingFourOf
        |> (not << List.isEmpty)


type alias ChosenPiece =
    Gamepiece


type Turn
    = HumanChoosing
    | ComputerPlaying ChosenPiece
    | ComputerChoosing
    | HumanPlaying ChosenPiece


type alias Winner =
    String



-- GAMESTATUS


type Gamestatus
    = InPlay Turn
    | Won Winner
    | Draw



-- MODEL


type alias Model =
    { board : BoardState
    , status : Gamestatus
    }



-- INIT


initialBoard : BoardState
initialBoard =
    Liste.lift4 Gamepiece shapes colours patterns sizes
        |> List.map (PieceState Unplayed)


initialGamestatus : Gamestatus
initialGamestatus =
    InPlay HumanChoosing


initialModel : Model
initialModel =
    { board = initialBoard
    , status = initialGamestatus
    }


updateBoard : Cellname -> Gamepiece -> BoardState -> BoardState
updateBoard name gamepiece board =
    if
        List.any ((==) { status = Unplayed, gamepiece = gamepiece }) board
            && not (List.any (\ps -> ps.status == Played name) board)
    then
        board
            |> List.filter ((/=) { status = Unplayed, gamepiece = gamepiece })
            |> (::) { status = Played name, gamepiece = gamepiece }

    else
        board



--
