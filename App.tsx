import React, { useState } from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { StatusBar } from 'expo-status-bar';
import CameraScreen from './src/screens/CameraScreen';
import CollageScreen from './src/screens/CollageScreen';
import type { Photo } from './src/lib/collage';

export default function App() {
  const [photos, setPhotos] = useState<Photo[] | null>(null);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <StatusBar style="auto" />
      {photos ? (
        <CollageScreen photos={photos} onRetake={() => setPhotos(null)} />
      ) : (
        <CameraScreen onDone={setPhotos} />
      )}
    </GestureHandlerRootView>
  );
}
