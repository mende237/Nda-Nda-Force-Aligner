# Acoustic Model Training and Evaluation

This project provides scripts for training and evaluating acoustic models using monophones and triphones with various configurations. The scripts handle data preparation, feature extraction, model training, alignment, and evaluation.

## Table of Contents

- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Nda' Nda'](#ndanda)
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
    git clone https://github.com/mende237/Nda-Nda-Force-Aligner.git
    cd Nda-Nda-Force-Aligner
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

![Kaldi Folder Structure](https://www.researchgate.net/publication/344438159/figure/fig24/AS:962084204474369@1606390157352/Figure-E1-summarizes-the-standard-files-and-directories-of-a-custom-Kaldi-project.png)
</p>

3. Configure the `main.sh` script with your project-specific settings. For the beginning, you must only configure the project folder path and data root folder path. Inside this file, there is one variable named `project_name`. Set this variable with your `<project_name>`. Check also the variable named `data_root` and set it to the data root you downloaded using this [link](https://drive.google.com/drive/folders/1tY8o_-wLLheOs6_wHTcrOhRNXHpD0dI0?usp=drive_link). Example:

```sh
data_root="/home/dimitri/Documents/memoire/data/mono"
project_name="test_MFCC_pitch_tone_1_2"
```

**NB:** The path to data is the one that directly leads to the folder containing the file named `utterance.txt`.

4. Run the main script:
    ```sh
    ./main.sh
    ```
This command will automatically perform all tasks from data preparation to evaluation, including feature extraction and model training (acoustic and language models). Four acoustic models will be trained:
- Monophone HMM
- Triphone HMM
- Triphone HMM + SAT
- Hybrid HMM-DNN

The training results will be stored respectively in the following files:
- `YOUR_KALDI_INSTALLATION_PATH/egs/PROJECT_NAME/exp/train_mono_50_per_spk/decode/scoring_kaldi/best_wer`
- `YOUR_KALDI_INSTALLATION_PATH/egs/PROJECT_NAME/exp/train_tri_delta_delta_50_per_spk/decode/scoring_kaldi/best_wer`
- `YOUR_KALDI_INSTALLATION_PATH/egs/PROJECT_NAME/exp/train_tri_sat_50_per_spk/decode/scoring_kaldi/best_wer`
- `YOUR_KALDI_INSTALLATION_PATH/egs/PROJECT_NAME/exp/tri4_nnet/decode/scoring_kaldi/best_wer`

The evaluation metric is WER (Word Error Rate).
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