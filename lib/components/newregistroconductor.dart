import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appsol_final/components/prelogin.dart';
import 'package:appsol_final/components/responsiveUI/breakpoint.dart';

class Registroconductor extends StatefulWidget {
  const Registroconductor({super.key});

  @override
  State<Registroconductor> createState() => _RegistroconductorState();
}

class _RegistroconductorState extends State<Registroconductor>{
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nombres = TextEditingController();
  final TextEditingController _apellidos = TextEditingController();
  final TextEditingController _dni = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _licencia = TextEditingController();
  final TextEditingController _soat = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  bool _obscureText = true;
  String? selectedSexo;
  List<String> sexos = ['Masculino', 'Femenino'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiCreateUser = '/api/user_conductor';
  int status = 0;
  DateTime? _selectedDate;

  //final _formKey = GlobalKey<FormState>();

//FUTURE DEL ARCHIVO ORIGINAL
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      locale: const Locale('es', ''), // Español
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.day}/${picked.month}/${picked.year}"; // Formato dd/MM/yyyy
      });
    }
  }

 Future<dynamic> registrar(nombre, apellidos, dni, fechaAct, nickname, contrasena, email, telefono, licencia, soat) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    },
  );

  try {
    // Parsear la fecha en el formato 'd/M/yyyy' (por ejemplo, '6/9/2024')
    DateTime fechaNacimiento = DateFormat('d/M/yyyy').parse(fechaAct);

    // Formatear la fecha como una cadena en el formato 'yyyy-MM-dd', compatible con el tipo DATE
    String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaNacimiento);
    
    print(".........");
    print("${nickname},${contrasena},$email,$nombre,$apellidos,$telefono,$fechaFormateada}");

    var res = await http.post(
      Uri.parse(apiUrl + apiCreateUser),
      headers: {"Content-type": "application/json"},
      body: jsonEncode({
        "rol_id": 5,
        "nickname": nickname,
        "contrasena": contrasena,
        "email": email ?? "NA",
        "nombres": nombre,
        "apellidos": apellidos,
        "licencia": licencia,
        "numero_soat": soat,
        "dni": dni,
        "telefono": telefono,
        "fecha_nacimiento": fechaFormateada,  // Formato compatible con DATE
        "soat": soat,
        "estado": "desconectado"
      }),
    );

    print("res----");
    print(res.body);

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

  //VISTA PRINCIPAL RESPONSIVA
  Widget registra(String tama, double ancho, double alto, double texto1) {
    
    return Stack(
      children: [
        // Imagen de fondo
        Positioned.fill(
          child: Image.asset(
            'lib/imagenes/aguamarina2.png', // Asegúrate de tener la imagen en la carpeta assets y agregarla en pubspec.yaml
            fit: BoxFit.cover,
          ),
        ),
        //Text("${tama} ${MediaQuery.of(context).size.width}}"),
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(texto1),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height/13,
                          decoration:const BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('lib/imagenes/nuevito.png'))),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¡Trabaja con nosotros!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width/15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 0),
                              SizedBox(height: 8),
                              /*Text(
                                'Vive bien, vive sano!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),*/
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            controller: _nombres,
                            decoration: const InputDecoration(
                              labelText: 'Nombres',

                              labelStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey
                                  //color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                              hintStyle: const TextStyle(
                                  fontSize: 17, color: Colors.grey
                                  //color: Color.fromARGB(255, 43, 48, 170),
                                  ),
                              hintText: 'Ingrese sus Nombres',
                              isDense: true,
                              border: InputBorder.none,
                              //filled: true,
                              //fillColor: Colors.white.withOpacity(1),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            controller: _apellidos,
                            decoration: const InputDecoration(
                              labelText: 'Apellidos',
                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                              hintText: 'Ingrese sus Apellidos',
                              isDense: true,
                              border: InputBorder.none,
                              //filled: true,
                              //fillColor: Colors.white.withOpacity(1),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 20,right: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white
                          ),
                          child: TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de nacimiento',
                              hintText: 'Fecha de nacimiento',
                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (value) {
                              if(value==null || value.isEmpty){
                                return 'El campo es obligatorio';
                              }
                              return null;
                            },
                            onTap: () {
                              _selectDate(context);
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: TextFormField(
                            controller: _telefono,
                            maxLength: 9,
                            decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                labelStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                hintStyle: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey,
                                ),
                                hintText: 'Ingrese su número',
                                isDense: true,
                                border: InputBorder.none,
                                //filled: true,
                                counterText: ''
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
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            controller: _dni,
                            decoration: const InputDecoration(
                              labelText: 'DNI',
                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                              hintText: 'Ingrese su DNI',
                              isDense: true,
                              border: InputBorder.none,
                              //filled: true,
                              //fillColor: Colors.white.withOpacity(1),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),
                        //const SizedBox(height: 4),
                        /*DropdownButtonFormField<String>(
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
                              ),*/
                        const SizedBox(height: 4),
                        /*TextFormField(
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
                              ),*/
                        //const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                                labelText: 'E-mail(Opcional)',
                                labelStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                hintStyle: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey,
                                ),
                                hintText: 'Ingresa su email',
                                isDense: true,
                                border: InputBorder.none
                                //filled: true,
                                //fillColor: Colors.white.withOpacity(0.8),
                                ),
                            keyboardType: TextInputType.emailAddress,
                           /* validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es obligatorio';
                              } else if (value != null &&
                                  !(value.contains('@gmail.com') ||
                                      value.contains('@hotmail.com'))) {
                                return 'No es un correo válido';
                              }
                              return null;
                            },*/
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: TextFormField(
                            controller: _username,
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                              hintText: 'Ingrese su usuario',
                              isDense: true,
                              border: InputBorder.none,
                              //filled: true,
                              //fillColor: Colors.white.withOpacity(1),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 4),

                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            controller: _password,
                            keyboardType: TextInputType.visiblePassword,
                            // obscureText:_obscureText,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                              hintText: 'Ingrese una contraseña',
                              isDense: true,
                              border: InputBorder.none,
                              //filled: true,
                              //fillColor: Colors.white.withOpacity(0.8),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility_outlined
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
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            controller: _licencia,
                            // obscureText:_obscureText,
                            decoration: const InputDecoration(
                              labelText: 'Licencia',
                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                              hintText: 'Ingrese una licencia',
                              isDense: true,
                              border: InputBorder.none,
                              //filled: true,
                              //fillColor: Colors.white.withOpacity(0.8),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            controller: _soat,
                            // obscureText:_obscureText,
                            decoration: const InputDecoration(
                              labelText: 'Número de SOAT',
                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                              hintText: 'Ingrese un número de soat',
                              isDense: true,
                              border: InputBorder.none,
                              //filled: true,
                              //fillColor: Colors.white.withOpacity(0.8),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width / 1,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Process data
                                // sexo,fechanacimiento,ruc
                                await registrar(
                                    _nombres.text,
                                    _apellidos.text,
                                    _dni.text,
                                  _dateController.text,
                                    _username.text,
                                    _password.text,
                                    _email.text,
                                    _telefono.text,
                                    _licencia.text,
                                    _soat.text
                                    );

                                if (status == 200) {
                                  Navigator.of(context).pop();
                                 // print("----entro al 200");
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        );
                                      });
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
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
                                                height: 17,
                                              ),
                                              Text(
                                                "¡Registro exitoso!",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            25,
                                                    color: const Color.fromARGB(
                                                        255, 2, 100, 181)),
                                              ),
                                              const SizedBox(
                                                height: 19,
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Prelogin()),
                                                    );
                                                  },
                                                  child:  Text(
                                                    "OK",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(context).size.width/23,
                                                        color: const Color.fromARGB(
                                                            255, 4, 93, 167)),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else if (status == 401) {
                                 // print("entro al 40");
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              4.5,
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
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            25,
                                                    color: const Color.fromARGB(
                                                        255, 2, 100, 181)),
                                              ),
                                              const SizedBox(
                                                height: 19,
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                       fontSize: MediaQuery.of(context).size.width/23,
                                                        color:const Color.fromARGB(
                                                            255, 4, 93, 167)),
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
                                backgroundColor:
                                    const Color.fromRGBO(0, 77, 255, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                            child: const Text(
                              "Registrarse",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('¿Ya tienes cuenta?',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(84, 226, 132, 1)),
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
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= Breakpoint.xsmall) {
            return registra("XS", 100, 85, 10);
          } else if (constraints.maxWidth <= Breakpoint.avgsmall) {
            return registra("avS", 110, 100, 13.0);
          } else if (constraints.maxWidth <= Breakpoint.small) {
            return registra("S", 140, 140, 18); // PUNTO CLAVE
          } else if (constraints.maxWidth <= Breakpoint.avgmedium) {
            return registra("avM", 160, 160, 18);
          } else if (constraints.maxWidth <= Breakpoint.medium) {
            return registra("M", 220, 180, 18);
          } else if (constraints.maxWidth <= Breakpoint.avglarg) {
            return registra("avL", 220, 200, 18);
          } else if (constraints.maxWidth <= Breakpoint.large) {
            return registra("L", 220, 220, 18);
          } else if (constraints.maxWidth <= Breakpoint.avgxlarge) {
            return registra("avXL", 240, 240, 18);
          } else {
            return registra("XL", 260, 260, 18);
          }
        },
      ),
    );
  }
}