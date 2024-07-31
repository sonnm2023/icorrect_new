import 'dart:convert';

import 'package:icorrect/src/models/module_lession_models/ai_response_model.dart';

const String json = '''{
  "pronunciation_score": 0.791,
  "data": {
    "words": [
      {
        "text": "he's",
        "ipa": [
          "h",
          "iː",
          "z"
        ],
        "phonemes": [
          {
            "start_index": 0,
            "end_index": 0,
            "text": "h",
            "ipa": "h",
            "score": 0.994,
            "phoneme_error": "h",
            "decision": "correct"
          },
          {
            "start_index": 1,
            "end_index": 1,
            "text": "e",
            "ipa": "iː",
            "score": 0.985,
            "phoneme_error": "iː",
            "decision": "correct"
          },
          {
            "start_index": 2,
            "end_index": 3,
            "text": "'s",
            "ipa": "z",
            "score": 0.85,
            "phoneme_error": "z",
            "decision": "correct"
          }
        ],
        "decision": "correct",
        "score": 0.943
      },
      {
        "text": "from",
        "ipa": [
          "f",
          "r",
          "ʌ",
          "m"
        ],
        "phonemes": [
          {
            "start_index": 4,
            "end_index": 4,
            "text": "f",
            "ipa": "f",
            "score": 0.998,
            "phoneme_error": "f",
            "decision": "correct"
          },
          {
            "start_index": 5,
            "end_index": 5,
            "text": "r",
            "ipa": "r",
            "score": 0.624,
            "phoneme_error": "r ə",
            "decision": "warning"
          },
          {
            "start_index": 6,
            "end_index": 6,
            "text": "o",
            "ipa": "ʌ",
            "score": 0.998,
            "phoneme_error": "ʌ",
            "decision": "correct"
          },
          {
            "start_index": 7,
            "end_index": 7,
            "text": "m",
            "ipa": "m",
            "score": 0.998,
            "phoneme_error": "m",
            "decision": "correct"
          }
        ],
        "decision": "correct",
        "score": 0.905
      },
      {
        "text": "asia",
        "ipa": [
          "eɪ",
          "ʒ",
          "ə"
        ],
        "phonemes": [
          {
            "start_index": 8,
            "end_index": 8,
            "text": "a",
            "ipa": "eɪ",
            "score": 0.068,
            "phoneme_error": "s aɪ",
            "decision": "error"
          },
          {
            "start_index": 9,
            "end_index": 9,
            "text": "s",
            "ipa": "ʒ",
            "score": 0.4,
            "phoneme_error": "i",
            "decision": "error"
          },
          {
            "start_index": 10,
            "end_index": 11,
            "text": "ia",
            "ipa": "ə",
            "score": 0.998,
            "phoneme_error": "ə",
            "decision": "correct"
          }
        ],
        "decision": "incorrect",
        "score": 0.489
      }
    ]
  },
  "fluency_score": -1,
  "intonation_score": -1,
  "score": 0.791,
  "status": true,
  "sentence": "he's from asia",
  "duration": 4.64,
  "request_id": "74789a5c3bd748a9b5846cb9f7cb4294",
  "user_id": "",
  "profile_id": "",
  "created_at": 1721883547.520841,
  "audio_path": "https://monkeymedia.vcdn.com.vn/App/uploads/mspeak_audio/74789a5c3bd748a9b5846cb9f7cb4294.wav",
  "msg": "Audio is valid",
  "server_version": "v4-build-01072024-ws-valid-audio"
}''';

abstract class AiResponseViewContract {
  void getAiResponseScoreComplete(AiResponseModel model);
  void getAiResponseScoreError();
}

class AiResponsePresenter {

  AiResponseViewContract? _view;

  AiResponsePresenter(this._view) {

  }

  void getAiResponseScore() {
    AiResponseModel model = AiResponseModel.fromJson(jsonDecode(json));
    _view!.getAiResponseScoreComplete(model);
  }
}