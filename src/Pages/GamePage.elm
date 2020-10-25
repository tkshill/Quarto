module Pages.GamePage exposing
    ( Colour(..)
    , Effect(..)
    , Gamepiece
    , Model
    , Msg
    , Params
    , Pattern(..)
    , Shape(..)
    , Size(..)
    , initModel
    , matchingDimensions
    , page
    , update
    , view
    , withNoEffects
    )

import Element exposing (Element, centerX, column, el, fill, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import List.Extra as Liste
import Pages.NotFound exposing (Msg)
import Set
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url
import Styles
import Svg exposing (Svg, svg)
import Svg.Attributes as Attr
import Task
import Process

page : Page Params Model Msg
page =
    Page.element
        { init =
            \params ->
                init params |> Tuple.mapSecond perform
        , update =
            \msg model ->
                update msg model |> Tuple.mapSecond perform
        , view = view
        , subscriptions = subscriptions
        }



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


type alias Gamepiece =
    { shape : Shape
    , colour : Colour
    , pattern : Pattern
    , size : Size
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


type Cellstate
    = EmptyCell
    | Occupied Gamepiece


type alias Cell =
    { cellname : Cellname
    , cellstate : Cellstate
    }


type alias CellBoard =
    { a1 : Cell
    , a2 : Cell
    , a3 : Cell
    , a4 : Cell
    , b1 : Cell
    , b2 : Cell
    , b3 : Cell
    , b4 : Cell
    , c1 : Cell
    , c2 : Cell
    , c3 : Cell
    , c4 : Cell
    , d1 : Cell
    , d2 : Cell
    , d3 : Cell
    , d4 : Cell
    }


type Player
    = HumanPlayer String
    | ComputerPlayer String


type SelectedPiece
    = Selected Gamepiece
    | NoPieceSelected

type CurrentTurn
    = Player1Selecting
    | Player2Playing
    | Player2Selecting
    | Player1Playing

type Gamestatus
    = GameInProgress SelectedPiece CurrentTurn
    | GameWon Player
    | Draw


type alias Model =
    { board : CellBoard
    , remainingPieces : List Gamepiece
    , gamestatus : Gamestatus
    , player1 : Player
    , player2 : Player
    }



-- Gamepiece Dimension helpers


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



-- Gamepiece helpers


gamepieceToList : Gamepiece -> List String
gamepieceToList { shape, colour, pattern, size } =
    [ shapeToString shape
    , colourToString colour
    , patternToString pattern
    , sizeToString size
    ]


gamepieceToString : Gamepiece -> String
gamepieceToString gamepiece =
    gamepiece
        |> gamepieceToList
        |> List.intersperse " "
        |> String.concat



-- Cell Name Helpers


cellnameToString : Cellname -> String
cellnameToString name =
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



-- Cell helpers


cellstateToMaybe : Cellstate -> Maybe Gamepiece
cellstateToMaybe cellstate =
    case cellstate of
        Occupied gamepiece ->
            Just gamepiece

        EmptyCell ->
            Nothing


-- Player helpers



playerToString : Player -> String
playerToString player =
    case player of
        HumanPlayer p ->
            p

        ComputerPlayer p ->
            p


delay : Float -> msg -> Cmd msg
delay time msg =
  Process.sleep time
  |> Task.perform (\_ -> msg)

-- INIT

initialCurrentTurn : CurrentTurn
initialCurrentTurn =
    Player1Selecting

initialPlayer1 : Player
initialPlayer1 =
    HumanPlayer "Human"

initialPlayer2 : Player
initialPlayer2 =
    ComputerPlayer "Beep Boop"

initialSelectedPiece : SelectedPiece
initialSelectedPiece =
    NoPieceSelected


initialCells : CellBoard
initialCells =
    let
        nameToCell name =
            { cellname = name, cellstate = EmptyCell }
    in
    { a1 = nameToCell A1
    , a2 = nameToCell A2
    , a3 = nameToCell A3
    , a4 = nameToCell A4
    , b1 = nameToCell B1
    , b2 = nameToCell B2
    , b3 = nameToCell B3
    , b4 = nameToCell B4
    , c1 = nameToCell C1
    , c2 = nameToCell C2
    , c3 = nameToCell C3
    , c4 = nameToCell C4
    , d1 = nameToCell D1
    , d2 = nameToCell D2
    , d3 = nameToCell D3
    , d4 = nameToCell D4
    }


initialPieces : List Gamepiece
initialPieces =
    Liste.lift4 Gamepiece shapes colours patterns sizes


initModel : Model
initModel =
    { board = initialCells
    , remainingPieces = initialPieces
    , gamestatus = GameInProgress initialSelectedPiece initialCurrentTurn
    , player1 = initialPlayer1
    , player2 = initialPlayer2
    }


type alias Params =
    ()


init : Url.Url Params -> ( Model, Effect )
init _ =
    ( initModel, NoEffect )



-- UPDATE




type Msg
    = SelectedAvilableGampiece Gamepiece
    | SelectedCellOnGameBoard Cell
    | ClickedRestartGameButton
    | ComputerPlayerAction


type Effect
    = NoEffect


update : Msg -> Model -> ( Model, Effect )
update msg model =
    case msg of
        SelectedAvilableGampiece gamepiece ->
            updateSelectingGamepiece gamepiece model
                |> withNoEffects

        SelectedCellOnGameBoard cell ->
            updateGamepiecePlaced cell model
                |> withNoEffects

        ClickedRestartGameButton ->
            initModel |> withNoEffects

        ComputerPlayerAction ->
            handleComputerAction model
                |> withNoEffects



-- Update Helpers
withEffect : Effect -> Model -> ( Model, Effect )
withEffect effect model =
    ( model, effect )


withNoEffects : Model -> ( Model, Effect )
withNoEffects =
    withEffect NoEffect



perform : Effect -> Cmd Msg
perform effect =
    case effect of
        NoEffect ->
            Cmd.none


withCmd : Model -> ( Model, Cmd Msg )
withCmd model =
    case model.player2 of
        ComputerPlayer n ->
            case model.gamestatus of
                GameInProgress _ Player2Playing ->
                    (model, delay (500) <| ComputerPlayerAction)
                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )



handleComputerAction : Model -> Model
handleComputerAction model =
    case model.gamestatus of
        -- GameInProgress _ Player1Selecting ->
        --     Just (SelectedAvilableGampiece gamepiece)

        -- GameInProgress _ Player2Selecting ->
        --     Just (SelectedAvilableGampiece gamepiece)

        -- GameInProgress selectedPiece Player1Playing ->
        --     Just (SelectedCellOnGameBoard cell)

        -- GameInProgress selectedPiece Player2Playing ->
        --     Just (SelectedCellOnGameBoard cell)

        _ -> (model)



updateGamepiecePlaced : Cell -> Model -> Model
updateGamepiecePlaced { cellname, cellstate } ({ board, remainingPieces, gamestatus } as model) =
    case (model.gamestatus, cellstate) of
        ( GameInProgress (Selected gamepiece) currentTurn, EmptyCell ) ->

            let
                newBoard =
                    updateCellBoard cellname gamepiece model.board

                newRemainingPieces =
                    removeGamepieceFromRemaining gamepiece remainingPieces

                newCurrentTurn =
                    updateCurrentTurn currentTurn

                win =
                    isWin newBoard

            in
            case ( win, remainingPieces, currentTurn) of
                ( True, _, Player1Playing ) ->
                    { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = GameWon model.player1 }

                ( True, _, Player2Playing ) ->
                    { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = GameWon model.player2 }

                ( _, [], _ ) ->
                    { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = Draw }

                _ ->
                    { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = GameInProgress NoPieceSelected newCurrentTurn }


        _ ->
            model


updateSelectingGamepiece : Gamepiece -> Model -> Model
updateSelectingGamepiece gamepiece model =
    case model.gamestatus of
    -- player 1 is selecting and player 1 is a human
        GameInProgress NoPieceSelected currentTurn ->
            let

                newPieceSelected =
                    Selected gamepiece

                newCurrentTurn =
                    updateCurrentTurn currentTurn
            in
            { model | gamestatus = GameInProgress newPieceSelected newCurrentTurn }
            -- return command message

        _ ->
            model


updateCurrentTurn : CurrentTurn -> CurrentTurn
updateCurrentTurn turn =
    case turn of
        Player1Selecting ->
            Player2Playing

        Player1Playing ->
            Player1Selecting

        Player2Selecting ->
            Player1Playing

        Player2Playing ->
            Player2Selecting


updateCellBoard : Cellname -> Gamepiece -> CellBoard -> CellBoard
updateCellBoard name piece board =
    let
        newCell =
            { cellname = name, cellstate = Occupied piece }
    in
    case name of
        A1 ->
            { board | a1 = newCell }

        A2 ->
            { board | a2 = newCell }

        A3 ->
            { board | a3 = newCell }

        A4 ->
            { board | a4 = newCell }

        B1 ->
            { board | b1 = newCell }

        B2 ->
            { board | b2 = newCell }

        B3 ->
            { board | b3 = newCell }

        B4 ->
            { board | b4 = newCell }

        C1 ->
            { board | c1 = newCell }

        C2 ->
            { board | c2 = newCell }

        C3 ->
            { board | c3 = newCell }

        C4 ->
            { board | c4 = newCell }

        D1 ->
            { board | d1 = newCell }

        D2 ->
            { board | d2 = newCell }

        D3 ->
            { board | d3 = newCell }

        D4 ->
            { board | d4 = newCell }


removeGamepieceFromRemaining : Gamepiece -> List Gamepiece -> List Gamepiece
removeGamepieceFromRemaining piece remainingPieces =
    List.filter ((/=) piece) remainingPieces


boardToWinnableCells : CellBoard -> List (List Cell)
boardToWinnableCells board =
    let
        isCellEmpty { cellstate } =
            cellstate == EmptyCell
    in
    [ [ board.a1, board.a2, board.a3, board.a4 ] -- column A
    , [ board.b1, board.b2, board.b3, board.b4 ] -- column B
    , [ board.c1, board.c2, board.c3, board.c4 ] -- column C
    , [ board.d1, board.d2, board.d3, board.d4 ] -- column D
    , [ board.a1, board.b1, board.c1, board.d1 ] -- row 1
    , [ board.a2, board.b2, board.c2, board.d2 ] -- row 2
    , [ board.a3, board.b3, board.c3, board.d3 ] -- row 3
    , [ board.a4, board.b4, board.c4, board.d4 ] -- row 4
    , [ board.a1, board.b2, board.c3, board.d4 ] -- back slash diagonal
    , [ board.a4, board.b3, board.c2, board.d1 ] -- forward slash diagonal
    ]
        |> List.filter (List.all isCellEmpty)


matchingDimensions : List Gamepiece -> Bool
matchingDimensions gamepieces =
    gamepieces
        -- convert from list of game pieces to sets of strings
        |> List.map (gamepieceToList >> Set.fromList)
        -- { "Circle", "Filled", "Colour1, ""Large"}
        -- interset the sets to make one set of common values
        |> Liste.foldl1 Set.intersect
        -- convert from Maybe set to set
        |> Maybe.withDefault Set.empty
        -- return True is set isn't empty, false if it is
        |> not
        << Set.isEmpty


isWin : CellBoard -> Bool
isWin board =
    board
        -- turn  a board to list of lists of game winning cells
        |> boardToWinnableCells
        -- strip cell names
        |> List.map (List.map (\{ cellstate } -> cellstate))
        -- convert cells to gamepieces and filter out cells that dont have gamepieces in them
        |> List.map (List.map cellstateToMaybe)
        |> List.map (List.filterMap identity)
        -- filter out those that aren't filled in
        |> List.filter (\x -> List.length x >= 4)
        -- turn to list of booleans on if cells have matches
        |> List.map matchingDimensions
        -- filter out false values
        |> List.filter identity
        -- if any values remain, return  bool
        |> not
        << List.isEmpty



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Quarto - Play"
    , body =
        [ column [ spacing 10, centerX ]
            [
              viewRemainingPieces model.remainingPieces
            , viewGamestatus model.gamestatus model.player1 model.player2
            , viewBoard model.board
            ]
        ]
    }

