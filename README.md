# Velosiraptor ASPLOS25 Artifact

This repository contains the artifact for the ASPLOS'25 paper *"Velosiraptor: Code Synthesis for Memory Translation"*.

## Citation

```
Reto Achermann, Em Chu, Ryan Mehri, Ilias Karimalis, and Margo
Seltzer. 2025. Velosiraptor: Code Synthesis for Memory Translation.
In ACM International Conference on Architectural Support for Pro-
gramming Languages and Operating Systems(ASPLOS ’25), March
30–April 3, 2025, Rotterdam, The Netherlands.
```

## Supported Platforms

For running the artifact a single-socket x86-64 server with Ubuntu 24.04 LTS is required.
Other platforms or architectures might work too, but are not tested.


## Preparation

To prepare the artifact, please follow the following instructions to install dependencies and
setup the required submodules.


**1. Initialize the Submodules**

The repository contains a set of submodules that pull in the required dependencies. To initialize
the submodules, run the following command:

```bash
git submodule update --init --recursive
```
Note, the submodules themselves have submodules, so you need the `--recursive` flag to set these
up properly.


**2. Install Dependencies**

On Ubuntu, you can install the dependencies using the following command:

```bash
sudo apt-get update
sudo apt-get install bc binutils bison curl dwarves flex gcc g++ git gnupg2 gzip libelf-dev \
           libncurses5-dev libssl-dev make openssl pahole perl-base python3 qemu-system-x86 \
           rsync tar unzip wget xz-utils gcc-aarch64-linux-gnu
```

Note: this basically includes the build dependencies for building the Linux kernel.


**3. Install Docker**

Install docker by following the official [instructions on the docker website](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository).


**4. Install Rust**

