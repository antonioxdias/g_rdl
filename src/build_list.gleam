import gleam/list

pub fn build_list(list: List(thing), new_thing: fn() -> thing, length: Int) {
  case list.length(list) {
    current_length if current_length == length -> list
    _ -> build_list([new_thing(), ..list], new_thing, length)
  }
}
