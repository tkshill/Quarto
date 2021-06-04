module Helpers exposing (andThen, lift, map, withCmd)


withCmd : Cmd msg -> ( a, Cmd msg ) -> ( a, Cmd msg )
withCmd cmds ( model, moreCmds ) =
    ( model, Cmd.batch [ cmds, moreCmds ] )


lift : a -> ( a, Cmd msg )
lift model =
    ( model, Cmd.none )


map : (a -> b) -> ( a, Cmd msg ) -> ( b, Cmd msg )
map f ma =
    andThen (lift << f) ma


andThen : (a -> ( b, Cmd msg )) -> ( a, Cmd msg ) -> ( b, Cmd msg )
andThen f ( model, cmds ) =
    let
        ( newa, moreCmds ) =
            f model
    in
    ( newa, Cmd.batch [ cmds, moreCmds ] )
