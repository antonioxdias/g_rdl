import consts.{amount_of_guesses}
import gleam/int
import gleam/list
import row.{type Row}
import utils.{build_list}

pub type Board {
  Board(answer: String, rows: List(Row), is_correct: Bool)
}

pub fn new(valid_words: List(String)) {
  fn() {
    let answer = pick_answer(valid_words)
    // io.debug(answer)
    let rows = build_list(row.new, amount_of_guesses)
    Board(answer, rows, False)
  }
}

fn pick_answer(valid_words: List(String)) {
  let max = list.length(valid_words) - 1
  let index = int.random(max)

  let answer =
    list.fold_until(valid_words, "0", fn(i, word) {
      let assert Ok(cur_index) = int.parse(i)
      case cur_index == index {
        True -> list.Stop(word)
        False -> list.Continue(int.to_string(cur_index + 1))
      }
    })
  answer
}

pub fn to_strings(board: Board) {
  list.map(board.rows, fn(item) { row.to_string(item) })
}

pub fn concat_strings(board_a: Board, board_b: Board) {
  list.map2(to_strings(board_a), to_strings(board_b), fn(a, b) {
    a <> "\t" <> b
  })
}

pub fn many_to_strings(boards: List(Board)) {
  let strings = build_list(fn() { "" }, amount_of_guesses)
  let #(strings, _) =
    list.map_fold(boards, strings, fn(strings, board) {
      let rows_str =
        list.map2(strings, board.rows, fn(row_str, board_row) {
          case row_str == "" {
            True -> row.to_string(board_row)
            False -> row_str <> "\t" <> row.to_string(board_row)
          }
        })
      #(rows_str, board)
    })
  strings
}

pub fn make_guess(board: Board, guess: String) {
  let #(_, rows) =
    list.map_fold(board.rows, False, fn(found, row) {
      case row.guess == "" {
        True if found == False -> #(True, row.make_guess(board.answer, guess))
        _ -> #(found, row)
      }
    })

  let is_correct = guess == board.answer

  Board(board.answer, rows, is_correct)
}