Follow the instructions on [Rustup.rs](https://rustup.rs/) to install Rust. For example, through
the install script:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

Note: it's best to add `source $HOME/.cargo/env` to your `.bashrc`/`.zshrc`/... file so it gets
automatically sourced.


**5. Install SMT Solver**

Install Z3 version `4.10.2` (other versions might work too, but are not tested).

To install the Z3 solver, follow the following instructions on the
[Z3 Github Release Page](https://github.com/Z3Prover/z3/releases/tag/z3-4.10.2), and make it
accessible by adding the directory to your `PATH` environment variable.

You can use the following script to automate the installation:

```bash
# in the velosiraptor directory
bash ./tools/download-z3.sh
export PATH=`pwd`:$PATH
```

Make sure you are making Z3 available in your path every time you open a new terminal by adding
this path in your `.bashrc`/`.zshrc`/... file.

**6. Install the Arm Fast Models 11.15**

For the simulated hardware components, we use the Arm Fast Models 11.15. This requires a license
and must be obtained from [Arm directly](https://developer.arm.com/Tools%20and%20Software/Fast%20Models).

You will need the following licenses:
 * Fast Models System Generator (MaxCore_SystemGen)
 * Fast Models Base Platform (SG_Simulator)
 * Fast Models Arm Cortex A53 (SG_ARM_Cortex-A53_CT)

Most of the evaluation can be done without the Fast Models licenses, including building the
hardware modules, but the simulator cannot be built and run without the licenses.



## Evaluation of the Paper

The following subsections contain the instructions to reproduce the results presented in the paper.
They are organized by the sections in the paper.

----------------------------------------------------------------------------------------------------

### Section 6.2: Velosiraptor generates code quickly

**Claim:**
The claim for this evaluation is that Velosiraptor can synthesize code quickly.

**Running the Experiment:**
To run the experiment execute the following command:

```bash
# in the velosiraptor directory
cargo bench --bench synth
```

This will run 100 iterations of synthesis for each of the specifications plus 100 iterations of
compiling the Linux kernel.

If you want to run a version of the experiment with fewer iterations, you can run the following command:

```bash
# in the velosiraptor directory
cargo bench --bench synth -- --smoke
```

**Duration:**

* Full version (100 iterations): more than 4 hours on an Intel Xeon Silver 4310 CPU @ 2.10GHz.
* Smoke version (5 iterations): around 15 minutes on an Intel Xeon Silver 4310 CPU @ 2.10GHz.


**Expected Results**
The script will produce a table that should correspond to Table 1 in the paper. Note, this result
significantly depends on the performance and characteristics of the hardware, that you are running
on, in particular the number of cores and the memory bandwidth available. Especially for the more complex
specifications, this can lead to differences in the synthesis time.

Also note, that if you are running the `--smoke` version you may see a higher variance in the results.

----------------------------------------------------------------------------------------------------

### Section 6.3: Ablation Study of Optimizations

**Claim**
The claim for this evaluation is that the optimizations that Velosiraptor employs are effective.

**Running the Experiment**
To run the experiment execute the following command:

```bash
# in the velosiraptor directory
cargo bench --bench opt
```

**Duration:**
The expected duration is less than one minute on an Intel Xeon Silver 4310 CPU @ 2.10GHz.


**Expected Results**
The script will print a Latex table that should match Table 2 in the paper showing a decrease
in the search space towards the right hand side of the table.

----------------------------------------------------------------------------------------------------

### Section 6.4: Hardware/Software Co-Design with Velosiraptor

**Claim**
The claim for this evaluation is that Velosiraptor can generate (simulated) hardware components from
the specifications.

**Additional Requirements for Parts 2 & 3**

This parts of the evaluation uses the Arm Fast Models Simulator 11.15. Note, that **this requires a license**
and the Fast Models sources. Then make sure you are sourcing the Fast Models environment before running to setup the environment correctly:

```bash
# Example path, depends on your installation
source $HOME/bin/arm/FastModelsTools_11.15/source_all.sh
```

If you don't have the license setup properly, you will see something like:

```
Error: license error: License checkout for feature FM_Simulator with version 11.15 has been denied by Flex back-end. Error code: -1
```

**Part 1: Generating the Hardware Components**

Given the license requirements, we provide a test that generates the hardware code and runs it through
a compiler with stubbed Fast Models dependencies. This produces the library implementing the
translation hardware functionality and this library would then be linked with the Arm FastModels to
produce the platform simulator.

```bash
# in the velosiraptor directory
cargo test --test fastmodels -- --nocapture
```

**Part 1: Duration**
This should take a few minutes on an Intel Xeon Silver 4310 CPU @ 2.10GHz.


**Part 1: Expected Results**

For each of the units, the test should print the following, indicating that the compilation of
the hardware module was successful.

```bash
Generate and Check: examples/mpu.vrs.vrs
  - Parsing mpu                                      ... ok
  - generate hardware module (fast models)...  ok
  - Compiling hardware module ...  ok

[...]

test result: ok. 1 passed; 0 failed; 5 ignored; 0 measured; 0 filtered out; finished in 23.47s
```
The generated files are in the `velosiraptor/out/examples_hwgen_fastmodels/<UNIT>/hw/fastmodels` directory,
where the `src` contains the generated code, and `build` contains a library (`*.a` file) that is the
compiled hardware component that will be linked with the Fast Models.

Note: it will show that some tests were ignored, this is fine as they are not relevant for this part
of the evaluation.


**Part 2: Building the Simulators**

Note: This and the subsequent steps for this part of the evaluation requires the Arm FastModels licenses
to build and run the simulator.

To build the platform simulators, run the following command:

```bash
# setup the FastModels environment for building
source <PATH/TO/FastModels>/etc/setup_all.sh
# in the velosiraptor directory
cargo test --test fastmodels -- --nocapture --ignored  build_fast_models_platforms
```

This will automatically build the full platform simulators each having one generated translation
hardware module.


**Part 2: Duration**
This should take a 10 minutes on an Intel Xeon Silver 4310 CPU @ 2.10GHz. Building the platforms
requires C++ compilation which may takes some time.

**Part 2: Expected Results**

The expected result is that the platform simulation binaries are successful generated.

```bash
Generate and Check: examples/mpu.vrs.vrs
  - Parsing mpu                                      ... ok
  - generate hardware module (fast models)...  ok
  - Compiling hardware module ...  ok

Building FastModels: examples/mpu.vrs.vrs
  - Compiling hardware module ...  ok
  - simulator successfully built `out/examples_hwgen_fastmodels/mpu/hw/fastmodels/build/plat_example_sim`
...
test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 5 filtered out; finished in 293.43s
```

The generated files are in the `velosiraptor/out/examples_hwgen_fastmodels/<UNIT>/hw/fastmodels/build` directory
that should now have a file `plat_example_sim` that is the platform simulator binary.

Again note that some tests are ignored, as they are not relevant for this part of the evaluation.


To build the platform simulator binaries manually, you can run the following command:
```bash
# in the velosiraptor directory
cd out/examples_hwgen_fastmodels/<UNIT>/hw/fastmodels
make
```

**Part 3: Running the Simulators**

Note, that running the simulation requires the Arm FastModels license to be available for the
Arm Fast Models base platform as well as the Arm Cortex A53 processor.

To run the platform simulators, run the following command.

```bash
# in the velosiraptor directory
cargo test --test fastmodels -- --nocapture --ignored  run_fast_models_platforms
```

This will build the platform simulator, the boot image that contains a test program, execute the
boot image on the platform simulator, check whether the output matches.

To build the bootimage and run the simulator manually, you can run the following commands:
```bash
# in the velosiraptor directory
cd support/arm-fastmodels-boot
VRS_TEST=src/tests/vrs_test_<UNIT>.c make

# in the velosiraptor directory
./out/examples_hwgen_fastmodels/<UNIT>/hw/fastmodels/build/plat_example_sim --data Memory0=support/arm-fastmodels-boot/bootimg.bin@0x0
```
Note: replace `<UNIT>` with the name of the unit you want to test. If the unit doesn't match the
one in the simulator, the test will fail.

**Part 3: Duration**

This should take a few minutes on an Intel Xeon Silver 4310 CPU @ 2.10GHz.

**Part 3: Expected Results**

The expected results for this part of the evaluation is that the boot image executes the tests and
matches the expected output.

For each of the units, you should see the following output.

```
Generate and Check: examples/mpu.vrs
  - Parsing mpu                                      ... ok
  - generate hardware module (fast models)...  ok
  - Compiling hardware module ...  ok

Building FastModels: examples/mpu.vrs
  - Compiling hardware module ...  ok
  - simulator successfully built `out/examples_hwgen_fastmodels/mpu/hw/fastmodels/build/plat_example_sim`

Building Bootimage
  - test file: src/tests/vrs_test_mpu.c
  - Compiling boot image ...  ok

Running FastModels: examples/mpu.vrs.vrs
  - sim: out/examples_hwgen_fastmodels/mpu/hw/fastmodels/build/plat_example_sim
  - bootimg: support/arm-fastmodels-boot/bootimg.bin
 -- executing ./out/examples_hwgen_fastmodels/mpu/hw/fastmodels/build/plat_example_sim --data Memory0=support/arm-fastmodels-boot/bootimg.bin@0x0
 -- OK! Simulator completed successfully.

[...]

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 5 filtered out; finished in 188.49s
```

If you run the simulator manually, your will see output like this:

```
telnetterminal: Listening for serial connection on port 5000
[ UNIT] [ WARN] Initializing translation unit AssocSegment
...
[ UNIT] [ INFO] reset completed
[ARMv8]: ###############################################################################
[ARMv8]: FastModels bootloader starting on ARM Cortex-A53 core rev. r2628 in EL3
[ARMv8]: ###############################################################################
...
[ARMv8]: Running VRS tests for: assoc_segment
[ARMv8]: Reconfigure..
[ARMv8]: Writing memory
[ UNIT] [ INFO] TranslationUnitBase::handle_remap() - translated 0x0 -> 0x1000
...
[ UNIT] [ INFO] TranslationUnitBase::handle_remap() - translated 0xff8 -> 0x1ff8
[ARMv8]: Reconfigure..
[ARMv8]: Writing memory..
[ UNIT] [ INFO] TranslationUnitBase::handle_remap() - translated 0x0 -> 0x2000
...
[ UNIT] [ INFO] TranslationUnitBase::handle_remap() - translated 0xff8 -> 0x2ff8
[ARMv8]: Verifying memory...
[ARMv8]: Verifying memory...
[ARMv8]: All memory mapped correctly
[ARMv8]: Velosiraptor tests completed.
```

----------------------------------------------------------------------------------------------------

### Section 6.5:  Velosiraptor can be used in a real OS

**Claim**
The claim for this evaluation is that Velosiraptor code can be integrated into a real operating
system.

**Additional Dependencies**

This requires:
 * KVM to be enabled and the user to have `sudo` privileges or be part of the KVM group.
 * Docker to be installed and the user to have `sudo` privileges or be part of the docker group.


**Running the Experiment**

```bash
# in the velosiraptor directory
cargo test --test codegen --  --nocapture
```

This should generate the relevant C files for integration into the Barrelfish OS.
The output should look like this:

```
...
test examples_codegen_c ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 7 filtered out; finished in 0.11s
```

For integration into the Barrelfish OS, copy the generated files into the `barrelfish` directory:
```bash
# in the velosiraptor directory
rsync -avz out/barrelfish_user/x86_64_pagetable/sw/clang/* ../barrelfish/usr/vspace/velosiraptor/
rsync -avz out/barrelfish_kernel/x86_64_pagetable/sw/clang/* ../barrelfish/kernel/include/velosiraptor
rsync -avz out/monolythic/x86_64_pagetable/sw/clang/* ../barrelfish/kernel/include/velosiraptor-monolyth
```

Now we can build and run the Barrelfish OS.

```bash
# from the artifact root directory
cd barrelfish
# drop into the docker container
bash tools/bfdocker.sh
mkdir -p build
cd build
../hake/hake.sh -s ../ -a x86_64
make X86_64_Basic -j
# exit the docker container
exit
```

Next we can boot Barrelfish. For this, navigate into the build directory.
```bash
# from the artifact root directory
cd barrelfish/build
../tools/qemu-wrapper.sh --menu ../hake/menu.lst.x86_64 --arch x86_64
```

**Expected Results**

The following output should be seen on the terminal.
```bash
vspace.0.0: $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
vspace.0.0: Velosiraptor Test: Starting
vspace.0.0: $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
vspace.0.0: Velosiraptor Test: Successfully booted with Velosiraptor mapping handlers in cpudriver
vspace.0.0: $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
vspace.0.0: Velosiraptor Test: Mapping the frame at address 0x20000000000
vspace.0.0: $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
vspace.0.0: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vspace.0.0: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vspace.0.0: Velosiraptor Test: accessing memory...
vspace.0.0: *addr = 0
vspace.0.0: *addr = 42
vspace.0.0: *addr = 42
vspace.0.0: Velosiraptor Test: Successfully exercised user-space mappings
vspace.0.0: $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
vspace.0.0: Velosiraptor Test: Exercising Monolythic Mappings
vspace.0.0: $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
vspace.0.0: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vspace.0.0: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vspace.0.0: Velosiraptor Test: accessing memory...
vspace.0.0: *addr = 42
vspace.0.0: *addr = 43
vspace.0.0: *addr = 43
vspace.0.0: Velosiraptor Test: Successfully exercised monolithic mappings
vspace.0.0: $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
vspace.0.0: Velosiraptor Test: Successfull
vspace.0.0: $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
```

----------------------------------------------------------------------------------------------------

### Section 6.6: Performance of Generated Code

**Claim**
The claim for this evaluation is that Velosiraptor generates code that is as fast as hand-written
code found in the Linux and Barrelfish kernels.

**Running the Experiment**
To run the experiment execute the following command:

```bash
cd velosiraptor
cargo bench --bench runtime
```

**Duration**
The expected duration is less than one minute on an Intel Xeon Silver 4310 CPU @ 2.10GHz.

**Expected Results**
The script will print a Latex table that should be similar to Table 3 in the paper.
In particular, the lines "Linux"/"Velosiraptor and "Barrelfish"/"Velosiraptor" should show the
same performance +/- 1ns.
