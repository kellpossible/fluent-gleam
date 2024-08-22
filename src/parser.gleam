import gleam/list
import gleam/option.{None, Some}
import gleam/regex
import gleam/result
import gleam/string
import parser/ast

type MyError =
  String

pub fn parse(input: String) -> Result(ast.Resource, MyError) {
  // TODO: what if remaining isn't empty?
  use #(nodes, remaining) <- result.try(parse_resource_body_nodes(input, []))
  Ok(ast.Resource(body: nodes))
}

fn parse_resource_body_nodes(
  input: String,
  nodes: List(ast.ResourceBodyNode),
) -> Result(#(List(ast.ResourceBodyNode), String), MyError) {
  let input = string.trim_left(input)
  case string.is_empty(input) {
    True -> Ok(#(nodes, input))
    False -> {
      use #(node, remaining) <- result.try(parse_resource_body_node(input))
      Ok(#(nodes |> list.append([node]), remaining))
    }
  }
}

fn parse_resource_body_node(
  input: String,
) -> Result(#(ast.ResourceBodyNode, String), MyError) {
  use _ <- result.try_recover(
    parse_term(input) |> map_matched(fn(term) { ast.ResourceBodyTerm(term) }),
  )
  use _ <- result.try_recover(
    parse_resource_comment(input)
    |> map_matched(fn(comment) {
      ast.ResourceBodyComment(ast.ResourceCommentKind(comment))
    }),
  )
  use _ <- result.try_recover(
    parse_group_comment(input)
    |> map_matched(fn(comment) {
      ast.ResourceBodyComment(ast.GroupCommentKind(comment))
    }),
  )
  use _ <- result.try_recover(
    parse_item_comment(input)
    |> map_matched(fn(comment) {
      ast.ResourceBodyComment(ast.ItemCommentKind(comment))
    }),
  )
  Error("Unable to parse")
}

fn map_matched(
  over: Result(#(a, String), b),
  with: fn(a) -> c,
) -> Result(#(c, String), b) {
  result.map(over, fn(ok) { #(with(ok.0), ok.1) })
}

fn parse_item_comment(
  input: String,
) -> Result(#(ast.ItemComment, String), MyError) {
  parse_comment(input, "#")
  |> map_matched(fn(ok) { ast.ItemComment(ok) })
}

fn parse_group_comment(
  input: String,
) -> Result(#(ast.GroupComment, String), MyError) {
  parse_comment(input, "##")
  |> map_matched(fn(ok) { ast.GroupComment(ok) })
}

fn parse_resource_comment(
  input: String,
) -> Result(#(ast.ResourceComment, String), MyError) {
  parse_comment(input, "###")
  |> map_matched(fn(ok) { ast.ResourceComment(ok) })
}

fn parse_comment(
  input: String,
  start_symbol: String,
) -> Result(#(String, String), MyError) {
  use #(content, remaining) <- result.try(case
    string.starts_with(input, start_symbol)
  {
    True -> {
      let #(matched, remaining) =
        parse_until_newline_or_end(string.drop_left(
          input,
          string.length(start_symbol),
        ))
      Ok(#(matched, remaining))
    }
    False -> Error("Not a comment")
  })

  case parse_comment(remaining, start_symbol) {
    Ok(#(comment, remaining)) -> {
      Ok(#(string.append(content, comment), remaining))
    }
    Error(_) -> {
      Ok(#(content, remaining))
    }
  }
}

fn parse_term(input: String) -> Result(#(ast.Term, String), MyError) {
  let #(comment, remaining) = case parse_item_comment(input) {
    Ok(#(comment, remaining)) -> #(Some(comment), remaining)
    Error(_) -> #(None, input)
  }
}

fn is_alpha(grapheme: String) -> Bool {
  let assert Ok(re) = regex.from_string("\\p{Letter}")
  re |> regex.check(grapheme)
}

fn is_number(grapheme: String) -> Bool {
  let assert Ok(re) = regex.from_string("\\p{Number}")
  re |> regex.check(grapheme)
}

fn is_alphanumeric(grapheme: String) -> Bool {
  is_alpha(grapheme) || is_number(grapheme)
}

fn parse_identifier(input: String) -> Result(#(ast.Identifier, String), MyError) {
  use #(_, consumed): #(Bool, Int) <- result.try(
    string.to_graphemes(input)
    |> list.try_fold(#(False, 0), fn(acc, grapheme) {
      let #(done, consumed) = acc
      case done {
        True -> Ok(#(True, consumed))
        False ->
          case
            consumed,
            is_alpha(grapheme),
            is_number(grapheme),
            grapheme == "-"
          {
            0, _, True, _ -> Error("Identifier cannot start with a number")
            0, _, _, True -> Error("Identifier cannot start with a -")
            _, True, _, _ | _, _, True, _ | _, _, _, True ->
              Ok(#(False, consumed + 1))
            _, _, _, _ -> Ok(#(True, consumed))
          }
      }
    }),
  )

  case consumed {
    0 -> Error("No valid identifier found")
    _ -> {
      Ok(#(
        ast.Identifier(string.slice(input, 0, consumed)),
        string.slice(input, consumed, string.length(input)),
      ))
    }
  }
}

fn parse_until_newline(input: String) -> Result(#(String, String), MyError) {
  result.map_error(string.split_once(input, "\n"), fn(_) { "Expected newline" })
}

fn parse_until_newline_or_end(input: String) -> #(String, String) {
  string.split_once(input, "\n") |> result.unwrap(#(input, ""))
}
