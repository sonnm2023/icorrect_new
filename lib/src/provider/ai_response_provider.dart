import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect/src/models/module_lession_models/ai_response_model.dart';

class AiResponseProvider extends ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  AiResponseModel? _aiResponseModel;
  AiResponseModel? get aiResponseModel => _aiResponseModel;

  List<Word> _listWord = [];
  List<Word> get listWord => _listWord;

  void setAiResponseModel(AiResponseModel model) {
    _aiResponseModel = model;
    _listWord = model.data.words;
    if (!isDisposed) {
      notifyListeners();
    }
  }


  bool _isMissionFinished = false;
  bool get isMissionFinished => _isMissionFinished;

  void setIsMissionFinished(bool isFinish) {
    _isMissionFinished = isFinish;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}