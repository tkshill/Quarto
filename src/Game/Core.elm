module Game.Core exposing
    ( Cellname(..)
    , Colour(..)
    , Gamepiece
    , Pattern(..)
    , Shape(..)
    , Size(..)
    )


type Shape
    = Square
    | Circle


type Colour
    = Colour1
    | Colour2


type Pattern
    = Solid
    | Hollow


type Size
    = Small
    | Large


type Cellname
    = A1
    | B1
    | C1
    | D1
    | A2
    | B2
    | C2
    | D2
    | A3
    | B3
    | C3
    | D3
    | A4
    | B4
    | C4
    | D4


type alias Gamepiece =
    { shape : Shape
    , colour : Colour
    , pattern : Pattern
    , size : Size
    }
