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
