# Cüzdan (Wealth Calculator)

A comprehensive Flutter application for tracking and managing personal wealth, assets, and finances with a focus on Turkish Lira and gold assets.

## Core Features

### 1. Asset Price Tracking
- Real-time monitoring of asset values including gold and currencies
- Automatic price updates through data scraping
- Display current market values in Turkish Lira (TRY)

### 2. Inventory Management
- Track personal wealth and assets
- Store and manage asset details
- Custom list creation for different asset types
- Total wealth calculation in Turkish Lira

### 3. Invoice Management
- Save and track invoices
- Store invoice details and related information
- Invoice history tracking
- Invoice data analysis

### 4. Calculator Tools
- Temporary calculations for quick wealth assessments
- Total wealth computation

### 5. Profile Management
- Personal profile customization
- Settings management
- User preferences storage

## Technical Details

### Architecture
- Built with Flutter for cross-platform compatibility
- Uses BLoC pattern for state management
- Local database storage for asset and invoice data
- Real-time data scraping for current market values

### Key Components
- Custom widgets for wealth display and management
- Notification system for invoice alerts
- Database helpers for local data management
- Utility functions for calculations and conversions

## Data Management
- Secure local storage using SQLite
- Efficient data scraping services
- Custom DAO (Data Access Object) implementations for:
  - Inventory management
  - Invoice tracking
  - Price monitoring
  - Portfolio list handling

## Installation

Clone the repository and ensure you have Flutter installed on your system. Run the following commands:

```bash
flutter pub get
flutter run
```

## Dependencies
- Flutter SDK
- SQLite for local database
- BLoC pattern libraries
- HTTP client for data scraping
