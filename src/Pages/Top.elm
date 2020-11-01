module Pages.Top exposing
    ( Effect(..)
    , Model
    , Msg
    , Params
    , initModel
    , page
    , update
    , view
    , withNoEffects
    )

import Dict
import Element exposing (Element, centerX, column, el, fill, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Game.Board as Board
    exposing
        ( BoardState
        , Cellname(..)
        , Colour(..)
        , Gamepiece
        , Pattern(..)
        , PlayedPieces
        , Shape(..)
        , Size(..)
        )
import List.Extra as Liste
import Pages.NotFound exposing (Msg)
import Process
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


type alias SelectedPiece =
    Gamepiece


type Cellstatus
    = EmptyCell
    | Occupied Gamepiece


type alias Cell =
    { name : Cellname
    , state : Cellstatus
    }


toCell : Cellname -> PlayedPieces -> Cell
toCell name pieces =
    case Dict.get (Board.nameToString name) pieces of
        Just gamepiece ->
            Cell name (Occupied gamepiece)

        Nothing ->
            Cell name EmptyCell


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
    { board : BoardState
    , status : Gamestatus
    }


gamepieceToString : Gamepiece -> String
gamepieceToString gamepiece =
    gamepiece
        |> Board.gamepieceToList
        |> List.intersperse " "
        |> String.concat



-- Cell Name Helpers
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


initModel : Model
initModel =
    { board = Board.initialBoard
    , status = InPlay initialTurn
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
    case ( msg, model.status ) of
        ( ClickedPiece gamepiece, InPlay HumanChoosing ) ->
            { model | status = InPlay (ComputerPlaying gamepiece) }
                |> withEffect (Delay 2 HumanChosePiece)

        ( HumanChosePiece, InPlay (ComputerPlaying gamepiece) ) ->
            tryFindAvailableCells model.board
                |> Maybe.map (updateGamepiecePlaced gamepiece model)
                |> Maybe.map (checkForWin (ComputerPlaying gamepiece))
                |> Maybe.withDefault (withNoEffects model)

        ( ComputerPlayedPiece, InPlay ComputerChoosing ) ->
            model.board
                |> Board.unPlayedPieces
                |> trySelectpiece
                |> Maybe.map (\piece -> { model | status = InPlay (HumanPlaying piece) })
                |> Maybe.withDefault { model | status = Draw }
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


tryFindAvailableCells : BoardState -> Maybe Cellname
tryFindAvailableCells board =
    board
        |> Board.availableCells
        |> List.head


trySelectpiece : List Gamepiece -> Maybe Gamepiece
trySelectpiece gamepiece =
    List.head gamepiece


updateGamepiecePlaced : Gamepiece -> Model -> Cellname -> Model
updateGamepiecePlaced gamepiece model name =
    Board.updateBoard name gamepiece model.board
        |> (\newBoard -> { model | board = newBoard })


checkForWin : Turn -> Model -> ( Model, Effect )
checkForWin turn model =
    case ( turn, Board.isWin model.board ) of
        ( _, True ) ->
            { model | status = Won (turnToActivePlayer turn) }
                |> withNoEffects

        ( HumanPlaying _, False ) ->
            { model | status = InPlay HumanChoosing }
                |> withNoEffects

        ( ComputerPlaying _, False ) ->
            { model | status = InPlay ComputerChoosing }
                |> withEffect (Delay 2 ComputerPlayedPiece)

        _ ->
            model |> withNoEffects



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
            [ viewRemainingPieces (Board.unPlayedPieces model.board)
            , viewGamestatus model.status
            , viewBoard (Board.playedPieces model.board)
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
            viewSvgbox [ Svg.text <| Board.nameToString name ]


viewCellButton : PlayedPieces -> Cellname -> Element Msg
viewCellButton pieces name =
    Input.button
        [ Border.color Styles.blue, Border.width 5, Region.description (cellStateToDescription (toCell name pieces)) ]
        { onPress = Just (ClickedGameboard (toCell name pieces))
        , label = viewCell (toCell name pieces)
        }


viewRestartButton : Element Msg
viewRestartButton =
    Input.button [ Background.color Styles.blue, Border.width 5, Font.color Styles.white ]
        { onPress = Just ClickedRestart, label = text "Restart" }


viewBoard : PlayedPieces -> Element Msg
viewBoard pieces =
    column [ centerX, Region.announce ]
        [ el [ Font.center, width fill ] (text "GameBoard")
        , row [] <| List.map (viewCellButton pieces) [ A1, B1, C1, D1 ]
        , row [] <| List.map (viewCellButton pieces) [ A2, B2, C2, D2 ]
        , row [] <| List.map (viewCellButton pieces) [ A3, B3, C3, D3 ]
        , row [] <| List.map (viewCellButton pieces) [ A4, B4, C4, D4 ]
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
            "Cell " ++ Board.nameToString name ++ ": Empty cell"

        Occupied gamepiece ->
            "Cell " ++ Board.nameToString name ++ ": " ++ gamepieceToString gamepiece



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
