import kaldiio

# Path to your ARK file
ark_path = '/home/dimitri/kaldi/egs/test_MFCC_pitch_tone_1_2_T/features/train/mfcc_pitch/raw_mfcc_pitch_train.3.ark'

# Load the ARK file
ark_generator = kaldiio.load_ark(ark_path)

# Extract the feature dimension from the first entry
for key, numpy_array in ark_generator:
    num_features = numpy_array.shape[0]
    feature_dim = numpy_array.shape[1]
    print(f"Number of features (rows) for key '{key}': {num_features}")
    print(f"Feature dimension for key '{key}': {feature_dim}")
    break  # Assuming all vectors have the same dimension, we only need the first entry
