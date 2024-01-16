import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/practice_repository.dart';

abstract class MyPracticeDetailViewContract {}

class MyPracticeDetailPresenter {
  final MyPracticeDetailViewContract? _view;
  // PracticeRepository? _practiceRepository;

  MyPracticeDetailPresenter(this._view) {
    // _practiceRepository = Injector().getPracticeRepository();
  }
}
