# Notification App

Esta aplicación móvil desarrollada en Flutter se centra en la gestión y visualización de notificaciones para los usuarios. Ofrece funcionalidades de autenticación, una pantalla de inicio personalizada y un sistema robusto de notificaciones.

Características principales:
- Autenticación de usuarios
- Pantalla de inicio personalizada
- Sistema de notificaciones en tiempo real
- Almacenamiento local de datos
- Interfaz de usuario moderna y responsive

Estructura del proyecto:
```
notification_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── theme.dart
│   │   ├── routes.dart
│   │   └── app_config.dart
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── errors/
│   │   │   └── app_exceptions.dart
│   │   ├── utils/
│   │   │   └── date_formatter.dart
│   │   └── widgets/
│   │       └── loading_indicator.dart
│   ├── features/
│   │   ├── auth/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── login_screen.dart
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart
│   │   │       └── widgets/
│   │   │           └── dashboard_card.dart
│   │   ├── notifications/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── notifications_screen.dart
│   │   └── admin/
│   │       └── presentation/
│   │           └── screens/
│   │               └── admin_users_screen.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── notification.dart
│   │   └── device.dart
│   └── services/
│       ├── api_service.dart
│       ├── background_service.dart
│       ├── local_notification_service.dart
│       ├── local_storage_service.dart
│       └── websocket_service.dart
├── assets/
│   ├── images/
│   │   └── logo.png
│   ├── fonts/
│   └── sounds/
│       └── notification_sound.mp3

test/
  └── ...
```
