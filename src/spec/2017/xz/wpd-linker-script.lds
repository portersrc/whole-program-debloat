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
*(.text.sum_str_to_hex)
. = ALIGN(0x1000);
*(.text.spec_mem_alloc_fds)
. = ALIGN(0x1000);
*(.text.spec_mem_init)
. = ALIGN(0x1000);
*(.text.spec_mem_load)
. = ALIGN(0x1000);
*(.text.print_sum)
. = ALIGN(0x1000);
*(.text.alone_encoder_init)
. = ALIGN(0x1000);
*(.text.lzma_stream_buffer_encode)
. = ALIGN(0x1000);
*(.text.lzma_raw_encoder_memusage)
. = ALIGN(0x1000);
*(.text.lzma_block_buffer_encode)
. = ALIGN(0x1000);
*(.text.message_mem_needed)
. = ALIGN(0x1000);
*(.text.io_write)
. = ALIGN(0x1000);
*(.text.lzma_alone_encoder)
. = ALIGN(0x1000);
*(.text.lzma_raw_encoder)
. = ALIGN(0x1000);
*(.text.is_format_lzma)
. = ALIGN(0x1000);
*(.text.lzma_alone_decoder)
. = ALIGN(0x1000);
*(.text.lzma_raw_decoder)
. = ALIGN(0x1000);
*(.text.io_close)
. = ALIGN(0x1000);
*(.text.lzma_stream_encoder)
. = ALIGN(0x1000);
*(.text.compressStream)
. = ALIGN(0x1000);
*(.text.spec_mem_write)
. = ALIGN(0x1000);
*(.text.get_check_names)
. = ALIGN(0x1000);
*(.text.print_adv_helper)
. = ALIGN(0x1000);
*(.text.message_bug)
. = ALIGN(0x1000);
*(.text.my_snprintf)
. = ALIGN(0x1000);
*(.text.parse_details)
. = ALIGN(0x1000);
*(.text.lzma_index_cat .text.index_cat_helper .text.lzma_index_decoder)
. = ALIGN(0x1000);
*(.text.io_pread)
. = ALIGN(0x1000);
*(.text.spec_mem_read)
. = ALIGN(0x1000);
*(.text.spec_mem_open)
. = ALIGN(0x1000);
*(.text.spec_mem_lseek)
. = ALIGN(0x1000);
*(.text.message_filters_to_str)
. = ALIGN(0x1000);
*(.text.parse_options)
. = ALIGN(0x1000);
*(.text.str_to_uint64)
. = ALIGN(0x1000);
*(.text.message_fatal)
. = ALIGN(0x1000);
*(.text.sha_process)
. = ALIGN(0x1000);
*(.text.uncompressStream)
. = ALIGN(0x1000);
*(.text.sha_done)
. = ALIGN(0x1000);
*(.text.sha_compress)
. = ALIGN(0x1000);
*(.text.lzma_stream_decoder)
. = ALIGN(0x1000);
*(.text.fd_grow)
. = ALIGN(0x1000);
*(.text.spec_mem_fwrite .text.spec_mem_feof .text.spec_mem_fread)
. = ALIGN(0x1000);
*(.text.lzma_code)
. = ALIGN(0x1000);
*(.text.alone_decode)
. = ALIGN(0x1000);
*(.text.alone_decoder_end)
. = ALIGN(0x1000);
*(.text.alone_decoder_memconfig)
. = ALIGN(0x1000);
*(.text.alone_encode)
. = ALIGN(0x1000);
*(.text.alone_encoder_end)
. = ALIGN(0x1000);
*(.text.block_encode)
. = ALIGN(0x1000);
*(.text.block_encoder_end)
. = ALIGN(0x1000);
*(.text.block_encoder_update)
. = ALIGN(0x1000);
*(.text.lzma2_encode)
. = ALIGN(0x1000);
*(.text.lzma2_encoder_end)
. = ALIGN(0x1000);
*(.text.lzma2_encoder_options_update)
. = ALIGN(0x1000);
*(.text.lzma_lzma2_encoder_memusage)
. = ALIGN(0x1000);
*(.text.lzma_lzma2_props_encode)
. = ALIGN(0x1000);
*(.text.lzma_lzma2_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma2_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma2_decode)
. = ALIGN(0x1000);
*(.text.lzma2_decoder_end)
. = ALIGN(0x1000);
*(.text.lzma_lzma2_decoder_memusage)
. = ALIGN(0x1000);
*(.text.lzma_lzma2_props_decode)
. = ALIGN(0x1000);
*(.text.delta_coder_end)
. = ALIGN(0x1000);
*(.text.lzma_delta_coder_memusage)
. = ALIGN(0x1000);
*(.text.lzma_delta_encoder_init)
. = ALIGN(0x1000);
*(.text.delta_encode)
. = ALIGN(0x1000);
*(.text.delta_encoder_update)
. = ALIGN(0x1000);
*(.text.lz_encoder_end)
. = ALIGN(0x1000);
*(.text.lz_encoder_update)
. = ALIGN(0x1000);
*(.text.lzma_mf_hc3_find)
. = ALIGN(0x1000);
*(.text.lzma_mf_hc3_skip)
. = ALIGN(0x1000);
*(.text.lzma_mf_hc4_find)
. = ALIGN(0x1000);
*(.text.lzma_mf_hc4_skip)
. = ALIGN(0x1000);
*(.text.lzma_mf_bt2_find)
. = ALIGN(0x1000);
*(.text.lzma_mf_bt2_skip)
. = ALIGN(0x1000);
*(.text.lzma_mf_bt3_find)
. = ALIGN(0x1000);
*(.text.lzma_mf_bt3_skip)
. = ALIGN(0x1000);
*(.text.lzma_mf_bt4_find)
. = ALIGN(0x1000);
*(.text.lzma_mf_bt4_skip)
. = ALIGN(0x1000);
*(.text.lzma_index_iter_next)
. = ALIGN(0x1000);
*(.text.iter_set_info)
. = ALIGN(0x1000);
*(.text.index_encode)
. = ALIGN(0x1000);
*(.text.index_stream_end)
. = ALIGN(0x1000);
*(.text.encoder_find)
. = ALIGN(0x1000);
*(.text.lz_decode)
. = ALIGN(0x1000);
*(.text.lz_decoder_end)
. = ALIGN(0x1000);
*(.text.lzma_lzma_encoder_init)
. = ALIGN(0x1000);
*(.text.lzma_encoder_init)
. = ALIGN(0x1000);
*(.text.lzma_encode)
. = ALIGN(0x1000);
*(.text.lzma_lzma_encode .text.rc_encode .text.length .text.match .text.lzma_lzma_optimum_fast .text.lzma_lzma_optimum_normal)
. = ALIGN(0x1000);
*(.text.lzma_lzma_encoder_memusage)
. = ALIGN(0x1000);
*(.text.index_encoder_end)
. = ALIGN(0x1000);
*(.text.lzma_stream_encoder_init)
. = ALIGN(0x1000);
*(.text.stream_encode)
. = ALIGN(0x1000);
*(.text.lzma_block_encoder_init)
. = ALIGN(0x1000);
*(.text.lzma_index_encoder_init)
. = ALIGN(0x1000);
*(.text.lzma_stream_footer_encode)
. = ALIGN(0x1000);
*(.text.lzma_filter_flags_encode .text.lzma_block_header_encode)
. = ALIGN(0x1000);
*(.text.stream_encoder_end)
. = ALIGN(0x1000);
*(.text.lzma_filter_flags_size)
. = ALIGN(0x1000);
*(.text.lzma_filters_copy .text.stream_encoder_update)
. = ALIGN(0x1000);
*(.text.lzma_lzma_props_encode)
. = ALIGN(0x1000);
*(.text.lzma_decode)
. = ALIGN(0x1000);
*(.text.lzma_decoder_uncompressed)
. = ALIGN(0x1000);
*(.text.lzma_lzma_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_lz_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_decoder_reset)
. = ALIGN(0x1000);
*(.text.lzma_lzma_decoder_memusage)
. = ALIGN(0x1000);
*(.text.lzma_lzma_props_decode)
. = ALIGN(0x1000);
*(.text.lzma_lzma2_encoder_init)
. = ALIGN(0x1000);
*(.text.lz_encoder_prepare)
. = ALIGN(0x1000);
*(.text.lzma_lz_encoder_init)
. = ALIGN(0x1000);
*(.text.lzma2_encoder_init)
. = ALIGN(0x1000);
*(.text.length_update_prices)
. = ALIGN(0x1000);
*(.text.lzma_lzma_encoder_reset)
. = ALIGN(0x1000);
*(.text.lzma_lzma_encoder_create)
. = ALIGN(0x1000);
*(.text.auto_decoder_init)
. = ALIGN(0x1000);
*(.text.auto_decode)
. = ALIGN(0x1000);
*(.text.lzma_alone_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_stream_decoder_init)
. = ALIGN(0x1000);
*(.text.auto_decoder_end)
. = ALIGN(0x1000);
*(.text.auto_decoder_get_check)
. = ALIGN(0x1000);
*(.text.auto_decoder_memconfig)
. = ALIGN(0x1000);
*(.text.block_decode)
. = ALIGN(0x1000);
*(.text.lzma_crc64)
. = ALIGN(0x1000);
*(.text.lzma_check_finish)
. = ALIGN(0x1000);
*(.text.block_decoder_end)
. = ALIGN(0x1000);
*(.text.decoder_find)
. = ALIGN(0x1000);
*(.text.index_tree_append)
. = ALIGN(0x1000);
*(.text.lzma_index_init)
. = ALIGN(0x1000);
*(.text.index_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_index_append)
. = ALIGN(0x1000);
*(.text.index_decode)
. = ALIGN(0x1000);
*(.text.index_decoder_end)
. = ALIGN(0x1000);
*(.text.index_tree_node_end)
. = ALIGN(0x1000);
*(.text.index_decoder_memconfig)
. = ALIGN(0x1000);
*(.text.lzma_index_hash_append .text.lzma_index_hash_decode .text.stream_decode)
. = ALIGN(0x1000);
*(.text.lzma_crc32)
. = ALIGN(0x1000);
*(.text.process)
. = ALIGN(0x1000);
*(.text.lzma_block_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_raw_coder_init)
. = ALIGN(0x1000);
*(.text.lzma_stream_footer_decode)
. = ALIGN(0x1000);
*(.text.lzma_block_header_decode .text.lzma_filter_flags_decode)
. = ALIGN(0x1000);
*(.text.lzma_raw_decoder_memusage)
. = ALIGN(0x1000);
*(.text.stream_decoder_end)
. = ALIGN(0x1000);
*(.text.stream_decoder_get_check)
. = ALIGN(0x1000);
*(.text.stream_decoder_memconfig)
. = ALIGN(0x1000);
*(.text.lz_encode)
. = ALIGN(0x1000);
*(.text.lzma_delta_props_encode)
. = ALIGN(0x1000);
*(.text.lzma_delta_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_delta_coder_init)
. = ALIGN(0x1000);
*(.text.delta_decode)
. = ALIGN(0x1000);
*(.text.lzma_delta_props_decode)
. = ALIGN(0x1000);
*(.text.simple_code)
. = ALIGN(0x1000);
*(.text.simple_coder_end)
. = ALIGN(0x1000);
*(.text.simple_coder_update)
. = ALIGN(0x1000);
*(.text.lzma_simple_props_size)
. = ALIGN(0x1000);
*(.text.lzma_simple_props_encode)
. = ALIGN(0x1000);
*(.text.lzma_simple_props_decode)
. = ALIGN(0x1000);
*(.text.lzma_simple_x86_encoder_init)
. = ALIGN(0x1000);
*(.text.x86_code)
. = ALIGN(0x1000);
*(.text.lzma_simple_x86_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_simple_powerpc_encoder_init)
. = ALIGN(0x1000);
*(.text.powerpc_code)
. = ALIGN(0x1000);
*(.text.lzma_simple_powerpc_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_simple_ia64_encoder_init)
. = ALIGN(0x1000);
*(.text.ia64_code)
. = ALIGN(0x1000);
*(.text.lzma_simple_ia64_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_simple_arm_encoder_init)
. = ALIGN(0x1000);
*(.text.arm_code)
. = ALIGN(0x1000);
*(.text.lzma_simple_arm_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_simple_armthumb_encoder_init)
. = ALIGN(0x1000);
*(.text.armthumb_code)
. = ALIGN(0x1000);
*(.text.lzma_simple_armthumb_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_simple_sparc_encoder_init)
. = ALIGN(0x1000);
*(.text.sparc_code)
. = ALIGN(0x1000);
*(.text.lzma_simple_sparc_decoder_init)
. = ALIGN(0x1000);
*(.text.lzma_simple_coder_init)
. = ALIGN(0x1000);
*(.text.set_delta)
. = ALIGN(0x1000);
*(.text.set_bcj)
. = ALIGN(0x1000);
*(.text.set_lzma)
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
