module Game.Board exposing
    ( Board
    , BoardStatus(..)
    , Cellname(..)
    , Colour(..)
    , Gamepiece
    , Pattern(..)
    , PlayedDict
    , Shape(..)
    , Size(..)
    , init
    , nameToString
    , openCells
    , pieceToString
    , playedPieces
    , status
    , unPlayedPieces
    , update
    )

import Dict exposing (Dict)
import List.Extra as Liste
import Set



-- Domain


type Shape
    = Square
    | Circle


type Colour
    = Colour1
    | Colour2


type Pattern
    = Solid
    | Hollow


type Size
    = Small
    | Large


type alias Gamepiece =
    { shape : Shape
    , colour : Colour
    , pattern : Pattern
    , size : Size
    }


type alias PlayedDict =
    Dict String Gamepiece


type FourOf a
    = FourOf
        { first : a
        , second : a
        , third : a
        , fourth : a
        }


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


type alias GameCell =
    ( Cellname, Gamepiece )


type PieceStatus
    = Unplayed
    | Played Cellname


type alias PieceState =
    { status : PieceStatus
    , gamepiece : Gamepiece
    }


type alias Board =
    List PieceState


type BoardStatus
    = MatchFound
    | Full
    | CanContinue



-- HELPERS


shapes : List Shape
shapes =
    [ Square, Circle ]


colours : List Colour
colours =
    [ Colour1, Colour2 ]


patterns : List Pattern
patterns =
    [ Solid, Hollow ]


sizes : List Size
sizes =
    [ Small, Large ]


pieceToList : Gamepiece -> List String
pieceToList { shape, colour, pattern, size } =
    [ shapeToString shape
    , colourToString colour
    , patternToString pattern
    , sizeToString size
    ]


fourOf : a -> a -> a -> a -> FourOf a
fourOf a b c d =
    FourOf { first = a, second = b, third = c, fourth = d }


mapFourOf : (a -> b) -> FourOf a -> FourOf b
mapFourOf f (FourOf { first, second, third, fourth }) =
    fourOf (f first) (f second) (f third) (f fourth)


allNames : List Cellname
allNames =
    [ A1, A2, A3, A4, B1, B2, B3, B4, C1, C2, C3, C4, D1, D2, D3, D4 ]



-- STRINGS


shapeToString : Shape -> String
shapeToString shape =
    case shape of
        Square ->
            "Square"

        Circle ->
            "Circle"


colourToString : Colour -> String
colourToString colour =
    case colour of
        Colour1 ->
            "Colour1"

        Colour2 ->
            "Colour2"


patternToString : Pattern -> String
patternToString pattern =
    case pattern of
        Solid ->
            "Solid"

        Hollow ->
            "Hollow"


sizeToString : Size -> String
sizeToString size =
    case size of
        Small ->
            "Small"

        Large ->
            "Large"


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


pieceToString : Gamepiece -> String
pieceToString gamepiece =
    gamepiece
        |> pieceToList
        |> List.intersperse " "
        |> String.concat



-- Played pieces and Unplayed Pieces


playedPieces : Board -> PlayedDict
playedPieces boardstate =
    boardstate
        |> List.filterMap tryPieceStateToCell
        |> List.foldl dictUpdate Dict.empty


unPlayedPieces : Board -> List Gamepiece
unPlayedPieces boardstate =
    boardstate
        |> List.filter (.status >> (==) Unplayed)
        |> List.map .gamepiece


tryPieceStateToCell : PieceState -> Maybe GameCell
tryPieceStateToCell pstate =
    pstate.status
        |> tryPieceCellname
        |> Maybe.map (\name -> ( name, pstate.gamepiece ))


tryPieceCellname : PieceStatus -> Maybe Cellname
tryPieceCellname pstatus =
    case pstatus of
        Unplayed ->
            Nothing

        Played name ->
            Just name


dictUpdate : GameCell -> PlayedDict -> PlayedDict
dictUpdate ( name, piece ) dict =
    Dict.insert (nameToString name) piece dict



-- INIT


init : Board
init =
    Liste.lift4 Gamepiece shapes colours patterns sizes
        |> List.map (PieceState Unplayed)



-- UPDATE


update : Cellname -> Gamepiece -> Board -> Board
update name gamepiece board =
    let
        pieceUnplayed =
            { status = Unplayed, gamepiece = gamepiece }

        piecePlayed =
            { status = Played name, gamepiece = gamepiece }

        nameIsUnused =
            List.member name (openCells board)
    in
    Liste.setIf (\piece -> (piece == pieceUnplayed) && nameIsUnused) piecePlayed board


tryPieceStateToName : PieceState -> Maybe Cellname
tryPieceStateToName ps =
    case ps.status of
        Played name ->
            Just name

        Unplayed ->
            Nothing


openCells : Board -> List Cellname
openCells board =
    let
        taken =
            List.filterMap tryPieceStateToName board
    in
    allNames
        |> Liste.filterNot (\name -> List.member name taken)



-- BOARD status


status : Board -> BoardStatus
status board =
    if hasMatch board then
        MatchFound

    else if isFull board then
        Full

    else
        CanContinue


isFull : Board -> Bool
isFull board =
    board |> unPlayedPieces |> List.isEmpty


hasMatch : Board -> Bool
hasMatch board =
    board
        |> playedPieces
        |> (\pieces -> List.map (playedPiecesToCombos pieces) allWinningNames)
        |> List.filterMap identity
        |> List.filter isMatchingFourOf
        |> (not << List.isEmpty)


allWinningNames : List (FourOf Cellname)
allWinningNames =
    [ fourOf A1 A2 A3 A4
    , fourOf B1 B2 B3 B4
    , fourOf C1 C2 C3 C4
    , fourOf D1 D2 D3 D4
    , fourOf A1 B1 C1 D1
    , fourOf A2 B2 C2 D2
    , fourOf A3 B3 C3 D3
    , fourOf A4 B4 C4 D4
    , fourOf A1 B2 C3 D4
    , fourOf A4 B3 C2 D1
    ]


isMatchingFourOf : FourOf Gamepiece -> Bool
isMatchingFourOf (FourOf { first, second, third, fourth }) =
    let
        firstSet =
            (pieceToList >> Set.fromList) first
    in
    [ second, third, fourth ]
        |> List.map (pieceToList >> Set.fromList)
        |> List.foldl Set.intersect firstSet
        |> (not << Set.isEmpty)


playedPiecesToCombos : PlayedDict -> FourOf Cellname -> Maybe (FourOf Gamepiece)
playedPiecesToCombos pieces winningNames =
    let
        get s =
            Dict.get s pieces
    in
    winningNames
        |> mapFourOf nameToString
        |> (\(FourOf s) -> Maybe.map4 fourOf (get s.first) (get s.second) (get s.third) (get s.fourth))
