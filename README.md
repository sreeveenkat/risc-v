# 🔥 5-Stage Pipelined RISC-V Processor (RV32I)

🚀 Designed and implemented a fully pipelined RISC-V CPU with hardware hazard handling and forwarding, achieving near **1 CPI throughput**.

---

## 📌 Overview

This repository contains the **RTL design and verification** of a fully functional **5-stage pipelined RISC-V CPU**, implemented using **Verilog HDL**. 

The design focuses on:
- **Instruction-Level Parallelism (ILP)**
- **Hazard Detection & Data Forwarding**
- **Controller-Datapath Separation**

✔ Supports all **37 RV32I Base Integer Instructions**  
✔ Fully synthesizable for **FPGA prototyping (Vivado/ZedBoard)**  

---

## ✨ Key Features

* **32-bit RISC-V (RV32I)** pipelined architecture  
* **Classic 5-Stage Pipeline:**
  - **IF** (Fetch): PC-based instruction retrieval  
  - **ID** (Decode): Instruction decoding and Register File read  
  - **EX** (Execute): ALU operations and branch resolution  
  - **MEM** (Memory): Data RAM access (Load/Store)  
  - **WB** (Write Back): Register File update  

* **Advanced Hazard Management:**
  * **Forwarding Unit:** Resolves RAW (Read-After-Write) hazards via data bypassing  
  * **Hazard Detection Unit:** Handles Load-use dependencies with 1-cycle stalls  
  * **Flush Logic:** Discards wrong-path instructions on branches/jumps  

* **Modular Design:** Clean separation of Control Unit, Datapath, and Pipeline Registers  
* **FPGA Ready:** Debug-friendly interface using switches for register selection and LEDs for data inspection  

---

## 📊 Performance Metrics

* **Ideal CPI:** ~1 (after pipeline fill)  
* **Load-Use Stall Penalty:** 1 cycle  
* **Branch Penalty:** 1–2 cycles (flush-based resolution)  
* **Pipeline Depth:** 5 stages  

---

## 🏗️ CPU Microarchitecture

### Pipeline Architecture

![Pipeline Diagram](results/diagrams/pipeline.png)

### Core Components

* **PC & Adder:** Program counter logic with stall support  
* **Pipeline Registers:** IF/ID, ID/EX, EX/MEM, MEM/WB with synchronous reset/flush  
* **Immediate Generator:** Supports I, S, B, U, and J formats  
* **Register File:** 32 × 32-bit registers (x0 hardwired to 0)  
* **Forwarding & Hazard Units:** Hardware interlocks for seamless execution  

---

## 🧠 Supported Instruction Set

| Category | Instructions |
| :--- | :--- |
| **Data Processing** | `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND` |
| **Immediate Operations** | `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI` |
| **Memory Operations** | `LW`, `LH`, `LB`, `LHU`, `LBU`, `SW`, `SH`, `SB` |
| **Branch & Jump** | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`, `JAL`, `JALR` |
| **Upper Immediate** | `LUI`, `AUIPC` |

---

## 🧪 Verification Results

### 1. Simulation Waveforms

Functional verification performed using a custom testbench to monitor stage-by-stage execution.

![Waveform](results/waveforms/waveform.png)

---

### 2. FPGA Implementation

The design was implemented on hardware to verify real-time execution.

![FPGA Demo](results/hardware/fpga_demo.png)

---

### 3. Synthesis Reports

* **Utilization:** LUTs, FFs, BRAM usage  
* **Power Analysis:** Thermal and dynamic power breakdown  

---

## 📁 Project Structure

```text
├── src/
│   ├── core/                # Pipeline logic (IF, ID, EX, MEM, WB)
│   ├── control/             # Main Control & ALU Control Logic
│   ├── execution/           # 32-bit ALU & Branch resolution
│   ├── memory/              # Instruction & Data Memory models
│   ├── utils/               # Muxes, Adders, and Pipeline Registers
│   └── fpga/                # Top-level wrapper & XDC Constraints
├── demo_programs/
│   ├── led_blinking/
│   └── sum_of_n/
├── results/
│   ├── waveforms/
│   ├── hardware/
│   └── reports/
└── README.md

💡 FPGA Demonstration
Switches sw[4:0] → Select register index (0–31)
LEDs led[7:0] → Display lower 8 bits of selected register
Reset Button → Restart execution from PC = 0

🔮 Future Improvements
🏗️ SoC Integration & Bus Protocols
AXI4 / AHB Interface for IP integration
SoC wrapper with UART, GPIO, Memory Controller
🚀 Performance Enhancements
Custom ISA Extensions (MAC, AI accelerators)
Branch Prediction (BTB + 2-bit predictor)
Superscalar execution
💾 Memory System
L1 Cache (Instruction + Data)
Tightly Coupled Memory (TCM)

👨‍💻 Author

Sreevenkat Eluva
Digital VLSI Design | RISC-V Architecture | Verilog RTL

📜 License

Open-source for academic and learning purposes.

