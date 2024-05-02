import build_list.{build_list}
import consts.{amount_of_guesses}
import gleam/list
import row.{type Row}

pub type Board {
  Board(answer: String, rows: List(Row), is_over: Bool)
}

pub fn new(word: String) {
  let rows = build_list([], row.new, amount_of_guesses)
  Board(word, rows, False)
}

pub fn to_strings(board: Board) {
  list.map(board.rows, fn(item) { row.to_string(item) })
}

pub fn concat_strings(board_a: Board, board_b: Board) {
  list.map2(to_strings(board_a), to_strings(board_b), fn(a, b) {
    a <> "\t" <> b
  })
}

pub fn make_guess(board: Board, guess: String) {
  let #(_, rows) =
    list.map_fold(board.rows, False, fn(found, row) {
      case row.guess == "" {
        True if found == False -> #(True, row.make_guess(board.answer, guess))
        _ -> #(found, row)
      }
    })

  let is_over = guess == board.answer

  Board(board.answer, rows, is_over)
}
