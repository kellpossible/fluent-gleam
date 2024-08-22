import gleam/option.{type Option}

pub type Comment {
  ItemCommentKind(ItemComment)
  GroupCommentKind(GroupComment)
  ResourceCommentKind(ResourceComment)
}

pub type ItemComment {
  ItemComment(content: String)
}

pub type GroupComment {
  GroupComment(content: String)
}

pub type ResourceComment {
  ResourceComment(content: String)
}

pub type ResourceBodyNode {
  ResourceBodyMessage(Message)
  ResourceBodyTerm(Term)
  ResourceBodyComment(Comment)
}

pub type Resource {
  Resource(body: List(ResourceBodyNode))
}

pub type PatternElement {
  PatternText(Text)
  PatternPlaceable(Placeable)
}

pub type Pattern {
  Pattern(elements: List(PatternElement))
}

pub type Text {
  Text(value: String)
}

pub type PlaceableExpression {
  PlaceableMessage(MessageReference)
  PlaceableTerm(TermReference)
  PlaceableSelect(Select)
}

pub type Placeable {
  Placeable(expression: PlaceableExpression)
}

pub type Identifier {
  Identifier(name: String)
}

pub type Term {
  Term(
    id: Identifier,
    value: Pattern,
    attributes: List(Attribute),
    comment: Option(ItemComment),
  )
}

pub type Attribute {
  Attribute(id: Identifier, value: Pattern)
}

pub type StringLiteral {
  StringLiteral(value: String)
}

pub type NumberLiteral {
  NumberLiteral(value: String)
}

pub type Selector {
  SelectorMessage(MessageReference)
  SelectorTerm(TermReference)
  SelectorSelect(Select)
}

pub type Select {
  Select(selector: Selector, variants: List(Variant))
}

pub type VariantKey {
  VariantKeyIdentifier(Identifier)
  VariantKeyNumberLiteral(NumberLiteral)
}

pub type Variant {
  Variant(key: VariantKey, value: Pattern, default: Bool)
}

pub type Message {
  Message(
    id: Identifier,
    value: Pattern,
    atrributes: List(Attribute),
    comment: Option(ItemComment),
  )
}

pub type MessageReference {
  MessageReference(id: Identifier, attribute: Attribute)
}

pub type PositionalCallArgument {
  PositionalCallArgumentTerm(TermReference)
  PositionalCallArgumentMessage(MessageReference)
}

pub type CallArguments {
  CallArguments(
    positional: List(PositionalCallArgument),
    named: List(NamedArgument),
  )
}

pub type NamedArgument {
  NamedArgument(name: Identifier, value: StringLiteral)
}

pub type TermReference {
  TermReference(id: Identifier, attribute: Attribute, arguments: CallArguments)
}

pub type Junk {
  Junk(content: String, annotations: List(String))
}
