import argv
import chromatic.{bg_green, bg_yellow, black, gray}
import consts.{default_amount_of_boards, possible_words_path, valid_words_path}
import game
import gleam/int
import gleam/io
import gleam/string
import simplifile

fn words_from_file(path: String) {
  let assert Ok(words) = simplifile.read(from: path)
  string.split(words, "\n")
}

fn load_amount_of_boards() -> Result(Int, Nil) {
  case argv.load().arguments {
    [value] -> {
      case int.parse(value) {
        Ok(amount) if amount > 0 -> Ok(amount)
        _ -> Error(Nil)
      }
    }
    [_, ..] -> Error(Nil)
    _ -> Ok(default_amount_of_boards)
  }
}

pub fn main() {
  io.println(
    "\nHello, "
    |> gray
    <> "g"
    |> black
    |> bg_yellow
    <> "_"
    |> gray
    <> "r"
    |> black
    |> bg_green
    <> "ld!\n"
    |> gray,
  )

  case load_amount_of_boards() {
    Ok(amount_of_boards) -> {
      let possible_words = words_from_file(possible_words_path)
      let valid_words = words_from_file(valid_words_path)

      let game = game.new(possible_words, valid_words, amount_of_boards)
      game.loop(game)
    }
    _ -> {
      io.println("usage: gleam run -t javascript <amount_of_boards>")
      game.exit_message()
    }
  }
}
