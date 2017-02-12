module Types exposing (..)

import RemoteData exposing (..)
import Http
import Dict exposing (Dict)


type alias SensorId =
    String


type alias Sensors =
    Dict SensorId Sensor


type alias Sensor =
    { id : SensorId
    , kind : String
    , freq : Int
    , on : Bool
    , vals : List Float
    , historySize : Int
    }


type alias Model =
    { message : String
    , history : List String
    , historySize : Int
    , sensors : WebData Sensors
    }


type Msg
    = OnValue SensorId String
    | Message String
    | SendMessage
    | ChangeMessage String
    | GotSensors (Result Http.Error (List Sensor))
    | ToggleSensor SensorId
    | ToggleAll
