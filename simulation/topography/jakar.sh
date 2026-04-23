#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Default values
nprocs_default=40
nprocs="${NPROCS:-$nprocs_default}"
CONTINUE_ON_ERROR=0

print_usage() {
	cat <<EOF
Usage: $0 [options]
Options:
	-n, --nprocs N       Number of MPI processes (default: ${nprocs_default})
	--continue-on-error  Continue running remaining cases on failure
	-h, --help           Show this help message
EOF
}

while [[ ${#} -gt 0 ]]; do
	case "$1" in
		-n|--nprocs)
			shift
			nprocs="$1"
			shift
			;;
		--continue-on-error)
			CONTINUE_ON_ERROR=1
			shift
			;;
		-h|--help)
			print_usage
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			print_usage
			exit 2
			;;
	esac
done

trap 'rc=$?; echo "ERROR: script failed at line ${LINENO} (exit ${rc})" >&2' ERR

echo "Using nprocs=${nprocs}"

# Try to load modules if `module` is available (non-fatal)
if command -v module >/dev/null 2>&1; then
	echo "Loading recommended modules..."
	module load compiler-rt/2024.0.0 ifort/2024.0.0 mpi/2021.13 || echo "Warning: module load failed"
fi

mkdir -p ./output

# Locate MPI launcher
if ! command -v mpirun >/dev/null 2>&1; then
	echo "mpirun not found in PATH" >&2
	exit 3
fi

# Locate binary
BIN="../../bin/waveqlab3d"
if [[ ! -x "$BIN" ]]; then
	if command -v waveqlab3d >/dev/null 2>&1; then
		BIN="$(command -v waveqlab3d)"
		echo "Found waveqlab3d at $BIN"
	else
		echo "Error: waveqlab3d binary not found at ../../bin/waveqlab3d and not in PATH" >&2
		exit 4
	fi
fi

cases=(
	"topo_1up_100m"
	"topo_2up_100m"
	"topo_3up_100m"
	"topo_4up_100m"
	"topo_5up_100m"
)

for fname in "${cases[@]}"; do
	infile="./input/${fname}.in"
	outfile="./output/${fname}.out"
	if [[ ! -f "$infile" ]]; then
		echo "Skipping ${fname}: input file ${infile} not found" >&2
		continue
	fi

	echo "Running ${fname} -> ${outfile} (nprocs=${nprocs})"
	if ! mpirun -np "${nprocs}" "$BIN" "$infile" | tee "$outfile"; then
		echo "Run failed for ${fname}" >&2
		if [[ ${CONTINUE_ON_ERROR} -eq 1 ]]; then
			echo "Continuing to next case due to --continue-on-error"
			continue
		else
			exit 5
		fi
	fi
done

echo "All done. Outputs in ./output"
