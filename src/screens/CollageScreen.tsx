import React, { useRef, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  Alert,
} from 'react-native';
import ViewShot from 'react-native-view-shot';
import * as MediaLibrary from 'expo-media-library';
import { createGridLayout, bringToFront, type Photo, type PhotoTransform } from '../lib/collage';
import DraggablePhoto from './DraggablePhoto';

type Props = {
  photos: Photo[];
  onRetake: () => void;
};

const { width } = Dimensions.get('window');
const CANVAS_SIZE = width - 32;

export default function CollageScreen({ photos, onRetake }: Props) {
  const [transforms, setTransforms] = useState<PhotoTransform[]>(() =>
    createGridLayout(photos, CANVAS_SIZE, CANVAS_SIZE)
  );
  const viewShotRef = useRef<ViewShot>(null);

  function handleBringToFront(id: string) {
    setTransforms((prev) => bringToFront(prev, id));
  }

  async function handleExport() {
    try {
      const { status } = await MediaLibrary.requestPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission needed', 'Allow photo access to save your collage.');
        return;
      }
      const uri = await viewShotRef.current?.capture?.();
      if (uri) {
        await MediaLibrary.saveToLibraryAsync(uri);
        Alert.alert('Saved!', 'Your collage was saved to your photo library.');
      }
    } catch (err) {
      Alert.alert('Export failed', String(err));
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Drag, pinch, and rotate your photos</Text>

      <ViewShot ref={viewShotRef} style={styles.canvas} options={{ format: 'png', quality: 1 }}>
        {transforms.map((t) => (
          <DraggablePhoto key={t.id} transform={t} onBringToFront={handleBringToFront} />
        ))}
      </ViewShot>

      <View style={styles.controls}>
        <TouchableOpacity style={styles.secondaryButton} onPress={onRetake}>
          <Text style={styles.secondaryButtonText}>Retake</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.button} onPress={handleExport}>
          <Text style={styles.buttonText}>Save collage</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f4f4f4', alignItems: 'center', paddingTop: 60 },
  title: { fontSize: 14, color: '#555', marginBottom: 12 },
  canvas: {
    width: CANVAS_SIZE,
    height: CANVAS_SIZE,
    backgroundColor: 'white',
    borderRadius: 12,
    overflow: 'hidden',
  },
  controls: { flexDirection: 'row', gap: 16, marginTop: 24 },
  button: { backgroundColor: '#111', paddingVertical: 12, paddingHorizontal: 24, borderRadius: 24 },
  buttonText: { color: 'white', fontWeight: '600' },
  secondaryButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#111',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 24,
  },
  secondaryButtonText: { color: '#111', fontWeight: '600' },
});
