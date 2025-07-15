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

## Contributing

Contributions are welcome. Please open issues or submit pull requests.

## License

This project is licensed under the MIT License.