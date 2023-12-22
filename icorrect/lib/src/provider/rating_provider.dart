import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/utils.dart';

class RatingProvider extends ChangeNotifier {
  String _ratingText = "Very Good";
  String get ratingText => _ratingText;

  void updateRating(double newRating) {
    _ratingText = Utils.getRatingText(newRating);
    notifyListeners();
  }
}
