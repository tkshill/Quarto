module Pages.Top exposing (Model, Msg, Params, page)

import Element exposing (..)
import Element.Font as Font
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import Styles


type alias Params =
    ()


type alias Model =
    Url Params


type alias Msg =
    Never


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }



-- VIEW


view : Url Params -> Document Msg
view { params } =
    { title = "Homepage"
    , body = [el [centerX, centerY, padding 25] <|
     Element.column [Font.center, centerX, padding 50]
     [el [centerX, centerY, Font.size 72] (text "Welcome to Quarto")
     , text "Quarto is a board game for two players invented by Swiss mathematician Blaise Müller. It is published and copyrighted by Gigamic."
     , text "The game is played on a 4×4 board. There are 16 unique pieces to play with, each of which is either:"
     , text "tall or short;"
     , text "red or blue (or a different pair of colors, e.g. light- or dark-stained wood);"
     , text "square or circular; and"
     , text "hollow-top or solid-top."
     , text "Players take turns choosing a piece which the other player must then place on the board."
     , text "A player wins by placing a piece on the board which forms a horizontal, vertical, or diagonal row of four pieces, all of which have a common attribute (all short, all circular, etc.)."
     , text "A variant rule included in many editions gives a second way to win by placing four matching pieces in a 2×2 square."
     ]]
    }
