import React, { useState } from "react";
import type { Photo } from "../src/lib/collage";
import CameraScreen from "../src/screens/CameraScreen";
import CollageScreen from "../src/screens/CollageScreen";

export default function Page() {
  const [photos, setPhotos] = useState<Photo[] | null>(null);

  return photos ? (
    <CollageScreen photos={photos} onRetake={() => setPhotos(null)} />
  ) : (
    <CameraScreen onDone={setPhotos} />
  );
}
