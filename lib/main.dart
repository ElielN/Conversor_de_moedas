import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:http/http.dart' as http;
import 'dart:async'; //permita que faça requisições sem ficar esperando, o programa não irá ficar em espera ocupada
import 'dart:convert'; //Converter a response para json

const request = "https://api.hgbrasil.com/finance?format=json&key=8ff71cf8";

void main() async {
  runApp(MaterialApp(
    home: Home(),
  ));
}

Future<Map> getData() async {
  //Usa o future pra pegar algo que não vai ser retornadona mesma hora
  http.Response response = await http
      .get(request); //O await mostra que iremos esperar os dados chegarem
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0.0;
  double euro = 0.0;

  void _clear(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _isEmpty(String text){
    if(text.isEmpty){
      _clear();
    }
  }

  void _realChanged(String text){
    _isEmpty(text);
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);

  }
  void _dolarChanged(String text){
    _isEmpty(text);
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar)/euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    _isEmpty(text);
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro)/dolar).toStringAsFixed(2);
  }

  void fazNada(){
    print("SUA MAE AQUELA VAGABA!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Conversor de Moedas \$"),
          centerTitle: true,
          backgroundColor: Colors.amber,
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))],
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text( //Enquanto ele estiver obtendo os dados da API, a tela irá indicar que está carregando os dados
                      "Carregando dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                default: //Caso ele não esteja em nenhum dos estados anteriores
                  if(snapshot.hasError){
                    return Center(
                      child: Text(
                        "Erro ao Carregar Dados :(",
                        style: TextStyle(color: Colors.red, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.monetization_on, size:150.0, color: Colors.amber),
                          Divider(),
                          buildTextField("Reais", "R\$", realController, _realChanged),
                          Divider(height: 50.0),
                          buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                          Divider(height: 50.0),
                          buildTextField("Euros", "€\$", euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f){
  return TextField(
    controller: c,
    style: TextStyle(color: Colors.amber), //Define a cor do input (texto de entrada)
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        focusedBorder: OutlineInputBorder( //Define a cor da borda do campo input ao ser clicada
            borderSide: BorderSide(color: Colors.white, width: 0.0)
        ),
        enabledBorder: OutlineInputBorder( //Define a cor da borda do campo input antes de ser clicada
          borderSide: BorderSide(color: Colors.amber, width: 0.0),
        ),
        border: OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: TextStyle(color: Colors.amber)

    ),
    onChanged: (String c){
      f(c); //O nome disso é gambiarra
    },
  );
}
/*
Há uma maneria de definir cores temas para o app de forma que não precisa
ficar setando as opções de cores da borda. Eu preferi fazer setando os atributos.
O resultado seria o mesmo ao usar o seguinte código:


      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          )),
    ));
 */