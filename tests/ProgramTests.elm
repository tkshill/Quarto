module ProgramTests exposing (start)

import Pages.GamePage as Gamepage
import ProgramTest exposing (ProgramTest)
import Spa.Document as Document


start : ProgramTest Gamepage.Model Gamepage.Msg (Cmd Gamepage.Msg)
start =
    ProgramTest.createDocument
        { init = \_ -> Gamepage.initModel |> Gamepage.withCmd
        , update = Gamepage.update
        , view = Gamepage.view >> Document.toBrowserDocument
        }
        |> ProgramTest.start ()
