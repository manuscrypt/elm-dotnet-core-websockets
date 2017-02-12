module Sensor exposing (..)

import Html exposing (Html, div, text, input, button, span)
import Html.Attributes as HA
import Html.Events as HE
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Label as Label
import Svg
import RemoteData exposing (..)
import Types exposing (..)
import Http
import Dict


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


sensorContainerStyle : Html.Attribute msg
sensorContainerStyle =
    HA.style
        [ "border" => "1px solid black"
        , "padding" => "20px"
        , "margin-top" => "20px"
        ]


viewError : Http.Error -> Html Msg
viewError err =
    div [] [ text <| "There was an error: " ++ toString err ]


viewSensors : Model -> Sensors -> Html Msg
viewSensors model arr =
    Dict.toList arr
        |> List.map Tuple.second
        |> List.sortBy .freq
        |> List.map (viewSensor model)
        |> div []


viewSensor : Model -> Sensor -> Html Msg
viewSensor model sensor =
    div [ sensorContainerStyle ]
        [ button [ HE.onClick <| Types.ToggleSensor sensor.id ]
            [ text
                (if sensor.on then
                    "Off"
                 else
                    "On"
                )
            ]
        , div [ HA.style [ "display" => "flex" ] ]
            [ viewPlot model sensor
            , viewInfo sensor
            ]
        ]


viewInfo : Sensor -> Html Msg
viewInfo sensor =
    div [ HA.style [ "flex" => "auto" ] ]
        [ infoRow "Kind" sensor.kind
        , infoRow "Id" (String.left 10 sensor.id)
        , infoRow "Reporting Freq." (toString sensor.freq ++ " Hz")
        , infoRow "Last Value"
            (Maybe.withDefault "-"
                (Maybe.map toString <|
                    List.head sensor.vals
                )
            )
        ]


infoRow : String -> String -> Html Msg
infoRow label value =
    div [ HA.style [ "flex" => "auto" ] ]
        [ span [] [ text label ]
        , text "   "
        , span [] [ text value ]
        ]


plotSize : ( Int, Int )
plotSize =
    ( 600, 100 )


pinkStroke : String
pinkStroke =
    "#441232"


viewPlot : Model -> Sensor -> Svg.Svg Msg
viewPlot model sensor =
    let
        data =
            List.indexedMap (\i v -> ( toFloat i, v )) <|
                List.take model.historySize <|
                    sensor.vals
    in
        plot
            [ size plotSize
            , margin ( 10, 20, 40, 20 )
            ]
            [ line
                [ Line.stroke pinkStroke
                , Line.strokeWidth 2
                  --, Line.smoothingBezier
                ]
                data
            , xAxis
                [ Axis.line [ Line.stroke "#000000" ]
                , Axis.tick [ Tick.viewDynamic toTickStyle ]
                , Axis.label [ Label.viewDynamic toLabelStyle ]
                ]
            ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


toTickStyle : Axis.LabelInfo -> List (Tick.StyleAttribute msg)
toTickStyle { index } =
    if isOdd index then
        [ Tick.length 7
        , Tick.stroke "#e4e3e3"
        ]
    else
        [ Tick.length 10
        , Tick.stroke "#b9b9b9"
        ]


toLabelStyle : Axis.LabelInfo -> List (Label.StyleAttribute msg)
toLabelStyle { index } =
    if isOdd index then
        []
    else
        [ Label.stroke "#969696"
        ]
