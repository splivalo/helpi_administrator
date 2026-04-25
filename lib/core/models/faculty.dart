/// Model fakulteta s backend ID-jem, akronimom i punim nazivom.
class Faculty {
  const Faculty({
    required this.id,
    required this.acronym,
    required this.fullName,
  });

  final int id;
  final String acronym;
  final String fullName;

  /// Statička lista svih fakulteta — poredak i nazivi usklađeni s backend seed datom.
  static const List<Faculty> all = [
    Faculty(id: 1, acronym: 'DA', fullName: 'Dramska akademija'),
    Faculty(id: 2, acronym: 'LA', fullName: 'Likovna akademija'),
    Faculty(id: 3, acronym: 'AGR', fullName: 'Agronomski fakultet'),
    Faculty(id: 4, acronym: 'AF', fullName: 'Arhitektonski fakultet'),
    Faculty(
      id: 5,
      acronym: 'ERF',
      fullName: 'Edukacijsko rehabilitacijski fakultet',
    ),
    Faculty(id: 6, acronym: 'EFZG', fullName: 'Ekonomski fakultet'),
    Faculty(id: 7, acronym: 'FER', fullName: 'Elektrotehnika i računarstvo'),
    Faculty(
      id: 8,
      acronym: 'FFRZ',
      fullName: 'Filozofija i religijske znanosti',
    ),
    Faculty(id: 9, acronym: 'FHS', fullName: 'Hrvatski studiji'),
    Faculty(
      id: 10,
      acronym: 'FKIT',
      fullName: 'Kemijsko inženjerstvo i tehnologija',
    ),
    Faculty(id: 11, acronym: 'FOI', fullName: 'Organizacija i informatika'),
    Faculty(id: 12, acronym: 'FPZG', fullName: 'Političke znanosti'),
    Faculty(id: 13, acronym: 'FPZ', fullName: 'Prometne znanosti'),
    Faculty(id: 14, acronym: 'FSB', fullName: 'Strojarstvo i brodogradnja'),
    Faculty(id: 15, acronym: 'FŠDT', fullName: 'Šumarstvo'),
    Faculty(id: 16, acronym: 'FBF', fullName: 'Farmacija i biokemija'),
    Faculty(id: 17, acronym: 'FFZG', fullName: 'Filozofski fakultet'),
    Faculty(id: 18, acronym: 'GEOF', fullName: 'Geodetski fakultet'),
    Faculty(id: 19, acronym: 'GEOTEH', fullName: 'Geotehnički fakultet'),
    Faculty(id: 20, acronym: 'GF', fullName: 'Građevinski fakultet'),
    Faculty(id: 21, acronym: 'GRF', fullName: 'Grafički fakultet'),
    Faculty(id: 22, acronym: 'KBF', fullName: 'Katolički bogoslovni fakultet'),
    Faculty(id: 23, acronym: 'KIF', fullName: 'Kineziološki fakultet'),
    Faculty(id: 24, acronym: 'MEF', fullName: 'Medicinski fakultet'),
    Faculty(id: 25, acronym: 'MET', fullName: 'Metalurški fakultet'),
    Faculty(id: 26, acronym: 'GMUZ', fullName: 'Glazbena akademija'),
    Faculty(id: 27, acronym: 'PRAVO', fullName: 'Pravni fakultet'),
    Faculty(
      id: 28,
      acronym: 'PBF',
      fullName: 'Prehrambeno biotehnološki fakultet',
    ),
    Faculty(id: 29, acronym: 'PMF', fullName: 'Prirodne znanosti'),
    Faculty(id: 30, acronym: 'RGN', fullName: 'Rudarstvo, geologija i nafta'),
    Faculty(id: 31, acronym: 'SFZG', fullName: 'Stomatološki fakultet'),
    Faculty(id: 32, acronym: 'TTF', fullName: 'Tekstilno tehnološki fakultet'),
    Faculty(id: 33, acronym: 'UFZG', fullName: 'Učiteljski fakultet'),
    Faculty(id: 34, acronym: 'VEF', fullName: 'Veterinarski fakultet'),
  ];

  /// Lookup po backend ID-u.
  static Faculty? byId(int id) {
    for (final f in all) {
      if (f.id == id) return f;
    }
    return null;
  }

  /// Lookup po akronimu.
  static Faculty? byAcronym(String acronym) {
    final upper = acronym.toUpperCase();
    for (final f in all) {
      if (f.acronym.toUpperCase() == upper) return f;
    }
    return null;
  }

  /// Lookup po punom nazivu (HR).
  static Faculty? byFullName(String name) {
    final lower = name.toLowerCase().trim();
    for (final f in all) {
      if (f.fullName.toLowerCase() == lower) return f;
    }
    return null;
  }

  @override
  String toString() => '$acronym — $fullName';
}
