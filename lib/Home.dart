import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List listaTarefas = [];
  TextEditingController controllerTarefa = TextEditingController();

  Future<File> getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  salvarTarefa() async {
    String textoDigitado = controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      listaTarefas.add(tarefa);
    });
    salvarArquivo();
    controllerTarefa.text = "";
  }

  salvarArquivo() async {
    var arquivo = await getFile();

    String dados = json.encode(listaTarefas);
    arquivo.writeAsString(dados);
  }

  lerAquivo() async {
    try {
      final arquivo = await getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget criarItemLista(context, index) {
    final item = listaTarefas[index]['titulo'];
    return Dismissible(
        key: Key(item),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          listaTarefas.removeAt(index);
          salvarArquivo();
        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text(listaTarefas[index]['titulo']),
          value: listaTarefas[index]['realizada'],
          onChanged: (valorAlterado) {
            setState(() {
              listaTarefas[index]['realizada'] = valorAlterado;
            });
            salvarArquivo();
          },
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lerAquivo().then((dados) {
      setState(() {
        listaTarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //salvarArquivo();
    //print("itens: " + listaTarefas.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de tarefas'),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                    controller: controllerTarefa,
                    decoration: InputDecoration(
                      labelText: 'Digite sua tarefa',
                    ),
                    onChanged: (text) {},
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        salvarTarefa();
                        Navigator.pop(context);
                      },
                      child: Text('Salvar'),
                    ),
                  ],
                );
              });
        },
      ),
      body: Column(
        children: [
          Text('dfgdfgd'),
          Expanded(
            child: ListView.builder(
              itemCount: listaTarefas.length,
              itemBuilder: criarItemLista,
            ),
          ),
        ],
      ),
    );
  }
}
