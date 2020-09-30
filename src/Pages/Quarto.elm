module Pages.Quarto exposing (Model, Msg, Params, page)

import Element exposing (Element, rgb255)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import List.Extra as Liste
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
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


type Shape
    = Square
    | Circle


type Colour
    = Black
    | White


type Pattern
    = Solid
    | Divoted


type Size
    = Small
    | Large


shapes : List Shape
shapes =
    [ Square, Circle ]


colours : List Colour
colours =
    [ Black, White ]


patterns : List Pattern
patterns =
    [ Solid, Divoted ]


sizes : List Size
sizes =
    [ Small, Large ]


type alias GamePiece =
    { shape : Shape
    , colour : Colour
    , pattern : Pattern
    , size : Size
    }


type CellName
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


cellNameToString : CellName -> String
cellNameToString name =
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
    Maybe GamePiece


type alias Cell =
    ( CellName, CellStatus )


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


initialPieces : List GamePiece
initialPieces =
    Liste.lift4 GamePiece shapes colours patterns sizes


type alias Params =
    ()


type alias Model =
    { board : CellBoard
    , remainingPieces : List GamePiece
    , selectedPiece : Maybe GamePiece
    }


init : Url Params -> Model
init { params } =
    Model initialCells initialPieces Nothing



-- UPDATE


type Msg
    = Clicked GamePiece
    | PlaceAttempt Cell


update : Msg -> Model -> Model
update msg model =
    case msg of
        Clicked gamepiece ->
            { model | selectedPiece = Just gamepiece }

        PlaceAttempt ( cellName, cellStatus ) ->
            case model.selectedPiece of
                Nothing ->
                    model

                Just gamepiece ->
                    case cellStatus of
                        Just _ ->
                            model

                        Nothing ->
                            let
                                newBoard =
                                    updateCellBoard cellName gamepiece model.board

                                remainingPieces =
                                    updatePiecesRemaining gamepiece model.remainingPieces
                            in
                            { model | board = newBoard, remainingPieces = remainingPieces, selectedPiece = Nothing }


updateCellBoard : CellName -> GamePiece -> CellBoard -> CellBoard
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


updatePiecesRemaining : GamePiece -> List GamePiece -> List GamePiece
updatePiecesRemaining piece remainingPieces =
    List.filter ((/=) piece) remainingPieces



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Game"
    , body =
        [ Element.column [ Element.spacing 10 ]
            [ Element.el [ Font.center, Element.width Element.fill ] (Element.text "Remaining Pieces")
            , Element.column [] <|
                List.map (Element.row []) <|
                    Liste.greedyGroupsOf 4 <|
                        List.map viewRemainingPiecesButton model.remainingPieces
            , Element.el [ Font.center, Element.width Element.fill ] (Element.text "Selected Piece")
            , viewSelected model.selectedPiece
            , Element.el [ Font.center, Element.width Element.fill ] (Element.text "GameBoard")
            , viewBoard model.board
            ]
        ]
    }


viewSelected : Maybe GamePiece -> Element msg
viewSelected x =
    case x of
        Just gamepiece ->
            viewGamepiece gamepiece

        Nothing ->
            Element.html <| svg [ Attr.width "60", Attr.height "60", Attr.viewBox "0 0 60 60" ] [ Svg.rect [ Attr.width "60", Attr.height "60", Attr.fill "none" ] [] ]


viewCell : Cell -> Element Msg
viewCell ( name, status ) =
    case status of
        Just gamepiece ->
            viewGamepiece gamepiece

        Nothing ->
            Element.html <|
                svg [ Attr.width "60", Attr.height "60", Attr.viewBox "0 0 60 60", Attr.fill "brown" ] [ Svg.text <| cellNameToString name ]


viewCellButton : Cell -> Element Msg
viewCellButton cell =
    Input.button [ Border.color (rgb255 52 42 31), Border.width 5 ] { onPress = Just (PlaceAttempt cell), label = viewCell cell }


viewBoard : CellBoard -> Element Msg
viewBoard cellboard =
    Element.column []
        [ Element.row [] <| List.map viewCellButton [ cellboard.a1, cellboard.a2, cellboard.a3, cellboard.a4 ]
        , Element.row [] <| List.map viewCellButton [ cellboard.b1, cellboard.b2, cellboard.b3, cellboard.b4 ]
        , Element.row [] <| List.map viewCellButton [ cellboard.c1, cellboard.c2, cellboard.c3, cellboard.c4 ]
        , Element.row [] <| List.map viewCellButton [ cellboard.d1, cellboard.d2, cellboard.d3, cellboard.d4 ]
        ]


viewRemainingPiecesButton : GamePiece -> Element Msg
viewRemainingPiecesButton gamepiece =
    let
        svgImage =
            viewGamepiece gamepiece
    in
    Input.button [] { onPress = Just (Clicked gamepiece), label = svgImage }


viewGamepiece : GamePiece -> Element msg
viewGamepiece gamepiece =
    gamepiece
        |> makeGamePieceSvg
        |> (\gamePieceSvg -> svg [ Attr.width "60", Attr.height "60", Attr.viewBox "0 0 60 60" ] [ gamePieceSvg ])
        |> Element.html


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
        Black ->
            [ Attr.color "#CAB8CB" ]

        White ->
            [ Attr.color "#DCB69F" ]


patternfunc : Pattern -> List (Svg.Attribute msg)
patternfunc pattern =
    case pattern of
        Solid ->
            [ Attr.fill "currentcolor" ]

        Divoted ->
            [ Attr.fill "none", Attr.strokeWidth "5", Attr.stroke "currentcolor" ]


makeGamePieceSvg : GamePiece -> Svg msg
makeGamePieceSvg { shape, colour, pattern, size } =
    let
        ( shapefunc, sizeAttributes ) =
            shapeAndSizefunc shape size

        colourAttributes =
            colourfunc colour

        patternAttributes =
            patternfunc pattern
    in
    shapefunc (List.concat [ patternAttributes, colourAttributes, sizeAttributes ]) []
