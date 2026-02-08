/// Writing genre tree based on Wikipedia's "List of writing genres".
/// Reuses AttributeNode from category_tree.dart for the tree structure.

import 'package:exult_flutter/core/constants/category_tree.dart';

const List<AttributeNode> writingGenreTree = [
  // ── Fiction ──────────────────────────────────────────────────────────────
  AttributeNode('Fiction', [
    // Action & Adventure
    AttributeNode('Action & Adventure', [
      AttributeNode('Adventure Fantasy', [
        AttributeNode('Heroic Fantasy'),
        AttributeNode('Lost World'),
        AttributeNode('Sword-and-sandal'),
        AttributeNode('Sword-and-sorcery'),
        AttributeNode('Sword-and-soul'),
        AttributeNode('Wuxia'),
      ]),
      AttributeNode('Nautical', [
        AttributeNode('Pirate'),
      ]),
      AttributeNode('Robinsonade'),
      AttributeNode('Spy', [
        AttributeNode('Spy-Fi'),
      ]),
      AttributeNode('Subterranean'),
      AttributeNode('Superhero'),
      AttributeNode('Swashbuckler', [
        AttributeNode('Picaresque'),
      ]),
    ]),

    // Classic & Literary Fiction
    AttributeNode('Classic & Literary Fiction', [
      AttributeNode('Bildungsroman'),
      AttributeNode('Encyclopedic'),
      AttributeNode('Epic', [
        AttributeNode('Epic Poetry'),
      ]),
      AttributeNode('Fabulation'),
    ]),

    // Comedy
    AttributeNode('Comedy', [
      AttributeNode('Burlesque'),
      AttributeNode('Fantasy Comedy'),
      AttributeNode('Comedy Horror'),
      AttributeNode('Conte'),
      AttributeNode('Parody', [
        AttributeNode('Metaparody'),
      ]),
      AttributeNode('Sci-fi Comedy'),
      AttributeNode('Surreal Comedy'),
      AttributeNode('Tall Tale'),
      AttributeNode('Tragicomedy'),
    ]),

    // Crime Fiction
    AttributeNode('Crime Fiction', [
      AttributeNode('Caper'),
      AttributeNode('Giallo'),
      AttributeNode('Legal Thriller'),
      AttributeNode('Mystery', [
        AttributeNode('Cozy Mystery'),
        AttributeNode('City Mysteries'),
        AttributeNode('Detective Fiction', [
          AttributeNode("Gong'an"),
          AttributeNode('Girl Detective'),
          AttributeNode('Inverted Detective Story'),
          AttributeNode('Occult Detective'),
          AttributeNode('Hardboiled'),
          AttributeNode('Historical Mystery'),
          AttributeNode('Locked-room Mystery'),
          AttributeNode('Police Procedural'),
          AttributeNode('Whodunit'),
        ]),
      ]),
      AttributeNode('Noir Fiction', [
        AttributeNode('Nordic Noir'),
        AttributeNode('Tart Noir'),
      ]),
    ]),

    // Erotica
    AttributeNode('Erotica'),

    // Folklore
    AttributeNode('Folklore', [
      AttributeNode('Animal Tale'),
      AttributeNode('Fable'),
      AttributeNode('Fairy Tale'),
      AttributeNode('Ghost Story'),
      AttributeNode('Legend'),
      AttributeNode('Myth'),
      AttributeNode('Parable'),
      AttributeNode('Urban Legend'),
    ]),

    // Fantasy (Speculative Fiction sub-section)
    AttributeNode('Fantasy', [
      AttributeNode('Action-Adventure Fantasy', [
        AttributeNode('Heroic Fantasy'),
        AttributeNode('Lost World'),
        AttributeNode('Subterranean Fantasy'),
        AttributeNode('Sword-and-sandal'),
        AttributeNode('Sword-and-sorcery'),
        AttributeNode('Wuxia'),
      ]),
      AttributeNode('Contemporary Fantasy', [
        AttributeNode('Occult Detective Fiction'),
        AttributeNode('Paranormal Romance'),
        AttributeNode('Urban Fantasy'),
      ]),
      AttributeNode('Cozy Fantasy'),
      AttributeNode('Dark Fantasy'),
      AttributeNode('Fairytale Fantasy'),
      AttributeNode('Fantastique'),
      AttributeNode('Fantasy Comedy', [
        AttributeNode('Bangsian Fantasy'),
      ]),
      AttributeNode('Fantasy of Manners'),
      AttributeNode('Gaslamp Fantasy'),
      AttributeNode('Gothic Fantasy'),
      AttributeNode('Grimdark'),
      AttributeNode('Hard Fantasy'),
      AttributeNode('High Fantasy'),
      AttributeNode('Historical Fantasy'),
      AttributeNode('Isekai'),
      AttributeNode('Juvenile Fantasy'),
      AttributeNode('Low Fantasy'),
      AttributeNode('Magical Realism'),
      AttributeNode('Mythic Fiction', [
        AttributeNode('Mythopoeia'),
        AttributeNode('Mythpunk'),
      ]),
      AttributeNode('Romantic Fantasy'),
      AttributeNode('Science Fantasy', [
        AttributeNode('Dying Earth'),
        AttributeNode('Planetary Romance'),
        AttributeNode('Sword and Planet'),
      ]),
      AttributeNode('Shenmo'),
      AttributeNode('Superhero Fantasy'),
      AttributeNode('Supernatural Fiction'),
      AttributeNode('Weird Fiction', [
        AttributeNode('New Weird'),
      ]),
      AttributeNode('Weird West'),
      AttributeNode('Xenofiction'),
    ]),

    // Gothic Fiction
    AttributeNode('Gothic Fiction'),

    // Historical Fiction
    AttributeNode('Historical Fiction', [
      AttributeNode('Alternate History'),
      AttributeNode('Historical Fantasy'),
      AttributeNode('Historical Mystery'),
      AttributeNode('Historical Romance', [
        AttributeNode('Regency Romance'),
      ]),
      AttributeNode('Nautical Fiction', [
        AttributeNode('Pirate Novel'),
      ]),
    ]),

    // Horror (Speculative Fiction sub-section)
    AttributeNode('Horror', [
      AttributeNode('Body Horror'),
      AttributeNode('Comedy Horror', [
        AttributeNode('Zombie Comedy'),
      ]),
      AttributeNode('Erotic Horror', [
        AttributeNode('Ero Guro'),
      ]),
      AttributeNode('Ghost Stories'),
      AttributeNode('Gothic Horror', [
        AttributeNode('American Gothic'),
        AttributeNode('Southern Gothic'),
        AttributeNode('Southern Ontario Gothic'),
        AttributeNode('Space Gothic'),
        AttributeNode('Suburban Gothic'),
        AttributeNode('Tasmanian Gothic'),
        AttributeNode('Urban Gothic'),
      ]),
      AttributeNode('Japanese Horror'),
      AttributeNode('Korean Horror'),
      AttributeNode('Lovecraftian Horror'),
      AttributeNode('Monster Literature', [
        AttributeNode('Jiangshi Fiction'),
        AttributeNode('Werewolf Fiction'),
        AttributeNode('Vampire Literature'),
      ]),
      AttributeNode('Psychological Horror'),
      AttributeNode('Splatterpunk'),
      AttributeNode('Techno Horror'),
      AttributeNode('Weird Menace'),
      AttributeNode('Zombie Apocalypse'),
    ]),

    // Metafiction
    AttributeNode('Metafiction', [
      AttributeNode('Metaparody'),
    ]),

    // Nonsense
    AttributeNode('Nonsense', [
      AttributeNode('Nonsense Verse'),
    ]),

    // Philosophical Fiction
    AttributeNode('Philosophical Fiction'),

    // Political Fiction
    AttributeNode('Political Fiction', [
      AttributeNode('Libertarian Sci-fi'),
      AttributeNode('Social Sci-fi'),
      AttributeNode('Political Thriller'),
    ]),

    // Postmodern Literature
    AttributeNode('Postmodern Literature'),

    // Realist Fiction
    AttributeNode('Realist Fiction', [
      AttributeNode('Hysterical Realism'),
    ]),

    // Religious Fiction
    AttributeNode('Religious Fiction', [
      AttributeNode('Christian Fiction'),
      AttributeNode('Islamic Fiction'),
      AttributeNode('Theological Fiction'),
      AttributeNode('Visionary Fiction'),
    ]),

    // Romance
    AttributeNode('Romance', [
      AttributeNode('Amish Romance'),
      AttributeNode('Chivalric Romance', [
        AttributeNode('Romantic Fantasy'),
      ]),
      AttributeNode('Contemporary Romance', [
        AttributeNode('Gay Romance'),
        AttributeNode('Lesbian Romance'),
        AttributeNode('Medical Romance'),
      ]),
      AttributeNode('Erotic Romance', [
        AttributeNode('Erotic Thriller'),
      ]),
      AttributeNode('Historical Romance', [
        AttributeNode('Regency Romance'),
      ]),
      AttributeNode('Inspirational Romance'),
      AttributeNode('Paranormal Romance', [
        AttributeNode('Time-travel Romance'),
      ]),
      AttributeNode('Romantic Suspense'),
      AttributeNode('Western Romance'),
      AttributeNode('Young Adult Romance'),
    ]),

    // Satire
    AttributeNode('Satire', [
      AttributeNode('Horatian'),
      AttributeNode('Juvenalian'),
      AttributeNode('Menippean'),
    ]),

    // Science Fiction (Speculative Fiction sub-section)
    AttributeNode('Science Fiction', [
      AttributeNode('Apocalyptic & Post-Apocalyptic'),
      AttributeNode('Afrofuturism', [
        AttributeNode('Africanfuturism'),
      ]),
      AttributeNode('Christian Sci-fi'),
      AttributeNode('Sci-fi Comedy'),
      AttributeNode('Utopian & Dystopian', [
        AttributeNode('Dystopian Fiction', [
          AttributeNode('Cyberpunk', [
            AttributeNode('Biopunk'),
            AttributeNode('Dieselpunk'),
            AttributeNode('Japanese Cyberpunk'),
            AttributeNode('Nanopunk'),
            AttributeNode('Solarpunk'),
            AttributeNode('Steampunk'),
          ]),
        ]),
        AttributeNode('Utopian Fiction'),
      ]),
      AttributeNode('Feminist Sci-fi'),
      AttributeNode('Gothic Sci-fi'),
      AttributeNode('Hard Science Fiction', [
        AttributeNode('Climate Fiction'),
        AttributeNode('Parallel World'),
      ]),
      AttributeNode('Libertarian Sci-fi'),
      AttributeNode('Mecha', [
        AttributeNode('Mecha Anime and Manga'),
      ]),
      AttributeNode('Military Sci-fi'),
      AttributeNode('Soft Science Fiction', [
        AttributeNode('Anthropological Sci-fi'),
        AttributeNode('Social Sci-fi'),
      ]),
      AttributeNode('Space Opera'),
      AttributeNode('Space Western'),
      AttributeNode('Spy-Fi'),
      AttributeNode('Tech Noir'),
      AttributeNode('Techno-thriller'),
    ]),

    // Speculative Fiction (umbrella)
    AttributeNode('Speculative Fiction'),

    // Superhero (Speculative Fiction sub-section)
    AttributeNode('Superhero Fiction', [
      AttributeNode('Heroic Fantasy'),
      AttributeNode('Cape Punk'),
      AttributeNode('Heroic Noir'),
    ]),

    // Thriller & Suspense
    AttributeNode('Thriller & Suspense', [
      AttributeNode('Conspiracy Thriller'),
      AttributeNode('Erotic Thriller'),
      AttributeNode('Legal Thriller'),
      AttributeNode('Financial Thriller'),
      AttributeNode('Political Thriller'),
      AttributeNode('Psychological Thriller'),
      AttributeNode('Romantic Suspense'),
      AttributeNode('Techno-thriller'),
    ]),

    // Urban Fiction
    AttributeNode('Urban Fiction'),

    // Western Fiction
    AttributeNode('Western Fiction', [
      AttributeNode('Florida Western'),
      AttributeNode('Northern'),
      AttributeNode('Space Western'),
      AttributeNode('Western Romance'),
      AttributeNode('Weird West'),
    ]),
  ]),

  // ── Nonfiction ───────────────────────────────────────────────────────────
  AttributeNode('Nonfiction', [
    AttributeNode('Academic Writing', [
      AttributeNode('Literature Review'),
      AttributeNode('Monograph'),
      AttributeNode('Research Article'),
      AttributeNode('Scientific Writing'),
      AttributeNode('Technical Report'),
      AttributeNode('Textbook'),
      AttributeNode('Thesis'),
    ]),
    AttributeNode('Bibliography', [
      AttributeNode('Annotated Bibliography'),
    ]),
    AttributeNode('Biography', [
      AttributeNode('Autobiography'),
      AttributeNode('Diary'),
      AttributeNode('Memoir'),
      AttributeNode('Misery Literature'),
      AttributeNode('Slave Narrative', [
        AttributeNode('Contemporary Slave Narrative'),
        AttributeNode('Neo-slave Narrative'),
      ]),
    ]),
    AttributeNode('Cookbook'),
    AttributeNode('Creative Nonfiction', [
      AttributeNode('Personal Narrative'),
    ]),
    AttributeNode('Essay', [
      AttributeNode('Position Paper'),
    ]),
    AttributeNode('Journalistic Writing', [
      AttributeNode('Arts Journalism'),
      AttributeNode('Business Journalism'),
      AttributeNode('Data-driven Journalism'),
      AttributeNode('Entertainment Journalism'),
      AttributeNode('Environmental Journalism'),
      AttributeNode('Fashion Journalism'),
      AttributeNode('Global Journalism'),
      AttributeNode('Medical Journalism'),
      AttributeNode('Political Journalism'),
      AttributeNode('Science Journalism'),
      AttributeNode('Sports Journalism'),
      AttributeNode('Technical Journalism'),
      AttributeNode('Trade Journalism'),
      AttributeNode('Video Game Journalism'),
      AttributeNode('World News'),
    ]),
    AttributeNode('Non-fiction Novel'),
    AttributeNode('Obituary'),
    AttributeNode('Philosophy'),
    AttributeNode('Popular Science'),
    AttributeNode('Reference'),
    AttributeNode('Self-Help'),
    AttributeNode('Travel Writing', [
      AttributeNode('Guide Book'),
      AttributeNode('Travel Blog'),
    ]),
    AttributeNode('True Crime'),
  ]),

  // ── Children's & Young Adult ─────────────────────────────────────────────
  AttributeNode("Children's & Young Adult", [
    AttributeNode("Children's Literature"),
    AttributeNode('New Adult Fiction'),
    AttributeNode('Young Adult Fiction'),
  ]),

  // ── Drama ────────────────────────────────────────────────────────────────
  AttributeNode('Drama', [
    AttributeNode('Comedy Drama'),
    AttributeNode('Melodrama'),
    AttributeNode('Musical'),
    AttributeNode('Tragedy'),
    AttributeNode('Tragicomedy'),
  ]),

  // ── Poetry ───────────────────────────────────────────────────────────────
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
