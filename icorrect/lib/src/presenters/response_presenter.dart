import 'dart:convert';

import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/models/my_test_models/result_response_model.dart';

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
      print(dataMap.toString());
      if (dataMap.isNotEmpty) {
        ResultResponseModel responseModel =
            ResultResponseModel.fromJson(dataMap);
        _view!.getSuccessResponse(responseModel);
      } else {
        _view!.getErrorResponse('Loading result response fail !');
      }
    }).catchError((onError) =>
        // ignore: invalid_return_type_for_catch_error
        _view!.getErrorResponse("Can't load response :${onError.toString()}"));
  }
}
