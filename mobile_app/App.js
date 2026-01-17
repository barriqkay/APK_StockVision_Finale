import React, { useState } from 'react';
import { View, Text, Button, TextInput, StyleSheet, ScrollView, Alert } from 'react-native';

// EDIT: Set BASE_URL according to your environment.
// - On desktop (web): use http://localhost:8000
// - On Android emulator (AVD): use http://10.0.2.2:8000
// - On Expo Go device, use your machine IP like http://192.168.1.10:8000
const BASE_URL = 'http://10.0.2.2:8000';

export default function App() {
  const [latest, setLatest] = useState(null);
  const [prediction, setPrediction] = useState(null);
  const [inputs, setInputs] = useState({
    open: '', high: '', low: '', close: '', volume: '',
    return1: '', ma7: '', ma21: '', std7: ''
  });

  const fetchLatest = async () => {
    try {
      const res = await fetch(`${BASE_URL}/latest/GGRM.JK`);
      const j = await res.json();
      if (j.error) return Alert.alert('Error', j.error);
      setLatest(j);
    } catch (e) {
      Alert.alert('Network error', String(e));
    }
  };

  const doPredict = async () => {
    try {
      const payload = {
        open: parseFloat(inputs.open) || 0,
        high: parseFloat(inputs.high) || 0,
        low: parseFloat(inputs.low) || 0,
        close: parseFloat(inputs.close) || 0,
        volume: parseFloat(inputs.volume) || 0,
        return1: parseFloat(inputs.return1) || 0,
        ma7: parseFloat(inputs.ma7) || 0,
        ma21: parseFloat(inputs.ma21) || 0,
        std7: parseFloat(inputs.std7) || 0
      };

      const res = await fetch(`${BASE_URL}/predict`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const j = await res.json();
      if (j.error) return Alert.alert('Prediction error', j.error);
      setPrediction(j);
    } catch (e) {
      Alert.alert('Network error', String(e));
    }
  };

  const handleChange = (k, v) => setInputs(s => ({ ...s, [k]: v }));

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>GGRM Mobile (API Frontend)</Text>

      <View style={styles.section}>
        <Button title="Fetch Latest GGRM" onPress={fetchLatest} />
        {latest && (
          <View style={styles.result}>
            <Text>Date: {latest.date}</Text>
            <Text>Close: {latest.close}</Text>
            <Text>Open: {latest.open}</Text>
            <Text>Volume: {latest.volume}</Text>
          </View>
        )}
      </View>

      <View style={styles.section}>
        <Text style={styles.sub}>Predict Next Close</Text>
        {['open','high','low','close','volume','return1','ma7','ma21','std7'].map((k) => (
          <TextInput
            key={k}
            style={styles.input}
            placeholder={k}
            keyboardType="numeric"
            value={inputs[k]}
            onChangeText={(t) => handleChange(k, t)}
          />
        ))}

        <Button title="Predict" onPress={doPredict} />

        {prediction && (
          <View style={styles.result}>
            <Text>Predicted Close: {prediction.predicted_close}</Text>
            <Text>Timestamp: {prediction.timestamp}</Text>
          </View>
        )}
      </View>

      <View style={{ height: 60 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { padding: 20 },
  title: { fontSize: 20, fontWeight: 'bold', marginBottom: 12 },
  section: { marginBottom: 24 },
  sub: { fontWeight: '600', marginBottom: 8 },
  input: { borderWidth: 1, borderColor: '#ccc', padding: 8, marginBottom: 8, borderRadius: 6 },
  result: { marginTop: 12, padding: 10, backgroundColor: '#f6f6f6', borderRadius: 6 }
});
