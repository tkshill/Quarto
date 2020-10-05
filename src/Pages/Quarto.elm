module Pages.Quarto exposing
    ( Colour(..)
    , Gamepiece
    , Model
    , Msg
    , Params
    , Pattern(..)
    , Shape(..)
    , Size(..)
    , matchingDimensions
    , page
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
import Spa.Url as Url exposing (Url)
import Styles
import Svg exposing (Svg, svg)
import Svg.Attributes as Attr



{-
   module Pages.Quarto exposing (Model, Msg, Params, page)

   import Spa.Document exposing (Document)
   import Spa.Page as Page exposing (Page)
   import Spa.Url as Url exposing (Url)

-}


page : Page Params Model Msg
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- DOMAIN
-- Gamepiece Dimensions


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



-- Gamepiece


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



-- BOARD CELLS
-- Cell Names


type Cellname
    = A1
    | A2
    | A3
    | A4
    | B1
    | B2
    | B3
    | B4
    | C1
    | C2
    | C3
    | C4
    | D1
    | D2
    | D3
    | D4


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


type alias CellStatus =
    Maybe Gamepiece


type alias Cell =
    ( Cellname, CellStatus )


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


playerToString : Player -> String
playerToString player =
    case player of
        Player1 ->
            "Player1"

        Player2 ->
            "Player2"


type alias Activeplayer =
    Player


type alias SelectedPiece =
    Maybe Gamepiece


type Gamestatus
    = ActiveGame Activeplayer SelectedPiece
    | GameOver EndStatus


type EndStatus
    = GameWon Player
    | Draw


type alias Model =
    { board : CellBoard
    , remainingPieces : List Gamepiece
    , gamestatus : Gamestatus
    }



-- INIT


initialCells : CellBoard
initialCells =
    let
        nameToCell name =
            ( name, Nothing )
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


type alias Params =
    ()


init : Url Params -> Model
init { params } =
    { board = initialCells
    , remainingPieces = initialPieces
    , gamestatus = ActiveGame Player1 Nothing
    }



-- UPDATE
-- Messages


type Msg
    = Clicked Gamepiece
    | PlaceAttempt Cell
    | RestartGame


update : Msg -> Model -> Model
update msg model =
    case msg of
        Clicked gamepiece ->
            updateSelectingGamepiece gamepiece model

        PlaceAttempt cell ->
            updateGamepiecePlaced cell model

        RestartGame ->
            { board = initialCells, remainingPieces = initialPieces, gamestatus = ActiveGame Player1 Nothing }



-- Update Helpers


updateGamepiecePlaced : Cell -> Model -> Model
updateGamepiecePlaced ( cellname, cellstatus ) model =
    case model.gamestatus of
        GameOver _ ->
            model

        ActiveGame player selectedPiece ->
            case ( selectedPiece, cellstatus ) of
                ( Nothing, _ ) ->
                    model

                ( _, Just _ ) ->
                    model

                ( Just gamepiece, Nothing ) ->
                    let
                        newBoard =
                            updateCellBoard cellname gamepiece model.board

                        win =
                            isWin newBoard

                        remainingPieces =
                            updatePiecesRemaining gamepiece model.remainingPieces
                    in
                    case ( win, remainingPieces ) of
                        ( True, _ ) ->
                            { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = GameOver (GameWon player) }

                        ( _, [] ) ->
                            { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = GameOver Draw }

                        _ ->
                            { model | board = newBoard, remainingPieces = remainingPieces, gamestatus = ActiveGame player Nothing }


updateSelectingGamepiece : Gamepiece -> Model -> Model
updateSelectingGamepiece gamepiece model =
    case model.gamestatus of
        GameOver _ ->
            model

        ActiveGame player _ ->
            let
                newActiveplayer =
                    updateActiveplayer player

                newPieceSelected =
                    Just gamepiece
            in
            { model | gamestatus = ActiveGame newActiveplayer newPieceSelected }


updateActiveplayer : Player -> Player
updateActiveplayer player =
    case player of
        Player1 ->
            Player2

        Player2 ->
            Player1


updateCellBoard : Cellname -> Gamepiece -> CellBoard -> CellBoard
updateCellBoard name piece board =
    case name of
        A1 ->
            { board | a1 = ( name, Just piece ) }

        A2 ->
            { board | a2 = ( name, Just piece ) }

        A3 ->
            { board | a3 = ( name, Just piece ) }

        A4 ->
            { board | a4 = ( name, Just piece ) }

        B1 ->
            { board | b1 = ( name, Just piece ) }

        B2 ->
            { board | b2 = ( name, Just piece ) }

        B3 ->
            { board | b3 = ( name, Just piece ) }

        B4 ->
            { board | b4 = ( name, Just piece ) }

        C1 ->
            { board | c1 = ( name, Just piece ) }

        C2 ->
            { board | c2 = ( name, Just piece ) }

        C3 ->
            { board | c3 = ( name, Just piece ) }

        C4 ->
            { board | c4 = ( name, Just piece ) }

        D1 ->
            { board | d1 = ( name, Just piece ) }

        D2 ->
            { board | d2 = ( name, Just piece ) }

        D3 ->
            { board | d3 = ( name, Just piece ) }

        D4 ->
            { board | d4 = ( name, Just piece ) }


updatePiecesRemaining : Gamepiece -> List Gamepiece -> List Gamepiece
updatePiecesRemaining piece remainingPieces =
    List.filter ((/=) piece) remainingPieces


boardToWinnableCells : CellBoard -> List (List Cell)
boardToWinnableCells board =
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
        |> List.filter (\cells -> List.all (\( _, status ) -> status /= Nothing) cells)


matchingDimensions : List Gamepiece -> Bool
matchingDimensions gamepieces =
    gamepieces
        -- convert from list of game pieces to sets of strings
        |> List.map (gamepieceToList >> Set.fromList)
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
        |> List.map (List.map (\( _, cellstatus ) -> cellstatus))
        -- convert cells to gamepieces and filter out cells that dont have gamepieces in them
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
        GameOver endstatus ->
            case endstatus of
                GameWon player ->
                    row []
                        [ viewSvgbox [ Svg.text <| "Winner: " ++ playerToString player ]
                        , viewRestartButton
                        ]

                Draw ->
                    row []
                        [ viewSvgbox [ Svg.text "It's a Draw" ]
                        , viewRestartButton
                        ]

        ActiveGame player selectedGamepiece ->
            case selectedGamepiece of
                Just gamepiece ->
                    row []
                        [ text "Piece Selected: "
                        , viewGamepiece gamepiece
                        , text <| "Active Player: " ++ playerToString player
                        ]

                Nothing ->
                    row []
                        [ viewSvgbox
                            [ Svg.rect [ Attr.width "60", Attr.height "60", Attr.fill "none" ] [] ]
                        , text <| "Active Player: " ++ playerToString player
                        ]


viewCell : Cell -> Element Msg
viewCell ( name, status ) =
    case status of
        Just gamepiece ->
            viewGamepiece gamepiece

        Nothing ->
            viewSvgbox [ Svg.text <| cellnameToString name ]


viewCellButton : Cell -> Element Msg
viewCellButton cell =
    Input.button
        [ Border.color Styles.blue, Border.width 5 ]
        { onPress = Just (PlaceAttempt cell)
        , label = viewCell cell
        }


viewRestartButton : Element Msg
viewRestartButton =
    Input.button [ Background.color Styles.blue, Border.width 5, Font.color Styles.white ]
        { onPress = Just RestartGame, label = text "Restart" }


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
        svgImage =
            viewGamepiece gamepiece
    in
    Input.button [] { onPress = Just (Clicked gamepiece), label = svgImage }


viewGamepiece : Gamepiece -> Element msg
viewGamepiece gamepiece =
    gamepiece
        |> makeGamepieceSvg
        |> (\singleSvg -> viewSvgbox [ singleSvg ])


viewSvgbox : List (Svg msg) -> Element msg
viewSvgbox objects =
    Element.html <|
        svg [ Attr.width "60", Attr.height "60", Attr.viewBox "0 0 60 60" ] objects



-- Svg gamepiece helper funxtions


shapeAndSizefunc :
    Shape
    -> Size
    ->
        ( List (Svg.Attribute msg)
          -> List (Svg msg)
          -> Svg msg
        , List (Svg.Attribute msg)
        )
shapeAndSizefunc shape size =
    case ( shape, size ) of
        ( Circle, Small ) ->
            ( Svg.circle, [ Attr.r "15", Attr.cx "30", Attr.cy "30" ] )

        ( Circle, Large ) ->
            ( Svg.circle, [ Attr.r "25", Attr.cx "30", Attr.cy "30" ] )

        ( Square, Small ) ->
            ( Svg.rect, [ Attr.x "15", Attr.y "15", Attr.width "30", Attr.height "30" ] )

        ( Square, Large ) ->
            ( Svg.rect, [ Attr.x "5", Attr.y "5", Attr.width "50", Attr.height "50" ] )


colourfunc : Colour -> List (Svg.Attribute msg)
colourfunc colour =
    case colour of
        Colour1 ->
            [ Styles.colortoCssRGBString Styles.red
                |> Attr.color
            ]

        Colour2 ->
            [ Styles.colortoCssRGBString Styles.yellow
                |> Attr.color
            ]


patternfunc : Pattern -> List (Svg.Attribute msg)
patternfunc pattern =
    case pattern of
        Solid ->
            [ Attr.fill "currentcolor" ]

        Hollow ->
            [ Attr.fill "none", Attr.strokeWidth "5", Attr.stroke "currentcolor" ]


makeGamepieceSvg : Gamepiece -> Svg msg
makeGamepieceSvg { shape, colour, pattern, size } =
    let
        ( shapefunc, sizeAttributes ) =
            shapeAndSizefunc shape size

        colourAttributes =
            colourfunc colour

        patternAttributes =
            patternfunc pattern
    in
    shapefunc (List.concat [ patternAttributes, colourAttributes, sizeAttributes ]) []
