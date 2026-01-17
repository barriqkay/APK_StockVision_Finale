import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';

class PredictScreen extends StatefulWidget {
  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final Map<String, TextEditingController> ctrls = {
    'open': TextEditingController(),
    'high': TextEditingController(),
    'low': TextEditingController(),
    'close': TextEditingController(),
    'volume': TextEditingController(),
    'return1': TextEditingController(),
    'ma7': TextEditingController(),
    'ma21': TextEditingController(),
    'std7': TextEditingController(),
  };

  bool loading = false;
  Map<String, dynamic>? result;

  void doPredict() async {
    setState(() => loading = true);
    final payload = {
      'open': double.tryParse(ctrls['open']!.text) ?? 0,
      'high': double.tryParse(ctrls['high']!.text) ?? 0,
      'low': double.tryParse(ctrls['low']!.text) ?? 0,
      'close': double.tryParse(ctrls['close']!.text) ?? 0,
      'volume': double.tryParse(ctrls['volume']!.text) ?? 0,
      'return1': double.tryParse(ctrls['return1']!.text) ?? 0,
      'ma7': double.tryParse(ctrls['ma7']!.text) ?? 0,
      'ma21': double.tryParse(ctrls['ma21']!.text) ?? 0,
      'std7': double.tryParse(ctrls['std7']!.text) ?? 0,
    };

    try {
      final api = ApiService();
      final r = await api.predict(payload);
      setState(() => result = r);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Predict')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ...ctrls.keys.map((k) => Padding(padding: EdgeInsets.only(bottom: 10), child: InputField(controller: ctrls[k]!, label: k.toUpperCase(), hint: k))),
            loading ? Center(child: CircularProgressIndicator()) : CustomButton(label: 'Predict', onPressed: doPredict),
            SizedBox(height: 16),
            if (result != null) Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(children: [
                  Text('Predicted Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('${result!['predicted_close']}', style: TextStyle(fontSize: 22)),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
