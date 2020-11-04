module Game exposing
    ( Cell
    , Cellname
    , Gamepiece
    , Model(..)
    , Msg(..)
    , Status(..)
    , currentStatus
    , gameboard
    , init
    , remainingPieces
    , update
    )

import Dict
import Game.Board as Board
    exposing
        ( Board
        , BoardStatus(..)
        , Cellname
        , Gamepiece
        )
import List.Nonempty as Listn
import Process
import Random
import Shared exposing (Model)
import Task



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


type alias Cellname =
    Board.Cellname


type alias Gamepiece =
    Board.Gamepiece


type alias ChosenPiece =
    Gamepiece


type GeneratorOptions
    = GetGamepiece
    | GetCell


type Turn
    = ChoosingPiece
    | ChoosingCellToPlay ChosenPiece


type Status
    = InPlay ActivePlayer Turn
    | Won Winner
    | Draw


type Model
    = Model { board : Board, status : Status }



-- INIT


initStatus : Status
initStatus =
    InPlay Human ChoosingPiece


init : Model
init =
    Model { board = Board.init, status = initStatus }



-- Msg


type Msg
    = HumanSelectedPiece Gamepiece
    | HumanSelectedCell Cellname
    | RestartWanted
    | ComputerSelectedCell Cellname
    | ComputerSelectedPiece Gamepiece
    | NoOp



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case ( msg, model.status ) of
        ( HumanSelectedPiece piece, InPlay Human ChoosingPiece ) ->
            Model model
                |> noCmds
                |> map (nextPlayerStartsPlaying Human piece)
                |> withCmd (wait 2)
                |> andThen (computerChooses GetCell)

        ( ComputerSelectedCell name, InPlay Computer (ChoosingCellToPlay piece) ) ->
            Model model
                |> noCmds
                |> map (playerMakesPlay name piece)
                |> andThen (checkForWin Computer)

        ( ComputerSelectedPiece piece, InPlay Computer ChoosingPiece ) ->
            Model model
                |> noCmds
                |> map (nextPlayerStartsPlaying Computer piece)

        ( HumanSelectedCell name, InPlay Human (ChoosingCellToPlay piece) ) ->
            Model model
                |> noCmds
                |> map (playerMakesPlay name piece)
                |> andThen (checkForWin Human)

        ( RestartWanted, _ ) ->
            init |> noCmds

        ( NoOp, _ ) ->
            Model model |> noCmds

        _ ->
            Model model |> noCmds


nextPlayerStartsPlaying : ActivePlayer -> Gamepiece -> Model -> Model
nextPlayerStartsPlaying player piece (Model model) =
    Model { model | status = InPlay (switch player) (ChoosingCellToPlay piece) }


computerChooses : GeneratorOptions -> Model -> ( Model, Cmd Msg )
computerChooses opt (Model model) =
    let
        helper : (a -> Msg) -> List a -> ( Model, Cmd Msg )
        helper msg lst =
            lst
                |> Listn.fromList
                |> Maybe.map
                    (\items ->
                        ( Model model, Random.generate msg (Listn.sample items) )
                    )
                |> Maybe.withDefault (Model model |> noCmds)
    in
    case opt of
        GetCell ->
            Board.openCells model.board
                |> helper ComputerSelectedCell

        GetGamepiece ->
            Board.unPlayedPieces model.board
                |> helper ComputerSelectedPiece


playerMakesPlay : Cellname -> Gamepiece -> Model -> Model
playerMakesPlay name piece (Model model) =
    let
        newBoard =
            Board.update name piece model.board
    in
    Model { model | board = newBoard }


checkForWin : ActivePlayer -> Model -> ( Model, Cmd Msg )
checkForWin player (Model ({ board, status } as model)) =
    case ( player, Board.status board ) of
        ( Computer, CanContinue ) ->
            Model model
                |> noCmds
                |> map (playerStartsChoosing Computer)
                |> withCmd (wait 2)
                |> andThen (computerChooses GetGamepiece)

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



-- CMD


withCmd : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withCmd cmds ( model, moreCmds ) =
    ( model, Cmd.batch [ cmds, moreCmds ] )


noCmds : Model -> ( Model, Cmd Msg )
noCmds model =
    ( model, Cmd.none )


map : (Model -> Model) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
map f ma =
    andThen (noCmds << f) ma


andThen : (Model -> ( Model, Cmd Msg )) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen f ( model, cmds ) =
    let
        ( newModel, moreCmds ) =
            f model
    in
    ( newModel, Cmd.batch [ cmds, moreCmds ] )


type Seconds
    = Seconds Int


wait : Int -> Cmd Msg
wait i =
    delay (Seconds i) NoOp


delay : Seconds -> Msg -> Cmd Msg
delay (Seconds time) msg =
    Process.sleep (toFloat <| time * 1000)
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity



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


currentStatus : Model -> Status
currentStatus (Model model) =
    model.status
