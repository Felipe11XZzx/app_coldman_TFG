#Estructura del Proyecto

lib/
├── data/
│   ├── models/           # Modelos de datos
│   │   ├── cliente.dart
│   │   ├── empleado.dart
│   │   ├── servicio.dart
│   │   └── cita.dart
│   ├── repositories/     # Comunicación con APIs
│   │   ├── api_service.dart
│   │   ├── cliente_repository.dart
│   │   ├── empleado_repository.dart
│   │   └── servicio_repository.dart
│   └── providers/        # Gestión de estado
│       ├── auth_provider.dart
│       ├── cliente_provider.dart
│       ├── empleado_provider.dart
│       └── servicio_provider.dart
├── presentation/
│   ├── screens/          # Pantallas principales
│   │   ├── auth/
│   │   │   └── screen_login.dart
│   │   ├── admin/
│   │   │   ├── screen_admin.dart
│   │   │   └── screen_gestion_servicios.dart
│   │   ├── cliente/
│   │   │   ├── screen_cliente.dart
│   │   │   └── screen_solicitar_cita.dart
│   │   └── empleado/
│   │       └── screen_empleado.dart
│   └── widgets/          # Componentes reutilizables
│       ├── custom_button.dart
│       ├── service_card.dart
│       └── date_picker_widget.dart
├── utils/               # Utilidades y helpers
│   ├── constants.dart
│   ├── colors.dart
│   └── validators.dart
└── main.dart           # Punto de entrada
