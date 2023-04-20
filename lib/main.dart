// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:num_to_words/num_to_words.dart';

void main() async {
  // Inicializa o Firebase antes de executar o aplicativo
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    );
  // Cria e executa o aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();

  void _addText() async {
    final text = _textController.text.trim();

    if (text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('numero').add({
       'numero': int.parse(text),
       'extenso': NumberToWord.convert(int.parse(text)),
       'timestamp': DateTime.now().toUtc().toString(),
      });
      

      _textController.clear();
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TextsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar número'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(hintText: 'Adicionar número'),
              ),
            ),
            ElevatedButton(
              onPressed: _addText,
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}

class TextsPage extends StatelessWidget {
  const TextsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Número'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
        .collection('numero')
        .orderBy('timestamp', descending: true)
        .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final texts = snapshot.data!.docs
              .map((doc) => '${doc['numero']} - ${doc['extenso']}')
              .toList();

          return ListView.builder(
            itemCount: texts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(texts[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class NumberToWord {
  static const List<String> units = [
    'zero',
    'um',
    'dois',
    'três',
    'quatro',
    'cinco',
    'seis',
    'sete',
    'oito',
    'nove',
    'dez',
    'onze',
    'doze',
    'treze',
    'quatorze',
    'quinze',
    'dezesseis',
    'dezessete',
    'dezoito',
    'dezenove'
  ];

  static const List<String> tens = [
    '',
    '',
    'vinte',
    'trinta',
    'quarenta',
    'cinquenta',
    'sessenta',
    'setenta',
    'oitenta',
    'noventa'
  ];

  static const List<String> hundreds = [
    '',
    'cem',
    'duzentos',
    'trezentos',
    'quatrocentos',
    'quinhentos',
    'seiscentos',
    'setecentos',
    'oitocentos',
    'novecentos'
  ];

  static String convert(int n) {
    if (n < 20) {
      return units[n];
    }
    if (n < 100) {
      return '${tens[n ~/ 10]}${n % 10 != 0 ? ' e ${units[n % 10]}' : ''}';
    }
    if (n < 1000) {
      return '${hundreds[n ~/ 100]}${n % 100 != 0 ? ' e ${convert(n % 100)}' : ''}';
    }
    throw ArgumentError('n deve ser menor que 1000');
  }
}
