import argparse
from textgrid import TextGrid
import os

def textgrid_to_ctm(textgrid_file, tier_name, tier_index, ctm_output_file):
    """
    Converts a specific tier of a TextGrid file to a CTM file.

    Parameters:
        textgrid_file (str): Path to the TextGrid file.
        tier_name (str or None): Name of the tier to extract.
        tier_index (int or None): Index of the tier to extract.
        ctm_output_file (str): Path to save the resulting CTM file.
    """
    tg = TextGrid()
    tg.read(textgrid_file)

    # Select tier by index or name, or default to first
    tier = None
    if tier_index is not None:
        if 0 <= tier_index < len(tg.tiers):
            tier = tg.tiers[tier_index]
        else:
            raise ValueError(f"Tier index {tier_index} out of range.")
    elif tier_name is not None:
        tier = next((t for t in tg.tiers if t.name == tier_name), None)
        if not tier:
            raise ValueError(f"Tier '{tier_name}' not found in TextGrid.")
    else:
        tier = tg.tiers[0]

    with open(ctm_output_file, 'w') as f:
        for interval in tier.intervals:
            if not interval.mark.strip():
                continue
            start_time = interval.minTime
            duration = interval.maxTime - interval.minTime
            label = interval.mark.strip()
            filename_no_ext = os.path.splitext(os.path.basename(textgrid_file))[0]
            f.write(f"{filename_no_ext} 1 {start_time:.6f} {duration:.6f} {label}\n")

    print(f"CTM file saved to: {ctm_output_file}")

def main():
    parser = argparse.ArgumentParser(description="Convert a TextGrid tier to a CTM file.")
    parser.add_argument("textgrid_file", type=str, help="Path to the TextGrid file.")
    parser.add_argument("ctm_output_file", type=str, help="Path to save the resulting CTM file.")
    parser.add_argument("--tier-name", type=str, default=None, help="Name of the tier to extract.")
    parser.add_argument("--tier-index", type=int, default=None, help="Index of the tier to extract (0-based).")

    args = parser.parse_args()

    try:
        textgrid_to_ctm(args.textgrid_file, args.tier_name, args.tier_index, args.ctm_output_file)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
