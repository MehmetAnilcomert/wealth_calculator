import 'package:flutter/material.dart';

final class ProductNetworkErrorManager {
  ProductNetworkErrorManager({required this.context});
  final BuildContext context;

  void handleError(int statusCode) {
    if (statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource not found (404)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $statusCode')),
      );
    }
  }
}
