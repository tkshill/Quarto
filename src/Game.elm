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
    = Model State

type alias State =
    { board : Board
    , status : GameStatus
    , statusMessage : StatusMessage }



-- INIT


initStatus : GameStatus
initStatus =
    InPlay Human ChoosingPiece


initStatusMessage : StatusMessage
initStatusMessage = NoMessage


init : Model
init = toModel init_

init_ : State
init_ =
    { board = Board.init
    , status = initStatus
    , statusMessage = initStatusMessage
    }



-- Msg


type Msg
    = HumanSelectedPiece Gamepiece
    | HumanSelectedCell Cellname
    | RestartWanted
    | ComputerSelectedCell Cellname
    | ComputerSelectedPiece Gamepiece
    | NoOp



-- UPDATE

toModel : State -> Model
toModel = Model

update : Msg -> Model -> (Model, Cmd Msg)
update msg (Model model) =
    update_ msg model
    |> map toModel


update_ : Msg -> State -> ( State, Cmd Msg )
update_ msg (model) =
    case ( msg, model.status ) of
        ( HumanSelectedPiece piece, InPlay Human ChoosingPiece ) ->
            model
                |> noCmds
                |> map (nextPlayerStartsPlaying Human piece)
                |> andThen (computerChooses ComputerSelectedCell Board.openCells)

        ( HumanSelectedPiece _, _ ) ->
            { model | statusMessage = SomePiecePlayedWhenNotPlayersTurn }
                |> noCmds

        ( ComputerSelectedCell name, InPlay Computer (ChoosingCellToPlay piece) ) ->
            model
                |> noCmds
                |> map (playerTryPlay name piece)
                |> (\( maybeModel, c ) ->
                        case maybeModel of
                            Just m ->
                                andThen (checkForWin Computer) ( m, c )

                            Nothing ->
                                model |> noCmds
                   )

        ( ComputerSelectedPiece piece, InPlay Computer ChoosingPiece ) ->
            { model | statusMessage = NoMessage }
                |> noCmds
                |> map (nextPlayerStartsPlaying Computer piece)

        ( HumanSelectedCell name, InPlay Human (ChoosingCellToPlay piece) ) ->
            { model | statusMessage = NoMessage }
                |> noCmds
                |> map (playerTryPlay name piece)
                |> (\( maybeModel, c ) ->
                        case maybeModel of
                            Just m ->
                                andThen (checkForWin Human) ( m, c )

                            Nothing ->
                                model |> noCmds
                   )

        ( RestartWanted, _ ) ->
            init_ |> noCmds

        ( NoOp, _ ) ->
            model |> noCmds

        _ ->
            model |> noCmds

nextPlayerStartsPlaying : ActivePlayer -> Gamepiece -> State -> State
nextPlayerStartsPlaying player piece model =
    { model | status = InPlay (switch player) (ChoosingCellToPlay piece) }


msgGenerator : (a -> Msg) -> Generator a -> (Int -> Msg)
msgGenerator msgConstructor generator =
    \num ->
        Random.initialSeed num
            |> Random.step generator
            |> (\( value, _ ) -> msgConstructor value)


computerChooses : (a -> Msg) -> (Board -> List a) -> State -> ( State, Cmd Msg )
computerChooses msgConstructor boardfunc (model) =
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
        |> (\cmds -> ( model, cmds ))


playerTryPlay : Cellname -> Gamepiece -> State -> Maybe State
playerTryPlay name piece model =
    let
        newBoard =
            Board.update name piece model.board
    in
    if newBoard == model.board then
        Nothing

    else
        Just { model | board = newBoard }


checkForWin : ActivePlayer -> State -> ( State, Cmd Msg )
checkForWin player ({ board, status } as model) =
    case ( player, Board.status board ) of
        ( Computer, CanContinue ) ->
            model
                |> noCmds
                |> map (playerStartsChoosing Computer)
                |> andThen (computerChooses ComputerSelectedPiece Board.unPlayedPieces)

        ( Human, CanContinue ) ->
            model
                |> noCmds
                |> map (playerStartsChoosing Human)

        ( _, MatchFound ) ->
            { model | status = Won player }
                |> noCmds

        ( _, Full ) ->
            { model | status = Draw } |> noCmds


playerStartsChoosing : Player -> State -> State
playerStartsChoosing player model =
    { model | status = InPlay player ChoosingPiece }



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


