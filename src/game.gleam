import board.{type Board}
import chromatic.{blue, bold, red, green} 
import consts.{amount_of_guesses, codepoint_int_a, codepoint_int_z}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import question.{question}

pub type Game {
  Game(
    possible_words: List(String),
    valid_words: List(String),
    board_1: Board,
    board_2: Board,
    board_3: Board,
    board_4: Board,
    attempts: Int,
    all_correct: Bool,
    is_over: Bool,
  )
}

type GuessError {
  Empty
  TooLong
  TooShort
  NonAlpha
  UnknownWord
}

pub fn new(possible_words: List(String), valid_words: List(String)) {
  let answer_1 = pick_answer(valid_words)
  let answer_2 = pick_answer(valid_words)
  let answer_3 = pick_answer(valid_words)
  let answer_4 = pick_answer(valid_words)

  // TODO ensure picked words are unique

  // io.debug(answer_1)
  // io.debug(answer_2)
  // io.debug(answer_3)
  // io.debug(answer_4)

  Game(
    possible_words,
    valid_words,
    board.new(answer_1),
    board.new(answer_2),
    board.new(answer_3),
    board.new(answer_4),
    0,
    False,
    False,
  )
}

fn pick_answer(valid_words: List(String)) {
  let max = list.length(valid_words) - 1
  let index = int.random(max)
  let assert Ok(answer) = list.at(valid_words, index)
  answer
}

pub fn loop(game: Game) {
  print(game)

  question.question("\nMake a guess\n", fn(guess) {
    let game = case parse_guess(game, guess) {
      Error(Empty) -> {
        io.println(
          "Guess is empty"
          |> red,
        )
        game
      }
      Error(TooLong) -> {
        io.println(
          "\nGuess is too long"
          |> red,
        )
        game
      }
      Error(TooShort) -> {
        io.println(
          "\nGuess is too short"
          |> red,
        )
        game
      }
      Error(NonAlpha) -> {
        io.println(
          "\nOnly letters are allowed"
          |> red,
        )
        game
      }
      Error(UnknownWord) -> {
        io.println(
          "\nUnknown word"
          |> red,
        )
        game
      }
      Ok(guess) -> make_guess(game, guess)
    }

    case game.is_over {
      False -> loop(game)
      True -> game_over(game)
    }
  })
}

fn print(game: Game) {
  let top_boards_strings = board.concat_strings(game.board_1, game.board_2)
  let bottom_boards_strings = board.concat_strings(game.board_3, game.board_4)

  io.println("")
  list.each(top_boards_strings, io.println)
  io.println("\n")
  list.each(bottom_boards_strings, io.println)
}

fn parse_guess(game: Game, guess: String) -> Result(String, GuessError) {
  guess
  |> string.trim()
  |> string.lowercase()
  |> Ok
  |> result.try(parse_guess_empty)
  |> result.try(parse_guess_length)
  |> result.try(parse_guess_is_alpha)
  |> result.try(parse_guess_is_word(_, game.possible_words))
}

fn parse_guess_empty(guess: String) -> Result(String, GuessError) {
  case string.is_empty(guess) {
    True -> Error(Empty)
    False -> Ok(guess)
  }
}

fn parse_guess_length(guess: String) -> Result(String, GuessError) {
  case string.length(guess) {
    len if len > 5 -> Error(TooLong)
    len if len < 5 -> Error(TooShort)
    _ -> Ok(guess)
  }
}

fn parse_guess_is_alpha(guess: String) -> Result(String, GuessError) {
  let all_chars_are_alpha =
    string.to_utf_codepoints(guess)
    |> list.fold_until(True, fn(_, codepoint) {
      case string.utf_codepoint_to_int(codepoint) {
        int if int < codepoint_int_a -> list.Stop(False)
        int if int > codepoint_int_z -> list.Stop(False)
        _ -> list.Continue(True)
      }
    })

  case all_chars_are_alpha {
    False -> Error(NonAlpha)
    True -> Ok(guess)
  }
}

fn parse_guess_is_word(
  guess: String,
  possible_words: List(String),
) -> Result(String, GuessError) {
  case list.any(possible_words, fn(word) { word == guess }) {
    False -> Error(UnknownWord)
    True -> Ok(guess)
  }
}

fn make_guess(game: Game, guess: String) {
  let board_1 = case game.board_1.is_correct {
    True -> game.board_1
    False -> board.make_guess(game.board_1, guess)
  }

  let board_2 = case game.board_2.is_correct {
    True -> game.board_2
    False -> board.make_guess(game.board_2, guess)
  }

  let board_3 = case game.board_3.is_correct {
    True -> game.board_3
    False -> board.make_guess(game.board_3, guess)
  }

  let board_4 = case game.board_4.is_correct {
    True -> game.board_4
    False -> board.make_guess(game.board_4, guess)
  }

  let attempts = game.attempts + 1
  let all_correct =
    board_1.is_correct && board_2.is_correct && board_3.is_correct && board_4.is_correct
  let is_over = all_correct || attempts == amount_of_guesses

  Game(
    game.possible_words,
    game.valid_words,
    board_1,
    board_2,
    board_3,
    board_4,
    attempts,
    all_correct,
    is_over,
  )
}

fn answer_is_correct_color(answer: String, is_correct: Bool) {
  case is_correct {
    True -> answer |> bold |> green
    False -> answer |> bold |> red
  }
}

fn game_over(game: Game) {
  print(game)
  io.println("")
  case game.all_correct {
    True -> {
      io.println("Guessed in " <> int.to_string(game.attempts) <> " attempts!")
      io.println(
        "You "
        <> "WOW"
        |> blue
        <> "!",
      )
    }
    False -> {
      io.println(
        "The words were: "
        <> game.board_1.answer
        |> answer_is_correct_color(game.board_1.is_correct)
        <> ", "
        <> game.board_2.answer
        |> answer_is_correct_color(game.board_2.is_correct)
        <> ", "
        <> game.board_3.answer
        |> answer_is_correct_color(game.board_3.is_correct)
        <> ", "
        <> game.board_4.answer
        |> answer_is_correct_color(game.board_4.is_correct)
        <> ".",
      )
      io.println("Better luck next time.")
    }
  }
  io.println("")
  io.println("Press ctrl + c to exit")
}
