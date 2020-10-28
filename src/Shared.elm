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
import Element exposing (Element, centerX, column, fill, height, link, newTabLink, padding, row, spacing, text, width)
import Element.Background as Background
import Element.Font as Font
import Html exposing (b)
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
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page } _ =
    { title = page.title
    , body =
        [ column [ spacing 20, height fill, width fill ]
            [ header
            , body page.body
            , footer
            ]
        ]
    }


header : Element msg
header =
    row [ width fill, spacing 20, padding 20, Background.color Styles.blue ]
        [ link [ Font.color Styles.white ] { url = Route.toString Route.Top, label = text "Home" }
        , link [ Font.color Styles.white ] { url = Route.toString Route.GamePage, label = text "Play!" }
        ]


body : List (Element msg) -> Element msg
body listy =
    column [ height fill, centerX ] listy



-- remember to change github link to image


footer : Element msg
footer =
    row [ width fill, spacing 20, padding 20, Background.color Styles.black ]
        [ newTabLink [ Font.color Styles.white, centerX ] { url = "https://github.com/tkshill/Quarto", label = text "Checkout the GitHub Repository!" } ]
