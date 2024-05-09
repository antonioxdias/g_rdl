import gleam/list

fn build_list_internal(list: List(thing), new_thing: fn() -> thing, length: Int) {
  case list.length(list) {
    current_length if current_length == length -> list.reverse(list)
    _ -> build_list_internal([new_thing(), ..list], new_thing, length)
  }
}

pub fn build_list(new_thing: fn() -> thing, length: Int) {
  build_list_internal([], new_thing, length)
}

pub fn fold2(
  over1 list1: List(a),
  over2 list2: List(b),
  from initial: acc,
  with fun: fn(acc, a, b) -> acc,
) -> acc {
  case list1, list2 {
    [], _ | _, [] -> initial
    [x, ..rest1], [y, ..rest2] -> fold2(rest1, rest2, fun(initial, x, y), fun)
  }
}
