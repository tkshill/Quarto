module Game exposing
    ( Cell
    , GameStatus(..)
    , Model
    , Msg(..)
    , Player(..)
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
    , viewBoard
    , viewRemainingPieces
    )

import Angle
import Camera3d
import Color
import Dict
import Direction3d
import Element exposing (Element)
import Game.Board as Board
    exposing
        ( Board
        , BoardStatus(..)
        )
import Game.Core exposing (Cellname(..), Gamepiece)
import Helpers exposing (andThen, map, noCmds)
import Length exposing (Meters)
import LineSegment3d exposing (LineSegment3d)
import List.Extra as Liste
import List.Nonempty as Listn
import Pixels
import Point3d
import Process
import Random exposing (Generator)
import Scene3d
import Scene3d.Material as Material
import Task
import Time
import Viewpoint3d



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
    , statusMessage : StatusMessage
    }



-- INIT


initStatus : GameStatus
initStatus =
    InPlay Human ChoosingPiece


initStatusMessage : StatusMessage
initStatusMessage =
    NoMessage


init : Model
init =
    toModel init_


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
toModel =
    Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    update_ msg model
        |> map toModel


update_ : Msg -> State -> ( State, Cmd Msg )
update_ msg model =
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
computerChooses msgConstructor boardfunc model =
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



------------- 3d stuff ------------------


type alias CenterPoint =
    ( Float, Float )


initCoords : List CenterPoint
initCoords =
    let
        vals =
            [ -1.5, -0.5, 0.5, 1.5 ]

        helper x y =
            ( x, y )
    in
    Liste.lift2 helper vals vals


centerPointToLineSegments : CenterPoint -> List (LineSegment3d Meters coordinates)
centerPointToLineSegments ( x, y ) =
    -- top line
    [ LineSegment3d.fromEndpoints ( Point3d.meters (x - 0.5) (y + 0.5) 0, Point3d.meters (x + 0.5) (y + 0.5) 0 )
    -- right line
    , LineSegment3d.fromEndpoints ( Point3d.meters (x + 0.5) (y + 0.5) 0, Point3d.meters (x + 0.5) (y - 0.5) 0 )
    -- bottom line
    , LineSegment3d.fromEndpoints ( Point3d.meters (x + 0.5) (y - 0.5) 0, Point3d.meters (x - 0.5) (y - 0.5) 0 )
    -- left line
    , LineSegment3d.fromEndpoints ( Point3d.meters (x - 0.5) (y - 0.5) 0, Point3d.meters (x - 0.5) (y + 0.5) 0 )
    ]


viewBoard : Model -> Element msg
viewBoard _ =
    Element.none


viewRemainingPieces : Model -> Element msg
viewRemainingPieces _ =
    let
        lineSegmentEntities =
            initCoords
            |> List.concatMap centerPointToLineSegments
            |> List.map (Scene3d.lineSegment (Material.color Color.blue))
        -- Create a camera using perspective projection
        camera =
            Camera3d.perspective
                { -- Camera is at the point (4, 2, 2), looking at the point
                  -- (0, 0, 0), oriented so that positive Z appears up
                  viewpoint =
                    Viewpoint3d.lookAt
                        { focalPoint = Point3d.origin
                        , eyePoint = Point3d.meters 7.0 3.5 3.5
                        , upDirection = Direction3d.positiveZ
                        }

                -- The image on the screen will have a total rendered 'height'
                -- of 30 degrees; small angles make the camera act more like a
                -- telescope and large numbers make it act more like a fisheye
                -- lens
                , verticalFieldOfView = Angle.degrees 30
                }
    in
    -- Render a scene that doesn't involve any lighting (no lighting is needed
    -- here since we provided a material that will result in a constant color
    -- no matter what lighting is used)
    Scene3d.unlit
        { -- Our scene has a single 'entity' in it
          entities = lineSegmentEntities
            -- [ Scene3d.quad (Material.color Color.blue)
            --     (Point3d.meters -1 -1 0)
            --     (Point3d.meters 1 -1 0)
            --     (Point3d.meters 1 1 0)
            --     (Point3d.meters -1 1 0)
            -- ]

        -- Provide the camera to be used when rendering the scene
        , camera = camera

        -- Anything closer than 1 meter to the camera will be clipped away
        -- (this is necessary because of the internals of how WebGL works)
        , clipDepth = Length.meters 1

        -- Using a transparent background means that the HTML underneath the
        -- scene will show through
        , background = Scene3d.transparentBackground

        -- Size in pixels of the generated HTML element
        , dimensions = ( Pixels.int 500, Pixels.int 375 )
        }
        |> Element.html
