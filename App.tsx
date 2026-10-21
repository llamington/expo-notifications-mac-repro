import * as Device from "expo-device";
import * as Notifications from "expo-notifications";
import { useState } from "react";
import { Button, ScrollView, StyleSheet, Text } from "react-native";

export default function App() {
  const [results, setResults] = useState<string[]>([]);

  async function run(label: string, fn: () => Promise<unknown>) {
    let entry: string;
    try {
      entry = `${label} resolved:\n${JSON.stringify(await fn(), null, 2)}`;
    } catch (error) {
      const e = error as { name?: string; code?: string; message?: string };
      entry = `${label} rejected:\n${JSON.stringify(
        { name: e.name, code: e.code, message: e.message },
        null,
        2,
      )}`;
    }
    console.log(entry);
    setResults((prev) => [entry, ...prev]);
  }

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text>
        modelId: {Device.modelId} | {Device.osName} {Device.osVersion}
      </Text>
      <Button
        title="getPermissionsAsync"
        onPress={() => run("getPermissionsAsync", Notifications.getPermissionsAsync)}
      />
      <Button
        title="requestPermissionsAsync"
        onPress={() =>
          run("requestPermissionsAsync", Notifications.requestPermissionsAsync)
        }
      />
      {results.map((r, i) => (
        <Text key={i} style={styles.result}>
          {r}
        </Text>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { padding: 24, paddingTop: 80, gap: 12 },
  result: { fontFamily: "Menlo", fontSize: 12 },
});
