enum Gender { male, female, neutral }

class Word {
  final int id;
  final String gender;
  final String root;
  final String level; // A1, A2, ...

  Word({required this.id, required this.gender, required this.root, required this.level});
  @override
  String toString() {
    return "Word id: $id, gender: $gender, root: $root";
  }
  //Word.fromMap(Map<String, dynamic> map) : id = map["pk"], gender = map["gender"], root = map["root"], level = map["level"];
}