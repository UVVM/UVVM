# multisim.sh
# Simple support for driving UVVM from shell scripts.
# Supported simulators: GHDL, NVC, ModelSim/Questa, Xilinx Vivado (XSim).
# For examples of use, see compile_all.sh in this directory, and the
# compile_all_and_simulate.sh scripts for bitvis_uart and bitvis_irqc.

set -o errexit

if [ -z $SIM ]; then
    echo "no simulator specified"
    echo "supported simulators: ghdl, nvc, vsim, xsim"
    exit 1
fi
if [ -z $TARGET_DIR ]; then
    TARGET_DIR="."
fi

abspath () {
    _paths=("$@")
    if [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
        echo "$(cygpath -m $(realpath ${_paths[@]}))"
    else
        echo "$(realpath ${_paths[@]})"
    fi
}

# compile one or more sources into specified library
# arguments:
# $1 = library
# $2..$n = VHDL source files
compile () {
    _lib=$1 && shift && _sources=($(abspath "$@"))
    if [ "$SIM" = "ghdl" ]; then
        cmd="ghdl -a --work=${_lib} --std=08 -frelaxed -fsynopsys -Wno-hide -Wno-shared ${_sources[@]}"
    elif [ "$SIM" = "nvc" ]; then
        cmd="nvc --std=2008 -L . --work=${_lib} -a --relaxed ${_sources[@]}"
    elif [ "$SIM" = "vsim" ]; then
        cmd="vcom -2008 -work ${_lib} -explicit -vopt -stats=none ${_sources[@]}"
    elif [ "$SIM" = "xsim" ]; then
        cmd="xvhdl -2008 -work ${_lib} ${_sources[@]}"
    else
        echo "unsupported simulator (${SIM})"
        echo "supported simulators: ghdl, nvc, vsim, xsim"
        exit 1
    fi
    _dir=$(abspath $TARGET_DIR/$SIM)
    ( mkdir -p $_dir && cd $_dir && echo "${cmd}" && bash -c "$cmd" )
}

# compile sources for specified UVVM component, using its compile_order.txt file
# arguments:
# $1 = component directory
compile_component () {
    _path=$(abspath $1) && _component=$(basename $_path)
    _compile_order=($(tail -n +2 "$_path/script/compile_order.txt" | tr -d '\r' | tr '\n' ' '))
    _sources=()
    for _source in "${_compile_order[@]}"; do
        _sources+=("${_path}/script/${_source}")
    done    
    compile $_component ${_sources[@]}
}

# run simulation
# arguments:
# $1 = library
# $2 = design unit
simulate () {
    _lib=$1 && _top=$2
    if [ "$SIM" = "ghdl" ]; then
        cmd="ghdl --elab-run --work=${_lib} --std=08 -frelaxed -fsynopsys ${_top}"
    elif [ "$SIM" = "nvc" ]; then
        cmd="nvc --std=2008 -L . --work=${_lib} -e ${_top} && nvc --std=2008 -L . --work=${_lib} -r ${_top}"        
    elif [ "$SIM" = "vsim" ]; then
        cmd="vsim -work ${_lib} -t ps -c -onfinish stop -do \"onfinish exit; run -all; exit\" ${_top}"
    elif [ "$SIM" = "xsim" ]; then
        cmd="xelab --relax -top ${_lib}.${_top} -snapshot ${_top}_snapshot && xsim -runall --onerror quit --onfinish quit ${_top}_snapshot"
    else
        echo "unsupported simulator (${SIM})"
        echo "supported simulators: ghdl, nvc, vsim, xsim"
        exit 1
    fi
    _dir=$(abspath $TARGET_DIR/$SIM)
    ( mkdir -p $_dir && cd $_dir && echo "${cmd}" && bash -c "$cmd" )
}
