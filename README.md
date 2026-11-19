# FitAccess — FlutterApp

Aplicación móvil de gimnasio desarrollada en **Flutter** con **Firebase** como backend.
Permite gestionar rutinas de entrenamiento organizadas por categoría (Push / Pull / Legs / Core),
con soporte de múltiples perfiles por usuario, catálogo de ejercicios, importación por código QR
y un **Modo Entrenamiento en Vivo** con rest timer, vibración y cálculo de discos.

---

## Stack tecnológico

| Tecnología | Uso |
|---|---|
| Flutter (Dart SDK ^3.13) | Framework de UI multiplataforma (Android / iOS / Web) |
| Material 3 | Sistema de diseño (temas claro y oscuro) |
| Firebase Core / Auth | Autenticación con cuentas de Google |
| Cloud Firestore | Base de datos NoSQL en la nube (persistencia) |
| google_sign_in 7.x | Inicio de sesión con Google |
| mobile_scanner | Escaneo de códigos QR (cámara) |
| vibration | Feedback háptico al finalizar el descanso |
| cached_network_image / google_fonts | Carga de imágenes y tipografía Nunito |

---

## Cumplimiento de los requerimientos

### 1. Interfaz de Usuario adecuada y adaptativa

- **Material 3** con `useMaterial3: true` y dos `ColorScheme` completos (claro y oscuro)
  definidos en `lib/src/theme/color_sheme.dart`.
- **Tema dinámico**: la app arranca en modo `system` y el usuario alterna claro/oscuro en
  tiempo real desde el Drawer (`themeNotifier`, `ValueListenableBuilder` en `main.dart`).
- Tipografía consistente con **Google Fonts (Nunito)** aplicada a ambos temas.
- Widgets trabajados a lo largo del cursado, integrados de forma consistente:
  - `StatelessWidget` / `StatefulWidget`, `StreamBuilder` para UI reactiva a la base de datos.
  - Navegación: `Navigator` con rutas nombradas y anidadas, `IndexedStack` para conservar el
    estado de cada pestaña, `GlobalKey<NavigatorState>` por tab, `NavigatorPopHandler` para el
    botón atrás de Android.
  - `TabBar` + `TabBarView` (Mis Rutinas por categoría), `Drawer` con `DrawerHeader`,
    `FloatingActionButton` centrado en la barra inferior.
  - Diálogos: `AlertDialog` de confirmación para acciones destructivas, `MenuAnchor` para el
    menú contextual de rutina, diálogos de edición de peso/reps y calculadora de discos.
  - Componentes reutilizables propios: `BotonBlack`, `BotonWhite`, `IconText`, `InputPropio`,
    `CustomImageLoader`, `CardRoutine`, `Exercise`, tablas de series y tarjetas de descanso.
- Layouts adaptativos: `SafeArea`, `Expanded` / `Flexible`, `SingleChildScrollView`,
  `ListView.builder`, y orientaciones declaradas para teléfono y tablet (iOS `Info.plist`).
- Accesibilidad básica: etiquetas de texto acompañan a los íconos, estados vacíos con mensajes
  explicativos y feedback visual (`SnackBar`, estados de carga con `CircularProgressIndicator`).

### 2. Persistencia de datos

- **Cloud Firestore** como tecnología de persistencia principal, garantizando integridad,
  consistencia y recuperación de la información:
  - Documentos con `FieldValue.serverTimestamp()` para `createdAt` / `updatedAt`.
  - **Streams reactivos** (`snapshots()`) en `lib/src/services/firebase_services.dart`: la UI
    se actualiza sola ante cualquier cambio en los datos, sin refrescos manuales.
  - Escrituras atómicas con `FieldValue.arrayUnion` para agregar ejercicios.
- Modelo jerárquico por usuario y perfil (ver modelo de datos más abajo), lo que aísla los
  datos de cada usuario mediante las reglas de seguridad de Firestore.
- Recursos externos persistidos en Cloudinary (imágenes de ejercicios y rutinas).

### 3. Gestión de datos (ABM completo sobre el modelo principal)

Entidad principal: **Rutina** (con sus ejercicios embebidos). Entidad secundaria también con
ABM: **Perfil**. Todas las operaciones están centralizadas en
`lib/src/services/firebase_services.dart`.

| Operación | Rutinas | Perfiles |
|---|---|---|
| **Alta** | `addRutina()` — desde `AddRutinaPage` | `crearNuevoPerfil()` + `crearUsuario()` |
| **Lectura** | `streamRutinas()`, `streamRutinasPorCategoria()`, `streamProximaRutina()`, `streamRutina()`, `streamEjerciciosDeRutina()` | `streamPerfiles()`, `streamPerfil()`, `getPerfil()` |
| **Modificación** | `updateRutina()`, `updateEjercicioEnRutina()`, `setRutinaFinalizada()`, `resetRutina()` | `updatePerfil()`, `cambiarPerfilActivo()` |
| **Eliminación** | `borrarRutina()`, `borrarEjercicioDeRutina()` | — |

**Validaciones de entrada implementadas:**

- Nombre de rutina obligatorio con mínimo de 4 caracteres; el botón "Save Routine" permanece
  deshabilitado hasta cumplirlo (`_nombreValido` en `add_rutina_page.dart`).
- Indicador visual de nombre válido (check verde) con `onChanged`.
- Confirmación obligatoria antes de eliminar una rutina (`AlertDialog` "¿Eliminar rutina?").
- Doble validación de perfil activo antes de escribir en Firestore
  (`getPerfilActivoId()` en `add_rutina_page.dart`).
