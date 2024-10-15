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

For running the artifact a x86-64 server with Ubuntu 24.04 LTS is required.
Other platforms might work, but are not tested.


## Preparation

To prepare the artifact, please follow the following instructions.

**1. Initialize the Submodules**

The repository contains a set of submodules that pull in the required dependencies. To initialize the submodules, run the following commands:

```bash
$ git submodule update --init --recursive
```

**2. Install Rust**

Follow the instructions on [Rustup.rs](https://rustup.rs/) to install Rust.

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**3. Install SMT Solver**

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

This will run 100 iterations of synthesis for each of the specifications, which will take some time.

**TODO: add a quick option here**

The expected duration is less than one minute on an Intel Xeon Silver 4310 CPU @ 2.10GHz.


**Expected Results**

The script will produce a table that should correspond to Table 1 in the paper. Note, this
results depend on.

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

This part of the evaluation uses the Arm Fast Models Simulator, which requires a license.

**Running the Experiment**

```bash
cd velosiraptor
cargo bench --bench runtime
```

**Expected Runtime**

**Expected Results**

----------------------------------------------------------------------------------------------------

### Section 6.5:  Velosiraptor can be used in a real OS

**Claim**
The claim for this evaluation is that Velosiraptor code can be integrated into a real operating
system.

**Running the Experiment**

**Expected Runtime**

**Expected Results**

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