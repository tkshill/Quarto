module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Navigation exposing (Key)
import Element exposing (centerX, column, fill, height, link, padding, row, spacing, text, width)
import Element.Background as Background
import Element.Font as Font
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Styles
import Url exposing (Url)



-- INIT


type alias Flags =
    ()


type alias Model =
    { url : Url
    , key : Key
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model url key
    , Cmd.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page, toMsg } _ =
    { title = page.title
    , body =
        [ column [ spacing 20, height fill, width fill ]
            [ row [ width fill, spacing 20, padding 20, Background.color Styles.blue ]
                [ link [ Font.color Styles.white ] { url = Route.toString Route.Top, label = text "Homepage" }
                , link [ Font.color Styles.white ] { url = Route.toString Route.Quarto, label = text "Game" }
                ]
            , column [ height fill, centerX ] page.body
            ]
        ]
    }