viewRemainingPieces: List Gamepiece -> Element Msg
viewRemainingPieces remainingPieces =

    column [spacing 10, centerX]
    [
        el [ Font.center, width fill ] (text "Remaining Pieces")
        , column [ centerX ] <|
                List.map (row [ centerX ]) <|
                    Liste.greedyGroupsOf 4 <|
                        List.map viewRemainingPiecesButton remainingPieces]






viewGamestatus : Gamestatus -> Player -> Player -> Element Msg
viewGamestatus gamestatus player1 player2 =
    let

        containerize : Element Msg -> Element Msg
        containerize elem = column [] [ (el [ Font.center, width fill ] (text "Game Status")), elem ]
    in
    case gamestatus of
        GameWon winner ->
            row [] [ viewSvgbox [ Svg.text <| "Winner: " ++ playerToString winner ], viewRestartButton]
            |> containerize


        Draw ->
            containerize (row [] [ viewSvgbox [ Svg.text "It's a Draw" ], viewRestartButton])


        GameInProgress selectedGamepiece currentTurn ->
            case (currentTurn, selectedGamepiece) of
                (Player1Playing, Selected gamepiece) ->
                    row []
                        [ text <| playerToString player2 ++ " has selected "
                        , viewGamepiece gamepiece
                        , text <| "It's " ++ playerToString player1 ++ "'s turn!"
                        ]

                (Player2Playing, Selected gamepiece) ->
                    row []
                        [ text <| playerToString player1 ++ " has selected "
                        , viewGamepiece gamepiece
                        , text <| "It's " ++ playerToString player2 ++ "'s turn!"
                        ]

                (Player1Selecting, _) ->
                    row []
                        [ viewSvgbox
                            [ Svg.rect [ Attr.width "60", Attr.height "60", Attr.fill "none" ] [] ]
                        , text <| playerToString player1 ++ "'s turn to select a piece!"
                        ]
                    |> containerize

                (Player2Selecting, _) ->
                    row []
                        [ viewSvgbox
                            [ Svg.rect [ Attr.width "60", Attr.height "60", Attr.fill "none" ] [] ]
                        , text <| playerToString player2 ++ "'s turn to select a piece!"
                        ]
                    |> containerize

                _ ->
                    row []
                        [ text <| "This is an impossible state"
                        ]



