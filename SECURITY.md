# 🔐 Security Policy

## 📋 Versiones Soportadas

Solo se aplican parches de seguridad a las siguientes versiones del proyecto:

| Versión | Soportada |
|---|---|
| `>= 1.0.0` (latest stable) | ✅ Sí |
| `1.x.x-rc.*` (release candidate) | ⚠️ Limitado |
| `1.x.x-beta.*` | ❌ No |
| `1.x.x-alpha.*` | ❌ No |
| `< 1.0.0` | ❌ No |

> Solo la **última versión estable** recibe actualizaciones de seguridad activas.  
> Consulta [CHANGELOG.md](./CHANGELOG.md) y los [releases del repositorio](../../releases) para verificar la versión actual.

---

## 🚨 Reporte de Vulnerabilidades

### Canal oficial — GitHub Issues

**Todos los reportes de seguridad deben realizarse a través de la sección de Issues de GitHub:**

👉 **[Abrir un Security Issue](../../issues/new?template=security_report.md&labels=security,priority:high)**

Al crear el issue, selecciona la plantilla **"Security Report"** o usa la etiqueta `security`.

> ⚠️ **Importante:** Si la vulnerabilidad es crítica y expone datos de usuarios reales, marca el issue como **confidencial** (si el repositorio lo permite) o usa el título `[SECURITY][CONFIDENTIAL]: <descripción breve>` para que el equipo lo atienda con máxima prioridad y lo trate con discreción.

---

### Plantilla de Reporte

Al abrir el issue, incluye la siguiente información:

```markdown
## 🔐 Reporte de Seguridad

**Versión afectada:** <!-- ej. v1.2.3 -->
**Plataforma:** <!-- Android / iOS / Ambas -->
**Severidad estimada:** <!-- Crítica / Alta / Media / Baja -->

### Descripción
<!-- Describe la vulnerabilidad de forma clara y concisa -->

### Pasos para reproducir
1. 
2. 
3. 

### Impacto potencial
<!-- ¿Qué podría lograr un atacante explotando esto? -->

### Componente afectado
<!-- ej. lib/core/network/, lib/features/pokemon/data/ -->

### Evidencia / PoC
<!-- Capturas, logs, código de prueba (sin datos reales) -->

### Posible solución sugerida
<!-- (Opcional) Si tienes una idea de cómo resolverlo -->
```

---

## ⏱️ Tiempos de Respuesta

| Severidad | Primera respuesta | Resolución objetivo |
|---|---|---|
| 🔴 **Crítica** | 24 horas | 3 días hábiles |
| 🟠 **Alta** | 48 horas | 7 días hábiles |
| 🟡 **Media** | 72 horas | 14 días hábiles |
| 🟢 **Baja** | 5 días hábiles | Próximo sprint |

El equipo actualizará el issue con el estado del avance. Si no recibes respuesta en el plazo indicado, agrega un comentario en el mismo issue mencionando `@maintainers`.

---

## 🏷️ Etiquetas de Issues para Seguridad

Al crear el issue, aplica las etiquetas correspondientes:

| Etiqueta | Uso |
|---|---|
| `security` | Todo reporte de seguridad (obligatoria) |
| `priority:critical` | Vulnerabilidad que compromete datos o acceso |
| `priority:high` | Fallo que puede ser explotado con esfuerzo moderado |
| `priority:medium` | Riesgo acotado o difícil de explotar |
| `priority:low` | Mejora de hardening sin riesgo inmediato |
| `platform:android` | Afecta específicamente Android |
| `platform:ios` | Afecta específicamente iOS |
| `component:network` | Relacionado con capa de red / Dio / HTTP |
| `component:api` | Relacionado con integración PokeAPI |
| `component:storage` | Relacionado con almacenamiento local |

---

## 🛡️ Prácticas de Seguridad del Proyecto

Las siguientes prácticas están definidas en [`agents.md`](./agents.md) y son de cumplimiento obligatorio en todo el código del proyecto.

### 🌐 Seguridad en la Capa de Red (Dio + PokeAPI)

La integración con la PokeAPI (`https://pokeapi.co/api/v2/`) debe cumplir:

