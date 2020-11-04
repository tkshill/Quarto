module Helpers exposing (andThen, map, noCmds, withCmd)


withCmd : Cmd msg -> ( a, Cmd msg ) -> ( a, Cmd msg )
withCmd cmds ( model, moreCmds ) =
    ( model, Cmd.batch [ cmds, moreCmds ] )


noCmds : a -> ( a, Cmd msg )
noCmds model =
    ( model, Cmd.none )


map : (a -> a) -> ( a, Cmd msg ) -> ( a, Cmd msg )
map f ma =
    andThen (noCmds << f) ma


andThen : (a -> ( a, Cmd msg )) -> ( a, Cmd msg ) -> ( a, Cmd msg )
andThen f ( model, cmds ) =
    let
        ( newa, moreCmds ) =
            f model
    in
    ( newa, Cmd.batch [ cmds, moreCmds ] )
