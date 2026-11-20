#!/usr/bin/env python3
"""Pipeline datapath diagram of src/processor.v (instance names and signals as in the RTL).

Writes results/architecture.png.  Run from the repository root:  python3 results/make_architecture.py
"""
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon, Rectangle

K = "black"
G = "#555555"
MONO = "DejaVu Sans Mono"
OUT = Path(__file__).resolve().parent / "architecture.png"

fig, ax = plt.subplots(figsize=(18, 9.4))
fig.patch.set_facecolor("white")
ax.set_xlim(-0.6, 25.9)
ax.set_ylim(-0.2, 13.4)
ax.set_aspect("equal")
ax.axis("off")


def box(x, y, w, h, title, inst=None, fs=8.6, fill="white"):
    ax.add_patch(Rectangle((x, y), w, h, fc=fill, ec=K, lw=1.3, zorder=2))
    ax.text(x + w / 2, y + h / 2, title, ha="center", va="center", fontsize=fs, zorder=3, linespacing=1.25)
    if inst:
        ax.text(x + w / 2, y - 0.08, inst, ha="center", va="top", fontsize=6.8, family=MONO, color=G, zorder=3)


def mux(xc, yc, h, inst=None, n=2, label_top=True):
    w = 0.42
    ax.add_patch(Polygon([(xc - w / 2, yc - h / 2), (xc - w / 2, yc + h / 2), (xc + w / 2, yc + h / 2 - 0.22),
                          (xc + w / 2, yc - h / 2 + 0.22)], closed=True, fc="white", ec=K, lw=1.3, zorder=2))
    ax.text(xc, yc, "M\nU\nX", ha="center", va="center", fontsize=5.6, zorder=3, linespacing=0.95)
    if inst:
        ax.text(xc, yc + h / 2 + 0.06 if label_top else yc - h / 2 - 0.06, inst, ha="center",
                va="bottom" if label_top else "top", fontsize=6.6, family=MONO, color=G, zorder=3)
    return xc - w / 2, xc + w / 2


def wire(pts, arrow=True, dashed=False, lw=1.15, color=K):
    xs, ys = zip(*pts)
    ax.plot(xs, ys, color=color, lw=lw, ls=(0, (4, 2.5)) if dashed else "-", zorder=4, solid_capstyle="butt")
    if arrow:
        (x0, y0), (x1, y1) = pts[-2], pts[-1]
        ax.annotate("", xy=(x1, y1), xytext=(x1 - 0.001 * (x1 - x0) - (0.18 if x1 > x0 else -0.18 if x1 < x0 else 0),
                                              y1 - (0.18 if y1 > y0 else -0.18 if y1 < y0 else 0)),
                    arrowprops=dict(arrowstyle="-|>", color=color, lw=lw, mutation_scale=8, shrinkA=0, shrinkB=0), zorder=5)


def dot(x, y):
    ax.plot([x], [y], "o", color=K, ms=3.2, zorder=6)


def lab(x, y, t, ha="left", va="bottom", fs=6.8, color=K, mono=True):
    ax.text(x, y, t, ha=ha, va=va, fontsize=fs, family=MONO if mono else None, color=color, zorder=6)


# ---------------------------------------------------------------- pipeline registers
BAR_LO, BAR_HI, BW = 1.7, 11.0, 0.32
bars = {"IF/ID": 5.0, "ID/EX": 10.4, "EX/MEM": 19.4, "MEM/WB": 23.0}
for name, x in bars.items():
    ax.add_patch(Rectangle((x, BAR_LO), BW, BAR_HI - BAR_LO, fc="#e6e6e6", ec=K, lw=1.3, zorder=2))
    ax.text(x + BW / 2, BAR_LO - 0.1, name, ha="center", va="top", fontsize=8, fontweight="bold", zorder=7,
            bbox=dict(fc="white", ec="none", pad=0.5))
edges = [-0.5] + [x + BW / 2 for x in bars.values()] + [25.9]
for i, name in enumerate(["IF", "ID", "EX", "MEM", "WB"]):
    ax.text((edges[i] + edges[i + 1]) / 2, 13.15, name, ha="center", va="center", fontsize=12, fontweight="bold")
    if i:
        ax.plot([edges[i]] * 2, [12.8, 13.4], color="#bbbbbb", lw=0.8)
L = lambda n: bars[n]
R = lambda n: bars[n] + BW

# ---------------------------------------------------------------- IF
yA = 6.0
mpc_l, mpc_r = mux(0.1, yA, 2.0, "pcsrc", label_top=False)
box(0.75, 5.45, 0.9, 1.1, "PC", "pc")
box(2.35, 4.9, 2.0, 2.2, "Instruction\nmemory", "inst_mem")
box(2.55, 8.1, 1.2, 0.8, "+4", "PC_plus4")
wire([(mpc_r, yA), (0.75, yA)])
wire([(1.65, yA), (2.35, yA)])
dot(2.0, yA)
wire([(2.0, yA), (2.0, 8.5), (2.55, 8.5)])
wire([(4.35, yA), (L("IF/ID"), yA)])
lab(4.4, yA + 0.05, "instr")
wire([(3.75, 8.5), (4.2, 8.5), (4.2, 9.6), (-0.45, 9.6), (-0.45, yA + 0.6), (mpc_l, yA + 0.6)])
lab(2.4, 9.65, "PC+4")
dot(2.0, 8.5)
wire([(2.0, 8.5), (2.0, 10.4), (L("IF/ID"), 10.4)])
lab(2.1, 10.45, "PC")

