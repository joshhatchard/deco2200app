import React, { useRef, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Image,
  FlatList,
} from 'react-native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import type { Photo } from '../lib/collage';

type Props = {
  onDone: (photos: Photo[]) => void;
};

let nextId = 0;

export default function CameraScreen({ onDone }: Props) {
  const [permission, requestPermission] = useCameraPermissions();
  const cameraRef = useRef<CameraView>(null);
  const [photos, setPhotos] = useState<Photo[]>([]);

  if (!permission) {
    // Permission state still loading.
    return <View style={styles.center} />;
  }

  if (!permission.granted) {
    return (
      <View style={styles.center}>
        <Text style={styles.message}>We need camera access to take collage photos.</Text>
        <TouchableOpacity style={styles.button} onPress={requestPermission}>
          <Text style={styles.buttonText}>Grant permission</Text>
        </TouchableOpacity>
      </View>
    );
  }

  async function takePhoto() {
    if (!cameraRef.current) return;
    const result = await cameraRef.current.takePictureAsync({ quality: 0.7 });
    if (result?.uri) {
      setPhotos((prev) => [...prev, { id: String(nextId++), uri: result.uri }]);
    }
  }

  return (
    <View style={styles.container}>
      <CameraView ref={cameraRef} style={styles.camera} facing="back" />

      {photos.length > 0 && (
        <FlatList
          data={photos}
          horizontal
          keyExtractor={(item) => item.id}
          style={styles.filmstrip}
          renderItem={({ item }) => (
            <Image source={{ uri: item.uri }} style={styles.thumb} />
          )}
        />
      )}

      <View style={styles.controls}>
        <TouchableOpacity style={styles.shutter} onPress={takePhoto} />
        <TouchableOpacity
          style={[styles.button, photos.length === 0 && styles.buttonDisabled]}
          disabled={photos.length === 0}
          onPress={() => onDone(photos)}
        >
          <Text style={styles.buttonText}>Make collage ({photos.length})</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: 'black' },
  camera: { flex: 1 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 24 },
  message: { textAlign: 'center', marginBottom: 16, color: '#333' },
  filmstrip: { position: 'absolute', bottom: 140, left: 0, right: 0, paddingHorizontal: 8 },
  thumb: { width: 56, height: 56, borderRadius: 8, marginRight: 8, borderWidth: 2, borderColor: 'white' },
  controls: {
    position: 'absolute',
    bottom: 24,
    left: 0,
    right: 0,
    alignItems: 'center',
    gap: 16,
  },
  shutter: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: 'white',
    borderWidth: 4,
    borderColor: '#ddd',
  },
  button: {
    backgroundColor: '#111',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 24,
  },
  buttonDisabled: { opacity: 0.4 },
  buttonText: { color: 'white', fontWeight: '600' },
});
