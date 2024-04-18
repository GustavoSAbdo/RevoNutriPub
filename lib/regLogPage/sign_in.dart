import 'package:complete/regLogPage/password_field.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:complete/regLogPage/sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:complete/hive/hive_user.dart';

class CustomSignInScreen extends StatefulWidget {
  const CustomSignInScreen({super.key});

  @override
  _CustomSignInScreenState createState() => _CustomSignInScreenState();
}

class _CustomSignInScreenState extends State<CustomSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetPasswordController = TextEditingController();

  Future<void> _signIn() async {
  if (_formKey.currentState!.validate()) {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Assumindo que o login foi bem-sucedido, obtém os dados do usuário
      await fetchAndStoreUserData(userCredential.user!.uid);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      bool hasCompletedSecondaryRegistration = userData['regDois'] ?? false;

      if (hasCompletedSecondaryRegistration) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/registerDois');
      }

      // Salva o e-mail do usuário se _saveEmail for verdadeiro
      if (_saveEmail.value) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _emailController.text.trim());
        await prefs.setBool('saveEmail', _saveEmail.value);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'Email ou senha incorretos. Por favor verifique seus dados e tente novamente.';
          break;
        default:
          errorMessage = 'Ocorreu um erro ao fazer login.';
          break;
      }
      _showErrorDialog(errorMessage);
    }
  }
}

Future<void> fetchAndStoreUserData(String userId) async {
  final userBox = Hive.box<HiveUser>('userBox');
  HiveUser? hiveUser = userBox.get(userId);

  if (hiveUser == null) {
    // Se não há dados no Hive, busca do Firebase
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var userData = userDoc.data() as Map<String, dynamic>;

    hiveUser = HiveUser(
      altura: double.tryParse(userData['altura']?.toString() ?? '0.0') ?? 0.0,
      idade: int.tryParse(userData['idade']?.toString() ?? '0') ?? 0,
      multiplicadorGord: double.tryParse(userData['multiplicadorGord']?.toString() ?? '0.0') ?? 0.0,
      multiplicadorProt: double.tryParse(userData['multiplicadorProt']?.toString() ?? '0.0') ?? 0.0,
      numRefeicoes: int.tryParse(userData['numRefeicoes']?.toString() ?? '0') ?? 0,
      peso: double.tryParse(userData['peso']?.toString() ?? '0.0') ?? 0.0,
      nivelAtividade: userData['nivelAtividade'] as String,
      objetivo: userData['objetivo'] as String,
      refeicaoPosTreino: int.tryParse(userData['refeicaoPosTreino']?.toString() ?? '0') ?? 0,
      tmb: double.tryParse(userData['tmb']?.toString() ?? '0.0') ?? 0.0,
    );

    // Salva os dados no Hive
    await userBox.put(userId, hiveUser);
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  final ValueNotifier<bool> _saveEmail = ValueNotifier<bool>(false);

  Future<void> _loadSaveEmailPreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? savedSaveEmail = prefs.getBool('saveEmail');
      if (savedSaveEmail != null) {
        _saveEmail.value = savedSaveEmail;
      }
    } catch (e) {
      _showErrorDialog('Erro ao carregar a preferência de salvar e-mail');
    }
  }

  Future<void> _loadEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      if (savedEmail != null) {
        _emailController.text = savedEmail;
      }
    } catch (e) {
      _showErrorDialog('Erro ao carregar o e-mail salvo');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    await _loadEmail();
    await _loadSaveEmailPreference();
  }

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_loadEmail(), _loadSaveEmailPreference()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text("")),
            body: SingleChildScrollView(
              // Adicionado SingleChildScrollView aqui
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0), // Adicionado padding aqui
                        child: Image.asset('assets/images/logo.png',
                            width: 150, height: 150),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu e-mail';
                          }
                          if (!RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b')
                              .hasMatch(value)) {
                            return 'Por favor, insira um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _saveEmail,
                        builder: (context, saveEmail, child) {
                          return CheckboxListTile(
                            title: const Text("Salvar e-mail"),
                            value: saveEmail,
                            onChanged: (newValue) {
                              _saveEmail.value = newValue ?? _saveEmail.value;
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                      PasswordField(
                        controller: _passwordController,
                        labelText: "Senha",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          return null; // Retorna null se o valor passar na validação
                        },
                      ),
                      SignInButton(
                        formKey: _formKey,
                        signIn: _signIn,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Ainda não tem conta?"),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/register');
                            },
                            child: const Text('Registre-se'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Esqueceu sua senha?"),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Redefinir senha'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: _resetPasswordController,
                                        decoration: const InputDecoration(
                                            labelText: 'Digite seu e-mail'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, insira seu e-mail';
                                          }
                                          if (!RegExp(
                                                  r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b')
                                              .hasMatch(value)) {
                                            return 'Por favor, insira um e-mail válido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseAuth.instance
                                              .sendPasswordResetEmail(
                                            email: _resetPasswordController.text
                                                .trim(),
                                          );
                                          Navigator.of(context).pop();
                                        } on FirebaseAuthException catch (e) {
                                          String errorMessage;
                                          switch (e.code) {
                                            case 'user-not-found':
                                              errorMessage =
                                                  'Nenhum usuário encontrado com esse e-mail.';
                                              break;
                                            default:
                                              errorMessage =
                                                  'Ocorreu um erro ao redefinir a senha.';
                                              break;
                                          }
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  'Erro ao redefinir senha'),
                                              content: Text(errorMessage),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Enviar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Clique aqui'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
