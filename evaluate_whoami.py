"""Compatibility entry point for the original whoami evaluation commands."""
import argparse
from evaluate_lab import main

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compare-scope', action='store_true')
    args = parser.parse_args()
    raise SystemExit(main(['--case', 'whoami-scope' if args.compare_scope else 'whoami-priv']))
