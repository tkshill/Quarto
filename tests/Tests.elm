module Tests exposing (suite)

import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "game win logic"
        [ test "a list of matching gampieces should return true" <| \_ -> Expect.fail "matching game pieces does not return true"
        ]
