class QuestionsModel {
  String? questionId;
  String? chapterId;
  int? times;
  int? correct;
  bool? lastAnsweredCorrect;
  bool? isFavorite;
  String? annex;
  String? questionClass;
  int? points;
  String? solution;
  String? imageBelow;
  String? title;
  String? subitle;
  String? answer1;
  String? answer2;
  String? answer3;
  bool? hasVideo;
  bool? hasPicture;
  int? type;
  bool? isActive;
  String? tip1;
  String? tip2;
  bool? current;
  QuestionsModel({
    this.questionId,
    this.chapterId,
    this.times,
    this.correct,
    this.lastAnsweredCorrect,
    this.isFavorite,
    this.annex,
    this.questionClass,
    this.points,
    this.solution,
    this.imageBelow,
    this.title,
    this.subitle,
    this.answer1,
    this.answer2,
    this.answer3,
    this.hasVideo,
    this.hasPicture,
    this.type,
    this.isActive,
    this.tip1,
    this.tip2,
    this.current,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'chapterId': chapterId,
      'times': times,
      'correct': correct,
      'lastAnsweredCorrect': lastAnsweredCorrect,
      'isFavorite': isFavorite,
      'annex': annex,
      'questionClass': questionClass,
      'points': points,
      'solution': solution,
      'imageBelow': imageBelow,
      'title': title,
      'subitle': subitle,
      'answer1': answer1,
      'answer2': answer2,
      'answer3': answer3,
      'hasVideo': hasVideo,
      'hasPicture': hasPicture,
      'type': type,
      'isActive': isActive,
      'tip1': tip1,
      'tip2': tip2,
      'current': current,
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
