module Game exposing
    ( Cell
    , Cellname(..)
    , Colour(..)
    , GameStatus(..)
    , Gamepiece
    , Model(..)
    , Msg(..)
    , Pattern(..)
    , Player(..)
    , Shape(..)
    , Size(..)
    , StatusMessage(..)
    , Turn(..)
    , currentStatus
    , currentStatusMessage
    , gameboard
    , init
    , nameToString
    , pieceToString
    , playerToString
    , remainingPieces
    , update
    )

import Dict exposing (Dict)
import Helpers exposing (andThen, lift, map)
import List.Extra as Liste
import List.Nonempty as Listn
import Process
import Random exposing (Generator)
import Set
import Shared exposing (Model)
import Task
import Time



-- DOMAIN


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


type alias Gamepiece =
    { shape : Shape
    , colour : Colour
    , pattern : Pattern
    , size : Size
    }


type Player
    = Human
    | Computer


type alias ActivePlayer =
    Player


type alias Winner =
    Player


type alias Cell =
    { name : Cellname
    , status : Maybe Gamepiece
    }


type alias ChosenPiece =
    Gamepiece


type Turn
    = ChoosingPiece
    | ChoosingCellToPlay ChosenPiece


type GameStatus
    = InPlay ActivePlayer Turn
    | Won Winner
    | Draw


type StatusMessage
    = NoMessage
    | SomePiecePlayedWhenNotPlayersTurn


type Model
    = Model { board : Board, status : GameStatus, statusMessage : StatusMessage }


type alias PlayedDict =
    Dict String Gamepiece


type FourOf a
    = FourOf
        { first : a
        , second : a
        , third : a
        , fourth : a
        }


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



-- INIT


initStatus : GameStatus
initStatus =
    InPlay Human ChoosingPiece


initStatusMessage : StatusMessage
initStatusMessage =
    NoMessage


init : Model
init =
    Model { board = initBoard, status = initStatus, statusMessage = initStatusMessage }



-- Msg


type Msg
    = HumanSelectedPiece Gamepiece
    | HumanSelectedCell Cellname
    | RestartWanted
    | ComputerSelectedCell Cellname
    | ComputerSelectedPiece Gamepiece



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case ( msg, model.status ) of
        ( HumanSelectedPiece piece, InPlay Human ChoosingPiece ) ->
            Model model
                |> lift
                |> map (nextPlayerStartsPlaying Human piece)
                |> andThen (computerChooses ComputerSelectedCell openCells)

        ( HumanSelectedPiece _, _ ) ->
            Model { model | statusMessage = SomePiecePlayedWhenNotPlayersTurn }
                |> lift

        ( ComputerSelectedCell name, InPlay Computer (ChoosingCellToPlay piece) ) ->
            Model model
                |> lift
                |> map (playerTryPlay name piece)
                |> (\( maybeModel, c ) ->
                        case maybeModel of
                            Just m ->
                                andThen (checkForWin Computer) ( m, c )

                            Nothing ->
                                Model model |> lift
                   )

        ( ComputerSelectedPiece piece, InPlay Computer ChoosingPiece ) ->
            Model { model | statusMessage = NoMessage }
                |> lift
                |> map (nextPlayerStartsPlaying Computer piece)

        ( HumanSelectedCell name, InPlay Human (ChoosingCellToPlay piece) ) ->
            Model { model | statusMessage = NoMessage }
                |> lift
                |> map (playerTryPlay name piece)
                |> (\( maybeModel, c ) ->
                        case maybeModel of
                            Just m ->
                                andThen (checkForWin Human) ( m, c )

                            Nothing ->
                                Model model |> lift
                   )

        ( RestartWanted, _ ) ->
            init |> lift

        _ ->
            Model model |> lift


nextPlayerStartsPlaying : ActivePlayer -> Gamepiece -> Model -> Model
nextPlayerStartsPlaying player piece (Model model) =
    Model { model | status = InPlay (switch player) (ChoosingCellToPlay piece) }