# ---------------------------------------------------------------- ID
box(7.0, 4.4, 1.9, 3.2, "Register\nfile\n32 x 32\n(x0 = 0)", "registers")
box(6.9, 8.5, 2.1, 0.95, "Main control", "MCU")
box(7.2, 2.6, 1.6, 0.9, "Imm gen", "immediate_generator")
box(5.6, 11.55, 2.4, 0.85, "Hazard detection", "HDU", fs=8)
wire([(R("IF/ID"), yA), (6.3, yA)], arrow=False)
dot(6.3, yA)
wire([(6.3, yA), (6.3, 6.9), (7.0, 6.9)])
lab(6.35, 6.95, "rs1")
wire([(6.3, yA), (6.3, 5.9), (7.0, 5.9)])
lab(6.35, 5.95, "rs2")
wire([(6.3, yA), (6.3, 3.05), (7.2, 3.05)])
wire([(6.3, 6.9), (6.3, 8.95), (6.9, 8.95)])
lab(6.35, 9.0, "opcode")
wire([(8.9, 6.9), (L("ID/EX"), 6.9)])
lab(8.95, 6.95, "rs1_data")
wire([(8.9, 5.9), (L("ID/EX"), 5.9)])
lab(8.95, 5.95, "rs2_data")
wire([(8.8, 3.05), (L("ID/EX"), 3.05)])
lab(8.85, 3.1, "immediate")
wire([(9.0, 8.95), (L("ID/EX"), 8.95)])
lab(9.05, 9.0, "control")
wire([(R("IF/ID"), 10.4), (L("ID/EX"), 10.4)])
lab(5.45, 10.45, "PC_ID")
wire([(5.6, 11.97), (1.2, 11.97), (1.2, 6.55)], dashed=True)
lab(1.3, 12.02, "PCWrite")
wire([(5.6, 11.72), (L("IF/ID") + BW / 2, 11.72), (L("IF/ID") + BW / 2, BAR_HI)], dashed=True)
lab(3.5, 11.47, "IF_ID_Write", va="top")
wire([(8.0, 11.97), (L("ID/EX") + BW / 2, 11.97), (L("ID/EX") + BW / 2, BAR_HI)], dashed=True)
lab(8.1, 12.02, "ID_EX_flush")

# ---------------------------------------------------------------- EX
fa_l, fa_r = mux(11.6, 6.9, 1.5, "forward_value_A")
fb_l, fb_r = mux(11.6, 4.7, 1.5)
ax.text(11.6, 3.9, "forward_value_B", ha="center", va="top", fontsize=6.6, family=MONO, color=G, zorder=7, bbox=dict(fc="white", ec="none", pad=0.3))
sa_l, sa_r = mux(13.5, 7.15, 1.2)
ax.text(13.72, 7.8, "ALU_A_select", ha="left", va="bottom", fontsize=6.6, family=MONO, color=G)
sb_l, sb_r = mux(13.5, 4.45, 1.2)
ax.text(13.72, 3.8, "ALU_B_select", ha="left", va="top", fontsize=6.6, family=MONO, color=G)
ax.add_patch(Polygon([(14.6, 3.9), (14.6, 5.3), (14.95, 5.8), (14.6, 6.3), (14.6, 7.7), (15.9, 6.6), (15.9, 5.0)],
                     closed=True, fc="white", ec=K, lw=1.3, zorder=2))
ax.text(15.3, 5.8, "ALU", ha="center", va="center", fontsize=9, zorder=3)
ax.text(16.0, 4.75, "alu", ha="left", va="top", fontsize=6.8, family=MONO, color=G)
box(14.45, 1.6, 1.6, 0.8, "ALU control\n(ALU_control)", None, fs=7.4)
box(14.6, 9.0, 1.3, 0.8, "Add", "branch_calc", fs=8.6)
box(16.6, 8.45, 2.3, 1.9, "Branch_taken\nPCSel\ncontrol_hazard\n(flush IF/ID, ID/EX)", None, fs=7.2)
box(11.15, 2.15, 1.75, 0.8, "Forwarding unit\n(forward)", None, fs=7.4)