viewCell : Cell -> Element Msg
viewCell { cellname, cellstate } =
    case cellstate of
        Occupied gamepiece ->
            viewGamepiece gamepiece

        EmptyCell ->
            viewSvgbox [ Svg.text <| cellnameToString cellname ]


viewCellButton : Cell -> Element Msg
viewCellButton cell =
    Input.button
        [ Border.color Styles.blue, Border.width 5, Region.description (cellStateToDescription cell) ]
        { onPress = Just (SelectedCellOnGameBoard cell)
        , label = viewCell cell
        }


viewRestartButton : Element Msg
viewRestartButton =
    Input.button [ Background.color Styles.blue, Border.width 5, Font.color Styles.white ]
        { onPress = Just ClickedRestartGameButton, label = text "Restart" }




viewBoard : CellBoard -> Element Msg
viewBoard cellboard =
    column [ centerX ]
        [  el [ Font.center, width fill ] (text "GameBoard")
        , row [] <| List.map viewCellButton [ cellboard.a1, cellboard.b1, cellboard.c1, cellboard.d1 ]
        , row [] <| List.map viewCellButton [ cellboard.a2, cellboard.b2, cellboard.c2, cellboard.d2 ]
        , row [] <| List.map viewCellButton [ cellboard.a3, cellboard.b3, cellboard.c3, cellboard.d3 ]
        , row [] <| List.map viewCellButton [ cellboard.a4, cellboard.b4, cellboard.c4, cellboard.d4 ]
        ]


