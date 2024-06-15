class AppConfigInfoModel {
  int? _errorCode;
  String? _status;
  Data? _data;

  AppConfigInfoModel(int errorCode, String status, Data data) {
    _errorCode = errorCode;
    _status = status;
    _data = data;
  }

  int get errorCode => _errorCode ?? 0;
  set errorCode(int errorCode) => _errorCode = errorCode;
  String get status => _status ?? "";
  set status(String status) => _status = status;
  Data get data => _data ?? Data.fromJson({});
  set data(Data data) => _data = data;

  AppConfigInfoModel.fromJson(Map<String, dynamic> json) {
    _errorCode = json['error_code'];
    _status = json['status'];
    _data = (json['data'] != null ? Data.fromJson(json['data']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error_code'] = _errorCode;
    data['status'] = _status;
    if (_data != null) {
      data['data'] = _data!.toJson();
    }
    return data;
  }
}

class Data {
  String? _isShowGgLogin;
  String? _minAnswerTime;
  String? _shortAnswerGuide;
  String? _shortAnswerMessage;
  String? _reminderTime;
  String? _isShowFacebookLogin;
  String? _isShowFormula;
  String? _mailToCallExp;
  String? _isCallExp;
  String? _timelinePostPolicy;
  String? _reportPostReason;
  String? _freeDiamond;
  String? _isShowInviteForDiamond;
  String? _isShowInviteForVip;
  String? _defaultVideo;
  String? _freeVipDay;
  String? _vipYear;
  String? _vipMonth;
  String? _oneYearFee;
  String? _oneMonthFee;
  String? _premiumVersionContent;
  String? _premiumVersion;
  String? _showDiamondDefault;
  String? _diamondDefaultPack;
  String? _payFailSurvey;
  String? _createOrderMessage;
  String? _isAutoShowGgSignin;
  String? _achievementEmpty;
  String? _targetExplain;
  String? _surveyNotFinishedTestGold;
  String? _showSurveyNotFinishedTest;
  String? _logUrl;
  String? _secretkey;
  String? _goldOfEachFollower;
  String? _limitOfFollow;
  String? _requireUpdateVersion;
  String? _currentVersion;
  String? _viewCorrectionGold;
  String? _removeAdsGold;
  String? _hideTrialService;
  String? _showTrialService;
  String? _isHideService;
  String? _trialServiceCoin;
  String? _trialServiceExplain;
  String? _part3LimitTime;
  String? _part2LimitTime;
  String? _part1LimitTime;
  String? _sharingPolicy;
  String? _showBank;
  String? _termOfUse;
  String? _thankPoint;
  String? _sharingLink;
  String? _distributerLink;
  String? _fileDomain;
  String? _introducePart2;
  String? _endOfTest;
  String? _endOfTakeNote;
  List<TestOption>? _testOption;
  TestTime? _testTime;
  String? _sharePolicy;
  String? _countryFlagLink;
  List<Country>? _country;

  Data(String? isShowGgLogin,
      String? minAnswerTime,
      String? shortAnswerGuide,
      String? shortAnswerMessage,
      String? reminderTime,
      String? isShowFacebookLogin,
      String? isShowFormula,
      String? mailToCallExp,
      String? isCallExp,
      String? timelinePostPolicy,
      String? reportPostReason,
      String? freeDiamond,
      String? isShowInviteForDiamond,
      String? isShowInviteForVip,
      String? defaultVideo,
      String? freeVipDay,
      String? vipYear,
      String? vipMonth,
      String? oneYearFee,
      String? oneMonthFee,
      String? premiumVersionContent,
      String? premiumVersion,
      String? showDiamondDefault,
      String? diamondDefaultPack,
      String? payFailSurvey,
      String? createOrderMessage,
      String? isAutoShowGgSignin,
      String? achievementEmpty,
      String? targetExplain,
      String? surveyNotFinishedTestGold,
      String? showSurveyNotFinishedTest,
      String? logUrl,
      String? secretkey,
      String? goldOfEachFollower,
      String? limitOfFollow,
      String? requireUpdateVersion,
      String? currentVersion,
      String? viewCorrectionGold,
      String? removeAdsGold,
      String? hideTrialService,
      String? showTrialService,
      String? isHideService,
      String? trialServiceCoin,
      String? trialServiceExplain,
      String? part3LimitTime,
      String? part2LimitTime,
      String? part1LimitTime,
      String? sharingPolicy,
      String? showBank,
      String? termOfUse,
      String? thankPoint,
      String? sharingLink,
      String? distributerLink,
      String? fileDomain,
      String? introducePart2,
      String? endOfTest,
      String? endOfTakeNote,
      List<TestOption>? testOption,
      TestTime? testTime,
      String? sharePolicy,
      String? countryFlagLink,
      List<Country>? country) {
    _isShowGgLogin = isShowGgLogin;
    _minAnswerTime = minAnswerTime;
    _shortAnswerGuide = shortAnswerGuide;
    _shortAnswerMessage = shortAnswerMessage;
    _reminderTime = reminderTime;
    _isShowFacebookLogin = isShowFacebookLogin;
    _isShowFormula = isShowFormula;
    _mailToCallExp = mailToCallExp;
    _isCallExp = isCallExp;
    _timelinePostPolicy = timelinePostPolicy;
    _reportPostReason = reportPostReason;
    _freeDiamond = freeDiamond;
    _isShowInviteForDiamond = isShowInviteForDiamond;
    _isShowInviteForVip = isShowInviteForVip;
    _defaultVideo = defaultVideo;
    _freeVipDay = freeVipDay;
    _vipYear = vipYear;
    _vipMonth = vipMonth;
    _oneYearFee = oneYearFee;
    _oneMonthFee = oneMonthFee;
    _premiumVersionContent = premiumVersionContent;
    _premiumVersion = premiumVersion;
    _showDiamondDefault = showDiamondDefault;
    _diamondDefaultPack = diamondDefaultPack;
    _payFailSurvey = payFailSurvey;
    _createOrderMessage = createOrderMessage;
    _isAutoShowGgSignin = isAutoShowGgSignin;
    _achievementEmpty = achievementEmpty;
    _targetExplain = targetExplain;
    _surveyNotFinishedTestGold = surveyNotFinishedTestGold;
    _showSurveyNotFinishedTest = showSurveyNotFinishedTest;
    _logUrl = logUrl;
    _secretkey = secretkey;
    _goldOfEachFollower = goldOfEachFollower;
    _limitOfFollow = limitOfFollow;
    _requireUpdateVersion = requireUpdateVersion;
    _currentVersion = currentVersion;
    _viewCorrectionGold = viewCorrectionGold;
    _removeAdsGold = removeAdsGold;
    _hideTrialService = hideTrialService;
    _showTrialService = showTrialService;
    _isHideService = isHideService;
    _trialServiceCoin = trialServiceCoin;
    _trialServiceExplain = trialServiceExplain;
    _part3LimitTime = part3LimitTime;
    _part2LimitTime = part2LimitTime;
    _part1LimitTime = part1LimitTime;
    _sharingPolicy = sharingPolicy;
    _showBank = showBank;
    _termOfUse = termOfUse;
    _thankPoint = thankPoint;
    _sharingLink = sharingLink;
    _distributerLink = distributerLink;
    _fileDomain = fileDomain;
    _introducePart2 = introducePart2;
    _endOfTest = endOfTest;
    _endOfTakeNote = endOfTakeNote;
    _testOption = testOption;
    _testTime = testTime;
    _sharePolicy = sharePolicy;
    _countryFlagLink = countryFlagLink;
    _country = country;
  }

  String get isShowGgLogin => _isShowGgLogin ?? "";
  set isShowGgLogin(String isShowGgLogin) => _isShowGgLogin = isShowGgLogin;
  String get minAnswerTime => _minAnswerTime ?? "";
  set minAnswerTime(String minAnswerTime) => _minAnswerTime = minAnswerTime;
  String get shortAnswerGuide => _shortAnswerGuide ?? "";
  set shortAnswerGuide(String shortAnswerGuide) =>
      _shortAnswerGuide = shortAnswerGuide;
  String get shortAnswerMessage => _shortAnswerMessage ?? "";
  set shortAnswerMessage(String shortAnswerMessage) =>
      _shortAnswerMessage = shortAnswerMessage;
  String get reminderTime => _reminderTime ?? "";
  set reminderTime(String reminderTime) => _reminderTime = reminderTime;
  String get isShowFacebookLogin => _isShowFacebookLogin ?? "";
  set isShowFacebookLogin(String isShowFacebookLogin) =>
      _isShowFacebookLogin = isShowFacebookLogin;
  String get isShowFormula => _isShowFormula ?? "";
  set isShowFormula(String isShowFormula) => _isShowFormula = isShowFormula;
  String get mailToCallExp => _mailToCallExp ?? "";
  set mailToCallExp(String mailToCallExp) => _mailToCallExp = mailToCallExp;
  String get isCallExp => _isCallExp ?? "";
  set isCallExp(String isCallExp) => _isCallExp = isCallExp;
  String get timelinePostPolicy => _timelinePostPolicy ?? "";
  set timelinePostPolicy(String timelinePostPolicy) =>
      _timelinePostPolicy = timelinePostPolicy;
  String get reportPostReason => _reportPostReason ?? "";
  set reportPostReason(String reportPostReason) =>
      _reportPostReason = reportPostReason;
  String get freeDiamond => _freeDiamond ?? "";
  set freeDiamond(String freeDiamond) => _freeDiamond = freeDiamond;
  String get isShowInviteForDiamond => _isShowInviteForDiamond ?? "";
  set isShowInviteForDiamond(String isShowInviteForDiamond) =>
      _isShowInviteForDiamond = isShowInviteForDiamond;
  String get isShowInviteForVip => _isShowInviteForVip ?? "";
  set isShowInviteForVip(String isShowInviteForVip) =>
      _isShowInviteForVip = isShowInviteForVip;
  String get defaultVideo => _defaultVideo ?? "";
  set defaultVideo(String defaultVideo) => _defaultVideo = defaultVideo;
  String get freeVipDay => _freeVipDay ?? "";
  set freeVipDay(String freeVipDay) => _freeVipDay = freeVipDay;
  String get vipYear => _vipYear ?? "";
  set vipYear(String vipYear) => _vipYear = vipYear;
  String get vipMonth => _vipMonth ?? "";
  set vipMonth(String vipMonth) => _vipMonth = vipMonth;
  String get oneYearFee => _oneYearFee ?? "";
  set oneYearFee(String oneYearFee) => _oneYearFee = oneYearFee;
  String get oneMonthFee => _oneMonthFee ?? "";
  set oneMonthFee(String oneMonthFee) => _oneMonthFee = oneMonthFee;
  String get premiumVersionContent => _premiumVersionContent ?? "";
  set premiumVersionContent(String premiumVersionContent) =>
      _premiumVersionContent = premiumVersionContent;
  String get premiumVersion => _premiumVersion ?? "";
  set premiumVersion(String premiumVersion) => _premiumVersion = premiumVersion;
  String get showDiamondDefault => _showDiamondDefault ?? "";
  set showDiamondDefault(String showDiamondDefault) =>
      _showDiamondDefault = showDiamondDefault;
  String get diamondDefaultPack => _diamondDefaultPack ?? "";
  set diamondDefaultPack(String diamondDefaultPack) =>
      _diamondDefaultPack = diamondDefaultPack;
  String get payFailSurvey => _payFailSurvey ?? "";
  set payFailSurvey(String payFailSurvey) => _payFailSurvey = payFailSurvey;
  String get createOrderMessage => _createOrderMessage ?? "";
  set createOrderMessage(String createOrderMessage) =>
      _createOrderMessage = createOrderMessage;
  String get isAutoShowGgSignin => _isAutoShowGgSignin ?? "";
  set isAutoShowGgSignin(String isAutoShowGgSignin) =>
      _isAutoShowGgSignin = isAutoShowGgSignin;
  String get achievementEmpty => _achievementEmpty ?? "";
  set achievementEmpty(String achievementEmpty) =>
      _achievementEmpty = achievementEmpty;
  String get targetExplain => _targetExplain ?? "";
  set targetExplain(String targetExplain) => _targetExplain = targetExplain;
  String get surveyNotFinishedTestGold => _surveyNotFinishedTestGold ?? "";
  set surveyNotFinishedTestGold(String surveyNotFinishedTestGold) =>
      _surveyNotFinishedTestGold = surveyNotFinishedTestGold;
  String get showSurveyNotFinishedTest => _showSurveyNotFinishedTest ?? "";
  set showSurveyNotFinishedTest(String showSurveyNotFinishedTest) =>
      _showSurveyNotFinishedTest = showSurveyNotFinishedTest;
  String get logUrl => _logUrl ?? "";
  set logUrl(String logUrl) => _logUrl = logUrl;
  String get secretkey => _secretkey ?? "";
  set secretkey(String secretkey) => _secretkey = secretkey;
  String get goldOfEachFollower => _goldOfEachFollower ?? "";
  set goldOfEachFollower(String goldOfEachFollower) =>
      _goldOfEachFollower = goldOfEachFollower;
  String get limitOfFollow => _limitOfFollow ?? "";
  set limitOfFollow(String limitOfFollow) => _limitOfFollow = limitOfFollow;
  String get requireUpdateVersion => _requireUpdateVersion ?? "";
  set requireUpdateVersion(String requireUpdateVersion) =>
      _requireUpdateVersion = requireUpdateVersion;
  String get currentVersion => _currentVersion ?? "";
  set currentVersion(String currentVersion) => _currentVersion = currentVersion;
  String get viewCorrectionGold => _viewCorrectionGold ?? "";
  set viewCorrectionGold(String viewCorrectionGold) =>
      _viewCorrectionGold = viewCorrectionGold;
  String get removeAdsGold => _removeAdsGold ?? "";
  set removeAdsGold(String removeAdsGold) => _removeAdsGold = removeAdsGold;
  String get hideTrialService => _hideTrialService ?? "";
  set hideTrialService(String hideTrialService) =>
      _hideTrialService = hideTrialService;
  String get showTrialService => _showTrialService ?? "";
  set showTrialService(String showTrialService) =>
      _showTrialService = showTrialService;
  String get isHideService => _isHideService ?? "";
  set isHideService(String isHideService) => _isHideService = isHideService;
  String get trialServiceCoin => _trialServiceCoin ?? "";
  set trialServiceCoin(String trialServiceCoin) =>
      _trialServiceCoin = trialServiceCoin;
  String get trialServiceExplain => _trialServiceExplain ?? "";
  set trialServiceExplain(String trialServiceExplain) =>
      _trialServiceExplain = trialServiceExplain;
  String get part3LimitTime => _part3LimitTime ?? "";
  set part3LimitTime(String part3LimitTime) => _part3LimitTime = part3LimitTime;
  String get part2LimitTime => _part2LimitTime ?? "";
  set part2LimitTime(String part2LimitTime) => _part2LimitTime = part2LimitTime;
  String get part1LimitTime => _part1LimitTime ?? "";
  set part1LimitTime(String part1LimitTime) => _part1LimitTime = part1LimitTime;
  String get sharingPolicy => _sharingPolicy ?? "";
  set sharingPolicy(String sharingPolicy) => _sharingPolicy = sharingPolicy;
  String get showBank => _showBank ?? "";
  set showBank(String showBank) => _showBank = showBank;
  String get termOfUse => _termOfUse ?? "";
  set termOfUse(String termOfUse) => _termOfUse = termOfUse;
  String get thankPoint => _thankPoint ?? "";
  set thankPoint(String thankPoint) => _thankPoint = thankPoint;
  String get sharingLink => _sharingLink ?? "";
  set sharingLink(String sharingLink) => _sharingLink = sharingLink;
  String get distributerLink => _distributerLink ?? "";
  set distributerLink(String distributerLink) =>
      _distributerLink = distributerLink;
  String get fileDomain => _fileDomain ?? "";
  set fileDomain(String fileDomain) => _fileDomain = fileDomain;
  String get introducePart2 => _introducePart2 ?? "";
  set introducePart2(String introducePart2) => _introducePart2 = introducePart2;
  String get endOfTest => _endOfTest ?? "";
  set endOfTest(String endOfTest) => _endOfTest = endOfTest;
  String get endOfTakeNote => _endOfTakeNote ?? "";
  set endOfTakeNote(String endOfTakeNote) => _endOfTakeNote = endOfTakeNote;
  List<TestOption> get testOption => _testOption ?? [];
  set testOption(List<TestOption> testOption) => _testOption = testOption;
  TestTime get testTime => _testTime ?? TestTime(0, 0, 0, 0, 0);
  set testTime(TestTime testTime) => _testTime = testTime;
  String get sharePolicy => _sharePolicy ?? "";
  set sharePolicy(String sharePolicy) => _sharePolicy = sharePolicy;
  String get countryFlagLink => _countryFlagLink ?? "";
  set countryFlagLink(String countryFlagLink) =>
      _countryFlagLink = countryFlagLink;
  List<Country> get country => _country ?? [];
  set country(List<Country> country) => _country = country;

  Data.fromJson(Map<String, dynamic> json) {
    _isShowGgLogin = json['is_show_gg_login'];
    _minAnswerTime = json['min_answer_time'];
    _shortAnswerGuide = json['short_answer_guide'];
    _shortAnswerMessage = json['short_answer_message'];
    _reminderTime = json['reminder_time'];
    _isShowFacebookLogin = json['is_show_facebook_login'];
    _isShowFormula = json['is_show_formula'];
    _mailToCallExp = json['mail_to_call_exp'];
    _isCallExp = json['is_call_exp'];
    _timelinePostPolicy = json['timeline_post_policy'];
    _reportPostReason = json['report_post_reason'];
    _freeDiamond = json['free_diamond'];
    _isShowInviteForDiamond = json['is_show_invite_for_diamond'];
    _isShowInviteForVip = json['is_show_invite_for_vip'];
    _defaultVideo = json['default_video'];
    _freeVipDay = json['free_vip_day'];
    _vipYear = json['vip_year'];
    _vipMonth = json['vip_month'];
    _oneYearFee = json['one_year_fee'];
    _oneMonthFee = json['one_month_fee'];
    _premiumVersionContent = json['premium_version_content'];
    _premiumVersion = json['premium_version'];
    _showDiamondDefault = json['show_diamond_default'];
    _diamondDefaultPack = json['diamond_default_pack'];
    _payFailSurvey = json['pay_fail_survey'];
    _createOrderMessage = json['create_order_message'];
    _isAutoShowGgSignin = json['is_auto_show_gg_signin'];
    _achievementEmpty = json['achievement_empty'];
    _targetExplain = json['target_explain'];
    _surveyNotFinishedTestGold = json['survey_not_finished_test_gold'];
    _showSurveyNotFinishedTest = json['show_survey_not_finished_test'];
    _logUrl = json['log_url'];
    _secretkey = json['secretkey'];
    _goldOfEachFollower = json['gold_of_each_follower'];
    _limitOfFollow = json['limit_of_follow'];
    _requireUpdateVersion = json['require_update_version'];
    _currentVersion = json['current_version'];
    _viewCorrectionGold = json['view_correction_gold'];
    _removeAdsGold = json['remove_ads_gold'];
    _hideTrialService = json['hide_trial_service'];
    _showTrialService = json['show_trial_service'];
    _isHideService = json['is_hide_service'];
    _trialServiceCoin = json['trial_service_coin'];
    _trialServiceExplain = json['trial_service_explain'];
    _part3LimitTime = json['part3_limit_time'];
    _part2LimitTime = json['part2_limit_time'];
    _part1LimitTime = json['part1_limit_time'];
    _sharingPolicy = json['sharing_policy'];
    _showBank = json['show_bank'];
    _termOfUse = json['term_of_use'];
    _thankPoint = json['thank_point'];
    _sharingLink = json['sharing_link'];
    _distributerLink = json['distributer_link'];
    _fileDomain = json['file_domain'];
    _introducePart2 = json['introduce_part_2'];
    _endOfTest = json['end_of_test'];
    _endOfTakeNote = json['end_of_take_note'];
    if (json['test_option'] != null) {
      _testOption = <TestOption>[];
      json['test_option'].forEach((v) {
        _testOption!.add(TestOption.fromJson(v));
      });
    }
    _testTime = (json['test_time'] != null
        ? TestTime.fromJson(json['test_time'])
        : null)!;
    _sharePolicy = json['share_policy'];
    _countryFlagLink = json['country_flag_link'];
    if (json['country'] != null) {
      _country = <Country>[];
      json['country'].forEach((v) {
        _country!.add(Country.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_show_gg_login'] = _isShowGgLogin;
    data['min_answer_time'] = _minAnswerTime;
    data['short_answer_guide'] = _shortAnswerGuide;
    data['short_answer_message'] = _shortAnswerMessage;
    data['reminder_time'] = _reminderTime;
    data['is_show_facebook_login'] = _isShowFacebookLogin;
    data['is_show_formula'] = _isShowFormula;
    data['mail_to_call_exp'] = _mailToCallExp;
    data['is_call_exp'] = _isCallExp;
    data['timeline_post_policy'] = _timelinePostPolicy;
    data['report_post_reason'] = _reportPostReason;
    data['free_diamond'] = _freeDiamond;
    data['is_show_invite_for_diamond'] = _isShowInviteForDiamond;
    data['is_show_invite_for_vip'] = _isShowInviteForVip;
    data['default_video'] = _defaultVideo;
    data['free_vip_day'] = _freeVipDay;
    data['vip_year'] = _vipYear;
    data['vip_month'] = _vipMonth;
    data['one_year_fee'] = _oneYearFee;
    data['one_month_fee'] = _oneMonthFee;
    data['premium_version_content'] = _premiumVersionContent;
    data['premium_version'] = _premiumVersion;
    data['show_diamond_default'] = _showDiamondDefault;
    data['diamond_default_pack'] = _diamondDefaultPack;
    data['pay_fail_survey'] = _payFailSurvey;
    data['create_order_message'] = _createOrderMessage;
    data['is_auto_show_gg_signin'] = _isAutoShowGgSignin;
    data['achievement_empty'] = _achievementEmpty;
    data['target_explain'] = _targetExplain;
    data['survey_not_finished_test_gold'] = _surveyNotFinishedTestGold;
    data['show_survey_not_finished_test'] = _showSurveyNotFinishedTest;
    data['log_url'] = _logUrl;
    data['secretkey'] = _secretkey;
    data['gold_of_each_follower'] = _goldOfEachFollower;
    data['limit_of_follow'] = _limitOfFollow;
    data['require_update_version'] = _requireUpdateVersion;
    data['current_version'] = _currentVersion;
    data['view_correction_gold'] = _viewCorrectionGold;
    data['remove_ads_gold'] = _removeAdsGold;
    data['hide_trial_service'] = _hideTrialService;
    data['show_trial_service'] = _showTrialService;
    data['is_hide_service'] = _isHideService;
    data['trial_service_coin'] = _trialServiceCoin;
    data['trial_service_explain'] = _trialServiceExplain;
    data['part3_limit_time'] = _part3LimitTime;
    data['part2_limit_time'] = _part2LimitTime;
    data['part1_limit_time'] = _part1LimitTime;
    data['sharing_policy'] = _sharingPolicy;
    data['show_bank'] = _showBank;
    data['term_of_use'] = _termOfUse;
    data['thank_point'] = _thankPoint;
    data['sharing_link'] = _sharingLink;
    data['distributer_link'] = _distributerLink;
    data['file_domain'] = _fileDomain;
    data['introduce_part_2'] = _introducePart2;
    data['end_of_test'] = _endOfTest;
    data['end_of_take_note'] = _endOfTakeNote;
    data['test_option'] = _testOption!.map((v) => v.toJson()).toList();
    data['test_time'] = _testTime!.toJson();
    data['share_policy'] = _sharePolicy;
    data['country_flag_link'] = _countryFlagLink;
    data['country'] = _country!.map((v) => v.toJson()).toList();
    return data;
  }
}

class TestOption {
  int? _testOption;
  String? _title;
  String? _description;

  TestOption(int testOption, String title, String description) {
    _testOption = testOption;
    _title = title;
    _description = description;
  }

  int get testOption => _testOption ?? 0;
  set testOption(int testOption) => _testOption = testOption;
  String get title => _title ?? "";
  set title(String title) => _title = title;
  String get description => _description ?? "";
  set description(String description) => _description = description;

  TestOption.fromJson(Map<String, dynamic> json) {
    _testOption = json['test_option'];
    _title = json['title'];
    _description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['test_option'] = _testOption;
    data['title'] = _title;
    data['description'] = _description;
    return data;
  }
}

class TestTime {
  int? _i1;
  int? _i2;
  int? _i3;
  int? _i4;
  int? _i5;

  TestTime(int i1, int i2, int i3, int i4, int i5) {
    _i1 = i1;
    _i2 = i2;
    _i3 = i3;
    _i4 = i4;
    _i5 = i5;
  }

  int get i1 => _i1 ?? 0;
  set i1(int i1) => _i1 = i1;
  int get i2 => _i2 ?? 0;
  set i2(int i2) => _i2 = i2;
  int get i3 => _i3 ?? 0;
  set i3(int i3) => _i3 = i3;
  int get i4 => _i4 ?? 0;
  set i4(int i4) => _i4 = i4;
  int get i5 => _i5 ?? 0;
  set i5(int i5) => _i5 = i5;

  TestTime.fromJson(Map<String, dynamic> json) {
    _i1 = json['1'];
    _i2 = json['2'];
    _i3 = json['3'];
    _i4 = json['4'];
    _i5 = json['5'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['1'] = _i1;
    data['2'] = _i2;
    data['3'] = _i3;
    data['4'] = _i4;
    data['5'] = _i5;
    return data;
  }
}

class Country {
  String? _iso;
  String? _nicename;
  int? _phonecode;

  Country(String iso, String nicename, int phonecode) {
    _iso = iso;
    _nicename = nicename;
    _phonecode = phonecode;
  }

  String get iso => _iso ?? "";
  set iso(String iso) => _iso = iso;
  String get nicename => _nicename ?? "";
  set nicename(String nicename) => _nicename = nicename;
  int get phonecode => _phonecode ?? 0;
  set phonecode(int phonecode) => _phonecode = phonecode;

  Country.fromJson(Map<String, dynamic> json) {
    _iso = json['iso'];
    _nicename = json['nicename'];
    _phonecode = json['phonecode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['iso'] = _iso;
    data['nicename'] = _nicename;
    data['phonecode'] = _phonecode;
    return data;
  }
}