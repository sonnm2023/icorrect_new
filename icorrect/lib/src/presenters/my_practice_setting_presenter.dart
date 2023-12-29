abstract class MyPracticeSettingViewContract {
  // void onGetListHomeworkComplete(List<ActivitiesModel> homeworks,
  //     List<NewClassModel> classes, String serverCurrentTime);

  // void onGetListHomeworkError(String message);

  // void onLogoutComplete();

  // void onLogoutError(String message);

  // void onUpdateCurrentUserInfo(UserDataModel userDataModel);

  // void onRefreshListHomework();
}

class MyPracticeSettingPresenter {
  final MyPracticeSettingViewContract? _view;
  // AuthRepository? _authRepository;
  // HomeWorkRepository? _homeWorkRepository;

  MyPracticeSettingPresenter(this._view) {
    // _authRepository = Injector().getAuthRepository();
    // _homeWorkRepository = Injector().getHomeWorkRepository();
  }
}
