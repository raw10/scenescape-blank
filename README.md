# SceneScape Blank

A minimal starter template for new SceneScape projects to get up and running in minutes.

## Features

- Clean project structure
- Ready for customization
- No dependencies included
- All images are pulled from Docker Hub—no additional build steps required

## Getting Started

1. Clone this repository:

    ```bash
    git clone https://github.com/raw10/scenescape-blank.git
    ```

2. Navigate to the project directory:

    ```bash
    cd scenescape-blank
    ```

3. Run the setup script to initialize the environment:

    ```bash
    ./setup.sh
    ```

   This will guide you through initialization and optionally start the environment with Docker Compose.

4. To start the environment manually at any time:

    ```bash
    docker compose up -d
    ```

5. To check running containers:

    ```bash
    docker compose ps
    ```

## Resetting the Environment

To completely reset the environment (remove all containers, volumes, secrets, and optionally images), run:

```bash
sudo ./reset.sh
```

> **Warning:** This is a destructive operation and will prompt for confirmation.

---

## Testing the System

Once the environment is running, you can test the system as follows:

1. **Add a Scene:**
   Use the SceneScape web interface or API to create a new scene.

2. **Add a Camera:**
   Add a camera to the scene with the ID `camera1`.

3. **Live View:**
   Open the live view for the camera. You should see the sample video playing with vehicle detections overlaid.

- The DLStreamer Pipeline Server is pre-configured to use the video file `car-detection.ts` for `camera1`.
- The pipeline configuration can be found in [`src/dlstreamer-pipeline-server/config.json`](src/dlstreamer-pipeline-server/config.json).

**Reference Pipeline Configuration:**

- The pipeline uses `multifilesrc` to loop the video file.
- Only .ts files will loop infinitely, so the setup script converts videos from .mp4 to .ts formats.
- Vehicle detection is performed using the specified model.
- Results are published and available in the live view.

---

## Camera & Model Configuration

### Changing the Model

- Edit [`src/dlstreamer-pipeline-server/config.json`](src/dlstreamer-pipeline-server/config.json).
- Locate the `"model"` property in the pipeline string for your camera (e.g. `model=/home/pipeline-server/models/intersection/openvino.xml`).
- Replace the path with your desired model file.
- Place your model deployment files in [`src/dlstreamer-pipeline-server/models/`](src/dlstreamer-pipeline-server/models/).

### Adding New Cameras or Videos

- Add a new entry to the `"pipelines"` array in [`src/dlstreamer-pipeline-server/config.json`](src/dlstreamer-pipeline-server/config.json).
- Specify a unique `"name"` and configure the pipeline string and parameters for the new camera.
- Make sure the `"cameraid"` in `"camera_config"` matches your new camera's ID.

### Updating Camera Calibrations

The camera calibration file is located at [`src/dlstreamer-pipeline-server/calibrations.json`](src/dlstreamer-pipeline-server/calibrations.json).
Each entry in this file is keyed by the camera ID as specified in your pipeline configuration. This allows you to provide unique calibration parameters for each camera.

#### **FOV Example (Recommended)**

```json
{
  "camera1": {
    "intrinsics": { "fov": 70 },
    "distortion": [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  }
}
```

- Use `"fov"` for a single diagonal field of view (FOV).
- The pipeline will compute `fx`, `fy`, `cx`, `cy` based on the frame resolution and diagonal FOV.

#### **HFOV/VFOV Example**

```json
{
  "camera1": { ... },
  "camera2": {
    "intrinsics": { "hfov": 70, "vfov": 45 },
    "distortion": [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  }
}
```

- Use `"hfov"` and `"vfov"` for configuring using horizontal and vertical fields of view.

#### **Direct Intrinsics Example (Advanced)**

```json
{
  "camera1": { ... },
  "camera2": { ... },
  "camera3": {
    "intrinsics": { "fx": 905, "fy": 905, "cx": 640, "cy": 360 },
    "distortion": [0.012,-0.123,0,0,0,0,0,0,0,0,0,0,0,0]
  }
}

```

- Only use direct intrinsics if you know the exact values for your camera and resolution.

### Configuring Confidence Thresholds

- Edit [`src/dlstreamer-pipeline-server/models/confidence_thresholds.json`](src/dlstreamer-pipeline-server/models/confidence_thresholds.json).
- Use a JSON object with `"default"` and optional per-class thresholds:

  ```json
  {
    "default": 0.5,
    "person": 0.8,
    "vehicle": 0.7
  }
  ```

- The pipeline server will filter detections below the specified thresholds for each class.

---

## Contributing

Contributions are welcome. Please open issues or submit pull requests.

## License

This project is licensed under the MIT License.