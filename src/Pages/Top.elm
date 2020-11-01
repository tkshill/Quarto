module Pages.Top exposing
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
import Process
import Set
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url
import Styles
import Svg exposing (Svg, svg)
import Svg.Attributes as Attr
import Task


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
    { name : Cellname
    , state : Cellstate
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


type alias SelectedPiece =
    Gamepiece


type Turn
    = HumanChoosing
    | ComputerPlaying SelectedPiece
    | ComputerChoosing
    | HumanPlaying SelectedPiece


type alias Winner =
    String


type Gamestatus
    = InPlay Turn
    | Won Winner
    | Draw


type alias Model =
    { board : CellBoard
    , remainingPieces : List Gamepiece
    , gamestatus : Gamestatus
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



-- Turn helpers


turnToActivePlayer : Turn -> String
turnToActivePlayer turn =
    case turn of
        HumanChoosing ->
            "Human Player"

        HumanPlaying _ ->
            "Human Player"

        ComputerChoosing ->
            "Computer Player"

        ComputerPlaying _ ->
            "Computer Player"



-- INIT


initialTurn : Turn
initialTurn =
    HumanChoosing


initialCells : CellBoard
initialCells =
    let
        nameToCell name =
            { name = name, state = EmptyCell }
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
    , gamestatus = InPlay initialTurn
    }


type alias Params =
    ()


init : Url.Url Params -> ( Model, Effect )
init _ =
    ( initModel, NoEffect )



-- UPDATE


type Msg
    = ClickedPiece Gamepiece
    | ClickedGameboard Cell
    | ClickedRestart
    | HumanChosePiece
    | ComputerPlayedPiece


update : Msg -> Model -> ( Model, Effect )
update msg model =
    case ( msg, model.gamestatus ) of
        ( ClickedPiece gamepiece, InPlay HumanChoosing ) ->
            { model | gamestatus = InPlay (ComputerPlaying gamepiece) }
                |> withEffect (Delay 2 HumanChosePiece)

        ( HumanChosePiece, InPlay (ComputerPlaying gamepiece) ) ->
            tryFindAvailableCells model.board
                |> Maybe.map (updateGamepiecePlaced gamepiece model)
                |> Maybe.map (checkForWin (ComputerPlaying gamepiece))
                |> Maybe.withDefault (withNoEffects model)

        ( ComputerPlayedPiece, InPlay ComputerChoosing ) ->
            trySelectpiece model.remainingPieces
                |> Maybe.map (\piece -> { model | gamestatus = InPlay (HumanPlaying piece) })
                |> Maybe.withDefault { model | gamestatus = Draw }
                |> withNoEffects

        ( ClickedGameboard cell, InPlay (HumanPlaying gamepiece) ) ->
            updateCellClicked cell gamepiece model

        ( ClickedRestart, Won _ ) ->
            initModel |> withNoEffects

        ( ClickedRestart, Draw ) ->
            initModel |> withNoEffects

        _ ->
            model |> withNoEffects



-- Update Helpers


updateCellClicked : Cell -> Gamepiece -> Model -> ( Model, Effect )
updateCellClicked cell piece model =
    case cell.state of
        Occupied _ ->
            model |> withNoEffects

        EmptyCell ->
            updateGamepiecePlaced piece model cell.name
                |> checkForWin (HumanPlaying piece)


tryFindAvailableCells : CellBoard -> Maybe Cellname
tryFindAvailableCells b =
    [ b.a1
    , b.a2
    , b.a3
    , b.a4
    , b.b1
    , b.b2
    , b.b3
    , b.b4
    , b.c1
    , b.c2
    , b.c3
    , b.c4
    , b.d1
    , b.d2
    , b.d3
    , b.d4
    ]
        |> List.filter (\cell -> cell.state == EmptyCell)
        |> List.map (\cell -> cell.name)
        |> List.head


trySelectpiece : List Gamepiece -> Maybe Gamepiece
trySelectpiece gamepiece =
    List.head gamepiece


updateGamepiecePlaced : Gamepiece -> Model -> Cellname -> Model
updateGamepiecePlaced gamepiece model name =
    let
        newBoard =
            updateCellBoard name gamepiece model.board

        remainingPieces =
            updateRemaining gamepiece model.remainingPieces
    in
    { model | remainingPieces = remainingPieces, board = newBoard }


checkForWin : Turn -> Model -> ( Model, Effect )
checkForWin turn model =
    case ( turn, isWin model.board ) of
        ( _, True ) ->
            { model | gamestatus = Won (turnToActivePlayer turn) }
                |> withNoEffects

        ( HumanPlaying _, False ) ->
            { model | gamestatus = InPlay HumanChoosing }
                |> withNoEffects

        ( ComputerPlaying _, False ) ->
            { model | gamestatus = InPlay ComputerChoosing }
                |> withEffect (Delay 2 ComputerPlayedPiece)

        _ ->
            model |> withNoEffects


updateCellBoard : Cellname -> Gamepiece -> CellBoard -> CellBoard
updateCellBoard name piece board =
    let
        newCell =
            { name = name, state = Occupied piece }
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


updateRemaining : Gamepiece -> List Gamepiece -> List Gamepiece
updateRemaining piece remainingPieces =
    List.filter ((/=) piece) remainingPieces


boardToWinnableCells : CellBoard -> List (List Cell)
boardToWinnableCells board =
    let
        isCellFilled { state } =
            state /= EmptyCell
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
        |> List.filter (List.all isCellFilled)


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
        |> List.map (List.map (\{ state } -> state))
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



-- Cmd and Effects


type alias Seconds =
    Int


type Effect
    = NoEffect
    | Delay Seconds Msg



-- Cmd and Effect Helpers


delay : Float -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


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

        Delay seconds msg ->
            delay (toFloat seconds * 1000) msg



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
            [ viewRemainingPieces model.remainingPieces
            , viewGamestatus model.gamestatus
            , viewBoard model.board
            ]
        ]
    }


