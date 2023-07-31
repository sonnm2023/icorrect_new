import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/repositories/homework_repository.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';

class Injector {
  static final Injector _singleton = Injector._internal();
  factory Injector() {
    return _singleton;
  }
  Injector._internal();
  AuthRepository getAuthRepository() => AuthRepositoryImpl();
  HomeWorkRepository getHomeWorkRepository() => HomeWorkRepositoryImpl();
  SimulatorTestRepository getTestRepository() => SimulatorTestRepositoryImpl();
  MyTestRepository getMyTestRepository() => MyTestImpl();
}