- El ejercicio debe elegirse del catálogo o provenir de un QR válido antes de agregarse.
- Parseo del contenido QR con `jsonDecode` dentro de `try/catch`: contenido no JSON muestra
  error y no se agrega.
- Protección contra doble guardado (`_guardando`) y contra uso de `context` tras `dispose`
  (verificaciones con `mounted`).
- Confirmación al finalizar el entrenamiento con series incompletas (`ConfirmFinishDialog`).

### 4. Seguridad y control de acceso

**Autenticación de usuarios (control de acceso a la app):**

- Inicio de sesión único vía **Firebase Auth + Google Sign In** (`login.dart`).
- `Gate` en `main.dart`: escucha `authStateChanges()` y decide en tiempo real si mostrar la
  pantalla de login o el contenido privado. Sin sesión no hay acceso a ninguna pantalla.
- Creación automática del documento de usuario y perfil "Principal" al primer login
  (`crearUsuario()`).
- Cierre de sesión con `disconnect()` + `signOut()` desde el Drawer.

**Permisos de usuario sobre funcionalidades del dispositivo:**

| Permiso | Funcionalidad | Gestión |
|---|---|---|
| `android.permission.CAMERA` | Escaneo de QR de ejercicios (`qr_scanner_modal.dart`) | **Permiso en ejecución**: el plugin `mobile_scanner` solicita el permiso al usuario al abrir la cámara, antes de iniciar el escaneo. No requiere declaración en el manifiesto de la app. |
| `android.permission.VIBRATE` | Vibración al terminar el descanso (`exerciseLive_page.dart`) | Declarada explícitamente en `android/app/src/main/AndroidManifest.xml` |
| `NSCameraUsageDescription` (iOS) | Escaneo de QR | Gestionado por el plugin `mobile_scanner`; se recomienda agregarlo en `ios/Runner/Info.plist` antes de publicar |

La app **solicita la cámara en tiempo de ejecución**: cuando el usuario toca "Escanear
ejercicio con código QR", el plugin muestra el diálogo nativo de permiso antes de abrir la
cámara. Si el permiso se niega o el QR no es válido, la funcionalidad degrada con mensaje
de error y no se agrega ningún ejercicio.

---

## Modelo de datos (Firestore)

```
usuarios/{uid}                                  → { nombre, email, photoUrl, defaultProfileId }
  /perfiles/{profileId}                         → { nombre, image, descripcion, createdAt }
    /rutinas/{id}                               → { categoria, name, description, image,
                                                    tiempo, finalizada, createdAt,
                                                    ejercicios: [ { id, name, image, tiempo,
                                                    series, reps, peso, descanso,
                                                    description, finalizado } ] }
ejercicios/{id}                                 → { name, image, tiempo, description }
```

- Categorías válidas de rutina: `push`, `pull`, `legs`, `core`.
- El estado `finalizada` de la rutina se marca automáticamente cuando todos sus ejercicios
  están en `finalizado: true` (`checkAndFinalizarRutina()`).
- `resetRutina()` permite reutilizar la rutina en un nuevo ciclo de entrenamiento.

---

## Flujo de la aplicación

1. **Login** → cuenta de Google → usuario + perfil "Principal" se crean si no existen.
2. **Home** → muestra la próxima rutina no finalizada y sus ejercicios.
3. **Mis Rutinas** → rutinas por categoría (tabs), acceso a detalle con editar / reset / eliminar.
4. **Crear Rutina** (+) → formulario validado → ejercicios del catálogo o escaneados por QR →
   guardado atómico en Firestore.
5. **Modo Entrenamiento en Vivo** → cronómetro total, rest timer por serie con vibración,
   edición de peso/reps, series completables y finalización automática del ejercicio y la rutina.
6. **Perfiles** → crear, cambiar y editar perfiles (ej.: Volumen / Definición / Fuerza), cada
   uno con sus propias rutinas.

---

## Estructura del proyecto

```
lib/
├── main.dart                       # Init Firebase/GoogleSignIn, temas, Gate de autenticación
├── firebase_options.dart           # Configuración generada por FlutterFire CLI
└── src/
    ├── pages/                      # Pantallas (login, home, rutinas, ABM, modo live)
    ├── components/                 # Widgets reutilizables
    │   ├── exercise_live/          # Rest timer, tabla de series, diálogos, calculadora de discos
    │   ├── add_ejercicio/          # Formulario, catálogo, preview y escáner QR
    │   ├── rutines_page/           # Tarjetas de rutina
    │   └── login/, landing/        # Widgets de login y landing
    ├── services/firebase_services.dart  # Capa de datos (Firestore)
    ├── provider/                   # Provider de datos locales (legado)
    └── theme/color_sheme.dart      # ColorScheme claro y oscuro
```

---

## Puesta en marcha

1. **Clonar el repositorio:**

   ```bash
   git clone https://github.com/catalancarlosrolando/FlutterApp.git
   cd FlutterApp
   ```

2. **Instalar todas las dependencias declaradas:**

   ```bash
   flutter pub get
   ```

3. **Verificar que el entorno esté listo:**

   ```bash
   flutter doctor
   ```

4. **Configurar Firebase** (si se usa una cuenta propia):

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   En Firebase Console habilitar **Authentication (Google)** y **Cloud Firestore**, y copiar el
   *Web Client ID* de Google en `GoogleSignIn.instance.initialize(serverClientId: ...)`
   dentro de `lib/main.dart`.

5. **Ejecutar la app:**

   ```bash
   flutter run
   ```

> [!TIP]
> Si abrís la carpeta directamente en **VS Code** o **Android Studio** con las extensiones de
> Flutter instaladas, el editor suele detectar el `pubspec.yaml` y ejecuta `flutter pub get`
> automáticamente por vos.
