module Pages.About exposing (Model, Msg, Params, page)

import Element
    exposing
        ( Attribute
        , DeviceClass(..)
        , centerX
        , column
        , el
        , fill
        , height
        , padding
        , paragraph
        , px
        , spacing
        , text
        , width
        )
import Element.Font as Font
import Element.Region as Region
import Helpers exposing (noCmds)
import Shared exposing (Dimensions)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import Styles


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }



-- INIT


type alias Params =
    ()


type alias Model =
    Shared.Dimensions


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared _ =
    ( shared.dimensions, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model |> noCmds


save : Model -> Shared.Model -> Shared.Model
save _ shared =
    shared


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared _ =
    ( shared.dimensions, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "About"
    , body =
        [ column (style model)
            [ el [ Region.heading 1, centerX, Font.bold ] (text "What is this project?")
            , paragraph [ width fill, height fill, spacing 5, Font.color Styles.blue ]
                [ text "This is an example project of the game Quarto, built using the Elm programming language." ]
            , el [ Region.heading 1, centerX, Font.bold ] (text "What is Quarto")
            , paragraph [ width fill, height fill, spacing 5, Font.color Styles.blue ]
                [ text "Quarto is a board game for two players invented by Swiss mathematician Blaise Müller. It is published and copyrighted by Gigamic. "
                , text "The game is played on a 4×4 board. "
                , text "There are 16 unique pieces to play with, each of which is either; "
                , text "tall or short; "
                , text "red or blue (or a different pair of colors, e.g. light- or dark-stained wood); "
                , text "square or circular; "
                , text "and hollow-top or solid-top. "
                ]
            , el [ Region.heading 1, centerX, Font.bold ] (text "How to Play")
            , paragraph [ width fill, spacing 5, height fill, Font.color Styles.blue ]
                [ text "Players take turns choosing a piece which the other player must then place on the board."
                , text "A player wins by placing a piece on the board which forms a horizontal, vertical, or diagonal row of four pieces, all of which have a common attribute (all short, all circular, etc.)."
                ]
            ]
        ]
    }


style : Dimensions -> List (Attribute msg)
style dimensions =
    let
        device =
            Element.classifyDevice dimensions
    in
    case device.class of
        Phone ->
            [ Font.center, Font.justify, width fill, height fill, padding 15, spacing 15 ]

        _ ->
            [ Font.center, Font.justify, width (px 580), height fill, centerX, padding 20, spacing 20 ]
