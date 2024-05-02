import build_list.{build_list}
import cell.{type Cell}
import consts.{word_size}
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub type Row {
  Row(guess: String, cells: List(Cell))
}

pub fn new() {
  let cells = build_list([], cell.new, word_size)
  Row("", cells)
}

pub fn to_string(row: Row) {
  list.fold(row.cells, "", fn(acc, item) { acc <> " " <> cell.to_string(item) })
  |> string.trim
}

pub fn make_guess(answer: String, guess: String) {
  let guess_chars = string.to_graphemes(guess)
  let answer_chars = string.to_graphemes(answer)

  let char_counts =
    list.fold(answer_chars, dict.new(), fn(counts, char) {
      let count = case dict.get(counts, char) {
        Ok(count) -> count + 1
        _ -> 1
      }
      dict.insert(counts, char, count)
    })

  let update_char_counts = fn(char_counts, guess_char) {
    dict.update(char_counts, guess_char, fn(count) {
      option.unwrap(count, 1) - 1
    })
  }

  // Look for correct chars
  let #(cells, char_counts) =
    guess_chars
    |> list.index_fold(#([], char_counts), fn(acc, guess_char, i) {
      let #(cells, char_counts) = acc
      let assert Ok(answer_char) = list.at(answer_chars, i)

      let #(cell, char_counts) = case guess_char == answer_char {
        True -> #(
          cell.Correct(guess_char),
          update_char_counts(char_counts, guess_char),
        )
        False -> #(cell.Wrong(guess_char), char_counts)
      }

      let cells = list.concat([cells, [cell]])
      #(cells, char_counts)
    })

  // Look for possible chars
  let #(cells, _) =
    cells
    |> list.fold(#([], char_counts), fn(acc, cell) {
      let #(cells, char_counts) = acc
      let #(guess_char, is_correct) = case cell {
        cell.Empty -> panic as "cell should not be empty after Correct check"
        cell.Wrong(char) -> #(char, False)
        cell.Possible(char) -> #(char, False)
        cell.Correct(char) -> #(char, True)
      }

      let is_possible = result.unwrap(dict.get(char_counts, guess_char), 0) > 0

      let #(cell, char_counts) = case guess_char {
        _ if is_correct -> #(cell.Correct(guess_char), char_counts)
        _ if is_possible -> #(
          cell.Possible(guess_char),
          update_char_counts(char_counts, guess_char),
        )
        _ -> #(cell.Wrong(guess_char), char_counts)
      }

      let cells = list.concat([cells, [cell]])
      #(cells, char_counts)
    })

  Row(guess, cells)
}