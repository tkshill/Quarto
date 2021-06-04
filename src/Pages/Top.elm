module Pages.Top exposing
    ( Model
    , Msg
    , Params
    , page
    , update
    , view
    )

import Element
    exposing
        ( Attribute
        , Element
        , centerX
        , column
        , el
        , fill
        , padding
        , paragraph
        , row
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Game
    exposing
        ( Cell
        , Cellname(..)
        , Colour(..)
        , GameStatus(..)
        , Gamepiece
        , Msg(..)
        , Pattern(..)
        , Player(..)
        , Shape(..)
        , Size(..)
        , StatusMessage(..)
        , Turn(..)
        )
import Helpers exposing (lift)
import List.Extra as Liste
import Pages.NotFound exposing (Msg)
import Shared exposing (Dimensions)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url
import Styles
import Svg exposing (Svg, svg)
import Svg.Attributes as Attr


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , save = save
        , load = load
        }


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    lift { model | dimensions = shared.dimensions }


save : Model -> Shared.Model -> Shared.Model
save _ shared =
    shared



--


type alias Model =
    { game : Game.Model
    , dimensions : Shared.Flags
    }



-- INIT


type alias Params =
    ()


init : Shared.Model -> Url.Url Params -> ( Model, Cmd Msg )
init shared _ =
    lift { game = Game.init, dimensions = shared.dimensions }



-- UPDATE


type Msg
    = GameMessage Game.Msg


gameUpdateToUpdate : Model -> ( Game.Model, Cmd Game.Msg ) -> ( Model, Cmd Msg )
gameUpdateToUpdate model ( gmodel, gcmds ) =
    ( { model | game = gmodel }
    , Cmd.map GameMessage gcmds
    )



-- gameMsgToMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GameMessage msg_ ->
            Game.update msg_ model.game
                |> gameUpdateToUpdate model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Quarto - Play"
    , body =
        [ column [ padding 20, spacing 20, centerX ]
            [ rowOrCol model.dimensions
                [ centerX ]
                [ viewBoard (Game.gameboard model.game)
                , viewRemainingPieces (Game.remainingPieces model.game)
                ]
            , viewGamestatus (Game.currentStatus model.game) model.dimensions
            , viewStatusMessage (Game.currentStatusMessage model.game)
            ]
        ]
    }


viewRemainingPieces : List Gamepiece -> Element Msg
viewRemainingPieces remainingPieces =
    column [ padding 10, centerX ]
        [ column [] <|
            List.map (row []) <|
                Liste.greedyGroupsOf 4 <|
                    List.map viewRemainingPiecesButton remainingPieces
        ]


viewBoard : (Cellname -> Cell) -> Element Msg
viewBoard cellDict =
    column [ Region.announce, centerX ]
        [ row [] <| List.map (viewCellButton << cellDict) [ A1, B1, C1, D1 ]
        , row [] <| List.map (viewCellButton << cellDict) [ A2, B2, C2, D2 ]
        , row [] <| List.map (viewCellButton << cellDict) [ A3, B3, C3, D3 ]
        , row [] <| List.map (viewCellButton << cellDict) [ A4, B4, C4, D4 ]
        ]


viewGamestatus : GameStatus -> Dimensions -> Element Msg
viewGamestatus gamestatus _ =
    let
        containerize : List (Element Msg) -> Element Msg
        containerize elements =
            el [ Font.center, centerX ] (column [ width fill, spacing 5, Font.center, centerX ] elements)
    in
    case gamestatus of
        Won winner ->
            containerize [ text <| "The Winner is : " ++ Game.playerToString winner, viewRestartButton ]

        Draw ->
            containerize [ text "It's a Draw!", viewRestartButton ]

        InPlay player (ChoosingCellToPlay gamepiece) ->
            let
                script =
                    case player of
                        Human ->
                            paragraph [] [ text "Click an empty cell to play the piece the computer chose for you. " ]

                        Computer ->
                            paragraph [] [ text "Computer is thinking of where to play selected gamepiece. " ]
            in
            containerize
                [ script
                , row [ centerX, Font.center ] [ text "Selected gamepiece: ", viewGamepiece gamepiece ]
                ]

        InPlay player ChoosingPiece ->
            let
                script =
                    case player of
                        Human ->
                            text "Choose a piece for the computer to play."

                        Computer ->
                            text "Computer is choosing a piece for you to play."
            in
            containerize
                [ script ]


viewStatusMessage : StatusMessage -> Element Msg
viewStatusMessage statusMessage =
    case statusMessage of
        NoMessage ->
            Element.el [] (Element.text "")

        SomePiecePlayedWhenNotPlayersTurn ->
            Element.el [ centerX, Font.center, Region.announce ] (Element.text "It's not your turn to choose a piece!")


viewCell : Cell -> Element Msg
viewCell { name, status } =
    case status of
        Just gamepiece ->
            viewGamepiece gamepiece

        Nothing ->
            viewSvgbox [ Svg.text <| Game.nameToString name ]


viewCellButton : Cell -> Element Msg
viewCellButton cell =
    Input.button
        [ Border.color Styles.blue, Border.width 5, Region.description (cellStateToDescription cell) ]
        { onPress = Just (GameMessage (HumanSelectedCell cell.name))
        , label = viewCell cell
        }


viewRestartButton : Element Msg
viewRestartButton =
    Input.button [ Background.color Styles.white, Border.width 5, Border.color Styles.blue, padding 5, centerX, Font.color Styles.blue ]
        { onPress = Just (GameMessage RestartWanted), label = text "Restart" }


viewRemainingPiecesButton : Gamepiece -> Element Msg
viewRemainingPiecesButton gamepiece =
    let
        gamePieceImage =
            viewGamepiece gamepiece

        ariaDescription =
            Game.pieceToString gamepiece
    in
    Input.button [ Region.description ariaDescription ]
        { onPress = Just (GameMessage (HumanSelectedPiece gamepiece))
        , label = gamePieceImage
        }


viewGamepiece : Gamepiece -> Element msg
viewGamepiece gamepiece =
    gamepiece
        |> makeGamepieceSvg
        |> (\singleSvg -> viewSvgbox [ singleSvg ])



-- Description helper functions


cellStateToDescription : Cell -> String
cellStateToDescription { name, status } =
    case status of
        Nothing ->
            "Cell " ++ Game.nameToString name ++ ": Empty cell"

        Just gamepiece ->
            "Cell " ++ Game.nameToString name ++ ": " ++ Game.pieceToString gamepiece



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


rowOrCol : Dimensions -> (List (Attribute msg) -> List (Element msg) -> Element msg)
rowOrCol dims =
    if dims.width < 800 then
        column

    else
        row
