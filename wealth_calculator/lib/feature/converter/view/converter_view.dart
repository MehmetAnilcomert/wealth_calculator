import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/feature/converter/viewmodel/converter_bloc.dart';
import 'package:wealth_calculator/feature/converter/viewmodel/converter_event.dart';
import 'package:wealth_calculator/feature/converter/viewmodel/converter_state.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';
import 'package:wealth_calculator/product/utility/padding/product_padding.dart';

part 'mixin/converter_view_mixin.dart';

/// View for converting TL amount to wealth amounts
class ConverterView extends StatelessWidget {
  const ConverterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConverterBloc()..add(const LoadConverterData()),
      child: const _ConverterViewBody(),
    );
  }
}

class _ConverterViewBody extends StatefulWidget {
  const _ConverterViewBody();

  @override
  State<_ConverterViewBody> createState() => _ConverterViewBodyState();
}

class _ConverterViewBodyState extends State<_ConverterViewBody>
    with ConverterViewMixin {
  final TextEditingController _tlController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _tlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.transparent,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: colorScheme.onPrimaryContainer),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          LocaleKeys.tlConverter.tr(),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<ConverterBloc, ConverterState>(
        listener: (context, state) {
          if (state is ConverterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${LocaleKeys.error.tr()}: ${state.message}'),
                backgroundColor: colorScheme.deleteBackground,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ConverterLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            );
          }

          if (state is ConverterLoaded) {
            return Column(
              children: [
                buildInputSection(context, state, colorScheme, _tlController),
                Padding(
                  padding: const ProductPadding.symmetricVerticalSmall(),
                  child: buildTypeFilterSection(context, state, colorScheme),
                ),
                Expanded(
                  child: buildResultsList(context, state, colorScheme),
                ),
              ],
            );
          }

          return Center(
            child: Text(
              LocaleKeys.noDataAvailable.tr(),
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
