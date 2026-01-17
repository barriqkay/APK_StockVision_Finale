import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();
  Map<String, dynamic>? latest;
  Map<String, dynamic>? prediction;
  bool loading = false;

  void fetchData() async {
    setState(() => loading = true);
    try {
      final latestData = await api.getLatest();
      setState(() => latest = latestData);
      
      // Also fetch prediction
      final pred = await api.predictNext();
      setState(() => prediction = pred);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GGRM Prediction Dashboard'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            onPressed: fetchData,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh data',
          )
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Latest Price Card
                    Text(
                      'Current Price',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        width: double.infinity,
                        child: latest == null
                            ? Text('No data available')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GGRM.JK',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Rp ${latest!['ohlcv']['close'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoItem('Open', 'Rp ${latest!['ohlcv']['open'].toStringAsFixed(0)}'),
                                      _buildInfoItem('High', 'Rp ${latest!['ohlcv']['high'].toStringAsFixed(0)}'),
                                      _buildInfoItem('Low', 'Rp ${latest!['ohlcv']['low'].toStringAsFixed(0)}'),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Date: ${latest!['date']}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Prediction Card
                    Text(
                      'Next Day Prediction',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.green[50]!, Colors.blue[50]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: prediction == null
                            ? Text('No prediction available')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Predicted Close Price',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Rp ${prediction!['predicted_close'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildPredictionItem(
                                        'Change',
                                        'Rp ${prediction!['price_change'].toStringAsFixed(0)}',
                                        prediction!['price_change'] >= 0 ? Colors.green : Colors.red,
                                      ),
                                      _buildPredictionItem(
                                        'Percentage',
                                        '${prediction!['pct_change'].toStringAsFixed(2)}%',
                                        prediction!['pct_change'] >= 0 ? Colors.green : Colors.red,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Confidence: ${prediction!['confidence']} | Updated: ${prediction!['last_update']}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Tools
                    Text(
                      'Tools',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/predict'),
                          icon: Icon(Icons.show_chart),
                          label: Text('Predict'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showHistory(),
                          icon: Icon(Icons.history),
                          label: Text('History'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPredictionItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _showHistory() async {
    try {
      final history = await api.getHistory();
      if (history != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Price History'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Data points: ${history['data_points']}'),
                  SizedBox(height: 12),
                  Text('Period: ${history['period']}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close'))],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
    );
  }
}
