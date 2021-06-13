/* Script for -pie -z combreloc -z now -z relro: position independent executable, combine & sort relocs */
/* Copyright (C) 2014-2018 Free Software Foundation, Inc.
Copying and distribution of this script, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  */
OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64",
"elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)
SEARCH_DIR("=/usr/local/lib/x86_64-linux-gnu"); SEARCH_DIR("=/lib/x86_64-linux-gnu"); SEARCH_DIR("=/usr/lib/x86_64-linux-gnu"); SEARCH_DIR("=/usr/lib/x86_64-linux-gnu64"); SEARCH_DIR("=/usr/local/lib64"); SEARCH_DIR("=/lib64"); SEARCH_DIR("=/usr/lib64"); SEARCH_DIR("=/usr/local/lib"); SEARCH_DIR("=/lib"); SEARCH_DIR("=/usr/lib"); SEARCH_DIR("=/usr/x86_64-linux-gnu/lib64"); SEARCH_DIR("=/usr/x86_64-linux-gnu/lib");
SECTIONS
{
/* Read-only sections, merged into text segment: */
PROVIDE (__executable_start = SEGMENT_START("text-segment", 0)); . = SEGMENT_START("text-segment", 0) + SIZEOF_HEADERS;
.interp         : { *(.interp) }
.note.gnu.build-id : { *(.note.gnu.build-id) }
.hash           : { *(.hash) }
.gnu.hash       : { *(.gnu.hash) }
.dynsym         : { *(.dynsym) }
.dynstr         : { *(.dynstr) }
.gnu.version    : { *(.gnu.version) }
.gnu.version_d  : { *(.gnu.version_d) }
.gnu.version_r  : { *(.gnu.version_r) }
.rela.dyn       :
{
*(.rela.init)
*(.rela.text .rela.text.* .rela.gnu.linkonce.t.*)
*(.rela.fini)
*(.rela.rodata .rela.rodata.* .rela.gnu.linkonce.r.*)
*(.rela.data .rela.data.* .rela.gnu.linkonce.d.*)
*(.rela.tdata .rela.tdata.* .rela.gnu.linkonce.td.*)
*(.rela.tbss .rela.tbss.* .rela.gnu.linkonce.tb.*)
*(.rela.ctors)
*(.rela.dtors)
*(.rela.got)
*(.rela.bss .rela.bss.* .rela.gnu.linkonce.b.*)
*(.rela.ldata .rela.ldata.* .rela.gnu.linkonce.l.*)
*(.rela.lbss .rela.lbss.* .rela.gnu.linkonce.lb.*)
*(.rela.lrodata .rela.lrodata.* .rela.gnu.linkonce.lr.*)
*(.rela.ifunc)
}
.rela.plt       :
{
*(.rela.plt)
PROVIDE_HIDDEN (__rela_iplt_start = .);
*(.rela.iplt)
PROVIDE_HIDDEN (__rela_iplt_end = .);
}
.init           :
{
KEEP (*(SORT_NONE(.init)))
}
.plt            : { *(.plt) *(.iplt) }
.plt.got        : { *(.plt.got) }
.plt.sec        : { *(.plt.sec) }
.text ALIGN(0x1000):
{
*(.text.unlikely .text.*_unlikely .text.unlikely.*)
*(.text.exit .text.exit.*)
*(.text.startup .text.startup.*)
*(.text.hot .text.hot.*)
*(.stub .gnu.linkonce.t.*)
*(.text)
. = ALIGN(0x1000);
*(.text._ZN13SimParameters8setparamEPKcS1_)
. = ALIGN(0x1000);
*(.text._ZN7Lattice3setE6VectorS0_S0_S0_)
. = ALIGN(0x1000);
*(.text._ZN9ResultSet7compareERS_ .text._ZN9PatchList10setresultsEP9ResultSet .text._ZN9ResultSet9writefileEP8_IO_FILE .text._ZN9ResultSet8readfileEP8_IO_FILE .text._Z5equalPdS_ .text._Z5equalPdS_S_S_)
. = ALIGN(0x1000);
*(.text._ZN11SelfCompute6doWorkEP9PatchList)
. = ALIGN(0x1000);
*(.text._ZN11PairCompute6doWorkEP9PatchList)
. = ALIGN(0x1000);
*(.text._Z10exit_usagePKc)
. = ALIGN(0x1000);
*(.text._ZN13SimParameters8readfileEP8_IO_FILE)
. = ALIGN(0x1000);
*(.text._ZN7LJTable8readfileEP8_IO_FILE)
. = ALIGN(0x1000);
*(.text._ZN8Molecule8readfileEP8_IO_FILE)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil6selectEP13SimParametersP8MoleculeP7LJTable)
. = ALIGN(0x1000);
*(.text._ZN9PatchList8readfileEP8_IO_FILEP8Molecule)
. = ALIGN(0x1000);
*(.text._ZN11ComputeList8readfileEP8_IO_FILEP9PatchList)
. = ALIGN(0x1000);
*(.text._ZN9PatchListD2Ev)
. = ALIGN(0x1000);
*(.text._ZN8MoleculeD2Ev)
. = ALIGN(0x1000);
*(.text._Z8NAMD_diePKc)
. = ALIGN(0x1000);
*(.text._ZN11ObjectArenaIcE11getNewArrayEi)
. = ALIGN(0x1000);
*(.text._ZN5Patch8readfileEP8_IO_FILEP8Molecule)
. = ALIGN(0x1000);
*(.text._ZN26ComputeNonbondedWorkArraysC2Ev .text._GLOBAL__sub_I_Compute.C)
. = ALIGN(0x1000);
*(.text._ZN26ComputeNonbondedWorkArraysD2Ev)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil20calc_pair_energy_fepEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN11ComputeListC2Ev)
. = ALIGN(0x1000);
*(.text._ZN11ComputeListD2Ev)
. = ALIGN(0x1000);
*(.text._ZN13SimParametersC2Ev)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayIdED2Ev)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayIdED0Ev)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayItED2Ev)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayItED0Ev)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayI6VectorED2Ev)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayI6VectorED0Ev)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil30calc_pair_energy_fullelect_fepEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil36calc_pair_energy_merge_fullelect_fepEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil35calc_pair_energy_slow_fullelect_fepEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil20calc_self_energy_fepEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil30calc_self_energy_fullelect_fepEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil36calc_self_energy_merge_fullelect_fepEP9nonbonded)
. = ALIGN(0x1000);
*(.text._Z24fep_vdw_forceandenergiesdddddddddiidddPdS_S_)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil35calc_self_energy_slow_fullelect_fepEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil13calc_pair_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil20calc_pair_energy_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil23calc_pair_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil30calc_pair_energy_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil29calc_pair_merge_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil30calc_self_energy_fullelect_intEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil36calc_self_energy_merge_fullelect_intEP9nonbonded)
. = ALIGN(0x1000);
*(.text._GLOBAL__sub_I_ComputeNonbondedUtil.C)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil10calc_errorEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil36calc_pair_energy_merge_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil28calc_pair_slow_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil35calc_pair_energy_slow_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil13calc_self_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil20calc_self_energy_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil23calc_self_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil30calc_self_energy_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil29calc_self_merge_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil36calc_self_energy_merge_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil28calc_self_slow_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil35calc_self_energy_slow_fullelect_lesEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil15calc_pair_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil22calc_pair_energy_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil25calc_pair_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil32calc_pair_energy_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil31calc_pair_merge_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil38calc_pair_energy_merge_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN9PatchListC2ER7Lattice)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil30calc_pair_slow_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil37calc_pair_energy_slow_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil15calc_self_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil22calc_self_energy_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil25calc_self_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil32calc_self_energy_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil31calc_self_merge_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil38calc_self_energy_merge_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil30calc_self_slow_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil37calc_self_energy_slow_fullelect_pprofEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil9calc_pairEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil16calc_pair_energyEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil19calc_pair_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil26calc_pair_energy_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil25calc_pair_merge_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil32calc_pair_energy_merge_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil24calc_pair_slow_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil31calc_pair_energy_slow_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil9calc_selfEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil16calc_self_energyEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil19calc_self_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil26calc_self_energy_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil25calc_self_merge_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil32calc_self_energy_merge_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil24calc_self_slow_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil31calc_self_energy_slow_fullelectEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil20calc_pair_energy_intEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil30calc_pair_energy_fullelect_intEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil36calc_pair_energy_merge_fullelect_intEP9nonbonded)
. = ALIGN(0x1000);
*(.text._ZN20ComputeNonbondedUtil20calc_self_energy_intEP9nonbonded)
. = ALIGN(0x1000);
*(.text._Z8NAMD_bugPKc)
. = ALIGN(0x1000);
*(.text._Z22pairlist_from_pairlistddddPK8CompAtomPKtiPtdPd)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayI6VectorE6resizeEi)
. = ALIGN(0x1000);
*(.text._ZN7LJTableC2Ev)
. = ALIGN(0x1000);
*(.text._ZN7LJTableD2Ev)
. = ALIGN(0x1000);
*(.text._ZN8MoleculeC2Ev)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayIPcED2Ev)
. = ALIGN(0x1000);
*(.text._ZN11ResizeArrayIPcED0Ev)
. = ALIGN(0x1000);
*(.text._ZN5PatchC2Ev)
. = ALIGN(0x1000);
*(.text._ZN5PatchD2Ev)
. = ALIGN(0x1000);
*(.text.*)
/* .gnu.warning sections are handled specially by elf32.em.  */
*(.gnu.warning)
}
.fini ALIGN(0x1000):
{
KEEP (*(SORT_NONE(.fini)))
}
PROVIDE (__etext = .);
PROVIDE (_etext = .);
PROVIDE (etext = .);
.rodata         : { *(.rodata .rodata.* .gnu.linkonce.r.*) }
.rodata1        : { *(.rodata1) }
.eh_frame_hdr : { *(.eh_frame_hdr) *(.eh_frame_entry .eh_frame_entry.*) }
.eh_frame       : ONLY_IF_RO { KEEP (*(.eh_frame)) *(.eh_frame.*) }
.gcc_except_table   : ONLY_IF_RO { *(.gcc_except_table
.gcc_except_table.*) }
.gnu_extab   : ONLY_IF_RO { *(.gnu_extab*) }
/* These sections are generated by the Sun/Oracle C++ compiler.  */
.exception_ranges   : ONLY_IF_RO { *(.exception_ranges
.exception_ranges*) }
/* Adjust the address for the data segment.  We want to adjust up to
the same address within the page on the next page up.  */
. = DATA_SEGMENT_ALIGN (CONSTANT (MAXPAGESIZE), CONSTANT (COMMONPAGESIZE));
/* Exception handling  */
.eh_frame       : ONLY_IF_RW { KEEP (*(.eh_frame)) *(.eh_frame.*) }
.gnu_extab      : ONLY_IF_RW { *(.gnu_extab) }
.gcc_except_table   : ONLY_IF_RW { *(.gcc_except_table .gcc_except_table.*) }
.exception_ranges   : ONLY_IF_RW { *(.exception_ranges .exception_ranges*) }
/* Thread Local Storage sections  */
.tdata	  : { *(.tdata .tdata.* .gnu.linkonce.td.*) }
.tbss		  : { *(.tbss .tbss.* .gnu.linkonce.tb.*) *(.tcommon) }
.preinit_array     :
{
PROVIDE_HIDDEN (__preinit_array_start = .);
KEEP (*(.preinit_array))
PROVIDE_HIDDEN (__preinit_array_end = .);
}
.init_array     :
{
PROVIDE_HIDDEN (__init_array_start = .);
KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
PROVIDE_HIDDEN (__init_array_end = .);
}
.fini_array     :
{
PROVIDE_HIDDEN (__fini_array_start = .);
KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
PROVIDE_HIDDEN (__fini_array_end = .);
}
.ctors          :
{
/* gcc uses crtbegin.o to find the start of
the constructors, so we make sure it is
first.  Because this is a wildcard, it
doesn't matter if the user does not
actually link against crtbegin.o; the
linker won't look for a file to match a
wildcard.  The wildcard also means that it
doesn't matter which directory crtbegin.o
is in.  */
KEEP (*crtbegin.o(.ctors))
KEEP (*crtbegin?.o(.ctors))
/* We don't want to include the .ctor section from
the crtend.o file until after the sorted ctors.
The .ctor section from the crtend file contains the
end of ctors marker and it must be last */
KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
KEEP (*(SORT(.ctors.*)))
KEEP (*(.ctors))
}
.dtors          :
{
KEEP (*crtbegin.o(.dtors))
KEEP (*crtbegin?.o(.dtors))
KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
KEEP (*(SORT(.dtors.*)))
KEEP (*(.dtors))
}
.jcr            : { KEEP (*(.jcr)) }
.data.rel.ro : { *(.data.rel.ro.local* .gnu.linkonce.d.rel.ro.local.*) *(.data.rel.ro .data.rel.ro.* .gnu.linkonce.d.rel.ro.*) }
.dynamic        : { *(.dynamic) }
.got            : { *(.got.plt) *(.igot.plt) *(.got) *(.igot) }
. = DATA_SEGMENT_RELRO_END (0, .);
.data           :
{
*(.data .data.* .gnu.linkonce.d.*)
SORT(CONSTRUCTORS)
}
.data1          : { *(.data1) }
_edata = .; PROVIDE (edata = .);
. = .;
__bss_start = .;
.bss            :
{
*(.dynbss)
*(.bss .bss.* .gnu.linkonce.b.*)
*(COMMON)
/* Align here to ensure that the .bss section occupies space up to
_end.  Align after .bss to ensure correct alignment even if the
.bss section disappears because there are no input sections.
FIXME: Why do we need it? When there is no .bss section, we don't
pad the .data section.  */
. = ALIGN(. != 0 ? 64 / 8 : 1);
}
.lbss   :
{
*(.dynlbss)
*(.lbss .lbss.* .gnu.linkonce.lb.*)
*(LARGE_COMMON)
}
. = ALIGN(64 / 8);
. = SEGMENT_START("ldata-segment", .);
.lrodata   ALIGN(CONSTANT (MAXPAGESIZE)) + (. & (CONSTANT (MAXPAGESIZE) - 1)) :
{
*(.lrodata .lrodata.* .gnu.linkonce.lr.*)
}
.ldata   ALIGN(CONSTANT (MAXPAGESIZE)) + (. & (CONSTANT (MAXPAGESIZE) - 1)) :
{
*(.ldata .ldata.* .gnu.linkonce.l.*)
. = ALIGN(. != 0 ? 64 / 8 : 1);
}
. = ALIGN(64 / 8);
_end = .; PROVIDE (end = .);
. = DATA_SEGMENT_END (.);
/* Stabs debugging sections.  */
.stab          0 : { *(.stab) }
.stabstr       0 : { *(.stabstr) }
.stab.excl     0 : { *(.stab.excl) }
.stab.exclstr  0 : { *(.stab.exclstr) }
.stab.index    0 : { *(.stab.index) }
.stab.indexstr 0 : { *(.stab.indexstr) }
.comment       0 : { *(.comment) }
/* DWARF debug sections.
Symbols in the DWARF debugging sections are relative to the beginning
of the section so we begin them at 0.  */
/* DWARF 1 */
.debug          0 : { *(.debug) }
.line           0 : { *(.line) }
/* GNU DWARF 1 extensions */
.debug_srcinfo  0 : { *(.debug_srcinfo) }
.debug_sfnames  0 : { *(.debug_sfnames) }
/* DWARF 1.1 and DWARF 2 */
.debug_aranges  0 : { *(.debug_aranges) }
.debug_pubnames 0 : { *(.debug_pubnames) }
/* DWARF 2 */
.debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
.debug_abbrev   0 : { *(.debug_abbrev) }
.debug_line     0 : { *(.debug_line .debug_line.* .debug_line_end ) }
.debug_frame    0 : { *(.debug_frame) }
.debug_str      0 : { *(.debug_str) }
.debug_loc      0 : { *(.debug_loc) }
.debug_macinfo  0 : { *(.debug_macinfo) }
/* SGI/MIPS DWARF 2 extensions */
.debug_weaknames 0 : { *(.debug_weaknames) }
.debug_funcnames 0 : { *(.debug_funcnames) }
.debug_typenames 0 : { *(.debug_typenames) }
.debug_varnames  0 : { *(.debug_varnames) }
/* DWARF 3 */
.debug_pubtypes 0 : { *(.debug_pubtypes) }
.debug_ranges   0 : { *(.debug_ranges) }
/* DWARF Extension.  */
.debug_macro    0 : { *(.debug_macro) }
.debug_addr     0 : { *(.debug_addr) }
.gnu.attributes 0 : { KEEP (*(.gnu.attributes)) }
/DISCARD/ : { *(.note.GNU-stack) *(.gnu_debuglink) *(.gnu.lto_*) }
}
