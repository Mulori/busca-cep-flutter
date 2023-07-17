import 'package:cep/models/endereco_model.dart';
import 'package:cep/repositories/cep_repository.dart';
import 'package:cep/repositories/cep_repository_impl.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CepRepository cepRepository = CepRepositoryImpl();
  EnderecoModel? enderecoModel;
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  final cepEC = TextEditingController();

  @override
  void dispose() {
    cepEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
          key: formKey,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(25.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Busca CEP Flutter',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    TextFormField(
                      controller: cepEC,
                      maxLength: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ('O CEP é obrigatório');
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          final valid =
                              formKey.currentState?.validate() ?? false;

                          if (valid) {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              final endereco =
                                  await cepRepository.getCep(cepEC.text);

                              setState(() {
                                enderecoModel = endereco;
                                isLoading = false;
                              });
                            } on Exception catch (e) {
                              setState(() {
                                enderecoModel = null;
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Erro ao buscar endereço')));
                            }
                          }
                        },
                        child: const Text('Buscar')),
                    Visibility(
                        visible: isLoading, child: CircularProgressIndicator()),
                    Visibility(
                        visible: enderecoModel != null,
                        child: Text(
                          '${enderecoModel?.cep} ${enderecoModel?.logradouro} ${enderecoModel?.complemento}',
                          textAlign: TextAlign.center,
                        ))
                  ]),
            ),
          )),
    );
  }
}