msgGenerator : (a -> Msg) -> Generator a -> (Int -> Msg)
msgGenerator msgConstructor generator =
    \num ->
        Random.initialSeed num
            |> Random.step generator
            |> (\( value, _ ) -> msgConstructor value)


computerChooses : (a -> Msg) -> (Board -> List a) -> Model -> ( Model, Cmd Msg )
computerChooses msgConstructor boardfunc (Model model) =
    let
        generator : Listn.Nonempty a -> Cmd Msg
        generator items =
            items
                |> Listn.sample
                |> msgGenerator msgConstructor
                |> delay 3
    in
    boardfunc model.board
        |> Listn.fromList
        |> Maybe.map generator
        |> Maybe.withDefault Cmd.none
        |> (\cmds -> ( Model model, cmds ))


playerTryPlay : Cellname -> Gamepiece -> Model -> Maybe Model
playerTryPlay name piece (Model model) =
    let
        newBoard =
            updateBoard name piece model.board
    in
    if newBoard == model.board then
        Nothing

    else
        Just (Model { model | board = newBoard })



-- do not remove unused status param, seems to break elm's record decomposition


checkForWin : ActivePlayer -> Model -> ( Model, Cmd Msg )
checkForWin player (Model ({ board } as model)) =
    case ( player, boardStatus board ) of
        ( Computer, CanContinue ) ->
            Model model
                |> lift
                |> map (playerStartsChoosing Computer)
                |> andThen (computerChooses ComputerSelectedPiece unPlayedPieces)

        ( Human, CanContinue ) ->
            Model model
                |> lift
                |> map (playerStartsChoosing Human)

        ( _, MatchFound ) ->
            Model { model | status = Won player }
                |> lift

        ( _, Full ) ->
            Model { model | status = Draw } |> lift


playerStartsChoosing : Player -> Model -> Model
playerStartsChoosing player (Model model) =
    Model { model | status = InPlay player ChoosingPiece }



-- Cmd Msg


type alias Seconds =
    Int


delay : Seconds -> (Int -> Msg) -> Cmd Msg
delay time generator =
    Process.sleep (toFloat <| time * 1000)
        |> Task.andThen (\_ -> Time.now)
        |> Task.perform (Time.posixToMillis >> generator)



-- UTILITY


switch : ActivePlayer -> ActivePlayer
switch player =
    if player == Human then
        Computer

    else
        Human


gameboard : Model -> (Cellname -> Cell)
gameboard (Model model) =
    \name ->
        playedPieces model.board
            |> Dict.get (nameToString name)
            |> Cell name


remainingPieces : Model -> List Gamepiece
remainingPieces (Model model) =
    unPlayedPieces model.board


currentStatus : Model -> GameStatus
currentStatus (Model model) =
    model.status


currentStatusMessage : Model -> StatusMessage
currentStatusMessage (Model model) =
    model.statusMessage


playerToString : Player -> String
playerToString player =
    case player of
        Human ->
            "Human"

        Computer ->
            "Computer"



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


initBoard : Board
initBoard =
    Liste.lift4 Gamepiece shapes colours patterns sizes
        |> List.map (PieceState Unplayed)



-- UPDATE


updateBoard : Cellname -> Gamepiece -> Board -> Board
updateBoard name gamepiece board =
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


boardStatus : Board -> BoardStatus
boardStatus board =
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
        |> (\pieces -> List.map (playedPiecesToCombo pieces) allWinningNames)
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


playedPiecesToCombo : PlayedDict -> FourOf Cellname -> Maybe (FourOf Gamepiece)
playedPiecesToCombo pieces winningNames =
    let
        get s =
            Dict.get s pieces
    in
    winningNames
        |> mapFourOf nameToString
        |> (\(FourOf s) -> Maybe.map4 fourOf (get s.first) (get s.second) (get s.third) (get s.fourth))
