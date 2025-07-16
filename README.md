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
- Vehicle detection is performed using the specified model.
- Results are published and available in the live view.

---

## Contributing

Contributions are welcome. Please open issues or submit pull requests.

## License

This project is licensed under the MIT License.