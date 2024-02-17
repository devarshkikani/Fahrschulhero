class ChapterModel {
  String? id;
  String? name;
  String? details;
  int? totalQuestions;
  int? correctAnswered;
  ChapterModel(
      {this.id,
      this.name,
      this.details,
      this.totalQuestions,
      this.correctAnswered});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'totalQuestions': totalQuestions,
      'correctAnswered': correctAnswered,
    };
  }
/*
  Databasedata.name(Map<String, dynamic> map) {
    this.id = map['id'];
    this.saveResult = map['saveResult'];
    this.date = map['date'];
    this.isFavourite = map['isFavourite'];
  }*/
}
