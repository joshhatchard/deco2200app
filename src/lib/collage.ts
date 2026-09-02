/**
 * Pure collage logic — no React, no React Native imports here.
 *
 * Keeping this file framework-agnostic means that when you move to
 * higher fidelity (better gestures, Skia rendering, a web version,
 * whatever), this logic ports over unchanged. Only the rendering
 * layer (the screens) needs to be rebuilt.
 */

export type Photo = {
  id: string;
  uri: string;
};

export type PhotoTransform = {
  id: string;
  uri: string;
  x: number; // center x, in canvas coordinates
  y: number; // center y, in canvas coordinates
  width: number;
  height: number;
  scale: number;
  rotation: number; // degrees
  zIndex: number;
};

/**
 * Lays photos out in a simple non-overlapping grid as a sensible
 * starting point. The user can then drag/pinch/rotate from there.
 */
export function createGridLayout(
  photos: Photo[],
  canvasWidth: number,
  canvasHeight: number,
  padding = 12
): PhotoTransform[] {
  const count = photos.length;
  if (count === 0) return [];

  const columns = Math.ceil(Math.sqrt(count));
  const rows = Math.ceil(count / columns);

  const cellWidth = (canvasWidth - padding * (columns + 1)) / columns;
  const cellHeight = (canvasHeight - padding * (rows + 1)) / rows;
  const cellSize = Math.min(cellWidth, cellHeight);

  return photos.map((photo, index) => {
    const col = index % columns;
    const row = Math.floor(index / columns);

    const x = padding + cellSize / 2 + col * (cellSize + padding);
    const y = padding + cellSize / 2 + row * (cellSize + padding);

    return {
      id: photo.id,
      uri: photo.uri,
      x,
      y,
      width: cellSize,
      height: cellSize,
      scale: 1,
      rotation: 0,
      zIndex: index,
    };
  });
}

/**
 * Lays photos out in a loose, overlapping "scrapbook" style with
 * slight random rotation — an alternative starting layout worth
 * testing against the grid.
 */
export function createScrapbookLayout(
  photos: Photo[],
  canvasWidth: number,
  canvasHeight: number
): PhotoTransform[] {
  const baseSize = Math.min(canvasWidth, canvasHeight) * 0.45;

  return photos.map((photo, index) => {
    const x = canvasWidth * (0.3 + 0.4 * Math.random());
    const y = canvasHeight * (0.3 + 0.4 * Math.random());
    const rotation = -15 + Math.random() * 30;

    return {
      id: photo.id,
      uri: photo.uri,
      x,
      y,
      width: baseSize,
      height: baseSize,
      scale: 1,
      rotation,
      zIndex: index,
    };
  });
}

/** Bring a photo to the front, e.g. when the user starts dragging it. */
export function bringToFront(
  transforms: PhotoTransform[],
  id: string
): PhotoTransform[] {
  const maxZ = Math.max(...transforms.map((t) => t.zIndex), 0);
  return transforms.map((t) =>
    t.id === id ? { ...t, zIndex: maxZ + 1 } : t
  );
}

/** Apply an incremental pan/pinch/rotate gesture update to one photo. */
export function updateTransform(
  transforms: PhotoTransform[],
  id: string,
  delta: Partial<Pick<PhotoTransform, 'x' | 'y' | 'scale' | 'rotation'>>
): PhotoTransform[] {
  return transforms.map((t) => (t.id === id ? { ...t, ...delta } : t));
}
