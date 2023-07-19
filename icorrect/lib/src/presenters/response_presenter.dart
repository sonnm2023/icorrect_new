import 'dart:convert';

import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/models/my_test_models/result_response_model.dart';
import 'package:icorrect/src/models/my_test_models/skill_problem_model.dart';

abstract class ResponseContracts {
  void getSuccessResponse(ResultResponseModel responseModel);
  void getErrorResponse(String message);
}

class ResponsePresenter {
  final ResponseContracts? _view;
  MyTestRepository? _repository;

  ResponsePresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  void getResponse(String orderId) async {
    assert(_view != null && _repository != null);

    _repository!.getResponse(orderId).then((value) {
      Map<String, dynamic> dataMap = jsonDecode(value) ?? {};
      if (dataMap.isNotEmpty) {
        ResultResponseModel responseModel =
            ResultResponseModel.fromJson(dataMap);
        _view!.getSuccessResponse(responseModel);
      } else {
        _view!.getErrorResponse('Loading result response fail !');
      }
    }).catchError((onError) =>
        _view!.getErrorResponse("Can't load response :${onError.toString()}"));
  }
}