viewRemainingPieces : List Gamepiece -> Element Msg
viewRemainingPieces remainingPieces =
    column [ spacing 10, centerX ]
        [ el [ Font.center, width fill ] (text "Remaining Pieces")
        , column [ centerX ] <|
            List.map (row [ centerX ]) <|
                Liste.greedyGroupsOf 4 <|
                    List.map viewRemainingPiecesButton remainingPieces
        ]


viewGamestatus : Gamestatus -> Element Msg
viewGamestatus gamestatus =
    let
        containerize : Element Msg -> Element Msg
        containerize elem =
            column [] [ el [ Font.center, width fill ] (text "Game Status"), elem ]
    in
    case gamestatus of
        Won winner ->
            row [] [ viewSvgbox [ Svg.text <| "Winner: " ++ winner ], viewRestartButton ]
                |> containerize

        Draw ->
            containerize (row [] [ viewSvgbox [ Svg.text "It's a Draw" ], viewRestartButton ])

        InPlay (ComputerPlaying gamepiece) ->
            row []
                [ text "Piece Selected: "
                , viewGamepiece gamepiece
                , text <| "Active Player: " ++ turnToActivePlayer (ComputerPlaying gamepiece)
                ]
                |> containerize

        InPlay (HumanPlaying gamepiece) ->
            row []
                [ text "Piece Selected: "
                , viewGamepiece gamepiece
                , text <| "Active Player: " ++ turnToActivePlayer (HumanPlaying gamepiece)
                ]
                |> containerize

        InPlay turn ->
            row []
                [ viewSvgbox
                    [ Svg.rect [ Attr.width "60", Attr.height "60", Attr.fill "none" ] [] ]
                , text <| "Active Player: " ++ turnToActivePlayer turn
                ]
                |> containerize


viewCell : Cell -> Element Msg
viewCell { name, state } =
    case state of
        Occupied gamepiece ->
            viewGamepiece gamepiece

        EmptyCell ->
            viewSvgbox [ Svg.text <| cellnameToString name ]


viewCellButton : Cell -> Element Msg
viewCellButton cell =
    Input.button
        [ Border.color Styles.blue, Border.width 5, Region.description (cellStateToDescription cell) ]
        { onPress = Just (ClickedGameboard cell)
        , label = viewCell cell
        }


viewRestartButton : Element Msg
viewRestartButton =
    Input.button [ Background.color Styles.blue, Border.width 5, Font.color Styles.white ]
        { onPress = Just ClickedRestart, label = text "Restart" }


viewBoard : CellBoard -> Element Msg
viewBoard cellboard =
    column [ centerX, Region.announce ]
        [ el [ Font.center, width fill ] (text "GameBoard")
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
        { onPress = Just (ClickedPiece gamepiece)
        , label = gamePieceImage
        }


viewGamepiece : Gamepiece -> Element msg
viewGamepiece gamepiece =
    gamepiece
        |> makeGamepieceSvg
        |> (\singleSvg -> viewSvgbox [ singleSvg ])



-- Description helper functions


cellStateToDescription : Cell -> String
cellStateToDescription { name, state } =
    case state of
        EmptyCell ->
            "Cell " ++ cellnameToString name ++ ": Empty cell"

        Occupied gamepiece ->
            "Cell " ++ cellnameToString name ++ ": " ++ gamepieceToString gamepiece



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
