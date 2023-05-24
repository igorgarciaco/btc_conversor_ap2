import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BitcoinConverter(),
    );
  }
}

class BitcoinConverter extends StatefulWidget {
  @override
  _BitcoinConverterState createState() => _BitcoinConverterState();
}

class _BitcoinConverterState extends State<BitcoinConverter> {
  double _bitcoinPrice = 0.0;
  double _bitcoinAmount = 0.0;
  double _convertedAmount = 0.0;
  bool _isBitcoinToReal = true;

  void _fetchBitcoinPrice() async {
    final response = await http.get(
        Uri.parse('https://api.coindesk.com/v1/bpi/currentprice/BRL.json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _bitcoinPrice = data['bpi']['BRL']['rate_float'];
        _convertedAmount = _isBitcoinToReal
            ? _bitcoinAmount * _bitcoinPrice
            : _bitcoinAmount / _bitcoinPrice;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBitcoinPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitcoin Converter'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cotação do Bitcoin: R\$ $_bitcoinPrice',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  if (_isBitcoinToReal) {
                    _bitcoinAmount = double.tryParse(value) ?? 0.0;
                    _convertedAmount = _bitcoinAmount * _bitcoinPrice;
                  } else {
                    _convertedAmount = double.tryParse(value) ?? 0.0;
                    _bitcoinAmount = _convertedAmount / _bitcoinPrice;
                  }
                });
              },
              decoration: InputDecoration(
                labelText:
                    _isBitcoinToReal ? 'Valor em Bitcoin' : 'Valor em Real',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text(
              _isBitcoinToReal ? 'Valor em Real:' : 'Valor em Bitcoin:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              _isBitcoinToReal
                  ? 'R\$ $_convertedAmount'
                  : '$_convertedAmount BTC',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isBitcoinToReal = !_isBitcoinToReal;
                });
              },
              child: Text(_isBitcoinToReal
                  ? 'Converter para Bitcoin'
                  : 'Converter para Real'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchBitcoinPrice,
              child: Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
