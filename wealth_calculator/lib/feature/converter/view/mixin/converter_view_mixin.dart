part of '../converter_view.dart';

/// Mixin for converter view UI components and helper methods
mixin ConverterViewMixin on State<_ConverterViewBody> {
  /// Build the TL amount input section
  Widget buildInputSection(
    BuildContext context,
    ConverterLoaded state,
    ColorScheme colorScheme,
    TextEditingController tlController,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.blackOverlay10,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.enterTLAmount.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tlController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Icon(Icons.currency_lira, color: colorScheme.primary),
              suffixIcon: tlController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: colorScheme.error),
                      onPressed: () {
                        tlController.clear();
                        context
                            .read<ConverterBloc>()
                            .add(const ClearConversion());
                      },
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {});
              if (value.isNotEmpty) {
                final tlAmount = double.tryParse(value) ?? 0.0;
                if (tlAmount > 0) {
                  context.read<ConverterBloc>().add(
                        ConvertTLAmount(
                          tlAmount: tlAmount,
                          filterType: state.selectedType,
                        ),
                      );
                }
              } else {
                context.read<ConverterBloc>().add(const ClearConversion());
              }
            },
          ),
        ],
      ),
    );
  }

  /// Build the price type filter section (Gold/Currency tabs)
  Widget buildTypeFilterSection(
    BuildContext context,
    ConverterLoaded state,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: buildFilterButton(
              context,
              LocaleKeys.gold.tr(),
              Icons.monetization_on_outlined,
              PriceType.gold,
              state.selectedType == PriceType.gold,
              colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildFilterButton(
              context,
              LocaleKeys.currency.tr(),
              Icons.currency_exchange,
              PriceType.currency,
              state.selectedType == PriceType.currency,
              colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single filter button
  Widget buildFilterButton(
    BuildContext context,
    String label,
    IconData icon,
    PriceType type,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<ConverterBloc>().add(ChangePriceTypeFilter(type));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: colorScheme.blackOverlay5,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the conversion results list
  Widget buildResultsList(
    BuildContext context,
    ConverterLoaded state,
    ColorScheme colorScheme,
  ) {
    if (state.conversionResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calculate_outlined,
              size: 80,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.enterAmountToConvert.tr(),
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.conversionResults.length,
      itemBuilder: (context, index) {
        final result = state.conversionResults[index];
        final wealth = result.wealth;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.blackOverlay5,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  state.selectedType == PriceType.gold
                      ? Icons.monetization_on_outlined
                      : Icons.currency_exchange,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wealth.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${LocaleKeys.price.tr()}: ${wealth.buyingPrice}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formatAmount(result.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Format amount for display
  String formatAmount(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(2);
    } else if (amount >= 1) {
      return amount.toStringAsFixed(4);
    } else {
      return amount.toStringAsFixed(6);
    }
  }
}
