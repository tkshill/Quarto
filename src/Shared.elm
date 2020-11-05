module Shared exposing
    ( Dimensions
    , Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events
import Browser.Navigation exposing (Key)
import Element
    exposing
        ( Attribute
        , DeviceClass(..)
        , Element
        , Orientation(..)
        , alignLeft
        , alignRight
        , column
        , fill
        , height
        , link
        , newTabLink
        , padding
        , paragraph
        , row
        , spacing
        , text
        , width
        )
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


type alias Dimensions =
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
    , dimensions : Dimensions
    }



-- UPDATE


type Msg
    = WindowResized Int Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowResized width height ->
            { model | dimensions = Dimensions width height }
                |> noCmds


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize WindowResized



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page } model =
    { title = page.title
    , body =
        [ column (style model.dimensions)
            [ header
            , body page.body
            , footer
            ]
        ]
    }


header : Element msg
header =
    row [ width fill, spacing 20, padding 20, Background.color Styles.blue, Region.navigation ]
        [ link [ Font.color Styles.white, alignLeft ] { url = Route.toString Route.Top, label = text "Home" }
        , link [ Font.color Styles.white, alignRight ] { url = Route.toString Route.About, label = text "About" }
        ]


body : List (Element msg) -> Element msg
body listy =
    column [ width fill, height fill, Region.mainContent ] listy



-- remember to change github link to image


footer : Element msg
footer =
    row [ width fill, spacing 20, padding 20, Font.color Styles.white, Background.color Styles.black ]
        [ paragraph [ Font.center ]
            [ text "Check out our "
            , newTabLink [ Font.color Styles.red ] { url = "https://github.com/tkshill/Quarto", label = text "Repository" }
            ]
        ]


style : Dimensions -> List (Attribute msg)
style dimensions =
    let
        device =
            Element.classifyDevice dimensions
    in
    case device.class of
        Phone ->
            [ height fill, width fill, Font.size 18 ]

        _ ->
            [ height fill, width fill, Font.size 20 ]
