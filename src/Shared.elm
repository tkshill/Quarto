module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events
import Browser.Navigation exposing (Key)
import Element exposing (Element, centerX, column, fill, height, link, newTabLink, padding, row, spacing, text, width)
import Element.Background as Background
import Element.Font as Font
import Element.Region as Region
import Helpers exposing (noCmds)
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Styles
import Url exposing (Url)



-- INIT


type alias Flags =
    { width : Int
    , height : Int
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    Model url key flags
        |> noCmds



-- MODEL


type alias Model =
    { url : Url
    , key : Key
    , dimensions : Flags
    }



-- UPDATE


type Msg
    = WindowResized Int Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowResized width height ->
            { model | dimensions = Flags width height }
                |> noCmds


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize WindowResized



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page } _ =
    { title = page.title
    , body =
        [ column [ spacing 20, height fill, width fill, Region.mainContent ]
            [ header
            , body page.body
            , footer
            ]
        ]
    }


header : Element msg
header =
    row [ width fill, spacing 20, padding 20, Background.color Styles.blue, Region.navigation ]
        [--link [ Font.color Styles.white ] { url = Route.toString Route.Top, label = text "Home" }
        ]


body : List (Element msg) -> Element msg
body listy =
    column [ height fill, centerX ] listy



-- remember to change github link to image


footer : Element msg
footer =
    row [ width fill, spacing 20, padding 20, Background.color Styles.black ]
        [ newTabLink [ Font.color Styles.white, centerX ] { url = "https://github.com/tkshill/Quarto", label = text "Checkout the GitHub Repository!" } ]
