Expense Tracker App
- A Flutter-based expense tracking application that allows users to manage daily expenses, budgets, split transactions, recurring expenses, and view analytics with full currency and date-range support.

Features Overview
Expense Management
- Add, edit, and delete expenses (in-memory)
- Optional notes and receipt flag
- Support for split expenses across multiple categories
- Safe editing rules to preserve split integrity

Recurring Expenses
- Create recurring expenses from normal expenses
- Monthly interval support
- Automatic generation of due expenses

Budget Management
- Category-based budgets
- Editable limits
- Visual progress indicators
- Over-budget and safe status labels

Date Range Filtering
- Defaults to current month on app launch
- Custom date range selection via calendar
- One-tap reset to current month
- All views update reactively

Multi-Currency Support
- Supported currencies: USD, EUR, GBP, JPY, PHP
- Centralized currency conversion
- Consistent values across Home, Budget, and Analytics

Analytics (Derived from Core Logic)
- Daily spending trends
- Category-based expense distribution
- Split-aware calculations
- Fully date-range and currency responsive



Architecture Overview
- The app follows a Provider-based reactive architecture using Riverpod.

Key Layers
- UI Layer – Pages & widgets
- Provider Layer – State & computed providers
- Core Logic Layer – Currency & expense calculations
- Model Layer – Data structures