# Notification App

Esta aplicación móvil desarrollada en Flutter se centra en la gestión y visualización de notificaciones para los usuarios. Ofrece funcionalidades de autenticación, una pantalla de inicio personalizada y un sistema robusto de notificaciones.

Características principales:
- Autenticación de usuarios
- Pantalla de inicio personalizada
- Sistema de notificaciones en tiempo real
- Almacenamiento local de datos
- Interfaz de usuario moderna y responsive

Estructura del proyecto:

lib/
  ├── main.dart
  ├── app.dart
  ├── config/
  │   ├── theme.dart
  │   ├── routes.dart
  │   └── app_config.dart
  ├── core/
  │   ├── constants/
  │   ├── errors/
  │   ├── utils/
  │   └── widgets/
  ├── features/
  │   ├── auth/
  │   │   ├── data/
  │   │   │   └── mock_auth_repository.dart
  │   │   ├── domain/
  │   │   │   └── auth_repository.dart
  │   │   └── presentation/
  │   │       ├── screens/
  │   │       │   └── login_screen.dart
  │   │       └── widgets/
  │   ├── notifications/
  │   │   ├── data/
  │   │   │   └── mock_notification_repository.dart
  │   │   ├── domain/
  │   │   │   └── notification_repository.dart
  │   │   └── presentation/
  │   │       ├── screens/
  │   │       │   └── notifications_screen.dart
  │   │       └── widgets/
  │   └── home/
  │       ├── data/
  │       ├── domain/
  │       └── presentation/
  │           └── screens/
  │               └── home_screen.dart
  ├── services/
  │   ├── local_auth_service.dart
  │   ├── local_notification_service.dart
  │   ├── local_storage_service.dart
  │   └── api_service.dart
  ├── shared/
  │   ├── models/
  │   │   ├── user.dart
  │   │   └── notification.dart
  │   └── widgets/
  └── assets/
      ├── images/
      │   └── company_logo.png
      ├── fonts/
      └── sounds/
          └── notification_sounds/

test/
  └── ...