viewRemainingPiecesButton : Gamepiece -> Element Msg
viewRemainingPiecesButton gamepiece =
    let
        gamePieceImage =
            viewGamepiece gamepiece

        ariaDescription =
            gamepieceToString gamepiece
    in
    Input.button [ Region.description ariaDescription ]
        { onPress = Just (SelectedAvilableGampiece gamepiece)
        , label = gamePieceImage
        }



viewGamepiece : Gamepiece -> Element msg
viewGamepiece gamepiece =
    gamepiece
        |> makeGamepieceSvg
        |> (\singleSvg -> viewSvgbox [ singleSvg ])



-- Description helper functions


cellStateToDescription : Cell -> String
cellStateToDescription { cellname, cellstate } =
    case cellstate of
        EmptyCell ->
            "Cell " ++ cellnameToString cellname ++ ": Empty cell"

        Occupied gamepiece ->
            "Cell " ++ cellnameToString cellname ++ ": " ++ gamepieceToString gamepiece



-- Svg gamepiece helper funxtions


viewSvgbox : List (Svg msg) -> Element msg
viewSvgbox objects =
    Element.html <|
        svg [ Attr.width "60", Attr.height "60", Attr.viewBox "0 0 60 60" ] objects


shapeAndSizeToSvgfuncAndAttrs :
    Shape
    -> Size
    ->
        ( List (Svg.Attribute msg)
          -> List (Svg msg)
          -> Svg msg
        , List (Svg.Attribute msg)
        )
