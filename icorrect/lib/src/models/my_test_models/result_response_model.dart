import 'package:icorrect/src/models/my_test_models/skill_problem_model.dart';

class ResultResponseModel {
  int? _id;
  int? _orderId;
  String? _overallScore;
  String? _fluency;
  String? _lexicalResource;
  String? _grammatical;
  String? _pronunciation;
  String? _overallComment;
  int? _staffCreate;
  int? _staffUpdate;
  String? _updatedAt;
  String? _createdAt;
  String? _deletedAt;
  int? _status;
  List<SkillProblem>? _fluencyProblem = [];
  List<SkillProblem>? _lexicalResourceProblem = [];
  List<SkillProblem>? _grammaticalProblem = [];
  List<SkillProblem>? _pronunciationProblem = [];
  int? _orderType;

  ResultResponseModel(
      [this._id,
      this._orderId,
      this._overallScore,
      this._fluency,
      this._lexicalResource,
      this._grammatical,
      this._pronunciation,
      this._overallComment,
      this._staffCreate,
      this._staffUpdate,
      this._updatedAt,
      this._createdAt,
      this._deletedAt,
      this._status,
      this._fluencyProblem,
      this._lexicalResourceProblem,
      this._grammaticalProblem,
      this._pronunciationProblem,
      this._orderType]);

  int? get id => this._id ?? 0;

  set id(int? value) => this._id = value;

  get orderId => this._orderId ?? 0;

  set orderId(value) => this._orderId = value;

  get overallScore => this._overallScore ?? '0.0';

  set overallScore(value) => this._overallScore = value;

  get fluency => this._fluency ?? '0.0';

  set fluency(value) => this._fluency = value;

  get lexicalResource => this._lexicalResource ?? '0.0';

  set lexicalResource(value) => this._lexicalResource = value;

  get grammatical => this._grammatical ?? '0.0';

  set grammatical(value) => this._grammatical = value;

  get pronunciation => this._pronunciation ?? '0.0';

  set pronunciation(value) => this._pronunciation = value;

  get overallComment =>
      this._overallComment ?? 'Nothing overall comment in here';

  set overallComment(value) => this._overallComment = value;

  get staffCreate => this._staffCreate ?? 0;

  set staffCreate(value) => this._staffCreate = value;

  get staffUpdate => this._staffUpdate ?? 0;

  set staffUpdate(value) => this._staffUpdate = value;

  get updatedAt => this._updatedAt ?? '';

  set updatedAt(value) => this._updatedAt = value;

  get createdAt => this._createdAt ?? '';

  set createdAt(value) => this._createdAt = value;

  get deletedAt => this._deletedAt ?? '';

  set deletedAt(value) => this._deletedAt = value;

  get status => this._status ?? 0;

  set status(value) => this._status = value;

  get fluencyProblem => this._fluencyProblem ?? [];

  set fluencyProblem(value) => this._fluencyProblem = value;

  get lexicalResourceProblem => this._lexicalResourceProblem ?? [];

  set lexicalResourceProblem(value) => this._lexicalResourceProblem = value;

  get grammaticalProblem => this._grammaticalProblem ?? [];

  set grammaticalProblem(value) => this._grammaticalProblem = value;

  get pronunciationProblem => this._pronunciationProblem ?? [];

  set pronunciationProblem(value) => this._pronunciationProblem = value;

  get orderType => this._orderType ?? 0;

  set orderType(value) => this._orderType = value;

  ResultResponseModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'] ?? 0;
    _orderId = json['order_id'] ?? 0;
    _overallScore = json['overall_score'] ?? '0.0';
    _fluency = json['fluency'] ?? '0.0';
    _lexicalResource = json['lexical_resource'] ?? '0.0';
    _grammatical = json['grammatical'] ?? '0.0';
    _pronunciation = json['pronunciation'] ?? '0.0';
    _overallComment = json['overall_comment'] ?? '';
    _staffCreate = json['staff_created'] ?? 0;
    _staffUpdate = json['staff_updated'] ?? 0;
    _updatedAt = json['updated_at'] ?? '';
    _createdAt = json['created_at'] ?? '';
    _deletedAt = json['deleted_at'] ?? '';
    _status = json['status'] ?? 0;
    _orderType = json['order_type'] ?? 0;

    List<dynamic> fluencyProblems = json['fluency_problem'] ?? [];
    for (int i = 0; i < fluencyProblems.length; i++) {
      _fluencyProblem!.add(SkillProblem.fromJson(fluencyProblems[i]));
    }

    List<dynamic> lexicalProblems = json['lexical_resource_problem'] ?? [];
    for (int i = 0; i < lexicalProblems.length; i++) {
      _lexicalResourceProblem!.add(SkillProblem.fromJson(lexicalProblems[i]));
    }

    List<dynamic> grammaticalProblems = json['grammatical_problem'] ?? [];
    for (int i = 0; i < grammaticalProblems.length; i++) {
      _grammaticalProblem!.add(SkillProblem.fromJson(grammaticalProblems[i]));
    }
    List<dynamic> pronunciationProblems = json['pronunciation_problem'] ?? [];
    for (int i = 0; i < pronunciationProblems.length; i++) {
      _pronunciationProblem!
          .add(SkillProblem.fromJson(pronunciationProblems[i]));
    }
  }
}
