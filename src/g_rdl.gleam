import chromatic.{bg_green, bg_yellow, black, white}
import consts.{possible_words_path, valid_words_path}
import game
import gleam/io
import gleam/string
import simplifile

fn words_from_file(path: String) {
  let assert Ok(words) = simplifile.read(from: path)
  string.split(words, "\n")
}

pub fn main() {
  io.println(
    "\nHello, "
    |> white
    <> "g"
    |> black
    |> bg_yellow
    <> "_"
    |> white
    <> "r"
    |> black
    |> bg_green
    <> "ld!\n"
    |> white,
  )

  let possible_words = words_from_file(possible_words_path)
  let valid_words = words_from_file(valid_words_path)

  let game = game.new(possible_words, valid_words)
  game.loop(game)
}
