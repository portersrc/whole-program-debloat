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
*(.text._Z14setup_epd_lineP11gamestate_tP7state_tPKc .text._Z16post_fh_thinkingP7state_tiiPci .text._Z16post_fl_thinkingP7state_tiiPci .text._Z21post_multipv_thinkingP7state_tiii .text._Z11search_rootP7state_tiii .text._Z5thinkP11gamestate_tP7state_t .text._Z13display_boardP7state_ti .text._Z19extract_ponder_moveP7state_t .text._Z13post_thinkingP7state_tiiPci)
. = ALIGN(0x1000);
*(.text._Z8myprintfPKcz)
. = ALIGN(0x1000);
*(.text._Z9free_hashv)
. = ALIGN(0x1000);
*(.text._Z10attacks_toP7state_ti .text._Z14drawn_endgamesP7state_tiii .text._Z9gen_quietP7state_tPi .text._Z15gen_good_checksP7state_tPi .text._Z5fevalP7state_tiP12t_eval_comps .text._Z4evalP7state_tiii .text._Z16static_pawn_evalP7state_t .text._Z7qsearchP7state_tiiii .text._ZL17search_time_checkP7state_t .text._Z6searchP7state_tiiiii .text._ZL11order_movesP7state_tPiS1_ij .text._ZL12history_goodP7state_tii .text._Z3seeP7state_tiiii .text._Z7StoreTTP7state_tiiijiiii)
. = ALIGN(0x1000);
*(.text._Z18initialize_zobristP7state_t)
. = ALIGN(0x1000);
*(.text._Z22SetupPrecalculatedDatav)
. = ALIGN(0x1000);
*(.text._Z18preprocess_preparev)
. = ALIGN(0x1000);
*(.text._Z18reset_piece_squareP7state_t)
. = ALIGN(0x1000);
*(.text._Z17run_epd_testsuiteP11gamestate_tP7state_tPKc)
. = ALIGN(0x1000);
*(.text._ZL15hash_extract_pvP7state_tiPc)
. = ALIGN(0x1000);
*(.text._Z11comp_to_sanP7state_tiPc)
. = ALIGN(0x1000);
*(.text._Z16gen_check_blocksP7state_tPii)
. = ALIGN(0x1000);
*(.text._Z12gen_capturesP7state_tPi)
. = ALIGN(0x1000);
*(.text._Z7ProbeTTP7state_tPiiiPjS1_S1_S1_S1_i)
. = ALIGN(0x1000);
*(.text._Z13allocate_timeP11gamestate_ti)
. = ALIGN(0x1000);
*(.text._Z6rinputPciP8_IO_FILE)
. = ALIGN(0x1000);
*(.text._Z12verify_coordP7state_tPcPi)
. = ALIGN(0x1000);
*(.text._Z13comp_to_coordP7state_tiPc)
. = ALIGN(0x1000);
*(.text._Z11is_attackedP7state_tii)
. = ALIGN(0x1000);
*(.text._Z3genP7state_tPi .text._Z4makeP7state_ti .text._Z6unmakeP7state_ti .text._Z11check_legalP7state_ti)
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
