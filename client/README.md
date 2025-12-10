# wedding_me

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
```
lib/
├── main.dart
├── core/                # Ядро приложения: сервисы API, темы, общие утилиты
│   ├── api/
│   ├── theme/
│   └── utils/
├── features/            # Основные модули/фичи приложения
│   ├── authentication/  # Модуль регистрации и входа
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── home/            # Модуль главного экрана
│   │   ├── screens/
│   │   └── widgets/
│   └── profile/         # Модуль профиля пользователя
│       ├── screens/
│       └── models/
└── widgets/             # Общие, атомарные виджеты, которые не привязаны к конкретной фиче
```
