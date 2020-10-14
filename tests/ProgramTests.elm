module ProgramTests exposing (start)

import Pages.GamePage as Gamepage exposing (Gamepiece)
import ProgramTest exposing (ProgramTest)
import Spa.Document as Document


simulateEffects : Gamepiece.Effect -> ProgramTest.SimulatedEffect Main.Msg
simulateEffects effects =
    case effect of
        Main.NoEffect ->
            Cmd.none


start : ProgramTest Gamepage.Model Gamepage.Msg (Cmd Gamepage.Msg)
start =
    ProgramTest.createDocument
        { init = \_ -> Gamepage.initModel |> Gamepage.withNoEffects
        , update = Gamepage.update
        , view = Gamepage.view >> Document.toBrowserDocument
        }
        |> ProgramTest.withSimulatedEffects simulateEffects
        |> ProgramTest.start ()
