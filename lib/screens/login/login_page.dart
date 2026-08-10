import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe o e-mail e a senha.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
      );
    } on FirebaseAuthException catch (erro) {
      if (!mounted) return;

      String mensagem;

      switch (erro.code) {
        case 'invalid-email':
          mensagem = 'E-mail inválido.';
          break;

        case 'user-disabled':
          mensagem = 'Este usuário está desativado.';
          break;

        case 'user-not-found':
          mensagem = 'Usuário não encontrado.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          mensagem = 'E-mail ou senha incorretos.';
          break;

        case 'too-many-requests':
          mensagem =
              'Muitas tentativas de acesso. Tente novamente mais tarde.';
          break;

        default:
          mensagem =
              'Não foi possível entrar. Verifique o e-mail e a senha.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(mensagem),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Ocorreu um erro ao fazer login.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 400,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'DS SOLUÇÕES',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Sistema de Gestão',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      decoration:
                          const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon:
                            Icon(Icons.email),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _senhaController,
                      obscureText: _ocultarSenha,
                      textInputAction:
                          TextInputAction.done,
                      onSubmitted: (_) {
                        if (!_carregando) {
                          _entrar();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon:
                            const Icon(Icons.lock),
                        border:
                            const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _ocultarSenha =
                                  !_ocultarSenha;
                            });
                          },
                          icon: Icon(
                            _ocultarSenha
                                ? Icons.visibility
                                : Icons
                                    .visibility_off,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFE30613,
                          ),
                          foregroundColor:
                              Colors.white,
                        ),
                        onPressed:
                            _carregando
                                ? null
                                : _entrar,
                        child: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'ENTRAR',
                                style:
                                    TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}