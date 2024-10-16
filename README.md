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
Other platforms might work too, but are not tested.


## Preparation

To prepare the artifact, please follow the following instructions.

**1. Initialize the Submodules**

The repository contains a set of submodules that pull in the required dependencies. To initialize
the submodules, run the following commands:

```bash
$ git submodule update --init --recursive
```

**2. Install Dependencies**

On Ubuntu, you can install the dependencies using the following command:

```bash
$ sudo apt-get update
$ sudo apt-get install bc binutils bison curl dwarves flex gcc g++ git gnupg2 gzip libelf-dev \
               libncurses5-dev libssl-dev make openssl pahole perl-base python3 qemu-system-x86 \
               rsync tar unzip wget xz-utils


```

**3. Install Docker**

Install docker by follwing the [instructions](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository).

**3. Install Rust**

Follow the instructions on [Rustup.rs](https://rustup.rs/) to install Rust.

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

**4. Install SMT Solver**

Install Z3 version 4.10.2.

To install the Z3 solver, follow the following instructions on the [Z3 Github Release Page](https://github.com/Z3Prover/z3/releases/tag/z3-4.10.2), and make it accessible in the path.

You can use the following script to automate the installation. Make sure you are making Z3 available
in the path.

```bash
$ bash ./tools/download-z3.sh
export PATH=`pwd`:$PATH
```

## Evaluation of the Paper

The following subsections contain the instructions to reproduce the results presented in the paper.
They are organized by the sections in the paper.

----------------------------------------------------------------------------------------------------

### Section 6.2: Velosiraptor generates code quickly

**Claim**
The claim for this evaluation is that Velosiraptor can synthesize code quickly.

**Running the Experiment**
To run the experiment execute the following command:

```bash
cd velosiraptor
cargo bench --bench synth
```

This will run 100 iterations of synthesis for each of the specifications plus 100 iterations of
compiling the Linux kernel. Note, that will take more than 4 hours on an Intel Xeon Silver 4310 CPU @ 2.10GHz.

If you want to run a version of the experiment with fewer iterations, you can run the following command:

```bash
cd velosiraptor
cargo bench --bench synth -- --smoke
```
The expected duration for this should be around 15 minutes on an Intel Xeon Silver 4310 CPU @ 2.10GHz.


**Expected Results**
The script will produce a table that should correspond to Table 1 in the paper. Note, this result
significantly depends on the performance and characteristics of the hardware, that you are running on, in particular the number of cores and the memory bandwidth. Especially for the more complex
specifications, this can lead to differences in the synthesis time.

----------------------------------------------------------------------------------------------------

### Section 6.3: Ablation Study of Optimizations

**Claim**
The claim for this evaluation is that the optimizations that Velosiraptor employs are effective.

**Running the Experiment**
To run the experiment execute the following command:

```bash
cd velosiraptor
cargo bench --bench opt
```

The expected duration is less than one minute on an Intel Xeon Silver 4310 CPU @ 2.10GHz.


**Expected Results**
The script will print a Latex table that should match Table 2 in the paper showing a decrease
in the search space towards the right hand side of the table.

----------------------------------------------------------------------------------------------------

### Section 6.4: Hardware/Software Co-Design with Velosiraptor

**Additional Requirements**

This part of the evaluation uses the Arm Fast Models Simulator. Note, that **this requires a license**
and the Fast Models sources.

**Part 1: Generating the Hardware Components**

Given the license requirements, we provide a test that generates the hardware code and runs it throug
a compiler with stubbed Fast Models dependencies.

```bash
cd velosiraptor
cargo test --test fastmodels -- --nocapture
```
This should take a few minutes on an Intel Xeon Silver 4310 CPU @ 2.10GHz.

**Part 1: Expected Results**

For each of the units, the test should print the following, indicating that the compilation of
the hardware module was successful.

```bash
Generate and Check: examples/mpu.vrs.vrs
  - Parsing mpu                                      ... ok
  - generate hardware module (fast models)...  ok
  - Compiling hardware module ...  ok
```
The generated files are in the `velosiraptor/out/examples_hwgen_fastmodels/<UNIT>/hw/fastmodels` directory,
where the `src` contains the generated code, and `build` contains a library that is the compiled
hardware component that will be linked with the Fast Models.

**Part 2: Building the Simulators**

Note, that building the simulators requires the Arm FastModels to be installed and the license to
be available.

```
# setup the FastModels environment for building
source <PATH/TO/FastModels>/etc/setup_all.sh
```

This should take a few minutes on an Intel Xeon Silver 4310 CPU @ 2.10GHz.

**Part 3: Expected Results**

The expected result is that the platform simulation binaries are successful generated.



**Part 3: Running the Emulated Binaries**

Note, that running the simulation requires the Arm FastModels license to be available.

```
$(PLATFORM_BIN) --data Memory0=bootimg.bin@0x0
```


**Part 2: Expected Results**



----------------------------------------------------------------------------------------------------

### Section 6.5:  Velosiraptor can be used in a real OS

**Claim**
The claim for this evaluation is that Velosiraptor code can be integrated into a real operating
system.

**Additional Dependencies**

This requires:
 * KVM to be enabled and the user to have sudo privileges or be part of the KVM group.
 * Docker to be installed and the user to have sudo privileges or be part of the docker group.

**Running the Experiment**

```
cd velosiraptor
cargo test --test codegen --  --nocapture
```

This should generate the relevant C files for integration into the Barrelfish OS.
The output should look like this:

```
test examples_codegen_c ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 7 filtered out; finished in 0.11s
```

For integration into the Barrelfish OS, copy the generated files into the `barrelfish` directory:
```bash
# in the artifact root directory
rsync -avz velosiraptor/out/barrelfish_user/x86_64_pagetable/sw/clang/* barrelfish/usr/vspace/velosiraptor/
rsync -avz velosiraptor/out/barrelfish_kernel/x86_64_pagetable/sw/clang/* barrelfish/kernel/include/velosiraptor
rsync -avz velosiraptor/out/monolythic/x86_64_pagetable/sw/clang/* barrelfish/kernel/include/velosiraptor-monolyth
```

Now we can build and run the Barrelfish OS.

```bash
# from the artifact root directory
$ cd barrelfish
# drop into the docker container
$ bash tools/bfdocker.sh
$ mkdir build
$ cd build
$ ../hake/hake.sh -s ../ -a x86_64
$ make X86_64_Basic -j
# exit the docker container
$ exit
```

Next we can boot Barrelfish. For this, navigate into the build directory.
```bash
# from the artifact root directory
$ cd barrelfish/build
$ ../tools/qemu-wrapper.sh --menu ../hake/menu.lst.x86_64 --arch x86_64
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

The expected duration is less than one minute on an Intel Xeon Silver 4310 CPU @ 2.10GHz.

**Expected Results**
The script will print a Latex table that should be similar to Table 3 in the paper.
In particular, the lines "Linux"/"Velosiraptor and "Barrelfish"/"Velosiraptor" should show the
same performance +/- 1ns.

**TODO: replace arbutus with \system**