shapeAndSizeToSvgfuncAndAttrs shape size =
    case ( shape, size ) of
        ( Circle, Small ) ->
            ( Svg.circle, [ Attr.r "15", Attr.cx "30", Attr.cy "30" ] )

        ( Circle, Large ) ->
            ( Svg.circle, [ Attr.r "25", Attr.cx "30", Attr.cy "30" ] )

        ( Square, Small ) ->
            ( Svg.rect, [ Attr.x "15", Attr.y "15", Attr.width "30", Attr.height "30" ] )

        ( Square, Large ) ->
            ( Svg.rect, [ Attr.x "5", Attr.y "5", Attr.width "50", Attr.height "50" ] )


colourToSvgAttrs : Colour -> List (Svg.Attribute msg)
colourToSvgAttrs colour =
    case colour of
        Colour1 ->
            [ Styles.colortoCssRGBString Styles.red
                |> Attr.color
            ]

        Colour2 ->
            [ Styles.colortoCssRGBString Styles.yellow
                |> Attr.color
            ]


patternToSvgAttrs : Pattern -> List (Svg.Attribute msg)
patternToSvgAttrs pattern =
    case pattern of
        Solid ->
            [ Attr.fill "currentcolor" ]

        Hollow ->
            [ Attr.fill "none", Attr.strokeWidth "5", Attr.stroke "currentcolor" ]


makeGamepieceSvg : Gamepiece -> Svg msg
makeGamepieceSvg { shape, colour, pattern, size } =
    let
        ( shapefunc, sizeAttributes ) =
            shapeAndSizeToSvgfuncAndAttrs shape size

        colourAttributes =
            colourToSvgAttrs colour

        patternAttributes =
            patternToSvgAttrs pattern
    in
    shapefunc (List.concat [ patternAttributes, colourAttributes, sizeAttributes ]) []
