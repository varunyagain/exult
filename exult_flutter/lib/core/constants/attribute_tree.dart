/// ECORFAN ISBN Classification category tree.
/// Based on https://www.ecorfan.org/ISBN/Clasificaci%C3%B3n%20de%20ISBN_ECORFAN_En.pdf
/// Follows Dewey Decimal Classification structure.

class AttributeNode {
  final String name;
  final List<AttributeNode> children;

  const AttributeNode(this.name, [this.children = const []]);

  /// Returns all leaf-level category names in this subtree (including self if leaf).
  List<String> get allLeafNames {
    if (children.isEmpty) return [name];
    return children.expand((c) => c.allLeafNames).toList();
  }

  /// Returns all category names in this subtree (including self and all descendants).
  List<String> get allNames {
    return [name, ...children.expand((c) => c.allNames)];
  }
}

const List<AttributeNode> ecorfanCategoryTree = [
  // 0 - Generalities
  AttributeNode('Generalities', [
    AttributeNode('Knowledge & Intellectual Life'),
    AttributeNode('Computer Science', [
      AttributeNode('Programming & Software'),
      AttributeNode('Artificial Intelligence'),
    ]),
    AttributeNode('Bibliography & Librarianship'),
    AttributeNode('Encyclopedic Works'),
    AttributeNode('Museology'),
    AttributeNode('Journalism & Publishing'),
    AttributeNode('Manuscripts & Rare Books'),
  ]),

  // 100 - Philosophy and Psychology
  AttributeNode('Philosophy & Psychology', [
    AttributeNode('Metaphysics'),
    AttributeNode('Epistemology'),
    AttributeNode('Parapsychology & Occultism'),
    AttributeNode('Philosophical Schools'),
    AttributeNode('Psychology', [
      AttributeNode('Mental Processes & Intelligence'),
      AttributeNode('Subconscious & Altered States'),
      AttributeNode('Developmental Psychology'),
      AttributeNode('Comparative Psychology'),
      AttributeNode('Applied Psychology'),
    ]),
    AttributeNode('Logic'),
    AttributeNode('Ethics & Moral Philosophy'),
    AttributeNode('Ancient & Medieval Philosophy'),
    AttributeNode('Modern Western Philosophy'),
  ]),

  // 200 - Religion
  AttributeNode('Religion', [
    AttributeNode('Philosophy of Religion'),
    AttributeNode('The Bible'),
    AttributeNode('Christianity & Christian Theology'),
    AttributeNode('Christian Morality'),
    AttributeNode('Christian Orders & Local Church'),
    AttributeNode('History of Christianity'),
    AttributeNode('Comparative Religion'),
    AttributeNode('Buddhism'),
    AttributeNode('Hinduism'),
    AttributeNode('Judaism'),
    AttributeNode('Islam'),
    AttributeNode('Other Religions'),
  ]),

  // 300 - Social Sciences
  AttributeNode('Social Sciences', [
    AttributeNode('Sociology & Anthropology'),
    AttributeNode('Social Interaction & Communication'),
    AttributeNode('Social Groups & Culture'),
    AttributeNode('Statistics'),
    AttributeNode('Political Science', [
      AttributeNode('Political Ideologies'),
      AttributeNode('International Relations'),
      AttributeNode('Legislative Process'),
    ]),
    AttributeNode('Economics', [
      AttributeNode('Labor Economics'),
      AttributeNode('Financial Economics'),
      AttributeNode('Land & Energy Economics'),
      AttributeNode('Public Finance'),
      AttributeNode('Production & Industry'),
      AttributeNode('Macroeconomics'),
    ]),
    AttributeNode('Law', [
      AttributeNode('International Law'),
      AttributeNode('Constitutional & Administrative Law'),
      AttributeNode('Criminal Law'),
      AttributeNode('Private & Commercial Law'),
    ]),
    AttributeNode('Public Administration & Military Science'),
    AttributeNode('Social Problems & Services', [
      AttributeNode('Criminology'),
      AttributeNode('Insurance'),
    ]),
    AttributeNode('Education', [
      AttributeNode('Primary Education'),
      AttributeNode('Secondary Education'),
      AttributeNode('Higher Education'),
    ]),
    AttributeNode('Commerce & Transport', [
      AttributeNode('International Trade'),
      AttributeNode('Telecommunications'),
      AttributeNode('Transportation'),
    ]),
    AttributeNode('Customs, Etiquette & Folklore'),
  ]),

  // 400 - Languages
  AttributeNode('Languages', [
    AttributeNode('Linguistics'),
    AttributeNode('English'),
    AttributeNode('Germanic Languages'),
    AttributeNode('French & Romance Languages'),
    AttributeNode('Italian & Romanian'),
    AttributeNode('Spanish & Portuguese'),
    AttributeNode('Latin & Italic Languages'),
    AttributeNode('Classical Greek'),
    AttributeNode('Other Languages', [
      AttributeNode('Chinese'),
      AttributeNode('Japanese'),
      AttributeNode('Native American Languages'),
    ]),
  ]),

  // 500 - Natural Sciences and Mathematics
  AttributeNode('Natural Sciences & Mathematics', [
    AttributeNode('Mathematics', [
      AttributeNode('Algebra & Number Theory'),
      AttributeNode('Arithmetic'),
      AttributeNode('Topology'),
      AttributeNode('Analysis & Calculus'),
      AttributeNode('Geometry'),
      AttributeNode('Probability & Statistics'),
    ]),
    AttributeNode('Astronomy'),
    AttributeNode('Physics', [
      AttributeNode('Mechanics'),
      AttributeNode('Fluid Mechanics'),
      AttributeNode('Sound & Vibrations'),
      AttributeNode('Light & Optics'),
      AttributeNode('Heat & Thermodynamics'),
      AttributeNode('Electricity & Electronics'),
      AttributeNode('Magnetism'),
      AttributeNode('Atomic & Nuclear Physics'),
    ]),
    AttributeNode('Chemistry', [
      AttributeNode('Physical & Theoretical Chemistry'),
      AttributeNode('Analytical Chemistry'),
      AttributeNode('Inorganic Chemistry'),
      AttributeNode('Organic Chemistry'),
    ]),
    AttributeNode('Earth Sciences', [
      AttributeNode('Geology & Meteorology'),
      AttributeNode('Oceanography'),
      AttributeNode('Climatology'),
      AttributeNode('Mineralogy & Petrology'),
    ]),
    AttributeNode('Paleontology'),
    AttributeNode('Life Sciences & Biology', [
      AttributeNode('Physiology & Anatomy'),
      AttributeNode('Cell Biology'),
      AttributeNode('Biochemistry'),
      AttributeNode('Genetics & Evolution'),
      AttributeNode('Ecology'),
      AttributeNode('Microbiology'),
    ]),
    AttributeNode('Botany'),
    AttributeNode('Zoology'),
  ]),

  // 600 - Technology (Applied Sciences)
  AttributeNode('Technology', [
    AttributeNode('Medical Sciences', [
      AttributeNode('Human Anatomy & Physiology'),
      AttributeNode('Health Promotion & Hygiene'),
      AttributeNode('Forensic & Preventive Medicine'),
      AttributeNode('Pharmacology & Therapeutics'),
      AttributeNode('Diseases & Pathology'),
      AttributeNode('Surgery'),
      AttributeNode('Gynecology & Pediatrics'),
    ]),
    AttributeNode('Engineering', [
      AttributeNode('Civil Engineering'),
      AttributeNode('Electrical & Electronics Engineering'),
      AttributeNode('Mechanical Engineering'),
      AttributeNode('Mining'),
      AttributeNode('Military & Nautical Engineering'),
      AttributeNode('Hydraulic Engineering'),
      AttributeNode('Sanitary & Environmental Engineering'),
      AttributeNode('Astronautics & Robotics'),
    ]),
    AttributeNode('Agriculture', [
      AttributeNode('Soil Science & Cultivation'),
      AttributeNode('Field & Plantation Crops'),
      AttributeNode('Horticulture'),
      AttributeNode('Animal Production & Veterinary'),
      AttributeNode('Forestry'),
      AttributeNode('Fishing & Conservation'),
    ]),
    AttributeNode('Domestic Economy & Food', [
      AttributeNode('Food & Cooking'),
      AttributeNode('Housing & Home Equipment'),
      AttributeNode('Clothing & Personal Care'),
    ]),
    AttributeNode('Management & Business', [
      AttributeNode('Office Services'),
      AttributeNode('Accounting'),
      AttributeNode('General Management'),
      AttributeNode('Marketing & Sales'),
      AttributeNode('Advertising & Public Relations'),
    ]),
    AttributeNode('Chemical Engineering & Biotechnology'),
    AttributeNode('Manufacturing', [
      AttributeNode('Metalwork'),
      AttributeNode('Textiles'),
      AttributeNode('Printing'),
      AttributeNode('Construction'),
    ]),
  ]),

  // 700 - Arts, Fine Arts and Decorative Arts
  AttributeNode('Arts', [
    AttributeNode('Art History & Criticism'),
    AttributeNode('Urban Planning & Landscape'),
    AttributeNode('Architecture'),
    AttributeNode('Sculpture'),
    AttributeNode('Drawing & Graphic Design', [
      AttributeNode('Cartoons & Comics'),
      AttributeNode('Commercial Art & Illustration'),
    ]),
    AttributeNode('Decorative Arts & Crafts'),
    AttributeNode('Painting'),
    AttributeNode('Graphic Arts & Engraving'),
    AttributeNode('Photography & Cinematography'),
    AttributeNode('Music', [
      AttributeNode('Musical Composition & Forms'),
      AttributeNode('Vocal Music & Opera'),
      AttributeNode('Musical Instruments'),
    ]),
    AttributeNode('Performing Arts', [
      AttributeNode('Theater & Drama'),
      AttributeNode('Ballet & Dance'),
      AttributeNode('Radio & Television'),
    ]),
    AttributeNode('Recreation & Games', [
      AttributeNode('Indoor Games & Chess'),
      AttributeNode('Sports & Athletics'),
      AttributeNode('Water & Aerial Sports'),
      AttributeNode('Equestrian Sports'),
    ]),
  ]),

  // 800 - Literature and Rhetoric
  AttributeNode('Literature & Rhetoric', [
    AttributeNode('Philosophy & Theory of Literature'),
    AttributeNode('Rhetoric & Collections'),
    AttributeNode("Children's Literature"),
    AttributeNode('English Literature', [
      AttributeNode('English Poetry'),
      AttributeNode('English Theater'),
      AttributeNode('English Novel'),
      AttributeNode('English Essays'),
    ]),
    AttributeNode('Germanic Literature'),
    AttributeNode('French Literature'),
    AttributeNode('Italian & Romanian Literature'),
    AttributeNode('Spanish & Portuguese Literature', [
      AttributeNode('Spanish Poetry'),
      AttributeNode('Spanish Theater'),
      AttributeNode('Spanish Novel'),
      AttributeNode('Spanish Essays'),
      AttributeNode('Portuguese Literature'),
    ]),
    AttributeNode('Latin Literature'),
    AttributeNode('Greek Literature'),
    AttributeNode('Russian Literature'),
    AttributeNode('Other Literatures'),
  ]),

  // 900 - Geography and History
  AttributeNode('Geography & History', [
    AttributeNode('Philosophy & Theory of History'),
    AttributeNode('Geography & Travel'),
    AttributeNode('Maps & Atlases'),
    AttributeNode('Biography & Genealogy'),
    AttributeNode('Ancient History'),
    AttributeNode('European History', [
      AttributeNode('British History'),
      AttributeNode('French History'),
      AttributeNode('German History'),
      AttributeNode('Italian History'),
      AttributeNode('Eastern European History'),
    ]),
    AttributeNode('Asian History'),
    AttributeNode('African History'),
    AttributeNode('North American History', [
      AttributeNode('United States History'),
      AttributeNode('Mexican History'),
      AttributeNode('Central American History'),
      AttributeNode('Caribbean History'),
    ]),
    AttributeNode('South American History'),
  ]),
];

/// Flat list of ALL category names from the tree (for backwards compatibility
/// and for populating category pickers in forms).
List<String> get allCategoryNames {
  List<String> result = [];
  void collect(List<AttributeNode> nodes) {
    for (final node in nodes) {
      result.add(node.name);
      collect(node.children);
    }
  }
  collect(ecorfanCategoryTree);
  return result;
}
