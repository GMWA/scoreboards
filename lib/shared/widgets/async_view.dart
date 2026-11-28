import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/theme.dart';

/// Shows a provider's value: a spinner while it first loads, [error] if it
/// failed, [data] once it has a value. A refresh keeps the current value on
/// screen rather than going back to the spinner.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    required this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final Widget Function() error;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncValue(hasValue: true, :final value) => data(value as T),
      AsyncError() => error(),
      _ => const Center(child: CircularProgressIndicator(color: AppColors.coral)),
    };
  }
}
