import React, { useState } from 'react';
import { Image, StyleSheet } from 'react-native';
import {
  Gesture,
  GestureDetector,
} from 'react-native-gesture-handler';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  runOnJS,
} from 'react-native-reanimated';
import type { PhotoTransform } from '../lib/collage';

type Props = {
  transform: PhotoTransform;
  onBringToFront: (id: string) => void;
};

/**
 * Handles the live drag/pinch/rotate interaction for one photo.
 * Gesture math lives here (framework-specific), but it reads its
 * starting values from the plain PhotoTransform object, so the
 * layout logic in lib/collage.ts stays the single source of truth
 * for "where things start."
 */
export default function DraggablePhoto({ transform, onBringToFront }: Props) {
  const translateX = useSharedValue(transform.x);
  const translateY = useSharedValue(transform.y);
  const scale = useSharedValue(transform.scale);
  const rotation = useSharedValue(transform.rotation);

  const startX = useSharedValue(0);
  const startY = useSharedValue(0);
  const startScale = useSharedValue(1);
  const startRotation = useSharedValue(0);

  const [, forceRender] = useState(0);

  const pan = Gesture.Pan()
    .onStart(() => {
      startX.value = translateX.value;
      startY.value = translateY.value;
      runOnJS(onBringToFront)(transform.id);
    })
    .onUpdate((e) => {
      translateX.value = startX.value + e.translationX;
      translateY.value = startY.value + e.translationY;
    });

  const pinch = Gesture.Pinch()
    .onStart(() => {
      startScale.value = scale.value;
    })
    .onUpdate((e) => {
      scale.value = startScale.value * e.scale;
    });

  const rotate = Gesture.Rotation()
    .onStart(() => {
      startRotation.value = rotation.value;
    })
    .onUpdate((e) => {
      rotation.value = startRotation.value + (e.rotation * 180) / Math.PI;
    });

  const composed = Gesture.Simultaneous(pan, pinch, rotate);

  const animatedStyle = useAnimatedStyle(() => ({
    position: 'absolute',
    left: translateX.value - transform.width / 2,
    top: translateY.value - transform.height / 2,
    width: transform.width,
    height: transform.height,
    zIndex: transform.zIndex,
    transform: [
      { scale: scale.value },
      { rotate: `${rotation.value}deg` },
    ],
  }));

  return (
    <GestureDetector gesture={composed}>
      <Animated.View style={animatedStyle}>
        <Image source={{ uri: transform.uri }} style={styles.image} />
      </Animated.View>
    </GestureDetector>
  );
}

const styles = StyleSheet.create({
  image: {
    width: '100%',
    height: '100%',
    borderRadius: 6,
    borderWidth: 2,
    borderColor: 'white',
  },
});
