import os
import re

# Create mapping from string keys to LocaleKeys properties
KEY_MAPPING = {
    'appTitle': 'LocaleKeys.appTitle',
    'inventory': 'LocaleKeys.inventory',
    'prices': 'LocaleKeys.prices',
    'invoice': 'LocaleKeys.invoice',
    'profile': 'LocaleKeys.profile',
    'totalWealth': 'LocaleKeys.totalWealth',
    'currency': 'LocaleKeys.currency',
    'gold': 'LocaleKeys.gold',
    'commodities': 'LocaleKeys.commodities',
    'stocks': 'LocaleKeys.stocks',
    'settings': 'LocaleKeys.settings',
    'language': 'LocaleKeys.language',
    'theme': 'LocaleKeys.theme',
    'notifications': 'LocaleKeys.notifications',
    'addNewItem': 'LocaleKeys.addNewItem',
    'save': 'LocaleKeys.save',
    'cancel': 'LocaleKeys.cancel',
    'delete': 'LocaleKeys.delete',
    'edit': 'LocaleKeys.edit',
    'amount': 'LocaleKeys.amount',
    'price': 'LocaleKeys.price',
    'date': 'LocaleKeys.date',
    'total': 'LocaleKeys.total',
    'welcome': 'LocaleKeys.welcome',
    'currentPrice': 'LocaleKeys.currentPrice',
    'highest': 'LocaleKeys.highest',
    'lowest': 'LocaleKeys.lowest',
    'volume': 'LocaleKeys.volume',
    'time': 'LocaleKeys.time',
    'selectGold': 'LocaleKeys.selectGold',
    'selectCurrency': 'LocaleKeys.selectCurrency',
    'enterAmount': 'LocaleKeys.enterAmount',
    'logout': 'LocaleKeys.logout',
    'noDataAvailable': 'LocaleKeys.noDataAvailable',
    'error': 'LocaleKeys.error',
    'loading': 'LocaleKeys.loading',
    'today': 'LocaleKeys.today',
    'yes': 'LocaleKeys.yes',
    'no': 'LocaleKeys.no',
    'priorities': 'LocaleKeys.priorities',
    'sortByDate': 'LocaleKeys.sortByDate',
    'sortByAmount': 'LocaleKeys.sortByAmount',
    'unpaidInvoices': 'LocaleKeys.unpaidInvoices',
    'paidInvoices': 'LocaleKeys.paidInvoices',
    'assets': 'LocaleKeys.assets',
    'marketData': 'LocaleKeys.marketData',
    'calculator': 'LocaleKeys.calculator',
    'wealthCalculator': 'LocaleKeys.wealthCalculator',
    'search': 'LocaleKeys.search',
    'portfolio': 'LocaleKeys.portfolio',
    'invoiceTitle': 'LocaleKeys.invoiceTitle',
    'unpaid': 'LocaleKeys.unpaid',
    'paid': 'LocaleKeys.paid',
    'dueDate': 'LocaleKeys.dueDate',
    'importance': 'LocaleKeys.importance',
    'description': 'LocaleKeys.description',
    'high': 'LocaleKeys.high',
    'medium': 'LocaleKeys.medium',
    'low': 'LocaleKeys.low',
    'addAsset': 'LocaleKeys.addAsset',
    'totalAssets': 'LocaleKeys.totalAssets',
    'assetHistory': 'LocaleKeys.assetHistory',
    'assetDistribution': 'LocaleKeys.assetDistribution',
    'goldPrices': 'LocaleKeys.goldPrices',
    'currencyPrices': 'LocaleKeys.currencyPrices',
    'stocksBist': 'LocaleKeys.stocksBist',
    'commoditiesPrices': 'LocaleKeys.commoditiesPrices',
    'portfolioIndividual': 'LocaleKeys.portfolioIndividual',
    'swipe': 'LocaleKeys.swipe',
    'milyar': 'LocaleKeys.milyar',
    'milyon': 'LocaleKeys.milyon',
    'bin': 'LocaleKeys.bin',
}

def find_dart_files(root_dir):
    """Find all .dart files in lib directory, excluding generated files"""
    dart_files = []
    for root, dirs, files in os.walk(root_dir):
        # Skip generated files
        if 'generated' in root or '.g.dart' in root:
            continue
        for file in files:
            if file.endswith('.dart') and not file.endswith('.g.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

def update_file(filepath):
    """Update a single file with LocaleKeys"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        has_changes = False
        
        # Check if file needs LocaleKeys import
        needs_locale_keys = False
        
        # Replace 'key'.tr() with LocaleKeys.key.tr()
        for key, locale_key in KEY_MAPPING.items():
            pattern = f"'{key}'.tr\\(\\)"
            if re.search(pattern, content):
                needs_locale_keys = True
                content = re.sub(pattern, f"{locale_key}.tr()", content)
                has_changes = True
        
        # Add import if needed and not already present
        if needs_locale_keys and 'LocaleKeys' not in content:
            # Find the last import statement
            import_pattern = r"(import\s+['\"].*?['\"];)"
            imports = list(re.finditer(import_pattern, content))
            if imports:
                last_import = imports[-1]
                insert_pos = last_import.end()
                content = (
                    content[:insert_pos] + 
                    "\nimport 'package:wealth_calculator/product/init/language/locale_keys.g.dart';" + 
                    content[insert_pos:]
                )
        
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ Updated: {filepath}")
            return True
        else:
            return False
            
    except Exception as e:
        print(f"✗ Error processing {filepath}: {e}")
        return False

# Main execution
lib_dir = r"c:\repos\wealth_calculator\wealth_calculator\lib"
dart_files = find_dart_files(lib_dir)

print(f"Found {len(dart_files)} Dart files")
print("=" * 60)

updated_count = 0
for filepath in dart_files:
    if update_file(filepath):
        updated_count += 1

print("=" * 60)
print(f"Updated {updated_count} out of {len(dart_files)} files")
