# Pokédex App
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=karlosarr_pokedexapp&metric=coverage)](https://sonarcloud.io/summary/new_code?id=karlosarr_pokedexapp)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=karlosarr_pokedexapp&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=karlosarr_pokedexapp)

A Flutter Pokédex application for Android and iOS built with Clean Architecture, consuming the [PokeAPI v2](https://pokeapi.co/docs/v2).

## 📋 Descripción

Aplicación móvil que permite explorar y consultar información de Pokémon utilizando la PokeAPI. Implementada con Flutter siguiendo principios de Clean Architecture y Feature-First organization.

## 🚀 Instalación

**Requisitos:**
- Flutter SDK `^3.11.0`
- Dart SDK `^3.11.0`
- Android Studio / Xcode (según plataforma)

```bash
# Clonar el repositorio
git clone https://github.com/karlosarr/pokedexapp.git
cd pokedexapp

# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run
```

## ⚙️ Configuración

El proyecto usa Firebase. El archivo `firebase_options.dart` es generado por `flutterfire configure` y debe estar presente antes de correr la app.

```bash
# Si necesitas regenerar la configuración de Firebase
dart pub global activate flutterfire_cli
flutterfire configure
```

## 🧩 Funcionalidades

### 🏠 Pokémon List — Home Page

**Descripción:** Lista paginada de Pokémon con imagen y nombre.

**Archivo:** [lib/features/pokemon/presentation/pages/home_page.dart](lib/features/pokemon/presentation/pages/home_page.dart)

**Endpoint:** `GET https://pokeapi.co/api/v2/pokemon?limit=20&offset=0`

---

### 🔍 Pokémon Detail — Detail Page

**Descripción:** Vista detallada de un Pokémon: stats, tipos, imagen y habilidades.

**Archivo:** [lib/features/pokemon/presentation/pages/detail_page.dart](lib/features/pokemon/presentation/pages/detail_page.dart)

**Endpoint:** `GET https://pokeapi.co/api/v2/pokemon/{name|id}`

---

### 🌙 Dark Mode / Material 3

Soporte de tema oscuro y claro con Material Design 3.

**Archivos:** [lib/core/theme/](lib/core/theme/)

## 🌐 API Reference (PokeAPI)

**Base URL:** `https://pokeapi.co/api/v2/`

| Endpoint | Descripción |
|---|---|
| `GET /pokemon?limit=N&offset=N` | Lista paginada de Pokémon |
| `GET /pokemon/{name\|id}` | Detalle de un Pokémon |

Sin autenticación requerida. Rate limiting por IP.

## 🏗️ Arquitectura

```
lib/
├── core/
│   ├── errors/         # Failures y Exceptions
│   ├── network/        # Configuración de Dio
│   ├── theme/          # Material 3 themes
│   └── usecases/       # Base UseCase
├── features/
│   └── pokemon/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           └── pages/
└── main.dart
```

**Stack:**

| Área | Librería |
|---|---|
| State Management | `flutter_riverpod` |
| Dependency Injection | `get_it` |
| HTTP | `dio` |
| Navigation | `go_router` |
| Error Handling | `fpdart` (`Either<Failure, T>`) |
| Image Cache | `cached_network_image` |
| Crash Reporting | `firebase_crashlytics` |

## 🧪 Tests

```bash
# Correr todos los tests
flutter test

# Con cobertura
flutter test --coverage

# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Cobertura mínima esperada:

| Capa | Cobertura |
|---|---|
| Domain (UseCases, Entities) | 100% |
| Data (Repositories, Models) | 90%+ |
| Presentation (Controllers) | 80%+ |

## 📦 Build & Release

```bash
# Android
flutter build apk --release

# iOS (requiere Mac + Xcode)
flutter build ios --release
```

**CI/CD:** GitHub Actions con tres jobs paralelos — `Test & Analysis`, `Build Android`, `Build iOS` — más un job de `SonarQube Scan` al finalizar. Ver [.github/workflows/ci.yml](.github/workflows/ci.yml).

## 🤝 Contribución

Este proyecto sigue [Trunk-Based Development](https://trunkbaseddevelopment.com/) y [Conventional Commits](https://www.conventionalcommits.org/).

**Prefijos de rama:** `feature/`, `fix/`, `hotfix/`, `chore/`, `refactor/`, `test/`, `docs/`, `release/`

**Checklist antes de PR:**
- [ ] Tests pasan: `flutter test`
- [ ] Sin errores de lint: `flutter analyze`
- [ ] README actualizado si aplica
- [ ] Versión actualizada en `pubspec.yaml` si aplica

## 📄 Changelog

### v1.0.0
- Lista de Pokémon con paginación
- Vista de detalle de Pokémon
- Soporte Dark Mode / Material 3
- Integración Firebase Crashlytics
- CI/CD con GitHub Actions + SonarQube
