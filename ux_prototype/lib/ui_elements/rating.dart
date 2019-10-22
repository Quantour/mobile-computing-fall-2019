import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExperienceRatingWidget extends StatelessWidget {

  final double rating;
  final bool useColumn;

  ExperienceRatingWidget({@required this.rating, this.useColumn = false}) {
    if (rating < 1 || rating > 5)
      throw ArgumentError.value(rating, "Experience Rating", "Rating must be a double value between 1 and 5");
  }

  @override
  Widget build(BuildContext context) {
    int j = 0;
    if      (rating < 1.5) {j = 1;}
    else if (rating < 2.5) {j = 2;}
    else if (rating < 3.5) {j = 3;}
    else if (rating < 4.5) {j = 4;}
    else                  {j = 5;}

    List<Widget> ch = <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 1; i <= 5; i++)
            Icon(
              Icons.star,
              color: i <= j ? Colors.orange[300] : Colors.grey,
            )
        ],
      ),
      Text(rating.toStringAsFixed(1))
    ];

    if (!this.useColumn)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: ch
      );
    else
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: ch
      );
  }
}




class DifficultyRatingWidget extends StatelessWidget {

  final double rating;
  final bool useColumn;

  DifficultyRatingWidget({@required this.rating, this.useColumn = false}) {
    if (rating < 1 || rating > 5)
      throw ArgumentError.value(rating, "Difficulty Rating", "Rating must be a double value between 1 and 5");
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    String textRating;
    int j = 0;
    if      (rating < 1.5) {j = 1; color = Color.fromRGBO(87, 227, 44, 1); textRating = "beginner";}
    else if (rating < 2.5) {j = 2; color = Color.fromRGBO(183, 221, 41, 1); textRating = "easy";}
    else if (rating < 3.5) {j = 3; color = Color.fromRGBO(225, 226, 52, 1); textRating = "moderate";}
    else if (rating < 4.5) {j = 4; color = Color.fromRGBO(225, 165, 52, 1); textRating = "hard";}
    else                  {j = 5; color = Color.fromRGBO(225, 69, 69, 1); textRating = "expert";}

    List<Widget> ch = <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 1; i <= 5; i++)
            Icon(
              Icons.accessibility_new,
              color: i <= j ? color : Colors.grey,
            ),
          ],
      ),
      Text(textRating)
    ];

    if (!this.useColumn)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: ch,
      );
    else
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: ch,
      );
  }
}


