import os
import shutil

def copy_vhdl_files():
    """
    Copy all VHDL files from uvvm_vvc_framework/src_target_dependent
    into each VIP folder under <vip>/src/, skipping VIPs that do not need them.
    """
    # Source directory
    uvvm_root = "../"
    src_dir = os.path.join(uvvm_root, "uvvm_vvc_framework", "src_target_dependent")
    if not os.path.isdir(src_dir):
        raise FileNotFoundError("Source directory not found: {}".format(src_dir))

    # Collect all VHDL files
    vhdl_files = [f for f in os.listdir(src_dir) if f.lower().endswith(".vhd")]
    if not vhdl_files:
        print("No VHDL files found in src_target_dependent. ({})".format(src_dir))
        return

    # Only look at immediate subdirectories of uvvm_root
    for d in os.listdir(uvvm_root):
        vip_path = os.path.join(uvvm_root, d)
        if os.path.isdir(vip_path) and "_vip_" in d.lower():
            vvc_methods_file = os.path.join(vip_path, "src", "vvc_methods_pkg.vhd")

            # Skip if vvc_methods_pkg.vhd doesn't exist in vip/src (meaning it doesn't need td files)
            if not os.path.isfile(vvc_methods_file):
                print("Skipping {} (it doesn't require target dependent files)".format(d))
                continue

            target_dir = os.path.join(vip_path, "src")

            # Copy files
            for vhdl_file in vhdl_files:
                src_file = os.path.join(src_dir, vhdl_file)
                dst_file = os.path.join(target_dir, vhdl_file)
                shutil.copy2(src_file, dst_file)
            print("Copied files to {}".format(target_dir))

    print("Copy operation completed.")

if __name__ == "__main__":
    copy_vhdl_files()