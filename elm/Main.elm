module Main exposing (..)

import Html exposing (Html, div, text, input, button)
import Html.Attributes as HA
import Html.Events as HE
import WebSocket exposing (..)
import RemoteData exposing (..)
import Api
import Sensor exposing (viewSensors)
import Types exposing (..)
import Dict exposing (Dict)


main : Program Never Model Msg
main =
    Html.program { init = init, update = update, view = view, subscriptions = subscriptions }


init : ( Model, Cmd Msg )
init =
    { message = ""
    , history = []
    , historySize = 50
    , sensors = Loading
    }
        ! [ Api.fetchSensors ]


view : Model -> Html.Html Msg
view model =
    div []
        [ input
            [ HA.type_ "text"
            , HE.onInput ChangeMessage
            , HA.value model.message
            ]
            []
        , button
            [ HE.onClick SendMessage
            , HA.disabled (String.length model.message == 0)
            ]
            [ text "Send" ]
        , button [ HE.onClick ToggleAll ] [ text "All" ]
        , Api.viewRemote (viewSensors model) model.sensors
        , div [] <| List.map (\s -> div [] [ text s ]) model.history
        ]


getSensor : SensorId -> WebData Sensors -> Maybe Sensor
getSensor id remoteSensors =
    case remoteSensors of
        Success sensors ->
            Dict.get id sensors

        _ ->
            Nothing



--List.take 20 <| i :: model.vals
--RemoteData.map (updateSensors sId) model.sensors


floatValueHandler : SensorId -> String -> Model -> Model
floatValueHandler sId str model =
    case String.toFloat str of
        Ok i ->
            { model | sensors = updateSensors sId (addValue i) model.sensors }

        Err _ ->
            { model | history = ("could not convert " ++ str ++ " to float") :: model.history }


simpleHandler : String -> Model -> Model
simpleHandler str model =
    { model | history = List.take model.historySize <| str :: model.history }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnValue sId str ->
            floatValueHandler sId str model ! []

        Message str ->
            simpleHandler str model ! []

        ChangeMessage str ->
            { model | message = str } ! []

        SendMessage ->
            { model | message = "" } ! [ Api.sendMessage model.message ]

        GotSensors res ->
            case res of
                Ok sensors ->
                    { model | sensors = Success <| Dict.fromList <| List.map (\s -> ( s.id, s )) sensors } ! []

                Err err ->
                    { model | sensors = Failure err } ! []

        ToggleSensor id ->
            case Dict.get id <| getSensors model of
                Nothing ->
                    model ! []

                Just s ->
                    { model | sensors = updateSensors id toggleSensor model.sensors }
                        ! []

        ToggleAll ->
            let
                updated =
                    Dict.map (\k v -> { v | on = not (v.on) }) <| getSensors model
            in
                { model | sensors = Success updated } ! []


getSensors : Model -> Dict SensorId Sensor
getSensors model =
    case model.sensors of
        Success sensors ->
            sensors

        _ ->
            Dict.empty


updateSensors : SensorId -> (SensorId -> SensorId -> Sensor -> Sensor) -> WebData Sensors -> WebData Sensors
updateSensors id fn webData =
    RemoteData.map (Dict.map (fn id)) webData


toggleSensor : SensorId -> SensorId -> Sensor -> Sensor
toggleSensor id key s =
    if key == id then
        { s | on = not (s.on) }
    else
        s


addValue : Float -> SensorId -> SensorId -> Sensor -> Sensor
addValue val id key s =
    if key == id then
        { s | vals = List.take s.historySize <| val :: s.vals }
    else
        s


sensorSubscription : SensorId -> Sensor -> Sub Msg
sensorSubscription sId sensor =
    if sensor.on then
        listen (Api.sensorSocketUrl sId) (OnValue sId)
    else
        Sub.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch <|
        (Api.chatSubscription model)
            :: (List.map Tuple.second <|
                    Dict.toList <|
                        Dict.map sensorSubscription (getSensors model)
               )
