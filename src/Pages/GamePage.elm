module Pages.GamePage exposing
    ( Colour(..)
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
    , withCmd
    )

import Element exposing (Element, centerX, column, el, fill, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import List.Extra as Liste
import Pages.NotFound exposing (Msg)
import Set
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url
import Styles
import Svg exposing (Svg, svg)
import Svg.Attributes as Attr


page : Page Params Model Msg
page =
    Page.element
        { init = init
        , update = update
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
    = Player1
    | Player2


type alias Activeplayer =
    Player


type alias Winner =
    Player


type SelectedPiece
    = Selected Gamepiece
    | NoPieceSelected


type Gamestatus
    = GameInProgress Activeplayer SelectedPiece
    | GameWon Winner
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
        Player1 ->
            "Player1"

        Player2 ->
            "Player2"



-- INIT


initialPlayer : Player
initialPlayer =
    Player1


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
    , gamestatus = GameInProgress initialPlayer initialSelectedPiece
    }


type alias Params =
    ()


init : Url.Url Params -> ( Model, Cmd Msg )
init _ =
    initModel |> withCmd



-- UPDATE
-- Messages


type Msg
    = ClickedAvilableGampiece Gamepiece
    | ClickedCellOnGameBoard Cell
    | ClickedRestartGameButton


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedAvilableGampiece gamepiece ->
            updateSelectingGamepiece gamepiece model
                |> withCmd

        ClickedCellOnGameBoard cell ->
            updateGamepiecePlaced cell model
                |> withCmd

        ClickedRestartGameButton ->
            initModel
                |> withCmd



-- Update Helpers


withCmd : Model -> ( Model, Cmd Msg )
withCmd model =
    ( model, Cmd.none )


updateGamepiecePlaced : Cell -> Model -> Model
updateGamepiecePlaced { cellname, cellstate } model =
    case model.gamestatus of
        GameInProgress player selectedPiece ->
            case ( selectedPiece, cellstate ) of
                ( Selected gamepiece, EmptyCell ) ->
                    let
                        newBoard =
                            updateCellBoard cellname gamepiece model.board

                        win =
                            isWin newBoard

                        remainingPieces =
                            removeGamepieceFromRemaining gamepiece model.remainingPieces
                    in
                    case ( win, remainingPieces ) of
                        ( True, _ ) ->
                            { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = GameWon player }

                        ( _, [] ) ->
                            { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = Draw }

                        _ ->
                            { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = GameInProgress player NoPieceSelected }

                _ ->
                    model

        _ ->
            model


updateSelectingGamepiece : Gamepiece -> Model -> Model
updateSelectingGamepiece gamepiece model =
    case model.gamestatus of
        GameInProgress player _ ->
            let
                newActiveplayer =
                    updateActiveplayer player

                newPieceSelected =
                    Selected gamepiece
            in
            { model | gamestatus = GameInProgress newActiveplayer newPieceSelected }

        _ ->
            model


updateActiveplayer : Player -> Player
updateActiveplayer player =
    case player of
        Player1 ->
            Player2

        Player2 ->
            Player1


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
            [ el [ Font.center, width fill ] (text "Remaining Pieces")
            , column [ centerX ] <|
                List.map (row [ centerX ]) <|
                    Liste.greedyGroupsOf 4 <|
                        List.map viewRemainingPiecesButton model.remainingPieces
            , el [ Font.center, width fill ] (text "Game Status")
            , viewGamestatus model.gamestatus
            , el [ Font.center, width fill ] (text "GameBoard")
            , viewBoard model.board
            ]
        ]
    }


viewGamestatus : Gamestatus -> Element Msg
viewGamestatus gamestatus =
    case gamestatus of
        GameWon winner ->
            row []
                [ viewSvgbox [ Svg.text <| "Winner: " ++ playerToString winner ]
                , viewRestartButton
                ]

        Draw ->
            row []
                [ viewSvgbox [ Svg.text "It's a Draw" ]
                , viewRestartButton
                ]

        GameInProgress activeplayer selectedGamepiece ->
            case selectedGamepiece of
                Selected gamepiece ->
                    row []
                        [ text "Piece Selected: "
                        , viewGamepiece gamepiece
                        , text <| "Active Player: " ++ playerToString activeplayer
                        ]

                NoPieceSelected ->
                    row []
                        [ viewSvgbox
                            [ Svg.rect [ Attr.width "60", Attr.height "60", Attr.fill "none" ] [] ]
                        , text <| "Active Player: " ++ playerToString activeplayer
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
        [ Border.color Styles.blue, Border.width 5 ]
        { onPress = Just (ClickedCellOnGameBoard cell)
        , label = viewCell cell
        }


viewRestartButton : Element Msg
viewRestartButton =
    Input.button [ Background.color Styles.blue, Border.width 5, Font.color Styles.white ]
        { onPress = Just ClickedRestartGameButton, label = text "Restart" }


viewBoard : CellBoard -> Element Msg
viewBoard cellboard =
    column [ centerX ]
        [ row [] <| List.map viewCellButton [ cellboard.a1, cellboard.b1, cellboard.c1, cellboard.d1 ]
        , row [] <| List.map viewCellButton [ cellboard.a2, cellboard.b2, cellboard.c2, cellboard.d2 ]
        , row [] <| List.map viewCellButton [ cellboard.a3, cellboard.b3, cellboard.c3, cellboard.d3 ]
        , row [] <| List.map viewCellButton [ cellboard.a4, cellboard.b4, cellboard.c4, cellboard.d4 ]
        ]


viewRemainingPiecesButton : Gamepiece -> Element Msg
viewRemainingPiecesButton gamepiece =
    let
        gamePieceImage =
            viewGamepiece gamepiece
    in
    Input.button [] { onPress = Just (ClickedAvilableGampiece gamepiece), label = gamePieceImage }


viewGamepiece : Gamepiece -> Element msg
viewGamepiece gamepiece =
    gamepiece
        |> makeGamepieceSvg
        |> (\singleSvg -> viewSvgbox [ singleSvg ])



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
