enum Gender { male, female, neutral }

class Word {
  final int id;
  final String gender;
  final String root;

  const Word({required this.id, required this.gender, required this.root});
  @override
  String toString() {
    return "Word id: $id, gender: $gender, root: $root";
  }
}