# Acoustic Model Training and Evaluation

This project provides scripts for training and evaluating acoustic models using monophones and triphones with various configurations. The scripts handle data preparation, feature extraction, model training, alignment, and evaluation.

## Table of Contents

- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Scripts Overview](#scripts-overview)
<!-- - [Configuration](#Configuration) -->
- [Contributing](#contributing)
- [License](#license)

## Project Structure
```
configs/
    └── Config.json
evaluation/
    ├── evaluation.sh
    └── make_graph.sh
feature_extractions/
    └── features_extractions.sh
logs/
    └── error.log
main.sh
README.md
requirements.sh
requirements.txt
training/
    ├── acoustic_model/
    └── language_model/
Utils/
    ├── data_preparation/
    ├── init_kaldi_projet_structure/
    ├── phone_statistics/
    │   └── phone_statistics.sh
    ├── utils.sh
    ├── view_ark_file.py
    └── word_count_occurence.py
```

## Requirements

- Kaldi
- Python 3.x
- NumPy
- Matplotlib
- etc
- Check the `requirements.txt` and `requirements.sh` for more details


## Installation
1. Ensure Kaldi is installed and properly configured. Follow the [Kaldi installation guide](http://kaldi-asr.org/doc/install.html) for detailed instructions.

2. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/yourproject.git
    cd yourproject
    ```

3. Install the required Python packages to your Python virtual environment:
    ```sh
    pip install -r requirements.txt
    ```
 
3. shell dependencies  
    Install `jq`:
    ```sh
    sudo apt-get install jq
    ```
    or ensure that the `requirements.sh` file has execution rights and run:
    ```sh
    chmod +x requirements.sh
    ./requirements.sh
    ```


## Configuration

### Configuring `Config.json`

The `Config.json` file contains paths to your Kaldi installation and Python virtual environment. Here is an example configuration:

```json
{
    "kaldi_installation_path" : "/home/dimitri/kaldi",
    "python_virtual_environement_path" : "/home/dimitri/NdaNdaForceAligner/myvenv"
}
```

### Setting Environment Variables

To set the Kaldi installation path as an environment variable, add the following line to your `~/.bashrc` file, replacing the path with your own Kaldi installation path:

```sh
echo 'export KALDI_INSTALLATION_PATH="/home/dimitri/kaldi"' >> ~/.bashrc
```

## Usage

1. Prepare your data by placing it in the appropriate directories. You can get the data by using this [link](https://drive.google.com/drive/folders/1tY8o_-wLLheOs6_wHTcrOhRNXHpD0dI0?usp=drive_link). Inside this drive folder, you will find two folders: `mono` and `stereo`. The `mono` folder contains audio data with one channel, and the `stereo` folder contains the same data with two channels. It is recommended to use the `mono` data.
2. Run the `initialize.sh` script located in the `init_kaldi_projet_structure/` folder. Change the directory to `init_kaldi_projet_structure/` and run the command below, where `<project_name>` is the name of the folder that will contain all the data in Kaldi format:

    ```sh
    ./initialize.sh <project_name>
    ```

    This script will create a folder named `<project_name>` inside `YOUR_KALDI_INSTALLATION_PATH/egs`. The created folder will contain all the necessary subfolders required by Kaldi to train a model.
<p align="center">
    <img src="https://maelfabien.github.io/assets/images/directorystructure.png" alt="Kaldi Folder Structure">
</p>
2. Configure the `main.sh` script with your project-specific settings.

3. Run the main script:
    ```sh
    ./main.sh
    ```

## Scripts Overview

### `main.sh`

The main script orchestrates the entire process, including data preparation, feature extraction, model training, alignment, and evaluation.

### `monophone_count.py`

This script counts the occurrences of monophones and tones, saves the results to CSV files, and generates distribution graphs.

### `triphone_count.py`

This script counts the occurrences of triphones, saves the results to CSV files, and generates distribution graphs.

### `Utils/data_preparation/main_data_preparation.sh`

Prepares the data for training and evaluation.

### `Utils/feature_extractions/features_extractions.sh`

Extracts features from the data for training and testing.

### `training/acoustic_model/monophone_trainning.sh`

Trains monophone acoustic models.

### `training/acoustic_model/triphone_training.sh`

Trains triphone acoustic models with various configurations.

### `training/acoustic_model/align.sh`

Aligns the data using the trained models.

### `evaluation/evaluation.sh`

Evaluates the trained models on test data.

### `evaluation/make_graph.sh`

Constructs the graph for decoding.

<!-- ## Configuration

The `main.sh` script contains several configuration options, such as:

- `project_name`: Name of the project.
- `data_root`: Root directory for the data.
- `nbr_job_feature_extraction`: Number of jobs for feature extraction.
- `nbr_job_trainning`: Number of jobs for training.
- `trainning_type`: Type of training to perform (1-5). -->

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.