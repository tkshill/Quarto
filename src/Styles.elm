module Styles exposing (black, blue, colortoCssRGBString, red, white, yellow)

import Element exposing (Color, rgb255)
import Element.Font as Font 




-- Accessible color pallette for use throughout application:
--    all text should be either black or white
--    black text should be used with red and yellow backgrounds
--    white text should be used with blue backgrounds


black : Color
black =
    rgb255 0 0 0


white : Color
white =
    rgb255 255 255 255


blue : Color
blue =
    rgb255 0 68 136


red : Color
red =
    rgb255 187 85 102


yellow : Color
yellow =
    rgb255 221 170 51


colortoCssRGBString : Color -> String
colortoCssRGBString color =
    let
        rgb =
            Element.toRgb color
    in
    "rgb("
        ++ String.fromFloat (rgb.red * 255)
        ++ ","
        ++ String.fromFloat (rgb.green * 255)
        ++ ","
        ++ String.fromFloat (rgb.blue * 255)
        ++ ")"


orbitron = Font.family [
    Font.external {
    name = "Orbitron"
    ,url = "https://fonts.googleapis.com/css?family=Orbitron"
    } 
    ,Font.sansSerif ]
