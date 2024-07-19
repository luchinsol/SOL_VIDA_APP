import 'package:appsol_final/components/responsiveUI/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:appsol_final/components/prelogin.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:intl/intl.dart';
//import 'package:solvida/componentes/responsiveUI/breakpoint.dart';
//import 'breakpoint.dart';

class Formucli extends StatefulWidget {
  const Formucli({super.key});

  @override
  State<Formucli> createState() => _FormucliState();
}

//copia del archivo original
class _FormucliState extends State<Formucli> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nombres = TextEditingController();
  final TextEditingController _apellidos = TextEditingController();
  final TextEditingController _dni = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _ruc = TextEditingController();
  bool _obscureText = true;
  String? selectedSexo;
  List<String> sexos = ['Masculino', 'Femenino'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiCreateUser = '/api/user_cliente';
  int status = 0;

  //final _formKey = GlobalKey<FormState>();

//FUTURE DEL ARCHIVO ORIGINAL

  Future<dynamic> registrar(nombre, apellidos, dni, sexo, fecha, fechaAct,
      nickname, contrasena, email, telefono, ruc) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        });
    try {
      // Parsear la fecha de nacimiento a DateTime
      DateTime fechaNacimiento = DateFormat('d/M/yyyy').parse(fecha);

      // Formatear la fecha como una cadena en el formato deseado (por ejemplo, 'yyyy-MM-dd')
      String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaNacimiento);
      String fechaActual = DateFormat('yyyy-MM-dd').format(fechaAct);

      var res = await http.post(Uri.parse(apiUrl + apiCreateUser),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "rol_id": 4,
            "nickname": nickname,
            "contrasena": contrasena,
            "email": email,
            "nombre": nombre,
            "apellidos": apellidos,
            "telefono": telefono,
            "ruc": ruc ?? "",
            "dni": dni,
            "fecha_nacimiento": fechaFormateada,
            "fecha_creacion_cuenta": fechaActual,
            "sexo": sexo,
            "direccion_empresa": "NA",
            "suscripcion": "Básico",
            "nombre_empresa": "NA",
            "frecuencia": "NA",
            "quiereretirar": false,
            "medio_retiro": "NA",
            "banco_retiro": "NA",
            "numero_cuenta": "NA"
          }));
      if (res.statusCode == 200) {
        setState(() {
          status = 200;
        });
      } else if (res.statusCode == 401) {
        setState(() {
          status = 401;
        });
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime tiempoActual = DateTime.now();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double padding = 16.0;
          if (constraints.maxWidth >= Breakpoint.avgsmall &&
              constraints.maxWidth < Breakpoint.small) {
            padding = 24.0;
          } else if (constraints.maxWidth >= Breakpoint.small &&
              constraints.maxWidth < Breakpoint.avgmedium) {
            padding = 32.0;
          } else if (constraints.maxWidth >= Breakpoint.avgmedium) {
            padding = 40.0;
          }

          return Stack(
            children: [
              // Imagen de fondo
              Positioned.fill(
                child: Image.asset(
                  'lib/imagenes/diseño_register_final.png', // Asegúrate de tener la imagen en la carpeta assets y agregarla en pubspec.yaml
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Image.asset(
                                  'lib/imagenes/nuevito.png', // Asegúrate de tener el logo en la carpeta assets y agregarla en pubspec.yaml
                                  height: 75,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Registrate y sorprendete!',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 0),
                                    Text(
                                      'sorprendete!',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Vive bien, vive sano!',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nombres,
                                decoration: InputDecoration(
                                  labelText: 'Nombres',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintText: 'Ingrese sus Nombres',
                                  isDense: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _apellidos,
                                decoration: InputDecoration(
                                  labelText: 'Apellidos',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintText: 'Ingrese sus Apellidos',
                                  isDense: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _dni,
                                decoration: InputDecoration(
                                  labelText: 'Dni',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintText: 'Ingrese su DNI',
                                  isDense: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: selectedSexo,
                                onChanged: (value) {
                                  setState(() {
                                    selectedSexo = value;
                                  });
                                },
                                items: sexos.map((sexo) {
                                  return DropdownMenuItem<String>(
                                    value: sexo,
                                    child: Text(sexo),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText: 'Sexo',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  //hintText: 'Ingrese sus Apellidos',
                                  isDense: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(1),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                readOnly: true,
                                controller: _fechaController,
                                onTap: () async {
                                  // Abre el selector de fechas cuando se hace clic en el campo
                                  DateTime? fechaSeleccionada =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime(2101),
                                  );

                                  if (fechaSeleccionada != null) {
                                    // Actualiza el valor del campo de texto con la fecha seleccionada
                                    _fechaController.text =
                                        "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}";
                                  }
                                },
                                //keyboardType: TextInputType.datetime,

                                decoration: InputDecoration(
                                  labelText: 'Fecha nacimiento',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintText: 'Fecha nacimiento',
                                  isDense: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.datetime,
                                keyboardAppearance: Brightness.light,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _username,
                                decoration: InputDecoration(
                                  labelText: 'Usuario',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintText: 'Ingrese su usuario',
                                  isDense: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _password,
                                keyboardType: TextInputType.visiblePassword,
                                // obscureText:_obscureText,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintText: 'Ingrese una contraseña',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(0.8),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    child: Icon(
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                obscureText: _obscureText,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _telefono,
                                maxLength: 9,
                                decoration: InputDecoration(
                                  labelText: 'Teléfono',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintText: 'Ingrese su número',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(0.8),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _email,
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                                  hintText: 'Ingresa su email',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  //fillColor: Colors.white.withOpacity(0.8),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  } else if (value != null &&
                                      !(value.contains('@gmail.com') ||
                                          value.contains('@hotmail.com'))) {
                                    return 'No es un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Container(
                                height: 40,
                                width: MediaQuery.of(context).size.width / 1,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      // Process data
                                      await registrar(
                                          _nombres.text,
                                          _apellidos.text,
                                          _dni.text,
                                          selectedSexo,
                                          _fechaController.text,
                                          tiempoActual,
                                          _username.text,
                                          _password.text,
                                          _email.text,
                                          _telefono.text,
                                          _ruc.text);

                                      if (status == 200) {
                                        Navigator.of(context).pop();
                                        print("----entro al 200");
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              );
                                            });
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    5,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: const BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  'lib/imagenes/nuevecito.png'))),
                                                    ),
                                                    const SizedBox(
                                                      height: 19,
                                                    ),
                                                    Text(
                                                      "Felicitaciones!",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              25,
                                                          color: const Color
                                                              .fromARGB(255, 2,
                                                              100, 181)),
                                                    ),
                                                    const SizedBox(
                                                      height: 19,
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const Prelogin()),
                                                          );
                                                        },
                                                        child: const Text(
                                                          "OK",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 24,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      4,
                                                                      93,
                                                                      167)),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else if (status == 401) {
                                        print("entro al 40");
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    5,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: const BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  'lib/imagenes/nuevecito.png'))),
                                                    ),
                                                    const SizedBox(
                                                      height: 19,
                                                    ),
                                                    Text(
                                                      "Intente otro usuario por favor.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              25,
                                                          color: const Color
                                                              .fromARGB(255, 2,
                                                              100, 181)),
                                                    ),
                                                    const SizedBox(
                                                      height: 19,
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                          "OK",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 24,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      4,
                                                                      93,
                                                                      167)),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 63, 108, 232),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      )),
                                  child: const Text(
                                    "Registrarse",
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿Ya tienes cuenta?',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Prelogin(),
                                    ));
                                // Navegar a la página de inicio de sesión
                              },
                              child: const Text(
                                'Inicia Sesión',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
