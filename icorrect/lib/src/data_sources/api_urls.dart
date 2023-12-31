//Example
// final Uri API_USER_LIST = Uri.parse('https://api.randomuser.me/?results=50');

import 'package:icorrect/src/data_sources/utils.dart';

const apiDomain = "http://api.ielts-correction.com/";
const icorrectDomain = "https://ielts-correction.com/";
const icorrectDomain1 = "ielts-correction.com";
const publicDomain = "http://public.icorrect.vn/";
const toolDomain = "http://tool.ielts-correction.com/";

///// api endpoints
const String registerEP = 'auth/register';
const String loginEP = 'auth/login';
const String getUserInfoEP = 'me';
const String logoutEP = 'auth/logout';
const String profileInfoEP = 'auth/profile-info';
const String updateInfoEP = 'auth/update-info';
const String changePasswordEP = 'auth/change-password';
const String getTestInfoEP = 'api/v1/ielts-test/syllabus/create';
const String appConfigEP = 'api/v1/ielts-test/app-config';
String downloadFileEP(String name) => '${apiDomain}file?filename=$name';
String fileEP(String name) => '${icorrectDomain}file?filename=$name';

String responseEP(String orderId) =>
    '${toolDomain}api/response?order_id=$orderId';

Future<String> aiResponseEP(String orderId) async =>
    '${icorrectDomain}ai-response/index1.html?order_id=$orderId&token=${await Utils.getAccessToken()}';

String specialHomeWorksEP(
    String email, String activityId, int status, int example) {
  return "$publicDomain"
      "api/list-answers-activity?activity_id="
      "$activityId"
      "&email="
      "$email"
      "&status="
      "$status"
      "&example="
      "$example"
      "&all=1";
}

String myTestDetailEP(String testId) =>
    '${icorrectDomain}api/v1/ielts-test/show/$testId';

String submitHomeWorkEP() {
  return '${icorrectDomain}api/v1/ielts-test/syllabus/submit';
}

String submitHomeWorkV2EP() {
  return '${icorrectDomain}api/v1/ielts-test/submit-v2';
}

String submitExam() {
  return '${icorrectDomain}api/v1/exam/submit';
}

String getTestDetailWithIdEP(String testId) =>
    '${toolDomain}api/get-test-with-id/$testId';

String getActivitiesList(Map<String, String> queryParameters) {
  return '${apiDomain}api/v1/syllabus/activities-of-class/index?${Uri(queryParameters: queryParameters).query}';
}

String getUserAuthDetailEP()=>'$icorrectDomain/api/v1/exam/voice-bio/detail';
String submitAuthEP() {
  return  '$icorrectDomain/api/v1/exam/voice-bio/submit';
}

class RequestMethod {
  static const post = 'POST';
  static const get = 'GET';
  static const patch = 'PATCH';
  static const put = 'PUT';
  static const delete = 'DELETE';
}
