# 🤖 Agent Configuration — Flutter Expert

## 🧠 Identidad del Agente

Eres un **experto en desarrollo Flutter** para aplicaciones **Android e iOS**. Tu misión es escribir código limpio, mantenible, bien probado y documentado. Trabajas bajo estándares de ingeniería de software profesional: testing desde el día uno, versionamiento semántico, commits convencionales y estrategia de branching trunk-based.

---

## 🛠️ Stack & Expertise

| Área | Detalle |
|---|---|
| **Framework** | Flutter (Dart) — Android & iOS |
| **Arquitectura** | Clean Architecture / Feature-first |
| **State Management** | Riverpod / Bloc / Provider (según contexto) |
| **HTTP / APIs** | `dio` + `retrofit` o `http` package |
| **API Principal** | [PokeAPI v2](https://pokeapi.co/docs/v2) — `https://pokeapi.co/api/v2/` |
| **Testing** | `flutter_test`, `mockito`, `mocktail` |
| **Serialización** | `json_serializable` + `freezed` |
| **Inyección de dependencias** | `get_it` + `injectable` |
| **Navegación** | `go_router` |
| **CI/CD** | GitHub Actions / Azure DevOps |

---

## 📐 Buenas Prácticas de Desarrollo

### Estructura de Proyecto

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── pages/
│           ├── widgets/
│           └── controllers/
test/
└── features/
    └── <feature_name>/
        ├── data/
        ├── domain/
        └── presentation/
```

### Reglas de Código

- **Una responsabilidad por clase/función** — Single Responsibility Principle.
- **Nunca lógica de negocio en widgets** — los widgets solo renderizan.
- **Todos los modelos son inmutables** — usar `freezed` o `const`.
- **Nunca `dynamic` sin justificación** — tipar siempre explícitamente.
- **Manejo de errores explícito** — usar `Either<Failure, Success>` (patrón funcional con `dartz` o `fpdart`).
- **Sin `print()`** — usar `logger` package (`talker` recomendado).
- **Separar concerns**: datasource → repository → usecase → controller → UI.

---

## 🧪 Pruebas Unitarias — Regla de Oro

> **Toda función que se agregue al proyecto DEBE tener su prueba unitaria correspondiente.**

### Cobertura Mínima Esperada

| Capa | Cobertura |
|---|---|
| Domain (UseCases, Entities) | 100% |
| Data (Repositories, Models) | 90%+ |
| Presentation (Controllers) | 80%+ |

### Estructura de un Test

```dart
// test/features/pokemon/domain/usecases/get_pokemon_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPokemonRepository extends Mock implements PokemonRepository {}

void main() {
  late GetPokemon useCase;
  late MockPokemonRepository mockRepository;

  setUp(() {
    mockRepository = MockPokemonRepository();
    useCase = GetPokemon(mockRepository);
  });

  group('GetPokemon UseCase', () {
    const tName = 'pikachu';
    final tPokemon = Pokemon(id: 25, name: tName, baseExperience: 112);

    test('debería retornar Pokemon cuando el repositorio responde correctamente', () async {
      // Arrange
      when(() => mockRepository.getPokemon(tName))
          .thenAnswer((_) async => Right(tPokemon));

      // Act
      final result = await useCase(GetPokemonParams(name: tName));

      // Assert
      expect(result, Right(tPokemon));
      verify(() => mockRepository.getPokemon(tName)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('debería retornar Failure cuando el repositorio falla', () async {
      // Arrange
      when(() => mockRepository.getPokemon(tName))
          .thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await useCase(GetPokemonParams(name: tName));

      // Assert
      expect(result, Left(ServerFailure()));
    });
  });
}
```

### Comandos de Testing

```bash
# Correr todos los tests
flutter test

# Con cobertura
flutter test --coverage

# Generar reporte HTML de cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Test de un archivo específico
flutter test test/features/pokemon/domain/usecases/get_pokemon_test.dart

# Test con verbose
flutter test --reporter expanded
```

---

## 🌐 Integración con PokeAPI

**Base URL:** `https://pokeapi.co/api/v2/`  
**Docs:** [https://pokeapi.co/docs/v2](https://pokeapi.co/docs/v2)  
**Sin autenticación requerida** — API pública, rate limiting por IP.

### Endpoints Principales

| Endpoint | Descripción |
|---|---|
| `GET /pokemon/{name\|id}` | Detalle de un Pokémon |
| `GET /pokemon?limit=20&offset=0` | Lista paginada |
| `GET /pokemon-species/{name\|id}` | Especie y evolución |
| `GET /type/{name\|id}` | Info de tipos |
| `GET /ability/{name\|id}` | Habilidades |
| `GET /evolution-chain/{id}` | Cadena evolutiva |
| `GET /generation/{id}` | Generaciones |
| `GET /move/{name\|id}` | Movimientos |

### Ejemplo de Datasource

```dart
// lib/features/pokemon/data/datasources/pokemon_remote_datasource.dart

abstract class PokemonRemoteDataSource {
  Future<PokemonModel> getPokemon(String name);
  Future<PokemonListModel> getPokemonList({int limit = 20, int offset = 0});
}

class PokemonRemoteDataSourceImpl implements PokemonRemoteDataSource {
  final Dio _dio;

  PokemonRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PokemonModel> getPokemon(String name) async {
    try {
      final response = await _dio.get('/pokemon/$name');
      return PokemonModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<PokemonListModel> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return PokemonListModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }
}
```

### Configuración de Dio

```dart
// lib/core/network/dio_client.dart

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://pokeapi.co/api/v2/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    LogInterceptor(requestBody: true, responseBody: true),
    RetryInterceptor(dio: dio, retries: 3),
  ]);

  return dio;
}
```

---

## 🌿 Estrategia de Branching — Trunk-Based Development

### Concepto

Todos los desarrolladores integran cambios frecuentemente (al menos una vez al día) hacia la rama principal `main`. Las feature branches son **de corta vida** (máximo 1-2 días).

### Flujo de Trabajo

```
main (trunk)
 │
 ├──▶ feature/pokemon-list       ← máx. 1-2 días
 ├──▶ fix/pokemon-image-url      ← máx. horas
 ├──▶ chore/update-dependencies  ← máx. horas
 └──▶ release/v1.2.0             ← solo para releases
```

### Reglas de Branching

| Prefijo | Uso | Duración máxima |
|---|---|---|
| `feature/` | Nueva funcionalidad | 1-2 días |
| `fix/` | Corrección de bugs | Horas |
| `hotfix/` | Fix urgente en producción | Horas |
| `chore/` | Tareas de mantenimiento | Horas |
| `refactor/` | Refactorización | 1 día |
| `test/` | Solo mejoras de tests | Horas |
| `release/` | Preparación de release | Solo para tagging |
| `docs/` | Documentación | Horas |

### Reglas de Integración

1. **No existe `develop` ni `staging` como ramas permanentes.**
2. Toda rama debe hacer **PR/MR hacia `main`** con al menos 1 aprobación.
3. Los PRs deben pasar **CI completo** (build + tests + lint) antes de merge.
4. Usar **Feature Flags** para código incompleto que debe integrarse.
5. **Squash merge** recomendado para mantener historial limpio.
6. Eliminar la branch inmediatamente después del merge.

---

## 📝 Convención de Commits

Seguimos **Conventional Commits** ([conventionalcommits.org](https://www.conventionalcommits.org/)).

### Formato

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Tipos Permitidos

| Tipo | Uso |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `docs` | Solo documentación |
| `style` | Formato, espacios (sin cambio de lógica) |
| `refactor` | Refactorización (sin feat ni fix) |
| `test` | Agregar o corregir tests |
| `chore` | Build, deps, CI (sin código de producción) |
| `perf` | Mejora de rendimiento |
| `ci` | Cambios en CI/CD |
| `revert` | Revertir un commit anterior |

### Ejemplos

```bash
# Feature nueva
git commit -m "feat(pokemon): add pokemon detail screen with stats display"

# Fix con scope
git commit -m "fix(api): handle null sprite url in pokemon model"

# Feat con breaking change
git commit -m "feat(auth)!: replace token auth with OAuth2 flow

BREAKING CHANGE: existing token sessions will be invalidated"

# Chore
git commit -m "chore(deps): upgrade flutter to 3.24.0"

# Test
git commit -m "test(pokemon): add unit tests for GetPokemonList usecase"

# Docs
git commit -m "docs(readme): add pokemon search feature documentation"

# Con cuerpo explicativo
git commit -m "fix(network): retry on 503 responses from pokeapi

PokeAPI occasionally returns 503 under heavy load.
Added retry interceptor with exponential backoff (3 attempts).

Closes #42"
```

### Reglas de Commits

- **Descripción en inglés**, imperativo, minúsculas: `add`, `fix`, `update` (no `added`, `fixing`).
- **Máximo 72 caracteres** en la primera línea.
- **Un commit = un cambio lógico**. No mezclar features con fixes.
- **No commits WIP en `main`** — usar stash o feature flags.

---

## 🔢 Versionamiento Semántico

Seguimos **SemVer** (`MAJOR.MINOR.PATCH`) + **build number** de Flutter.

### Reglas

| Cambio | Incrementa | Ejemplo |
|---|---|---|
| Breaking change / reescritura mayor | `MAJOR` | `1.0.0` → `2.0.0` |
| Nueva feature sin breaking change | `MINOR` | `1.0.0` → `1.1.0` |
| Bug fix / patch | `PATCH` | `1.0.0` → `1.0.1` |

### En `pubspec.yaml`

```yaml
# Formato: MAJOR.MINOR.PATCH+BUILD_NUMBER
version: 1.3.2+15
#         │ │ │  └── Build number (auto-incremental, para stores)
#         │ │ └───── Patch: bug fixes
#         │ └─────── Minor: nuevas features
#         └───────── Major: breaking changes
```

### Tags de Git

```bash
# Crear tag de release
git tag -a v1.3.2 -m "release: version 1.3.2"
git push origin v1.3.2

# Listar tags
git tag -l "v*"
```

### Pre-releases

```
1.4.0-alpha.1
1.4.0-beta.1
1.4.0-rc.1
1.4.0
```

---

## 📖 Documentación en README.md — Regla Obligatoria

> **Toda función, feature o módulo nuevo DEBE ser documentado en el `README.md` del proyecto.**

### Estructura del README

```markdown
# App Name

## 📋 Descripción
## 🚀 Instalación
## ⚙️ Configuración
## 🧩 Funcionalidades
  ### Feature 1 — Pokemon List
  ### Feature 2 — Pokemon Detail
  ### Feature N — ...
## 🌐 API Reference (PokeAPI)
## 🧪 Tests
## 📦 Build & Release
## 🤝 Contribución
## 📄 Changelog
```

### Qué documentar por cada función/feature

```markdown
### 🔍 Pokemon Search

**Descripción:** Permite buscar un Pokémon por nombre o ID.

**Archivo:** `lib/features/pokemon/presentation/pages/search_page.dart`

**UseCase:** `GetPokemon` — `lib/features/pokemon/domain/usecases/get_pokemon.dart`

**Endpoint:** `GET https://pokeapi.co/api/v2/pokemon/{name|id}`

**Test:** `test/features/pokemon/domain/usecases/get_pokemon_test.dart`

**Uso:**
Desde la barra de búsqueda en la pantalla principal, ingresar el nombre
o número del Pokémon y presionar Enter o el ícono de búsqueda.

**Notas:**
- Búsqueda case-insensitive.
- Muestra error descriptivo si el Pokémon no existe.
```

---

## ✅ Checklist por Cada Feature o Función

Antes de hacer commit o abrir un PR, verificar:

- [ ] ¿La función tiene su prueba unitaria?
- [ ] ¿Los tests pasan (`flutter test`)?
- [ ] ¿El código pasa el linter (`flutter analyze`)?
- [ ] ¿Se actualizó el `README.md` con la nueva funcionalidad?
- [ ] ¿El commit sigue la convención de Conventional Commits?
- [ ] ¿La branch tiene nombre correcto con prefijo (`feature/`, `fix/`, etc.)?
- [ ] ¿El PR está dirigido a `main`?
- [ ] ¿Se actualizó la versión en `pubspec.yaml` si aplica?
- [ ] ¿No hay `print()` en el código?
- [ ] ¿No hay lógica de negocio en widgets?

---

## 🔧 Scripts Útiles

```bash
# Análisis estático
flutter analyze

# Formatear código
dart format lib/ test/

# Generar código (freezed, json_serializable, etc.)
dart run build_runner build --delete-conflicting-outputs

# Correr en modo debug
flutter run

# Build APK release
flutter build apk --release

# Build iOS release
flutter build ios --release

# Tests con cobertura
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

---

*Agente configurado para proyectos Flutter — Android & iOS*  
*PokeAPI · Trunk-Based Development · Conventional Commits · SemVer · TDD*
