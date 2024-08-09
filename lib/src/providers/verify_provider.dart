import 'package:flutter/cupertino.dart';
import 'package:icorrect_pc/src/models/auth_models/class_merchant_model.dart';
import 'package:icorrect_pc/src/models/auth_models/student_merchant_model.dart';

class VerifyProvider extends ChangeNotifier {

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
    super.notifyListeners();
  }

  List<ClassModel> _listClass = [];
  List<ClassModel> get listClass => _listClass;

  void setListClass(List<ClassModel> classes) {
    _listClass.addAll(classes);
    notifyListeners();
  }

  ClassModel? _currentClass;
  ClassModel? get currentClass => _currentClass;
  void setCurrentClass(ClassModel currentClass) {
    _currentClass = currentClass;
    notifyListeners();
  }

  List<StudentModel> _currentListStudent = [];
  List<StudentModel> get currentListStudent => _currentListStudent;

  void setCurrentListStudent(List<StudentModel> list) {
    _currentListStudent.addAll(list);
    notifyListeners();
  }

  void clearListClass() {
    _listClass.clear();
    notifyListeners();
  }

  void clearListStudent() {
    _currentListStudent.clear();
    notifyListeners();
  }
}