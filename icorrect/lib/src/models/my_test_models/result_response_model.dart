

import 'package:icorrect/src/models/my_test_models/skill_problem_model.dart';

class ResultResponseModel {
  var _id;
  var _orderId;
  var _overallScore;
  var _fluency;
  var _lexicalResource;
  var _grammatical;
  var _pronunciation;
  var _overallComment;
  var _staffCreate;
  var _staffUpdate;
  var _updatedAt;
  var _createdAt;
  var _deletedAt;
  var _status;
  List<SkillProblem>? _fluencyProblem;
  List<SkillProblem>? _lexicalResourceProblem;
  List<SkillProblem>? _grammaticalProblem;
  List<SkillProblem>? _pronunciationProblem;
  var _orderType;

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

  get id => this._id ??'';

  set id(var value) => this._id = value;

  get orderId => this._orderId ??'';

  set orderId(value) => this._orderId = value;

  get overallScore => this._overallScore ??'';

  set overallScore(value) => this._overallScore = value;

  get fluency => this._fluency ??'';

  set fluency(value) => this._fluency = value;

  get lexicalResource => this._lexicalResource ??'';

  set lexicalResource(value) => this._lexicalResource = value;

  get grammatical => this._grammatical ??'';

  set grammatical(value) => this._grammatical = value;

  get pronunciation => this._pronunciation ??'';

  set pronunciation(value) => this._pronunciation = value;

  get overallComment => this._overallComment ??'';

  set overallComment(value) => this._overallComment = value;

  get staffCreate => this._staffCreate ??'';

  set staffCreate(value) => this._staffCreate = value;

  get staffUpdate => this._staffUpdate ??'';

  set staffUpdate(value) => this._staffUpdate = value;

  get updatedAt => this._updatedAt ??'';

  set updatedAt(value) => this._updatedAt = value;

  get createdAt => this._createdAt ??'';

  set createdAt(value) => this._createdAt = value;

  get deletedAt => this._deletedAt ??'';

  set deletedAt(value) => this._deletedAt = value;

  get status => this._status ??'';

  set status(value) => this._status = value;

  List<SkillProblem> get fluencyProblem => this._fluencyProblem ??[];

  set fluencyProblem(value) => this._fluencyProblem = value;

  List<SkillProblem> get lexicalResourceProblem =>
      this._lexicalResourceProblem ??[];

  set lexicalResourceProblem(value) => this._lexicalResourceProblem = value;

  List<SkillProblem> get grammaticalProblem => this._grammaticalProblem ??[];

  set grammaticalProblem(value) => this._grammaticalProblem = value;

  List<SkillProblem> get pronunciationProblem => this._pronunciationProblem ??[];

  set pronunciationProblem(value) => this._pronunciationProblem = value;

  get orderType => this._orderType ??'';

  set orderType(value) => this._orderType = value;
}