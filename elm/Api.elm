module Api exposing (..)

import WebSocket exposing (..)
import HttpBuilder exposing (..)
import Json.Decode as JD exposing (string, int)
import Json.Decode.Pipeline as JD exposing (decode, required, optional, hardcoded)
import Time
import Http
import Html
import Types exposing (..)
import RemoteData exposing (..)


chatSocketUrl : String
chatSocketUrl =
    "ws://localhost:5000/chat"


sensorSocketUrl : SensorId -> String
sensorSocketUrl sId =
    "ws://localhost:5000/sensor/" ++ sId


sensorDecoder : JD.Decoder Sensor
sensorDecoder =
    decode Sensor
        |> required "id" string
        |> required "kind" (JD.at [ "name" ] string)
        |> required "reportingMode" (JD.at [ "frequency" ] int)
        |> hardcoded False
        |> hardcoded []
        |> hardcoded 50


fetchSensors : Cmd Msg
fetchSensors =
    HttpBuilder.get "/sensors"
        |> withTimeout (3 * Time.second)
        |> withExpect (Http.expectJson <| JD.list sensorDecoder)
        |> withCredentials
        |> HttpBuilder.send GotSensors



-- subscribe : SensorId -> Cmd Msg
-- subscribe sId =
--     WebSocket.send sensorSocketUrl ("subscribe" sId)
--
--
-- unsubscribe : SensorId -> Cmd Msg
-- unsubscribe sId =
--     WebSocket.send sensorSocketUrl ("unsubscribe:" ++ sId)


sendMessage : String -> Cmd Msg
sendMessage str =
    WebSocket.send chatSocketUrl str


chatSubscription : Model -> Sub Msg
chatSubscription model =
    listen chatSocketUrl Message


dispatchValue : String -> Msg
dispatchValue s =
    case String.split ":" s of
        [ a, b ] ->
            OnValue a b

        _ ->
            Message ("Error: " ++ s)


viewRemote : (a -> Html.Html Msg) -> WebData a -> Html.Html Msg
viewRemote fn webData =
    case webData of
        Success data ->
            fn data

        NotAsked ->
            Html.text "not asked"

        Loading ->
            Html.text "loading"

        Failure err ->
            Html.text <| toString err
