import board.{type Board}
import build_list.{build_list}
import chromatic.{blue, bold, green, red}
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
    boards: List(Board),
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
  let amount_of_boards = 6
  let boards = build_list([], board.new(valid_words), amount_of_boards)
  Game(possible_words, valid_words, boards, 0, False, False)
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
  io.println("")
  list.each(board.many_to_strings(game.boards), io.println)
  io.println("\n")
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
  let boards =
    list.map(game.boards, fn(game_board) {
      case game_board.is_correct {
        True -> game_board
        False -> board.make_guess(game_board, guess)
      }
    })

  let attempts = game.attempts + 1
  let all_correct =
    list.fold(boards, True, fn(acc, game_board) {
      acc && game_board.is_correct
    })
  let is_over = all_correct || attempts == amount_of_guesses

  Game(
    game.possible_words,
    game.valid_words,
    boards,
    attempts,
    all_correct,
    is_over,
  )
}

fn answer_is_correct_color(answer: String, is_correct: Bool) {
  case is_correct {
    True ->
      answer
      |> bold
      |> green
    False ->
      answer
      |> bold
      |> red
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
        <> list.map(game.boards, fn(game_board) {
          game_board.answer
          |> answer_is_correct_color(game_board.is_correct)
        })
        |> string.join(", ")
        <> "."
      )
      io.println("Better luck next time.")
    }
  }
  io.println("")
  io.println("Press ctrl + c to exit")
}