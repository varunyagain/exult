/// Writing genre tree based on Wikipedia's "List of writing genres".
/// Reuses AttributeNode from category_tree.dart for the tree structure.

import 'package:exult_flutter/core/constants/category_tree.dart';

const List<AttributeNode> writingGenreTree = [
  // Fiction
  AttributeNode('Fiction', [
    AttributeNode('Action & Adventure', [
      AttributeNode('Action Fiction'),
      AttributeNode('Adventure Fiction'),
    ]),
    AttributeNode('Classic & Literary Fiction', [
      AttributeNode('Bildungsroman'),
      AttributeNode('Epic'),
      AttributeNode('Fabulation'),
      AttributeNode('Picaresque'),
    ]),
    AttributeNode('Comedy'),
    AttributeNode('Crime Fiction', [
      AttributeNode('Detective Fiction'),
      AttributeNode('Mystery'),
      AttributeNode('Noir Fiction'),
    ]),
    AttributeNode('Erotica'),
    AttributeNode('Fairy Tale'),
    AttributeNode('Fantasy', [
      AttributeNode('Contemporary Fantasy'),
      AttributeNode('Dark Fantasy'),
      AttributeNode('High Fantasy'),
      AttributeNode('Historical Fantasy'),
      AttributeNode('Low Fantasy'),
      AttributeNode('Urban Fantasy'),
    ]),
    AttributeNode('Gothic Fiction'),
    AttributeNode('Historical Fiction'),
    AttributeNode('Horror'),
    AttributeNode('Magical Realism'),
    AttributeNode('Mythopoeia'),
    AttributeNode('Political Fiction'),
    AttributeNode('Romance', [
      AttributeNode('Contemporary Romance'),
      AttributeNode('Gothic Romance'),
      AttributeNode('Historical Romance'),
      AttributeNode('Paranormal Romance'),
    ]),
    AttributeNode('Satire'),
    AttributeNode('Science Fiction', [
      AttributeNode('Apocalyptic & Post-Apocalyptic'),
      AttributeNode('Cyberpunk'),
      AttributeNode('Dystopian Fiction'),
      AttributeNode('Hard Science Fiction'),
      AttributeNode('Soft Science Fiction'),
      AttributeNode('Space Opera'),
      AttributeNode('Steampunk'),
    ]),
    AttributeNode('Speculative Fiction'),
    AttributeNode('Thriller & Suspense'),
    AttributeNode('Utopian Fiction'),
    AttributeNode('Western Fiction'),
  ]),

  // Nonfiction
  AttributeNode('Nonfiction', [
    AttributeNode('Academic Writing'),
    AttributeNode('Autobiography & Memoir'),
    AttributeNode('Biography'),
    AttributeNode('Creative Nonfiction'),
    AttributeNode('Essay'),
    AttributeNode('Journalism & Reportage'),
    AttributeNode('Philosophy'),
    AttributeNode('Popular Science'),
    AttributeNode('Reference'),
    AttributeNode('Self-Help'),
    AttributeNode('Speech'),
    AttributeNode('Travel Writing'),
    AttributeNode('True Crime'),
  ]),

  // Children's & Young Adult
  AttributeNode("Children's & Young Adult", [
    AttributeNode("Children's Literature"),
    AttributeNode('New Adult Fiction'),
    AttributeNode('Young Adult Fiction'),
  ]),

  // Drama
  AttributeNode('Drama', [
    AttributeNode('Comedy Drama'),
    AttributeNode('Melodrama'),
    AttributeNode('Musical'),
    AttributeNode('Tragedy'),
    AttributeNode('Tragicomedy'),
  ]),

  // Poetry
  AttributeNode('Poetry', [
    AttributeNode('Epic Poetry'),
    AttributeNode('Haiku'),
    AttributeNode('Limerick'),
    AttributeNode('Lyric Poetry'),
    AttributeNode('Narrative Poetry'),
    AttributeNode('Prose Poetry'),
    AttributeNode('Sonnet'),
  ]),
];

/// Flat list of ALL genre names from the tree.
List<String> get allGenreNames {
  List<String> result = [];
  void collect(List<AttributeNode> nodes) {
    for (final node in nodes) {
      result.add(node.name);
      collect(node.children);
    }
  }
  collect(writingGenreTree);
  return result;
}
