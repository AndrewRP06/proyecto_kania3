# Kartnia

Aplicación Flutter para la comunidad de karting. Permite consultar circuitos y carreras, gestionar inscripciones y perfiles, y ver el ranking de pilotos. La aplicación usa Firebase Authentication para el acceso y Cloud Firestore para los datos.

## Requisitos

- Flutter instalado y disponible en `PATH` (con una versión de Dart compatible con `pubspec.yaml`).
- Android Studio con un emulador Android configurado, o un dispositivo Android con depuración USB.
- Google Chrome para ejecutar la aplicación web.
- Acceso al proyecto Firebase `proyecto-arp-flutter` para usar autenticación y Firestore.

Comprueba la instalación de Flutter con:

```bash
flutter doctor
```

## Descargar y arrancar el proyecto

Desde un equipo limpio:

```bash
git clone https://github.com/AndrewRP06/proyecto_kania3.git
cd proyecto_kania3
flutter pub get
```

Para iniciar la aplicación en Android, arranca un emulador o conecta un dispositivo y ejecuta:

```bash
flutter devices
flutter run -d <id-del-dispositivo>
```

Para iniciar la aplicación en Chrome:

```bash
flutter run -d chrome
```

Si Chrome no aparece en `flutter devices`, comprueba que esté instalado y que Flutter tenga habilitado el soporte web.

## Estructura del proyecto

El código de interfaz y de datos está separado por responsabilidad para que las pantallas no tengan que concentrar toda la lógica:

- `lib/views/`: pantallas de la aplicación, como inicio de sesión, perfil, carreras, ranking y onboarding.
- `lib/widgets/`: componentes reutilizables que forman parte de varias pantallas, como tarjetas y la barra de navegación.
- `lib/ObjectsFirebase/`: modelos de datos y conversores de Firestore. Las clases `Carrera`, `Circuito` y `Perfil` convierten los documentos en objetos tipados; sus referencias usan `withConverter`.
- `lib/Dataholder.dart`: acceso y gestión de datos de la sesión y del perfil.
- `lib/theme/`: colores y estilos compartidos.
- `assets/images/`: imágenes locales utilizadas por la interfaz.

Los modelos también contienen referencias y operaciones de Firestore; actualmente no existe una carpeta `services/` separada. Mantener pantallas, widgets, modelos y tema en sus propios directorios facilita localizar cada parte y modificarla sin mezclar presentación, datos y estilos.

## Configuración de Firebase

La aplicación inicializa Firebase en `lib/main.dart`. La configuración de cliente disponible en este repositorio es:

- `lib/ObjectsFirebase/firebase_options.dart`: opciones de Firebase para Android, iOS, macOS, Windows y web.
- `android/app/google-services.json`: configuración de la aplicación Android.
- `firebase.json`: metadatos usados por FlutterFire CLI.

Estos archivos contienen identificadores y opciones de cliente que la aplicación necesita para conectarse. Están incluidos actualmente en este repositorio para que el clon pueda configurarse con el proyecto Firebase asociado. Si se sustituye el proyecto Firebase, hay que actualizar las opciones de cliente y el archivo de Android con los valores de ese proyecto.

**No subas al repositorio claves privadas ni credenciales administrativas**, por ejemplo una clave de cuenta de servicio (`service-account.json`), archivos `.env` con secretos, claves privadas de firma o credenciales de proveedores. Las opciones de cliente no sustituyen las reglas de seguridad de Firebase: configura Authentication, Firestore Rules y las restricciones de las claves desde Firebase Console.

Para que las funciones de la aplicación estén disponibles, el proyecto Firebase debe tener habilitado el método de acceso por correo y contraseña, y una base de datos Cloud Firestore. El código consulta, entre otras, las colecciones `Perfiles`, `Carreras` y `circuitos`; la aplicación no crea automáticamente datos de ejemplo para esas colecciones.

## Organización de los datos

Los modelos de Firestore se encuentran en `lib/ObjectsFirebase/`. Las colecciones principales que consulta la aplicación son:

- `Perfiles`: perfiles de usuario, con subcolecciones para carreras inscritas e historial.
- `Carreras`: carreras disponibles.
- `circuitos`: circuitos que se muestran en la pantalla de inicio.

Para probar las pantallas con contenido, crea documentos de prueba en Firestore con los campos que leen los modelos y revisa las reglas de acceso. Los datos de Firestore no se incluyen en el repositorio.

## Dependencias

Las dependencias de Flutter se declaran en `pubspec.yaml` y sus versiones resueltas se registran en `pubspec.lock`. Después de clonar el proyecto, `flutter pub get` las descarga.
