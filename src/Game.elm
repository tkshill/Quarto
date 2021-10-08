module Game exposing
    ( Cell
    , GameStatus(..)
    , Model(..)
    , Msg(..)
    , Player(..)
    , Turn(..)
    , StatusMessage(..)
    , currentStatus
    , gameboard
    , init
    , nameToString
    , pieceToString
    , playerToString
    , remainingPieces
    , currentStatusMessage
    , update
    )

import Dict
import Game.Board as Board
    exposing
        ( Board
        , BoardStatus(..)
        )
import Game.Core exposing (Cellname(..), Gamepiece)
import Helpers exposing (andThen, map, noCmds)
import List.Nonempty as Listn
import Process
import Random exposing (Generator)
import Shared exposing (Model)
import Task
import Time



-- DOMAIN


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



-- INIT


initStatus : GameStatus
initStatus =
    InPlay Human ChoosingPiece


initStatusMessage : StatusMessage
initStatusMessage = NoMessage


init : Model
init =
    Model { board = Board.init, status = initStatus, statusMessage = initStatusMessage }



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
                |> noCmds
                |> map (nextPlayerStartsPlaying Human piece)
                |> andThen (computerChooses ComputerSelectedCell Board.openCells)

        ( HumanSelectedPiece piece, _ ) ->
            Model { model | statusMessage = SomePiecePlayedWhenNotPlayersTurn }
                |> noCmds

        ( ComputerSelectedCell name, InPlay Computer (ChoosingCellToPlay piece) ) ->
            Model model
                |> noCmds
                |> map (playerTryPlay name piece)
                |> (\( maybeModel, c ) ->
                        case maybeModel of
                            Just m ->
                                andThen (checkForWin Computer) ( m, c )

                            Nothing ->
                                Model model |> noCmds
                   )

        ( ComputerSelectedPiece piece, InPlay Computer ChoosingPiece ) ->
            Model { model | statusMessage = NoMessage }
                |> noCmds
                |> map (nextPlayerStartsPlaying Computer piece)

        ( HumanSelectedCell name, InPlay Human (ChoosingCellToPlay piece) ) ->
            Model { model | statusMessage = NoMessage }
                |> noCmds
                |> map (playerTryPlay name piece)
                |> (\( maybeModel, c ) ->
                        case maybeModel of
                            Just m ->
                                andThen (checkForWin Human) ( m, c )

                            Nothing ->
                                Model model |> noCmds
                   )

        ( RestartWanted, _ ) ->
            init |> noCmds

        _ ->
            Model model |> noCmds


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
            Board.update name piece model.board
    in
    if newBoard == model.board then
        Nothing

    else
        Just (Model { model | board = newBoard })


checkForWin : ActivePlayer -> Model -> ( Model, Cmd Msg )
checkForWin player (Model ({ board, status } as model)) =
    case ( player, Board.status board ) of
        ( Computer, CanContinue ) ->
            Model model
                |> noCmds
                |> map (playerStartsChoosing Computer)
                |> andThen (computerChooses ComputerSelectedPiece Board.unPlayedPieces)

        ( Human, CanContinue ) ->
            Model model
                |> noCmds
                |> map (playerStartsChoosing Human)

        ( _, MatchFound ) ->
            Model { model | status = Won player }
                |> noCmds

        ( _, Full ) ->
            Model { model | status = Draw } |> noCmds


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
        Board.playedPieces model.board
            |> Dict.get (Board.nameToString name)
            |> Cell name


remainingPieces : Model -> List Gamepiece
remainingPieces (Model model) =
    Board.unPlayedPieces model.board


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


nameToString : Cellname -> String
nameToString =
    Board.nameToString


pieceToString : Gamepiece -> String
pieceToString =
    Board.pieceToString
