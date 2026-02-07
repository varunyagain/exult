/// ECORFAN ISBN Classification category tree.
/// Based on https://www.ecorfan.org/ISBN/Clasificaci%C3%B3n%20de%20ISBN_ECORFAN_En.pdf
/// Follows Dewey Decimal Classification structure.

class CategoryNode {
  final String name;
  final List<CategoryNode> children;

  const CategoryNode(this.name, [this.children = const []]);

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

const List<CategoryNode> ecorfanCategoryTree = [
  // 0 - Generalities
  CategoryNode('Generalities', [
    CategoryNode('Knowledge & Intellectual Life'),
    CategoryNode('Computer Science', [
      CategoryNode('Programming & Software'),
      CategoryNode('Artificial Intelligence'),
    ]),
    CategoryNode('Bibliography & Librarianship'),
    CategoryNode('Encyclopedic Works'),
    CategoryNode('Museology'),
    CategoryNode('Journalism & Publishing'),
    CategoryNode('Manuscripts & Rare Books'),
  ]),

  // 100 - Philosophy and Psychology
  CategoryNode('Philosophy & Psychology', [
    CategoryNode('Metaphysics'),
    CategoryNode('Epistemology'),
    CategoryNode('Parapsychology & Occultism'),
    CategoryNode('Philosophical Schools'),
    CategoryNode('Psychology', [
      CategoryNode('Mental Processes & Intelligence'),
      CategoryNode('Subconscious & Altered States'),
      CategoryNode('Developmental Psychology'),
      CategoryNode('Comparative Psychology'),
      CategoryNode('Applied Psychology'),
    ]),
    CategoryNode('Logic'),
    CategoryNode('Ethics & Moral Philosophy'),
    CategoryNode('Ancient & Medieval Philosophy'),
    CategoryNode('Modern Western Philosophy'),
  ]),

  // 200 - Religion
  CategoryNode('Religion', [
    CategoryNode('Philosophy of Religion'),
    CategoryNode('The Bible'),
    CategoryNode('Christianity & Christian Theology'),
    CategoryNode('Christian Morality'),
    CategoryNode('Christian Orders & Local Church'),
    CategoryNode('History of Christianity'),
    CategoryNode('Comparative Religion'),
    CategoryNode('Buddhism'),
    CategoryNode('Hinduism'),
    CategoryNode('Judaism'),
    CategoryNode('Islam'),
    CategoryNode('Other Religions'),
  ]),

  // 300 - Social Sciences
  CategoryNode('Social Sciences', [
    CategoryNode('Sociology & Anthropology'),
    CategoryNode('Social Interaction & Communication'),
    CategoryNode('Social Groups & Culture'),
    CategoryNode('Statistics'),
    CategoryNode('Political Science', [
      CategoryNode('Political Ideologies'),
      CategoryNode('International Relations'),
      CategoryNode('Legislative Process'),
    ]),
    CategoryNode('Economics', [
      CategoryNode('Labor Economics'),
      CategoryNode('Financial Economics'),
      CategoryNode('Land & Energy Economics'),
      CategoryNode('Public Finance'),
      CategoryNode('Production & Industry'),
      CategoryNode('Macroeconomics'),
    ]),
    CategoryNode('Law', [
      CategoryNode('International Law'),
      CategoryNode('Constitutional & Administrative Law'),
      CategoryNode('Criminal Law'),
      CategoryNode('Private & Commercial Law'),
    ]),
    CategoryNode('Public Administration & Military Science'),
    CategoryNode('Social Problems & Services', [
      CategoryNode('Criminology'),
      CategoryNode('Insurance'),
    ]),
    CategoryNode('Education', [
      CategoryNode('Primary Education'),
      CategoryNode('Secondary Education'),
      CategoryNode('Higher Education'),
    ]),
    CategoryNode('Commerce & Transport', [
      CategoryNode('International Trade'),
      CategoryNode('Telecommunications'),
      CategoryNode('Transportation'),
    ]),
    CategoryNode('Customs, Etiquette & Folklore'),
  ]),

  // 400 - Languages
  CategoryNode('Languages', [
    CategoryNode('Linguistics'),
    CategoryNode('English'),
    CategoryNode('Germanic Languages'),
    CategoryNode('French & Romance Languages'),
    CategoryNode('Italian & Romanian'),
    CategoryNode('Spanish & Portuguese'),
    CategoryNode('Latin & Italic Languages'),
    CategoryNode('Classical Greek'),
    CategoryNode('Other Languages', [
      CategoryNode('Chinese'),
      CategoryNode('Japanese'),
      CategoryNode('Native American Languages'),
    ]),
  ]),

  // 500 - Natural Sciences and Mathematics
  CategoryNode('Natural Sciences & Mathematics', [
    CategoryNode('Mathematics', [
      CategoryNode('Algebra & Number Theory'),
      CategoryNode('Arithmetic'),
      CategoryNode('Topology'),
      CategoryNode('Analysis & Calculus'),
      CategoryNode('Geometry'),
      CategoryNode('Probability & Statistics'),
    ]),
    CategoryNode('Astronomy'),
    CategoryNode('Physics', [
      CategoryNode('Mechanics'),
      CategoryNode('Fluid Mechanics'),
      CategoryNode('Sound & Vibrations'),
      CategoryNode('Light & Optics'),
      CategoryNode('Heat & Thermodynamics'),
      CategoryNode('Electricity & Electronics'),
      CategoryNode('Magnetism'),
      CategoryNode('Atomic & Nuclear Physics'),
    ]),
    CategoryNode('Chemistry', [
      CategoryNode('Physical & Theoretical Chemistry'),
      CategoryNode('Analytical Chemistry'),
      CategoryNode('Inorganic Chemistry'),
      CategoryNode('Organic Chemistry'),
    ]),
    CategoryNode('Earth Sciences', [
      CategoryNode('Geology & Meteorology'),
      CategoryNode('Oceanography'),
      CategoryNode('Climatology'),
      CategoryNode('Mineralogy & Petrology'),
    ]),
    CategoryNode('Paleontology'),
    CategoryNode('Life Sciences & Biology', [
      CategoryNode('Physiology & Anatomy'),
      CategoryNode('Cell Biology'),
      CategoryNode('Biochemistry'),
      CategoryNode('Genetics & Evolution'),
      CategoryNode('Ecology'),
      CategoryNode('Microbiology'),
    ]),
    CategoryNode('Botany'),
    CategoryNode('Zoology'),
  ]),

  // 600 - Technology (Applied Sciences)
  CategoryNode('Technology', [
    CategoryNode('Medical Sciences', [
      CategoryNode('Human Anatomy & Physiology'),
      CategoryNode('Health Promotion & Hygiene'),
      CategoryNode('Forensic & Preventive Medicine'),
      CategoryNode('Pharmacology & Therapeutics'),
      CategoryNode('Diseases & Pathology'),
      CategoryNode('Surgery'),
      CategoryNode('Gynecology & Pediatrics'),
    ]),
    CategoryNode('Engineering', [
      CategoryNode('Civil Engineering'),
      CategoryNode('Electrical & Electronics Engineering'),
      CategoryNode('Mechanical Engineering'),
      CategoryNode('Mining'),
      CategoryNode('Military & Nautical Engineering'),
      CategoryNode('Hydraulic Engineering'),
      CategoryNode('Sanitary & Environmental Engineering'),
      CategoryNode('Astronautics & Robotics'),
    ]),
    CategoryNode('Agriculture', [
      CategoryNode('Soil Science & Cultivation'),
      CategoryNode('Field & Plantation Crops'),
      CategoryNode('Horticulture'),
      CategoryNode('Animal Production & Veterinary'),
      CategoryNode('Forestry'),
      CategoryNode('Fishing & Conservation'),
    ]),
    CategoryNode('Domestic Economy & Food', [
      CategoryNode('Food & Cooking'),
      CategoryNode('Housing & Home Equipment'),
      CategoryNode('Clothing & Personal Care'),
    ]),
    CategoryNode('Management & Business', [
      CategoryNode('Office Services'),
      CategoryNode('Accounting'),
      CategoryNode('General Management'),
      CategoryNode('Marketing & Sales'),
      CategoryNode('Advertising & Public Relations'),
    ]),
    CategoryNode('Chemical Engineering & Biotechnology'),
    CategoryNode('Manufacturing', [
      CategoryNode('Metalwork'),
      CategoryNode('Textiles'),
      CategoryNode('Printing'),
      CategoryNode('Construction'),
    ]),
  ]),

  // 700 - Arts, Fine Arts and Decorative Arts
  CategoryNode('Arts', [
    CategoryNode('Art History & Criticism'),
    CategoryNode('Urban Planning & Landscape'),
    CategoryNode('Architecture'),
    CategoryNode('Sculpture'),
    CategoryNode('Drawing & Graphic Design', [
      CategoryNode('Cartoons & Comics'),
      CategoryNode('Commercial Art & Illustration'),
    ]),
    CategoryNode('Decorative Arts & Crafts'),
    CategoryNode('Painting'),
    CategoryNode('Graphic Arts & Engraving'),
    CategoryNode('Photography & Cinematography'),
    CategoryNode('Music', [
      CategoryNode('Musical Composition & Forms'),
      CategoryNode('Vocal Music & Opera'),
      CategoryNode('Musical Instruments'),
    ]),
    CategoryNode('Performing Arts', [
      CategoryNode('Theater & Drama'),
      CategoryNode('Ballet & Dance'),
      CategoryNode('Radio & Television'),
    ]),
    CategoryNode('Recreation & Games', [
      CategoryNode('Indoor Games & Chess'),
      CategoryNode('Sports & Athletics'),
      CategoryNode('Water & Aerial Sports'),
      CategoryNode('Equestrian Sports'),
    ]),
  ]),

  // 800 - Literature and Rhetoric
  CategoryNode('Literature & Rhetoric', [
    CategoryNode('Philosophy & Theory of Literature'),
    CategoryNode('Rhetoric & Collections'),
    CategoryNode("Children's Literature"),
    CategoryNode('English Literature', [
      CategoryNode('English Poetry'),
      CategoryNode('English Theater'),
      CategoryNode('English Novel'),
      CategoryNode('English Essays'),
    ]),
    CategoryNode('Germanic Literature'),
    CategoryNode('French Literature'),
    CategoryNode('Italian & Romanian Literature'),
    CategoryNode('Spanish & Portuguese Literature', [
      CategoryNode('Spanish Poetry'),
      CategoryNode('Spanish Theater'),
      CategoryNode('Spanish Novel'),
      CategoryNode('Spanish Essays'),
      CategoryNode('Portuguese Literature'),
    ]),
    CategoryNode('Latin Literature'),
    CategoryNode('Greek Literature'),
    CategoryNode('Russian Literature'),
    CategoryNode('Other Literatures'),
  ]),

  // 900 - Geography and History
  CategoryNode('Geography & History', [
    CategoryNode('Philosophy & Theory of History'),
    CategoryNode('Geography & Travel'),
    CategoryNode('Maps & Atlases'),
    CategoryNode('Biography & Genealogy'),
    CategoryNode('Ancient History'),
    CategoryNode('European History', [
      CategoryNode('British History'),
      CategoryNode('French History'),
      CategoryNode('German History'),
      CategoryNode('Italian History'),
      CategoryNode('Eastern European History'),
    ]),
    CategoryNode('Asian History'),
    CategoryNode('African History'),
    CategoryNode('North American History', [
      CategoryNode('United States History'),
      CategoryNode('Mexican History'),
      CategoryNode('Central American History'),
      CategoryNode('Caribbean History'),
    ]),
    CategoryNode('South American History'),
  ]),
];

/// Flat list of ALL category names from the tree (for backwards compatibility
/// and for populating category pickers in forms).
List<String> get allCategoryNames {
  List<String> result = [];
  void collect(List<CategoryNode> nodes) {
    for (final node in nodes) {
      result.add(node.name);
      collect(node.children);
    }
  }
  collect(ecorfanCategoryTree);
  return result;
}
