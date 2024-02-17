import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _db;
  late String databasesPath;
  late String path;
  late bool exists;
  DatabaseHelper._createInstance();
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  DatabaseHelper._privateConstructure();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructure();
  Future<Database> get database async {
    if (_db == null) {
      _db = await initDb();
    }
    return _db!;
  }

  Future<Database> initDb() async {
    databasesPath = await getDatabasesPath();
    path = join(databasesPath, "database/drive.db");
    exists = await databaseExists(path);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data =
          await rootBundle.load(join("assets", "database/drive.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(
        bytes,
        flush: true,
      );
    } else {}
    var db = await openDatabase(
      path,
      version: 5,
    );
    return db;
  }

  Future onCreate() async {
    Database db = await this.database;
    await db.rawQuery(
        "CREATE TABLE chapter(id INTEGER ,name TEXT NOT NULL, details TEXT NOT NULL, totalQuestions TEXT NOT NULL, correctAnswered TEXT NOT NULL);");
    await db.rawQuery(
        "CREATE TABLE questions(questionId INTEGER ,chapterId INTEGER ,times INTEGER, correct INTEGER, lastAnsweredCorrect BOOLEAN default false, isFavorite BOOLEAN default false, annex TEXT NOT NULL, quetionsClass TEXT NOT NULL, points INTEGER, solution TEXT NOT NULL, imageBelow TEXT NOT NULL, title TEXT NOT NULL, subitle TEXT NOT NULL, answer1 TEXT NOT NULL, answer2 TEXT NOT NULL, answer3 TEXT NOT NULL, hasVideo BOOLEAN default false, hasPicture BOOLEAN default false, type INTEGER, isActive BOOLEAN default false, tip1 TEXT NOT NULL, tip2 TEXT NOT NULL, current BOOLEAN default false);");
    await db.rawQuery(
        "CREATE INDEX IX_Questions_ChapterId ON questions (chapterId)");
  }

  Future deleteTable() async {
    Database db = await this.database;
    await db.rawQuery("DROP TABLE chapter");
    await db.rawQuery("DROP TABLE questions");
  }

  Future insertChapter(response) async {
    Database db = await this.database;
    Batch batch = db.batch();
    for (int i = 0; i < response['data'].length; i++) {
      var data = response['data'][i];
      data['totalQuestions'] = data['questions'].length;
      data['correctAnswered'] = (data['questions'] as List)
          .where((e) => e['correct'] > 0)
          .toList()
          .length;
      batch.insert('chapter', {
        'id': '${data['id']}',
        'name': '${data['name']}',
        'details': '${data['details']}',
        'totalQuestions': '${data['totalQuestions']}',
        'correctAnswered': '${data['correctAnswered']}',
      });
      await insertQuestions(data);
    }
    await batch.commit(noResult: true);
  }

  Future insertQuestions(data) async {
    Database db = await this.database;
    Batch batch = db.batch();
    for (int j = 0; j < data['questions'].length; j++) {
      final question = data['questions'][j];
      batch.insert('questions', {
        'questionId': question['questionId'],
        'chapterId': data['id'],
        'times': question['times'],
        'correct': question['correct'],
        'lastAnsweredCorrect': question['lastAnsweredCorrect'],
        'isFavorite': question['isFavorite'],
        'annex': question['annex'],
        'quetionsClass': question['class'],
        'points': question['points'],
        'solution': question['solution'],
        'imageBelow': question['imageBelow'],
        'title': question['title'],
        'subitle': question['subitle'] ?? '',
        'answer1': question['answer1'],
        'answer2': question['answer2'] ?? '',
        'answer3': question['answer3'] ?? '',
        'hasVideo': question['hasVideo'],
        'hasPicture': question['hasPicture'],
        'type': question['type'],
        'isActive': question['isActive'],
        'tip1': question['tip1'],
        'tip2': question['tip2'],
        'current': 'false',
      });
    }
    await batch.commit(noResult: true);
  }

  Future setFavorite(String questionId, bool isFavorite) async {
    Database db = await this.database;
    await db.rawUpdate(
        "UPDATE questions SET isFavorite = '$isFavorite' WHERE  questionId = '$questionId'");
  }

  Future<List> getQuestions(String chapterId) async {
    Database db = await database;
    List<Map> saveQuestions = await db
        .rawQuery("SELECT * FROM questions WHERE  chapterId == '$chapterId'");
    return saveQuestions;
  }

  Future<Map<String, List>> validQuestions(String chapterId) async {
    Database db = await database;
    List<Map> questions;
    List<Map> previousQuestion = [];
    questions = await db.rawQuery(
        "SELECT * FROM questions WHERE  chapterId == '$chapterId' AND times == 0");
    if (questions.length != 0) {
      previousQuestion = await db.rawQuery(
          "SELECT * FROM questions WHERE  chapterId == '$chapterId' AND times != 0");
    }

    if (questions.length == 0) {
      questions = await db.rawQuery(
          "SELECT * FROM questions WHERE  chapterId == '$chapterId' AND correct == 0");
      if (questions.length != 0) {
        previousQuestion = await db.rawQuery(
            "SELECT * FROM questions WHERE  chapterId == '$chapterId' AND correct != 0");
      }
    }
    List<Map> totalQuestion = await db
        .rawQuery("SELECT * FROM questions WHERE  chapterId == '$chapterId'");

    if (questions.length == 0) {
      previousQuestion = [];
      for (int i = 0; i < totalQuestion.length; i++) {
        if (totalQuestion[i]['current'] == 'true') {
          questions = totalQuestion.sublist(i, totalQuestion.length);
          break;
        } else {
          previousQuestion.add(totalQuestion[i]);
        }
      }
    }
    if (previousQuestion.length == totalQuestion.length) {
      questions = previousQuestion;
      previousQuestion = [];
    }
    return {
      'previousQuetions': previousQuestion,
      'questions': questions,
    };
  }

  Future questionUpdate(String questionId, bool isCorrect,
      String nextQuestionId, String chapterId) async {
    Database db = await database;
    if (isCorrect) {
      await db.rawQuery(
          "UPDATE questions SET correct = correct + 1 , times = times + 1, lastAnsweredCorrect = '$isCorrect', current = 'false'  WHERE questionId == '$questionId'");
    } else {
      await db.rawQuery(
          "UPDATE questions SET times = times + 1, lastAnsweredCorrect = '$isCorrect', current = 'false' WHERE questionId == '$questionId'");
    }
    if (nextQuestionId != '')
      await db.rawQuery(
          "UPDATE questions SET current = 'true' WHERE questionId == '$nextQuestionId'");
    List correctQuestions = await db.rawQuery(
        "SELECT * FROM questions WHERE chapterId == '$chapterId' AND correct > 0 ");
    await db.rawQuery(
        "UPDATE chapter SET correctAnswered = '${correctQuestions.length}' WHERE id = '$chapterId'");
  }

  Future<List> getChapter() async {
    final Database db = await database;
    final List<Map<String, dynamic>> chapter = await db.query("chapter");
    return chapter;
  }

  Future<List> mistakes(
    String chapterId,
  ) async {
    final Database db = await database;
    final List<Map<String, dynamic>> data = await db.rawQuery(
        "SELECT * FROM questions WHERE chapterId == '$chapterId' AND correct == 0 AND times > 0");
    return data;
  }

  Future<List> savedQuestions() async {
    final Database db = await database;
    final List<Map<String, dynamic>> data = await db.rawQuery(
        "SELECT * FROM questions WHERE isFavorite == '${true}' OR isFavorite == '1'");
    return data;
  }

  Future<List> getAllQuestions() async {
    final Database db = await database;
    final List<Map<String, dynamic>> data =
        await db.rawQuery("SELECT * FROM questions");
    return data;
  }

  Future<List> getCorrectAnsweredQuestions() async {
    final Database db = await database;
    List<Map<String, dynamic>> questions =
        await db.rawQuery("SELECT * FROM questions WHERE correct > 0");
    return questions;
  }

  Future<bool> correctQuestionOfChapter(String chapterId) async {
    final Database db = await database;
    List<Map<String, dynamic>> questions = await db.rawQuery(
        "SELECT * FROM questions WHERE chapterId == '$chapterId' AND correct == 0 ");
    if (questions.isEmpty) {
      List<Map<String, dynamic>> currentQuestions = await db.rawQuery(
          "SELECT * FROM questions WHERE chapterId == '$chapterId' AND current == 'true' ");
      if (currentQuestions.isEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> correctAllChapter() async {
    final Database db = await database;
    List<Map<String, dynamic>> questions =
        await db.rawQuery("SELECT * FROM questions WHERE correct == 0 ");
    if (questions.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<RxList> getQuestionsWithoutAssets() async {
    final Database db = await database;
    List<Map<String, dynamic>> data = await db.rawQuery(
        "SELECT * FROM questions WHERE hasVideo != 1 AND hasPicture != 1 ");
    return data.obs;
  }
}
