module TestGameLogic exposing (suite)

import Expect
import Test exposing (Test, describe, test)

suite : Test
suite =
    describe "Dummy Default Test"
    [
        test "the empty list has 0 length" 
            <| \_ -> Expect.equal 0 
            <| List.length []
    ]
       