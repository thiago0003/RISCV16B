BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

# rm -rf obj_dir 
mkdir obj_dir

if [ -d "obj_dir" ]; then
    rm -r obj_dir/top.json obj_dir/top_pnr.json obj_dir/top.fs
fi

yosys -p "read_verilog RISCV16/*.v ; synth_gowin -noalu -top top -json obj_dir/top.json"

echo "------------------------------------------------25%------------------------------------------------"

if [ -f "obj_dir/top.json" ]; then
    nextpnr-himbaechel --json obj_dir/top.json --write obj_dir/top_pnr.json --freq 27 --device ${DEVICE} --vopt family=${FAMILY} --vopt cst=${BOARD}.cst
fi

echo "------------------------------------------------50%------------------------------------------------"

if [ -f "obj_dir/top_pnr.json" ]; then
    gowin_pack -d ${FAMILY} -o obj_dir/top.fs obj_dir/top_pnr.json
fi

echo "------------------------------------------------75%------------------------------------------------"


if [ -f "obj_dir/top.fs" ]; then
    openFPGALoader -b ${BOARD} obj_dir/top.fs -f
fi

echo "------------------------------------------------100%------------------------------------------------"