import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExperienceRatingWidget extends StatelessWidget {

  final double rating;

  ExperienceRatingWidget({@required this.rating}) {
    if (rating < 1 || rating > 5)
      throw ArgumentError.value(rating, "Experience Rating", "Rating must be a double value between 1 and 5");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 1; i <= 5; i++)
          Icon(
            Icons.star,
            color: i < rating ? Colors.orange[300] : Colors.grey,
          ),
        Text(rating.toStringAsFixed(1))
      ],
    );
  }
}




class DifficultyRatingWidget extends StatelessWidget {

  final double rating;

  DifficultyRatingWidget({@required this.rating}) {
    if (rating < 1 || rating > 5)
      throw ArgumentError.value(rating, "Difficulty Rating", "Rating must be a double value between 1 and 5");
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    String text_rating;
    if      (rating <= 1) {color = Color.fromRGBO(87, 227, 44, 1); text_rating = "beginner";}
    else if (rating <= 2) {color = Color.fromRGBO(183, 221, 41, 1); text_rating = "easy";}
    else if (rating <= 3) {color = Color.fromRGBO(225, 226, 52, 1); text_rating = "moderate";}
    else if (rating <= 4) {color = Color.fromRGBO(225, 165, 52, 1); text_rating = "hard";}
    else                  {color = Color.fromRGBO(225, 69, 69, 1); text_rating = "expert";}

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 1; i <= 5; i++)
          Icon(
            Icons.accessibility_new,
            color: i < rating ? color : Colors.grey,
          ),
        Text(text_rating)
      ],
    );
  }
}


