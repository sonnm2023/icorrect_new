//Example
// final Uri API_USER_LIST = Uri.parse('https://api.randomuser.me/?results=50');

import '../utils/utils.dart';

// const apiDomain = "http://api.ielts-correction.com/";
// const icorrectDomain1 = "ielts-correction.com";
// const publicDomain = "http://public.icorrect.vn/";
// const toolDomain = "http://tool.ielts-correction.com/";
// const devToolDomain = 'http://devapi.ielts-correction.com/';
const icorrectDomain = "https://ielts-correction.com/";
// const icorrectDomain = 'http://devapi.ielts-correction.com/';
const publicDomain = icorrectDomain;
const toolDomain = icorrectDomain;
const apiDomain = icorrectDomain;
const devToolDomain = icorrectDomain;
const oldPublicDomain = "http://public.icorrect.vn/";
const oldToolDomain = "http://tool.ielts-correction.com/";

const testPositionApi = "http://public.icorrect.vn/api/student/test-position";
const testPositionUser = "ic_landing";
const testPositionPass = "5]N;3e:t<3uvgR2L";

///// api endpoints
const String registerEP = 'auth/register';
const String loginEP = 'auth/login';
const String getUserInfoEP = 'me';
const String logoutEP = 'auth/logout';
const String profileInfoEP = 'auth/profile-info';
const String updateInfoEP = 'auth/update-info';
const String changePasswordEP = 'auth/change-password';
const String getTestHomeWorkInfoEP = 'api/v1/ielts-test/syllabus/create';
const String appConfigEP = 'api/v1/ielts-test/app-config';

const String verifyLicenceEP = 'api/v1/merchant/license/info';
const String loginClassIDEP = 'auth/merchant/login';
const String getListClassEP = 'api/v1/merchant/class';
const String getListSyllabusEP = 'api/v1/merchant/syllabus';
const String verifyConfigEP = 'api/v1/merchant/config/verify';
String changeDeviceNameEP(String deviceID) => '${icorrectDomain}api/v1/merchant/device/$deviceID';
String getListFilesSyllabusEP(int id, int page, String merchantID, String checksum)
=> '$icorrectDomain$getListSyllabusEP/$id/file?page=$page&merchant_id=$merchantID&check_sum=$checksum';
String getListStudentEP(int id, String merchantId, String checkSum) => '$icorrectDomain$getListClassEP/$id/student?merchant_id=$merchantId&check_sum=$checkSum';

String downloadFileEP(String name) => '${apiDomain}file?filename=$name';
String fileEP(String name) => '${icorrectDomain}file?filename=$name';

String responseEP(String orderId) =>
    '${oldToolDomain}api/response?order_id=$orderId';

Future<String> aiResponseEP(String orderId) async =>
    '${icorrectDomain}ai/response?order_id=$orderId&token=${await Utils.instance().getAccessToken()}';

String specialHomeWorksEP(
    String email, String activityId, int status, int example) {
  return "$oldPublicDomain"
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
  // return '${icorrectDomain}api/v1/ielts-test/submit-v2'; //Change from server required 202311301651
  return '${icorrectDomain}api/v1/ielts-test/syllabus/submit';
}

String submitExam() {
  return '${icorrectDomain}api/v1/exam/submit';
}

String submitPractice() {
  return '${icorrectDomain}api/v1/ielts-test/submit';
}

String getTestDetailWithIdEP(String testId) =>
    '${oldToolDomain}api/get-test-with-id/$testId';

// String getActivitiesList(Map<String, String> queryParameters) {
//   return '${apiDomain}api/v1/syllabus/activities-of-class/index?${Uri(queryParameters: queryParameters).query}';
// }

String getActivitiesList(int license) {
  return '${apiDomain}api/v1/syllabus/activities-of-class/index?license=$license';
}

String getUserAuthDetailEP() => '$icorrectDomain/api/v1/exam/voice-bio/detail';
String submitAuthEP() {
  return '$icorrectDomain/api/v1/exam/voice-bio/submit';
}

String getPracticeTopicsListEP(Map<String, String> queryParameters) {
  return '$icorrectDomain/api/v1/ielts-test/bank/topic/index?${Uri(queryParameters: queryParameters).query}';
}

String getTestPracticeInfoEP(Map<String, String> queryParameters) {
  return '$icorrectDomain/api/v1/ielts-test/create?${Uri(queryParameters: queryParameters).query}';
}

String getMyPracticeTestEP(String page) {
  return '$icorrectDomain/api/v1/ielts-test/index?page=$page';
}

String deleteTestEP(String testId) {
  return '$icorrectDomain/api/v1/ielts-test/destroy/$testId';
}

String getMyPracticeTestDetailEP(String testId) {
  return '$icorrectDomain/api/v1/ielts-test/show/$testId';
}

class RequestMethod {
  static const post = 'POST';
  static const get = 'GET';
  static const patch = 'PATCH';
  static const put = 'PUT';
  static const delete = 'DELETE';
}
