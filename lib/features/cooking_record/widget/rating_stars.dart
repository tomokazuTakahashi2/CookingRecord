import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 32.0,
    this.readOnly = false,
  });

  final int rating;
  final Function(int)? onRatingChanged;
  final double size;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final icon = Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
          size: size,
        );
        return readOnly
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: icon,
              )
            : IconButton(
                iconSize: size,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                constraints: const BoxConstraints(),
                icon: icon,
                onPressed: () => onRatingChanged?.call(index + 1),
              );
      }),
    );
  }
}