```dart
// ✅ CORRECTO — Timeouts definidos siempre
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://pokeapi.co/api/v2/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
);

// ✅ CORRECTO — Capturar y tipar excepciones de red
try {
  final response = await _dio.get('/pokemon/$name');
  return PokemonModel.fromJson(response.data);
} on DioException catch (e) {
  throw ServerException.fromDioError(e); // nunca exponer e.message crudo
}

// ❌ INCORRECTO — Nunca capturar Exception genérico y continuar silenciosamente
try {
  final response = await _dio.get('/pokemon/$name');
} catch (e) {
  print(e); // expone stack trace, viola privacidad de logs
}
```

**Reglas obligatorias para la red:**

- Siempre definir `connectTimeout` y `receiveTimeout`.
- Nunca loguear respuestas completas de red en producción — usar `kDebugMode`.
- Sanitizar mensajes de error antes de mostrarlos al usuario.
- No exponer URLs internas ni tokens en logs.
- Usar `RetryInterceptor` con backoff exponencial (máx. 3 reintentos).
- Validar el esquema de respuesta antes de parsear con `fromJson`.

### 📦 Serialización Segura de Datos

```dart
// ✅ CORRECTO — Modelos inmutables con freezed, tipos explícitos
@freezed
class PokemonModel with _$PokemonModel {
  const factory PokemonModel({
    required int id,
    required String name,
    int? baseExperience,       // nullable explícito
    String? spriteUrl,         // nunca asumir que existe
  }) = _PokemonModel;

  factory PokemonModel.fromJson(Map<String, dynamic> json) =>
      _$PokemonModelFromJson(json);
}

// ❌ INCORRECTO — Tipos dynamic y sin validación
Map<dynamic, dynamic> data = response.data; // nunca dynamic
final name = data['name'];                  // crash si el campo no existe
```

**Reglas de serialización:**

- Nunca usar `dynamic` sin justificación documentada.
- Todos los campos opcionales de la API deben ser `nullable` (`?`) en el modelo.
- Usar `json_serializable` + `freezed` — sin deserialización manual.
- Validar estructura de respuesta antes de construir entidades de dominio.

### 🔒 Almacenamiento Local

```dart
// ✅ CORRECTO — Datos sensibles en flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
await _storage.write(key: 'user_token', value: token);

// ❌ INCORRECTO — SharedPreferences para datos sensibles
final prefs = await SharedPreferences.getInstance();
prefs.setString('user_token', token); // sin cifrado, texto plano
```

**Reglas de almacenamiento:**

- `SharedPreferences` solo para preferencias no sensibles (tema, idioma).
- `flutter_secure_storage` para cualquier token, credencial o dato de sesión.
- Nunca almacenar respuestas completas de la API sin parsear.
- Purgar datos de caché al cerrar sesión.

### 📵 Logging Seguro

```dart
// ✅ CORRECTO — Logger condicional, sin datos sensibles
import 'package:talker_flutter/talker_flutter.dart';

final talker = Talker();

// Solo en debug
if (kDebugMode) {
  talker.debug('Pokemon fetched: ${pokemon.name}');
}

// ❌ INCORRECTO — print() expone información en producción
print('Response: ${response.data}');       // viola políticas de stores
print('Token: $token');                    // exposición de credenciales
```

**Reglas de logging:**

- **Prohibido `print()`** en todo el código — usar `talker` o equivalente.
- Logs de red (`LogInterceptor` de Dio) solo activos en `kDebugMode`.
- Nunca loguear tokens, IDs de usuario, ni datos personales.
- En producción: nivel `warning` o superior únicamente.

### 🧪 Seguridad en Pruebas Unitarias

```dart
// ✅ CORRECTO — Usar datos ficticios en tests
const tName = 'pikachu';
final tPokemon = Pokemon(id: 25, name: tName);

// ❌ INCORRECTO — Nunca usar datos reales o credenciales en tests
const realToken = 'eyJhbGciOiJIUzI1...'; // expone secretos en el repo
```

**Reglas para tests:**

- Nunca incluir credenciales, tokens o datos reales en archivos de test.
- Usar siempre mocks (`mocktail` / `mockito`) para dependencias externas.
- Los archivos de fixtures JSON deben contener únicamente datos ficticios.
- No hacer llamadas HTTP reales en tests unitarios — todo debe ser mockeado.

### 🔑 Gestión de Secretos y Configuración

```dart
// ✅ CORRECTO — Variables de entorno con flutter_dotenv o --dart-define
// En CI: --dart-define=API_KEY=${{ secrets.API_KEY }}
const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

// ❌ INCORRECTO — Hardcodear secretos en el código
const apiKey = 'sk-abc123xyz'; // nunca en el código fuente
```

**Reglas de secretos:**

