import chromatic.{bg_green, bg_yellow, black, bold, gray}
import gleam/string.{uppercase}

pub type Cell {
  Empty
  Wrong(String)
  Possible(String)
  Correct(String)
}

pub fn new() {
  Empty
}

pub fn to_string(cell: Cell) {
  case cell {
    Empty ->
      "_"
      |> gray
    Wrong(char) ->
      char
      |> uppercase
      |> bold
      |> gray
    Possible(char) ->
      char
      |> uppercase
      |> bold
      |> black
      |> bg_yellow
    Correct(char) ->
      char
      |> uppercase
      |> bold
      |> black
      |> bg_green
  }
}
