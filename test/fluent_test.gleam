import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import parser
import parser/ast

pub fn main() {
  gleeunit.main()
}

pub fn parse_item_comment_test() {
  let node = should.be_ok(parser.parse("# hello\n"))
  should.equal(
    ast.Resource([
      ast.ResourceBodyComment(ast.ItemCommentKind(ast.ItemComment(" hello"))),
    ]),
    node,
  )

  let node = should.be_ok(parser.parse("# hello"))
  should.equal(
    ast.Resource([
      ast.ResourceBodyComment(ast.ItemCommentKind(ast.ItemComment(" hello"))),
    ]),
    node,
  )
}

pub fn parse_group_comment_test() {
  let node = should.be_ok(parser.parse("## hello\n"))
  should.equal(
    ast.Resource([
      ast.ResourceBodyComment(ast.GroupCommentKind(ast.GroupComment(" hello"))),
    ]),
    node,
  )

  let node = should.be_ok(parser.parse("## hello"))
  should.equal(
    ast.Resource([
      ast.ResourceBodyComment(ast.GroupCommentKind(ast.GroupComment(" hello"))),
    ]),
    node,
  )
}

pub fn parse_resource_comment_test() {
  let node = should.be_ok(parser.parse("### hello\n"))
  should.equal(
    ast.Resource([
      ast.ResourceBodyComment(
        ast.ResourceCommentKind(ast.ResourceComment(" hello")),
      ),
    ]),
    node,
  )

  let node = should.be_ok(parser.parse("### hello"))
  should.equal(
    ast.Resource([
      ast.ResourceBodyComment(
        ast.ResourceCommentKind(ast.ResourceComment(" hello")),
      ),
    ]),
    node,
  )
}

pub fn parse_term_test() {
  let node = should.be_ok(parser.parse("# Comment\n-term = Hello World\n"))
  should.equal(
    ast.Resource([
      ast.ResourceBodyTerm(ast.Term(
        id: ast.Identifier(name: "-term"),
        value: ast.Pattern([ast.PatternText(ast.Text("Hello World"))]),
        attributes: [],
        comment: Some(ast.ItemComment(" Comment")),
      )),
    ]),
    node,
  )
}