- Nunca hardcodear claves, tokens ni URLs de entorno en el código.
- Usar `--dart-define` para inyección en tiempo de compilación.
- Las variables de entorno de CI/CD van en **GitHub Secrets**, nunca en el repo.
- Agregar al `.gitignore`: `.env`, `*.keystore`, `google-services.json`, `GoogleService-Info.plist`, `key.properties`.

```gitignore
# .gitignore — entradas de seguridad obligatorias
.env
*.env.*
android/key.properties
android/app/*.keystore
android/app/*.jks
ios/Runner/GoogleService-Info.plist
android/app/google-services.json
```

### 📱 Seguridad en Android e iOS

**Android (`android/app/build.gradle`):**

```groovy
android {
    buildTypes {
        release {
            minifyEnabled true          // ofuscación de código
            shrinkResources true        // eliminar recursos no usados
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                         'proguard-rules.pro'
        }
    }
}
```

**iOS (`ios/Runner/Info.plist`):**

- Declarar solo los permisos estrictamente necesarios.
- No incluir `NSAllowsArbitraryLoads = true` en `ATS` sin justificación.
- Usar `App Transport Security` con dominios explícitos si se necesitan excepciones.

---

## 🔄 Proceso de Resolución de Vulnerabilidades

El flujo para gestionar un reporte de seguridad sigue la estrategia Trunk-Based Development definida en `agents.md`:

```
1. Issue abierto en GitHub con etiqueta `security`
         │
         ▼
2. Triage: asignación de severidad y responsable (< 24h)
         │
         ▼
3. Branch: hotfix/security-<issue-number>-<descripcion>
         │  (ejemplo: hotfix/security-87-dio-token-leak)
         │
         ▼
4. Fix desarrollado + prueba unitaria que reproduce la vulnerabilidad
         │
         ▼
5. PR hacia main con referencia al issue (Closes #87)
         │  Commit: fix(security): <descripcion del fix>
         │
         ▼
6. Review obligatorio por al menos 1 maintainer
         │
         ▼
7. Merge a main + tag de patch release (ej. v1.2.4)
         │
         ▼
8. Issue cerrado con referencia al commit y versión
         │
         ▼
9. Actualización del CHANGELOG.md con sección [Security]
```

### Convención de Commits para Fixes de Seguridad

```bash
# Fix de seguridad
git commit -m "fix(security): prevent token exposure in dio log interceptor

Disabled LogInterceptor in release builds to avoid leaking
Authorization headers in device logs.

Closes #87"

# Con breaking change si el fix requiere migración
git commit -m "fix(security)!: enforce certificate pinning for all API calls

BREAKING CHANGE: apps without updated certificates will fail to connect.
Users must update to v1.3.0 or later.

Closes #92"
```

---

## 📊 Clasificación de Severidad (CVSS simplificado)

| Severidad | Descripción | Ejemplos en este proyecto |
|---|---|---|
| 🔴 **Crítica** | Compromiso total de datos o del dispositivo | Exposición de keystore, RCE, bypass de auth |
| 🟠 **Alta** | Acceso no autorizado a funciones o datos | Token en logs, fuga de caché sin cifrar |
| 🟡 **Media** | Degradación de seguridad o fuga parcial | MITM posible sin certificate pinning, logs verbosos en prod |
| 🟢 **Baja** | Hardening o mejora sin riesgo inmediato | Timeout no definido, permission innecesario en manifest |

---

## 📚 Referencias y Recursos

- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Dart Language Security](https://dart.dev/security)
- [Android App Security Checklist](https://developer.android.com/topic/security/best-practices)
- [iOS Security Guide — Apple](https://support.apple.com/guide/security/welcome/web)
- [PokeAPI — Política de Uso](https://pokeapi.co/docs/v2#fairuse)
- [`agents.md`](./agents.md) — Configuración del agente y buenas prácticas del proyecto

---

## 🤝 Reconocimientos

Los reportes de seguridad válidos serán reconocidos en el `CHANGELOG.md` bajo la sección `[Security]` con mención al issue correspondiente (a menos que el reportante solicite anonimato).

```markdown
## [Security] v1.2.4 — 2025-06-01
- fix(security): prevent token exposure in dio log interceptor (#87) — reported by @usuario
```

---

*Este documento aplica a todas las versiones activamente mantenidas del proyecto.*  
*Revisado y alineado con [`agents.md`](./agents.md) — Flutter · Trunk-Based · SemVer · Conventional Commits*