# operands
wire([(R("ID/EX"), 6.9), (fa_l, 6.9)])
wire([(R("ID/EX"), 5.9), (11.0, 5.9), (11.0, 4.95), (fb_l, 4.95)])
wire([(fa_r, 6.9), (sa_l, 6.9)])
wire([(fb_r, 4.7), (sb_l, 4.7)])
dot(12.4, 4.7)
wire([(12.4, 4.7), (12.4, 3.35), (18.7, 3.35), (18.7, 4.6), (L("EX/MEM"), 4.6)])
lab(16.9, 3.4, "rs2 (store data)")
wire([(R("ID/EX"), 3.05), (13.0, 3.05), (13.0, 4.2), (sb_l, 4.2)])
lab(10.85, 3.1, "imm_EX")
dot(13.0, 3.8)
wire([(13.0, 3.8), (14.2, 3.8), (14.2, 9.2), (14.6, 9.2)])
wire([(R("ID/EX"), 10.4), (12.9, 10.4), (12.9, 7.4), (sa_l, 7.4)])
lab(10.85, 10.45, "PC_EX")
dot(12.9, 9.6)
wire([(12.9, 9.6), (14.6, 9.6)])
wire([(sa_r, 7.15), (14.6, 7.15)])
wire([(sb_r, 4.45), (14.6, 4.45)])
wire([(15.9, 5.8), (L("EX/MEM"), 5.8)])
lab(16.1, 5.85, "ALU_result")
wire([(15.25, 2.4), (15.25, 4.4)])
lab(15.32, 2.5, "ALUControl", fs=6.2)
wire([(R("ID/EX"), 1.95), (14.45, 1.95)], dashed=True)
lab(12.95, 1.98, "ALUOp, funct3/7", fs=6.0)
wire([(15.6, 6.85), (15.6, 8.0), (17.2, 8.0), (17.2, 8.45)], dashed=True)
lab(15.7, 8.05, "Zero, Less, LessU", fs=6.2)
wire([(15.9, 9.4), (16.6, 9.4)])
lab(15.95, 9.45, "target", fs=6.0)
# forwarding unit selects
wire([(11.6, 2.95), (11.6, 3.95)], dashed=True)
wire([(12.15, 2.95), (12.15, 5.75), (11.6, 5.75), (11.6, 6.15)], dashed=True)
lab(11.65, 3.4, "forward_B", fs=6.0)
lab(12.2, 5.25, "forward_A", fs=6.0)
# PC feedback (branch / jal / jalr target) on the top lane
wire([(18.9, 9.9), (19.15, 9.9), (19.15, 12.55), (-0.25, 12.55), (-0.25, yA - 0.1), (mpc_l, yA - 0.1)])
lab(10.0, 12.6, "branch_address_EX / jalr_target  (selected by PCSel)")

# ---------------------------------------------------------------- MEM
box(20.1, 4.3, 2.0, 2.6, "Data\nmemory\n(byte/half)", "memory")
wire([(R("EX/MEM"), 5.8), (20.1, 5.8)])
lab(19.75, 5.85, "addr", fs=6.2)
wire([(R("EX/MEM"), 4.6), (20.1, 4.6)])
lab(19.75, 4.65, "wdata", fs=6.2)
wire([(22.1, 5.6), (L("MEM/WB"), 5.6)])
lab(22.15, 5.65, "rdata", fs=6.2)
dot(19.9, 5.8)
wire([(19.9, 5.8), (19.9, 7.6), (L("MEM/WB"), 7.6)])
lab(20.0, 7.65, "ALU_result_MEM", fs=6.2)
wire([(R("EX/MEM"), 10.4), (L("MEM/WB"), 10.4)])
lab(19.75, 10.45, "PC_MEM", fs=6.2)

# ---------------------------------------------------------------- WB
wb_l, wb_r = mux(24.4, 7.2, 2.4, "WriteBack_Selection")
wire([(R("MEM/WB"), 7.6), (wb_l, 7.6)])
wire([(R("MEM/WB"), 5.6), (23.7, 5.6), (23.7, 6.9), (wb_l, 6.9)])
wire([(R("MEM/WB"), 10.4), (23.9, 10.4), (23.9, 8.1), (wb_l, 8.1)])
lab(23.35, 10.45, "PC+4", fs=6.2)
wire([(wb_r, 7.2), (25.4, 7.2), (25.4, 0.7), (6.6, 0.7), (6.6, 4.8), (7.0, 4.8)])
lab(20.5, 0.75, "write_data -> register file (rd_WB, RegWrite_WB)")

# ---------------------------------------------------------------- forwarding data paths (dashed)
dot(19.9, 7.6)
wire([(19.9, 7.6), (19.9, 8.25), (11.15, 8.25), (11.15, 7.25), (fa_l, 7.25)], dashed=True)
dot(11.15, 7.25)
wire([(11.15, 7.25), (11.15, 5.25), (fb_l, 5.25)], dashed=True)
lab(12.95, 8.3, "ALU_result_MEM (EX/MEM -> EX)", fs=6.2)
dot(17.0, 0.7)
wire([(17.0, 0.7), (17.0, 1.25), (10.85, 1.25), (10.85, 6.5), (fa_l, 6.5)], dashed=True)
dot(10.85, 4.45)
wire([(10.85, 4.45), (fb_l, 4.45)], dashed=True)
lab(11.0, 1.18, "write_data (MEM/WB -> EX)", fs=6.2, va="top")

fig.savefig(OUT, dpi=170, facecolor="white", bbox_inches="tight", pad_inches=0.15)
print("wrote", OUT)
