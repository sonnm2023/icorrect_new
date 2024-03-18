//Example
// final Uri API_USER_LIST = Uri.parse('https://api.randomuser.me/?results=50');

//================START PRODUCT API URLs========================================
/*
import 'package:icorrect/src/data_sources/utils.dart';

const icorrectDomain = "https://ielts-correction.com/";
const publicDomain = icorrectDomain;
const toolDomain = icorrectDomain;
const apiDomain = icorrectDomain;
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
String downloadFileEP(String name) => '${apiDomain}file?filename=$name';
String fileEP(String name) => '${icorrectDomain}file?filename=$name';

String responseEP(String orderId) =>
    '${oldToolDomain}api/response?order_id=$orderId';

Future<String> aiResponseEP(String orderId) async =>
    '${icorrectDomain}ai-response/index1.html?order_id=$orderId&token=${await Utils.getAccessToken()}';

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

String getActivitiesList(Map<String, String> queryParameters) {
  return '${apiDomain}api/v1/syllabus/activities-of-class/index?${Uri(queryParameters: queryParameters).query}';
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

const String bankListEP = '/api/v1/ielts-test/banks/student'; //API 143

String getListTopicOfBankEP(String distributeCode) {
  return '$icorrectDomain//api/v1/ielts-test/banks/$distributeCode/topics'; //API 144
}

const String customPracticeEP = 'api/v1/ielts-test/practices/custom'; //API 145

class RequestMethod {
  static const post = 'POST';
  static const get = 'GET';
  static const patch = 'PATCH';
  static const put = 'PUT';
  static const delete = 'DELETE';
}
*/
//================END PRODUCT API URLs========================================

//================START DEV API URLs========================================
//Example
// final Uri API_USER_LIST = Uri.parse('https://api.randomuser.me/?results=50');

import 'package:icorrect/src/data_sources/utils.dart';

const dev_icorrectDomain = "http://devapi.ielts-correction.com/";
const dev_publicDomain = "http://devpublic.icorrect.vn/";
const dev_toolDomain = "http://devtool.ielts-correction.com/";
const dev_apiDomain = "http://devapi.ielts-correction.com/";

const icorrectDomain = dev_icorrectDomain;
const publicDomain = dev_publicDomain;
const toolDomain = dev_toolDomain;
const apiDomain = dev_apiDomain;

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
String downloadFileEP(String name) => '${apiDomain}file?filename=$name';
String fileEP(String name) => '${icorrectDomain}file?filename=$name';

String responseEP(String orderId) =>
    '${dev_toolDomain}api/response?order_id=$orderId';

Future<String> aiResponseEP(String orderId) async =>
    '${icorrectDomain}ai-response/index1.html?order_id=$orderId&token=${await Utils.getAccessToken()}';

String specialHomeWorksEP(
    String email, String activityId, int status, int example) {
  return "$dev_publicDomain"
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
    '${dev_toolDomain}api/get-test-with-id/$testId';

String getActivitiesList(Map<String, String> queryParameters) {
  return '${apiDomain}api/v1/syllabus/activities-of-class/index?${Uri(queryParameters: queryParameters).query}';
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

const String bankListEP = '/api/v1/ielts-test/banks/student'; //API 143

String getListTopicOfBankEP(String distributeCode) {
  return '$icorrectDomain//api/v1/ielts-test/banks/$distributeCode/topics'; //API 144
}

const String customPracticeEP = 'api/v1/ielts-test/practices/custom'; //API 145

class RequestMethod {
  static const post = 'POST';
  static const get = 'GET';
  static const patch = 'PATCH';
  static const put = 'PUT';
  static const delete = 'DELETE';
}

//================END DEV API URLs==========================================